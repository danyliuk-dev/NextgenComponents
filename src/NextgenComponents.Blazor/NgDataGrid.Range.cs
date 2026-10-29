using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web.Virtualization;
namespace NextgenComponents.Blazor;

public partial class NgDataGrid<TItem> {
    [Parameter] public Func<NgDataRangeRequest,CancellationToken,Task<NgDataRangeResult<TItem>>>? ReadRange {get;set;}
    [Parameter] public Func<NgGroupedRangeRequest,CancellationToken,Task<NgGroupedRangeResult<TItem>>>? ReadGroupedRange {get;set;}
    [Parameter] public string ExpandWindowGroupsText {get;set;}="Expand loaded groups";
    [Parameter] public string CollapseWindowGroupsText {get;set;}="Collapse loaded groups";
    private bool IsRange=>ReadRange is not null || ReadGroupedRange is not null;
    private IReadOnlyList<GridEntry> groupedRangeEntries=[];
    private int loadedSlotCount;
    private string previousCollapsed="";
    private string CollapseSignature=>string.Join("|",(CollapsibleGroups?CollapsedGroups:[]).Order(StringComparer.Ordinal).Select(id=>$"{id.Length}:{id}"));
    [Parameter] public string LoadedWindowText {get;set;}="Loaded window";
    [Parameter] public string SelectWindowText {get;set;}="Select loaded window";
    private VirtualRows<GridEntry>? rangeRows;
    private int rangeStart;
    private long rangeEpoch;
    private bool rangeKnown;
    private Delegate? ReaderIdentity=>(Delegate?)ReadGroupedRange??(Delegate?)ReadRange??(Delegate?)ReadGroupedData??ReadData;

    private void ValidateRangeMode() {
        if(!IsRange)return;
        if(!Virtualize || ReadData is not null || ReadGroupedData is not null || Items.Count>0 || Selectors.Count>0 || GroupAggregates.Count>0 || ReadRange is not null && (ReadGroupedRange is not null || RemoteGroupKeys.Count>0))
            throw new ArgumentException("ReadRange requires Virtualize and cannot be combined with Items, page readers or grouping.");
        if(ReadGroupedRange is not null)NgGroupedData.ValidateKeys(RemoteGroupKeys);
        if(RowHeight>128 || Math.Ceiling(ViewportHeight/RowHeight)>128)
            throw new ArgumentException("Range mode supports rows up to 128px and at most 128 visible rows.");
    }
    private void ResetRange() {
        ++revision;pending?.Cancel();pending?.Dispose();pending=null;
        ++rangeEpoch;groupedRangeEntries=[];loadedSlotCount=0;rangeKnown=false;rangeStart=0;total=0;filtered=[];groups=[];loading=error=false;
        CancelExport();InvalidateEdit();
    }
    private async Task RetryReadAsync() {
        if(!IsRange){await ReloadAsync();return;}
        if(rangeRows is not null)await rangeRows.RefreshAsync();
    }
    private async ValueTask<ItemsProviderResult<GridEntry>> ReadRangeRows(ItemsProviderRequest demand) {
        var reader=ReadRange;var groupedReader=ReadGroupedRange;
        if(disposed || !IsRange)return new([],0);
        var ticket=++revision;var epoch=rangeEpoch;
        pending?.Cancel();pending?.Dispose();
        pending=CancellationTokenSource.CreateLinkedTokenSource(demand.CancellationToken);
        var token=pending.Token;
        var request=new NgDataRangeRequest(demand.StartIndex,demand.Count,search,Array.AsReadOnly(sorts.ToArray()));
        rangeStart=request.StartIndex;loading=true;error=false;filtered=[];groups=[];groupedRangeEntries=[];loadedSlotCount=0;CancelExport();
        await InvokeAsync(StateHasChanged);
        try {
            NgDataRange.ValidateRequest(request);
            if(groupedReader is not null) {
                var groupedRequest=new NgGroupedRangeRequest(request.StartIndex,request.Count,search,request.Sorts,Array.AsReadOnly(RemoteGroupKeys.ToArray()),Array.AsReadOnly((CollapsibleGroups?CollapsedGroups:[]).Order(StringComparer.Ordinal).ToArray()));
                NgGroupedRange.ValidateRequest(groupedRequest);
                var answer=await groupedReader(groupedRequest,token);
                token.ThrowIfCancellationRequested();
                if(disposed || ticket!=revision || epoch!=rangeEpoch)return new([],0);
                var window=NgGroupedRange.Validate(answer,groupedRequest,RowId);
                var metadata=window.Groups.ToDictionary(g=>NgDataOperations.GroupId(g.Path),StringComparer.Ordinal);
                groupedRangeEntries=window.Entries.Select(e=>e.IsGroup?new GridEntry(new NgGridGroup<TItem>(e.Path,[],[],metadata[NgDataOperations.GroupId(e.Path)].Count,metadata[NgDataOperations.GroupId(e.Path)].Summaries),default,false):new GridEntry(null,e.Item,true)).ToArray();
                filtered=groupedRangeEntries.Where(e=>e.HasRow).Select(e=>e.Row!).ToArray();
                groups=groupedRangeEntries.Where(e=>e.Group is not null).Select(e=>e.Group!).ToArray();
                total=window.Total;loadedSlotCount=window.Entries.Count;rangeKnown=true;
                return new(groupedRangeEntries,total);
            }
            var result=await reader!(request,token);
            token.ThrowIfCancellationRequested();
            if(disposed || ticket!=revision || epoch!=rangeEpoch)return new([],0);
            var rows=NgDataRange.Validate(result,request,RowId);
            filtered=rows;loadedSlotCount=rows.Count;total=result.Total;rangeKnown=true;
            return new(rows.Select(r=>new GridEntry(null,r,true)),total);
        } catch(OperationCanceledException) when(token.IsCancellationRequested) {
            return new([],0);
        } catch {
            if(!disposed && ticket==revision && epoch==rangeEpoch){error=true;filtered=[];}
            // Preserve scroll extent for retry, but never expose stale rows as current.
            return new(Enumerable.Repeat(new GridEntry(null,default,false),Math.Min(request.Count,Math.Max(0,total-request.StartIndex))),total);
        } finally {
            if(!disposed && ticket==revision && epoch==rangeEpoch){loading=false;await InvokeAsync(StateHasChanged);}
        }
    }
}

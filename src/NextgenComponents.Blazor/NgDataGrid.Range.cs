using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web.Virtualization;
namespace NextgenComponents.Blazor;

public partial class NgDataGrid<TItem> {
    [Parameter] public Func<NgDataRangeRequest,CancellationToken,Task<NgDataRangeResult<TItem>>>? ReadRange {get;set;}
    [Parameter] public string LoadedWindowText {get;set;}="Loaded window";
    [Parameter] public string SelectWindowText {get;set;}="Select loaded window";
    private VirtualRows<GridEntry>? rangeRows;
    private int rangeStart;
    private long rangeEpoch;
    private bool rangeKnown;
    private Delegate? ReaderIdentity=>(Delegate?)ReadRange??(Delegate?)ReadGroupedData??ReadData;

    private void ValidateRangeMode() {
        if(ReadRange is null)return;
        if(!Virtualize || ReadData is not null || ReadGroupedData is not null || Items.Count>0 || Selectors.Count>0 || GroupAggregates.Count>0 || RemoteGroupKeys.Count>0)
            throw new ArgumentException("ReadRange requires Virtualize and cannot be combined with Items, page readers or grouping.");
        if(RowHeight>128 || Math.Ceiling(ViewportHeight/RowHeight)>128)
            throw new ArgumentException("Range mode supports rows up to 128px and at most 128 visible rows.");
    }
    private void ResetRange() {
        ++revision;pending?.Cancel();pending?.Dispose();pending=null;
        ++rangeEpoch;rangeKnown=false;rangeStart=0;total=0;filtered=[];groups=[];loading=error=false;
        CancelExport();InvalidateEdit();
    }
    private async Task RetryReadAsync() {
        if(ReadRange is null){await ReloadAsync();return;}
        if(rangeRows is not null)await rangeRows.RefreshAsync();
    }
    private async ValueTask<ItemsProviderResult<GridEntry>> ReadRangeRows(ItemsProviderRequest demand) {
        var reader=ReadRange;
        if(disposed || reader is null)return new([],0);
        var ticket=++revision;var epoch=rangeEpoch;
        pending?.Cancel();pending?.Dispose();
        pending=CancellationTokenSource.CreateLinkedTokenSource(demand.CancellationToken);
        var token=pending.Token;
        var request=new NgDataRangeRequest(demand.StartIndex,demand.Count,search,Array.AsReadOnly(sorts.ToArray()));
        rangeStart=request.StartIndex;loading=true;error=false;filtered=[];CancelExport();
        await InvokeAsync(StateHasChanged);
        try {
            NgDataRange.ValidateRequest(request);
            var result=await reader(request,token);
            token.ThrowIfCancellationRequested();
            if(disposed || ticket!=revision || epoch!=rangeEpoch)return new([],0);
            var rows=NgDataRange.Validate(result,request,RowId);
            filtered=rows;total=result.Total;rangeKnown=true;
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

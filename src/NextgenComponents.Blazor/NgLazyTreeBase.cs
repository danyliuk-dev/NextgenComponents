using Microsoft.AspNetCore.Components;
using Microsoft.JSInterop;
namespace NextgenComponents.Blazor;

/// <summary>Lazy child cache scoped to an immutable root collection and DataVersion.</summary>
public abstract class NgLazyTreeBase<T> : ComponentBase, IDisposable
{
    [Parameter] public IReadOnlyList<NgTreeNode<T>> Items { get; set; }=[];
    [Parameter] public Func<NgTreeNode<T>,CancellationToken,Task<IReadOnlyList<NgTreeNode<T>>>>? LoadChildren { get; set; }
    [Parameter] public object? DataVersion { get; set; }
    [Parameter] public string LoadingText { get; set; }="Loading children…";
    [Parameter] public string ErrorText { get; set; }="Unable to load children. Expand to retry.";
    [Inject] private IJSRuntime TreeJS { get; set; }=default!;
    protected ElementReference CheckRoot;
    [Parameter] public bool ShowCheckActions { get; set; }
    [Parameter] public string CheckLoadedText { get; set; }="Check loaded nodes";
    [Parameter] public string ClearLoadedText { get; set; }="Clear loaded checks";
    private IReadOnlyList<string> CheckTargets=>ResolvedItems.Where(n=>!n.Disabled && (CanCheck?.Invoke(n)??true)).SelectMany(n=>NgDataOperations.TreeCheckTargets(n,true,CanCheck)).ToArray();
    protected bool CanCheckLoaded(bool value)=>!disposed && Checkboxes && ShowCheckActions && !CheckingReadOnly && CheckedIdsChanged.HasDelegate && CheckTargets.Any(id=>CheckedIds.Contains(id)!=value);
    protected async Task CheckLoaded(bool value){
        if(!CanCheckLoaded(value))return;
        var next=new HashSet<string>(CheckedIds);
        foreach(var id in CheckTargets){if(value)next.Add(id);else next.Remove(id);}
        await CheckedIdsChanged.InvokeAsync(next);
    }
    [Parameter] public bool CheckChildren { get; set; }
    protected bool? CheckState(NgTreeNode<T> node)=>NgDataOperations.TreeCheckState(node,CheckedIds,CheckChildren,CanCheck);
    protected string CheckAria(NgTreeNode<T> node)=>CheckState(node) switch {true=>"true",false=>"false",_=>"mixed"};
    protected override async Task OnAfterRenderAsync(bool firstRender){
        if(!Checkboxes || disposed)return;
        var module=await TreeJS.InvokeAsync<IJSObjectReference>("import","./_content/NextgenComponents.Blazor/nextgen.js");
        await module.InvokeVoidAsync("treeChecks",CheckRoot);await module.DisposeAsync();
    }
    [Parameter] public bool Checkboxes { get; set; }
    [Parameter] public HashSet<string> CheckedIds { get; set; }=[];
    [Parameter] public EventCallback<HashSet<string>> CheckedIdsChanged { get; set; }
    [Parameter] public bool CheckingReadOnly { get; set; }
    [Parameter] public Func<NgTreeNode<T>,bool>? CanCheck { get; set; }
    [Parameter] public Func<T,string>? CheckLabel { get; set; }
    protected bool CanToggleCheck(NgTreeNode<T> node)=>!disposed && Checkboxes && !CheckingReadOnly && CheckedIdsChanged.HasDelegate && !node.Disabled && (CanCheck?.Invoke(node)??true);
    protected async Task ToggleCheck(string id,IReadOnlyList<NgTreeRow<T>> visible){
        var node=visible.FirstOrDefault(r=>r.Node.Id==id)?.Node;
        if(node is null || !CanToggleCheck(node))return;
        var next=NgDataOperations.ToggleTreeCheck(node,CheckedIds,CheckChildren,CanCheck);
        await CheckedIdsChanged.InvokeAsync(next);
    }
    private readonly Dictionary<string,IReadOnlyList<NgTreeNode<T>>> cache=[];
    private readonly HashSet<string> loading=[],errors=[];
    private IReadOnlyList<NgTreeNode<T>>? source;
    private Delegate? loader;
    private object? version;
    private CancellationTokenSource lifetime=new();
    private int revision;
    private bool disposed;
    protected bool IsLoading(string id)=>loading.Contains(id);
    protected bool HasError(string id)=>errors.Contains(id);
    protected IReadOnlyList<NgTreeNode<T>> ResolvedItems=>Resolve(Items);
    private IReadOnlyList<NgTreeNode<T>> Resolve(IReadOnlyList<NgTreeNode<T>> nodes)=>nodes.Select(n=>cache.TryGetValue(n.Id,out var children)
        ? n with { Children=Resolve(children),HasChildren=children.Count>0 }
        : n with { Children=Resolve(n.Children??[]) }).ToArray();
    protected override void OnParametersSet(){
        // Validate before resolving, including cycles and reused IDs.
        NgDataOperations.Flatten(Items,new HashSet<string>(),_=>"");
        if(!ReferenceEquals(source,Items) || !Equals(loader,LoadChildren) || !Equals(version,DataVersion)){
            ++revision;lifetime.Cancel();lifetime.Dispose();lifetime=new();cache.Clear();loading.Clear();errors.Clear();
            source=Items;loader=LoadChildren;version=DataVersion;
        }
    }
    protected async Task<bool> EnsureChildren(NgTreeNode<T> node){
        if(!node.HasChildren || node.Children?.Count>0 || cache.ContainsKey(node.Id))return true;
        if(LoadChildren is null || loading.Contains(node.Id))return false;
        var ticket=revision;loading.Add(node.Id);errors.Remove(node.Id);StateHasChanged();
        try{
            var children=await LoadChildren(node,lifetime.Token);
            if(disposed || revision!=ticket)return false;
            NgDataOperations.Flatten(children,new HashSet<string>(),_=>"");
            cache[node.Id]=children.ToArray();
            try{NgDataOperations.Flatten(ResolvedItems,new HashSet<string>(),_=>"");}
            catch{cache.Remove(node.Id);throw;}
            return true;
        }catch(Exception){if(!disposed && revision==ticket)errors.Add(node.Id);return false;}
        finally{if(!disposed && revision==ticket)loading.Remove(node.Id);}
    }
    public void Dispose(){disposed=true;++revision;lifetime.Cancel();lifetime.Dispose();}
}

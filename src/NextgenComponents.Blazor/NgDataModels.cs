using System.Globalization;
using Microsoft.AspNetCore.Components;
namespace NextgenComponents.Blazor;

public sealed record NgDataColumn<T>(string Key, string Title, Func<T,object?> Value,
    bool Sortable = true, Func<T,string>? Format = null, RenderFragment<T>? Template = null)
{
    public string Text(T item) => Format?.Invoke(item) ?? Convert.ToString(Value(item),CultureInfo.CurrentCulture) ?? "";
}
public sealed record NgTreeNode<T>(string Id,T Item,IReadOnlyList<NgTreeNode<T>>? Children=null,bool Disabled=false,bool HasChildren=false);
public sealed record NgTreeRow<T>(NgTreeNode<T> Node,int Depth,string? ParentId,bool Expanded);
public sealed record NgBreadcrumbItem(string Id,string Label);

public sealed record NgSortDescriptor(string Key,bool Descending=false);
public sealed record NgDataRequest(int Page,int PageSize,string Search,IReadOnlyList<NgSortDescriptor> Sorts);
public sealed record NgDataResult<T>(IReadOnlyList<T> Items,int Total);

public static class NgDataOperations
{
    // A branch check represents its own record plus eligible, loaded descendants.
    // Protected nodes are subtree barriers; their existing IDs are preserved.
    public static IReadOnlyList<string> TreeCheckTargets<T>(NgTreeNode<T> node,bool cascade,Func<NgTreeNode<T>,bool>? canCheck=null) {
        var ids=new List<string>{node.Id};
        void Walk(NgTreeNode<T> parent){foreach(var child in parent.Children??[]){if(child.Disabled || !(canCheck?.Invoke(child)??true))continue;ids.Add(child.Id);Walk(child);}}
        if(cascade && !node.Disabled && (canCheck?.Invoke(node)??true))Walk(node);
        return ids;
    }
    public static bool? TreeCheckState<T>(NgTreeNode<T> node,ISet<string> checkedIds,bool cascade,Func<NgTreeNode<T>,bool>? canCheck=null) {
        var targets=TreeCheckTargets(node,cascade,canCheck);var count=targets.Count(checkedIds.Contains);
        return count==0?false:count==targets.Count?true:null;
    }
    public static HashSet<string> ToggleTreeCheck<T>(NgTreeNode<T> node,ISet<string> checkedIds,bool cascade,Func<NgTreeNode<T>,bool>? canCheck=null) {
        var next=new HashSet<string>(checkedIds);
        if(node.Disabled || !(canCheck?.Invoke(node)??true))return next;
        var targets=TreeCheckTargets(node,cascade,canCheck);var clear=targets.All(checkedIds.Contains);
        foreach(var id in targets){if(clear)next.Remove(id);else next.Add(id);}
        return next;
    }

    public static int PageCount(int total,int size) => Math.Max(1,(int)Math.Ceiling(Math.Max(0,total)/(double)Math.Max(1,size)));
    public static int ClampPage(int page,int total,int size) => Math.Clamp(page,1,PageCount(total,size));
    public static IReadOnlyList<T> Query<T>(IEnumerable<T> source,IReadOnlyList<NgDataColumn<T>> columns,string search,string? sortKey,bool descending)
    {
        return Query(source,columns,search,sortKey is null?[]:[new(sortKey,descending)]);
    }
    public static IReadOnlyList<T> Query<T>(IEnumerable<T> source,IReadOnlyList<NgDataColumn<T>> columns,string search,IReadOnlyList<NgSortDescriptor> sorts)
    {
        var rows=source.Where(row=>string.IsNullOrWhiteSpace(search)||columns.Any(c=>c.Text(row).Contains(search.Trim(),StringComparison.CurrentCultureIgnoreCase)));
        IOrderedEnumerable<T>? ordered=null;
        foreach(var sort in sorts) {
            var column=columns.FirstOrDefault(c=>c.Key==sort.Key && c.Sortable);
            if(column is null)continue;
            ordered=ordered is null
                ? sort.Descending?rows.OrderByDescending(column.Value,ValueComparer.Instance):rows.OrderBy(column.Value,ValueComparer.Instance)
                : sort.Descending?ordered.ThenByDescending(column.Value,ValueComparer.Instance):ordered.ThenBy(column.Value,ValueComparer.Instance);
        }
        return (ordered??rows).ToArray();
    }
    public static int CompareValues(object? a,object? b) => ValueComparer.Instance.Compare(a,b);
    private sealed class ValueComparer : IComparer<object?>
    {
        public static readonly ValueComparer Instance=new();
        public int Compare(object? a,object? b) => a is null ? (b is null?0:-1) : b is null ? 1 : a is string sa && b is string sb ? StringComparer.CurrentCultureIgnoreCase.Compare(sa,sb) : a is IComparable comparable && a.GetType()==b.GetType() ? comparable.CompareTo(b) : StringComparer.CurrentCultureIgnoreCase.Compare(Convert.ToString(a),Convert.ToString(b));
    }
    public static IReadOnlyList<NgTreeRow<T>> Flatten<T>(IReadOnlyList<NgTreeNode<T>> roots,ISet<string> expanded,Func<T,string> label,string search="",Comparison<NgTreeNode<T>>? comparison=null)
    {
        var ids=new HashSet<string>();
        void Validate(IEnumerable<NgTreeNode<T>> nodes) { foreach(var node in nodes) { if(string.IsNullOrWhiteSpace(node.Id) || !ids.Add(node.Id))throw new ArgumentException($"Duplicate or cyclic tree ID: {node.Id}"); Validate(node.Children??[]); } }
        Validate(roots);
        var filtering=!string.IsNullOrWhiteSpace(search);
        List<NgTreeRow<T>> Walk(IEnumerable<NgTreeNode<T>> nodes,int depth,string? parent) {
            var ordered=nodes.ToList();if(comparison is not null) ordered=ordered.Select((n,i)=>(n,i)).OrderBy(x=>x.n,Comparer<NgTreeNode<T>>.Create(comparison)).Select(x=>x.n).ToList();
            var result=new List<NgTreeRow<T>>();
            foreach(var node in ordered) {
                var children=Walk(node.Children??[],depth+1,node.Id);
                var match=label(node.Item).Contains(search.Trim(),StringComparison.CurrentCultureIgnoreCase);
                if(filtering && !match && children.Count==0)continue;
                var open=filtering ? children.Count>0 : (node.Children?.Count>0 || node.HasChildren) && expanded.Contains(node.Id);
                result.Add(new(node,depth,parent,open));
                if(open)result.AddRange(children);
            }
            return result;
        }
        return Walk(roots,0,null);
    }
}

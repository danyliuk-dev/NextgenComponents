using System.Globalization;
using Microsoft.AspNetCore.Components;
namespace NextgenComponents.Blazor;

public sealed record NgDataColumn<T>(string Key, string Title, Func<T,object?> Value,
    bool Sortable = true, Func<T,string>? Format = null, RenderFragment<T>? Template = null)
{
    public string Text(T item) => Format?.Invoke(item) ?? Convert.ToString(Value(item),CultureInfo.CurrentCulture) ?? "";
}
public sealed record NgTreeNode<T>(string Id,T Item,IReadOnlyList<NgTreeNode<T>>? Children=null,bool Disabled=false);
public sealed record NgTreeRow<T>(NgTreeNode<T> Node,int Depth,string? ParentId,bool Expanded);
public sealed record NgBreadcrumbItem(string Id,string Label);

public static class NgDataOperations
{
    public static int PageCount(int total,int size) => Math.Max(1,(int)Math.Ceiling(Math.Max(0,total)/(double)Math.Max(1,size)));
    public static int ClampPage(int page,int total,int size) => Math.Clamp(page,1,PageCount(total,size));
    public static IReadOnlyList<T> Query<T>(IEnumerable<T> source,IReadOnlyList<NgDataColumn<T>> columns,string search,string? sortKey,bool descending)
    {
        var rows=source.Where(row=>string.IsNullOrWhiteSpace(search)||columns.Any(c=>c.Text(row).Contains(search.Trim(),StringComparison.CurrentCultureIgnoreCase)));
        var column=columns.FirstOrDefault(c=>c.Key==sortKey && c.Sortable);
        if(column is not null) rows=descending ? rows.OrderByDescending(column.Value,ValueComparer.Instance) : rows.OrderBy(column.Value,ValueComparer.Instance);
        return rows.ToArray();
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
        void Validate(IEnumerable<NgTreeNode<T>> nodes) { foreach(var node in nodes) { if(!ids.Add(node.Id))throw new ArgumentException($"Duplicate or cyclic tree ID: {node.Id}"); Validate(node.Children??[]); } }
        Validate(roots);
        var filtering=!string.IsNullOrWhiteSpace(search);
        List<NgTreeRow<T>> Walk(IEnumerable<NgTreeNode<T>> nodes,int depth,string? parent) {
            var ordered=nodes.ToList();if(comparison is not null) ordered=ordered.Select((n,i)=>(n,i)).OrderBy(x=>x.n,Comparer<NgTreeNode<T>>.Create(comparison)).Select(x=>x.n).ToList();
            var result=new List<NgTreeRow<T>>();
            foreach(var node in ordered) {
                var children=Walk(node.Children??[],depth+1,node.Id);
                var match=label(node.Item).Contains(search.Trim(),StringComparison.CurrentCultureIgnoreCase);
                if(filtering && !match && children.Count==0)continue;
                var open=filtering ? children.Count>0 : expanded.Contains(node.Id);
                result.Add(new(node,depth,parent,open));
                if(open)result.AddRange(children);
            }
            return result;
        }
        return Walk(roots,0,null);
    }
}

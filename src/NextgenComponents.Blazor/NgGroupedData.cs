namespace NextgenComponents.Blazor;

/// A group-aware record page. GroupKeys are application-defined field names, not executable selectors.
public sealed record NgGroupedDataRequest(int Page,int PageSize,string Search,IReadOnlyList<NgSortDescriptor> Sorts,IReadOnlyList<string> GroupKeys);
public sealed record NgGroupSummary(string Title,double? Value);
public sealed record NgRemoteGroup(IReadOnlyList<string> Path,int Count,IReadOnlyList<NgGroupSummary> Summaries);
public sealed record NgGroupedItem<T>(T Item,IReadOnlyList<string> Path);
public sealed record NgGroupedDataResult<T>(IReadOnlyList<NgGroupedItem<T>> Items,int Total,IReadOnlyList<NgRemoteGroup> Groups);

public static class NgGroupedData
{
    public static void ValidateKeys(IReadOnlyList<string> keys) {
        if(keys.Count is <1 or >8 || keys.Any(string.IsNullOrWhiteSpace) || keys.Distinct(StringComparer.Ordinal).Count()!=keys.Count)
            throw new ArgumentException("Provide one to eight distinct nonblank group keys.");
    }

    // Validate and copy the entire envelope before exposing any rows or metadata.
    public static IReadOnlyList<NgGridGroup<T>> Validate<T>(NgGroupedDataResult<T> result,NgGroupedDataRequest request,Func<T,string> rowId) {
        ValidateKeys(request.GroupKeys);
        var expected=(int)Math.Min(request.PageSize,Math.Max(0,(long)result.Total-((long)request.Page-1)*request.PageSize));
        if(request.Page<1 || request.PageSize<1 || result.Total<0 || result.Items.Count!=expected)throw new ArgumentException("Invalid grouped page size or total.");
        var ids=new HashSet<string>(StringComparer.Ordinal);
        var paths=new Dictionary<string,IReadOnlyList<string>>(StringComparer.Ordinal);
        var members=new Dictionary<string,List<T>>(StringComparer.Ordinal);
        var children=new Dictionary<string,List<string>>(StringComparer.Ordinal){{"",[]}};
        var previous=new string?[request.GroupKeys.Count];
        var visited=Enumerable.Range(0,request.GroupKeys.Count).Select(_=>new HashSet<string>(StringComparer.Ordinal)).ToArray();
        foreach(var row in result.Items){
            var id=rowId(row.Item);
            if(string.IsNullOrWhiteSpace(id) || !ids.Add(id) || row.Path.Count!=request.GroupKeys.Count || row.Path.Any(k=>k is null))throw new ArgumentException("Invalid grouped row identity or path.");
            for(var depth=1;depth<=row.Path.Count;depth++){
                var path=row.Path.Take(depth).ToArray();var key=NgDataOperations.GroupId(path);
                if(previous[depth-1]!=key && !visited[depth-1].Add(key))throw new ArgumentException("Group records must be contiguous.");
                previous[depth-1]=key;
                if(!members.TryGetValue(key,out var rows)){
                    members[key]=rows=[];paths[key]=Array.AsReadOnly(path);children[key]=[];
                    children[NgDataOperations.GroupId(path.Take(depth-1))].Add(key);
                }
                rows.Add(row.Item);
            }
        }
        var metadata=new Dictionary<string,NgRemoteGroup>(StringComparer.Ordinal);
        foreach(var group in result.Groups){
            if(group.Path.Count<1 || group.Path.Count>request.GroupKeys.Count || group.Path.Any(k=>k is null))throw new ArgumentException("Invalid metadata path.");
            var id=NgDataOperations.GroupId(group.Path);
            if(!members.TryGetValue(id,out var rows) || !metadata.TryAdd(id,group) || group.Count<rows.Count || group.Count>result.Total)throw new ArgumentException("Inconsistent group count or duplicate metadata.");
            if(group.Summaries.Any(s=>string.IsNullOrWhiteSpace(s.Title) || s.Value is {} v && !double.IsFinite(v)) || group.Summaries.Select(s=>s.Title).Distinct(StringComparer.Ordinal).Count()!=group.Summaries.Count)throw new ArgumentException("Invalid group summaries.");
        }
        if(metadata.Count!=members.Count)throw new ArgumentException("Missing group metadata.");
        foreach(var (parent,list) in children){
            var maximum=parent==""?result.Total:metadata[parent].Count;
            if(list.Sum(id=>(long)metadata[id].Count)>maximum)throw new ArgumentException("Sibling counts exceed parent total.");
        }
        NgGridGroup<T> Build(string id)=>new(paths[id],Array.AsReadOnly(members[id].ToArray()),Array.AsReadOnly(children[id].Select(Build).ToArray()),metadata[id].Count,Array.AsReadOnly(metadata[id].Summaries.ToArray()));
        return Array.AsReadOnly(children[""].Select(Build).ToArray());
    }

    /// Reference server adapter: filter/sort first, then call this over the full result.
    public static NgGroupedDataResult<T> Page<T>(IReadOnlyList<T> filteredSorted,IReadOnlyList<Func<T,string>> selectors,IReadOnlyList<NgGroupAggregate<T>> aggregates,int page,int size){
        if(selectors.Count is <1 or >8 || page<1 || size<1)throw new ArgumentException("Invalid grouped page request.");
        var tree=NgDataOperations.GroupTree(filteredSorted,selectors);
        var flat=NgDataOperations.AllGroups(tree).Where(g=>g.Children.Count==0).SelectMany(g=>g.Items.Select(r=>new NgGroupedItem<T>(r,g.Path))).ToArray();
        var skip=Math.Min(flat.LongLength,((long)page-1)*size);
        var rows=flat.Skip((int)skip).Take(size).ToArray();
        var needed=rows.SelectMany(r=>Enumerable.Range(1,r.Path.Count).Select(n=>NgDataOperations.GroupId(r.Path.Take(n)))).ToHashSet();
        var metadata=NgDataOperations.AllGroups(tree).Where(g=>needed.Contains(g.Id)).Select(g=>new NgRemoteGroup(g.Path,g.Items.Count,aggregates.Select(a=>new NgGroupSummary(a.Title,a.Calculate(g.Items))).ToArray())).ToArray();
        return new(rows,filteredSorted.Count,metadata);
    }
}

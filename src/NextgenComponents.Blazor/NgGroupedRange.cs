namespace NextgenComponents.Blazor;

/// <summary>Offsets count visible slots (group headers and records), after server-side collapse.</summary>
public sealed record NgGroupedRangeRequest(int StartIndex,int Count,string Search,IReadOnlyList<NgSortDescriptor> Sorts,IReadOnlyList<string> GroupKeys,IReadOnlyList<string> CollapsedGroups);
public sealed record NgGroupedRangeEntry<T>(IReadOnlyList<string> Path,bool IsGroup,T? Item);
public sealed record NgGroupedRangeResult<T>(int StartIndex,int Total,int RecordTotal,IReadOnlyList<NgGroupedRangeEntry<T>> Entries,IReadOnlyList<NgRemoteGroup> Groups);

public static class NgGroupedRange {
    public static void ValidateRequest(NgGroupedRangeRequest request) {
        NgDataRange.ValidateRequest(new(request.StartIndex,request.Count,request.Search,request.Sorts));
        NgGroupedData.ValidateKeys(request.GroupKeys);
        if(request.CollapsedGroups is null || request.CollapsedGroups.Count>NgDataRange.MaxTotal || request.CollapsedGroups.Any(string.IsNullOrWhiteSpace) || request.CollapsedGroups.Distinct(StringComparer.Ordinal).Count()!=request.CollapsedGroups.Count)
            throw new ArgumentException("Invalid collapsed group IDs.");
    }

    /// <summary>Copies and validates the complete window before any entry becomes interactive.</summary>
    public static NgGroupedRangeResult<T> Validate<T>(NgGroupedRangeResult<T> result,NgGroupedRangeRequest request,Func<T,string> rowId) {
        ValidateRequest(request);
        if(result.StartIndex!=request.StartIndex || result.Total<0 || result.Total>NgDataRange.MaxTotal || result.RecordTotal<0 || result.RecordTotal>NgDataRange.MaxTotal || (result.RecordTotal==0)!=(result.Total==0) || result.Entries.Count!=Math.Min(request.Count,Math.Max(0,result.Total-request.StartIndex)))
            throw new ArgumentException("Invalid grouped range offset, count or totals.");
        if(request.StartIndex==0 && result.Entries.Count>0 && (!result.Entries[0].IsGroup || result.Entries[0].Path.Count!=1))throw new ArgumentException("The first slot must be a root group header.");
        var metadata=new Dictionary<string,NgRemoteGroup>(StringComparer.Ordinal);
        foreach(var g in result.Groups) {
            if(g.Path.Count<1 || g.Path.Count>request.GroupKeys.Count || g.Path.Any(k=>k is null) || g.Count<1 || g.Count>result.RecordTotal || g.Summaries.Any(s=>string.IsNullOrWhiteSpace(s.Title) || s.Value is {} v && !double.IsFinite(v)) || g.Summaries.Select(s=>s.Title).Distinct(StringComparer.Ordinal).Count()!=g.Summaries.Count)
                throw new ArgumentException("Invalid group metadata.");
            if(!metadata.TryAdd(NgDataOperations.GroupId(g.Path),new(Array.AsReadOnly(g.Path.ToArray()),g.Count,Array.AsReadOnly(g.Summaries.ToArray()))))throw new ArgumentException("Duplicate group metadata.");
        }
        var needed=new HashSet<string>(StringComparer.Ordinal);var headers=new HashSet<string>(StringComparer.Ordinal);var ids=new HashSet<string>(StringComparer.Ordinal);
        var members=new Dictionary<string,int>(StringComparer.Ordinal);var closed=new HashSet<string>(StringComparer.Ordinal);var previous=Array.Empty<string>();
        var collapsed=request.CollapsedGroups.ToHashSet(StringComparer.Ordinal);
        var entries=new List<NgGroupedRangeEntry<T>>();
        foreach(var e in result.Entries) {
            if(e.Path.Count<1 || e.Path.Count>request.GroupKeys.Count || e.Path.Any(k=>k is null) || !e.IsGroup && e.Path.Count!=request.GroupKeys.Count)throw new ArgumentException("Invalid entry path.");
            var path=e.Path.ToArray();var ancestors=Enumerable.Range(1,path.Length).Select(n=>NgDataOperations.GroupId(path.Take(n))).ToArray();var id=ancestors[^1];
            foreach(var old in previous.Except(ancestors))closed.Add(old);
            if(ancestors.Any(closed.Contains))throw new ArgumentException("Group entries must be contiguous.");
            for(var depth=0;depth<ancestors.Length;depth++) {
                var key=ancestors[depth];needed.Add(key);
                if(!metadata.ContainsKey(key) || (depth<ancestors.Length-1 || !e.IsGroup) && collapsed.Contains(key))throw new ArgumentException("Missing ancestor or entry below a collapsed group.");
                // A window may start within a group. New groups after its first slot must start with a header.
                if(entries.Count>0 && !previous.Contains(key) && (!e.IsGroup || depth!=ancestors.Length-1))throw new ArgumentException("Missing group header inside the window.");
                if(!e.IsGroup)members[key]=members.GetValueOrDefault(key)+1;
            }
            if(e.IsGroup) {
                if(!headers.Add(id) || members.ContainsKey(id))throw new ArgumentException("Duplicate or late group header.");
            }else if(e.Item is null || string.IsNullOrWhiteSpace(rowId(e.Item)) || !ids.Add(rowId(e.Item)))throw new ArgumentException("Invalid record identity.");
            entries.Add(new(Array.AsReadOnly(path),e.IsGroup,e.Item));previous=ancestors;
        }
        if(needed.Count!=metadata.Count || members.Any(p=>p.Value>metadata[p.Key].Count))throw new ArgumentException("Unexpected metadata or invalid group counts.");
        foreach(var siblings in metadata.Values.GroupBy(g=>NgDataOperations.GroupId(g.Path.Take(g.Path.Count-1)))) {
            var maximum=siblings.Key==""?result.RecordTotal:metadata[siblings.Key].Count;
            if(siblings.Sum(g=>(long)g.Count)>maximum)throw new ArgumentException("Sibling counts exceed parent total.");
        }
        return new(result.StartIndex,result.Total,result.RecordTotal,entries.AsReadOnly(),Array.AsReadOnly(metadata.Values.ToArray()));
    }

    /// <summary>Reference in-memory server adapter. Filter/sort the entire source before calling.</summary>
    public static NgGroupedRangeResult<T> Window<T>(IReadOnlyList<T> filteredSorted,IReadOnlyList<Func<T,string>> selectors,IReadOnlyList<NgGroupAggregate<T>> aggregates,NgGroupedRangeRequest request) {
        ValidateRequest(request);
        if(selectors.Count!=request.GroupKeys.Count || filteredSorted.Count>NgDataRange.MaxTotal)throw new ArgumentException("Invalid grouped range source.");
        var tree=NgDataOperations.GroupTree(filteredSorted,selectors);var slots=new List<NgGroupedRangeEntry<T>>();var collapsed=request.CollapsedGroups.ToHashSet(StringComparer.Ordinal);
        void Walk(IEnumerable<NgGridGroup<T>> nodes) { foreach(var g in nodes) {
            slots.Add(new(g.Path,true,default));
            if(collapsed.Contains(g.Id))continue;
            if(g.Children.Count>0)Walk(g.Children);else slots.AddRange(g.Items.Select(r=>new NgGroupedRangeEntry<T>(g.Path,false,r)));
        }}
        Walk(tree);
        if(slots.Count>NgDataRange.MaxTotal)throw new ArgumentException("Grouped range exceeds the visible-slot limit.");
        var entries=slots.Skip(request.StartIndex).Take(request.Count).ToArray();
        var needed=entries.SelectMany(e=>Enumerable.Range(1,e.Path.Count).Select(n=>NgDataOperations.GroupId(e.Path.Take(n)))).ToHashSet(StringComparer.Ordinal);
        var groups=NgDataOperations.AllGroups(tree).Where(g=>needed.Contains(g.Id)).Select(g=>new NgRemoteGroup(g.Path,g.Count,aggregates.Select(a=>new NgGroupSummary(a.Title,a.Calculate(g.Items))).ToArray())).ToArray();
        return new(request.StartIndex,slots.Count,filteredSorted.Count,entries,groups);
    }
}

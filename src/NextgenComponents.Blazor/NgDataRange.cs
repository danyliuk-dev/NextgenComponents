namespace NextgenComponents.Blazor;

/// <summary>A zero-based range in a stable, fully filtered/sorted server result.</summary>
public sealed record NgDataRangeRequest(int StartIndex,int Count,string Search,IReadOnlyList<NgSortDescriptor> Sorts);
public sealed record NgDataRangeResult<T>(int StartIndex,IReadOnlyList<T> Items,int Total);

public static class NgDataRange {
    public const int MaxCount=512, MaxTotal=100000;
    public static void ValidateRequest(NgDataRangeRequest request) {
        if(request.StartIndex<0 || request.StartIndex>MaxTotal || request.Count<1 || request.Count>MaxCount || request.Search is null || request.Sorts is null)
            throw new ArgumentException("Invalid range request.");
    }
    public static IReadOnlyList<T> Validate<T>(NgDataRangeResult<T> result,NgDataRangeRequest request,Func<T,string> rowId) {
        ValidateRequest(request);
        if(result.StartIndex!=request.StartIndex || result.Total<0 || result.Total>MaxTotal || result.Items is null || result.Items.Count!=Math.Min(request.Count,Math.Max(0,result.Total-request.StartIndex)))
            throw new ArgumentException("Range response must echo the offset and contain every requested record within the total.");
        var rows=result.Items.ToArray();
        var ids=rows.Select(rowId).ToArray();
        if(ids.Any(string.IsNullOrWhiteSpace) || ids.Distinct(StringComparer.Ordinal).Count()!=rows.Length)
            throw new ArgumentException("Range row IDs must be nonempty and unique.");
        return Array.AsReadOnly(rows);
    }
}

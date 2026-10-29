using NextgenComponents.Blazor;
namespace BlazorGallery;

/// Synthetic, read-only HTTP adapter shared by both Web galleries.
public static class GroupedRangeInventoryApi {
    private static readonly int[] Rows=Enumerable.Range(1,10000).ToArray();
    private static readonly NgDataColumn<int>[] Columns=[new("id","Record",i=>i,Format:i=>$"R{i:000000}"),new("name","Name",i=>$"Inventory {i:000000}")];
    public static string Region(int i)=>i<=5000?"North":"South";
    public static string Kind(int i)=>i%2==0?"Even":"Odd";
    public static void Map(WebApplication app) {
        app.MapPost("/api/grouped-range-inventory",async (NgGroupedRangeRequest request,HttpContext context)=>{
            try {NgGroupedRange.ValidateRequest(request);}catch(ArgumentException){return Results.BadRequest(new{error="Invalid grouped range."});}
            if(request.Search.Length>200 || request.Sorts.Count>2 || request.Sorts.Any(s=>s.Key is not ("id" or "name")) || request.Sorts.Select(s=>s.Key).Distinct().Count()!=request.Sorts.Count || !request.GroupKeys.SequenceEqual(new[]{"region","kind"}) && !request.GroupKeys.SequenceEqual(new[]{"region"}))return Results.BadRequest(new{error="Unsupported query."});
            await Task.Delay(context.Request.Query["slow"]=="true"?1200:120,context.RequestAborted);
            if(context.Request.Query["fail"]=="true")return Results.StatusCode(503);
            var rows=NgDataOperations.Query(context.Request.Query["small"]=="true"?Rows.Take(12).ToArray():Rows,Columns,request.Search,request.Sorts);
            var result=NgGroupedRange.Window(rows,request.GroupKeys.Count==2?[Region,Kind]:new Func<int,string>[]{Region},[],request);
            if(context.Request.Query["malformed"]=="true")result=result with {StartIndex=request.StartIndex+1};
            return Results.Json(result);
        }).RequireCors("GroupedInventoryDemo");
    }
}

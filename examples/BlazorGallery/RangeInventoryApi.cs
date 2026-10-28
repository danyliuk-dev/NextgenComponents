using NextgenComponents.Blazor;
namespace BlazorGallery;

/// <summary>Synthetic, read-only shared HTTP exercise for continuous range reads.</summary>
public static class RangeInventoryApi {
    private static readonly int[] Rows=Enumerable.Range(1,100000).ToArray();
    private static readonly NgDataColumn<int>[] Columns=[new("id","Record",i=>i,Format:i=>$"R{i:000000}"),new("name","Name",i=>$"Inventory {i:000000}")];
    public static void Map(WebApplication app) {
        app.MapPost("/api/range-inventory",async (NgDataRangeRequest request,HttpContext context)=>{
            try {NgDataRange.ValidateRequest(request);}catch(ArgumentException){return Results.BadRequest(new{error="Invalid range."});}
            if(request.Search.Length>200 || request.Sorts.Count>2 || request.Sorts.Any(s=>s.Key is not ("id" or "name")) || request.Sorts.Select(s=>s.Key).Distinct().Count()!=request.Sorts.Count)return Results.BadRequest(new{error="Unsupported query."});
            await Task.Delay(context.Request.Query["slow"]=="true"?1200:120,context.RequestAborted);
            if(context.Request.Query["fail"]=="true")return Results.StatusCode(503);
            var rows=NgDataOperations.Query(context.Request.Query["small"]=="true"?Rows.Take(12).ToArray():Rows,Columns,request.Search,request.Sorts);
            var result=new NgDataRangeResult<int>(request.StartIndex,rows.Skip(request.StartIndex).Take(request.Count).ToArray(),rows.Count);
            if(context.Request.Query["malformed"]=="true")result=result with {StartIndex=request.StartIndex+1};
            return Results.Json(result);
        }).RequireCors("GroupedInventoryDemo");
    }
}

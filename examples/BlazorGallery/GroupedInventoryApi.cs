using NextgenComponents.Blazor;
namespace BlazorGallery;

/// Read-only fixture endpoint for both Web galleries. No database or customer data.
public static class GroupedInventoryApi {
    public sealed record Product(string Id,string Name,int Count);
    private static readonly Product[] Rows=Enumerable.Range(1,40).Select(i=>new Product($"p{i}",i%2==0?"Desk":"Chair",i*4)).ToArray();
    private static readonly NgDataColumn<Product>[] Columns=[new("name","Name",r=>r.Name),new("count","Quantity",r=>r.Count)];
    private static readonly NgGroupAggregate<Product>[] Aggregates=[new("Total quantity",r=>r.Count),new("Average",r=>r.Count,"average")];
    public static void Map(WebApplication app) {
        app.MapPost("/api/grouped-inventory",async (NgGroupedDataRequest request,HttpContext context)=>{
            try{NgGroupedData.ValidateKeys(request.GroupKeys);}catch(ArgumentException){return Results.BadRequest(new{error="Invalid group keys."});}
            if(request.Page<1 || request.Page>1000000 || request.PageSize<1 || request.PageSize>50 || request.Search.Length>200 || request.GroupKeys.Any(k=>k is not ("name" or "availability")) || request.Sorts.Any(s=>s.Key is not ("name" or "count")))return Results.BadRequest(new{error="Unsupported demo query."});
            await Task.Delay(350,context.RequestAborted);
            if(context.Request.Query["fail"]=="true")return Results.StatusCode(503);
            var source=context.Request.Query["small"]=="true"?Rows.Take(7).ToArray():Rows;
            var filtered=NgDataOperations.Query(source,Columns,request.Search,request.Sorts);
            var selectors=request.GroupKeys.Select<string,Func<Product,string>>(k=>k=="name"?r=>r.Name:r=>r.Count<100?"Available":"Protected").ToArray();
            var result=NgGroupedData.Page(filtered,selectors,Aggregates,request.Page,request.PageSize);
            if(context.Request.Query["malformed"]=="true" && result.Groups.Count>0)result=result with {Groups=result.Groups.Select((g,i)=>i==0?g with {Count=0}:g).ToArray()};
            return Results.Json(result);
        }).RequireCors("GroupedInventoryDemo");
    }
}

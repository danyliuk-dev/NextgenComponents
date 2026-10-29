using BlazorGallery.Components;
var builder = WebApplication.CreateBuilder(args);
builder.WebHost.UseStaticWebAssets();
builder.Services.AddRazorComponents().AddInteractiveServerComponents();
builder.Services.AddHttpClient();
builder.Services.AddCors(options=>options.AddPolicy("GroupedInventoryDemo",policy=>policy.WithOrigins("http://127.0.0.1:5181").WithMethods("POST").WithHeaders("Content-Type")));
var app = builder.Build();
app.UseCors();
BlazorGallery.GroupedInventoryApi.Map(app);
BlazorGallery.RangeInventoryApi.Map(app);
BlazorGallery.GroupedRangeInventoryApi.Map(app);
var types = new Microsoft.AspNetCore.StaticFiles.FileExtensionContentTypeProvider();
types.Mappings[".mjs"]="text/javascript";
types.Mappings[".bcmap"]="application/octet-stream";
types.Mappings[".pfb"]="application/octet-stream";
app.UseStaticFiles(new StaticFileOptions { ContentTypeProvider=types });
// The local desktop workspace embeds the gallery and manual previews.
// Only the explicit loopback documentation origin may frame these pages.
app.Use(async (context, next) => {
    if (context.Connection.RemoteIpAddress is { } address && System.Net.IPAddress.IsLoopback(address)) {
        context.Response.OnStarting(() => {
            context.Response.Headers.Remove("X-Frame-Options");
            context.Response.Headers.ContentSecurityPolicy = "frame-ancestors 'self' http://127.0.0.1:5182";
            return Task.CompletedTask;
        });
    }
    await next();
});
app.UseAntiforgery();
app.MapRazorComponents<App>().AddInteractiveServerRenderMode();
app.Run();

using BlazorGallery.Components;
var builder = WebApplication.CreateBuilder(args);
builder.WebHost.UseStaticWebAssets();
builder.Services.AddRazorComponents().AddInteractiveServerComponents();
var app = builder.Build();
var types = new Microsoft.AspNetCore.StaticFiles.FileExtensionContentTypeProvider();
types.Mappings[".mjs"]="text/javascript";
types.Mappings[".bcmap"]="application/octet-stream";
types.Mappings[".pfb"]="application/octet-stream";
app.UseStaticFiles(new StaticFileOptions { ContentTypeProvider=types });
// Only the runnable manual examples may be embedded by the local docs launcher.
// Keep the default framing policy on every other gallery route.
app.Use(async (context, next) => {
    if (context.Request.Path.StartsWithSegments("/preview")) {
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

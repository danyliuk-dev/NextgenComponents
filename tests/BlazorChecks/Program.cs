using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using NextgenComponents.Blazor;
using System.Linq.Expressions;

var services = new ServiceCollection().AddLogging().AddSingleton<IJSRuntime, NoBrowserJS>().BuildServiceProvider();
await using var renderer = new HtmlRenderer(services, services.GetRequiredService<ILoggerFactory>());
var count = 0;
async Task Check<T>(Dictionary<string, object?> parameters, params string[] expected) where T : IComponent {
 var html = await renderer.Dispatcher.InvokeAsync(async () => (await renderer.RenderComponentAsync<T>(ParameterView.FromDictionary(parameters!))).ToHtmlString());
 foreach (var text in expected) if (!html.Contains(text)) throw new Exception($"{typeof(T).Name}: missing {text} in {html}");
 Console.WriteLine($"PASS {typeof(T).Name}"); count++;
}
RenderFragment Text(string value) => b => b.AddContent(0, value);
string? name = "<script>unsafe</script>";
decimal? number = 5;
bool enabled = true;
string team = "a";
NgOption[] options = [new("a", "Alpha"), new("b", "Beta", true)];
await Check<NgButton>(new() { ["Disabled"] = true, ["Primary"] = true, ["ChildContent"] = Text("Save") }, "disabled", "ng-primary", "type=\"button\"");
await Check<NgTextBox>(new() { ["Label"] = "Name", ["Value"] = name, ["ValueExpression"] = (Expression<Func<string?>>)(() => name), ["Id"] = "name" }, "for=\"name\"", "&lt;script&gt;", "id=\"name\"");
await Check<NgNumericTextBox>(new() { ["Label"] = "Seats", ["Value"] = number, ["ValueExpression"] = (Expression<Func<decimal?>>)(() => number), ["Min"] = (decimal?)1, ["Max"] = (decimal?)100 }, "type=\"number\"", "min=\"1\"", "max=\"100\"", "value=\"5\"");
await Check<NgCheckBox>(new() { ["Label"] = "Updates", ["Value"] = enabled, ["ValueExpression"] = (Expression<Func<bool>>)(() => enabled) }, "checked", "Updates");
await Check<NgSwitch>(new() { ["Label"] = "Active", ["Value"] = enabled, ["ValueExpression"] = (Expression<Func<bool>>)(() => enabled) }, "role=\"switch\"", "checked");
await Check<NgDropDownList>(new() { ["Label"] = "Team", ["Value"] = team, ["ValueExpression"] = (Expression<Func<string>>)(() => team), ["Items"] = options }, "Alpha", "disabled", "value=\"b\"");
await Check<NgRadioGroup>(new() { ["Label"] = "Access", ["Value"] = team, ["ValueExpression"] = (Expression<Func<string>>)(() => team), ["Items"] = options }, "legend", "value=\"a\"", "checked", "disabled");
await Check<NgTabs>(new() { ["Items"] = new NgTab[] { new("One", Text("First")), new("Two", Text("Second")) }, ["SelectedIndex"] = 1 }, "role=\"tablist\"", "aria-selected=\"true\"", "hidden", "Second");
await Check<NgDialog>(new() { ["Title"] = "Preview", ["ChildContent"] = Text("Details") }, "<dialog", "aria-labelledby", "Preview", "Details");
await Check<NgTooltip>(new() { ["Text"] = "Help" }, "role=\"tooltip\"", "aria-describedby", "Help");
await Check<NgNotification>(new() { ["Visible"] = true, ["Tone"] = "error", ["ChildContent"] = Text("Failed") }, "role=\"alert\"", "Dismiss notification", "Failed");
Console.WriteLine($"{count} server-rendering checks passed. Browser interaction requires the separate visual run.");
sealed class NoBrowserJS : IJSRuntime {
 public ValueTask<TValue> InvokeAsync<TValue>(string identifier, object?[]? args) => throw new InvalidOperationException("JS must not execute in SSR");
 public ValueTask<TValue> InvokeAsync<TValue>(string identifier, CancellationToken cancellationToken, object?[]? args) => InvokeAsync<TValue>(identifier,args);
}

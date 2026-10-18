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
DateOnly? date=new(2026,10,22);
TimeOnly? time=new(9,30);
DateTime? stamp=new(2026,10,22,9,30,0);
await Check<NgCalendar>(new(){["Value"]=date,["Min"]=new DateOnly(2026,10,1),["Max"]=new DateOnly(2026,10,31)},"October", "data-ng-day", "disabled");
await Check<NgDateInput>(new(){["Value"]=date,["ValueExpression"]=(Expression<Func<DateOnly?>>)(()=>date)},"2026-10-22");
await Check<NgDatePicker>(new(){["Value"]=date,["ValueExpression"]=(Expression<Func<DateOnly?>>)(()=>date)},"2026-10-22", "Choose");
await Check<NgTimePicker>(new(){["Value"]=time,["ValueExpression"]=(Expression<Func<TimeOnly?>>)(()=>time)},"09:30", "type=\"time\"");
await Check<NgDateTimePicker>(new(){["Value"]=stamp,["ValueExpression"]=(Expression<Func<DateTime?>>)(()=>stamp)},"2026-10-22", "datetime-local");
void Rule(bool condition,string name){if(!condition)throw new Exception(name);count++;Console.WriteLine($"PASS {name}");}
Rule(NgDateRules.TryDate("2024-02-29",out _),"leap day");
foreach(var invalid in new[]{"2026-02-29","2026-04-31","2026-13-01","2026-1-01"}) Rule(!NgDateRules.TryDate(invalid,out _),$"reject {invalid}");
Rule(!NgDateRules.TryTime("24:00",out _),"reject midnight overflow");
Rule(NgDateRules.RangeError(new(new(2026,10,23),new(2026,10,22))) is not null,"reject inverted range");
Rule(!NgDateRules.Allowed(new(2026,10,18),null,null,d=>d.DayOfWeek==DayOfWeek.Sunday),"reject disabled date");
Console.WriteLine($"{count} rendering and date-rule checks passed. Browser interaction requires the separate visual run.");
sealed class NoBrowserJS : IJSRuntime {
 public ValueTask<TValue> InvokeAsync<TValue>(string identifier, object?[]? args) => throw new InvalidOperationException("JS must not execute in SSR");
 public ValueTask<TValue> InvokeAsync<TValue>(string identifier, CancellationToken cancellationToken, object?[]? args) => InvokeAsync<TValue>(identifier,args);
}

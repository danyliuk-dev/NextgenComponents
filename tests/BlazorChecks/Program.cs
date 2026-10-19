using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using NextgenComponents.Blazor;
using System.Linq.Expressions;

var services = new ServiceCollection().AddLogging().AddSingleton<IJSRuntime, NoBrowserJS>().AddSingleton<NavigationManager, TestNavigation>().BuildServiceProvider();
await using var renderer = new HtmlRenderer(services, services.GetRequiredService<ILoggerFactory>());
var count = 0;
async Task Check<T>(Dictionary<string, object?> parameters, params string[] expected) where T : IComponent {
 var html = await renderer.Dispatcher.InvokeAsync(async () => (await renderer.RenderComponentAsync<T>(ParameterView.FromDictionary(parameters!))).ToHtmlString());
 foreach (var text in expected) if (!html.Contains(text)) throw new Exception($"{typeof(T).Name}: missing {text} in {html}");
 Console.WriteLine($"PASS {typeof(T).Name}"); count++;
}
foreach(var locked in new[]{false,true}){
 await Check<NgTreeView<string>>(new(){["Items"]=new[]{new NgTreeNode<string>("a","Alpha")},["Text"]=(Func<string,string>)(s=>s),["Checkboxes"]=true,["ShowCheckActions"]=true,["CheckingReadOnly"]=locked,["CheckLoadedText"]="<Check loaded>",["ClearLoadedText"]="Clear loaded"},"&lt;Check loaded&gt;","Clear loaded","disabled");
 await Check<NgTreeList<string>>(new(){["Items"]=Array.Empty<NgTreeNode<string>>(),["Columns"]=new[]{new NgDataColumn<string>("name","Name",s=>s)},["Checkboxes"]=true,["ShowCheckActions"]=true,["CheckingReadOnly"]=locked},"Check loaded nodes","Clear loaded checks","disabled");
}
var cascadeRoot=new NgTreeNode<string>("root","Root",[
 new("a","Alpha"),new("group","Group",[new("b","Beta")]),
 new("locked","Locked",[new("locked-child","Hidden locked child")],Disabled:true),
 new("protected","Protected",[new("protected-child","Hidden protected child")]),new("lazy","Lazy",HasChildren:true)]);
Func<NgTreeNode<string>,bool> permitted=n=>n.Id!="protected";
var originalChecks=new HashSet<string>{"unknown","locked","protected-child"};
var cascaded=NgDataOperations.ToggleTreeCheck(cascadeRoot,originalChecks,true,permitted);
if(!cascaded.SetEquals(["unknown","locked","protected-child","root","a","group","b","lazy"]) || originalChecks.Count!=3)throw new Exception("Cascade mutated or crossed protection");count++;
if(NgDataOperations.TreeCheckState(cascadeRoot,cascaded,true,permitted)!=true)throw new Exception("Full cascade state");count++;
cascaded.Remove("b");if(NgDataOperations.TreeCheckState(cascadeRoot,cascaded,true,permitted)!=null)throw new Exception("Partial cascade state");count++;
var restored=NgDataOperations.ToggleTreeCheck(cascadeRoot,cascaded,true,permitted);
var cleared=NgDataOperations.ToggleTreeCheck(cascadeRoot,restored,true,permitted);
if(!cleared.SetEquals(originalChecks))throw new Exception("Cascade clear lost protected/unknown IDs");count++;
if(!NgDataOperations.ToggleTreeCheck(cascadeRoot,originalChecks,false,permitted).SetEquals(["unknown","locked","protected-child","root"]))throw new Exception("Independent mode changed");count++;
await Check<NgTreeView<string>>(new(){["Items"]=new[]{cascadeRoot},["Text"]=(Func<string,string>)(s=>s),["Checkboxes"]=true,["CheckChildren"]=true,["CheckedIds"]=new HashSet<string>{"a"}},"aria-checked=\"mixed\"");
await Check<NgTreeList<string>>(new(){["Items"]=new[]{cascadeRoot},["Columns"]=new[]{new NgDataColumn<string>("name","Name",s=>s)},["Checkboxes"]=true,["CheckChildren"]=true,["CheckedIds"]=new HashSet<string>{"a"}},"aria-checked=\"mixed\"");
var checkedTree=new[]{new NgTreeNode<string>("a","<Alpha>"),new NgTreeNode<string>("b","Beta",Disabled:true)};
var checkHandler=EventCallback.Factory.Create<HashSet<string>>(new object(),(HashSet<string> ids)=>{});
foreach(var locked in new[]{false,true}) {
 await Check<NgTreeView<string>>(new(){["Items"]=checkedTree,["Text"]=(Func<string,string>)(s=>s),["Checkboxes"]=true,["CheckedIds"]=new HashSet<string>{"a","hidden"},["CheckedIdsChanged"]=checkHandler,["CheckingReadOnly"]=locked},"ng-tree-check","Check &lt;Alpha&gt;","checked","disabled");
 await Check<NgTreeList<string>>(new(){["Items"]=checkedTree,["Columns"]=new[]{new NgDataColumn<string>("name","Name",s=>s)},["Checkboxes"]=true,["CheckedIds"]=new HashSet<string>{"a"},["CheckedIdsChanged"]=checkHandler,["CheckingReadOnly"]=locked,["CheckLabel"]=(Func<string,string>)(s=>"Choose "+s)},"Choose &lt;Alpha&gt;","checked","disabled");
}
await Check<NgTreeView<string>>(new(){["Items"]=new[]{new NgTreeNode<string>("a","Alpha")},["Text"]=(Func<string,string>)(s=>s),["Checkboxes"]=true,["CanCheck"]=(Func<NgTreeNode<string>,bool>)(_=>false),["CheckedIdsChanged"]=checkHandler},"ng-tree-check","disabled");
await Check<NgTreeView<string>>(new(){["Items"]=new[]{new NgTreeNode<string>("a","Alpha")},["Text"]=(Func<string,string>)(s=>s),["Checkboxes"]=true},"ng-tree-check","disabled");
var remoteColumns=new[]{new NgDataColumn<string>("name","Name",s=>s)};
await Check<NgDataGrid<string>>(new(){["Columns"]=remoteColumns,["RowId"]=(Func<string,string>)(s=>s),["ReadData"]=(Func<NgDataRequest,CancellationToken,Task<NgDataResult<string>>>)((r,t)=>Task.FromResult(new NgDataResult<string>(["Server row"],42))),["MultiSort"]=true},"Server row","Clear sorting","42");
await Check<NgDataGrid<string>>(new(){["Columns"]=remoteColumns,["RowId"]=(Func<string,string>)(s=>s),["ReadData"]=(Func<NgDataRequest,CancellationToken,Task<NgDataResult<string>>>)((r,t)=>Task.FromException<NgDataResult<string>>(new Exception("private")))},"Unable to load records.","Retry");
await Check<NgDataGrid<string>>(new(){["Columns"]=remoteColumns,["RowId"]=(Func<string,string>)(s=>s),["ReadData"]=(Func<NgDataRequest,CancellationToken,Task<NgDataResult<string>>>)((r,t)=>Task.FromResult(new NgDataResult<string>(["duplicate","duplicate"],2)))},"Unable to load records.");
var manyRows=new[]{(Id:"a",Group:1,Value:2),(Id:"b",Group:0,Value:5),(Id:"c",Group:1,Value:3),(Id:"d",Group:1,Value:3)};
NgDataColumn<(string Id,int Group,int Value)>[] manyColumns=[new("group","Group",r=>r.Group),new("value","Value",r=>r.Value)];
if(string.Join(",",NgDataOperations.Query(manyRows,manyColumns,"",new NgSortDescriptor[]{new("group"),new("value",true)}).Select(r=>r.Id))!="b,c,d,a")throw new Exception("Unstable multi-sort");count++;
await Check<NgTreeView<string>>(new(){["Items"]=new[]{new NgTreeNode<string>("root","Root",HasChildren:true)},["Text"]=(Func<string,string>)(s=>s)},"Expand Root","aria-expanded=\"false\"");
await Check<NgTreeList<string>>(new(){["Items"]=new[]{new NgTreeNode<string>("root","Root",HasChildren:true)},["Columns"]=remoteColumns},"Expand Root");
await Check<NgDateRangePicker>(new(){["Presets"]=new[]{new NgDateRangePreset("week","<Week>",new(2026,10,20),new(2026,10,23))},["Value"]=new NgDateRange(new(2026,10,20),new(2026,10,23)),["ShowClearButton"]=true},"&lt;Week&gt;","aria-pressed=\"true\"","Clear range","disabled");
foreach(var presets in new[]{new[]{new NgDateRangePreset("","Empty",new(2026,10,1),new(2026,10,2))},new[]{new NgDateRangePreset("id"," ",new(2026,10,1),new(2026,10,2))},new[]{new NgDateRangePreset("id","Reverse",new(2026,10,2),new(2026,10,1))},new[]{new NgDateRangePreset("id","One",new(2026,10,1),new(2026,10,2)),new NgDateRangePreset("id","Two",new(2026,10,2),new(2026,10,3))}}){
 try{await Check<NgDateRangePicker>(new(){["Presets"]=presets});throw new Exception("Malformed presets accepted");}catch(ArgumentException){count++;}
}
RenderFragment Text(string value) => b => b.AddContent(0, value);
string? name = "<script>unsafe</script>";
await Check<NgTextBox>(new(){["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["Value"]="👨‍👩‍👧‍👦",["CounterMode"]="remaining",["MaxLength"]=4,["Id"]="counted",["HelperText"]="Help"},"7 over limit","data-over-limit=\"true\"","counted-help counted-count","aria-live=\"polite\"");
await Check<NgTextArea>(new(){["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["Value"]="Hi",["CounterMode"]="used"},"2 characters");
await Check<NgTextArea>(new(){["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["Value"]="Hi",["CounterMode"]="used",["CounterText"]=(Func<int,int?,string>)((n,m)=>$"<Used {n}>")},"&lt;Used 2&gt;");
foreach(var mode in new[]{"bad","remaining"}){
 try{await Check<NgTextBox>(new(){["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["CounterMode"]=mode});throw new Exception("Invalid counter accepted");}catch(ArgumentException){count++;}
}
decimal? number = 5;
bool enabled = true;
string team = "a";
NgOption[] options = [new("a", "Alpha"), new("b", "Beta", true)];
await Check<NgButton>(new() { ["Disabled"] = true, ["Primary"] = true, ["ChildContent"] = Text("Save") }, "disabled", "ng-primary", "type=\"button\"");
await Check<NgTextBox>(new(){["Label"]="Password",["Value"]="sample",["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["Password"]=true,["ShowPasswordToggle"]=true,["ShowClearButton"]=true},"type=\"password\"","Show password","Clear Password");
foreach(var rounded in new[]{"theme","none","small","medium","large","full"}){
 await Check<NgTextBox>(new(){["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["Rounded"]=rounded,["FillMode"]="flat"},"ng-text-rounded-"+rounded,"ng-text-fill-flat");
 await Check<NgTextArea>(new(){["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["Rounded"]=rounded,["FillMode"]="flat"},"ng-text-rounded-"+rounded,"ng-text-fill-flat");
}
try{await Check<NgTextBox>(new(){["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["Rounded"]="bad"});throw new Exception("Invalid corners accepted");}catch(ArgumentException){count++;}
try{await Check<NgTextArea>(new(){["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["Rounded"]="bad"});throw new Exception("Invalid corners accepted");}catch(ArgumentException){count++;}
await Check<NgTextBox>(new(){["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["Size"]="large",["FillMode"]="filled"},"ng-text-size-large","ng-text-fill-filled");
try{await Check<NgTextBox>(new(){["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["DebounceDelay"]=-1});throw new Exception("Negative delay accepted");}catch(ArgumentOutOfRangeException){count++;}
try{await Check<NgTextArea>(new(){["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["DebounceDelay"]=60001});throw new Exception("Excessive delay accepted");}catch(ArgumentOutOfRangeException){count++;}
await Check<NgTextArea>(new(){["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["Size"]="small",["FillMode"]="outline",["AutoSize"]=true},"ng-text-size-small","ng-text-fill-outline","ng-textarea-auto");
try{await Check<NgTextBox>(new(){["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["Size"]="invalid"});throw new Exception("Invalid size accepted");}catch(ArgumentException){count++;}
try{await Check<NgTextArea>(new(){["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["FillMode"]="invalid"});throw new Exception("Invalid fill accepted");}catch(ArgumentException){count++;}
await Check<NgTextArea>(new(){["Value"]="Lines",["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["AutoSize"]=true,["Rows"]=2,["MaxRows"]=6},"ng-textarea-auto","rows=\"2\"");
try{await Check<NgTextArea>(new(){["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["AutoSize"]=true,["Rows"]=4,["MaxRows"]=2});throw new Exception("Invalid automatic row bounds accepted");}catch(ArgumentOutOfRangeException){count++;Console.WriteLine("PASS invalid automatic row bounds");}
await Check<NgTextArea>(new(){["Label"]="Notes",["Value"]="",["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["ShowClearButton"]=true},"Clear Notes","disabled");
await Check<NgTextBox>(new() { ["Label"] = "Name", ["Value"] = name, ["ValueExpression"] = (Expression<Func<string?>>)(() => name), ["Id"] = "name" }, "for=\"name\"", "&lt;script&gt;", "id=\"name\"");
await Check<NgTextBox>(new(){["Label"]="Project",["Value"]=name,["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["Id"]="project",["ReadOnly"]=true,["MaxLength"]=80,["HelperText"]="Guidance",["PrefixTemplate"]=Text("Prefix"),["AdditionalAttributes"]=new Dictionary<string,object>{{"aria-describedby","external-help"}}},"readonly","maxlength=\"80\"","external-help project-help","Prefix","Guidance");
await Check<NgTextArea>(new(){["Value"]=name,["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["Rows"]=3,["ReadOnly"]=true,["HelperText"]="Notes guidance",["SuffixTemplate"]=Text("Suffix")},"readonly","rows=\"3\"","Notes guidance","Suffix");
await Check<NgForm>(new(){["Model"]=new object(),["Sections"]=new[]{new NgFormSection("fold","Details",new[]{Text("Retained field")},Expanded:false,OnExpandedChanged:EventCallback.Factory.Create<bool>(new object(),(bool value)=>{}))}},"aria-expanded=\"false\"","aria-controls=","hidden","Retained field","type=\"button\"");
await Check<NgForm>(new(){["Model"]=new object(),["Disabled"]=true,["Sections"]=new[]{new NgFormSection("fold","Details",new[]{Text("Field")},OnExpandedChanged:EventCallback.Factory.Create<bool>(new object(),(bool value)=>{}))}},"aria-expanded=\"true\"","disabled","ng-section-toggle");
NgFormSection SectionChain(int depth){var node=new NgFormSection("node","Level",new[]{Text("Leaf")});for(var i=1;i<depth;i++)node=new NgFormSection("node","Level",Sections:new[]{node});return node;}
await Check<NgForm>(new(){["Model"]=new object(),["Sections"]=new[]{SectionChain(8)},["Disabled"]=true},"Leaf","<legend>Level</legend>","disabled");
var cycleSections=new List<NgFormSection>();var cyclicSection=new NgFormSection("cycle","Cycle",Sections:cycleSections);cycleSections.Add(cyclicSection);
var nestedLeaf=new NgFormSection("leaf","Leaf",Array.Empty<RenderFragment>());
foreach(var invalidSection in new[]{SectionChain(9),cyclicSection,new NgFormSection("empty","Empty"),new NgFormSection("both","Both",Array.Empty<RenderFragment>(),Sections:Array.Empty<NgFormSection>()),new NgFormSection("spans","Spans",FieldSpans:Array.Empty<int>(),Sections:Array.Empty<NgFormSection>()),new NgFormSection("duplicate","Duplicate",Sections:new[]{nestedLeaf,nestedLeaf}),new NgFormSection("parent","Parent",Sections:new[]{nestedLeaf with{Title=" "}})}){try{await Check<NgForm>(new(){["Model"]=new object(),["Sections"]=new[]{invalidSection}});throw new Exception("Invalid nested tree accepted");}catch(ArgumentException){count++;}}
await Check<NgForm>(new(){["Model"]=new object(),["Sections"]=new[]{new NgFormSection("a","First",Sections:new[]{nestedLeaf}),new NgFormSection("b","Second",Sections:new[]{nestedLeaf})}},"First","Second","Leaf");
await Check<NgForm>(new(){["Model"]=new object(),["Sections"]=new[]{new NgFormSection("identity","<Identity>",new[]{Text("Name"),Text("Owner")},Description:"Required fields",Columns:2),new NgFormSection("notes","Notes",new[]{Text("Delivery")},FieldSpans:new[]{0})}},"<legend>&lt;Identity&gt;</legend>","Required fields","--ng-form-columns:2","Delivery");
var validSection=new NgFormSection("a","A",Array.Empty<RenderFragment>());
foreach(var sections in new[]{new[]{validSection,validSection},new[]{validSection with{Id=" "}},new[]{validSection with{Title=" "}},new[]{validSection with{Columns=5}},new[]{validSection with{MinColumnWidth=119}},new[]{validSection with{Gap=65}},new[]{validSection with{FieldSpans=new[]{1}}},new[]{validSection with{Fields=new[]{Text("Field")},FieldSpans=new[]{5}}}}){try{await Check<NgForm>(new(){["Model"]=new object(),["Sections"]=sections});throw new Exception("Invalid section accepted");}catch(ArgumentException){count++;}}
foreach(var extra in new Dictionary<string,object?>[]{new(){["Fields"]=Array.Empty<RenderFragment>()},new(){["ChildContent"]=Text("Legacy")},new(){["FieldSpans"]=Array.Empty<int>()}}){extra["Model"]=new object();extra["Sections"]=new[]{validSection};try{await Check<NgForm>(extra);throw new Exception("Mixed section content accepted");}catch(ArgumentException){count++;}}
await Check<NgForm>(new(){["Model"]=new object(),["Fields"]=new RenderFragment[]{Text("First"),Text("Wide")},["FieldSpans"]=new[]{1,0},["Columns"]=3},"@container ng-form-columns","--ng-form-count:3","grid-column:span var(--ng-form-count)");
foreach(var spans in new[]{Array.Empty<int>(),new[]{-1},new[]{5},new[]{1,1}}){try{await Check<NgForm>(new(){["Model"]=new object(),["Fields"]=new RenderFragment[]{Text("Field")},["FieldSpans"]=spans});throw new Exception("Invalid spans accepted");}catch(ArgumentException){count++;}}
await Check<NgForm>(new(){["Model"]=new object(),["Fields"]=new RenderFragment[]{Text("First"),Text("Second")},["Columns"]=2,["Gap"]=24,["Actions"]=Text("Save here")},"ng-form-layout","ng-form-cell","--ng-form-columns:2","--ng-form-gap:24px","ng-form-actions","Save here");
foreach(var invalidForm in new Dictionary<string,object?>[]{new(){["Columns"]=0},new(){["Columns"]=5},new(){["MinColumnWidth"]=119},new(){["Gap"]=65},new(){["Fields"]=Array.Empty<RenderFragment>(),["ChildContent"]=Text("Conflict")}}){invalidForm["Model"]=new object();try{await Check<NgForm>(invalidForm);throw new Exception("Invalid form layout accepted");}catch(ArgumentException){count++;}}
await Check<NgForm>(new(){["Model"]=new object(),["Disabled"]=true,["ChildContent"]=Text("Draft")},"fieldset","disabled","Draft","class=\"ng-form-fields\"");
await Check<NgNumericTextBox>(new() { ["Label"] = "Seats", ["Value"] = number, ["ValueExpression"] = (Expression<Func<decimal?>>)(() => number), ["Min"] = (decimal?)1, ["Max"] = (decimal?)100 }, "role=\"spinbutton\"", "aria-valuemin=\"1\"", "aria-valuemax=\"100\"", "value=\"5\"");
await Check<NgCheckBox>(new() { ["Label"] = "Updates", ["Value"] = enabled, ["ValueExpression"] = (Expression<Func<bool>>)(() => enabled) }, "checked", "Updates");
await Check<NgSwitch>(new() { ["Label"] = "Active", ["Value"] = enabled, ["ValueExpression"] = (Expression<Func<bool>>)(() => enabled) }, "role=\"switch\"", "checked");
await Check<NgDropDownList>(new() { ["Label"] = "Team", ["Value"] = team, ["ValueExpression"] = (Expression<Func<string>>)(() => team), ["Items"] = options }, "Alpha", "disabled", "value=\"b\"");
await Check<NgRadioGroup>(new() { ["Label"] = "Access", ["Value"] = team, ["ValueExpression"] = (Expression<Func<string>>)(() => team), ["Items"] = options }, "legend", "value=\"a\"", "checked", "disabled");
await Check<NgTabs>(new() { ["Items"] = new NgTab[] { new("One", Text("First")), new("Two", Text("Second")) }, ["SelectedIndex"] = 1 }, "role=\"tablist\"", "aria-selected=\"true\"", "hidden", "Second");
await Check<NgDialog>(new() { ["Title"] = "Preview", ["ChildContent"] = Text("Details") }, "<dialog", "aria-labelledby", "Preview", "Details");
await Check<NgTooltip>(new() { ["Text"] = "Help" }, "role=\"tooltip\"", "aria-describedby", "Help");
await Check<NgNotification>(new() { ["Visible"] = true, ["Tone"] = "error", ["ChildContent"] = Text("Failed") }, "role=\"alert\"", "Dismiss notification", "Failed");
await Check<NgAutoComplete>(new(){["Value"]="Lo",["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["Items"]=new[]{"London","Lisbon"},["FilterMode"]="startsWith",["MinLength"]=2,["ReadOnly"]=true},"London","readonly");
await Check<NgComboBox>(new(){["Value"]="a",["ValueExpression"]=(Expression<Func<string?>>)(()=>name),["Items"]=options,["ReadOnly"]=true,["ShowClearButton"]=true},"Alpha","readonly","Clear Choose an option");
string[] selectedInputs=["b"];
await Check<NgMultiSelect>(new(){["Value"]=selectedInputs,["ValueExpression"]=(Expression<Func<string[]>>)(()=>selectedInputs),["Items"]=options,["ShowActions"]=true,["ItemTemplate"]=(RenderFragment<NgOption>)(o=>Text("Item "+o.Label)),["TagTemplate"]=(RenderFragment<NgOption>)(o=>Text("Tag "+o.Label))},"Item Alpha","Tag Beta","Select filtered","Clear selection","aria-label=\"Remove Beta\"");
DateOnly? date=new(2026,10,22);
TimeOnly? time=new(9,30);
DateTime? stamp=new(2026,10,22,9,30,0);
await Check<NgCalendar>(new(){["Value"]=date,["Min"]=new DateOnly(2026,10,1),["Max"]=new DateOnly(2026,10,31)},"October", "data-ng-day", "disabled");
await Check<NgDateInput>(new(){["Value"]=date,["ValueExpression"]=(Expression<Func<DateOnly?>>)(()=>date)},"2026-10-22");
await Check<NgDatePicker>(new(){["Value"]=date,["ValueExpression"]=(Expression<Func<DateOnly?>>)(()=>date)},"2026-10-22", "Choose");
await Check<NgTimePicker>(new(){["Value"]=time,["ValueExpression"]=(Expression<Func<TimeOnly?>>)(()=>time)},"09:30", "type=\"time\"");
await Check<NgDateTimePicker>(new(){["Value"]=stamp,["ValueExpression"]=(Expression<Func<DateTime?>>)(()=>stamp)},"2026-10-22", "datetime-local");
await Check<NgNumericTextBox>(new(){["Value"]=number,["ValueExpression"]=(Expression<Func<decimal?>>)(()=>number),["ReadOnly"]=true,["HelperText"]="Bounded amount"},"readonly","Increase Number","Bounded amount");
await Check<NgTimePicker>(new(){["Value"]=time,["ValueExpression"]=(Expression<Func<TimeOnly?>>)(()=>time),["ReadOnly"]=true,["MinuteStep"]=15},"readonly","step=\"any\"");
void Rule(bool condition,string name){if(!condition)throw new Exception(name);count++;Console.WriteLine($"PASS {name}");}
Rule(NgFilterRules.Matches("Alpha","PH","contains",2)&&!NgFilterRules.Matches("Alpha","ph","startsWith",0)&&NgFilterRules.Matches("Alpha","HA","endsWith",0),"selection filter operators");
Rule(!NgFilterRules.Matches("Alpha","a","contains",2),"selection minimum query length");
try{NgFilterRules.Validate("bad",0);throw new Exception("bad filter accepted");}catch(ArgumentException){Rule(true,"reject unsupported filter");}
try{NgFilterRules.ValidateItems([new("a","First"),new("a","Second")]);throw new Exception("duplicate IDs accepted");}catch(ArgumentException){Rule(true,"reject duplicate selection IDs");}
Rule(NgDateRules.TryDate("2024-02-29",out _),"leap day");
foreach(var invalid in new[]{"2026-02-29","2026-04-31","2026-13-01","2026-1-01"}) Rule(!NgDateRules.TryDate(invalid,out _),$"reject {invalid}");
Rule(!NgDateRules.TryTime("24:00",out _),"reject midnight overflow");
Rule(NgDateRules.RangeError(new(new(2026,10,23),new(2026,10,22))) is not null,"reject inverted range");
Rule(!NgDateRules.Allowed(new(2026,10,18),null,null,d=>d.DayOfWeek==DayOfWeek.Sunday),"reject disabled date");
var data=new[]{(Id:"a",Budget:120),(Id:"b",Budget:9000),(Id:"c",Budget:75),(Id:"d",Budget:120)};
NgDataColumn<(string Id,int Budget)>[] dataColumns=[new("id","ID",r=>r.Id),new("budget","Budget",r=>r.Budget)];
Rule(NgDataOperations.Query(data,dataColumns,"","budget",false).Select(r=>r.Id).SequenceEqual(new[]{"c","a","d","b"}),"numeric stable sort");
Rule(NgDataOperations.Query(data,dataColumns,"","budget",true).Select(r=>r.Id).SequenceEqual(new[]{"b","a","d","c"}),"descending stable sort");
Rule(NgDataOperations.Query(data,dataColumns," 75 ",null,false).Single().Id=="c","filter before page");
Rule(NgDataOperations.ClampPage(9,0,5)==1 && NgDataOperations.ClampPage(9,6,5)==2,"page clamps on empty/shrink");
NgTreeNode<string>[] tree=[new("root","Root",[new("a","Alpha"),new("b","Beta",[new("c","Child")])])];
Rule(NgDataOperations.Flatten(tree,new HashSet<string>(),s=>s).Count==1,"collapsed descendants hidden");
var found=NgDataOperations.Flatten(tree,new HashSet<string>(),s=>s,"child");
Rule(found.Select(r=>r.Node.Id).SequenceEqual(new[]{"root","b","c"}) && found.Select(r=>r.Depth).SequenceEqual(new[]{0,1,2}),"search retains ancestor path");
Rule(NgDataOperations.Flatten(tree,new HashSet<string>{"root","b"},s=>s,"",(a,b)=>StringComparer.Ordinal.Compare(b.Item,a.Item)).Select(r=>r.Node.Id).SequenceEqual(new[]{"root","b","c","a"}),"tree sorts siblings only");
try { NgDataOperations.Flatten(new[]{new NgTreeNode<string>("x","One"),new NgTreeNode<string>("x","Two")},new HashSet<string>(),s=>s);throw new Exception("duplicate ID accepted"); } catch(ArgumentException){Rule(true,"duplicate tree IDs rejected");}
await Check<NgPager>(new(){["Total"]=18,["Page"]=2,["PageSize"]=5},"6", "10 of 18", "Rows per page", "Next page");
await Check<NgBreadcrumb>(new(){["Items"]=new NgBreadcrumbItem[]{new("all","All projects"),new("design","Design")}},"aria-current=\"page\"", "All projects", "Design");
await Check<NgDataGrid<(string Id,int Budget)>>(new(){["Items"]=data,["Columns"]=dataColumns,["RowId"]=(Func<(string Id,int Budget),string>)(r=>r.Id)},"Budget", "9000", "Select page");
await Check<NgDataGrid<(string Id,int Budget)>>(new(){["Items"]=data,["Columns"]=dataColumns,["RowId"]=(Func<(string Id,int Budget),string>)(r=>r.Id),["SelectedIds"]=new HashSet<string>{"a"},["SelectionReadOnly"]=true,["PageSizes"]=new[]{2,4}},"disabled", "checked", "value=\"4\"");
await Check<NgDataGrid<string>>(new(){["Items"]=Array.Empty<string>(),["Columns"]=new NgDataColumn<string>[]{new("id","ID",x=>x)},["RowId"]=(Func<string,string>)(x=>x),["EmptyTemplate"]=Text("Try a different query")},"Try a different query", "disabled");
await Check<NgPager>(new(){["Total"]=int.MaxValue,["Page"]=2,["PageSize"]=int.MaxValue-1},"2147483647", "of 2147483647");
await Check<NgTreeView<string>>(new(){["Items"]=tree,["Text"]=(Func<string,string>)(s=>s)},"role=\"tree\"", "Root", "aria-expanded=\"false\"");
await Check<NgTreeList<string>>(new(){["Items"]=tree,["Columns"]=new NgDataColumn<string>[]{new("name","Name",s=>s)}},"Root", "Expand Root", "Search Hierarchy");
await Check<NgTreeView<string>>(new(){["Items"]=tree,["Text"]=(Func<string,string>)(s=>s),["ExpansionReadOnly"]=true,["ItemTemplate"]=(RenderFragment<string>)(s=>Text("Team "+s))},"Team Root", "aria-label=\"Root\"", "disabled");
await Check<NgTreeList<string>>(new(){["Items"]=tree,["Columns"]=new NgDataColumn<string>[]{new("name","Name",s=>s,Template:s=>Text("Team "+s))},["SelectionReadOnly"]=true},"Team Root","aria-label=\"Root\"","disabled");
await Check<NgTreeView<string>>(new(){["Text"]=(Func<string,string>)(s=>s),["EmptyTemplate"]=Text("Empty tree")},"Empty tree");
await Check<NgTreeList<string>>(new(){["Columns"]=new NgDataColumn<string>[]{new("name","Name",s=>s)},["EmptyText"]="Empty hierarchy"},"Empty hierarchy");
Rule(!NgDataOperations.Flatten(tree,new HashSet<string>{"root","a"},s=>s).Single(r=>r.Node.Id=="a").Expanded,"leaf expanded IDs ignored");
try{NgDataOperations.Flatten(new[]{new NgTreeNode<string>(" ","Bad")},new HashSet<string>(),s=>s);throw new Exception("blank ID accepted");}catch(ArgumentException){Rule(true,"blank tree IDs rejected");}
NgChartSeries[] signed=[new("Values",[-10,0,20])];
var chart=NgChartMath.Build(NgChartKind.Column,["A","B","C"],signed);
var bars=chart.Marks.Where(m=>m.Point!=null).ToArray();
Rule(bars.Length==3 && bars.All(m=>m.Coordinates.All(double.IsFinite)) && bars[0].Coordinates[1]>bars[2].Coordinates[1],"signed chart bars share a finite zero baseline");
Rule(NgChartMath.Build(NgChartKind.Line,["A","B"],[new("Large",[0,1e308])]).Marks.All(m=>m.Coordinates.All(double.IsFinite)),"large finite chart ticks do not overflow");
var gaps=NgChartMath.Build(NgChartKind.Line,["A","B","C"],[new("Gap",[1,null,3])]);
Rule(gaps.Marks.Count(m=>m.Kind=="dot")==2 && !gaps.Marks.Any(m=>m.Kind=="line"&&m.Color!="grid"),"null points break lines");
Rule(NgChartMath.Build(NgChartKind.Area,["A","B","C"],signed,new HashSet<int>{0}).Marks.Count==0,"hidden series produces empty chart");
foreach(var kind in Enum.GetValues<NgChartKind>()) Rule(NgChartMath.Build(kind,["Only"],[new("One",[1])]).Marks.Any(m=>m.Point!=null),$"single point {kind}");
void Reject(Action action,string label){try{action();throw new Exception(label+" accepted");}catch(ArgumentException){Rule(true,label);}}
Reject(()=>NgChartMath.Build(NgChartKind.Pie,["A"],[new("Negative",[-1])]),"negative pie rejected");
Reject(()=>NgChartMath.Build(NgChartKind.Line,["A"],[new("Bad",[double.NaN])]),"nonfinite chart rejected");
Reject(()=>NgChartMath.Build(NgChartKind.Line,["A"],[new("Bad",[1,2])]),"mismatched categories rejected");
Rule(NgChartMath.Fraction(-1,0,100)==0&&NgChartMath.Fraction(150,0,100)==1,"gauge clamps outside bounds");
Reject(()=>NgChartMath.Fraction(1,1,1),"empty gauge range rejected");
var overnight=new NgScheduleEvent("x","Overnight",new(2026,12,31,23,0,0),new(2027,1,1,1,0,0));
Rule(NgScheduleRules.ForDay([overnight],new(2026,12,31)).Count==1&&NgScheduleRules.ForDay([overnight],new(2027,1,1)).Count==1,"overnight event in both calendar days");
Rule(NgScheduleRules.ForDay([overnight with {End=new(2027,1,1)}],new(2027,1,1)).Count==0,"midnight end excluded from next day");
Rule(NgScheduleRules.WeekStart(new(2027,1,3))==new DateTime(2026,12,28),"week crosses year boundary");
Rule(NgScheduleRules.Validate(overnight with {End=overnight.Start})!=null,"zero duration rejected");
await Check<NgChart>(new(){["Categories"]=new[]{"A","B","C"},["Series"]=signed},"<svg", "Values", "Chart data", "role=\"button\"");
await Check<NgChart>(new(){["Categories"]=new[]{"A","B","C"},["Series"]=signed,["HiddenSeries"]=new HashSet<int>{0,99},["EmptyText"]="Nothing visible"},"Nothing visible", "disabled");
await Check<NgChart>(new(){["Categories"]=new[]{"A","B","C"},["Series"]=signed,["SelectionReadOnly"]=true,["PointLabel"]=(Func<NgChartSelection,string>)(p=>$"Amount {p.Value} units")},"Amount -10 units", "aria-disabled=\"true\"", "disabled");
await Check<NgLinearGauge>(new(){["Value"]=150d},"role=\"meter\"", "aria-valuenow=\"100\"");
await Check<NgArcGauge>(new(){["Value"]=84d},"84", "<svg");
await Check<NgScheduler>(new(){["Date"]=new DateTime(2026,12,31),["Items"]=new[]{overnight}},"Overnight", "2027-01-01", "Previous week");
var sheet=new NgSheet(cells:new Dictionary<string,string>{{"A1","10"},{"A2","20"},{"A3","text"},{"B1","=A1+A2*2"},{"B2","=SUM(A1:A3)"},{"B3","=AVERAGE(A1:A3)"},{"C1","=-(2+3)*4/2"},{"C2","=COUNT(A1:A3)"}});
Rule(sheet.Evaluate("B1").Number==50&&sheet.Evaluate("B2").Number==30&&sheet.Evaluate("B3").Number==15&&sheet.Evaluate("C1").Number==-10&&sheet.Evaluate("C2").Number==2,"spreadsheet formula precedence and range functions");
Rule(sheet.Set("A1","50").Evaluate("B1").Number==90&&sheet.Evaluate("B1").Number==50,"immutable edits recalculate dependencies");
foreach(var (formula,expected) in new Dictionary<string,string>{{"=1/0","#DIV/0!"},{"=Z99","#REF!"},{"=UNKNOWN(1)","#NAME?"},{"=1+","#FORMULA!"},{"=1e309","#NUM!"},{"=A2+1","#VALUE!"},{"=A1","#CYCLE!"}})Rule(new NgSheet(cells:new Dictionary<string,string>{{"A1",formula},{"A2","text"}}).Evaluate("A1").Error==expected,$"formula rejects {formula}");
Rule(new NgSheet(cells:new Dictionary<string,string>{{"A1","=B1"},{"B1","=A1"}}).Evaluate("A1").Error=="#CYCLE!","indirect formula cycle");
Rule(new NgSheet(cells:new Dictionary<string,string>{{"A1","1e308"},{"A2","1e308"},{"B1","=AVERAGE(A1:A2)"}}).Evaluate("B1").Number==1e308,"large average stays finite");
var fanout=new Dictionary<string,string>{{"A1","1"}};for(var r=2;r<=80;r++)fanout[$"A{r}"]=$"=A{r-1}+A{r-1}";
Rule(new NgSheet(80,2,fanout).Evaluate("A80").Number.HasValue,"shared dependencies are cached");
Rule(new NgSheet(cells:new Dictionary<string,string>{{"A1","="+new string('(',70)+"1"+new string(')',70)}}).Evaluate("A1").Error=="#LIMIT!","formula nesting limit");
Rule(sheet.Paste("D1","2\t3\r\n=SUM(D1:E1)\ttext").Evaluate("D2").Number==5,"paste preserves formulas and CRLF");
Reject(()=>sheet.Paste("F8","1\t2"),"paste beyond bounds rejected atomically");
NgPivotRecord[] pivot=[new("1",new Dictionary<string,string>{{"Team","A"},{"Quarter","Q1"}},10),new("2",new Dictionary<string,string>{{"Team","A"},{"Quarter","Q1"}},20),new("3",new Dictionary<string,string>{{"Team","B"},{"Quarter","Q2"}},90),new("4",new Dictionary<string,string>{{"Team",""},{"Quarter","Q2"}},null)];
Rule(NgPivotMath.Aggregate(pivot,NgAggregate.Average)==40&&NgPivotMath.Aggregate(pivot,NgAggregate.Count)==4&&NgPivotMath.Aggregate(pivot,NgAggregate.Sum)==120,"pivot totals aggregate source records, not displayed means");
Rule(NgPivotMath.Filter(pivot,"Team","Quarter","",null).Count==1&&NgPivotMath.Filter(pivot,"Team","Quarter",null,null).Count==4,"blank pivot dimension differs from total");
Reject(()=>NgPivotMath.Validate([pivot[0],pivot[0]]),"duplicate pivot IDs rejected");
await Check<NgSpreadsheet>(new(){["Value"]=sheet,["ValueChanged"]=EventCallback.Factory.Create<NgSheet>(new object(),(NgSheet _) => {})},"Apply cell", "A1: 10", "B1: 50", "Undo", "Paste cells");
await Check<NgPivotGrid>(new(){["Items"]=pivot},"A / Q1: 30", "Total / Total: 120", "(blank)");
var doc = new NgDocument([new("Title",NgBlockKind.Heading1),new("<script>alert('x')</script>\n&",NgBlockKind.Bullet,Bold:true),new("Second",NgBlockKind.Bullet),new("Last",NgBlockKind.Numbered)]);
Rule(NgDocument.FromJson(doc.ToJson()).ToJson()==doc.ToJson(),"document JSON roundtrip");
Rule(doc.ToHtml().Contains("&lt;script&gt;") && !doc.ToHtml().Contains("<script>"),"document HTML escapes text");
Rule(doc.ToHtml().Contains("</li></ul><ol>") && doc.ToHtml().Contains("<strong>") && doc.ToHtml().Contains("<br>"),"document groups list types and formats text");
Rule(doc.Move(0,3).Blocks[3].Text=="Title" && doc.Blocks[0].Text=="Title","document move preserves immutable source");
Rule(new NgDocument().Remove(0).Blocks.Count==1,"delete last block leaves empty document");
Rule(doc.InsertAfter(0).Blocks[1].Text=="" && doc.Replace(0,new("Changed")).Blocks[0].Text=="Changed","document insert and replace");
Reject(()=>new NgDocument([]),"document rejects empty block list");
Reject(()=>new NgDocument(Enumerable.Repeat(new NgDocumentBlock(),101)),"document block limit");
Reject(()=>new NgDocument([new(new string('x',10001))]),"document text limit");
Reject(()=>new NgDocument(Enumerable.Repeat(new NgDocumentBlock(new string('x',10000)),11)),"document total limit");
Reject(()=>NgDocument.FromJson("{\"version\":2,\"blocks\":[{}]}"),"document rejects unknown version");
Reject(()=>NgDocument.FromJson("{\"version\":1,\"blocks\":[{\"kind\":99}]}"),"document rejects numeric enum");
Reject(()=>NgDocument.FromJson("{\"version\":1,\"blocks\":[{\"html\":\"unsafe\"}]}"),"document rejects raw HTML property");
Reject(()=>NgDocument.FromJson("null"),"document rejects null JSON");
await Check<NgEditor>(new(){["Value"]=doc,["ReadOnly"]=true},"Document preview","readonly","&lt;script&gt;","disabled","Block text");
await Check<NgEditor>(new(){["Value"]=doc},"readonly","disabled","Discard draft","Document preview");
await Check<NgEditor>(new(){["Value"]=doc,["ValueChanged"]=EventCallback.Factory.Create<NgDocument>(new object(),_=>{})},"Discard draft","Apply text","Document blocks");
var graph = new NgDiagramModel([new("a","Start",10,10),new("b","End",400,10,Shape:NgDiagramShape.Ellipse)],[new("e","a","b","Next")]);
Rule(NgDiagramModel.FromJson(graph.ToJson()).ToJson()==graph.ToJson(),"diagram JSON roundtrip");
var moved=graph.Move("a",-100,900);Rule(moved.Nodes[0].X==0&&moved.Nodes[0].Y==520&&graph.Nodes[0].X==10,"diagram immutable move clamps canvas");
Rule(graph.RemoveNode("a").Edges.Count==0&&graph.Nodes.Count==2,"diagram node deletion cascades only in new graph");
Rule(graph.RemoveEdge("e").Nodes.Count==2&&graph.RemoveEdge("e").Edges.Count==0,"diagram edge deletion preserves nodes");
Rule(graph.Line(graph.Edges[0]).Start==new NgDiagramPoint(170,50)&&graph.Line(graph.Edges[0]).End==new NgDiagramPoint(400,50),"diagram anchors on rectangle and ellipse boundaries");
var diamond=graph.UpsertNode(graph.Nodes[0] with {Shape=NgDiagramShape.Diamond});Rule(diamond.Line(diamond.Edges[0]).Start==new NgDiagramPoint(170,50),"diagram diamond boundary");
Rule(graph.UpsertEdge(new("e","b","a","Reverse",false)).Edges.Single().From=="b","diagram edge edit retains ID");
Reject(()=>new NgDiagramModel([graph.Nodes[0],graph.Nodes[0]]),"diagram duplicate node ID");
Reject(()=>new NgDiagramModel(graph.Nodes,[new("e","a","missing")]),"diagram dangling edge");
Reject(()=>new NgDiagramModel(graph.Nodes,[new("e","a","a")]),"diagram self link");
Reject(()=>graph.UpsertNode(graph.Nodes[0] with {X=double.NaN}),"diagram nonfinite bounds");
Reject(()=>graph.UpsertNode(graph.Nodes[0] with {Width=10}),"diagram invalid size");
Reject(()=>graph.Move("a",double.PositiveInfinity,0),"diagram nonfinite movement");
Reject(()=>graph.UpsertNode(new("bad id","Text",0,0)),"diagram invalid ID");
Reject(()=>NgDiagramModel.FromJson("{\"version\":2,\"width\":1000,\"height\":600,\"nodes\":[],\"edges\":[]}"),"diagram unknown version");
Reject(()=>NgDiagramModel.FromJson("{\"version\":1,\"width\":1000,\"height\":600,\"nodes\":[{\"id\":\"a\",\"text\":\"A\"}],\"edges\":[]}"),"diagram required coordinates");
await Check<NgDiagram>(new(){["Value"]=graph,["ReadOnly"]=true,["SelectedNodeId"]="a"},"Node Start","Connection Next: a to b","data-readonly=\"true\"","ng-selected","Fit width");
await Check<NgDiagram>(new(),"No nodes yet.");
await Check<NgDiagram>(new(){["Value"]=graph,["SelectionReadOnly"]=true,["NodeLabel"]=(Func<NgDiagramNode,string>)(n=>"Task <"+n.Text+">"),["EdgeLabel"]=(Func<NgDiagramEdge,string>)(e=>"Flow "+e.Text)},"Task &lt;Start&gt;","Flow Next","aria-disabled=\"true\"","data-readonly=\"true\"");
await Check<NgDiagram>(new(){["EmptyText"]="Nothing to connect"},"Nothing to connect");
await Check<NgDiagram>(new(){["Value"]=graph,["SelectionReadOnly"]=true,["ValueChanged"]=EventCallback.Factory.Create<NgDiagramModel>(new object(),_=>{})},"data-readonly=\"false\"","Node Start");
var largeNodes=Enumerable.Range(0,100).Select(i=>new NgDiagramNode("n"+i.ToString().PadLeft(63,'x'),new string('漢',100),0,0)).ToArray();
var largeEdges=Enumerable.Range(0,200).Select(i=>new NgDiagramEdge("e"+i.ToString().PadLeft(63,'x'),largeNodes[i%100].Id,largeNodes[(i+1)%100].Id,new string('漢',100))).ToArray();
var largeGraph=new NgDiagramModel(largeNodes,largeEdges);Rule(largeGraph.ToJson().Length>200000&&NgDiagramModel.FromJson(largeGraph.ToJson()).Edges.Count==200,"maximum Unicode diagram roundtrips within JSON limit");

var offsetGraph=new NgDiagramModel([new("fit","Fit",3000,3000,200,100)],width:5000,height:5000);
var fitView=offsetGraph.FitView(448,248);
Rule(fitView==new NgDiagramView(2,5976,5976),"fit occupied bounds centers distant node at maximum zoom");
Rule(new NgDiagramModel().FitView(400,300)==new NgDiagramView(1,0,0),"empty fit resets origin");
Rule(new NgDiagramModel([new("first","First",0,0),new("last","Last",4800,4800)],width:5000,height:5000).FitView(300,200).Zoom==.25,"fit honors minimum zoom");
Rule(offsetGraph.FitView(148,98).Zoom==.5,"fit reserves 24px padding and respects both dimensions");
Reject(()=>offsetGraph.FitView(double.NaN,300),"fit rejects nonfinite viewport");
await Check<NgPdfViewer>(new(){["Label"]="Invoice",["Source"]="samples/test.pdf",["Dark"]=true},"title=\"Invoice\"","theme=dark","source=http%3A%2F%2Flocalhost%2Fsamples%2Ftest.pdf");
await Check<NgPdfViewer>(new(),"PDF viewer","source=");
var mapPoints=new[]{new NgMapPoint(50.45,30.52),new NgMapPoint(50.46,30.54),new NgMapPoint(50.44,30.55)};
var mapPath=new NgMapPath("area","Park",mapPoints,true);mapPoints[0]=new(0,0);
Rule(mapPath.Points[0].Latitude==50.45,"map copies caller point collections");
Reject(()=>new NgMapPoint(double.NaN,0),"map rejects nonfinite coordinate");
Reject(()=>new NgMapPoint(86,0),"map rejects outside Web Mercator");
Reject(()=>new NgMapPoint(0,181),"map rejects longitude overflow");
Reject(()=>new NgMapView(0,0,20),"map rejects unsupported zoom");
Reject(()=>new NgMapPath("p","Polygon",[new(0,0),new(1,1)],true),"map polygon needs three points");
Reject(()=>new NgMapModel([new("area","Duplicate",new(0,0))],[mapPath]),"map rejects cross-layer duplicate IDs");
Reject(()=>new NgMapModel(Enumerable.Range(0,501).Select(i=>new NgMapMarker("m"+i,"Marker",new(0,0)))),"map marker limit");
Reject(()=>new NgMapMarker("bad id","Marker",new(0,0)),"map rejects invalid IDs");
await Check<NgMap>(new(){["Label"]="Places <safe>"},"Places &lt;safe&gt;","map-viewer/index.html","height:520px");
#pragma warning disable BL0005
var selectionEvents=0;var viewEvents=0;var clickEvents=0;
var eventMap=new NgMap{Value=new NgMapModel([new("office","Office",new(0,0))]),SelectedIdChanged=EventCallback.Factory.Create<string?>(new object(),_=>selectionEvents++),ViewChanged=EventCallback.Factory.Create<NgMapView>(new object(),_=>viewEvents++),OnMapClick=EventCallback.Factory.Create<NgMapPoint>(new object(),_=>clickEvents++)};
await eventMap.MapEvent("{\"kind\":\"selection\",\"revision\":0,\"id\":\"office\"}");Rule(selectionEvents==1,"map valid selection event");
await eventMap.MapEvent("{\"kind\":\"selection\",\"revision\":1,\"id\":\"office\"}");Rule(selectionEvents==1,"map stale event rejected");
await eventMap.MapEvent("{\"kind\":\"selection\",\"revision\":0,\"id\":\"missing\"}");Rule(selectionEvents==1,"map unknown selection rejected");
eventMap.SelectionReadOnly=true;await eventMap.MapEvent("{\"kind\":\"selection\",\"revision\":0,\"id\":null}");Rule(selectionEvents==1,"map selection lock enforced");
await eventMap.MapEvent("{\"kind\":\"view\",\"revision\":0,\"latitude\":10,\"longitude\":20,\"zoom\":5}");Rule(viewEvents==1,"map view remains independently enabled");
eventMap.NavigationReadOnly=true;await eventMap.MapEvent("{\"kind\":\"view\",\"revision\":0,\"latitude\":10,\"longitude\":20,\"zoom\":5}");Rule(viewEvents==1,"map navigation lock enforced");
await eventMap.MapEvent("{\"kind\":\"click\",\"revision\":0,\"latitude\":10,\"longitude\":20}");Rule(clickEvents==1,"map background click remains independent");
eventMap.MapClickReadOnly=true;await eventMap.MapEvent("{\"kind\":\"click\",\"revision\":0,\"latitude\":10,\"longitude\":20}");Rule(clickEvents==1,"map click lock enforced");
eventMap.NavigationReadOnly=false;eventMap.MapClickReadOnly=false;
foreach(var invalidEvent in new[]{"not json","[]","{}","{\"kind\":\"view\",\"revision\":0,\"latitude\":90,\"longitude\":20,\"zoom\":5}","{\"kind\":\"view\",\"revision\":0,\"latitude\":10,\"longitude\":20,\"zoom\":25}","{\"kind\":\"click\",\"revision\":0,\"latitude\":10,\"longitude\":181}"})await eventMap.MapEvent(invalidEvent);
Rule(viewEvents==1&&clickEvents==1,"map malformed and out of range events ignored");
await eventMap.DisposeAsync();await eventMap.MapEvent("{\"kind\":\"click\",\"revision\":1,\"latitude\":10,\"longitude\":20}");Rule(clickEvents==1,"map disposed events ignored");
#pragma warning restore BL0005

foreach(var radius in new[]{19,121}) {
 try {await Check<NgMap>(new(){["ClusterRadius"]=radius});throw new Exception("Invalid cluster radius accepted");}
 catch(ArgumentOutOfRangeException){Rule(true,"map rejects cluster radius "+radius);}
}
await Check<NgMap>(new(){["ClusterMarkers"]=true,["ClusterRadius"]=120},"map-viewer/index.html");
await Check<NgPromptBox>(new(){["Value"]="Long draft",["MaxLength"]=3},"Long draft","Shorten the prompt to 3","disabled");
await Check<NgAIPrompt>(new(){["Value"]="draft",["GenerationReadOnly"]=true,["HistoryReadOnly"]=true,["FeedbackReadOnly"]=true,["Generate"]=(Func<string,CancellationToken,Task<string>>)((_,_)=>Task.FromResult("response"))},"readonly","disabled","No responses yet");
await Check<NgPromptBox>(new(){["Value"]="<unsafe>",["Busy"]=true},"&lt;unsafe&gt;","readonly","Cancel","8000");
await Check<NgAIPrompt>(new(){["Suggestions"]=new[]{"First suggestion"},["Value"]="Bound initial prompt"},"Bound initial prompt","No responses yet","Connect a generation handler","First suggestion");
using(var prompts=new NgPromptSession()) {
 var pending=new TaskCompletionSource<string>();CancellationToken captured=default;
 var first=prompts.RunAsync("  old request  ",(p,t)=>{captured=t;return pending.Task;});
 Rule(prompts.IsBusy,"prompt busy immediately");
 Rule(await prompts.RunAsync("duplicate",(_,_)=>Task.FromResult("duplicate")) is null,"prompt prevents concurrent duplicate");
 prompts.Cancel();Rule(captured.IsCancellationRequested&&!prompts.IsBusy,"prompt cancellation reaches provider");
 await prompts.RunAsync("new request",(_,_)=>Task.FromResult("new response"));pending.SetResult("late old response");
 Rule(await first is null&&prompts.Responses.Count==1&&prompts.Selected!.Text=="new response","late cancelled response cannot overwrite new result");
 await prompts.RunAsync("failure",(_,_)=>throw new Exception("provider secret detail"));
 Rule(prompts.Error=="Generation failed. Try again."&&prompts.Responses.Count==1,"provider errors do not leak details or erase history");
 await prompts.RunAsync("empty",(_,_)=>Task.FromResult(" "));
 Rule(prompts.Error is not null,"empty prompt response rejected");
 await prompts.RunAsync("large",(_,_)=>Task.FromResult(new string('a',32001)));
 Rule(prompts.Error is not null,"oversized response rejected");
 for(var i=0;i<22;i++)await prompts.RunAsync("history "+i,(_,_)=>Task.FromResult("ok"));
 Rule(prompts.Responses.Count==20&&prompts.Responses[0].Prompt=="history 2","prompt history retains latest 20 results");
 var last=new TaskCompletionSource<string>();var clearing=prompts.RunAsync("clear me",(_,_)=>last.Task);prompts.Clear();last.SetResult("late");
 Rule(await clearing is null&&prompts.Responses.Count==0&&prompts.Selected is null,"clear prevents late repopulation");
 try{await prompts.RunAsync("   ",(_,_)=>Task.FromResult("invalid"));throw new Exception("blank accepted");}catch(ArgumentException){Rule(true,"blank prompt rejected");}
}
var disposedPrompts=new NgPromptSession();var afterDispose=new TaskCompletionSource<string>();var outstanding=disposedPrompts.RunAsync("dispose",(_,_)=>afterDispose.Task);disposedPrompts.Dispose();afterDispose.SetResult("late");Rule(await outstanding is null,"disposed prompt session ignores late result");
var steps=new NgStep[]{new("Contact"),new("Disabled",Disabled:true),new("Optional",Optional:true),new("Review",Valid:false)};
await Check<NgStepper>(new(){["Items"]=steps,["Linear"]=true},"aria-current=\"step\"","disabled","Optional","Needs attention");
await Check<NgStepper>(new(){["Items"]=steps,["Vertical"]=true,["Value"]=2},"ng-stepper-vertical","aria-current=\"step\"");
await Check<NgWizard>(new(){["Items"]=steps,["ChildContent"]=(RenderFragment<int>)(i=>Text($"Content {i}"))},"Content 0","Step 1 of 4","Next","Back");
Rule(NgStepRules.Adjacent(steps,0,1)==2&&NgStepRules.Adjacent(steps,2,-1)==0,"step navigation skips disabled entries");
Rule(NgStepRules.Adjacent(steps,0,-1)==-1&&NgStepRules.Adjacent(steps,3,1)==-1,"step boundaries");
Rule(NgStepRules.CanMove(steps,0,2,true)&&!NgStepRules.CanMove(steps,0,3,true)&&NgStepRules.CanMove(steps,3,0,true),"linear step contract");
Rule(NgStepRules.CanMove(steps,0,3,false)&&!NgStepRules.CanMove(steps,0,1,false)&&!NgStepRules.CanMove(steps,0,0,false),"nonlinear and current/disabled contract");
foreach(var invalid in new[]{-1,1,4}){try{NgStepRules.Validate(steps,invalid);throw new Exception("invalid current accepted");}catch(ArgumentException){Rule(true,"invalid active step rejected");}}
try{NgStepRules.Adjacent(steps,0,0);throw new Exception("zero direction accepted");}catch(ArgumentOutOfRangeException){Rule(true,"zero direction rejected");}
Reject(()=>NgStepRules.ValidatePresentation(" "),"empty stepper label");
Reject(()=>NgStepRules.ValidatePresentation("Progress","icons"),"unknown step display mode");
Reject(()=>NgStepRules.ValidatePresentation("Progress","all","left"),"unknown wizard position");
await Check<NgStepper>(new(){["Items"]=new[]{new NgStep("Review",Optional:true)},["DisplayMode"]="indicators",["Rtl"]=true,["IndicatorTemplate"]=(RenderFragment<NgStepContext>)(s=>Text("Custom icon"))},"aria-label=\"Step 1: Review, Optional\"","data-display-mode=\"indicators\"","dir=\"rtl\"","Custom icon");
await Check<NgWizard>(new(){["Items"]=new[]{new NgStep("Review")},["Position"]="end",["ChildContent"]=(RenderFragment<int>)(_=>Text("Summary")),["ActionsTemplate"]=(RenderFragment<NgWizardActions>)(a=>Text($"Custom actions {a.CanFinish}"))},"data-position=\"end\"","Custom actions False","Summary");
var menuChildren=new List<NgMenuItem>{new("leaf","Leaf")};var menuGroup=new NgMenuItem("group","Group",children:menuChildren);menuChildren.Clear();
Rule(menuGroup.Children.Count==1,"menu copies caller children");
NgNavigationRules.ValidateMenu([menuGroup]);
Rule(NgNavigationRules.CanInvoke([menuGroup],"leaf")&&!NgNavigationRules.CanInvoke([menuGroup],"group"),"menu invokes leaf only");
Rule(!NgNavigationRules.CanInvoke([new("blocked","Blocked",true,[menuGroup])],"leaf"),"disabled ancestor blocks command");
Reject(()=>NgNavigationRules.ValidateMenu([menuGroup,new("leaf","Duplicate")]),"duplicate menu ID");
Reject(()=>NgNavigationRules.ValidateMenu([new("a","A",children:[new("b","B",children:[menuGroup])])]),"menu depth limit");
Reject(()=>NgNavigationRules.ValidateMenu(Enumerable.Range(0,101).Select(i=>new NgMenuItem("n"+i,"Node")).ToArray()),"menu count limit");
Reject(()=>NgNavigationRules.ValidateDrawer([new("a","A"),new("a","Duplicate")],260),"duplicate drawer ID");
Reject(()=>NgNavigationRules.ValidateDrawer([],199),"drawer width limit");
await Check<NgMenu>(new(){["Items"]=new[]{menuGroup},["Label"]="Commands <safe>"},"menubar","Commands &lt;safe&gt;","aria-haspopup=\"menu\"","popover=\"auto\"");
await Check<NgDrawer>(new(){["Items"]=new[]{new NgOption("a","Overview")},["Expanded"]=true,["Overlay"]=false,["SelectedId"]="a"},"ng-drawer-push","aria-current=\"page\"","Overview");
Reject(()=>NgNavigationRules.ValidateMenu([new("sep","Section",separator:true,children:[new("x","X")])]),"separator children rejected");
Reject(()=>NgNavigationRules.ValidatePresentation(" "),"blank navigation label");
Reject(()=>NgNavigationRules.ValidatePresentation("Navigation","left"),"invalid logical position");
Rule(!NgNavigationRules.CanInvoke([new("hidden","Hidden",visible:false,children:[new("x","X")])],"x"),"hidden ancestor cannot invoke");
Rule(!NgNavigationRules.CanInvoke([new("sep","Section",separator:true)],"sep"),"separator cannot invoke");
await Check<NgMenu>(new(){["Items"]=new[]{new NgMenuItem("sep","Section",separator:true),new NgMenuItem("go","Go")},["Rtl"]=true,["CloseOnClick"]=false,["ItemTemplate"]=(RenderFragment<NgMenuItem>)(item=>Text("Custom text"))},"role=\"separator\"","dir=\"rtl\"","data-close-on-click=\"false\"","aria-label=\"Go\"","Custom text");
await Check<NgDrawer>(new(){["Items"]=new[]{new NgOption("a","Overview"),new NgOption("sep","Section")},["Expanded"]=true,["Overlay"]=false,["Position"]="end",["Rtl"]=true,["HeaderTemplate"]=Text("Custom header"),["FooterTemplate"]=Text("Custom footer"),["IsSeparator"]=(Func<NgOption,bool>)(i=>i.Value=="sep"),["ItemTemplate"]=(RenderFragment<NgOption>)(item=>Text("Custom item"))},"data-position=\"end\"","dir=\"rtl\"","ng-drawer-separator","Custom header","Custom footer","aria-label=\"Overview\"","Custom item");

var choices=new NgOption[]{new("a","Alpha"),new("b","Beta"),new("c","Locked",true)};var choiceValue=new List<string>{"a"};
Rule(NgSelectionRules.Toggle(choices,choiceValue,"b",true,true).SequenceEqual(new[]{"a","b"})&&choiceValue.SequenceEqual(new[]{"a"}),"multi selection preserves caller state");
Rule(NgSelectionRules.Toggle(choices,choiceValue,"b",false,true).SequenceEqual(new[]{"b"}),"single selection replaces prior choice");
Rule(NgSelectionRules.Toggle(choices,choiceValue,"a",false,false).SequenceEqual(choiceValue),"prevent last deselection");
Rule(NgSelectionRules.Toggle(choices,choiceValue,"a",false,true).Count==0,"allow empty selection");
Rule(NgSelectionRules.Toggle(choices,choiceValue,"c",true,true).SequenceEqual(choiceValue),"disabled choice ignored");
Reject(()=>NgSelectionRules.Validate(choices,["a","a"],true),"duplicate selected IDs");
Reject(()=>NgSelectionRules.Validate(choices,["a","b"],false),"multiple IDs in single mode");
Reject(()=>NgSelectionRules.Validate(choices,["missing"],true),"unknown selection ID");
Reject(()=>NgSelectionRules.Validate([choices[0],choices[0]],[],true),"duplicate option IDs");
Reject(()=>NgSelectionRules.Validate(Enumerable.Range(0,51).Select(i=>new NgOption("n"+i,"Node")).ToArray(),[],true),"selection item limit");
await Check<NgToggleButton>(new(){["Label"]="Flag",["AriaLabel"]="Flag setting",["Id"]="flag",["TabIndex"]=-1,["Size"]="lg",["Rounded"]="full",["FillMode"]="link",["ThemeColor"]="success",["Leading"]=Text("★"),["ChildContent"]=Text("Custom"),["OnClick"]=EventCallback.Factory.Create(new object(),()=>{})},"aria-label=\"Flag setting\"","tabindex=\"-1\"","ng-button-size-lg","ng-button-fill-link","Custom");
var hiddenButton=await renderer.Dispatcher.InvokeAsync(async()=>(await renderer.RenderComponentAsync<NgToggleButton>(ParameterView.FromDictionary(new Dictionary<string,object?>{["Label"]="Hidden",["Visible"]=false}))).ToHtmlString());
Rule(!hiddenButton.Contains("button"),"hidden toggle has no action DOM");
var mixedButtons=await renderer.Dispatcher.InvokeAsync(async()=>(await renderer.RenderComponentAsync<NgButtonGroup>(ParameterView.FromDictionary(new Dictionary<string,object?>{["Items"]=options,["IsCommand"]=(Func<NgOption,bool>)(x=>x.Value=="a"),["OnClick"]=EventCallback.Factory.Create<string>(new object(),_=>{}),["ItemTemplate"]=(RenderFragment<NgOption>)(x=>Text("Custom "+x.Label))}))).ToHtmlString());
Rule(mixedButtons.Contains("aria-label=\"Alpha\"")&&System.Text.RegularExpressions.Regex.Matches(mixedButtons,"aria-pressed=").Count==options.Length-1,"commands omit pressed state while preserving labelled templates");
try { await Check<NgButtonGroup>(new(){["Items"]=options,["Value"]=new[]{"a"},["IsCommand"]=(Func<NgOption,bool>)(x=>x.Value=="a")});throw new Exception("Selected command accepted"); } catch(ArgumentException){Rule(true,"selected command rejected");}
Reject(()=>NgButtonRules.Validate("xl","md","outline","primary"),"invalid button size");
Reject(()=>NgButtonRules.Validate("md","md","gradient","primary"),"invalid button fill");
await Check<NgToggleButton>(new(){["Label"]="Bold <safe>",["Value"]=true},"aria-pressed=\"true\"","Bold &lt;safe&gt;","disabled");
await Check<NgButtonGroup>(new(){["Items"]=choices,["Value"]=choiceValue,["Vertical"]=true},"role=\"group\"","ng-button-group-vertical","aria-pressed=\"true\"","Locked");
await Check<NgButtonGroup>(new(),"No options");
await Check<NgChip>(new(){["Label"]="<unsafe>",["Value"]=true,["Disabled"]=true,["OnRemove"]=EventCallback.Factory.Create(new object(),()=>{})},"&lt;unsafe&gt;","aria-pressed=\"true\"","disabled","Remove &lt;unsafe&gt;");
await Check<NgChip>(new(){["Label"]="Published",["Selectable"]=false},"aria-label=\"Published\">Published</span>");
await Check<NgChipList>(new(){["Items"]=options,["Value"]=new string[]{"a"},["Multiple"]=true},"role=\"listbox\"","role=\"option\"","aria-selected=\"true\"","aria-selected=\"false\"","aria-multiselectable=\"true\"","aria-orientation=\"horizontal\"");
await Check<NgChipList>(new(){["Items"]=options,["Selectable"]=false},"role=\"group\"");
var semanticHtml = await renderer.Dispatcher.InvokeAsync(async () => (await renderer.RenderComponentAsync<NgChipList>(ParameterView.FromDictionary(new Dictionary<string,object?>{["Items"]=options}))).ToHtmlString());
Rule(!semanticHtml.Contains("aria-pressed")&&!semanticHtml.Contains("aria-multiselectable"),"single listbox has selected state without pressed or multiselectable");
var removableSemanticHtml = await renderer.Dispatcher.InvokeAsync(async () => (await renderer.RenderComponentAsync<NgChipList>(ParameterView.FromDictionary(new Dictionary<string,object?>{["Items"]=options,["OnRemove"]=EventCallback.Factory.Create<string>(new object(),_=>{})}))).ToHtmlString());
Rule(removableSemanticHtml.Contains("role=\"group\"")&&!removableSemanticHtml.Contains("role=\"option\"")&&removableSemanticHtml.Contains("aria-pressed"),"removable chips retain separate accessible buttons");
await Check<NgChip>(new(){["Label"]="CI",["AriaLabel"]="CI — Continuous integration",["Value"]=true,["OnRemove"]=EventCallback.Factory.Create(new object(),()=>{})},"aria-label=\"CI &#x2014; Continuous integration\"","aria-pressed=\"true\"","Remove CI",">CI</button>");
await Check<NgChip>(new(){["Label"]="CI",["AriaLabel"]="CI status",["Selectable"]=false},"role=\"group\"","aria-label=\"CI status\"");
try { await Check<NgChip>(new(){["Label"]="CI",["AriaLabel"]="  "});throw new Exception("Blank accessible name accepted"); } catch(ArgumentException){Rule(true,"blank chip accessible name rejected");}
await Check<NgChipList>(new(){["Items"]=Array.Empty<NgOption>()},"No tags","role=\"listbox\"");
await Check<NgChipList>(new(){["Items"]=options,["Value"]=new string[]{"a"},["OnRemove"]=EventCallback.Factory.Create<string>(new object(),_=>{})},"Remove Alpha","Remove Beta","ng-chip-selected","disabled");
var enabledChip = await renderer.Dispatcher.InvokeAsync(async () => (await renderer.RenderComponentAsync<NgChip>(ParameterView.FromDictionary(new Dictionary<string,object?>{["Label"]="Tag",["Selectable"]=false,["OnRemove"]=EventCallback.Factory.Create(new object(),()=>{})}))).ToHtmlString());
Rule(!enabledChip.Contains("disabled="),"enabled chip removal is not disabled");
foreach(var sizeValue in new[]{"sm","md","lg"})foreach(var corners in new[]{"sm","md","lg","full"})foreach(var fillValue in new[]{"solid","outline"})foreach(var tone in new[]{"base","info","success","warning","error"}) NgChipRules.Validate(sizeValue,corners,fillValue,tone);
Rule(true,"all 120 chip appearance combinations accepted");
Reject(()=>NgChipRules.Validate("xl","full","solid","base"),"reject chip size");
Reject(()=>NgChipRules.Validate("md","invalid","solid","base"),"reject chip rounded");
Reject(()=>NgChipRules.Validate("md","full","invalid","base"),"reject chip fill");
Reject(()=>NgChipRules.Validate("md","full","solid","invalid"),"reject chip tone");
await Check<NgChip>(new(){["Label"]="Accessible label",["Size"]="lg",["Rounded"]="sm",["FillMode"]="solid",["ThemeColor"]="success",["ChildContent"]=Text("Custom content"),["Leading"]=Text("Icon"),["RemoveContent"]=Text("Remove symbol"),["OnRemove"]=EventCallback.Factory.Create(new object(),()=>{})},"ng-chip-lg","ng-chip-rounded-sm","ng-chip-solid","ng-chip-tone-success","aria-label=\"Accessible label\"","Custom content","Icon","Remove symbol");
var chipListHtml = await renderer.Dispatcher.InvokeAsync(async () => (await renderer.RenderComponentAsync<NgChipList>(ParameterView.FromDictionary(new Dictionary<string,object?>{["Items"]=options,["OnRemove"]=EventCallback.Factory.Create<string>(new object(),_=>{}),["CanRemove"]=(Func<NgOption,bool>)(item=>item.Value=="a"),["ItemAppearance"]=(Func<NgOption,NgChipAppearance>)(item=>new(ThemeColor:"warning"))}))).ToHtmlString());
Rule(chipListHtml.Contains("Remove Alpha")&&!chipListHtml.Contains("Remove Beta")&&chipListHtml.Contains("ng-chip-tone-warning"),"conditional removal and item appearance");
await Check<NgChip>(new(){["Label"]="Alpha",["RemoveLabel"]="Dismiss <Alpha>",["OnRemove"]=EventCallback.Factory.Create(new object(),()=>{})},"aria-label=\"Dismiss &lt;Alpha&gt;\"");
await Check<NgChipList>(new(){["Items"]=options,["RemoveLabel"]=(Func<NgOption,string>)(item=>$"Dismiss {item.Label}"),["OnRemove"]=EventCallback.Factory.Create<string>(new object(),_=>{})},"Dismiss Alpha","Dismiss Beta");
await Check<NgChipList>(new(){["Items"]=Array.Empty<NgOption>(),["EmptyText"]="No <topics> available"},"No &lt;topics&gt; available");
var largeChips=Enumerable.Range(1,500).Select(i=>new NgOption($"tag{i}",$"Topic {i}",i%10==0)).ToArray();
var largeValue=largeChips.Where(x=>!x.Disabled).Select(x=>x.Value).ToArray();
NgSelectionRules.Validate(largeChips,largeValue,true,maxItems:null);
Rule(NgSelectionRules.Toggle(largeChips,largeValue,"tag499",true,true,maxItems:null).Count==449,"large chip selection removes one ID");
Rule(NgSelectionRules.Toggle(largeChips,largeValue,"tag500",true,true,maxItems:null).SequenceEqual(largeValue),"large chip disabled selection unchanged");
Reject(()=>NgSelectionRules.Validate(largeChips,["missing"],true,maxItems:null),"large collection rejects unknown selection");
Reject(()=>NgSelectionRules.Validate([..largeChips,largeChips[0]],[],true,maxItems:null),"large collection rejects duplicate IDs");
await Check<NgChipList>(new(){["Items"]=largeChips,["Value"]=largeValue,["Multiple"]=true},"Topic 500","data-chip-id=\"tag499\"","ng-chip-selected");
var model = new ChipRecord { Id="ops", Name="Operations", Pinned=true };
var selectorCalls=0;
var chipData=new NgChipData<ChipRecord>([model],x=>{selectorCalls++;return x.Id;},x=>x.Name,removable:x=>!x.Pinned,appearance:x=>new(ThemeColor:"warning"));
Rule(ReferenceEquals(chipData.GetItem("ops"),model)&&selectorCalls==1,"chip adapter retains original record and evaluates selector once");
model.Name="Revised";
Rule(chipData.Items[0].Label=="Operations"&&!chipData.CanRemove(chipData.Items[0]),"chip adapter snapshots mapped fields");
Rule(new NgChipData<ChipRecord>([model],x=>x.Id,x=>x.Name).Items[0].Label=="Revised","chip adapter rebuild reads model changes");
Reject(()=>new NgChipData<ChipRecord>([model,model],x=>x.Id,x=>x.Name),"chip adapter rejects duplicate IDs");
Reject(()=>new NgChipData<ChipRecord>([model],x=>"bad id",x=>x.Name),"chip adapter rejects invalid ID");
Reject(()=>new NgChipData<ChipRecord>([model],x=>x.Id,x=>" "),"chip adapter rejects blank label");
Reject(()=>new NgChipData<ChipRecord>([model],x=>x.Id,x=>x.Name,appearance:x=>new(Size:"xxl")),"chip adapter rejects invalid appearance");
try{chipData.GetItem("missing");throw new Exception("unknown record accepted");}catch(KeyNotFoundException){Rule(true,"chip adapter rejects unknown lookup");}
await Check<NgChipList>(new(){["Items"]=chipData.Items,["CanRemove"]=(Func<NgOption,bool>)chipData.CanRemove,["ItemAppearance"]=(Func<NgOption,NgChipAppearance>)chipData.GetAppearance},"Operations","ng-chip-tone-warning");
await Check<NgChipList>(new(){["Items"]=options,["Id"]="business-topics",["Class"]="custom-list",["AriaLabelledBy"]="heading extra",["AriaDescribedBy"]="help"},"id=\"business-topics\"","ng-chip-list ng-chip-gap-md custom-list","aria-labelledby=\"heading extra\"","aria-describedby=\"help\"");
await Check<NgChip>(new(){["Label"]="Activity",["Id"]="activity-chip",["Class"]="custom-chip",["AriaLabelledBy"]="heading",["AriaDescribedBy"]="help",["OnClick"]=EventCallback.Factory.Create(new object(),()=>{})},"id=\"activity-chip\"","custom-chip ng-chip","aria-labelledby=\"heading\"","aria-describedby=\"help\"");
Reject(()=>NgChipRules.ValidateAccessibility("bad id",null,null),"chip DOM ID rejects whitespace");
Reject(()=>NgChipRules.ValidateAccessibility(null," ",null),"chip labelled-by rejects blank");
Reject(()=>NgChipRules.ValidateAccessibility(null,null," "),"chip described-by rejects blank");
await Check<NgChip>(new(){["Label"]="Published",["Selectable"]=false,["AriaDescribedBy"]="status-help"},"role=\"group\"","aria-describedby=\"status-help\"");
Rule(NgChipRules.GapPixels("sm")==4&&NgChipRules.GapPixels("md")==8&&NgChipRules.GapPixels("lg")==12,"chip spacing presets");
Reject(()=>NgChipRules.GapPixels("xl"),"chip gap rejects invalid preset");
Reject(()=>NgChipRules.ValidateTabIndex(1),"chip tab rejects positive index");
Reject(()=>NgChipRules.ValidateTabIndex(-2),"chip tab rejects other negative index");
await Check<NgChipList>(new(){["Items"]=options,["Gap"]="lg",["TabIndex"]=-1},"ng-chip-gap-lg","data-chip-tab-index=\"-1\"");
await Check<NgChip>(new(){["Label"]="Skipped",["TabIndex"]=-1,["OnClick"]=EventCallback.Factory.Create(new object(),()=>{})},"tabindex=\"-1\"");
var numericProbe=new NumericProbe();
Rule(numericProbe.Parse("2.5",out var numericValue)&&numericValue==2.5m,"numeric decimal accepted");
foreach(var bad in new[]{"11","-1","1e2","NaN","1,2"}) Rule(!numericProbe.Parse(bad,out _),"numeric rejects "+bad);
Rule(numericProbe.Parse("",out var emptyNumber)&&emptyNumber is null,"numeric optional empty");
var timeProbe=new TimeProbe();
Rule(!timeProbe.Parse("09:17")&&timeProbe.Parse("09:15"),"time minute interval validation");
var stampProbe=new StampProbe();
Rule(!stampProbe.Parse("2026-10-20 09:17")&&stampProbe.Parse("2026-10-20 09:15"),"datetime minute interval validation");
await Check<NgDateInput>(new(){["Value"]=date,["ValueExpression"]=(Expression<Func<DateOnly?>>)(()=>date),["ReadOnly"]=true},"readonly");
await Check<NgDatePicker>(new(){["Value"]=date,["ValueExpression"]=(Expression<Func<DateOnly?>>)(()=>date),["ReadOnly"]=true},"readonly","disabled");
var dateProbe = new DateProbe();
Rule(dateProbe.Parse("", out var emptyDate) && emptyDate is null,"date input clears optional value");
Rule(!dateProbe.Parse("2026-02-29",out _),"date input rejects invalid leap day");
Rule(dateProbe.Parse("2024-02-29",out _),"date input accepts leap day");
await Check<NgDropDownList>(new(){["Value"]="missing",["ValueExpression"]=(Expression<Func<string>>)(()=>team),["Items"]=options,["HelperText"]="Choose your team",["ReadOnly"]=true},"Unavailable selection: missing","Choose an available option.","Choose your team","disabled");
await Check<NgRadioGroup>(new(){["Value"]="a",["ValueExpression"]=(Expression<Func<string>>)(()=>team),["Items"]=options,["Orientation"]="vertical",["ItemTemplate"]=(RenderFragment<NgOption>)(o=>Text("Custom "+o.Label)),["ReadOnly"]=true},"flex-direction:column","Custom Alpha","aria-label=\"Alpha\"","disabled");
NgGaugeRange[] gaugeRanges=[new(60,100,"#b42318","High"),new(0,60,"#187444","Normal")];
var orderedRanges=NgGaugeRules.Validate(gaugeRanges,0,100);
Rule(orderedRanges[0].Label=="Normal"&&gaugeRanges[0].Label=="High","gauge sorts without mutating caller");
Rule(new[]{60d,100d,125d}.All(v=>NgGaugeRules.Active(orderedRanges,v,0,100)?.Label=="High"),"gauge adjacent and maximum boundaries");
Rule(NgGaugeRules.Active(orderedRanges,-10,0,100)?.Label=="Normal"&&NgGaugeRules.Active([gaugeRanges[0]],30,0,100)==null,"gauge clamps active range and permits gaps");
Rule(NgChartMath.Fraction(0,-1.7e308,1.7e308)==0.5,"gauge extreme finite span");
foreach(var bad in new NgGaugeRange[][]{[new(50,70,"#123456","Overlap"),..gaugeRanges],[new(-1,50,"#123456","Outside")],[new(10,10,"#123456","Empty")],[new(0,double.PositiveInfinity,"#123456","Infinite")],[new(0,50,"red","Color")],[new(0,50,"#123456\n","Trailing newline")],[new(0,50,"#123456"," ")]}) Reject(()=>NgGaugeRules.Validate(bad,0,100),"invalid gauge range");
await Check<NgLinearGauge>(new(){["Value"]=125d,["Ranges"]=gaugeRanges,["ValueFormatter"]=(Func<double,string>)(v=>v.ToString("F1",System.Globalization.CultureInfo.InvariantCulture))},"125.0 %","Above maximum","#b42318","aria-valuenow=\"100\"");
await Check<NgArcGauge>(new(){["Value"]=-10d,["Ranges"]=gaugeRanges},"-10 %","Below minimum","#187444","ng-gauge-legend");
await Check<NgLinearGauge>(new(){["Value"]=72.5},"72.5 %","aria-valuenow=\"72.5\"");
await Check<NgArcGauge>(new(){["Value"]=0d,["Min"]=-1.7e308,["Max"]=1.7e308},"aria-valuemax=\"1.7E&#x2B;308\"");
Rule(NgScheduleRules.WeekStart(new(2026,10,19),7)==new DateTime(2026,10,18),"Sunday schedule start");
Rule(NgScheduleRules.WeekStart(new(2026,10,19),3)==new DateTime(2026,10,14),"Wednesday schedule start");
Reject(()=>NgScheduleRules.WeekStart(new(2026,10,19),0),"invalid first weekday");
Rule(NgScheduleRules.CanDisplay(new(2,1,1),NgScheduleView.Day)&&!NgScheduleRules.CanDisplay(new(1,12,31),NgScheduleView.Day),"schedule lower boundary");
Rule(NgScheduleRules.CanDisplay(new(9998,12,31),NgScheduleView.Day)&&!NgScheduleRules.CanDisplay(new(9998,12,31),NgScheduleView.Week),"schedule full week upper boundary");
Rule(NgScheduleRules.Validate(new(" ","Title",new(2026,10,19),new(2026,10,20)))!=null,"schedule requires nonblank ID");
await Check<NgScheduler>(new(){["Date"]=new DateTime(2026,10,19),["View"]=NgScheduleView.Day,["EmptyText"]="No shifts"},"ng-schedule-single","Next day","No shifts","disabled");
await Check<NgScheduler>(new(){["Date"]=new DateTime(2026,10,19),["FirstDayOfWeek"]=7},"2026-10-18","2026-10-24");
await Check<NgScheduler>(new(){["Date"]=new DateTime(2026,10,19),["ReadOnly"]=true,["Items"]=new NgScheduleEvent[]{new("shift","Night",new(2026,10,18,23,0,0),new(2026,10,19,1,0,0))},["EventLabel"]=(Func<NgScheduleEvent,string>)(e=>"Shift: "+e.Title)},"Shift: Night","disabled");
var protectedSheet=new NgSheet(2,3,new Dictionary<string,string>{{"A1","2"},{"B1","locked"},{"C1","=A1*3"}});
Reject(()=>protectedSheet.Paste("A1","9\tlocked",a=>a!="B1"),"protected paste rejects unchanged protected target");
Rule(protectedSheet.Raw("A1")=="2","protected paste leaves source intact");
var editableSheet=protectedSheet.Paste("a1","9",a=>a=="A1");
Rule(editableSheet.Evaluate("C1").Number==27&&protectedSheet.ChangedCells(editableSheet).SequenceEqual(new[]{"A1"}),"protected formula recalculates without changing raw formula");
Reject(()=>protectedSheet.ChangedCells(new NgSheet()),"changed cells validates dimensions");
Rule(protectedSheet.ChangedCells(protectedSheet.Set("A1","2")).Count==0,"no-op changes excluded");
await Check<NgSpreadsheet>(new(){["Value"]=protectedSheet,["CanEdit"]=(Func<string,bool>)(a=>a!="A1"),["ValueChanged"]=EventCallback.Factory.Create<NgSheet>(new object(),(NgSheet _) => {})},"Protected","readonly","Paste cells");
await Check<NgSpreadsheet>(new(){["Value"]=protectedSheet},"readonly","disabled");
Reject(()=>NgPivotMath.Validate([new(" ",new Dictionary<string,string>(),1)]),"pivot rejects blank ID");
await Check<NgPivotGrid>(new(){["Items"]=pivot,["ShowRowTotals"]=false,["ShowColumnTotals"]=false,["ValueFormatter"]=(Func<double?,string>)(v=>v.HasValue?$"{v.Value:0} credits":"No value"),["RowLabel"]=(Func<string,string>)(v=>v==""?"Unassigned":"Team "+v),["ColumnLabel"]=(Func<string,string>)(v=>"Period "+v),["SelectionReadOnly"]=true},"Team A / Period Q1: 30 credits","Unassigned","disabled");
await Check<NgPivotGrid>(new(){["Items"]=pivot,["TotalText"]="All"},"All / All: 120");
await Check<NgPivotGrid>(new(){["EmptyText"]="No matching records"},"No matching records");
foreach(var (rowTotals,colTotals,expectedCells) in new[]{(true,true,12),(true,false,9),(false,true,8),(false,false,6)}){
 var pivotHtml=await renderer.Dispatcher.InvokeAsync(async ()=>(await renderer.RenderComponentAsync<NgPivotGrid>(ParameterView.FromDictionary(new Dictionary<string,object?>{{"Items",pivot},{"ShowRowTotals",rowTotals},{"ShowColumnTotals",colTotals}}))).ToHtmlString());
 Rule(System.Text.RegularExpressions.Regex.Matches(pivotHtml,"class=\"ng-pivot-cell\"").Count==expectedCells,$"pivot total shape {rowTotals}/{colTotals}");
}
Console.WriteLine($"{count} rendering and data/date-rule checks passed. Browser interaction requires the separate visual run.");
sealed class NoBrowserJS : IJSRuntime {
 public ValueTask<TValue> InvokeAsync<TValue>(string identifier, object?[]? args) => throw new InvalidOperationException("JS must not execute in SSR");
 public ValueTask<TValue> InvokeAsync<TValue>(string identifier, CancellationToken cancellationToken, object?[]? args) => InvokeAsync<TValue>(identifier,args);
}

sealed class TestNavigation : NavigationManager { public TestNavigation()=>Initialize("http://localhost/","http://localhost/"); protected override void NavigateToCore(string uri,bool forceLoad){} }

sealed class ChipRecord { public string Id {get;set;}=""; public string Name {get;set;}=""; public bool Pinned {get;set;} }

sealed class NumericProbe:NgNumericTextBox {
 public bool Parse(string text,out decimal? result){Min=0;Max=10;return TryParseValueFromString(text,out result,out _);}
}
sealed class TimeProbe:NgTimePicker {
 public bool Parse(string text){MinuteStep=15;return TryParseValueFromString(text,out _,out _);}
}
sealed class StampProbe:NgDateTimePicker {
 public bool Parse(string text){MinuteStep=15;return TryParseValueFromString(text,out _,out _);}
}

sealed class DateProbe:NgDateInput {
 public bool Parse(string text,out DateOnly? value) => TryParseValueFromString(text,out value,out _);
}

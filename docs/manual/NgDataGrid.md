# NgDataGrid — Data grid

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Page, search and sort local or remote records.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgDataGrid) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgDataGrid)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

ReadData/readData enables asynchronous page loading; Items/items is used only in local mode. The request contains 1-based Page/page, PageSize/pageSize, Search/search and an ordered immutable Sorts/sorts list. Return only the requested page and Total/total after filtering, before paging. The demo simulates a remote data adapter with a delay; replace its body with your HTTP/database call. A newer request or source replacement invalidates older results and errors; Blazor also passes a cancellation token. Flutter ignores stale futures but does not abort the transport. Loading hides old rows and blocks selection. Failure shows ErrorText/errorText and RetryText/retryText without exposing exception details. Change DataVersion/dataVersion to reload page 1; keep reader identity stable. Blazor ReloadAsync reloads the current page. A shrinking total clamps the page and fetches it again. Invalid totals, duplicate IDs and oversized pages become retryable errors. MultiSort/multiSort appends clicked columns by priority; clicking again toggles direction without moving priority. Clear sorting restores source order. Local sorting is stable. Row/column IDs must be unique and nonblank. Selection remains parent-owned and page selection preserves hidden/protected IDs. CanSelect/canSelect and SelectionReadOnly/selectionReadOnly still apply. Grouped remote scrolling uses ReadGroupedRange/readGroupedRange; batch/cell editing remains open. Remote grouping, single-record editing and CSV/TSV export use the explicit adapters below. See [data workspace](../data-workspace.md).

### Local grouping and paging

GroupBy/groupBy enables one local grouping level over string keys; empty strings are a valid group and keys are case-sensitive. Search and sort run first, then groups gather matching records in first-appearance order while preserving sorted order within each group, then the flattened grouped rows are paged. Headers do not consume page slots. A group crossing a page boundary repeats its header; the count is the complete filtered group count, not only the current page. GroupText/groupText formats the key and count as plain text. Selection/page selection covers data rows only and retains off-page IDs. Enabling/disabling grouping resets to page 1; changing a grouping rule in-place requires DataVersion/dataVersion to reset paging. Selectors must be pure. GroupBy/groupBy cannot be combined with ReadData/readData: use ReadGroupedData/readGroupedData for the group-aware server protocol, never approximate a full group from one server page. Grouped remote scrolling uses ReadGroupedRange/readGroupedRange; remote grouping, editing and export use the separate contracts below.

### Nested groups

GroupSelectors/groupSelectors accepts up to eight ordered string selectors for nested groups; use it instead of GroupBy/groupBy, never together. Each level keeps first-appearance order. Change DataVersion/dataVersion when changing the level order or rule; the demo uses its grouping switches as the version.

### Controlled expansion

CollapsibleGroups/collapsibleGroups opts into controlled expansion. CollapsedGroups/collapsedGroups stores full-path IDs from NgDataOperations.GroupId(path) / ngGroupId(path), not raw keys. IDs use length-prefixed UTF-16 segments, so repeated labels, empty keys and separator characters do not collide. Store the fresh set from CollapsedGroupsChanged/onCollapsedGroupsChanged to accept a request, or ignore it to reject. Hidden and unknown IDs survive updates. GroupExpansionReadOnly/groupExpansionReadOnly and missing callbacks disable controls; external collapsed state is still displayed. Turning collapsibility off ignores, but does not erase, stored state. GroupToggleLabel/groupToggleLabel receives the path and current expanded state; ExpandGroupsText/expandGroupsText and CollapseGroupsText/collapseGroupsText localize actions.

### Bulk actions and selection

Bulk actions affect every currently filtered group, including off-page descendants; filtered-out/unknown IDs are retained. Collapse is a view operation after paging: record ranges, page counts and full group counts stay unchanged, and each visited page repeats the necessary ancestor headers. Fully collapsed pages show headers only, not an empty-result message. Page selection includes only eligible rendered data rows; existing hidden selections are preserved.

### Group summaries

GroupAggregates/groupAggregates supplies NgGroupAggregate descriptors: title, numeric value selector, operation (sum, average, min, max, count) and optional format callback. Aggregates use all filtered records at each level, independently of paging and collapse; parent averages are record-weighted. Null/NaN/infinite values are ignored; count counts finite numeric values, while the header count counts records. Empty sum/count are zero, empty average/min/max are missing (displayed as an em dash). Results use double precision, not financial decimal arithmetic. Invalid operations fail validation. Headers and aggregate formatting are plain text; callbacks must be pure. The grid uses native keyboard buttons for toggling; no screen-reader certification or native-target parity is claimed.

### HTTP grouped data

ReadGroupedData/readGroupedData uses NgGroupedDataRequest (page, pageSize, search, sorts, groupKeys) and NgGroupedDataResult<T> (items with full paths, filtered total and full-count/summary metadata for the page groups). RemoteGroupKeys/remoteGroupKeys contains one to eight distinct field identifiers. Changing keys resets paging and invalidates pending work. Local selectors/aggregates and ordinary ReadData cannot be combined with this mode. Counts and summaries come from the server; malformed envelopes fail atomically into ErrorText and Retry. Collapse is local and retains record paging. Bulk actions explicitly affect page groups only; off-page state is preserved. RemoteSummaryText/remoteSummaryText formats numeric server summaries as plain text. The HTTP example calls the read-only Blazor gallery fixture endpoint from both platforms; keep port 5180 running for Flutter. Put the extra Dart imports at file scope (the transport is Web-specific); the remaining snippet belongs in a State class. No database provider is bundled. See [Remote grouped data](remote-grouped-data.md) for JSON schemas, validation rules, cancellation, adapter helpers and failure/shrink exercises.


### Create, edit and delete

Editing/editing accepts NgGridEditing<T>: text-field descriptors, a draft factory, validation, asynchronous persistence and per-record permissions. The editable inventory demonstrates required and integer validation, duplicate-name server errors, protected records, delayed saves, generic failures, retry and cancellation. See [Grid editing](grid-editing.md) for lifecycle, remote refresh, concurrency and application responsibilities.


### CSV and TSV export

Export/export accepts NgGridExport<T> with an output callback, ordered column keys, optional plain-text formatting, delimiter, headers, BOM and limits. Page exports rendered rows; Filtered exports the complete query; Selected intersects the query with caller-owned selected IDs. Full remote export requires ReadExportData/readExportData; ordinary page reads are never silently treated as complete datasets. See [Grid export](grid-export.md) for exact scope, escaping, formula protection, adapter, cancellation and browser-download contracts.


### Virtual scrolling

Virtualize/virtualize enables fixed-height windowed rendering. RowHeight/rowHeight defaults to 48; ViewportHeight/viewportHeight defaults to 384. Local Grid covers the filtered result; remote Grid retains its current-page adapter and pager; trees virtualize expanded loaded nodes. See [Virtual data](virtual-data.md) for complete selection, export, focus, layout and performance contracts and 10,000-record runnable demos. Continuous remote loading uses ReadRange/readRange; see Remote ranges.


### Continuous remote ranges

ReadRange/readRange with Virtualize/virtualize scrolls a flat server result while retaining one bounded window. Requests carry a zero-based startIndex, count, search and ordered sorts; responses echo startIndex, supply exactly the requested records within total, and provide total (0–100,000). Stable unique row IDs and deterministic server ordering are required. Page selection/export are labelled Loaded window and include overscan. Full remote export still requires its own adapter. See [Remote ranges](remote-ranges.md) for executable examples, JSON, error/retry, cancellation, limits and server consistency rules.


### Grouped remote ranges

ReadGroupedRange/readGroupedRange uses a separate server contract that counts visible group headers and records after accepted collapse. It retains one bounded window, validates ancestor metadata, rejects obsolete responses and preserves caller-owned selection. Loaded-window selection/export excludes headers. See [Grouped remote ranges](grouped-remote-ranges.md) for paired executable examples, HTTP contracts, limits, collapse and failure/retry behavior.


### Cell and custom editors
Enable CellEditing/cellEditing for field keys matching column keys. Activate the labelled Edit button in a cell, change its draft, then Save or Cancel below the table. The editable inventory supplies a custom numeric quantity input through EditorTemplate/editorBuilder. Saving validates the full record. See [Grid editing](grid-editing.md#cell-editing-and-custom-editors).

## Blazor example

```razor
@using System.Net.Http.Json
@inject System.Net.Http.IHttpClientFactory HttpFactory
@inject NavigationManager Navigation
<h3>Grid export</h3>
<p>Prepare a CSV or TSV file, inspect its row count, then download. Local export respects the current query; remote full export uses a separate bounded adapter.</p>
<NgCheckBox Label="Export quantity column" @bind-Value="exportQuantity"/>
<NgCheckBox Label="Use tab-separated format" @bind-Value="exportTsv"/>
<NgCheckBox Label="Fail exports" @bind-Value="exportFail"/>
<NgCheckBox Label="Lock export" @bind-Value="exportLocked"/>
@if(lastExport is {} file){<p>Last export: @file.RowCount rows · @string.Join(", ",file.ColumnKeys)</p><a class="ng-button" href="@($"data:{file.MimeType};base64,{Convert.ToBase64String(file.Bytes)}")" download="@file.FileName">Download last export</a><pre>@file.Content[..Math.Min(file.Content.Length,1200)]</pre>}
<h3>Local grouped inventory</h3>
<NgCheckBox Label="Group by product" @bind-Value="grouped"/>
<NgCheckBox Label="Also group by availability" @bind-Value="nested"/>
<NgCheckBox Label="Show group totals" @bind-Value="totals"/>
<NgCheckBox Label="Lock group expansion" @bind-Value="groupLocked"/>
<NgDataGrid TItem="Product" Label="Grouped inventory" Export="LocalExport" Items="rows" Columns="columns" RowId="r=>r.Id" GroupSelectors="Grouping" DataVersion="@($"{grouped}/{nested}")" CollapsibleGroups="true" @bind-CollapsedGroups="collapsed" GroupExpansionReadOnly="groupLocked" GroupAggregates="@(totals?aggregates:[])" GroupText="GroupCaption" MultiSort="true" @bind-SelectedIds="localSelected" CanSelect="r=>r.Count<100"/>
<p>Local selection: @string.Join(", ",localSelected.Order())</p>
<h3>Editable inventory</h3>
<p>Drafts are isolated. Quantities 100 and above are protected. Try a blank name, invalid quantity, a save failure and a retry.</p>
<NgCheckBox Label="Lock editing" @bind-Value="editLocked"/>
<NgCheckBox Label="Fail saves" @bind-Value="editFail"/>
<NgDataGrid TItem="Product" Label="Editable inventory" Items="editableRows" Columns="@(new NgDataColumn<Product>[]{new("name","Name",r=>r.Name),new("quantity","Quantity",r=>r.Count)})" RowId="r=>r.Id" Editing="Editor" GroupBy="r=>r.Name" Selectable="false"/>
<p>Successful writes: @writes</p>
<h3>HTTP grouped inventory</h3>
<p>Live requests to the local gallery API. Counts and summaries are computed before server paging.</p>
<NgCheckBox Label="Remote nested groups" @bind-Value="remoteNested"/>
<NgCheckBox Label="Fail grouped requests" @bind-Value="groupFail"/>
<NgCheckBox Label="Malformed grouped response" @bind-Value="groupMalformed"/>
<NgCheckBox Label="Small remote dataset" @bind-Value="groupSmall"/>
<NgButton OnClick="()=>groupVersion++">Reload grouped source</NgButton>
<NgDataGrid TItem="Product" Label="HTTP grouped inventory" ReadGroupedData="ReadGrouped" RemoteGroupKeys="@(remoteNested?new[]{"name","availability"}:new[]{"name"})" DataVersion="groupVersion" MultiSort="true" Columns="columns" RowId="r=>r.Id" CollapsibleGroups="true" @bind-CollapsedGroups="remoteCollapsed" @bind-SelectedIds="remoteSelected" CanSelect="r=>r.Count<100"/>
<p>Grouped requests: @groupRequests · @groupQuery</p>
<h3>Remote paging adapter</h3>
<NgCheckBox Label="Fail requests" @bind-Value="fail"/>
<NgButton OnClick="()=>version++">Reload source</NgButton>
<NgDataGrid TItem="Product" ReadData="Read" Export="RemoteExport" DataVersion="version" MultiSort="true" Columns="columns" RowId="r=>r.Id" @bind-SelectedIds="selected" CanSelect="r=>r.Count<100" PageSizes="new[]{5,10,20}"/>
<p>Requests: @requests · Latest query: @query</p>
@code {
 private bool exportQuantity=true,exportTsv,exportFail,exportLocked;private NgGridExportFile? lastExport;
 private NgGridExport<Product> LocalExport=>new(){OnExport=ReceiveExport,ColumnKeys=exportQuantity?["name","count"]:["name"],FileName=exportTsv?"inventory.tsv":"inventory.csv",Delimiter=exportTsv?"\t":",",ReadOnly=exportLocked,ScopeText="Local export scope",Format=(key,r)=>key=="count"?r.Count.ToString(System.Globalization.CultureInfo.InvariantCulture):r.Name};
 private NgGridExport<Product> RemoteExport=>LocalExport with {ReadExportData=ReadExport,ScopeText="Remote export scope"};
 private async Task ReceiveExport(NgGridExportFile file,CancellationToken token){token.ThrowIfCancellationRequested();if(exportFail)throw new InvalidOperationException("Private delivery detail");lastExport=file;await InvokeAsync(StateHasChanged);}
 private async Task<IReadOnlyList<Product>> ReadExport(NgGridExportRequest request,CancellationToken token){
   await Task.Delay(600,token);if(exportFail)throw new InvalidOperationException("Private adapter detail");
   var result=NgDataOperations.Query(rows,columns,request.Search,request.Sorts);
   if(request.Scope==NgGridExportScope.Selected)result=result.Where(r=>request.SelectedIds.Contains(r.Id)).ToArray();
   if(result.Count>request.MaxRows)throw new InvalidOperationException("Too many records");return result;
 }
 public record Product(string Id,string Name,int Count);
 private bool grouped=true,nested=true,totals=true,groupLocked;
 private HashSet<string> collapsed=[];
 private IReadOnlyList<Func<Product,string>> Grouping=>!grouped?[]:nested?[ProductGroup,r=>r.Count<100?"Available":"Protected"]:[ProductGroup];
 private static readonly NgGroupAggregate<Product>[] aggregates=[new("Total quantity",r=>r.Count),new("Average",r=>r.Count,"average",v=>v?.ToString("0.0")??"—")]; private HashSet<string> localSelected=[]; private string ProductGroup(Product row)=>row.Name; private string GroupCaption(string key,int count)=>$"{key}: {count} matching records";
 private List<Product> editableRows=[new("e1","Chair",12),new("e2","Desk",24),new("e3","Protected",100)];
 private bool editLocked,editFail;private int writes,nextEditId=4;
 private NgGridEditing<Product> Editor=>new(){
   CellEditing=true,EditorTemplate=ProductEditor,
   Fields=[new("name","Product name",true),new("quantity","Product quantity",true)],
   Draft=r=>new Dictionary<string,string>{{"name",r?.Name??""},{"quantity",r?.Count.ToString()??"0"}},
   ReadOnly=editLocked,CanUpdate=r=>r.Count<100,CanDelete=r=>r.Count<100,
   Validate=v=>!int.TryParse(v["quantity"],out var n)||n<0?"Quantity must be a nonnegative integer.":null,
   Commit=SaveProduct
 };
 private RenderFragment<NgGridEditorContext> ProductEditor=>ctx=>@<label class="ng-field">@ctx.Field.Label<input class="ng-input" type="@(ctx.Field.Key=="quantity"?"number":"text")" min="0" aria-label="@ctx.Field.Label" aria-required="true" value="@ctx.Value" disabled="@ctx.Disabled" @oninput="e=>ctx.SetValue(e.Value?.ToString()??string.Empty)" /></label>;
 private async Task<string?> SaveProduct(NgGridEditOperation operation,string? id,IReadOnlyDictionary<string,string> values,CancellationToken token){
   await Task.Delay(600,token);
   if(editFail)throw new InvalidOperationException("Private storage detail");
   if(editLocked)return "Editing is locked.";
   var existing=editableRows.FirstOrDefault(r=>r.Id==id);
   if(operation!=NgGridEditOperation.Create && (existing is null || existing.Count>=100))return "Record is missing or protected.";
   if(operation==NgGridEditOperation.Delete)editableRows.RemoveAll(r=>r.Id==id);
   else{
     var name=values["name"].Trim();var quantity=int.Parse(values["quantity"]);
     if(editableRows.Any(r=>r.Id!=id && string.Equals(r.Name,name,StringComparison.OrdinalIgnoreCase)))return "Product name already exists.";
     var next=new Product(id??$"e{nextEditId++}",name,quantity);
     if(operation==NgGridEditOperation.Create)editableRows.Add(next);else editableRows[editableRows.FindIndex(r=>r.Id==id)]=next;
   }
   writes++;await InvokeAsync(StateHasChanged);return null;
 }
 private bool remoteNested=true,groupFail,groupMalformed,groupSmall;private int groupVersion,groupRequests;private string groupQuery="";
 private HashSet<string> remoteCollapsed=[],remoteSelected=[];
 private async Task<NgGroupedDataResult<Product>> ReadGrouped(NgGroupedDataRequest request,CancellationToken token){
   groupRequests++;groupQuery=$"HTTP page {request.Page} / {string.Join(" > ",request.GroupKeys)} / {request.Search}";
   try{
     using var client=HttpFactory.CreateClient();
     var url=new Uri(new Uri(Navigation.BaseUri),$"api/grouped-inventory?fail={groupFail.ToString().ToLowerInvariant()}&malformed={groupMalformed.ToString().ToLowerInvariant()}&small={groupSmall.ToString().ToLowerInvariant()}");
     using var response=await client.PostAsJsonAsync(url,request,token);response.EnsureSuccessStatusCode();
     return await response.Content.ReadFromJsonAsync<NgGroupedDataResult<Product>>(cancellationToken:token)??throw new InvalidOperationException("Empty response");
   }finally{if(!token.IsCancellationRequested)await InvokeAsync(StateHasChanged);}
 }
 private bool fail; private int version,requests; private string query="";
 private HashSet<string> selected=[];
 private static readonly Product[] rows=Enumerable.Range(1,40).Select(i=>new Product($"p{i}",i%2==0?"Desk":"Chair",i*4)).ToArray();
 private static readonly NgDataColumn<Product>[] columns=[new("name","Name",r=>r.Name),new("count","Quantity",r=>r.Count)];
 private async Task<NgDataResult<Product>> Read(NgDataRequest request,CancellationToken token){
   requests++;query=$"{request.Search} / page {request.Page} / {request.Sorts.Count} sorts";
   await Task.Delay(350,token);await InvokeAsync(StateHasChanged);
   if(fail)throw new InvalidOperationException("Demo failure");
   var result=NgDataOperations.Query(rows,columns,request.Search,request.Sorts);
   return new(result.Skip((request.Page-1)*request.PageSize).Take(request.PageSize).ToArray(),result.Count);
 }
}
```

## Flutter example

```dart
import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

bool exportQuantity=true,exportTsv=false,exportFail=false,exportLocked=false;
NgGridExportFile? lastExport;
NgGridExport<({String id,String name,int count})> exportConfig(bool remote)=>NgGridExport(
  onExport:receiveExport,readExportData:remote?readExport:null,columnKeys:exportQuantity?['name','count']:['name'],
  fileName:exportTsv?'inventory.tsv':'inventory.csv',delimiter:exportTsv?'\t':',',readOnly:exportLocked,
  scopeText:remote?'Remote export scope':'Local export scope',format:(key,r)=>key=='count'?'${r.count}':r.name);
Future<void> receiveExport(NgGridExportFile file)async{
  if(exportFail)throw StateError('Private delivery detail');if(mounted)setState(()=>lastExport=file);
}
Future<List<({String id,String name,int count})>> readExport(NgGridExportRequest request)async{
  await Future<void>.delayed(const Duration(milliseconds:600));if(exportFail)throw StateError('Private adapter detail');
  var result=NgDataOperations.queryMany(rows,columns,request.search,request.sorts);
  if(request.scope==NgGridExportScope.selected)result=result.where((r)=>request.selectedIds.contains(r.id)).toList();
  if(result.length>request.maxRows)throw StateError('Too many records');return result;
}
void downloadExport(NgGridExportFile file){
  final anchor=web.HTMLAnchorElement()..href='data:${file.mimeType};base64,${base64Encode(file.bytes)}'..download=file.fileName;
  anchor.click();
}
final editableRows=<( {String id,String name,int count})>[(id:'e1',name:'Chair',count:12),(id:'e2',name:'Desk',count:24),(id:'e3',name:'Protected',count:100)];
bool editLocked=false,editFail=false;
int writes=0,nextEditId=4;
NgGridEditing<({String id,String name,int count})> get editor=>NgGridEditing(
  cellEditing:true,editorBuilder:(context,editor)=>TextFormField(key:ValueKey((editor.field.key,editor.disabled)),initialValue:editor.value,enabled:!editor.disabled,keyboardType:editor.field.key=='quantity'?TextInputType.number:TextInputType.text,decoration:InputDecoration(labelText:editor.field.label),onChanged:editor.setValue),
  fields:[NgGridEditField('name','Product name',required:true),NgGridEditField('quantity','Product quantity',required:true)],
  draft:(r)=>{'name':r?.name??'','quantity':'${r?.count??0}'},readOnly:editLocked,canUpdate:(r)=>r.count<100,canDelete:(r)=>r.count<100,
  validate:(v)=>int.tryParse(v['quantity']??'')==null || int.parse(v['quantity']!)<0?'Quantity must be a nonnegative integer.':null,
  commit:saveProduct);
Future<String?> saveProduct(NgGridEditOperation operation,String? id,Map<String,String> values)async{
  await Future<void>.delayed(const Duration(milliseconds:600));
  if(!mounted)return 'Editor closed.';
  if(editFail)throw StateError('Private storage detail');
  if(editLocked)return 'Editing is locked.';
  final index=editableRows.indexWhere((r)=>r.id==id);
  if(operation!=NgGridEditOperation.create && (index<0 || editableRows[index].count>=100))return 'Record is missing or protected.';
  if(operation==NgGridEditOperation.delete){setState(()=>editableRows.removeAt(index));}
  else{
    final name=values['name']!.trim(),quantity=int.parse(values['quantity']!);
    if(editableRows.any((r)=>r.id!=id && r.name.toLowerCase()==name.toLowerCase()))return 'Product name already exists.';
    final next=(id:id??'e${nextEditId++}',name:name,count:quantity);
    setState((){if(operation==NgGridEditOperation.create){editableRows.add(next);}else{editableRows[index]=next;}});
  }
  setState(()=>writes++);return null;
}
bool remoteNested=true,groupFail=false,groupMalformed=false,groupSmall=false;
int groupVersion=0,groupRequests=0;
String groupQuery='';
Set<String> remoteCollapsed={},remoteSelected={};
Future<NgGroupedDataResult<({String id,String name,int count})>> readGrouped(NgGroupedDataRequest request)async{
  groupRequests++;groupQuery='HTTP page ${request.page} / ${request.groupKeys.join(" > ")} / ${request.search}';
  try{
    final url='http://127.0.0.1:5180/api/grouped-inventory?fail=$groupFail&malformed=$groupMalformed&small=$groupSmall';
    final response=await web.window.fetch(url.toJS,web.RequestInit(method:'POST',headers:{'Content-Type':'application/json'}.jsify()! as JSObject,body:jsonEncode(request.toJson()).toJS)).toDart;
    if(!response.ok)throw StateError('Grouped request failed');
    final json=jsonDecode((await response.text().toDart).toDart) as Map<String,dynamic>;
    return NgGroupedDataResult.fromJson(json,(row)=>(id:row['id'] as String,name:row['name'] as String,count:row['count'] as int));
  }finally{if(mounted)setState((){});}
}
final rows = List.generate(40, (i) => (id: 'p${i+1}', name: i.isOdd ? 'Desk' : 'Chair', count: (i+1)*4));
final columns = <NgDataColumn<({String id, String name, int count})>>[
  NgDataColumn('name', 'Name', (r) => r.name), NgDataColumn('count', 'Quantity', (r) => r.count)];
Set<String> localSelected = {}; bool grouped=true,nested=true,totals=true,groupLocked=false;
Set<String> collapsed={};
final aggregates=<NgGroupAggregate<({String id,String name,int count})>>[NgGroupAggregate('Total quantity',(r)=>r.count.toDouble()),NgGroupAggregate('Average',(r)=>r.count.toDouble(),operation:'average',format:(v)=>v?.toStringAsFixed(1)??'—')];
Set<String> selected = {};
bool fail = false;
int version = 0, requests = 0;
String query = '';
Future<NgDataResult<({String id, String name, int count})>> read(NgDataRequest request) async {
  requests++; query = '${request.search} / page ${request.page} / ${request.sorts.length} sorts';
  await Future<void>.delayed(const Duration(milliseconds: 350)); if (mounted) setState(() {});
  if (fail) throw StateError('Demo failure');
  final result = NgDataOperations.queryMany(rows, columns, request.search, request.sorts);
  return NgDataResult(result.skip((request.page-1)*request.pageSize).take(request.pageSize).toList(), result.length);
}
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  const Text('Grid export'),
  const Text('Prepare CSV or TSV, inspect the result, then download. Remote full export uses a separate bounded adapter.'),
  NgCheckBox(label:'Export quantity column',value:exportQuantity,onChanged:(v)=>setState(()=>exportQuantity=v)),
  NgCheckBox(label:'Use tab-separated format',value:exportTsv,onChanged:(v)=>setState(()=>exportTsv=v)),
  NgCheckBox(label:'Fail exports',value:exportFail,onChanged:(v)=>setState(()=>exportFail=v)),
  NgCheckBox(label:'Lock export',value:exportLocked,onChanged:(v)=>setState(()=>exportLocked=v)),
  if(lastExport case final file?)...[Text('Last export: ${file.rowCount} rows · ${file.columnKeys.join(", ")}'),NgButton(onPressed:()=>downloadExport(file),child:const Text('Download last export')),SelectableText(file.content.substring(0,file.content.length>1200?1200:file.content.length))],
  const Text('Local grouped inventory'),
  NgCheckBox(label:'Group by product',value:grouped,onChanged:(v)=>setState(()=>grouped=v)),
  NgCheckBox(label:'Also group by availability',value:nested,onChanged:(v)=>setState(()=>nested=v)),
  NgCheckBox(label:'Show group totals',value:totals,onChanged:(v)=>setState(()=>totals=v)),
  NgCheckBox(label:'Lock group expansion',value:groupLocked,onChanged:(v)=>setState(()=>groupLocked=v)),
  NgDataGrid<({String id,String name,int count})>(label:'Grouped inventory',export:exportConfig(false),items:rows,columns:columns,rowId:(r)=>r.id,groupSelectors:!grouped?[]:nested?[(r)=>r.name,(r)=>r.count<100?'Available':'Protected']:[(r)=>r.name],dataVersion:'$grouped/$nested',collapsibleGroups:true,collapsedGroups:collapsed,onCollapsedGroupsChanged:(v)=>setState(()=>collapsed=v),groupExpansionReadOnly:groupLocked,groupAggregates:totals?aggregates:[],groupText:(key,count)=>'$key: $count matching records',multiSort:true,selectedIds:localSelected,onSelectionChanged:(v)=>setState(()=>localSelected=v),canSelect:(r)=>r.count<100),
  Text('Local selection: ${(localSelected.toList()..sort()).join(", ")}'),
  const Text('Editable inventory'),
  const Text('Drafts are isolated. Quantities 100 and above are protected. Try validation, failure and retry.'),
  NgCheckBox(label:'Lock editing',value:editLocked,onChanged:(v)=>setState(()=>editLocked=v)),
  NgCheckBox(label:'Fail saves',value:editFail,onChanged:(v)=>setState(()=>editFail=v)),
  NgDataGrid<({String id,String name,int count})>(label:'Editable inventory',items:editableRows,columns:[NgDataColumn('name','Name',(r)=>r.name),NgDataColumn('quantity','Quantity',(r)=>r.count)],rowId:(r)=>r.id,groupBy:(r)=>r.name,editing:editor),
  Text('Successful writes: $writes'),
  const Text('HTTP grouped inventory'),
  const Text('Live requests to the local gallery API. Start the Blazor gallery on port 5180.'),
  NgCheckBox(label:'Remote nested groups',value:remoteNested,onChanged:(v)=>setState(()=>remoteNested=v)),
  NgCheckBox(label:'Fail grouped requests',value:groupFail,onChanged:(v)=>setState(()=>groupFail=v)),
  NgCheckBox(label:'Malformed grouped response',value:groupMalformed,onChanged:(v)=>setState(()=>groupMalformed=v)),
  NgCheckBox(label:'Small remote dataset',value:groupSmall,onChanged:(v)=>setState(()=>groupSmall=v)),
  NgButton(onPressed:()=>setState(()=>groupVersion++),child:const Text('Reload grouped source')),
  NgDataGrid<({String id,String name,int count})>(label:'HTTP grouped inventory',readGroupedData:readGrouped,remoteGroupKeys:remoteNested?['name','availability']:['name'],dataVersion:groupVersion,multiSort:true,columns:columns,rowId:(r)=>r.id,collapsibleGroups:true,collapsedGroups:remoteCollapsed,onCollapsedGroupsChanged:(v)=>setState(()=>remoteCollapsed=v),selectedIds:remoteSelected,onSelectionChanged:(v)=>setState(()=>remoteSelected=v),canSelect:(r)=>r.count<100),
  Text('Grouped requests: $groupRequests · $groupQuery'),
  const Text('Remote paging adapter'),
  NgCheckBox(label: 'Fail requests', value: fail, onChanged: (v) => setState(() => fail = v)),
  NgButton(onPressed: () => setState(() => version++), child: const Text('Reload source')),
  NgDataGrid<({String id, String name, int count})>(readData: read, export:exportConfig(true), dataVersion: version, multiSort: true,
    columns: columns, rowId: (r) => r.id, selectedIds: selected, canSelect: (r) => r.count < 100,
    pageSizes: const [5,10,20], onSelectionChanged: (v) => setState(() => selected = v)),
  Text('Requests: $requests · Latest query: $query'),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Virtualize` | `bool` | false | Opt-in fixed-height virtual rendering. Local Grid covers the result; remote Grid retains pages; trees cover loaded expanded nodes. See Virtual data. |
| `RowHeight` | `float` | 48 | Fixed virtual row height, default 48 pixels; finite and at least 40. Templates must fit. |
| `ViewportHeight` | `float` | 384 | Virtual scroll viewport height, default 384 pixels; finite and at least one row. |
| `Export` | `NgGridExport<TItem>?` | not set | Optional NgGridExport configuration: query/selection scope, ordered columns, text formatting, bounded CSV/TSV delivery and a full-data remote adapter. See Grid export. |
| `Editing` | `NgGridEditing<TItem>?` | not set | Optional NgGridEditing configuration for isolated drafts, validation, async persistence and confirmed deletion. See Grid editing. |
| `ReadData` | `Func<NgDataRequest,CancellationToken,Task<NgDataResult<TItem>>>?` | not set | Async page adapter; return requested rows and filtered total. See request/result contracts above. |
| `ReadGroupedData` | `Func<NgGroupedDataRequest,CancellationToken,Task<NgGroupedDataResult<TItem>>>?` | not set | Async grouped page adapter; mutually exclusive with ReadData and local grouping/aggregates. |
| `RemoteGroupKeys` | `IReadOnlyList<string>` | [] | Ordered application-defined field identifiers, one to eight distinct nonblank keys. Changes reload page 1. |
| `RemoteSummaryText` | `Func<string,double?,string>?` | not set | Plain-text server summary formatter receiving title and nullable numeric value. |
| `ExpandPageGroupsText` | `string` | "Expand page groups" | Localized remote bulk-expand label; affects current page groups only. |
| `CollapsePageGroupsText` | `string` | "Collapse page groups" | Localized remote bulk-collapse label; affects current page groups only. |
| `GroupBy` | `Func<TItem,string>?` | not set | Pure local string-key selector; grouping precedes paging and cannot be combined with ReadData. |
| `GroupText` | `Func<string,int,string>?` | not set | Plain-text caption from the group key and complete filtered group count. |
| `GroupSelectors` | `IReadOnlyList<Func<TItem,string>>` | [] | Ordered local string selectors, up to eight levels. Mutually exclusive with GroupBy. |
| `GroupAggregates` | `IReadOnlyList<NgGroupAggregate<TItem>>` | [] | Numeric aggregate descriptors over all filtered records in each group. |
| `CollapsibleGroups` | `bool` | false | Enable controlled group expansion and bulk actions. Default false. |
| `CollapsedGroups` | `HashSet<string>` | [] | Parent-owned set of encoded full group path IDs; use GroupId/ngGroupId. |
| `CollapsedGroupsChanged` | `EventCallback<HashSet<string>>` | not set | Propose one fresh collapsed-ID set; accept by storing it. |
| `GroupExpansionReadOnly` | `bool` | false | Lock group expansion independently of row selection. |
| `GroupToggleLabel` | `Func<IReadOnlyList<string>,bool,string>?` | not set | Localized accessible toggle name from path and current expanded state. |
| `ExpandGroupsText` | `string` | "Expand all groups" | Localized expand-all action label. |
| `CollapseGroupsText` | `string` | "Collapse all groups" | Localized collapse-all action label. |
| `DataVersion` | `object?` | not set | Change to invalidate pending reads and cached data; keep stable otherwise. |
| `MultiSort` | `bool` | false | Append sorted columns in priority order; default false. |
| `LoadingText` | `string` | "Loading records…" | Localized loading status. |
| `ErrorText` | `string` | "Unable to load records." | Localized failure status; raw service errors are not rendered. |
| `RetryText` | `string` | "Retry" | Localized retry action text. |
| `Items` | `IReadOnlyList<TItem>` | [] | Input collection. Replace it when changing records or configuration. |
| `Columns` | `IReadOnlyList<NgDataColumn<TItem>>` | required | Column definitions; see the data model and example. |
| `RowId` | `Func<TItem,string>` | required | See the behavior rules and model contract above. |
| `Label` | `string` | "Records" | Visible label or accessible name. |
| `EmptyText` | `string` | "No matching records." | See the behavior rules and model contract above. |
| `CanSelect` | `Func<TItem,bool>?` | not set | See the behavior rules and model contract above. |
| `SelectionReadOnly` | `bool` | false | See the behavior rules and model contract above. |
| `EmptyTemplate` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `PageSizes` | `IReadOnlyList<int>` | [5,10,25,50] | See the behavior rules and model contract above. |
| `Selectable` | `bool` | true | See the behavior rules and model contract above. |
| `SelectedIds` | `HashSet<string>` | [] | See the behavior rules and model contract above. |
| `SelectedIdsChanged` | `EventCallback<HashSet<string>>` | not set | See the behavior rules and model contract above. |
| `Toolbar` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `RowActions` | `RenderFragment<TItem>?` | not set | See the behavior rules and model contract above. |
| `InitialPageSize` | `int` | 5 | See the behavior rules and model contract above. |
| `ReadRange` | `Func<NgDataRangeRequest,CancellationToken,Task<NgDataRangeResult<TItem>>>?` | not set | Flat remote range adapter; requires Virtualize and excludes Items, page readers and grouping. See Remote ranges. |
| `ReadGroupedRange` | `Func<NgGroupedRangeRequest,CancellationToken,Task<NgGroupedRangeResult<TItem>>>?` | not set | Group-aware visible-slot range adapter; requires Virtualize and RemoteGroupKeys. See Grouped remote ranges. |
| `ExpandWindowGroupsText` | `string` | "Expand loaded groups" | Localized action label for expanding group headers in the retained window. |
| `CollapseWindowGroupsText` | `string` | "Collapse loaded groups" | Localized action label for collapsing group headers in the retained window. |
| `LoadedWindowText` | `string` | "Loaded window" | Localized label for the retained range and Page export scope. |
| `SelectWindowText` | `string` | "Select loaded window" | Localized accessible name for selection of eligible loaded-window records. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `readGroupedRange` | `Future<NgGroupedRangeResult<T>> Function(NgGroupedRangeRequest)?` | Group-aware visible-slot range adapter; requires Virtualize and RemoteGroupKeys. See Grouped remote ranges. |
| `readRange` | `Future<NgDataRangeResult<T>> Function(NgDataRangeRequest)?` | Flat remote range adapter; requires Virtualize and excludes Items, page readers and grouping. See Remote ranges. |
| `loadedWindowText` | `String` | Localized label for the retained range and Page export scope. |
| `selectWindowText` | `String` | Localized accessible name for selection of eligible loaded-window records. |
| `expandWindowGroupsText` | `String` | Localized action label for expanding group headers in the retained window. |
| `collapseWindowGroupsText` | `String` | Localized action label for collapsing group headers in the retained window. |
| `virtualize` | `bool` | Opt-in fixed-height virtual rendering. Local Grid covers the result; remote Grid retains pages; trees cover loaded expanded nodes. See Virtual data. |
| `rowHeight` | `double` | Fixed virtual row height, default 48 pixels; finite and at least 40. Templates must fit. |
| `viewportHeight` | `double` | Virtual scroll viewport height, default 384 pixels; finite and at least one row. |
| `export` | `NgGridExport<T>?` | Optional NgGridExport configuration: query/selection scope, ordered columns, text formatting, bounded CSV/TSV delivery and a full-data remote adapter. See Grid export. |
| `editing` | `NgGridEditing<T>?` | Optional NgGridEditing configuration for isolated drafts, validation, async persistence and confirmed deletion. See Grid editing. |
| `items` | `List<T>` | Input collection. Replace it when changing records or configuration. |
| `readData` | `Future<NgDataResult<T>> Function(NgDataRequest)?` | Async page adapter; return requested rows and filtered total. See request/result contracts above. |
| `readGroupedData` | `Future<NgGroupedDataResult<T>> Function(NgGroupedDataRequest)?` | Async grouped page adapter; mutually exclusive with ReadData and local grouping/aggregates. |
| `remoteGroupKeys` | `List<String>` | Ordered application-defined field identifiers, one to eight distinct nonblank keys. Changes reload page 1. |
| `remoteSummaryText` | `String Function(String, double?)?` | Plain-text server summary formatter receiving title and nullable numeric value. |
| `expandPageGroupsText` | `String` | Localized remote bulk-expand label; affects current page groups only. |
| `collapsePageGroupsText` | `String` | Localized remote bulk-collapse label; affects current page groups only. |
| `dataVersion` | `Object?` | Change to invalidate pending reads and cached data; keep stable otherwise. |
| `groupBy` | `String Function(T)?` | Pure local string-key selector; grouping precedes paging and cannot be combined with ReadData. |
| `groupText` | `String Function(String, int)?` | Plain-text caption from the group key and complete filtered group count. |
| `groupSelectors` | `List<String Function(T)>` | Ordered local string selectors, up to eight levels. Mutually exclusive with GroupBy. |
| `groupAggregates` | `List<NgGroupAggregate<T>>` | Numeric aggregate descriptors over all filtered records in each group. |
| `collapsibleGroups` | `bool` | Enable controlled group expansion and bulk actions. Default false. |
| `groupExpansionReadOnly` | `bool` | Lock group expansion independently of row selection. |
| `collapsedGroups` | `Set<String>` | Parent-owned set of encoded full group path IDs; use GroupId/ngGroupId. |
| `onCollapsedGroupsChanged` | `ValueChanged<Set<String>>?` | Propose one fresh collapsed-ID set; accept with setState. |
| `groupToggleLabel` | `String Function(List<String>, bool)?` | Localized accessible toggle name from path and current expanded state. |
| `expandGroupsText` | `String` | Localized expand-all action label. |
| `collapseGroupsText` | `String` | Localized collapse-all action label. |
| `multiSort` | `bool` | Append sorted columns in priority order; default false. |
| `loadingText` | `String` | Localized loading status. |
| `errorText` | `String` | Localized failure status; raw service errors are not rendered. |
| `retryText` | `String` | Localized retry action text. |
| `columns` | `List<NgDataColumn<T>>` | Column definitions; see the data model and example. |
| `rowId` | `String Function(T)` | See the behavior rules and model contract above. |
| `selectedIds` | `Set<String>` | See the behavior rules and model contract above. |
| `onSelectionChanged` | `ValueChanged<Set<String>>?` | See the behavior rules and model contract above. |
| `rowActions` | `Widget Function(BuildContext, T)?` | See the behavior rules and model contract above. |
| `toolbar` | `Widget?` | See the behavior rules and model contract above. |
| `emptyBuilder` | `Widget?` | See the behavior rules and model contract above. |
| `selectionReadOnly` | `bool` | See the behavior rules and model contract above. |
| `canSelect` | `bool Function(T)?` | See the behavior rules and model contract above. |
| `pageSizes` | `List<int>` | See the behavior rules and model contract above. |
| `label` | `String` | Visible label or accessible name. |
| `emptyText` | `String` | See the behavior rules and model contract above. |
| `initialPageSize` | `int` | See the behavior rules and model contract above. |

```dart
const NgDataGrid({
    super.key,
    this.readRange,
    this.readGroupedRange,
    this.expandWindowGroupsText = 'Expand loaded groups',
    this.collapseWindowGroupsText = 'Collapse loaded groups',
    this.loadedWindowText = 'Loaded window',
    this.selectWindowText = 'Select loaded window',
    this.virtualize = false,
    this.rowHeight = 48,
    this.viewportHeight = 384,
    this.items = const [],
    this.editing,
    this.export,
    this.readData,
    this.readGroupedData,
    this.remoteGroupKeys = const [],
    this.remoteSummaryText,
    this.expandPageGroupsText = 'Expand page groups',
    this.collapsePageGroupsText = 'Collapse page groups',
    this.dataVersion,
    this.groupBy,
    this.groupText,
    this.groupSelectors = const [],
    this.groupAggregates = const [],
    this.collapsibleGroups = false,
    this.groupExpansionReadOnly = false,
    this.collapsedGroups = const {},
    this.onCollapsedGroupsChanged,
    this.groupToggleLabel,
    this.expandGroupsText = 'Expand all groups',
    this.collapseGroupsText = 'Collapse all groups',
    this.multiSort = false,
    this.loadingText = 'Loading records…',
    this.errorText = 'Unable to load records.',
    this.retryText = 'Retry',
    required this.columns,
    required this.rowId,
    this.selectedIds = const {},
    this.onSelectionChanged,
    this.rowActions,
    this.toolbar,
    this.emptyBuilder,
    this.selectionReadOnly = false,
    this.canSelect,
    this.pageSizes = const [5, 10, 25, 50],
    this.label = 'Records',
    this.emptyText = 'No matching records.',
    this.initialPageSize = 5,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgDataGrid.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/data.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.

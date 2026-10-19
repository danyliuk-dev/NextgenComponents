// GENERATED from scripts/manual_content.py. Do not edit.
import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';
class ComponentPreview extends StatelessWidget {
  final String name;
  const ComponentPreview({super.key, required this.name});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '$name preview', debugShowCheckedModeBanner: false,
    theme: NgTheme.light(), home: Scaffold(body: SafeArea(
      child: SingleChildScrollView(padding: const EdgeInsets.all(24),
        child: SizedBox(width: double.infinity, child: switch (name) {
'NgAIPrompt' => const NgAIPromptExample(),
'NgArcGauge' => const NgArcGaugeExample(),
'NgAutoComplete' => const NgAutoCompleteExample(),
'NgBreadcrumb' => const NgBreadcrumbExample(),
'NgButton' => const NgButtonExample(),
'NgButtonGroup' => const NgButtonGroupExample(),
'NgCalendar' => const NgCalendarExample(),
'NgChart' => const NgChartExample(),
'NgCheckBox' => const NgCheckBoxExample(),
'NgChip' => const NgChipExample(),
'NgChipList' => const NgChipListExample(),
'NgComboBox' => const NgComboBoxExample(),
'NgDataGrid' => const NgDataGridExample(),
'NgDateInput' => const NgDateInputExample(),
'NgDatePicker' => const NgDatePickerExample(),
'NgDateRangePicker' => const NgDateRangePickerExample(),
'NgDateTimePicker' => const NgDateTimePickerExample(),
'NgDiagram' => const NgDiagramExample(),
'NgDialog' => const NgDialogExample(),
'NgDrawer' => const NgDrawerExample(),
'NgDropDownList' => const NgDropDownListExample(),
'NgEditor' => const NgEditorExample(),
'NgForm' => const NgFormExample(),
'NgLinearGauge' => const NgLinearGaugeExample(),
'NgMap' => const NgMapExample(),
'NgMenu' => const NgMenuExample(),
'NgMultiSelect' => const NgMultiSelectExample(),
'NgNotification' => const NgNotificationExample(),
'NgNumericTextBox' => const NgNumericTextBoxExample(),
'NgPager' => const NgPagerExample(),
'NgPdfViewer' => const NgPdfViewerExample(),
'NgPivotGrid' => const NgPivotGridExample(),
'NgPromptBox' => const NgPromptBoxExample(),
'NgRadioGroup' => const NgRadioGroupExample(),
'NgScheduler' => const NgSchedulerExample(),
'NgSpreadsheet' => const NgSpreadsheetExample(),
'NgStepper' => const NgStepperExample(),
'NgSwitch' => const NgSwitchExample(),
'NgTabs' => const NgTabsExample(),
'NgTextArea' => const NgTextAreaExample(),
'NgTextBox' => const NgTextBoxExample(),
'NgTimePicker' => const NgTimePickerExample(),
'NgToggleButton' => const NgToggleButtonExample(),
'NgTooltip' => const NgTooltipExample(),
'NgTreeList' => const NgTreeListExample(),
'NgTreeView' => const NgTreeViewExample(),
'NgWizard' => const NgWizardExample(),_ => const Text('Unknown component.'),
})),
)));
}
class NgButtonExample extends StatefulWidget { const NgButtonExample({super.key}); @override State<NgButtonExample> createState()=>_NgButtonExampleState(); }
class _NgButtonExampleState extends State<NgButtonExample> {
int count = 0;
Widget build(BuildContext context) => NgButton(primary: true,
  onPressed: () => setState(() => count++), child: Text('Clicked $count times'));
}
class NgTextBoxExample extends StatefulWidget { const NgTextBoxExample({super.key}); @override State<NgTextBoxExample> createState()=>_NgTextBoxExampleState(); }
class _NgTextBoxExampleState extends State<NgTextBoxExample> {
String rounded='theme';
int delay=600,notifications=0,notifiedLength=0;
String size='medium',fill='theme';
bool locked = false, password = true; String submitted = '';
final editor = TextEditingController(text:'Design review');
final focus = FocusNode();
@override void dispose(){editor.dispose();focus.dispose();super.dispose();}
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>rounded=rounded=='theme'?'large':rounded=='large'?'none':rounded=='none'?'small':rounded=='small'?'medium':rounded=='medium'?'full':'theme'),child:const Text('Change corners')),NgButton(onPressed:()=>setState(()=>fill=fill=='flat'?'theme':'flat'),child:const Text('Toggle flat fill'))]),
Text('Corners: $rounded'),
Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>editor.text='External replacement'),child:const Text('Replace draft')),NgButton(onPressed:()=>setState(()=>delay=delay==600?0:600),child:const Text('Change delay'))]),
Text('Delay: $delay ms · Notifications: $notifications · Notified length: $notifiedLength'),
Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>size=size=='medium'?'large':size=='large'?'small':'medium'),child:const Text('Change size')),NgButton(onPressed:()=>setState(()=>fill=fill=='theme'?'filled':fill=='filled'?'outline':'theme'),child:const Text('Change fill'))]),
Text('Size: $size · Fill: $fill'),
NgButton(onPressed:()=>setState(()=>password=!password),child:const Text('Toggle password mode')),
NgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),
NgTextBox(rounded:rounded,debounceDelay:delay,onDebouncedChange:(v)=>setState((){notifications++;notifiedLength=v.length;}),size:size,fillMode:fill,label:'Project name',controller:editor,focusNode:focus,readOnly:locked,showClearButton:true,password:password,showPasswordToggle:true,maxLength:80,
helperText:'Use a short, descriptive name.',prefix:const Icon(Icons.edit_outlined),
onChanged:(_)=>setState((){}),onSubmitted:(v)=>setState(()=>submitted=v)),
NgButton(onPressed:()=>focus.requestFocus(),child:const Text('Focus editor')),
Text('Length: ${editor.text.length}')]);

}
class NgTextAreaExample extends StatefulWidget { const NgTextAreaExample({super.key}); @override State<NgTextAreaExample> createState()=>_NgTextAreaExampleState(); }
class _NgTextAreaExampleState extends State<NgTextAreaExample> {
String rounded='theme';
int delay=600,notifications=0,notifiedLength=0;
String size='medium',fill='theme';
bool automatic = true, locked = false;
final editor = TextEditingController(text:'Short note');
@override void dispose(){editor.dispose();super.dispose();}
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>rounded=rounded=='theme'?'large':rounded=='large'?'none':rounded=='none'?'small':rounded=='small'?'medium':rounded=='medium'?'full':'theme'),child:const Text('Change corners')),NgButton(onPressed:()=>setState(()=>fill=fill=='flat'?'theme':'flat'),child:const Text('Toggle flat fill'))]),
Text('Corners: $rounded'),
Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>editor.text='External replacement'),child:const Text('Replace draft')),NgButton(onPressed:()=>setState(()=>delay=delay==600?0:600),child:const Text('Change delay'))]),
Text('Delay: $delay ms · Notifications: $notifications · Notified length: $notifiedLength'),
Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>size=size=='medium'?'large':size=='large'?'small':'medium'),child:const Text('Change size')),NgButton(onPressed:()=>setState(()=>fill=fill=='theme'?'filled':fill=='filled'?'outline':'theme'),child:const Text('Change fill'))]),
Text('Size: $size · Fill: $fill'),
 Wrap(spacing:8,runSpacing:8,children:[
  NgButton(onPressed:()=>setState(()=>automatic=!automatic),child:const Text('Toggle automatic height')),
  NgButton(onPressed:()=>setState(()=>editor.text=List.generate(14,(i)=>'Line ${i+1}: a detailed delivery note.').join('\n')),child:const Text('Load long text')),
  NgButton(onPressed:()=>setState(()=>editor.text='Short note'),child:const Text('Load short text')),
 ]),
 NgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),
 NgTextArea(rounded:rounded,debounceDelay:delay,onDebouncedChange:(v)=>setState((){notifications++;notifiedLength=v.length;}),size:size,fillMode:fill,label:'Delivery notes',controller:editor,rows:2,maxRows:6,autoSize:automatic,
  readOnly:locked,showClearButton:true,helperText:'Grows from 2 to 6 rows; longer notes scroll.',onChanged:(_)=>setState((){})),
 Text('Automatic height: $automatic · Length: ${editor.text.length}'),
]);

}
class NgNumericTextBoxExample extends StatefulWidget { const NgNumericTextBoxExample({super.key}); @override State<NgNumericTextBoxExample> createState()=>_NgNumericTextBoxExampleState(); }
class _NgNumericTextBoxExampleState extends State<NgNumericTextBoxExample> {
double? amount=2; bool readOnly=false; String status='';
@override
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
 NgForm(submitLabel:'Save amount',onValidSubmit:()=>setState(()=>status='Saved amount: $amount'),child:
  NgNumericTextBox(label:'Amount',value:amount,min:0,max:10,step:0.5,readOnly:readOnly,
   helperText:'0 to 10; buttons change by 0.5.',onChanged:(v)=>setState(()=>amount=v))),
 NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Read only')),
 Text('Accepted amount: $amount'),Text(status),
]);
}
class NgCheckBoxExample extends StatefulWidget { const NgCheckBoxExample({super.key}); @override State<NgCheckBoxExample> createState()=>_NgCheckBoxExampleState(); }
class _NgCheckBoxExampleState extends State<NgCheckBoxExample> {
bool enabled = true;
Widget build(BuildContext context) => NgCheckBox(label: 'Notifications',
  value: enabled, onChanged: (v) => setState(() => enabled = v));
}
class NgSwitchExample extends StatefulWidget { const NgSwitchExample({super.key}); @override State<NgSwitchExample> createState()=>_NgSwitchExampleState(); }
class _NgSwitchExampleState extends State<NgSwitchExample> {
bool enabled = true;
Widget build(BuildContext context) => NgSwitch(label: 'Notifications',
  value: enabled, onChanged: (v) => setState(() => enabled = v));
}
class NgDropDownListExample extends StatefulWidget { const NgDropDownListExample({super.key}); @override State<NgDropDownListExample> createState()=>_NgDropDownListExampleState(); }
class _NgDropDownListExampleState extends State<NgDropDownListExample> {
String? team='design'; bool readOnly=false; String status='';
List<NgOption> items=[const NgOption('design','Design'),const NgOption('dev','Engineering'),const NgOption('locked','Unavailable',disabled:true)];
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 NgForm(submitLabel:'Save team',onValidSubmit:()=>setState(()=>status='Saved team: $team'),child:
  NgDropDownList(label:'Team',value:team,items:items,readOnly:readOnly,placeholder:'Choose a team',helperText:'Unavailable selections must be replaced.',onChanged:(v)=>setState(()=>team=v))),
 NgButton(onPressed:()=>setState(()=>items=items.where((o)=>o.value!=team).toList()),child:const Text('Remove selected option')),
 NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Read only')),
 Text('Selected team: $team'),Text(status),
]);
}
class NgRadioGroupExample extends StatefulWidget { const NgRadioGroupExample({super.key}); @override State<NgRadioGroupExample> createState()=>_NgRadioGroupExampleState(); }
class _NgRadioGroupExampleState extends State<NgRadioGroupExample> {
String? team='design'; bool readOnly=false; String orientation='vertical';
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 NgRadioGroup(label:'Team',value:team,orientation:orientation,readOnly:readOnly,helperText:'Choose one available team.',
  items:const[NgOption('design','Design'),NgOption('dev','Engineering'),NgOption('locked','Unavailable',disabled:true)],
  itemBuilder:(_,o)=>Text('Team · ${o.label}',style:const TextStyle(fontWeight:FontWeight.bold)),onChanged:(v)=>setState(()=>team=v)),
 NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Read only')),
 NgButton(onPressed:()=>setState(()=>orientation=orientation=='vertical'?'horizontal':'vertical'),child:const Text('Change layout')),
 Text('Selected team: $team'),
]);
}
class NgComboBoxExample extends StatefulWidget { const NgComboBoxExample({super.key}); @override State<NgComboBoxExample> createState()=>_NgComboBoxExampleState(); }
class _NgComboBoxExampleState extends State<NgComboBoxExample> {
bool locked=false;String? person='a';String status='Not saved';
List<NgOption> people=[const NgOption('a','Alex'),const NgOption('b','Bella'),const NgOption('x','Blocked',disabled:true)];
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
NgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),
NgForm(submitLabel:'Save selection',onValidSubmit:()=>setState(()=>status='Saved ID: $person'),child:
NgComboBox(label:'Assignee',value:person,items:people,required:true,readOnly:locked,showClearButton:true,filterMode:'startsWith',minLength:1,placeholder:'Search a person',onChanged:(v)=>setState(()=>person=v),itemBuilder:(_,o)=>Text('${o.label} · Team member'))),
NgButton(onPressed:()=>setState(()=>people=people.map((o)=>o.value==person?NgOption(o.value,'Alex Morgan'):o).toList()),child:const Text('Rename selected')),
Text(status)]);

}
class NgAutoCompleteExample extends StatefulWidget { const NgAutoCompleteExample({super.key}); @override State<NgAutoCompleteExample> createState()=>_NgAutoCompleteExampleState(); }
class _NgAutoCompleteExampleState extends State<NgAutoCompleteExample> {
bool locked=false;String city='';
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
NgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),
NgAutoComplete(label:'City',items:const ['London','Lisbon','Los Angeles','Berlin'],filterMode:'startsWith',minLength:2,readOnly:locked,placeholder:'Type at least two letters',onChanged:(v)=>setState(()=>city=v)),
Text('Current city: $city')]);

}
class NgMultiSelectExample extends StatefulWidget { const NgMultiSelectExample({super.key}); @override State<NgMultiSelectExample> createState()=>_NgMultiSelectExampleState(); }
class _NgMultiSelectExampleState extends State<NgMultiSelectExample> {
bool locked=false;List<String> selected=['locked'];
final services=const [NgOption('a','Alpha'),NgOption('b','Beta'),NgOption('g','Gamma'),NgOption('locked','Mandatory',disabled:true)];
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
NgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),
NgMultiSelect(label:'Services',value:selected,items:services,maxSelected:3,showActions:true,readOnly:locked,emptyText:'No matching services',onChanged:(v)=>setState(()=>selected=v),itemBuilder:(_,o)=>Text('${o.label} · service'),tagBuilder:(_,o)=>Text('✓ ${o.label}')),
Text('Selected IDs: ${selected.join(', ')}')]);

}
class NgDateInputExample extends StatefulWidget { const NgDateInputExample({super.key}); @override State<NgDateInputExample> createState()=>_NgDateInputExampleState(); }
class _NgDateInputExampleState extends State<NgDateInputExample> {
DateTime? value=DateTime(2026,10,20); bool readOnly=false;
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
 NgDateInput(value:value,min:DateTime(2026,10,1),max:DateTime(2026,10,31),
  readOnly:readOnly,disabledDate:(d)=>d.weekday==DateTime.sunday,
  onChanged:(v)=>setState(()=>value=v)),
 NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Read only')),
 Text('Accepted date: $value'),
]);
}
class NgDatePickerExample extends StatefulWidget { const NgDatePickerExample({super.key}); @override State<NgDatePickerExample> createState()=>_NgDatePickerExampleState(); }
class _NgDatePickerExampleState extends State<NgDatePickerExample> {
DateTime? value=DateTime(2026,10,20); bool readOnly=false;
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
 NgDatePicker(value:value,min:DateTime(2026,10,1),max:DateTime(2026,10,31),
  readOnly:readOnly,disabledDate:(d)=>d.weekday==DateTime.sunday,
  onChanged:(v)=>setState(()=>value=v)),
 NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Read only')),
 Text('Accepted date: $value'),
]);
}
class NgCalendarExample extends StatefulWidget { const NgCalendarExample({super.key}); @override State<NgCalendarExample> createState()=>_NgCalendarExampleState(); }
class _NgCalendarExampleState extends State<NgCalendarExample> {
DateTime? value=DateTime(2026,10,20); bool readOnly=false;
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
 NgCalendar(value:value,min:DateTime(2026,10,1),max:DateTime(2026,10,31),
  readOnly:readOnly,disabledDate:(d)=>d.weekday==DateTime.sunday,
  onChanged:(v)=>setState(()=>value=v)),
 NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Read only')),
 Text('Accepted date: $value'),
]);
}
class NgDateTimePickerExample extends StatefulWidget { const NgDateTimePickerExample({super.key}); @override State<NgDateTimePickerExample> createState()=>_NgDateTimePickerExampleState(); }
class _NgDateTimePickerExampleState extends State<NgDateTimePickerExample> {
DateTime? value = DateTime(2026,10,20,9,30);
Widget build(BuildContext context) => NgDateTimePicker(label: 'Appointment', minuteStep: 15, value: value,
  onChanged: (v) => setState(() => value = v));
}
class NgTimePickerExample extends StatefulWidget { const NgTimePickerExample({super.key}); @override State<NgTimePickerExample> createState()=>_NgTimePickerExampleState(); }
class _NgTimePickerExampleState extends State<NgTimePickerExample> {
TimeOfDay? value = const TimeOfDay(hour: 9, minute: 30);
Widget build(BuildContext context) => NgTimePicker(label: 'Appointment', minuteStep: 15, value: value,
  onChanged: (v) => setState(() => value = v));
}
class NgDateRangePickerExample extends StatefulWidget { const NgDateRangePickerExample({super.key}); @override State<NgDateRangePickerExample> createState()=>_NgDateRangePickerExampleState(); }
class _NgDateRangePickerExampleState extends State<NgDateRangePickerExample> {
NgDateRange? range = NgDateRange(DateTime(2026,10,20), DateTime(2026,10,23));
Widget build(BuildContext context) => NgDateRangePicker(label: 'Period', value: range,
  disabledDate: (d) => d.weekday == DateTime.sunday, required: true, onChanged: (v) => setState(() => range = v));
}
class NgFormExample extends StatefulWidget { const NgFormExample({super.key}); @override State<NgFormExample> createState()=>_NgFormExampleState(); }
class _NgFormExampleState extends State<NgFormExample> {
bool workspaceExpanded=true,identityExpanded=true,deliveryExpanded=true;
bool nested=false,sectioned=false,reverseSections=false;
int notesSpan=0;
bool customSummary=true,showSummary=true;
int revision=0,columns=2,gap=16; bool fail=false,disabled=false; String name='',owner='',notes='',reference='',status='Not saved';
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 Wrap(children:[NgButton(onPressed:()=>setState((){nested=!nested;sectioned=true;}),child:const Text('Nest sections'))]),
 Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>sectioned=!sectioned),child:const Text('Toggle sections')),NgButton(onPressed:()=>setState(()=>reverseSections=!reverseSections),child:const Text('Reverse sections'))]),
 Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>notesSpan=notesSpan==0?2:notesSpan==2?1:0),child:const Text('Change notes span')),NgButton(onPressed:()=>setState(()=>columns=3),child:const Text('Use three columns'))]),
 Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>customSummary=!customSummary),child:const Text('Toggle custom summary')),NgButton(onPressed:()=>setState(()=>showSummary=!showSummary),child:const Text('Toggle summary visibility'))]),
 Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>columns=columns==2?1:2),child:const Text('Change columns')),NgButton(onPressed:()=>setState(()=>gap=gap==16?32:16),child:const Text('Change spacing'))]),
 Text('Maximum columns: $columns · Gap: $gap'),
 NgCheckBox(label:'Simulate save failure',value:fail,onChanged:(v)=>setState(()=>fail=v)),
 NgCheckBox(label:'Disable form',value:disabled,onChanged:(v)=>setState(()=>disabled=v)),
 NgForm(fieldSpans:sectioned?null:[1,1,notesSpan,1],showSummary:showSummary,summaryTitle:'Review this application',summaryBuilder:customSummary?(_,errors)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Review ${errors.length} issue(s)',style:const TextStyle(fontWeight:FontWeight.bold)),for(final message in errors)Text(message)]):null,key:ValueKey(revision),columns:columns,gap:gap,enabled:!disabled,onValidSubmit:()async{
  final version=revision,denied=fail;final snapshot=name;await Future<void>.delayed(const Duration(seconds:1));
  if(denied)throw StateError('Demo failure');if(mounted&&version==revision)setState(()=>status='Saved: $snapshot');
 },fields:sectioned?null:formFields(),sections:sectioned?formSections():null,actionsBuilder:(_,submit)=>Wrap(spacing:12,runSpacing:8,crossAxisAlignment:WrapCrossAlignment.center,children:[NgButton(primary:true,onPressed:submit,child:const Text('Save application')),const Text('All fields are validated before saving.')])),
 NgButton(onPressed:()=>setState((){revision++;name='';owner='';notes='';reference='';status='Not saved';}),child:const Text('Reset application')),
 Text(status),
]);

List<Widget> formFields()=>[
  NgTextBox(label:'Application name',initialValue:name,maxLength:80,helperText:'Required before saving.',onChanged:(v)=>name=v,validator:(v)=>v==null||v.trim().isEmpty?'Enter an application name.':null),
  NgTextBox(label:'Owner',initialValue:owner,onChanged:(v)=>owner=v,validator:(v)=>(v??'').trim().isEmpty?'Enter an owner.':null),
  NgTextArea(label:'Notes',initialValue:notes,rows:2,onChanged:(v)=>notes=v),
  NgTextBox(label:'Reference',initialValue:reference,onChanged:(v)=>reference=v),
 ];
List<NgFormSection> formSections(){final fields=formFields();final sections=[NgFormSection(id:'identity',title:'Application details',description:'Name and owner are required.',expanded:identityExpanded,onExpandedChanged:(value)=>setState(()=>identityExpanded=value),fields:fields.sublist(0,2),columns:columns,gap:gap),NgFormSection(id:'delivery',title:'Delivery instructions',description:'Add notes and a reference for the team.',expanded:deliveryExpanded,onExpandedChanged:(value)=>setState(()=>deliveryExpanded=value),fields:fields.sublist(2),columns:columns,gap:gap,fieldSpans:[notesSpan,1])];final ordered=reverseSections?sections.reversed.toList():sections;return nested?[NgFormSection(id:'workspace',title:'Application workspace',description:'One form validates every nested section.',sections:ordered,expanded:workspaceExpanded,onExpandedChanged:(value)=>setState(()=>workspaceExpanded=value))]:ordered;}

}
class NgTabsExample extends StatefulWidget { const NgTabsExample({super.key}); @override State<NgTabsExample> createState()=>_NgTabsExampleState(); }
class _NgTabsExampleState extends State<NgTabsExample> {
int index = 0;
Widget build(BuildContext context) => NgTabs(selectedIndex: index,
  items: const [NgTab('Overview',Text('Summary')),NgTab('Details',Text('Details'))],
  onChanged: (v) => setState(() => index = v));
}
class NgDialogExample extends StatefulWidget { const NgDialogExample({super.key}); @override State<NgDialogExample> createState()=>_NgDialogExampleState(); }
class _NgDialogExampleState extends State<NgDialogExample> {
Widget build(BuildContext context) => NgButton(child: const Text('Open'),
  onPressed: () => NgDialog.show<void>(context, title: 'Confirmation',
    child: const Text('Continue?'), actions: [TextButton(
      onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))]));
}
class NgTooltipExample extends StatefulWidget { const NgTooltipExample({super.key}); @override State<NgTooltipExample> createState()=>_NgTooltipExampleState(); }
class _NgTooltipExampleState extends State<NgTooltipExample> {
Widget build(BuildContext context) => NgTooltip(text: 'Create a copy',
  child: NgButton(onPressed: () {}, child: const Text('Copy')));
}
class NgNotificationExample extends StatefulWidget { const NgNotificationExample({super.key}); @override State<NgNotificationExample> createState()=>_NgNotificationExampleState(); }
class _NgNotificationExampleState extends State<NgNotificationExample> {
bool visible = true;
Widget build(BuildContext context) => visible ? NgNotification(message: 'Saved',
  onDismiss: () => setState(() => visible = false)) : const SizedBox.shrink();
}
class NgPagerExample extends StatefulWidget { const NgPagerExample({super.key}); @override State<NgPagerExample> createState()=>_NgPagerExampleState(); }
class _NgPagerExampleState extends State<NgPagerExample> {
int page = 1, size = 5;
Widget build(BuildContext context) => NgPager(total: 18, page: page, pageSize: size,
  onPageChanged: (v) => setState(() => page = v),
  onPageSizeChanged: (v) => setState(() { size = v; page = 1; }));
}
class NgBreadcrumbExample extends StatefulWidget { const NgBreadcrumbExample({super.key}); @override State<NgBreadcrumbExample> createState()=>_NgBreadcrumbExampleState(); }
class _NgBreadcrumbExampleState extends State<NgBreadcrumbExample> {
String? selected;
Widget build(BuildContext context) => NgBreadcrumb(
  items: const [NgBreadcrumbItem('all','Projects'),NgBreadcrumbItem('design','Design')],
  onNavigate: (id) => setState(() => selected = id));
}
class NgDataGridExample extends StatefulWidget { const NgDataGridExample({super.key}); @override State<NgDataGridExample> createState()=>_NgDataGridExampleState(); }
class _NgDataGridExampleState extends State<NgDataGridExample> {
final rows = [(id: 'a', name: 'Desk', count: 12), (id: 'b', name: 'Chair', count: 120)];
Set<String> selected = {};
Widget build(BuildContext context) => NgDataGrid<({String id, String name, int count})>(
  items: rows, rowId: (r) => r.id, selectedIds: selected,
  canSelect: (r) => r.count < 100, pageSizes: const [5, 10, 20],
  onSelectionChanged: (v) => setState(() => selected = v),
  columns: [NgDataColumn('name','Name',(r) => r.name),
    NgDataColumn('count','Quantity',(r) => r.count)]);
}
class NgTreeViewExample extends StatefulWidget { const NgTreeViewExample({super.key}); @override State<NgTreeViewExample> createState()=>_NgTreeViewExampleState(); }
class _NgTreeViewExampleState extends State<NgTreeViewExample> {
bool selectionReadOnly = false, expansionReadOnly = false;
Set<String> expanded = {'root'}; String? selected;
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
  NgCheckBox(label: 'Selection read-only', value: selectionReadOnly, onChanged: (v) => setState(() => selectionReadOnly = v)),
  NgCheckBox(label: 'Expansion read-only', value: expansionReadOnly, onChanged: (v) => setState(() => expansionReadOnly = v)),
  NgTreeView<String>(
  selectionReadOnly: selectionReadOnly, expansionReadOnly: expansionReadOnly,
  emptyText: 'No teams found.',
  items: const [NgTreeNode('root','Projects',children: [NgTreeNode('a','Design'),NgTreeNode('b','Engineering')])],
  text: (s) => s,
  itemBuilder: (context, s) => Text('$s · team', style: const TextStyle(fontWeight: FontWeight.bold)),
  expandedIds: expanded, selectedId: selected,
  onExpandedChanged: (v) => setState(() => expanded = v),
  onSelected: (v) => setState(() => selected = v)),
  Text('Selected team: ${selected ?? "none"}'),
]);
}
class NgTreeListExample extends StatefulWidget { const NgTreeListExample({super.key}); @override State<NgTreeListExample> createState()=>_NgTreeListExampleState(); }
class _NgTreeListExampleState extends State<NgTreeListExample> {
bool selectionReadOnly = false, expansionReadOnly = false;
Set<String> expanded = {'root'}; String? selected;
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
  NgCheckBox(label: 'Selection read-only', value: selectionReadOnly, onChanged: (v) => setState(() => selectionReadOnly = v)),
  NgCheckBox(label: 'Expansion read-only', value: expansionReadOnly, onChanged: (v) => setState(() => expansionReadOnly = v)),
  NgTreeList<String>(
  selectionReadOnly: selectionReadOnly, expansionReadOnly: expansionReadOnly,
  emptyText: 'No teams found.',
  items: const [NgTreeNode('root','Projects',children: [NgTreeNode('a','Design'),NgTreeNode('b','Engineering')])],
  columns: [NgDataColumn('name','Name',(s) => s, cellBuilder: (context,s) => Text(s, style: const TextStyle(fontWeight: FontWeight.bold)))],
  expandedIds: expanded, selectedId: selected,
  onExpandedChanged: (v) => setState(() => expanded = v),
  onSelected: (v) => setState(() => selected = v)),
  Text('Selected team: ${selected ?? "none"}'),
]);
}
class NgChartExample extends StatefulWidget { const NgChartExample({super.key}); @override State<NgChartExample> createState()=>_NgChartExampleState(); }
class _NgChartExampleState extends State<NgChartExample> {
bool readOnly=false, legendReadOnly=false, revised=false, invalid=false, accept=true;
Set<int> hidden={}; String last='none';
String pointText(NgChartSelection p) => '${p.series} / ${p.category}: ${p.value.toStringAsFixed(0)} orders';
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
  NgCheckBox(label: 'Selection read-only', value: readOnly, onChanged: (v)=>setState(()=>readOnly=v)),
  NgCheckBox(label: 'Legend read-only', value: legendReadOnly, onChanged: (v)=>setState(()=>legendReadOnly=v)),
  NgCheckBox(label: 'Accept legend changes', value: accept, onChanged: (v)=>setState(()=>accept=v)),
  Wrap(spacing: 8, runSpacing: 8, children: [
    NgButton(onPressed: ()=>setState(()=>hidden={}), child: const Text('Show all series')),
    NgButton(onPressed: ()=>setState(()=>revised=!revised), child: const Text('Update values')),
    NgButton(onPressed: ()=>setState(()=>invalid=!invalid), child: const Text('Toggle invalid data')),
  ]),
  NgChart(title: 'Weekly orders', categories: const ['Mon','Tue','Wed'],
    series: invalid ? const [NgChartSeries('Orders',[1])] : [NgChartSeries('Orders',[revised?40:10,20,25]), const NgChartSeries('Target',[15,25,30])],
    hiddenSeries: hidden, onHiddenSeriesChanged: (v){if(accept)setState(()=>hidden=v);},
    selectionReadOnly: readOnly, legendReadOnly: legendReadOnly, pointLabel: pointText,
    emptyText: 'All series hidden.', onPointSelected: (p)=>setState(()=>last=pointText(p))),
  Text('Last callback: $last'),
]);
}
class NgLinearGaugeExample extends StatefulWidget { const NgLinearGaugeExample({super.key}); @override State<NgLinearGaugeExample> createState()=>_NgLinearGaugeExampleState(); }
class _NgLinearGaugeExampleState extends State<NgLinearGaugeExample> {
double value = 72.5;
bool showRanges = true;
final ranges = const [NgGaugeRange(0,60,'#187444','Normal'), NgGaugeRange(60,85,'#b66d16','Elevated'), NgGaugeRange(85,100,'#b42318','High')];
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
 Wrap(spacing: 8, runSpacing: 8, children: [
  for (final entry in {'Normal':42.5, 'Elevated':72.5, 'High':95.0, 'Above maximum':125.0, 'Below minimum':-10.0}.entries)
   NgButton(onPressed:()=>setState(()=>value=entry.value), child:Text(entry.key)),
  NgButton(onPressed:()=>setState(()=>showRanges=!showRanges), child:const Text('Toggle ranges')),
 ]),
 const SizedBox(height:16),
 NgLinearGauge(label:'Load',value:value,ranges:showRanges?ranges:const [],valueFormatter:(v)=>v.toStringAsFixed(1)),
]);
}
class NgArcGaugeExample extends StatefulWidget { const NgArcGaugeExample({super.key}); @override State<NgArcGaugeExample> createState()=>_NgArcGaugeExampleState(); }
class _NgArcGaugeExampleState extends State<NgArcGaugeExample> {
double value = 72.5;
bool showRanges = true;
final ranges = const [NgGaugeRange(0,60,'#187444','Normal'), NgGaugeRange(60,85,'#b66d16','Elevated'), NgGaugeRange(85,100,'#b42318','High')];
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
 Wrap(spacing: 8, runSpacing: 8, children: [
  for (final entry in {'Normal':42.5, 'Elevated':72.5, 'High':95.0, 'Above maximum':125.0, 'Below minimum':-10.0}.entries)
   NgButton(onPressed:()=>setState(()=>value=entry.value), child:Text(entry.key)),
  NgButton(onPressed:()=>setState(()=>showRanges=!showRanges), child:const Text('Toggle ranges')),
 ]),
 const SizedBox(height:16),
 NgArcGauge(label:'Load',value:value,ranges:showRanges?ranges:const [],valueFormatter:(v)=>v.toStringAsFixed(1)),
]);
}
class NgSchedulerExample extends StatefulWidget { const NgSchedulerExample({super.key}); @override State<NgSchedulerExample> createState()=>_NgSchedulerExampleState(); }
class _NgSchedulerExampleState extends State<NgSchedulerExample> {
DateTime date=DateTime(2026,10,19);
NgScheduleView view=NgScheduleView.week;
bool readOnly=false,navigationReadOnly=false,empty=false,accept=true;
int firstDay=1;
String message='none';
final events=[NgScheduleEvent('review','Review',DateTime(2026,10,19,10),DateTime(2026,10,19,11)),NgScheduleEvent('night','Overnight',DateTime(2026,10,19,23),DateTime(2026,10,20,1))];
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 Wrap(spacing:8,runSpacing:8,children:[
  NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Toggle editing lock')),
  NgButton(onPressed:()=>setState(()=>navigationReadOnly=!navigationReadOnly),child:const Text('Toggle navigation lock')),
  NgButton(onPressed:()=>setState(()=>accept=!accept),child:const Text('Toggle acceptance')),
  NgButton(onPressed:()=>setState(()=>firstDay=firstDay==1?7:1),child:const Text('Toggle week start')),
  NgButton(onPressed:()=>setState(()=>empty=!empty),child:const Text('Toggle events')),
  NgButton(onPressed:()=>setState((){date=DateTime(2026,10,19);view=NgScheduleView.week;}),child:const Text('Reset date')),
 ]),
 Text('Editing ${readOnly?"locked":"enabled"} · Navigation ${navigationReadOnly?"locked":"enabled"} · Proposals ${accept?"accepted":"rejected"} · Week starts ${firstDay==1?"Monday":"Sunday"}'),
 NgScheduler(date:date,view:view,firstDayOfWeek:firstDay,readOnly:readOnly,navigationReadOnly:navigationReadOnly,items:empty?const []:events,
  onDateChanged:(d){if(accept)setState(()=>date=d);},onViewChanged:(v){if(accept)setState(()=>view=v);},
  eventLabel:(e)=>'Shift: ${e.title}',emptyText:'No shifts planned',
  onCreate:(d)=>setState(()=>message='Create: ${NgScheduler.dayText(d)}'),onEdit:(e)=>setState(()=>message='Edit: ${e.title}')),
 Text('Last action: $message'),
]);
}
class NgSpreadsheetExample extends StatefulWidget { const NgSpreadsheetExample({super.key}); @override State<NgSpreadsheetExample> createState()=>_NgSpreadsheetExampleState(); }
class _NgSpreadsheetExampleState extends State<NgSpreadsheetExample> {
NgSheet sheet=initial();
bool protect=true,lockA1=false,readOnly=false,accept=true;
int proposals=0;
static NgSheet initial()=>NgSheet(rows:4,columns:4,cells:{'A1':'10','B1':'20','C1':'=SUM(A1:B1)'});
bool editable(String a)=>(!protect||!a.startsWith('C'))&&(!lockA1||a!='A1');
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 Wrap(spacing:8,runSpacing:8,children:[
  NgButton(onPressed:()=>setState(()=>protect=!protect),child:const Text('Toggle protection')),
  NgButton(onPressed:()=>setState(()=>lockA1=!lockA1),child:const Text('Toggle A1 lock')),
  NgButton(onPressed:()=>setState(()=>accept=!accept),child:const Text('Toggle acceptance')),
  NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Toggle read-only')),
  NgButton(onPressed:()=>setState(()=>sheet=initial()),child:const Text('Reset sheet')),
  NgButton(onPressed:()=>setState(()=>sheet=NgSheet(rows:1,columns:1)),child:const Text('Shrink sheet')),
 ]),
 Text('Protection ${protect?"enabled":"disabled"} · A1 ${lockA1?"locked":"editable"} · Changes ${accept?"accepted":"rejected"}'),
 NgSpreadsheet(value:sheet,canEdit:editable,readOnly:readOnly,onChanged:(v)=>setState((){proposals++;if(accept)sheet=v;})),
 Text('Accepted A1: ${sheet.raw("A1")} · Proposals: $proposals'),
]);
}
class NgPivotGridExample extends StatefulWidget { const NgPivotGridExample({super.key}); @override State<NgPivotGridExample> createState()=>_NgPivotGridExampleState(); }
class _NgPivotGridExampleState extends State<NgPivotGridExample> {
bool rowTotals=true,columnTotals=true,locked=false,average=false,empty=false;
String message='none';
List<NgPivotRecord> records=data(1);
static List<NgPivotRecord> data(int factor)=>[NgPivotRecord('a',{'Team':'A','Quarter':'Q1'},10.0*factor),NgPivotRecord('b',{'Team':'A','Quarter':'Q1'},30.0*factor),NgPivotRecord('c',{'Team':'B','Quarter':'Q2'},90.0*factor),NgPivotRecord('d',{'Team':'','Quarter':'Q1'},null)];
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 Wrap(spacing:8,runSpacing:8,children:[
  NgButton(onPressed:()=>setState(()=>rowTotals=!rowTotals),child:const Text('Toggle row totals')),
  NgButton(onPressed:()=>setState(()=>columnTotals=!columnTotals),child:const Text('Toggle column totals')),
  NgButton(onPressed:()=>setState(()=>locked=!locked),child:const Text('Toggle selection lock')),
  NgButton(onPressed:()=>setState(()=>average=!average),child:const Text('Toggle average')),
  NgButton(onPressed:()=>setState(()=>empty=!empty),child:const Text('Toggle empty data')),
  NgButton(onPressed:()=>setState(()=>records=data(2)),child:const Text('Update values')),
 ]),
 Text('Row totals ${rowTotals?"shown":"hidden"} · Column totals ${columnTotals?"shown":"hidden"} · Selection ${locked?"locked":"enabled"}'),
 NgPivotGrid(items:empty?const []:records,aggregate:average?NgAggregate.average:NgAggregate.sum,showRowTotals:rowTotals,showColumnTotals:columnTotals,selectionReadOnly:locked,
  valueFormatter:(v)=>v==null?'No value':'${v.toStringAsFixed(1)} credits',rowLabel:(v)=>v.isEmpty?'Unassigned':'Team $v',columnLabel:(v)=>'Period $v',totalText:'All',emptyText:'No matching deliveries',
  onCellSelected:(p)=>setState(()=>message='${p.row??"(total)"} / ${p.column??"(total)"} · ${p.records.length} records · IDs: ${p.records.map((r)=>r.id).join(",")}')),
 Text('Last drilldown: $message'),
]);
}
class NgEditorExample extends StatefulWidget { const NgEditorExample({super.key}); @override State<NgEditorExample> createState()=>_NgEditorExampleState(); }
class _NgEditorExampleState extends State<NgEditorExample> {
NgDocument document = NgDocument(blocks: const [
  NgDocumentBlock(text: 'Project plan', kind: NgBlockKind.heading1),
  NgDocumentBlock(text: 'Agree on requirements', kind: NgBlockKind.bullet),
  NgDocumentBlock(text: 'Review the result', kind: NgBlockKind.bullet, bold: true),
]);
bool accept = true, readOnly = false;
String saved = '';
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
  Wrap(spacing: 8, runSpacing: 8, children: [
    NgButton(onPressed: () => setState(() => accept = !accept), child: const Text('Toggle acceptance')),
    NgButton(onPressed: () => setState(() => readOnly = !readOnly), child: const Text('Toggle read-only')),
    NgButton(onPressed: () => setState(() => document = NgDocument(blocks: const [NgDocumentBlock(text: 'Imported brief'), NgDocumentBlock(text: 'Review imported content')])), child: const Text('Replace document')),
    NgButton(onPressed: () => setState(() => saved = document.toJson()), child: const Text('Save JSON')),
  ]),
  Text('Acceptance: ${accept ? "enabled" : "rejected"} · Accepted first block: ${document.blocks.first.text}'),
  NgEditor(label: 'Project description', value: document, readOnly: readOnly,
    onChanged: (v) => setState(() { if (accept) document = v; })),
  Text(saved),
]);
}
class NgDiagramExample extends StatefulWidget { const NgDiagramExample({super.key}); @override State<NgDiagramExample> createState()=>_NgDiagramExampleState(); }
class _NgDiagramExampleState extends State<NgDiagramExample> {
NgDiagramModel sample([double x=40,double y=100]) => NgDiagramModel(nodes: [
  NgDiagramNode('start', 'Start', x, y, shape: NgDiagramShape.ellipse),
  const NgDiagramNode('work', 'Processing', 360, 100),
], edges: const [NgDiagramEdge('next', 'start', 'work', text: 'Continue')]);
late NgDiagramModel graph=sample();
String? selectedNode, selectedEdge;
bool readOnly=false, selectionReadOnly=false, accept=true;
int moves=0;
Widget build(BuildContext context) => Column(crossAxisAlignment:CrossAxisAlignment.stretch, children:[
  Wrap(spacing:8,runSpacing:8,children:[
    NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Toggle move lock')),
    NgButton(onPressed:()=>setState(()=>selectionReadOnly=!selectionReadOnly),child:const Text('Toggle selection lock')),
    NgButton(onPressed:()=>setState(()=>accept=!accept),child:const Text('Toggle acceptance')),
    NgButton(onPressed:()=>setState(()=>graph=sample(120,140)),child:const Text('Replace graph')),
    NgButton(onPressed:()=>setState(()=>graph=graph.nodes.isEmpty?sample():NgDiagramModel()),child:const Text('Toggle empty graph')),
  ]),
  Text('Movement: ${readOnly?"locked":"enabled"} · Selection: ${selectionReadOnly?"locked":"enabled"} · Acceptance: ${accept?"enabled":"rejected"}'),
  Text('Start position: ${graph.nodes.isEmpty?"none":"${graph.nodes.first.x.round()}, ${graph.nodes.first.y.round()}"} · Move proposals: $moves'),
  NgDiagram(label: 'Process', value: graph, readOnly:readOnly, selectionReadOnly:selectionReadOnly,
    nodeLabel:(n)=>'Task ${n.text}',edgeLabel:(e)=>'Flow ${e.text}',emptyText:'Nothing to connect',
    onChanged: (v) => setState(() {moves++;if(accept)graph=v;}),
    selectedNodeId: selectedNode, selectedEdgeId: selectedEdge,
    onSelectedNodeIdChanged: (v) => setState(() => selectedNode = v),
    onSelectedEdgeIdChanged: (v) => setState(() => selectedEdge = v)),
  Text('Node: ${selectedNode??"none"} · Connection: ${selectedEdge??"none"}'),
]);
}
class NgPdfViewerExample extends StatefulWidget { const NgPdfViewerExample({super.key}); @override State<NgPdfViewerExample> createState()=>_NgPdfViewerExampleState(); }
class _NgPdfViewerExampleState extends State<NgPdfViewerExample> {
Widget build(BuildContext context) => const NgPdfViewer(
  label: 'Guide', source: 'samples/nextgen-guide.pdf', height: 720);
}
class NgMapExample extends StatefulWidget { const NgMapExample({super.key}); @override State<NgMapExample> createState()=>_NgMapExampleState(); }
class _NgMapExampleState extends State<NgMapExample> {
NgMapModel sample([bool updated=false]) => NgMapModel(markers:[
  NgMapMarker('office',updated?'Office updated':'Office',NgMapPoint(50.4501,30.5234)),
  NgMapMarker('depot','Depot',NgMapPoint(50.4501,30.5234)),
  NgMapMarker('park','Park',NgMapPoint(50.4466,30.5410)),
],paths:[NgMapPath('line','Delivery line',[NgMapPoint(50.4501,30.5234),NgMapPoint(50.4466,30.5410)])]);
late NgMapModel map=sample();
NgMapView view=NgMapView(latitude:50.4501,longitude:30.5234,zoom:13);
String? selected;
bool navigationLocked=false,selectionLocked=false,clickLocked=false,accept=true;
int selections=0,views=0,clicks=0;
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  Wrap(spacing:8,runSpacing:8,children:[
    NgButton(onPressed:()=>setState(()=>navigationLocked=!navigationLocked),child:const Text('Toggle navigation lock')),
    NgButton(onPressed:()=>setState(()=>selectionLocked=!selectionLocked),child:const Text('Toggle selection lock')),
    NgButton(onPressed:()=>setState(()=>clickLocked=!clickLocked),child:const Text('Toggle click lock')),
    NgButton(onPressed:()=>setState(()=>accept=!accept),child:const Text('Toggle acceptance')),
    NgButton(onPressed:()=>setState(()=>map=sample(true)),child:const Text('Replace objects')),
    NgButton(onPressed:()=>setState(()=>map=map.markers.isEmpty?sample():NgMapModel()),child:const Text('Toggle empty map')),
    NgButton(onPressed:()=>setState(()=>view=NgMapView(latitude:50.4501,longitude:30.5234,zoom:10)),child:const Text('Reset view')),
  ]),
  Text('Selected: ${selected??"none"} · View zoom: ${view.zoom} · Selection requests: $selections · View requests: $views · Map clicks: $clicks'),
  Text('Acceptance: ${accept?"enabled":"rejected"}'),
  NgMap(label:'Delivery map',value:map,view:view,selectedId:selected,clusterMarkers:true,
    navigationReadOnly:navigationLocked,selectionReadOnly:selectionLocked,mapClickReadOnly:clickLocked,emptyText:'No delivery points',
    onSelectedIdChanged:(id)=>setState((){selections++;if(accept)selected=id;}),
    onViewChanged:(next)=>setState((){views++;if(accept)view=next;}),
    onMapClick:(point)=>setState(()=>clicks++)),
]);
}
class NgPromptBoxExample extends StatefulWidget { const NgPromptBoxExample({super.key}); @override State<NgPromptBoxExample> createState()=>_NgPromptBoxExampleState(); }
class _NgPromptBoxExampleState extends State<NgPromptBoxExample> {
String prompt = '', result = '';
bool busy = false;
int revision = 0, limit = 80;
Future<void> submit(String text) async {
  final request = ++revision;
  setState(() => busy = true);
  await Future<void>.delayed(const Duration(milliseconds: 700));
  if (!mounted || request != revision) return;
  setState(() { result = 'Received prompt: $text'; busy = false; });
}
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
 NgButton(onPressed: () => setState(() => limit = limit == 80 ? 8 : 80), child: const Text('Toggle length limit')),
 NgPromptBox(label: 'Prompt', value: prompt, maxLength: limit,
  onChanged: (v) => setState(() => prompt = v), busy: busy,
  onSubmit: submit,
  onCancel: () => setState(() { revision++; busy = false; result = 'Cancelled'; })), Text(result)]);
}
class NgAIPromptExample extends StatefulWidget { const NgAIPromptExample({super.key}); @override State<NgAIPromptExample> createState()=>_NgAIPromptExampleState(); }
class _NgAIPromptExampleState extends State<NgAIPromptExample> {
String prompt = 'Draft a meeting agenda';
bool generationLocked = false, historyLocked = false, feedbackLocked = false;
int completed = 0, feedbackCount = 0;
Future<String> generate(String text, NgPromptCancellation cancellation) async {
  await Future<void>.delayed(const Duration(milliseconds: 1200));
  cancellation.throwIfCancelled();
  return 'Local example response to: $text'; // Connect your application service here.
}
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
 Wrap(spacing: 8, runSpacing: 8, children: [
  NgButton(onPressed: () => setState(() => generationLocked = !generationLocked), child: const Text('Toggle generation lock')),
  NgButton(onPressed: () => setState(() => historyLocked = !historyLocked), child: const Text('Toggle history lock')),
  NgButton(onPressed: () => setState(() => feedbackLocked = !feedbackLocked), child: const Text('Toggle feedback lock')),
 ]),
 NgAIPrompt(label: 'Assistant', value: prompt, onChanged: (v) => setState(() => prompt = v),
  generate: generate, generationReadOnly: generationLocked, historyReadOnly: historyLocked,
  feedbackReadOnly: feedbackLocked,
  suggestions: const ['Draft a meeting agenda', 'Suggest next steps'],
  onCompleted: (_) => setState(() => completed++), onFeedback: (_) => setState(() => feedbackCount++)),
 Text('Completed: $completed · Feedback events: $feedbackCount'),
]);
}
class NgStepperExample extends StatefulWidget { const NgStepperExample({super.key}); @override State<NgStepperExample> createState()=>_NgStepperExampleState(); }
class _NgStepperExampleState extends State<NgStepperExample> {
int current = 0; bool rtl = false; String mode = 'all';
final steps = const [NgStep('Draft',valid:true),NgStep('Details',optional:true,valid:false),NgStep('Publish')];
Widget build(BuildContext context) => Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  NgCheckBox(label:'Right-to-left',value:rtl,onChanged:(v)=>setState(()=>rtl=v)),
  DropdownButtonFormField<String>(initialValue:mode,decoration:const InputDecoration(labelText:'Step display'),
    items:const [DropdownMenuItem(value:'all',child:Text('Indicators and labels')),DropdownMenuItem(value:'labels',child:Text('Labels only')),DropdownMenuItem(value:'indicators',child:Text('Indicators only'))],
    onChanged:(v)=>setState(()=>mode=v!)),
  const SizedBox(height:16),
  NgStepper(label:'Publishing progress',items:steps,value:current,onChanged:(v)=>setState(()=>current=v),rtl:rtl,displayMode:mode,
    indicatorBuilder:(_,step)=>Icon(step.current?Icons.star:Icons.circle_outlined,size:20),
    labelBuilder:(_,step)=>Text(step.step.label,style:const TextStyle(fontWeight:FontWeight.bold))),
  Text('Selected step: ${current+1}'),
]);

}
class NgWizardExample extends StatefulWidget { const NgWizardExample({super.key}); @override State<NgWizardExample> createState()=>_NgWizardExampleState(); }
class _NgWizardExampleState extends State<NgWizardExample> {
int current = 0, reset = 0; bool blocked = false; String status = 'Not saved';
final name = TextEditingController(); final steps = const [NgStep('Contact'),NgStep('Review')];
@override void dispose(){name.dispose();super.dispose();}
Widget build(BuildContext context) => Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  NgCheckBox(label:'Block transitions',value:blocked,onChanged:(v)=>setState(()=>blocked=v)),
  NgButton(onPressed:()=>setState((){reset++;current=0;status='Not saved';}),child:const Text('Restart wizard')),
  NgWizard(label:'Application',items:steps,value:current,onChanged:(v)=>setState(()=>current=v),resetKey:reset,
    position:'start',beforeChange:(change)async=>!blocked,
    validateStep:(index)async=>index==0&&name.text.trim().isEmpty?'Enter your name.':null,
    onFinish:()async{setState(()=>status='Saved locally');},
    indicatorBuilder:(_,step)=>Icon(step.index==0?Icons.person_outline:Icons.check,size:20),
    contentBuilder:(_,index)=>index==0?NgTextBox(label:'Applicant name',controller:name):Text('Review: ${name.text}'),
    actionsBuilder:(_,a)=>Wrap(spacing:16,runSpacing:8,children:[
      NgButton(onPressed:a.canBack?a.back:null,child:const Text('Previous')),
      if(!a.isLast)NgButton(primary:true,onPressed:a.canNext?a.next:null,child:const Text('Continue'))
      else NgButton(primary:true,onPressed:a.canFinish?a.finish:null,child:const Text('Save application'))])),
  Text(status),
]);

}
class NgMenuExample extends StatefulWidget { const NgMenuExample({super.key}); @override State<NgMenuExample> createState()=>_NgMenuExampleState(); }
class _NgMenuExampleState extends State<NgMenuExample> {
bool keepOpen = false, rtl = false; String selected = 'none'; int count = 0;
final commands = [NgMenuItem('file','File',children:[
  NgMenuItem('new','New document'),NgMenuItem('exports','Export formats',separator:true),
  NgMenuItem('export','Export',children:[NgMenuItem('pdf','PDF'),NgMenuItem('csv','CSV')]),
  NgMenuItem('secret','Internal command',visible:false),NgMenuItem('delete','Delete',disabled:true)]),
  NgMenuItem('help','Help')];
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
  NgCheckBox(label:'Keep menu open',value:keepOpen,onChanged:(v)=>setState(()=>keepOpen=v)),
  NgCheckBox(label:'Right-to-left',value:rtl,onChanged:(v)=>setState(()=>rtl=v)),
  NgMenu(label:'Document commands',items:commands,selectedId:selected,rtl:rtl,closeOnClick:!keepOpen,
    leadingBuilder:(_,item)=>const Icon(Icons.description_outlined,size:18),
    itemBuilder:(_,item)=>Text(item.text,style:const TextStyle(fontWeight:FontWeight.bold)),
    onInvoke:(id)=>setState((){selected=id;count++;})),
  Text('Last command: $selected · Invocations: $count'),
]);

}
class NgDrawerExample extends StatefulWidget { const NgDrawerExample({super.key}); @override State<NgDrawerExample> createState()=>_NgDrawerExampleState(); }
class _NgDrawerExampleState extends State<NgDrawerExample> {
bool expanded = false, keepOpen = false, rtl = false; String? selected = 'overview';
final note = TextEditingController();
final items = const [NgOption('overview','Overview'),NgOption('divider','Workspace sections'),
  NgOption('reports','Reports'),NgOption('hidden','Internal'),NgOption('locked','Unavailable',disabled:true)];
@override void dispose(){note.dispose();super.dispose();}
Widget build(BuildContext context) => Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  NgCheckBox(label:'Keep drawer open',value:keepOpen,onChanged:(v)=>setState(()=>keepOpen=v)),
  NgCheckBox(label:'Right-to-left',value:rtl,onChanged:(v)=>setState(()=>rtl=v)),
  NgDrawer(label:'Workspace navigation',items:items,selectedId:selected,
    onSelectedIdChanged:(id)=>setState(()=>selected=id),expanded:expanded,
    onExpandedChanged:(v)=>setState(()=>expanded=v),position:'end',rtl:rtl,closeOnSelect:!keepOpen,
    isVisible:(item)=>item.value!='hidden',isSeparator:(item)=>item.value=='divider',
    header:const Text('Project workspace'),footer:const Text('Signed in as Morgan'),
    leadingBuilder:(_,item)=>const Icon(Icons.folder_outlined,size:18),
    itemBuilder:(_,item)=>Text(item.label,style:const TextStyle(fontWeight:FontWeight.bold)),
    child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Text('Current section: $selected'),NgTextBox(label:'Draft note',controller:note)])),
]);

}
class NgToggleButtonExample extends StatefulWidget { const NgToggleButtonExample({super.key}); @override State<NgToggleButtonExample> createState()=>_NgToggleButtonExampleState(); }
class _NgToggleButtonExampleState extends State<NgToggleButtonExample> {
bool selected = false;
int clicks = 0;
final toggleFocus = FocusNode();
@override
void dispose() { toggleFocus.dispose(); super.dispose(); }
Widget build(BuildContext context) => Column(children: [
  NgToggleButton(label: 'Preview outline', semanticIdentifier: 'preview-toggle', semanticHint: 'Toggle the preview outline.',
    value: selected, onChanged: (v) => setState(() => selected = v), onClick: () => setState(() => clicks++),
    focusNode: toggleFocus, size: 'lg', rounded: 'full', fillMode: 'outline', themeColor: 'success',
    leading: const Icon(Icons.star, size: 16), child: const Text('Preview outline')),
  TextButton(onPressed: toggleFocus.requestFocus, child: const Text('Focus preview')),
  Text('Selected: $selected. Activations: $clicks'),
]);

}
class NgButtonGroupExample extends StatefulWidget { const NgButtonGroupExample({super.key}); @override State<NgButtonGroupExample> createState()=>_NgButtonGroupExampleState(); }
class _NgButtonGroupExampleState extends State<NgButtonGroupExample> {
bool hideEmphasis = false;
List<String> selected = ['strong'];
String log = 'Ready';
final actions = const [NgOption('strong','Strong'),NgOption('emphasis','Emphasis'),NgOption('clear','Clear formatting')];
Widget build(BuildContext context) => Column(children: [
  NgCheckBox(label: 'Hide Emphasis', value: hideEmphasis, onChanged: (v) => setState(() => hideEmphasis=v)),
  NgButtonGroup(label: 'Formatting actions', items: actions, value: selected, multiple: true,
    isCommand: (item) => item.value=='clear', isVisible: (item) => !hideEmphasis || item.value!='emphasis',
    onChanged: (v) => setState(() { selected=v; log='changed:${v.join(",")}'; }),
    onClick: (id) => setState(() { log+=' | clicked:$id'; if(id=='clear')selected=[]; }),
    size: 'md', rounded: 'lg', fillMode: 'outline',
    itemAppearance: (item) => NgButtonAppearance(themeColor: item.value=='clear'?'info':null),
    leadingBuilder: (_) => const Icon(Icons.star, size:16), itemBuilder: (item) => Text(item.label)),
  Text('Selected: ${selected.join(",")}. $log'),
]);

}
class NgChipExample extends StatefulWidget { const NgChipExample({super.key}); @override State<NgChipExample> createState()=>_NgChipExampleState(); }
class _NgChipExampleState extends State<NgChipExample> {
bool selected = false, visible = true;
int clicks = 0;
Widget build(BuildContext context) => Wrap(spacing: 8, children: [
  NgChip(tabIndex: 0, semanticIdentifier: 'build-status', semanticLabel: 'Build succeeded — Open build activity', semanticHint: 'Opens the build activity summary.', label: 'Build succeeded', selectable: false, themeColor: 'success',
    fillMode: 'solid', size: 'lg', rounded: 'md', leading: const Icon(Icons.check, size: 18),
    child: const Text('Build succeeded'), onClick: () => setState(() => clicks++)),
  if (visible) NgChip(label: 'Favourite', value: selected,
    onChanged: (v) => setState(() => selected = v),
    removeIcon: const Icon(Icons.remove, size: 18),
    onRemove: () => setState(() => visible = false)),
  Text('Activity opened $clicks times'),
]);
}
class NgChipListExample extends StatefulWidget { const NgChipListExample({super.key}); @override State<NgChipListExample> createState()=>_NgChipListExampleState(); }
class _NgChipListExampleState extends State<NgChipListExample> {
List<({String id, String name, String owner, bool pinned, bool disabled})> records = [
  (id: 'ops', name: 'Operations', owner: 'Morgan', pinned: false, disabled: false),
  (id: 'finance', name: 'Finance', owner: 'Alex', pinned: true, disabled: false),
  (id: 'archive', name: 'Archive', owner: 'Sam', pinned: false, disabled: true),
];
List<String> selected = ['finance'];
final heading = 'Business topics';
final help = 'Choose topics for this workspace.';
bool rtl = false;
String message = 'Select a topic';
late var data = bind();
// Explicit record type keeps event handlers statically checked.
NgChipData<({String id, String name, String owner, bool pinned, bool disabled})> bind() => NgChipData(records, value: (x) => x.id, text: (x) => x.name,
  disabled: (x) => x.disabled, removable: (x) => !x.pinned,
  appearance: (x) => NgChipAppearance(themeColor: x.pinned ? 'success' : 'base'));
Widget build(BuildContext context) => Column(children: [
  Text(heading), Text(help),
  NgCheckBox(label: 'Right-to-left layout', value: rtl, onChanged: (v) => setState(() => rtl = v)),
  Directionality(textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
    child: NgChipList(gap: 'lg', tabIndex: 0, semanticIdentifier: 'business-topics', semanticHint: help, label: heading, items: data.items, value: selected,
    multiple: true, canRemove: data.canRemove, itemAppearance: data.getAppearance,
    onChanged: (v) => setState(() => selected = v),
    onClick: (id) => setState(() => message = 'Owner: ${data.getItem(id).owner}'),
    onRemove: (id) => setState(() {
      message = 'Removed ${data.getItem(id).name}';
      records = records.where((x) => x.id != id).toList();
      selected = selected.where((x) => x != id).toList();
      data = bind();
    }))),
  Text(message),
]);
}

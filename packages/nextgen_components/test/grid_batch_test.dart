import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
 testWidgets('batch consolidation, bounds, retry, locking and invalidation', (t) async {
  final rows=['Alpha','Beta'];
  var locked=false,invalid=false,version=0,calls=0;
  var pending=Completer<String?>();
  List<NgGridChange>? captured;
  late StateSetter refresh;
  await t.binding.setSurfaceSize(const Size(1400,1800));
  addTearDown(()=>t.binding.setSurfaceSize(null));
  await t.pumpWidget(MaterialApp(home:Scaffold(body:StatefulBuilder(builder:(context,setState){
   refresh=setState;
   return SingleChildScrollView(child:NgDataGrid<String>(items:rows,rowId:(r)=>r,dataVersion:version,
    columns:[NgDataColumn('name','Name',(r)=>r)],editing:NgGridEditing<String>(
     maxPendingChanges:2,fields:[NgGridEditField('name','Name',required:true)],draft:(r)=>{'name':r??''},
     canUpdate:(_)=>!locked,canDelete:(_)=>!locked,validate:(_)=>invalid?'Invalid':null,
     commit:(_,_,_)=>throw StateError('Single commit called'),
     commitBatch:(changes){calls++;captured=changes;return pending.future;},
    )));
  }))));
  Future<void> tap(String name,{int index=0}) async {final f=find.widgetWithText(TextButton,name).at(index);await t.ensureVisible(f);await t.tap(f);await t.pump();}
  Future<void> create(String value) async {await tap('Create record');await t.enterText(find.byType(TextFormField),value);await tap('Apply to batch');}
  await create('');expect(find.text('Complete all required fields.'),findsOneWidget);await tap('Cancel');
  await tap('Edit');await t.enterText(find.byType(TextFormField),'Changed');await tap('Apply to batch');
  expect(find.text('Pending changes (1)'),findsOneWidget);expect(calls,0);expect(rows,['Alpha','Beta']);
  await tap('Edit');expect(find.widgetWithText(TextFormField,'Changed'),findsOneWidget);await t.enterText(find.byType(TextFormField),'Revised');await tap('Apply to batch');
  expect(find.text('Pending changes (1)'),findsOneWidget);
  await tap('Delete');await tap('Cancel');expect(find.text('Name: Revised'),findsOneWidget);
  await create('New');expect(find.text('Pending changes (2)'),findsOneWidget);
  await create('Overflow');expect(find.text('The pending change limit has been reached.'),findsOneWidget);await tap('Cancel');
  refresh(()=>locked=true);await t.pump();await tap('Save changes');expect(calls,0);expect(find.text('A pending record is missing or cannot be changed. Undo it and retry.'),findsOneWidget);
  refresh((){locked=false;invalid=true;});await t.pump();await tap('Save changes');expect(find.text('Invalid'),findsOneWidget);expect(calls,0);
  refresh((){invalid=false;rows.remove('Alpha');});await t.pump();await tap('Save changes');expect(calls,0);
  refresh(()=>rows.insert(0,'Alpha'));await t.pump();await tap('Save changes');expect(calls,1);
  expect(captured!.first.values,{'name':'Revised'});expect(()=>captured!.clear(),throwsUnsupportedError);expect(()=>captured!.first.values['name']='bad',throwsUnsupportedError);
  expect(t.widget<TextButton>(find.widgetWithText(TextButton,'Discard all')).onPressed,isNull);
  expect(t.widget<TextButton>(find.widgetWithText(TextButton,'Create record')).onPressed,isNull);
  pending.complete('Conflict');await t.pump();expect(find.text('Conflict'),findsOneWidget);expect(find.text('Pending changes (2)'),findsOneWidget);
  final key=captured!.last.key;
  await tap('Edit',index:3);await t.enterText(find.byType(TextFormField),'New revised');await tap('Apply to batch');
  await tap('Undo change');expect(find.text('Pending changes (1)'),findsOneWidget);
  pending=Completer();await tap('Save changes');expect(captured!.single.key,key);expect(captured!.single.values['name'],'New revised');pending.complete(null);await t.pump();expect(find.text('Pending changes (1)'),findsNothing);
  await tap('Edit');await tap('Apply to batch');await tap('Delete');await tap('Apply to batch');
  pending=Completer();await tap('Save changes');expect(captured!.single.operation,NgGridEditOperation.delete);expect(captured!.single.values,isEmpty);pending.completeError(StateError('PRIVATE'));await t.pump();expect(find.text('Unable to save changes. Please retry.'),findsOneWidget);
  pending=Completer();await tap('Save changes');refresh(()=>version++);await t.pump();pending.complete('Stale');await t.pump();expect(find.text('Stale'),findsNothing);expect(find.text('Pending changes (1)'),findsNothing);
  await create('Discard');await tap('Discard all');expect(find.text('Pending changes (1)'),findsNothing);
 });
 testWidgets('remote queued records can be reviewed off page and refresh once', (t) async {
  final rows=['A','B'];var reads=0,writes=0;List<NgGridChange>? captured;
  Future<NgDataResult<String>> read(NgDataRequest request) async {reads++;return NgDataResult(rows.skip(request.page-1).take(1).toList(),2);}
  await t.binding.setSurfaceSize(const Size(1200,1500));addTearDown(()=>t.binding.setSurfaceSize(null));
  await t.pumpWidget(MaterialApp(home:Scaffold(body:SingleChildScrollView(child:NgDataGrid<String>(readData:read,initialPageSize:1,rowId:(r)=>r,columns:[NgDataColumn('name','Name',(r)=>r)],editing:NgGridEditing<String>(fields:[NgGridEditField('name','Name',required:true)],draft:(r)=>{'name':r??''},commit:(_,_,_)=>throw StateError('single'),commitBatch:(changes)async{writes++;captured=changes;return null;}))))));
  await t.pumpAndSettle();
  await t.tap(find.widgetWithText(TextButton,'Edit'));await t.pump();await t.enterText(find.byType(TextFormField),'First');await t.tap(find.text('Apply to batch'));await t.pump();
  await t.tap(find.byTooltip('Next page'));await t.pumpAndSettle();
  await t.tap(find.widgetWithText(TextButton,'Edit').last);await t.pump();await t.enterText(find.byType(TextFormField),'Revised');await t.tap(find.text('Apply to batch'));await t.pump();
  await t.tap(find.text('Save changes'));await t.pumpAndSettle();expect(writes,1);expect(reads,3);expect(captured!.single.id,'A');expect(captured!.single.values,{'name':'Revised'});expect(find.text('Pending changes (1)'),findsNothing);
 });

}

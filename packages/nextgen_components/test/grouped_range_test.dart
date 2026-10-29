import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';
import 'range_data_test.dart' show host, scrollEnd;
final columns=[NgDataColumn<int>('id','Record',(i)=>'row $i')];
final keys=<String Function(int)>[(i)=>i<500?'North':'South',(i)=>i%2==0?'Even':'Odd'];
NgGroupedRangeResult<int> result(NgGroupedRangeRequest q,[int count=1000])=>NgGroupedRange.window(List.generate(count,(i)=>i),keys,[],q);
void main(){
 test('every boundary supports ancestors, collapsed headers, and exact windows',(){
  for(final collapsed in <List<String>>[[],[ngGroupId(['North'])],[ngGroupId(['North','Even'])],[ngGroupId(['North']),ngGroupId(['South'])],['unknown']]){
   for(var start=0;start<37;start++)for(final count in [1,2,5,32]){
    final q=NgGroupedRangeRequest(start,count,'',[],['region','kind'],collapsed);
    final answer=NgGroupedRange.window<int>(List.generate(30,(i)=>i),[(i)=>i<15?'North':'South',(i)=>i%2==0?'Even':'Odd'],<NgGroupAggregate<int>>[],q);
    expect(NgGroupedRange.validate(answer,q,(i)=>'$i').entries.length,(answer.total-start).clamp(0,count));
   }
  }
 });
 test('malformed offsets, totals, metadata, collapse and identities are rejected',(){
  final q=NgGroupedRangeRequest(0,100,'',[],['region','kind'],[]);
  final a=result(q,30);
  for(final bad in [
   NgGroupedRangeResult(1,a.total,a.recordTotal,a.entries,a.groups),
   NgGroupedRangeResult(0,100001,a.recordTotal,a.entries,a.groups),
   NgGroupedRangeResult(0,a.total,a.recordTotal,a.entries.skip(1).toList(),a.groups),
   NgGroupedRangeResult(0,a.total,a.recordTotal,a.entries,a.groups.skip(1).toList()),
   NgGroupedRangeResult(0,a.total,a.recordTotal,a.entries,[...a.groups,a.groups.first]),
  ]){expect(()=>NgGroupedRange.validate(bad,q,(i)=>'$i'),throwsArgumentError);}
  expect(()=>NgGroupedRange.validate(a,q,(_)=>'duplicate'),throwsArgumentError);
  expect(()=>NgGroupedRange.validate(a,NgGroupedRangeRequest(0,100,'',[],['region','kind'],[ngGroupId(['North'])]),(i)=>'$i'),throwsArgumentError);
 });
 testWidgets('collapse acceptance reloads, rejection does not; windows stay bounded and selection survives', (t)async{
  var collapsed=<String>{},selected=<String>{'hidden'};var accept=false;
  final requests=<NgGroupedRangeRequest>[];
  Future<NgGroupedRangeResult<int>> read(NgGroupedRangeRequest q)async{requests.add(q);return result(q);}
  await t.pumpWidget(host(StatefulBuilder(builder:(c,set)=>NgDataGrid<int>(readGroupedRange:read,virtualize:true,viewportHeight:192,columns:columns,rowId:(i)=>'$i',remoteGroupKeys:const ['region','kind'],collapsibleGroups:true,collapsedGroups:collapsed,onCollapsedGroupsChanged:(v)=>set((){if(accept)collapsed=v;}),selectedIds:selected,onSelectionChanged:(v)=>set(()=>selected=v)))));
  await t.pumpAndSettle();expect(find.text('▾ North (500)'),findsOneWidget);
  final before=requests.length;
  await t.tap(find.text('▾ North (500)'));await t.pumpAndSettle();expect(requests.length,before);
  accept=true;
  await t.tap(find.byType(Checkbox).at(1));await t.pumpAndSettle();expect(selected,contains('0'));
  await t.tap(find.text('▾ North (500)'));await t.pumpAndSettle();expect(collapsed,{ngGroupId(['North'])});expect(requests.last.collapsedGroups,contains(ngGroupId(['North'])));
  expect(find.text('row 0'),findsNothing);expect(selected,containsAll(['hidden','0']));
  await scrollEnd(t);expect(find.text('row 999'),findsOneWidget);expect(requests.last.startIndex,greaterThan(300));expect(requests.every((q)=>q.count<=512),isTrue);expect(find.byType(NgPager),findsNothing);
 });
 testWidgets('only data records enter window selection and export', (t)async{
  NgGridExportFile? exported;var selected=<String>{};
  Future<NgGroupedRangeResult<int>> read(NgGroupedRangeRequest q)async=>result(q,10);
  await t.pumpWidget(host(StatefulBuilder(builder:(c,set)=>NgDataGrid<int>(readGroupedRange:read,virtualize:true,viewportHeight:192,columns:columns,rowId:(i)=>'$i',remoteGroupKeys:const ['region','kind'],selectedIds:selected,onSelectionChanged:(v)=>set(()=>selected=v),export:NgGridExport(onExport:(f)async{exported=f;})))));
  await t.pumpAndSettle();await t.tap(find.byType(Checkbox).first);await t.pumpAndSettle();expect(selected.length,10);
  await t.tap(find.text('Prepare export'));await t.pumpAndSettle();expect(exported!.rowCount,10);
 });
 testWidgets('stale failure cannot replace a new query; malformed windows retry', (t)async{
  final pending=<({NgGroupedRangeRequest q,Completer<NgGroupedRangeResult<int>> done})>[];
  Future<NgGroupedRangeResult<int>> read(NgGroupedRangeRequest q){final done=Completer<NgGroupedRangeResult<int>>();pending.add((q:q,done:done));return done.future;}
  await t.pumpWidget(host(NgDataGrid<int>(readGroupedRange:read,virtualize:true,viewportHeight:192,columns:columns,rowId:(i)=>'$i',remoteGroupKeys:const ['region','kind'])));
  await t.pump();await t.enterText(find.byType(TextField),'new');await t.pump();
  pending.last.done.complete(result(pending.last.q,10));await t.pumpAndSettle();pending.first.done.completeError(StateError('obsolete private error'));await t.pumpAndSettle();expect(find.text('Retry'),findsNothing);
  await t.enterText(find.byType(TextField),'bad');await t.pump();final a=result(pending.last.q,10);pending.last.done.complete(NgGroupedRangeResult(1,a.total,a.recordTotal,a.entries,a.groups));await t.pumpAndSettle();expect(find.text('row 0'),findsNothing);
  await t.tap(find.text('Retry'));await t.pump();pending.last.done.complete(result(pending.last.q,10));await t.pumpAndSettle();expect(find.text('row 0'),findsOneWidget);
 });
 testWidgets('server shrink corrects a grouped window', (t)async{
  var count=1000;
  Future<NgGroupedRangeResult<int>> read(NgGroupedRangeRequest q)async=>result(q,count);
  await t.pumpWidget(host(NgDataGrid<int>(readGroupedRange:read,virtualize:true,viewportHeight:192,columns:columns,rowId:(i)=>'$i',remoteGroupKeys:const ['region','kind'])));
  await t.pumpAndSettle();count=10;await scrollEnd(t);expect(find.textContaining('/ 13'),findsOneWidget);expect(t.takeException(),isNull);
 });
}

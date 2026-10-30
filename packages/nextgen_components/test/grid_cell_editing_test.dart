import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets('cell draft, custom editor, conflict, retry and stale callbacks', (t) async {
    final rows = [(id:'a', name:'Alpha', quantity:'12')];
    final writes = <Map<String,String>>[];
    var locked=false;
    Completer<String?>? pending;
    NgGridEditorContext? captured;
    late StateSetter refresh;
    await t.pumpWidget(MaterialApp(home:Scaffold(body:StatefulBuilder(builder:(context,setState){
      refresh=setState;
      return SingleChildScrollView(child:NgDataGrid<( {String id,String name,String quantity})>(
        items:rows,rowId:(r)=>r.id,
        columns:[NgDataColumn('name','Name',(r)=>r.name),NgDataColumn('quantity','Quantity',(r)=>r.quantity)],
        editing:NgGridEditing(cellEditing:true,readOnly:locked,
          fields:[NgGridEditField('name','Name',required:true),NgGridEditField('quantity','Quantity',required:true)],
          draft:(r)=>{'name':r?.name??'', 'quantity':r?.quantity??''},
          editorBuilder:(context,editor){captured=editor;return TextFormField(key:ValueKey((editor.field.key,editor.disabled)),initialValue:editor.value,enabled:!editor.disabled,decoration:InputDecoration(labelText:editor.field.label),onChanged:editor.setValue);},
          commit:(op,id,values){writes.add(values);pending=Completer<String?>();return pending!.future;},
        ),
      ));
    }))));
    // Row has two cell actions followed by the existing full-record action.
    await t.tap(find.widgetWithText(TextButton,'Edit').first);await t.pump();
    expect(find.byType(TextFormField),findsOneWidget);
    final obsolete=captured!;
    await t.enterText(find.byType(TextFormField),'');
    await t.tap(find.text('Save'));await t.pump();
    expect(find.text('Complete all required fields.'),findsOneWidget);expect(writes,isEmpty);
    await t.enterText(find.byType(TextFormField),'Beta');
    await t.tap(find.text('Save'));await t.pump();
    expect(writes.single,{'name':'Beta','quantity':'12'});expect(rows.single.name,'Alpha');
    obsolete.setValue('late');await t.pump();expect(writes.single['name'],'Beta');
    pending!.complete('Conflict');await t.pump();
    expect(find.text('Conflict'),findsOneWidget);expect(find.byType(TextFormField),findsOneWidget);
    refresh(()=>locked=true);await t.pump();captured!.setValue('blocked');await t.pump();
    refresh(()=>locked=false);await t.pump();
    await t.tap(find.text('Save'));await t.pump();expect(writes.last['name'],'Beta');
    pending!.complete(null);await t.pump();expect(find.byType(TextFormField),findsNothing);
    await t.tap(find.widgetWithText(TextButton,'Edit').first);await t.pump();
    obsolete.setValue('stale');await t.pump();
    await t.tap(find.text('Save'));await t.pump();expect(writes.last['name'],'Alpha');
    pending!.complete('Retry');await t.pump();
    await t.tap(find.text('Cancel'));await t.pump();expect(find.byType(TextFormField),findsNothing);
  });
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets('CRUD, isolated drafts, required validation and cancel delete', (
    t,
  ) async {
    final rows = ['Alpha'];
    final draft = {'name': ''};
    final writes = <NgGridEditOperation>[];
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NgDataGrid<String>(
              items: rows,
              columns: [NgDataColumn('n', 'Name', (r) => r)],
              rowId: (r) => r,
              editing: NgGridEditing(
                fields: [
                  NgGridEditField('name', 'Record name', required: true),
                ],
                draft: (r) => r == null ? draft : {'name': r},
                validate: (v) => v['name'] == 'bad' ? 'Invalid name' : null,
                commit: (op, id, v) async {
                  expect(() => v['name'] = 'mutate', throwsUnsupportedError);
                  writes.add(op);
                  if (op != NgGridEditOperation.create) rows.remove(id);
                  if (op != NgGridEditOperation.delete) rows.add(v['name']!);
                  return null;
                },
              ),
            ),
          ),
        ),
      ),
    );
    Future<void> click(String label, {bool last = false}) async {
      final f = last
          ? find.widgetWithText(TextButton, label).last
          : find.widgetWithText(TextButton, label).first;
      await t.ensureVisible(f);
      await t.tap(f);
      await t.pumpAndSettle();
    }

    await click('Create record');
    await t.enterText(find.byType(TextFormField), 'Discarded');
    await click('Cancel');
    expect(rows, ['Alpha']);
    expect(draft['name'], '');
    expect(writes, isEmpty);
    await click('Create record');
    await click('Save');
    expect(find.text('Complete all required fields.'), findsOneWidget);
    expect(writes, isEmpty);
    await t.enterText(find.byType(TextFormField), 'bad');
    await click('Save');
    expect(find.text('Invalid name'), findsOneWidget);
    await t.enterText(find.byType(TextFormField), 'Beta');
    await click('Save');
    expect(rows, ['Alpha', 'Beta']);
    await click('Edit');
    await t.enterText(find.byType(TextFormField), 'Updated');
    await click('Save');
    expect(rows, ['Beta', 'Updated']);
    await click('Delete');
    expect(find.textContaining('Delete this record?'), findsOneWidget);
    await click('Cancel');
    expect(rows.length, 2);
    await click('Delete');
    await click('Delete', last: true);
    expect(rows, ['Updated']);
    expect(writes, [
      NgGridEditOperation.create,
      NgGridEditOperation.update,
      NgGridEditOperation.delete,
    ]);
  });
  testWidgets(
    'single flight, generic failure, retained draft, server validation, retry',
    (t) async {
      var pending = Completer<String?>();
      var calls = 0;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NgDataGrid<String>(
              columns: [NgDataColumn('n', 'Name', (r) => r)],
              rowId: (r) => r,
              editing: NgGridEditing(
                fields: [NgGridEditField('name', 'Name')],
                draft: (_) => {},
                commit: (_, __, v) {
                  calls++;
                  expect(v['name'], 'Retained');
                  return pending.future;
                },
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('Create record'));
      await t.pump();
      await t.enterText(find.byType(TextFormField), 'Retained');
      await t.tap(find.text('Save'));
      await t.pump();
      expect(
        t.widget<TextButton>(find.widgetWithText(TextButton, 'Save')).onPressed,
        isNull,
      );
      expect(
        t
            .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'))
            .onPressed,
        isNull,
      );
      expect(calls, 1);
      pending.completeError(StateError('PRIVATE'));
      await t.pumpAndSettle();
      expect(
        find.text('Unable to save changes. Please retry.'),
        findsOneWidget,
      );
      expect(find.textContaining('PRIVATE'), findsNothing);
      expect(
        t.widget<TextFormField>(find.byType(TextFormField)).initialValue,
        'Retained',
      );
      pending = Completer<String?>();
      await t.tap(find.text('Save'));
      await t.pump();
      pending.complete('Conflict');
      await t.pumpAndSettle();
      expect(find.text('Conflict'), findsOneWidget);
      pending = Completer<String?>();
      await t.tap(find.text('Save'));
      await t.pump();
      pending.complete(null);
      await t.pumpAndSettle();
      expect(find.byType(TextFormField), findsNothing);
      expect(calls, 3);
    },
  );
  testWidgets(
    'permissions, removed records and invalidated source reject stale actions',
    (t) async {
      var locked = false, version = 0, calls = 0;
      var rows = ['Alpha'];
      late StateSetter update;
      final pending = Completer<String?>();
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, set) {
                update = set;
                return NgDataGrid<String>(
                  items: rows,
                  dataVersion: version,
                  columns: [NgDataColumn('n', 'Name', (r) => r)],
                  rowId: (r) => r,
                  editing: NgGridEditing(
                    fields: [NgGridEditField('n', 'Name')],
                    draft: (r) => {'n': r ?? ''},
                    readOnly: locked,
                    canDelete: (_) => false,
                    commit: (_, __, ___) {
                      calls++;
                      return pending.future;
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );
      expect(
        t
            .widget<TextButton>(find.widgetWithText(TextButton, 'Delete'))
            .onPressed,
        isNull,
      );
      final staleEdit = t
          .widget<TextButton>(find.widgetWithText(TextButton, 'Edit'))
          .onPressed!;
      update(() => locked = true);
      await t.pump();
      staleEdit();
      await t.pump();
      expect(find.byType(TextFormField), findsNothing);
      update(() => locked = false);
      await t.pump();
      await t.tap(find.text('Edit'));
      await t.pump();
      final staleSave = t
          .widget<TextButton>(find.widgetWithText(TextButton, 'Save'))
          .onPressed!;
      update(() => rows = []);
      await t.pump();
      staleSave();
      await t.pump();
      expect(calls, 0);
      await t.tap(find.text('Cancel'));
      await t.pump();
      await t.tap(find.text('Create record'));
      await t.pump();
      await t.tap(find.text('Save'));
      await t.pump();
      expect(calls, 1);
      update(() => version++);
      await t.pump();
      expect(find.byType(TextFormField), findsNothing);
      pending.complete('Obsolete');
      await t.pumpAndSettle();
      expect(find.text('Obsolete'), findsNothing);
    },
  );
  testWidgets('remote deletion reloads and clamps the last page', (t) async {
    final rows = ['A', 'B'];
    var reads = 0;
    Future<NgDataResult<String>> read(NgDataRequest r) async {
      reads++;
      return NgDataResult(
        rows.skip((r.page - 1) * r.pageSize).take(r.pageSize).toList(),
        rows.length,
      );
    }

    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgDataGrid<String>(
            readData: read,
            initialPageSize: 1,
            columns: [NgDataColumn('n', 'Name', (r) => r)],
            rowId: (r) => r,
            editing: NgGridEditing(
              fields: [NgGridEditField('n', 'Name')],
              draft: (r) => {'n': r ?? ''},
              commit: (op, id, v) async {
                rows.remove(id);
                return null;
              },
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Next page'));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(TextButton, 'Delete'));
    await t.pump();
    await t.tap(find.widgetWithText(TextButton, 'Delete').last);
    await t.pumpAndSettle();
    expect(rows, ['A']);
    expect(reads, 4);
    expect(find.text('A'), findsOneWidget);
  });
}

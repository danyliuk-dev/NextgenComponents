part of 'data.dart';

class NgGridEditorContext {
  final NgGridEditField field;
  final String value;
  final bool disabled;
  final ValueChanged<String> setValue;
  const NgGridEditorContext(this.field, this.value, this.disabled, this.setValue);
}

class NgGridChange {
  final String key;
  final NgGridEditOperation operation;
  final String? id;
  final Map<String,String> values;
  NgGridChange(this.key, this.operation, this.id, Map<String,String> values)
    : values = Map.unmodifiable(values);
}
class _NgPendingChange<T> {
  final NgGridChange change;
  final T? original;
  const _NgPendingChange(this.change, this.original);
}

enum NgGridEditOperation { create, update, delete }

class NgGridEditField {
  final String key, label;
  final bool required;
  const NgGridEditField(this.key, this.label, {this.required = false});
}

/// Return a safe application validation message, or null on successful commit.
class NgGridEditing<T> {
  final List<NgGridEditField> fields;
  final Map<String, String> Function(T?) draft;
  final Future<String?> Function(
    NgGridEditOperation,
    String?,
    Map<String, String>,
  )
  commit;
  final String? Function(Map<String, String>)? validate;
  final bool Function(T)? canUpdate, canDelete;
  final Future<String?> Function(List<NgGridChange>)? commitBatch;
  final int maxPendingChanges;
  final String pendingText, stageText, saveBatchText, discardText, undoText, batchLimitText, batchConflictText;
  final bool allowCreate, readOnly, cellEditing;
  final Widget Function(BuildContext, NgGridEditorContext)? editorBuilder;
  final String createText,
      updateText,
      deleteText,
      saveText,
      cancelText,
      confirmDeleteText,
      requiredText,
      errorText,
      savingText;
  const NgGridEditing({
    required this.fields,
    required this.draft,
    required this.commit,
    this.validate,
    this.canUpdate,
    this.canDelete,
    this.commitBatch,
    this.maxPendingChanges = 100,
    this.pendingText = 'Pending changes',
    this.stageText = 'Apply to batch',
    this.saveBatchText = 'Save changes',
    this.discardText = 'Discard all',
    this.undoText = 'Undo change',
    this.batchLimitText = 'The pending change limit has been reached.',
    this.batchConflictText = 'A pending record is missing or cannot be changed. Undo it and retry.',
    this.cellEditing = false,
    this.editorBuilder,
    this.allowCreate = true,
    this.readOnly = false,
    this.createText = 'Create record',
    this.updateText = 'Edit',
    this.deleteText = 'Delete',
    this.saveText = 'Save',
    this.cancelText = 'Cancel',
    this.confirmDeleteText = 'Delete this record?',
    this.requiredText = 'Complete all required fields.',
    this.errorText = 'Unable to save changes. Please retry.',
    this.savingText = 'Saving changes…',
  });
  void check() {
    if (maxPendingChanges < 1 || maxPendingChanges > 500) throw ArgumentError('Pending change limit must be between 1 and 500.');
    if (fields.isEmpty ||
        fields.any((f) => f.key.trim().isEmpty) ||
        fields.map((f) => f.key).toSet().length != fields.length) {
      throw ArgumentError('Editor fields must have unique nonempty keys.');
    }
  }
}

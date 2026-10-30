# Grid editing

Available in Blazor and Flutter Web since 0.67. See the [runnable Grid example](NgDataGrid.md) for both complete implementations.

## Connect your records

Pass `Editing` / `editing` an `NgGridEditing<T>` configuration. Without it, the Grid remains a read-only data view with optional application row actions. Editing adds Create record and per-record Edit/Delete buttons, alongside existing row actions. A single inline editor appears below the table; it is not a modal dialog. Delete opens a confirmation panel before calling persistence.

| Configuration | Contract |
|---|---|
| Fields / fields | Nonempty list of `NgGridEditField(key, label, required)`; keys must be nonblank and unique. Fields are text inputs. |
| Draft / draft | Receives the current record for update, or null/default for create. Returns field-key/string-value pairs. Keep this callback pure. |
| Validate / validate | Optional synchronous validation over a read-only snapshot; return null to accept or a safe message to reject. Skipped for delete. |
| Commit / commit | Asynchronous callback `(operation, id, values[, cancellationToken])`; operation is Create/Update/Delete in C#, create/update/delete in Dart. ID is null for create and the original stable row ID otherwise. Return null only after persistence succeeds; return a safe validation/conflict message to keep the draft open. |
| AllowCreate / allowCreate | Defaults true. |
| ReadOnly / readOnly | Defaults false; blocks starting edits and submitting, including previously captured actions. Cancel remains available while idle. |
| CanUpdate / canUpdate, CanDelete / canDelete | Optional current-record predicates, true by default. UI controls only; authorize again in persistence. |

The Grid copies the dictionary/map returned by Draft. Editing changes only this private string draft; it never mutates the input record or collection. Commit receives a read-only copy, so subsequent edits cannot change an in-flight request. Create must allocate a unique stable ID in the application. Update should preserve the original ID. Delete receives an empty values map. C# value-type records receive default(T) for create; use a reference/nullable model when that distinction matters.

Required checks trim whitespace without rewriting input. Custom validation can parse numbers, dates and cross-field constraints. Validation runs before Commit and never runs for delete. All messages render as plain text. Thrown exceptions become the generic ErrorText; exception details are not displayed. Return only messages safe for end users. An empty string is still an error; success is specifically null.

## Persistence and refresh

For local Items, Commit updates the application collection and notifies the parent as usual. For remote ReadData or ReadGroupedData, Commit performs the write and the Grid rereads the current query after success. Filtering, sorting and page size are retained. Group counts/summaries are recomputed by the local pipeline or server. If the last page disappears, the existing read pipeline clamps paging and fetches the corrected page. A created or updated record can legitimately be hidden by the current search, sort order or collapsed group; success does not jump to it.

The editor closes after a successful write, even when the subsequent read fails. In that case use the Grid's read Retry action: it retries the read, not the completed write. Selection and collapsed paths remain application-owned. Prune deleted selection IDs in your application if needed; the Grid does not silently normalize them.

While Commit is pending, editor inputs, Save/Delete confirmation, Cancel and starting another edit are disabled. A second invocation cannot submit another write. Returned validation messages and failures retain the draft for correction, retry or cancel. Search/paging remain available: a remote edit whose row is no longer loaded cannot be submitted until that row is loaded again. Local edits may be submitted even if a filter hides their record, provided it still exists and is permitted. Removing a record or locking permissions disables submission.

Changing DataVersion or replacing a read adapter discards the draft and invalidates pending completions. Removing Editing does the same. Use DataVersion when switching storage, changing editor field schemas or replacing persistence rules. Rebuilding a configuration with the same logical rules is supported without losing the draft. Blazor also cancels the pending write token; Flutter ignores obsolete futures. Disposal ignores subsequent results. Cancellation/invalidation cannot roll back a write already accepted by a server.

## Application responsibilities

The component supplies a complete single-record editing workflow, not a database transaction engine. Persistence owns authorization, uniqueness, conversion, concurrency/version checks and storage. Use an idempotency key or equivalent backend contract when a failed network response leaves write success uncertain; clicking retry cannot guarantee exactly-once delivery. A version conflict should return a safe message and preserve the draft until the user cancels/reloads or your application resolves it.

The gallery uses disposable in-memory records scoped to its page; reloading resets them. Both demos exercise delayed persistence, failures and duplicate-name validation. The grouped HTTP fixture remains read-only. No production records or public sites are modified by this demo.

## Presentation and localization

CreateText, UpdateText, DeleteText, SaveText, CancelText, ConfirmDeleteText, RequiredText, ErrorText and SavingText (lower camel case in Flutter) localize every built-in editor message/action. Field labels come from descriptors. Row action accessible names combine the translated action and stable ID. The form uses standard keyboard text inputs/buttons and live error/status announcements. Required fields expose ARIA required in Blazor; Flutter marks them visually with an asterisk. No physical screen-reader or native/mobile certification is claimed.

## Cell editing and custom editors

Enable `CellEditing` / `cellEditing` on the editing configuration. Each column whose key matches a field key gains a labelled Edit button. It opens that field inside the cell; Save, Cancel and error/status messages remain in the panel below the table. Only one record or cell can be edited at a time. Create and the row Edit action still open the full-record panel. Unmatched columns remain display-only.

The component takes a full draft snapshot even for a cell edit. Only the active field changes; required checks and custom validation still inspect all fields, and Commit receives the entire record draft. A cross-field error can require cancelling and using the row editor. The component does not implement patch persistence or merge concurrent server edits. Use application version checks to detect conflicts.

`EditorTemplate` / `editorBuilder` optionally replaces each default text input. Its `NgGridEditorContext` contains Field/field, Value/value, Disabled/disabled and SetValue/setValue. Use the field key to choose a numeric input, select, date editor or other control. Values remain strings; parsing and storage belong to the application. Supply a label and honor Disabled. The callback additionally rejects changes while saving, after permissions are revoked, after cancellation or from an obsolete edit session. Custom controls own their keyboard behavior and focus. Saving and cancellation use explicit buttons; typing Enter or leaving a cell does not automatically persist it.

Search, sorting, paging and virtualization can move the active cell out of view. The draft and action panel remain available; return to the row to edit the field again, or cancel. Remote submission requires the record to remain in the loaded window. Fixed row heights still apply: custom editors must fit the configured row height. Cell editing does not implement spreadsheet arrow-key navigation, variable row heights, file uploads or database providers.

The runnable editable inventory uses custom text/numeric controls, protected rows, delayed failures and retries on both Web platforms. The default text editor remains available when no custom builder is provided.

## Batch editing

Since 0.73, supplying `CommitBatch` / `commitBatch` enables a bounded queue of edits. The existing `Commit` / `commit` remains required for configuration compatibility but is never called in batch mode. The runnable inventory has a Batch editing checkbox. Switching this mode discards the active draft and pending changes.

Apply to batch validates and stages a full record draft. The original records, current query, grouping and exports remain unchanged until persistence succeeds. Pending changes lists every operation, ID and field value. Edit reopens a staged create/update; Undo change removes one entry; Discard all removes the queue. Cancelling an active editor retains any earlier queued version. Repeated edits of one existing ID consolidate into one change, including successive cell edits. Confirmed deletion replaces an update; undo the deletion before editing that record again. Creates have no record ID until the application assigns one.

`NgGridChange` exposes Key/key, Operation/operation, Id/id and Values/values. The key identifies one pending entry and survives revisions/retries within the queue. Do not treat it as a durable server transaction identifier. Save changes passes an immutable list with immutable full-record string maps; delete values are empty. `MaxPendingChanges` / `maxPendingChanges` defaults to 100 and must be 1–500. At the limit existing entries can still be revised or removed. Oversized newly staged changes are rejected with BatchLimitText/batchLimitText.

Save changes rechecks all required fields, custom validators and current permissions before invoking the batch callback exactly once. For local data, every update/delete must still exist in Items. For remote data, the current loaded record is used when available; otherwise the original queued record supplies the permission predicate. Thus a batch can span pages/windows, but off-page predicates are only a UI check against an earlier snapshot. The server must reauthorize and check versions for every record. Missing or newly protected local records keep the queue and show BatchConflictText/batchConflictText; undo affected entries before retrying.

The application must validate and commit the whole list atomically. Return null only after the entire transaction succeeds, or a safe message after rejecting it. There is no per-record fallback, partial-success protocol or automatic rollback. Use server transactions, concurrency tokens and an application-owned idempotency contract to handle ambiguous network failures. The demo validates a private working copy, including final-state unique names, before replacing the collection once.

During saving, all queue mutations and new editors are disabled. A message or exception preserves the entire queue for correction and retry. Success clears it and refreshes the query once; a read failure does not restore or resend the completed writes. DataVersion changes, reader replacement, removal of Editing, mode changes and disposal invalidate pending work and clear the queue. Rebuilding an equivalent configuration preserves it. Blazor cancels the token; Flutter ignores obsolete futures. Invalidation cannot undo server writes already accepted.

PendingText/pendingText, StageText/stageText, SaveBatchText/saveBatchText, DiscardText/discardText, UndoText/undoText, BatchLimitText/batchLimitText and BatchConflictText/batchConflictText localize batch controls and messages. Existing create/update/delete labels describe each queued operation. The queue is in-memory only; navigation or reload discards it. Spreadsheet keyboard navigation and durable offline mutation queues remain separate features.

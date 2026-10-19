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

This release uses text-field descriptors and an inline single-record editor. Custom field widgets/templates, batch editing, row/cell editing, file uploads and built-in database providers remain separate capabilities.

# Forms and dates — 0.2

Web-first implementation on Blazor and Flutter: eleven additional controls, bringing each library to 22. This is a working subset of the Telerik catalogue, not complete feature or API parity. Original implementation uses native framework primitives and the shared Nextgen tokens; no proprietary Telerik source was copied.

| Component | Implemented | Remaining scope |
|---|---|---|
| NgCalendar | Single date, month navigation, bounds, disabled days; Blazor culture/week start and day arrow keys; Flutter Material year selection | Multi-selection, multi-view calendar, configurable templates, parity of keyboard navigation/localization |
| NgDateInput | Strict yyyy-mm-dd parsing, impossible-date rejection, bounds, disabled dates, form errors | Segmented editing, configurable date formats |
| NgDatePicker | Text input plus calendar selection, disabled days, bounds; Blazor Clear/Close/Escape, Flutter modal dismissal | Unified popup behavior, templates, complete accessibility audit |
| NgDateRangePicker | Two date pickers, complete-pair and start/end ordering validation, endpoint disabled-date rules and read-only | Shared dual-calendar range highlighting, presets |
| NgTimePicker | Strict HH:mm, bounds, picker UI | Custom step intervals and time-list templates |
| NgDateTimePicker | Strict yyyy-mm-dd HH:mm, bounds, picker UI | Time-zone conversion, custom formats and step intervals |
| NgTextArea | Multiple rows, maximum length, disabled state, form integration | Auto-resizing and character-counter parity |
| NgAutoComplete | Local suggestions, free text | Remote/async data, virtualization, templates |
| NgComboBox | Local filtering, strict existing-option selection, disabled options, keyboard selection | Remote data, virtualization, custom item templates |
| NgMultiSelect | Filtered options, removable chips, selection limit, disabled options | Virtualization, remote data, select-all/grouping |
| NgForm | Explicit child layout, validators, error summary and valid-submit callback | Automatic model-driven editor generation, conditional schemas |

## Value and validation contracts

Blazor date types are `DateOnly?`, `TimeOnly?`, `DateTime?`, and `NgDateRange`. Flutter dates are local calendar `DateTime` values and times are `TimeOfDay`; these controls do not implicitly convert UTC. Date/time entry uses ISO wall-clock strings. Blazor's additional native picker editors follow browser locale; Flutter uses Material picker dialogs. Bounds are inclusive.

Invalid drafts remain visible and block form validation without overwriting the last valid model value. Supply `ValueExpression`/`@bind-Value` for Blazor inputs. Business requirements belong in model data annotations. Flutter exposes `required` on temporal controls/ComboBox/MultiSelect and validator callbacks on text editors. Selecting a date from a picker repairs an invalid draft, including when reselecting the previous valid value.

`NgForm` must not be nested inside another form. Blazor uses an `EditForm` with `DataAnnotationsValidator`; Flutter uses a `Form` and validates all registered fields before `onValidSubmit`. Arrays/lists emitted by MultiSelect are copied. Both examples reset the entire form with a new model/key so drafts, touched state and validation messages reset together. For an external wholesale Flutter model reset, similarly use a new key.

## Explore

- Blazor: `/forms`, linked from the foundation gallery.
- Flutter: **Forms and dates** from the foundation gallery.
- One booking scenario contains every new control, a shared calendar/date selection, unavailable Sundays, required fields, bounds, a service limit, and a saved-value summary.
- Light/dark and normal/compact themes share tokens. Popups and native picker rendering retain framework/browser differences.

Next major stage: data presentation and navigation (grid, tree, paging and related controls). Mobile and native desktop builds and physical-device interaction remain deferred by agreement.

## Text editors and form submission (0.29)

TextBox and TextArea add read-only mode, helper text, prefix/suffix decoration and public focus hooks. TextBox now also has a length limit; TextArea rejects invalid row/length configuration. Blazor merges helper descriptions with external ARIA description IDs. OnCommit uses the native change event; Flutter onSubmitted is the platform submission action. Length counting follows each platform and differs for emoji.

Form awaits asynchronous saving, blocks repeated submissions and shows configurable busy/error text. Failed saves can be retried. Flutter preserves field state when validation summaries appear or disappear. Application-owned drafts, transport cancellation and backend idempotency remain separate. Replace model and key to reset the entire form.

The Forms and dates gallery demonstrates these features with read-only text, simulated save failure and async saving. Detailed examples: [TextBox](manual/NgTextBox.md), [TextArea](manual/NgTextArea.md), [Form](manual/NgForm.md). Full feature gaps are recorded in [parity](parity.md).

## Selection input workbench (0.30)

AutoComplete, ComboBox and MultiSelect add contains/startsWith/endsWith filtering, minimum query lengths and read-only selection behavior. ComboBox adds clear, option templates and selected-label refresh. MultiSelect adds item/tag templates and optional atomic Select filtered / Clear selection actions. Disabled selections stay locked and count against the selection limit; a bulk addition over the limit changes nothing. Flutter validation follows the current controlled selection.

Blazor AutoComplete still uses a browser datalist; Flutter uses a native Material overlay. ComboBox empty popups and disabled-match presentation differ. MultiSelect is still an inline checklist. Remote loading, virtualization, grouping, full popup APIs and accessibility/native certification remain explicit gaps. See [AutoComplete](manual/NgAutoComplete.md), [ComboBox](manual/NgComboBox.md), [MultiSelect](manual/NgMultiSelect.md) and the [parity matrix](parity.md).


## Numeric and time editing (0.31)

NumericTextBox validates inclusive bounds inside the component on both platforms, preserves invalid drafts, and offers labelled increment/decrement buttons with clamping. Typed values need not be multiples of Step. Blazor uses invariant decimal syntax; Flutter finite double syntax, without exponent/group separators. Read-only protects the editor and buttons.

TimePicker and DateTimePicker add read-only and MinuteStep (positive divisors of 60). Intervals start at each hour, independent of Min. Native/Material popup minute choices remain unrestricted; off-step values are rejected. Flutter ignores stale popup results after parent rebuild, editing or disposal. Models supplied externally still require application validation. See the runnable manual examples for limits and usage.

## Calendar and date editing update

Calendar, DateInput, DatePicker and DateRangePicker now expose read-only behavior on both Web frameworks. Date range restrictions apply to each endpoint, not the intervening dates. Invalid Min/Max configurations fail early. Optional Blazor date input can be cleared without a parsing error. Flutter range validation follows parent model replacement; unchanged-value draft resets still require a new key. Calendar disables pointer and keyboard interaction in read-only mode.

Updated manual examples demonstrate October 2026 bounds, unavailable Sundays and a read-only toggle. See the parity matrix for the remaining reference features and verification history for current evidence.

## RadioGroup and DropDownList (0.33)

Both controls now provide read-only behavior and helper text. RadioGroup supports horizontal/vertical layout and decorative item templates that preserve the option label as the accessible name. DropDownList validates missing selected IDs without silently choosing a replacement; a missing key stays visible as an unavailable selection and blocks form submission. Flutter guards stale popup callbacks before updating form state. Read-only uses disabled native interaction. Required rules remain application-owned; RadioGroup's Flutter implementation is not a FormField.

## Text clear actions and password presentation (0.46)

TextBox and TextArea support `ShowClearButton` / `showClearButton` (default false). Clear produces the empty string, updates form state, emits one value-change callback and restores editor focus. The action is disabled for empty, read-only or disabled fields. It does not explicitly submit or commit; ordinary Blazor blur/change events can still commit the preceding typed value. Validators remain application-owned.

TextBox adds `Password` / `password` and `ShowPasswordToggle` / `showPasswordToggle`, both default false. Password masks the value; opt-in reveal only changes presentation. Read-only/disabled states suppress reveal and hide the value; clear and leaving the reveal control hide it. Flutter controller replacement also hides it. TextArea remains multiline plain text. This is presentation, not encryption or password-manager integration.

Existing adornments and clear/reveal controls coexist. Flutter keeps controller ownership with the caller, preserves initial-value form reset, and rejects retained clear/reveal handlers after parameter/controller replacement or disposal. Detailed manuals and live previews demonstrate both controls. Existing platform length-count and commit-timing differences remain.

## Bounded TextArea height (0.47)

`AutoSize` / `autoSize` defaults to false. Enable it to grow between `Rows` / `rows` (default 4) and `MaxRows` / `maxRows` (default 12), with internal scrolling above the cap. Both bounds accept 1–30, and the maximum must be at least the minimum in automatic mode. Growth includes wrapped text, not only explicit line breaks; width changes, clear and external text replacement recalculate the height even in read-only mode. Sizing never changes the text or emits value callbacks.

Blazor measures after interactive rendering with its packaged module and observes width/font changes; static SSR retains the Rows fallback. Auto mode disables manual resize; turning it off restores the prior inline height/overflow. Observers detach on component disposal or DOM removal. Flutter uses native minLines/maxLines layout. Platform font metrics/decorations remain different; custom CSS must not override the automatic height or box sizing. The manual provides a live long/short text and mode-switching example.


## Text editor appearance (0.48)

TextBox and TextArea support Size/size (small, medium, large) and FillMode/fillMode (theme, outline, filled). Defaults retain existing theme/density. Appearance changes keep text and form state, including automatic TextArea height. Invalid configuration throws. Flutter preserves native action hit targets and theme borders; equal sizes do not imply pixel parity. See the component manuals for live switches, theme behavior and limitations.


## Debounced notifications (0.49)

TextBox/TextArea offer OnDebouncedChange/onDebouncedChange with DebounceDelay/debounceDelay (300 ms default, 0–60000). Binding and validation remain immediate; only the optional notification is delayed. Each new input replaces pending work; locks, changed delay, external replacement, handler removal and disposal cancel it. Commit/submit remains independent and does not flush. Already-started asynchronous application work needs its own stale-result protection. See each editor manual for controller/reset and IME limitations.


## Responsive forms (0.50)

NgForm accepts an explicit Fields/fields list instead of legacy content, with Columns/columns (1–4), MinColumnWidth/minColumnWidth (120–1200, default 240) and Gap/gap (0–64, default 16). Columns adapt to container width while preserving values and validation. Actions/actionsBuilder places save controls below the grid; Flutter supplies a guarded nullable submit callback. Legacy content and the default Flutter Save button remain supported. Automatic schema generation, spans and nested groups remain open. See [Form manual](manual/NgForm.md).


## Validation summaries (0.51)

NgForm supports localized SummaryTitle/summaryTitle and SummaryTemplate/summaryBuilder with read-only error-message snapshots. The default summary lists individual errors; empty or hidden summaries do not render. Validation remains active when the summary is hidden. Blazor follows EditContext notifications; Flutter revalidates after field changes following the first attempted submission. Templates are descriptive; field-focus mapping remains open. See the [Form manual](manual/NgForm.md) for reset and validator contracts.


## Form field spans (0.52)

FieldSpans/fieldSpans optionally supplies one value per explicit field: 1–4 columns, or 0 for the entire available row. Spans clamp to the current responsive column count and preserve source order. Changing spans retains field state. Blazor container queries have a one-column fallback; Flutter uses Wrap. Nested groups, vertical spans and automatic schemas remain open. See the [Form manual](manual/NgForm.md).


## Rounded text editors and flat fill (0.53)

TextBox and TextArea support theme/none/small/medium/large/full corners and flat fill. Theme retains existing decoration; explicit presets request 0/4/8/16/9999 logical-pixel radii. Flat hides the idle border while retaining focus/error indicators in the supplied theme. Appearance switches retain editing, selection and validation; original pixel values and platform border behavior remain distinct. See the detailed editor manuals for custom Flutter theme rules and multiline guidance.

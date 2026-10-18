# Forms and dates — 0.2

Web-first implementation on Blazor and Flutter: eleven additional controls, bringing each library to 22. This is a working subset of the Telerik catalogue, not complete feature or API parity. Original implementation uses native framework primitives and the shared Nextgen tokens; no proprietary Telerik source was copied.

| Component | Implemented | Remaining scope |
|---|---|---|
| NgCalendar | Single date, month navigation, bounds, disabled days; Blazor culture/week start and day arrow keys; Flutter Material year selection | Multi-selection, multi-view calendar, configurable templates, parity of keyboard navigation/localization |
| NgDateInput | Strict yyyy-mm-dd parsing, impossible-date rejection, bounds, disabled dates, form errors | Segmented editing, configurable date formats |
| NgDatePicker | Text input plus calendar selection, disabled days, bounds; Blazor Clear/Close/Escape, Flutter modal dismissal | Unified popup behavior, templates, complete accessibility audit |
| NgDateRangePicker | Two date pickers, complete-pair and start/end ordering validation | Shared dual-calendar range highlighting, presets, disabled-date predicate |
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

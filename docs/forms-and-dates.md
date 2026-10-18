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

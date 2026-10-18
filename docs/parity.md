# Feature parity with Telerik UI for Blazor

Verification target: Blazor Web and Flutter Web. Reference audit date: 2026-10-18.

An implemented component is not a completed Telerik equivalent. The catalogue status describes availability only. No component currently has verified full feature parity. Public behavior is the target; API compatibility, exact theme pixels and commercial tooling integration are separate concerns.

## Completion rule

A component can be marked complete only after every reference feature is recorded, both implementations and detailed English examples exist, meaningful automated checks and visible Chrome scenarios pass, and remaining differences are explicitly accepted. Unknown is not complete. A test pass proves the tested behavior, not all reference behavior.

## Current work order

1. Finish the Chip/ChipList audit below: listbox and selection semantics, model binding and sizing limits, then accessibility and remaining public API differences.
2. Audit the existing selection/navigation group (ToggleButton, ButtonGroup, Menu, Drawer, Stepper, Wizard) against complete public reference pages.
3. Continue through existing editors/forms, data management, visualization and complex editors. Add new component names only after closing the active group or recording a user-approved exception.

## Chip and ChipList feature matrix

Sources: [Chip API](https://www.telerik.com/blazor-ui/documentation/api/telerik.blazor.components.telerikchip), [Chip appearance](https://www.telerik.com/blazor-ui/documentation/components/chip/appearance), [Chip events](https://www.telerik.com/blazor-ui/documentation/components/chip/events), [ChipList binding](https://www.telerik.com/blazor-ui/documentation/components/chiplist/data-bind), [ChipList templates](https://www.telerik.com/blazor-ui/documentation/components/chiplist/templates), [ChipList appearance](https://www.telerik.com/blazor-ui/documentation/components/chiplist/appearance), [keyboard demo](https://demos.telerik.com/blazor-ui/chiplist/keyboard-navigation), [RTL reference](https://www.telerik.com/blazor-ui/documentation/globalization/rtl-support), [ARIA reference](https://www.telerik.com/blazor-ui/documentation/components/chiplist/accessibility/wai-aria-support).

| Feature | Blazor | Flutter Web | Verification / remaining difference |
|---|---|---|---|
| Text and disabled state | Implemented | Implemented | Rendering/widget tests; Chrome. Static Flutter labels have no artificial checked state in 0.15. |
| Single/multiple/none selection | Implemented | Implemented | Controlled IDs; tests and Chrome. Defaults differ from Telerik ChipList. |
| Remove request and cancellation | Equivalent contract | Equivalent contract | Parent accepts/rejects, owns removal. Tested; no Telerik event-args API. |
| Independent click event | Implemented | Implemented | 0.15: click follows selection, removal is separate; disabled action tests. |
| Conditional per-item removal | Implemented | Implemented | CanRemove predicate; no property-name reflection. Tests and Chrome. |
| Three sizes | Implemented | Implemented | sm/md/lg; tests and Chrome. Exact pixel parity not claimed. |
| Rounded corners | Implemented | Implemented | sm/md/lg/full; tests and Chrome. Default full retained for compatibility. |
| Solid/outline fill | Implemented | Implemented | Tests and Chrome; default outline differs from Telerik. |
| Five semantic colors | Implemented | Implemented | base/info/success/warning/error; light/dark palette, tests and Chrome. |
| Per-item color/fill | Equivalent contract | Equivalent contract | NgChipAppearance callback inherits unspecified list defaults. |
| Custom chip/list content | Implemented | Implemented | RenderFragment / Widget builders with stable accessible labels; compiled manual and Chrome. |
| Leading icon/avatar and removal icon | Equivalent slots | Equivalent slots | Application-supplied content; no Telerik icon registry/variant API. No image loader is supplied. |
| Keyboard activation and list movement | Implemented core | Implemented core | 0.16: Enter/Space, Delete/Backspace, arrows and Home/End. 0.17 adds one remembered Tab entry and forward/reverse exit; selection-only Blazor semantics added in 0.24. |
| Focus after removal / public focus API | Implemented / FocusAsync | Implemented / public controller | 0.16: next/previous/container recovery; rejection, outside-focus protection and disabled neighbors tested. 0.18: Flutter public controller supports first-action and stable-ID focus, detachment and ownership guards. |
| Selection listbox/option semantics | Partial: selection-only | Remaining | 0.24: Blazor uses listbox/options with selected state when Selectable and no OnRemove callback. Removable lists retain group/buttons so removal stays accessible. Flutter SDK has no listbox/option roles. Type-ahead and screen-reader validation remain open. |
| Application-model binding | Typed adapter | Typed adapter | NgChipData<T> maps fields through typed selectors and resolves original records by ID. String property-name reflection differs from Telerik; icons use existing templates. |
| Large collections | No fixed cap / tested 500 | No fixed cap / tested 500 | 0.19 removes the ChipList 50-item guard. Eager rendering; no virtualization or unlimited performance claim. Other component caps unchanged. |
| Independent Chip accessible name | Implemented | Implemented | 0.25: AriaLabel / semanticLabel override the standalone main-chip name independently of visible text and removal. Blazor labelled-by takes precedence; runtime changes preserve selection. Per-item list names still use NgOption.Label. |
| Public identity, naming and help hooks | Implemented | Platform-specific contract | 0.22: Id/Class and AriaLabelledBy/AriaDescribedBy on Blazor; semanticIdentifier/semanticHint on Flutter. Flutter shared heading uses the same application string as label; no DOM-class or labelled-by API equivalence. |
| Configurable TabIndex | Limited contract: -1/0 | Limited contract: -1/0 | 0.23: Chip actions and the ChipList remembered entry can be skipped during Tab traversal without disabling interaction. Positive indices are not supported; Telerik Chip exposes an integer. List-level setting is a Nextgen extension. |
| ChipList gap sizing | Implemented presets | Implemented presets | 0.23: sm/md/lg spacing (4/8/12) applies to columns and wrapped rows. Default md preserves existing spacing. Original tokens, not exact theme pixels. |
| RTL/localized action labels | Scoped RTL layout / label hooks | Scoped RTL layout / label hooks | 0.21: inherited direction mirrors chip order, wrapped rows, leading/removal placement and Blazor divider; runtime switches preserve selection and focus. Application supplies translations and directional icons. Screen-reader audit remains. |
| Screen readers / WCAG certification | Not verified | Not verified | Browser inspection is not certification. Keyboard/focus semantics must be completed first. |
| ThemeBuilder / Telerik icon packages | Not compatible | Not compatible | Original themes/content slots; no commercial tooling compatibility claim. |
| Native mobile platforms | Deferred | Deferred | User chose Web first. Native validation is a separate phase. |

Dragging, editable tag input and virtualization are not established requirements in the audited Chip/ChipList references. They are optional extension proposals, not invented parity gaps.

See [capability notes](chips.md), [verification evidence](verification.md) and the [manual](manual/README.md).

## Complete catalogue inventory

The inventory includes chart modes as separate entries. “Not assessed” means the full reference feature checklist has not yet been completed; earlier capability documents remain useful evidence for implemented subsets.

| Reference component | Blazor availability | Flutter availability | Full feature audit |
|---|---|---|---|
| [AI Prompt](https://www.telerik.com/blazor-ui/ai-prompt) | Implemented subset: NgAIPrompt | Implemented subset: NgAIPrompt | Not assessed |
| [Inline AI Prompt](https://www.telerik.com/blazor-ui/inline-ai-prompt) | Not implemented | Not implemented | Not assessed |
| [LLM Kit](https://www.telerik.com/blazor-ui/llm-kit) | Not implemented | Not implemented | Not assessed |
| [PromptBox](https://www.telerik.com/blazor-ui/promptbox) | Implemented subset: NgPromptBox | Implemented subset: NgPromptBox | Not assessed |
| [SmartPasteButton](https://www.telerik.com/blazor-ui/smartpastebutton) | Not implemented | Not implemented | Not assessed |
| [AppBar](https://www.telerik.com/blazor-ui/appbar) | Not implemented | Not implemented | Not assessed |
| [Breadcrumb](https://www.telerik.com/blazor-ui/breadcrumb) | Implemented subset: NgBreadcrumb | Implemented subset: NgBreadcrumb | Not assessed |
| [Button Group](https://www.telerik.com/blazor-ui/buttongroup) | Implemented subset: NgButtonGroup | Implemented subset: NgButtonGroup | Not assessed |
| [Buttons](https://www.telerik.com/blazor-ui/buttons) | Implemented subset: NgButton | Implemented subset: NgButton | Not assessed |
| [Chip](https://www.telerik.com/blazor-ui/chip) | Implemented subset: NgChip | Implemented subset: NgChip | Partial — matrix above |
| [ChipList](https://www.telerik.com/blazor-ui/chiplist) | Implemented subset: NgChipList | Implemented subset: NgChipList | Partial — matrix above |
| [Context Menu](https://www.telerik.com/blazor-ui/context-menu) | Not implemented | Not implemented | Not assessed |
| [Drawer](https://www.telerik.com/blazor-ui/drawer) | Implemented subset: NgDrawer | Implemented subset: NgDrawer | Not assessed |
| [DropDownButton](https://www.telerik.com/blazor-ui/dropdownbutton) | Not implemented | Not implemented | Not assessed |
| [Floating Action Button](https://www.telerik.com/blazor-ui/floating-action-button) | Not implemented | Not implemented | Not assessed |
| [Menu](https://www.telerik.com/blazor-ui/menu) | Implemented subset: NgMenu | Implemented subset: NgMenu | Not assessed |
| [Segmented Control](https://www.telerik.com/blazor-ui/segmented-control) | Not implemented | Not implemented | Not assessed |
| [Speech-to-Text Button](https://www.telerik.com/blazor-ui/speech-to-text-button) | Not implemented | Not implemented | Not assessed |
| [Split Button](https://www.telerik.com/blazor-ui/split-button) | Not implemented | Not implemented | Not assessed |
| [Stepper](https://www.telerik.com/blazor-ui/stepper) | Implemented subset: NgStepper | Implemented subset: NgStepper | Not assessed |
| [Switch](https://www.telerik.com/blazor-ui/switch) | Implemented subset: NgSwitch | Implemented subset: NgSwitch | Not assessed |
| [TabStrip](https://www.telerik.com/blazor-ui/tabstrip) | Implemented subset: NgTabs | Implemented subset: NgTabs | Not assessed |
| [Toggle Button](https://www.telerik.com/blazor-ui/togglebutton) | Implemented subset: NgToggleButton | Implemented subset: NgToggleButton | Not assessed |
| [ToolBar](https://www.telerik.com/blazor-ui/toolbar) | Not implemented | Not implemented | Not assessed |
| [TreeView](https://www.telerik.com/blazor-ui/treeview) | Implemented subset: NgTreeView | Implemented subset: NgTreeView | Not assessed |
| [Data Grid](https://www.telerik.com/blazor-ui/grid) | Implemented subset: NgDataGrid | Implemented subset: NgDataGrid | Not assessed |
| [Filter](https://www.telerik.com/blazor-ui/filter) | Not implemented | Not implemented | Not assessed |
| [ListView](https://www.telerik.com/blazor-ui/listview) | Not implemented | Not implemented | Not assessed |
| [Pager](https://www.telerik.com/blazor-ui/pager) | Implemented subset: NgPager | Implemented subset: NgPager | Not assessed |
| [PivotGrid](https://www.telerik.com/blazor-ui/pivotgrid) | Implemented subset: NgPivotGrid | Implemented subset: NgPivotGrid | Not assessed |
| [Spreadsheet](https://www.telerik.com/blazor-ui/spreadsheet) | Implemented subset: NgSpreadsheet | Implemented subset: NgSpreadsheet | Not assessed |
| [TaskBoard](https://www.telerik.com/blazor-ui/taskboard) | Not implemented | Not implemented | Not assessed |
| [TreeList](https://www.telerik.com/blazor-ui/treelist) | Implemented subset: NgTreeList | Implemented subset: NgTreeList | Not assessed |
| [DropZone](https://www.telerik.com/blazor-ui/dropzone) | Not implemented | Not implemented | Not assessed |
| [File Manager](https://www.telerik.com/blazor-ui/file-manager) | Not implemented | Not implemented | Not assessed |
| [FileSelect](https://www.telerik.com/blazor-ui/fileselect) | Not implemented | Not implemented | Not assessed |
| [PDF Viewer](https://www.telerik.com/blazor-ui/pdf-viewer) | Implemented subset: NgPdfViewer | Implemented subset: NgPdfViewer | Not assessed |
| [Upload](https://www.telerik.com/blazor-ui/upload) | Not implemented | Not implemented | Not assessed |
| [Diagram](https://www.telerik.com/blazor-ui/diagram) | Implemented subset: NgDiagram | Implemented subset: NgDiagram | Not assessed |
| [Map](https://www.telerik.com/blazor-ui/map) | Implemented subset: NgMap | Implemented subset: NgMap | Not assessed |
| [Badge](https://www.telerik.com/blazor-ui/badge) | Not implemented | Not implemented | Not assessed |
| [FloatingLabel](https://www.telerik.com/blazor-ui/floatinglabel) | Not implemented | Not implemented | Not assessed |
| [FontIcon](https://www.telerik.com/blazor-ui/fonticon) | Not implemented | Not implemented | Not assessed |
| [SVGIcon](https://www.telerik.com/blazor-ui/svgicon) | Not implemented | Not implemented | Not assessed |
| [Area Chart](https://www.telerik.com/blazor-ui/area-chart) | Implemented subset: NgChart | Implemented subset: NgChart | Not assessed |
| [Bar Chart](https://www.telerik.com/blazor-ui/bar-chart) | Implemented subset: NgChart | Implemented subset: NgChart | Not assessed |
| [Barcode](https://www.telerik.com/blazor-ui/barcode) | Not implemented | Not implemented | Not assessed |
| [Bubble Chart](https://www.telerik.com/blazor-ui/bubble-chart) | Not implemented | Not implemented | Not assessed |
| [Candlestick Chart](https://www.telerik.com/blazor-ui/candlestick-chart) | Not implemented | Not implemented | Not assessed |
| [Chart](https://www.telerik.com/blazor-ui/chart) | Implemented subset: NgChart | Implemented subset: NgChart | Not assessed |
| [Column Chart](https://www.telerik.com/blazor-ui/column-chart) | Implemented subset: NgChart | Implemented subset: NgChart | Not assessed |
| [Donut Chart](https://www.telerik.com/blazor-ui/donut-chart) | Implemented subset: NgChart | Implemented subset: NgChart | Not assessed |
| [Heatmap](https://www.telerik.com/blazor-ui/heatmap) | Not implemented | Not implemented | Not assessed |
| [Line Chart](https://www.telerik.com/blazor-ui/line-chart) | Implemented subset: NgChart | Implemented subset: NgChart | Not assessed |
| [OHLC Chart](https://www.telerik.com/blazor-ui/ohlc-chart) | Not implemented | Not implemented | Not assessed |
| [Pie Chart](https://www.telerik.com/blazor-ui/pie-chart) | Implemented subset: NgChart | Implemented subset: NgChart | Not assessed |
| [QR Code](https://www.telerik.com/blazor-ui/qr-code) | Not implemented | Not implemented | Not assessed |
| [Radar Area Chart](https://www.telerik.com/blazor-ui/radar-area-chart) | Not implemented | Not implemented | Not assessed |
| [Radar Column Chart](https://www.telerik.com/blazor-ui/radar-column-chart) | Not implemented | Not implemented | Not assessed |
| [Radar Line Chart](https://www.telerik.com/blazor-ui/radar-line-chart) | Not implemented | Not implemented | Not assessed |
| [Range Area Chart](https://www.telerik.com/blazor-ui/range-area-chart) | Not implemented | Not implemented | Not assessed |
| [Range Bar Chart](https://www.telerik.com/blazor-ui/range-bar-chart) | Not implemented | Not implemented | Not assessed |
| [Range Column Chart](https://www.telerik.com/blazor-ui/range-column-chart) | Not implemented | Not implemented | Not assessed |
| [Sankey Chart](https://www.telerik.com/blazor-ui/sankey-chart) | Not implemented | Not implemented | Not assessed |
| [Scatter Chart](https://www.telerik.com/blazor-ui/scatter-chart) | Not implemented | Not implemented | Not assessed |
| [Scatter Line Chart](https://www.telerik.com/blazor-ui/scatter-line-chart) | Not implemented | Not implemented | Not assessed |
| [Stock Chart](https://www.telerik.com/blazor-ui/stock-chart) | Not implemented | Not implemented | Not assessed |
| [Trendline Chart](https://www.telerik.com/blazor-ui/trendline-chart) | Not implemented | Not implemented | Not assessed |
| [Waterfall Chart](https://www.telerik.com/blazor-ui/waterfall-chart) | Not implemented | Not implemented | Not assessed |
| [AutoComplete](https://www.telerik.com/blazor-ui/autocomplete) | Implemented subset: NgAutoComplete | Implemented subset: NgAutoComplete | Not assessed |
| [CheckBox](https://www.telerik.com/blazor-ui/checkbox) | Implemented subset: NgCheckBox | Implemented subset: NgCheckBox | Not assessed |
| [ColorGradient](https://www.telerik.com/blazor-ui/colorgradient) | Not implemented | Not implemented | Not assessed |
| [ColorPalette](https://www.telerik.com/blazor-ui/colorpalette) | Not implemented | Not implemented | Not assessed |
| [ColorPicker](https://www.telerik.com/blazor-ui/colorpicker) | Not implemented | Not implemented | Not assessed |
| [ComboBox](https://www.telerik.com/blazor-ui/combobox) | Implemented subset: NgComboBox | Implemented subset: NgComboBox | Not assessed |
| [DateInput](https://www.telerik.com/blazor-ui/date-input) | Implemented subset: NgDateInput | Implemented subset: NgDateInput | Not assessed |
| [DatePicker](https://www.telerik.com/blazor-ui/datepicker) | Implemented subset: NgDatePicker | Implemented subset: NgDatePicker | Not assessed |
| [DateRange Picker](https://www.telerik.com/blazor-ui/daterange-picker) | Implemented subset: NgDateRangePicker | Implemented subset: NgDateRangePicker | Not assessed |
| [DateTimePicker](https://www.telerik.com/blazor-ui/datetimepicker) | Implemented subset: NgDateTimePicker | Implemented subset: NgDateTimePicker | Not assessed |
| [DropDownList](https://www.telerik.com/blazor-ui/dropdownlist) | Implemented subset: NgDropDownList | Implemented subset: NgDropDownList | Not assessed |
| [DropDownTree](https://www.telerik.com/blazor-ui/dropdowntree) | Not implemented | Not implemented | Not assessed |
| [FlatColorPicker](https://www.telerik.com/blazor-ui/flatcolorpicker) | Not implemented | Not implemented | Not assessed |
| [ListBox](https://www.telerik.com/blazor-ui/listbox) | Not implemented | Not implemented | Not assessed |
| [MaskedTextBox](https://www.telerik.com/blazor-ui/maskedtextbox) | Not implemented | Not implemented | Not assessed |
| [MultiColumn ComboBox](https://www.telerik.com/blazor-ui/multicolumncombobox) | Not implemented | Not implemented | Not assessed |
| [MultiSelect](https://www.telerik.com/blazor-ui/multiselect) | Implemented subset: NgMultiSelect | Implemented subset: NgMultiSelect | Not assessed |
| [Numeric TextBox](https://www.telerik.com/blazor-ui/numeric-textbox) | Implemented subset: NgNumericTextBox | Implemented subset: NgNumericTextBox | Not assessed |
| [RadioGroup](https://www.telerik.com/blazor-ui/radiogroup) | Implemented subset: NgRadioGroup | Implemented subset: NgRadioGroup | Not assessed |
| [Rating](https://www.telerik.com/blazor-ui/rating) | Not implemented | Not implemented | Not assessed |
| [Rich Text Editor](https://www.telerik.com/blazor-ui/editor) | Implemented subset: NgEditor | Implemented subset: NgEditor | Not assessed |
| [Signature](https://www.telerik.com/blazor-ui/signature) | Not implemented | Not implemented | Not assessed |
| [TextArea](https://www.telerik.com/blazor-ui/textarea) | Implemented subset: NgTextArea | Implemented subset: NgTextArea | Not assessed |
| [TextBox](https://www.telerik.com/blazor-ui/textbox) | Implemented subset: NgTextBox | Implemented subset: NgTextBox | Not assessed |
| [TimePicker](https://www.telerik.com/blazor-ui/timepicker) | Implemented subset: NgTimePicker | Implemented subset: NgTimePicker | Not assessed |
| [Calendar](https://www.telerik.com/blazor-ui/calendar) | Implemented subset: NgCalendar | Implemented subset: NgCalendar | Not assessed |
| [Gantt](https://www.telerik.com/blazor-ui/gantt) | Not implemented | Not implemented | Not assessed |
| [Scheduler](https://www.telerik.com/blazor-ui/scheduler) | Implemented subset: NgScheduler | Implemented subset: NgScheduler | Not assessed |
| [Animation Container](https://www.telerik.com/blazor-ui/animation-container) | Not implemented | Not implemented | Not assessed |
| [Avatar](https://www.telerik.com/blazor-ui/avatar) | Not implemented | Not implemented | Not assessed |
| [Card](https://www.telerik.com/blazor-ui/card) | Not implemented | Not implemented | Not assessed |
| [Carousel](https://www.telerik.com/blazor-ui/carousel) | Not implemented | Not implemented | Not assessed |
| [DockManager](https://www.telerik.com/blazor-ui/dockmanager) | Not implemented | Not implemented | Not assessed |
| [Expansion Panel](https://www.telerik.com/blazor-ui/expansion-panel) | Not implemented | Not implemented | Not assessed |
| [Form](https://www.telerik.com/blazor-ui/form) | Implemented subset: NgForm | Implemented subset: NgForm | Not assessed |
| [GridLayout](https://www.telerik.com/blazor-ui/gridlayout) | Not implemented | Not implemented | Not assessed |
| [MediaQuery](https://www.telerik.com/blazor-ui/mediaquery) | Not implemented | Not implemented | Not assessed |
| [PanelBar](https://www.telerik.com/blazor-ui/panelbar) | Not implemented | Not implemented | Not assessed |
| [Splitter](https://www.telerik.com/blazor-ui/splitter) | Not implemented | Not implemented | Not assessed |
| [StackLayout](https://www.telerik.com/blazor-ui/stacklayout) | Not implemented | Not implemented | Not assessed |
| [TileLayout](https://www.telerik.com/blazor-ui/tilelayout) | Not implemented | Not implemented | Not assessed |
| [Tooltip](https://www.telerik.com/blazor-ui/tooltip) | Implemented subset: NgTooltip | Implemented subset: NgTooltip | Not assessed |
| [Window](https://www.telerik.com/blazor-ui/window) | Not implemented | Not implemented | Not assessed |
| [Wizard](https://www.telerik.com/blazor-ui/wizard) | Implemented subset: NgWizard | Implemented subset: NgWizard | Not assessed |
| [Arc Gauge](https://www.telerik.com/blazor-ui/arc-gauge) | Implemented subset: NgArcGauge | Implemented subset: NgArcGauge | Not assessed |
| [Circular Gauge](https://www.telerik.com/blazor-ui/circular-gauge) | Not implemented | Not implemented | Not assessed |
| [Linear Gauge](https://www.telerik.com/blazor-ui/linear-gauge) | Implemented subset: NgLinearGauge | Implemented subset: NgLinearGauge | Not assessed |
| [Radial Gauge](https://www.telerik.com/blazor-ui/radial-gauge) | Not implemented | Not implemented | Not assessed |
| [Chat](https://www.telerik.com/blazor-ui/chat-(conversational-ui)) | Not implemented | Not implemented | Not assessed |
| [ChunkProgressBar](https://www.telerik.com/blazor-ui/chunkprogressbar) | Not implemented | Not implemented | Not assessed |
| [Dialog](https://www.telerik.com/blazor-ui/dialog) | Implemented subset: NgDialog | Implemented subset: NgDialog | Not assessed |
| [Loader](https://www.telerik.com/blazor-ui/loader) | Not implemented | Not implemented | Not assessed |
| [Loader Container](https://www.telerik.com/blazor-ui/loader-container) | Not implemented | Not implemented | Not assessed |
| [Notification](https://www.telerik.com/blazor-ui/notification) | Implemented subset: NgNotification | Implemented subset: NgNotification | Not assessed |
| [Popover](https://www.telerik.com/blazor-ui/popover) | Not implemented | Not implemented | Not assessed |
| [Popup](https://www.telerik.com/blazor-ui/popup) | Not implemented | Not implemented | Not assessed |
| [ProgressBar](https://www.telerik.com/blazor-ui/progressbar) | Not implemented | Not implemented | Not assessed |
| [RangeSlider](https://www.telerik.com/blazor-ui/rangeslider) | Not implemented | Not implemented | Not assessed |
| [Skeleton](https://www.telerik.com/blazor-ui/skeleton) | Not implemented | Not implemented | Not assessed |
| [Slider](https://www.telerik.com/blazor-ui/slider) | Not implemented | Not implemented | Not assessed |
| [ValidationMessage](https://www.telerik.com/blazor-ui/validation-message) | Not implemented | Not implemented | Not assessed |
| [ValidationSummary](https://www.telerik.com/blazor-ui/validationsummary) | Not implemented | Not implemented | Not assessed |
| [ValidationTooltip](https://www.telerik.com/blazor-ui/validationtooltip) | Not implemented | Not implemented | Not assessed |
| [Visual Studio Code](https://www.telerik.com/blazor-ui/visual-studio-code) | Not implemented | Not implemented | Not assessed |
| [Reporting Integration](https://www.telerik.com/blazor-ui/blazor-reporting) | Not implemented | Not implemented | Not assessed |
| [PDFProcessing](https://www.telerik.com/blazor-ui/pdfprocessing) | Not implemented | Not implemented | Not assessed |
| [SpreadProcessing](https://www.telerik.com/blazor-ui/spreadprocessing) | Not implemented | Not implemented | Not assessed |
| [SpreadStreamProcessing](https://www.telerik.com/blazor-ui/spreadstreamprocessing) | Not implemented | Not implemented | Not assessed |
| [WordsProcessing](https://www.telerik.com/blazor-ui/wordprocessing) | Not implemented | Not implemented | Not assessed |
| [ZipLibrary](https://www.telerik.com/blazor-ui/ziplibrary) | Not implemented | Not implemented | Not assessed |

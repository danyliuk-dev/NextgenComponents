# Feature parity with Telerik UI for Blazor

Verification target: Blazor Web and Flutter Web. Reference audit date: 2026-10-19.

An implemented component is not a completed Telerik equivalent. The catalogue status describes availability only. No component currently has verified full feature parity. Public behavior is the target; API compatibility, exact theme pixels and commercial tooling integration are separate concerns.

## Completion rule

A component can be marked complete only after every reference feature is recorded, both implementations and detailed English examples exist, meaningful automated checks and visible Chrome scenarios pass, and remaining differences are explicitly accepted. Unknown is not complete. A test pass proves the tested behavior, not all reference behavior.

## Current work order

1. Chip/ChipList remaining gaps stay tracked below; do not mark full parity or silently accept them. Work is delivered in component blocks, not one release per parameter.
2. ToggleButton/ButtonGroup and Menu/Drawer implementation blocks are delivered with explicit remaining gaps below. Stepper/Wizard is also delivered below; TextBox/TextArea/Form is delivered in 0.29; AutoComplete/ComboBox/MultiSelect is delivered in 0.30; numeric/time editing is delivered in 0.31; Calendar, DateInput, DatePicker and DateRangePicker are delivered in 0.32; RadioGroup and DropDownList are delivered in 0.33; Grid protected/read-only selection is delivered in 0.34; TreeView/TreeList controlled state and templates are delivered in 0.35; Chart interaction and presentation are delivered in 0.36; gauge ranges and presentation are delivered in 0.37; Scheduler day/week navigation and guarded actions are delivered in 0.38; Spreadsheet controlled edits and cell protection are delivered in 0.39; PivotGrid presentation and guarded drilldown are delivered in 0.40; Editor controlled changes and history are delivered in 0.41; next work continues with Diagram. No block is a full-parity verdict.
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

## ToggleButton and ButtonGroup audit (0.26)

Sources: [ToggleButton overview](https://www.telerik.com/blazor-ui/documentation/components/togglebutton/overview), [ToggleButton appearance](https://www.telerik.com/blazor-ui/documentation/components/togglebutton/appearance), [ButtonGroup overview](https://www.telerik.com/blazor-ui/documentation/components/buttongroup/overview), [button kinds and visibility](https://www.telerik.com/blazor-ui/documentation/components/buttongroup/buttons), [events](https://www.telerik.com/blazor-ui/documentation/components/buttongroup/events).

| Feature | Blazor and Flutter Web | Remaining difference |
|---|---|---|
| Controlled single/multiple selection and disabled state | Implemented; existing rules retained | Defaults and callback API differ; 50-item cap remains |
| Mixed commands and toggles, independent click | Implemented in 0.26 | NgOption predicates and ID callbacks, not declarative Telerik child types/event args |
| Visibility without losing selected state | Implemented in 0.26 | Application owns focus after hiding the focused item |
| Decorative icons/images and custom content | Implemented slots in 0.26 | No Telerik icon package or built-in image loader |
| Size, rounded, five fill modes, eleven color tokens | Implemented in 0.26; shared per-item override | Original theme values/defaults; no exact pixel or ThemeBuilder compatibility |
| Identity, accessible names/help, toggle focus | Implemented platform contracts in 0.26 | CSS/DOM hooks are Blazor-only; Flutter uses Semantics and FocusNode |
| Keyboard activation | Native Tab/Shift+Tab and Enter/Space | No composite arrow navigation; TabIndex limited to -1/0 |
| Layout | Horizontal wrapping and vertical groups | Width belongs to application layout; no dedicated Width parameter |
| Other reference APIs | Not complete | Native submit/reset type, arbitrary HTML attributes and full inherited API audit remain; screen-reader certification unverified |

No full-parity verdict: the component block is usable and documented, with remaining reference/API gaps recorded above.

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
| [Drawer](https://www.telerik.com/blazor-ui/drawer) | Implemented subset: NgDrawer | Implemented subset: NgDrawer | Partial — navigation matrix below |
| [DropDownButton](https://www.telerik.com/blazor-ui/dropdownbutton) | Not implemented | Not implemented | Not assessed |
| [Floating Action Button](https://www.telerik.com/blazor-ui/floating-action-button) | Not implemented | Not implemented | Not assessed |
| [Menu](https://www.telerik.com/blazor-ui/menu) | Implemented subset: NgMenu | Implemented subset: NgMenu | Partial — navigation matrix below |
| [Segmented Control](https://www.telerik.com/blazor-ui/segmented-control) | Not implemented | Not implemented | Not assessed |
| [Speech-to-Text Button](https://www.telerik.com/blazor-ui/speech-to-text-button) | Not implemented | Not implemented | Not assessed |
| [Split Button](https://www.telerik.com/blazor-ui/split-button) | Not implemented | Not implemented | Not assessed |
| [Stepper](https://www.telerik.com/blazor-ui/stepper) | Implemented subset: NgStepper | Implemented subset: NgStepper | Partial — wizard matrix below |
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
| [AutoComplete](https://www.telerik.com/blazor-ui/autocomplete) | Implemented subset: NgAutoComplete | Implemented subset: NgAutoComplete | Partial — selection input matrix below |
| [CheckBox](https://www.telerik.com/blazor-ui/checkbox) | Implemented subset: NgCheckBox | Implemented subset: NgCheckBox | Not assessed |
| [ColorGradient](https://www.telerik.com/blazor-ui/colorgradient) | Not implemented | Not implemented | Not assessed |
| [ColorPalette](https://www.telerik.com/blazor-ui/colorpalette) | Not implemented | Not implemented | Not assessed |
| [ColorPicker](https://www.telerik.com/blazor-ui/colorpicker) | Not implemented | Not implemented | Not assessed |
| [ComboBox](https://www.telerik.com/blazor-ui/combobox) | Implemented subset: NgComboBox | Implemented subset: NgComboBox | Partial — selection input matrix below |
| [DateInput](https://www.telerik.com/blazor-ui/date-input) | Implemented subset: NgDateInput | Implemented subset: NgDateInput | Not assessed |
| [DatePicker](https://www.telerik.com/blazor-ui/datepicker) | Implemented subset: NgDatePicker | Implemented subset: NgDatePicker | Not assessed |
| [DateRange Picker](https://www.telerik.com/blazor-ui/daterange-picker) | Implemented subset: NgDateRangePicker | Implemented subset: NgDateRangePicker | Not assessed |
| [DateTimePicker](https://www.telerik.com/blazor-ui/datetimepicker) | Implemented subset: NgDateTimePicker | Implemented subset: NgDateTimePicker | Not assessed |
| [DropDownList](https://www.telerik.com/blazor-ui/dropdownlist) | Implemented subset: NgDropDownList | Implemented subset: NgDropDownList | Partial — choice editor matrix below |
| [DropDownTree](https://www.telerik.com/blazor-ui/dropdowntree) | Not implemented | Not implemented | Not assessed |
| [FlatColorPicker](https://www.telerik.com/blazor-ui/flatcolorpicker) | Not implemented | Not implemented | Not assessed |
| [ListBox](https://www.telerik.com/blazor-ui/listbox) | Not implemented | Not implemented | Not assessed |
| [MaskedTextBox](https://www.telerik.com/blazor-ui/maskedtextbox) | Not implemented | Not implemented | Not assessed |
| [MultiColumn ComboBox](https://www.telerik.com/blazor-ui/multicolumncombobox) | Not implemented | Not implemented | Not assessed |
| [MultiSelect](https://www.telerik.com/blazor-ui/multiselect) | Implemented subset: NgMultiSelect | Implemented subset: NgMultiSelect | Partial — selection input matrix below |
| [Numeric TextBox](https://www.telerik.com/blazor-ui/numeric-textbox) | Implemented subset: NgNumericTextBox | Implemented subset: NgNumericTextBox | Not assessed |
| [RadioGroup](https://www.telerik.com/blazor-ui/radiogroup) | Implemented subset: NgRadioGroup | Implemented subset: NgRadioGroup | Partial — choice editor matrix below |
| [Rating](https://www.telerik.com/blazor-ui/rating) | Not implemented | Not implemented | Not assessed |
| [Rich Text Editor](https://www.telerik.com/blazor-ui/editor) | Implemented subset: NgEditor | Implemented subset: NgEditor | Not assessed |
| [Signature](https://www.telerik.com/blazor-ui/signature) | Not implemented | Not implemented | Not assessed |
| [TextArea](https://www.telerik.com/blazor-ui/textarea) | Implemented subset: NgTextArea | Implemented subset: NgTextArea | Partial — text/form matrix below |
| [TextBox](https://www.telerik.com/blazor-ui/textbox) | Implemented subset: NgTextBox | Implemented subset: NgTextBox | Partial — text/form matrix below |
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
| [Form](https://www.telerik.com/blazor-ui/form) | Implemented subset: NgForm | Implemented subset: NgForm | Partial — text/form matrix below |
| [GridLayout](https://www.telerik.com/blazor-ui/gridlayout) | Not implemented | Not implemented | Not assessed |
| [MediaQuery](https://www.telerik.com/blazor-ui/mediaquery) | Not implemented | Not implemented | Not assessed |
| [PanelBar](https://www.telerik.com/blazor-ui/panelbar) | Not implemented | Not implemented | Not assessed |
| [Splitter](https://www.telerik.com/blazor-ui/splitter) | Not implemented | Not implemented | Not assessed |
| [StackLayout](https://www.telerik.com/blazor-ui/stacklayout) | Not implemented | Not implemented | Not assessed |
| [TileLayout](https://www.telerik.com/blazor-ui/tilelayout) | Not implemented | Not implemented | Not assessed |
| [Tooltip](https://www.telerik.com/blazor-ui/tooltip) | Implemented subset: NgTooltip | Implemented subset: NgTooltip | Not assessed |
| [Window](https://www.telerik.com/blazor-ui/window) | Not implemented | Not implemented | Not assessed |
| [Wizard](https://www.telerik.com/blazor-ui/wizard) | Implemented subset: NgWizard | Implemented subset: NgWizard | Partial — wizard matrix below |
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

## Menu and Drawer audit (0.27)

Sources: [Menu overview](https://www.telerik.com/blazor-ui/documentation/components/menu/overview), [Menu binding](https://www.telerik.com/blazor-ui/documentation/components/menu/data-binding/overview), [Menu templates](https://www.telerik.com/blazor-ui/documentation/components/menu/templates), [Drawer overview](https://www.telerik.com/blazor-ui/documentation/components/drawer/overview), [Drawer templates](https://www.telerik.com/blazor-ui/documentation/components/drawer/templates), [mini mode](https://www.telerik.com/blazor-ui/documentation/components/drawer/mini-view).

| Feature | Blazor / Flutter Web | Remaining difference |
|---|---|---|
| Menu nested commands and disabled ancestors | Implemented; three levels / 100 nodes | Fixed model and caps; no arbitrary field mapping or flat-to-tree adapter |
| Menu icons, item display and separators | Leading/item templates and immutable separator model flag | Display-only templates; no built-in icon registry |
| Hidden entries | Menu Visible; Drawer IsVisible predicate | Application must restore focus when removing the focused item |
| Menu close policy and RTL | CloseOnClick; RTL arrows/layout | Blazor click/keyboard opening; Flutter native Material hover. No common hover-delay/animation API |
| Drawer modes, position and selection | Push/Overlay; logical start/end; RTL; CloseOnSelect | Push stacks above content under 600px, Flutter panel height 420px |
| Drawer icons and templates | Item/leading and header/footer slots | No full template replacement or arbitrary model binding |
| Disabled/read-only destinations | Disabled state and missing callback disable selection | An open overlay intentionally remains dismissible |
| Mini mode / swipe / automatic URLs | Not implemented | Routing stays application-owned |
| Accessibility and platforms | Native buttons/dialog or Material semantics; Web checked | Full screen-reader and native mobile validation remain open |


## Stepper and Wizard audit (0.28)

Sources: [Stepper overview](https://www.telerik.com/blazor-ui/documentation/components/stepper/overview), [step templates](https://www.telerik.com/blazor-ui/documentation/components/stepper/step-template), [Wizard layout](https://www.telerik.com/blazor-ui/documentation/components/wizard/layout), [Wizard buttons](https://www.telerik.com/blazor-ui/documentation/components/wizard/structure/buttons), [Wizard events](https://www.telerik.com/blazor-ui/documentation/components/wizard/events).

| Feature | Blazor / Flutter Web | Remaining difference |
|---|---|---|
| Controlled step, linear navigation and disabled/optional/valid states | Implemented; 1–30 steps | Optional/Valid remain presentation; no automatic form validation integration |
| Indicators, labels and templates | all/labels/indicators modes; indicator/label slots with complete accessible names | No full interactive step replacement, per-step template fields or icon registry |
| Orientation, RTL and Wizard layouts | Horizontal/vertical; top/bottom/start/end, responsive side stacking | Logical sides differ from physical-position API; original themes |
| Wizard actions | Built-in captions or custom action context | Custom controls must use Can… flags and provided callbacks; no Telerik event-args compatibility |
| Cancellable transitions | Async BeforeChange before forward validation, backward navigation and Finish | Unified pipeline; standalone Stepper relies on controlled application callback |
| Async completion and reset | Busy/duplicate guards, ResetKey, stale-result rejection | No transport cancellation, server idempotency or rollback of external side effects |
| Content and forms | Active-step content; application-owned models and validators | No retained inactive panels or automatic form wiring |
| Accessibility/localization | Native Tab and Enter/Space; state names preserved in templates | Arrow navigation, focus transfer, full localization and screen-reader certification remain open |
| Animation/native platforms | Not implemented / deferred | Web-first validation only |


## TextBox, TextArea and Form audit (0.29)

Sources: [TextBox API](https://www.telerik.com/blazor-ui/documentation/api/telerik.blazor.components.teleriktextbox), [TextArea overview](https://www.telerik.com/blazor-ui/documentation/components/textarea/overview), [input adornments](https://www.telerik.com/blazor-ui/documentation/common-features/input-adornments), [Form overview](https://www.telerik.com/blazor-ui/documentation/components/form/overview).

| Capability | Blazor and Flutter Web | Remaining difference |
|---|---|---|
| Editing and validation | Live values, model validators, read-only and disabled modes | Native event/validation contracts; no API compatibility |
| Guidance and decoration | Placeholder, helper text, prefix/suffix slots | Short decorative content; not full template replacement |
| Length and multiline | Positive limits; TextArea 1–30 rows | Browser UTF-16 versus Flutter grapheme limits; Flutter native counter; no auto-resize |
| Focus and commit | Blazor FocusAsync / native change; Flutter FocusNode / submit action | Blur and multiline Enter timing differ |
| Async form submission | Validation, invalid callback, busy guard, localized status/error, retry | Server idempotency, cancellation and external side effects belong to app |
| Reset | Replace model/key to reset drafts and validation | No automatic draft persistence or schema generation |
| Appearance and advanced text APIs | Shared original theme | Size/fill variants, clear/password modes and debounce remain open |
| Form layout/schema | Explicit children | Automatic model fields, conditional schema, templates and column API remain open |
| Certification | Web scenario checks | Native/mobile and full screen-reader audit deferred |


## AutoComplete, ComboBox and MultiSelect audit (0.30)

Sources: [AutoComplete filtering](https://www.telerik.com/blazor-ui/documentation/components/autocomplete/filter), [ComboBox templates](https://www.telerik.com/blazor-ui/documentation/components/combobox/templates), [ComboBox overview](https://www.telerik.com/blazor-ui/documentation/components/combobox/overview), [MultiSelect API](https://www.telerik.com/blazor-ui/documentation/api/telerik.blazor.components.telerikmultiselect-2).

| Capability | Both Web implementations | Difference / open scope |
|---|---|---|
| Local filtering | contains/startsWith/endsWith; nonnegative minimum query length | Native datalist may further filter; no locale-specific collation |
| Value contracts | AutoComplete free text; ComboBox IDs and invalid draft validation; MultiSelect copied ID lists | No arbitrary model mapping or custom values in ComboBox/MultiSelect |
| Read-only and disabled | Editors block selection changes; readonly MultiSelect still filters | Native focus/popup behavior differs |
| Templates | ComboBox items; MultiSelect items and tags; model accessible names retained | No AutoComplete, header/footer or summary templates |
| Clear and bulk actions | ComboBox clear; MultiSelect atomic Select filtered and Clear selection | Bulk is original Nextgen behavior; disabled selections stay locked |
| Limits and dynamic data | Positive selection limits, unique IDs, selected-label refresh and controlled validation | Parent owns missing IDs and external over-limit values |
| Empty state and popup | Blazor ComboBox and both MultiSelect empty text | Flutter ComboBox closes empty popup; MultiSelect remains inline checklist |
| Keyboard and accessibility | Native traversal; Flutter ComboBox active-option highlight | Full focus and screen-reader audit, mobile/native remain open |
| Remote data and performance | Local collections only | OnRead, cancellation/debounce, virtualization and ValueMapper remain open |
| Appearance and advanced behavior | Original shared theme | Grouping, popup settings/close events, full localization and appearance variants remain open |


## Numeric and time editing block (0.31)

| Capability | Implemented on both Web platforms | Remaining gap |
|---|---|---|
| Numeric bounds | Retained invalid drafts, form errors, inclusive limits | Parent model validation remains application-owned |
| Numeric increment | Labelled increase/decrease, positive step, clamping, read-only | Culture/currency formatting, precision policy and acceleration |
| Time intervals | MinuteStep dividing 60, input and picker validation, read-only | Restricted-minute popup, disabled-time lists, custom formats and time zones |
| Pending Flutter dialogs | Ignore results after parent rebuild, editor change or disposal | Dialog cancellation/automatic dismissal is not implemented |


## Calendar and date editors (0.32)

Sources: [Calendar API](https://www.telerik.com/blazor-ui/documentation/api/telerik.blazor.components.telerikcalendar), [DatePicker API](https://www.telerik.com/blazor-ui/documentation/api/telerik.blazor.components.telerikdatepicker-1), [DateRangePicker overview](https://www.telerik.com/blazor-ui/documentation/components/daterangepicker/overview).

| Capability | Both Web implementations | Difference / open scope |
|---|---|---|
| Read-only | Calendar, DateInput, DatePicker and DateRangePicker block edits | Calendar navigation is also blocked; native focus differs |
| Bounds and unavailable dates | Inclusive bounds, invalid configuration rejection, range endpoint predicates | Excluded days inside an otherwise valid range are allowed |
| Empty/invalid drafts | Optional clearing, retained invalid input, form validation | Blazor single-date external model validation remains application-owned |
| Controlled range | Parent replacement participates in Flutter validation | Unchanged-value draft reset requires a new key |
| Calendar presentation | Single date; platform calendar navigation | Multi-select, shared range highlighting, week numbers, multiple views and templates remain open |
| Formatting/localization | ISO editor text; framework-specific calendar locale | Segmented/custom-format input and unified localization remain open |
| Popup and accessibility | Existing Escape/dismissal behavior, guarded Flutter results | Full popup event API, keyboard parity, screen-reader and native/mobile certification remain open |

This block is not a full-parity verdict. See verification history for automated and foreground Chrome evidence.


## RadioGroup and DropDownList (0.33)

Sources: [DropDownList overview](https://www.telerik.com/blazor-ui/documentation/components/dropdownlist/overview), [RadioGroup layout](https://www.telerik.com/blazor-ui/documentation/components/radiogroup/layout), [RadioGroup API](https://www.telerik.com/blazor-ui/documentation/api/telerik.blazor.components.telerikradiogroup-2).

| Capability | Both Web implementations | Remaining difference |
|---|---|---|
| User selection | Read-only/disabled, item disabled state, nonempty unique IDs | Read-only uses disabled interaction; focus behavior differs from text editors |
| Radio layout and content | Horizontal/vertical, decorative templates with model accessible names, helper text | Horizontal default retained; label-position and full appearance API remain open |
| Dynamic dropdown items | Unknown selected key stays visible and fails form validation; replacement recovers | No implicit fallback selection; parent owns clearing |
| Flutter popup races | Reject callbacks after rebuild/disposal before mutating field/model | Dialog dismissal and cancellation API remain open |
| Empty selection | Blazor empty placeholder option; Flutter null hint | Flutter has no clear command; required rules belong to application |
| Data and advanced presentation | Local NgOption collections | Remote data, filtering, virtualization, grouping and popup templates remain open |
| Certification | Automated tests and visible Chrome evidence | No full Telerik parity, screen-reader or native/mobile certification |


## Grid selection and paging configuration (0.34)

| Capability | Shared implementation | Remaining boundary |
|---|---|---|
| Protected selection | CanSelect/canSelect and selection read-only; preserve protected and hidden selected IDs | No range or cell selection |
| Page selection | Toggle eligible visible rows only, partial-selection accessible description, controlled immutable callbacks | No select-all-pages operation |
| Presentation | Empty template/widget and configured page sizes; current size retained | No direct page input or localization API |
| Validation | Nonempty unique row IDs and column keys, at least one column | Server loading, virtualization, multi-sort, grouping and built-in CRUD remain open |
| Certification | Blazor/Flutter Web tests and visible local Chrome | No full Telerik, native or screen-reader certification |


## TreeView and TreeList state (0.35)

| Capability | Shared implementation | Remaining boundary |
|---|---|---|
| Controlled state | Callbacks propose selection/expansion; caller accepts or rejects; stale and disabled handlers guarded | Parent owns pruning removed IDs |
| Independent locks | SelectionReadOnly and ExpansionReadOnly; programmatic updates still accepted | These are Nextgen UI controls, not authorization |
| Search | Matching paths temporarily expanded, clearing restores caller expansion; whitespace inactive | Local filtering only |
| Templates | TreeView decorative item content; TreeList first-column cell content; custom empty content | Model labels remain accessible/search names; no interactive template controls |
| Keyboard | TreeView arrows navigate enabled nodes; ArrowRight enters immediate children only; stale leaf expansion ignored | Roving tabindex, focus recovery, type-ahead, multi/check selection and TreeList treegrid semantics remain open |
| Scope | Nested local data, nonempty unique IDs/column keys | Lazy loading, virtualization, drag/drop, server operations and full Telerik parity remain open |

Reference: [Telerik TreeView expansion](https://www.telerik.com/blazor-ui/documentation/components/treeview/expanded-items) and [selection](https://www.telerik.com/blazor-ui/documentation/components/treeview/selection/overview). Contracts above describe Nextgen behavior, not API compatibility.


## Chart interaction and labels (0.36)

| Capability | Shared implementation | Remaining boundary |
|---|---|---|
| Legend visibility | Optional controlled hidden-series set with immutable proposals; internal mode remains default | Series identity is index; parent owns reorder/pruning |
| Independent locks | LegendReadOnly and SelectionReadOnly; programmatic visibility still works | Chart owns point selection; no controlled selection API |
| Data replacement | Keep identical visible selected point; clear hidden/removed/changed points and invalid states; reject stale callbacks | Callers replace input lists; no remote loading contract |
| Point labels | Plain-text formatter for tooltip, point actions, accessible names and status; custom empty text | No axis formatter, arbitrary tooltip template, localization or slice-label layout |
| Scope | Column, bar, line, area, pie and donut | Zoom/pan, stacking, mixed axes, export and full Telerik parity remain open |

Reference: [Telerik Chart legend](https://www.telerik.com/blazor-ui/documentation/components/chart/legend) and [tooltips](https://www.telerik.com/blazor-ui/documentation/components/chart/tooltip/overview). Nextgen uses its own state and formatter API.

## Gauge ranges and readings (0.37)

Both gauges support validated nonoverlapping color ranges, text legends, active status, formatted readings and bounds, and explicit out-of-scale status. Finite extreme bounds are normalized without overflow. Pointers, advanced ticks/scales, animation and export remain open. See [contracts](analytics-and-schedule.md#gauge-ranges-and-formatted-readings-037).

Reference: [Telerik Linear Gauge ranges](https://www.telerik.com/blazor-ui/documentation/components/gauges/linear/ranges). Nextgen uses its own shared range and formatter API.

## Scheduler navigation and actions (0.38)

Day and week agendas with controlled date/view proposals, ISO first weekday, independent editing/navigation locks, disabled missing callbacks, stale-action guards, plain-text event labels and custom empty-day text. Full displayed dates stay in years 2–9998. Month/year/time-slot views, recurrence, resources, drag/drop, resize, timezone conversion, persistence and full parity remain open.

Reference: [Telerik Scheduler navigation](https://www.telerik.com/blazor-ui/documentation/components/scheduler/navigation). Nextgen uses its own agenda and callback contracts; see [scheduler documentation](manual/NgScheduler.md).

## Spreadsheet ownership and protection (0.39)

Controlled immutable proposals with accepted-only history, rejected draft retention, external replacement reconciliation and no-op suppression. CanEdit protects raw cell values while preserving formula inspection and recalculation. Paste validates every supplied destination atomically; undo/redo recheck changed cells against current protection. Missing callbacks and ReadOnly disable editing. Stale callbacks cannot edit a replacement sheet or bypass locks.

Multi-cell selection, clipboard integration, formatting, merged cells, XLSX/CSV, multiple sheets and full Excel/Telerik parity remain open. See [Spreadsheet contracts](manual/NgSpreadsheet.md). Reference: [Telerik Spreadsheet overview](https://www.telerik.com/blazor-ui/documentation/components/spreadsheet/overview).

## Pivot presentation and drilldown (0.40)

Independent row/column total visibility with a grand total when both are enabled. Plain-text aggregate and raw-key label formatters, custom total/empty text, readable locked cells, disabled absent callbacks, stale-action guards and read-only collections of original drilldown records. Formatting preserves raw keys, sorting and weighted source aggregation.

Remaining: nested dimensions, multiple measures, arbitrary content templates, OLAP, configurator, export, virtualization and full parity. See [PivotGrid manual](manual/NgPivotGrid.md). Reference: [Telerik PivotGrid templates](https://www.telerik.com/blazor-ui/documentation/components/pivotgrid/templates).

## Editor ownership and drafts (0.41)

Immutable proposals for text, formatting, block insertion/removal/reorder and Undo/Redo. The parent accepts by returning the exact proposal instance; rejection preserves the accepted document, selection, draft and history. Independent replacement resets history and draft. Discard draft is local, missing callbacks disable mutation, and stale actions after replacement/selection/lock changes or disposal are ignored. Read-only mode preserves document inspection.

Inline rich-text ranges, HTML import, links/images/tables, collaboration and native verification remain open. See [Editor contracts](manual/NgEditor.md). Reference: [Telerik Editor events](https://www.telerik.com/blazor-ui/documentation/components/editor/events); Nextgen uses typed blocks and explicit Apply rather than HTML editing.

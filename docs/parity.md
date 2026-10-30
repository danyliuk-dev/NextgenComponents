# Feature parity with Telerik UI for Blazor

Verification target: Blazor Web and Flutter Web. Reference audit date: 2026-10-19.

An implemented component is not a completed Telerik equivalent. The catalogue status describes availability only. No component currently has verified full feature parity. Public behavior is the target; API compatibility, exact theme pixels and commercial tooling integration are separate concerns.

## Completion rule

A component can be marked complete only after every reference feature is recorded, both implementations and detailed English examples exist, meaningful automated checks and visible Chrome scenarios pass, and remaining differences are explicitly accepted. Unknown is not complete. A test pass proves the tested behavior, not all reference behavior.

## Current work order

1. Chip/ChipList remaining gaps stay tracked below; do not mark full parity or silently accept them. Work is delivered in component blocks, not one release per parameter.
2. ToggleButton/ButtonGroup and Menu/Drawer implementation blocks are delivered with explicit remaining gaps below. Stepper/Wizard is also delivered below; TextBox/TextArea/Form is delivered in 0.29; AutoComplete/ComboBox/MultiSelect is delivered in 0.30; numeric/time editing is delivered in 0.31; Calendar, DateInput, DatePicker and DateRangePicker are delivered in 0.32; RadioGroup and DropDownList are delivered in 0.33; Grid protected/read-only selection is delivered in 0.34; TreeView/TreeList controlled state and templates are delivered in 0.35; Chart interaction and presentation are delivered in 0.36; gauge ranges and presentation are delivered in 0.37; Scheduler day/week navigation and guarded actions are delivered in 0.38; Spreadsheet controlled edits and cell protection are delivered in 0.39; PivotGrid presentation and guarded drilldown are delivered in 0.40; Editor controlled changes and history are delivered in 0.41; Diagram guarded interaction and presentation are delivered in 0.42; Map controlled state and interaction locks are delivered in 0.43; PDF lazy thumbnails and synchronized navigation are delivered in 0.44; AI Prompt independent permissions and PromptBox length recovery are delivered in 0.45; text-field clear actions and password presentation are delivered in 0.46; bounded TextArea autosizing is delivered in 0.47; 0.48 text editor appearance and 0.49 debounced notifications delivered; responsive form fields/actions are delivered in 0.50; live customizable validation summaries are delivered in 0.51; responsive field spans are delivered in 0.52; rounded editors and flat fill are delivered in 0.53; named form sections are delivered in 0.54; nested form sections are delivered in 0.55; controlled section expansion is delivered in 0.56; IME-aware text notifications are delivered in 0.57; date range presets and atomic clearing are delivered in 0.58; configurable text counters are delivered in 0.59; 0.60 adds Grid remote paging/search/multi-sort and lazy TreeView/TreeList children at the user's request; 0.61 adds independent controlled tree checkboxes; 0.62 adds cascade over loaded tree records with partial state; 0.63 adds explicit bulk loaded-tree checking; 0.64 adds local Grid grouping; 0.65 completes the bounded local grouping workspace; 0.66 adds server grouping and HTTP adapters; 0.67 delivers single-record Grid editing; 0.68 delivers the bounded CSV/TSV export workflow; 0.69 adds fixed-height virtual rendering of local Grid results, loaded remote pages and loaded expanded trees; 0.70 adds bounded continuous remote Grid ranges. No block is a full-parity verdict.
3. Continuous remote range scrolling is delivered in 0.70. Grouped remote range loading is delivered in 0.71; see docs/roadmap.md for the remaining blocks and release criteria. Continue through existing editors/forms, data management, visualization and complex editors. Add new component names only after closing the active group or recording a user-approved exception.

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
| Length and multiline | Positive limits; TextArea 1–30 rows | Browser UTF-16 versus Flutter grapheme limits; Flutter native counter; bounded autosizing added in 0.47 |
| Focus and commit | Blazor FocusAsync / native change; Flutter FocusNode / submit action | Blur and multiline Enter timing differ |
| Async form submission | Validation, invalid callback, busy guard, localized status/error, retry | Server idempotency, cancellation and external side effects belong to app |
| Reset | Replace model/key to reset drafts and validation | No automatic draft persistence or schema generation |
| Appearance and advanced text APIs | Shared original theme | Size/fill variants delivered in 0.48 and debounced notifications in 0.49; rounded presets/flat fill delivered in 0.53; arbitrary border styling remains application-owned |
| Form layout/schema | Explicit children | Responsive explicit field columns/actions delivered in 0.50; automatic model fields and conditional schemas remain open; spans delivered in 0.52 and named sections in 0.54 |
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
| Controlled range | Parent replacement participates in Flutter validation | Preset/clear actions repair unchanged-value drafts in 0.58; other external draft resets require a new key |
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

## Diagram interaction and presentation (0.42)

Independent movement and selection locks, missing-handler disabling, parent-controlled move proposals and plain-text node/edge label formatters. Parameter changes and zoom cancel drag previews; stale keyboard/pointer/selection actions cannot alter replacement graphs, including reused node IDs. Blazor also rechecks graph identity and permissions after awaited selection callbacks. Custom empty text preserves viewport navigation.

Auto layout, obstacle routing, drag-to-connect, resize handles, groups, templates, export and native verification remain open. See [Diagram contracts](manual/NgDiagram.md). Reference: [Telerik Diagram events](https://www.telerik.com/blazor-ui/documentation/components/diagram/events). Nextgen retains its own typed graph API.

## Map ownership and interaction locks (0.43)

Independent navigation, selection and background-click locks. Selection follows accepted parent state; supplied view callbacks enable controlled navigation with rejection reconciliation and no feedback events. Without a view callback, navigation remains local. Revision-tagged iframe events reject stale actions, unknown IDs and malformed coordinates. Empty text is configurable; cluster navigation respects locks.

GeoJSON, vector/bubble layers, routing, editing, offline/export and native Flutter support remain open. See [Map contracts](manual/NgMap.md). Reference: [Telerik Map events](https://www.telerik.com/blazor-ui/documentation/components/map/events). Nextgen uses its own typed models and Leaflet-backed Web renderer.

## PDF thumbnails (0.44)

Collapsible numbered page rail with native keyboard buttons, current-page indication and synchronization with toolbar/search navigation. Visible previews render sequentially at bounded resolution and release canvases on scroll, close and document replacement. Narrow layout and dark theme are supported on both Web platforms.

Passwords, print, annotations/forms/signatures, links, OCR, parent page/load callbacks and native Flutter support remain open. See [PDF Viewer contracts](manual/NgPdfViewer.md).

## AI prompt permissions and draft validation (0.45)

Independent generation, history-clear and feedback locks with global read-only support, missing-handler disabling and action-time guards. Generation locks cancel pending work without removing previous responses. PromptBox preserves oversized drafts after limit reductions, disables Send and permits incremental correction.

Streaming, rich output, attachments, speech, command templates, model selection, durable conversations, built-in provider integration and native verification remain open. See [AI contracts](ai-interface.md).

## Text clear actions and password presentation (0.46)

TextBox and TextArea provide opt-in clear actions, form updates and restored editor focus. TextBox additionally supports masked single-line input and optional reveal. Empty, locked or disabled fields cannot clear; locked/disabled password fields cannot reveal. Flutter guards retained callbacks after controller replacement and preserves initialValue form reset.

Automatic resize, appearance variants and debounced notifications were added in 0.47–0.49. Password-manager integration and native certification remain open. See [text and form capabilities](forms-and-dates.md).

## Bounded TextArea autosizing (0.47)

Opt-in AutoSize with Rows as minimum and MaxRows as maximum (1–30); growth for line breaks and wrapping, internal scrolling at the cap, shrinking on clear/external replacement, width changes and read-only content. Fixed mode retains its previous layout. Blazor packages its measurement module; Flutter uses native minLines/maxLines. Resizing emits no value callback.

Equal row counts do not imply identical pixel metrics. Rounded presets/flat fill arrived in 0.53; accessibility/native certification remains open. See [TextArea manual](manual/NgTextArea.md).

## Text editor appearance (0.48)

TextBox and TextArea expose small/medium/large sizes and theme/outline/filled backgrounds. Defaults inherit existing density and decoration. Appearance changes preserve editor/form state and automatic TextArea sizing; platform focus/error borders and native action hit targets remain intact.

Debounced notifications were added in 0.49. Arbitrary border styling, generated form schemas and accessibility/native certification remain open. See [text and form capabilities](forms-and-dates.md).

## Debounced text notifications (0.49)

Optional delayed notifications for TextBox and TextArea preserve immediate binding and validation. Bursts coalesce; locks, changed delay, external replacement, handler removal and disposal cancel pending work. Commit/submit remains independent. Examples expose notification counts without echoing password values.

Application request cancellation, arbitrary border styling and generated form schemas remain open. See [text and form capabilities](forms-and-dates.md).

## Responsive form fields and actions (0.50)

Explicit field lists support up to four columns, a preferred minimum cell width and configurable gaps. Layout follows available container width and preserves field/form state on resize. Custom action slots stay outside the grid; validation and busy/disabled guards remain active.

Automatic model editor generation, conditional schemas and native/accessibility certification remain open. See [Form manual](manual/NgForm.md).

## Live validation summaries (0.51)

Localized default headings and message lists, custom summary templates with read-only message snapshots, visibility controls and live error updates. Presentation changes preserve field state; hiding a summary never disables validation. Blazor follows EditContext notifications, while Flutter refreshes after field changes following a submit attempt.

Automatic editor generation, conditional schemas, error-to-field focus mapping and native/accessibility certification remain open. See [Form manual](manual/NgForm.md).

## Responsive form field spans (0.52)

Explicit per-field spans (1–4) and full-row fields (0), clamped to available columns. Fields flow in source order without dense reordering, retain state across span changes and collapse safely on narrow screens. Blazor uses container queries with a one-column fallback; Flutter uses Wrap.

Automatic model/schema generation, conditional schemas, vertical spans and native/accessibility certification remain open. See [Form manual](manual/NgForm.md).

## Rounded text editors and flat fill (0.53)

Both text editors provide theme/none/small/medium/large/full corners and an opt-in flat fill. Idle borders disappear without changing dimensions; focus and error indicators remain in the supplied theme. Appearance updates retain text, selection, focus and validation. Flutter retains explicit theme border sides and outline/underline kinds. Original values and platform-specific borders are not pixel/API parity.

Reference: [TextBox appearance](https://www.telerik.com/blazor-ui/documentation/components/textbox/appearance). Arbitrary border styling and full accessibility/native certification remain open.

## Named form sections (0.54)

NgForm accepts explicitly defined sections with stable IDs, plain-text titles/descriptions and independent responsive columns, gaps and field spans. All sections share one validation context, summary and guarded submit. Whole-section reordering retains state and focus. Blazor uses fieldset/legend; Flutter uses semantic headings. No new catalog component is counted.

Recursive nesting is available in 0.55; controlled expansion is available in 0.56; automatic editors and conditional schemas remain open. Removing sections has platform-specific validation semantics; switching content modes can rebuild editor state. See [Form manual](manual/NgForm.md).

## Nested form sections (0.55)

Section branches accept child sections instead of fields. One form owns validation and submission for all descendants. Stable sibling IDs preserve descendant state during reorder; IDs can repeat under different parents. The tree is validated before rendering: exactly one content list per node, leaf-only spans, unique sibling IDs, no cycles and at most eight levels.

Wrapping/unwrapping or moving a node across parents can recreate editor state. Controlled expansion is available in 0.56; automatic schemas, conditional visibility and full accessibility/native certification remain open. See [Form manual](manual/NgForm.md).

## Controlled form section expansion (0.56)

Expanded defaults to true. An expansion callback adds a disclosure button that requests the next state; the application accepts or rejects it. Hidden descendants stay mounted and validated, preserving editor state. Disabled/busy forms and collapsed ancestors block toggles; replaced/disposed callbacks are guarded. Blazor exposes aria-expanded/controls; Flutter excludes hidden focus and pauses tickers.

Validation does not auto-expand invalid groups. Applications must provide access to hidden errors and manage focus for external collapse. Conditional schemas and full accessibility/native certification remain open. See [Form manual](manual/NgForm.md).

## IME-aware text notifications (0.57)

TextBox/TextArea suppress delayed notifications during composition and restart the delay on completion, including unchanged strings and zero delay. Draft binding and validation remain immediate. Clear, locks and external replacements retain their cancellation behavior. Flutter Web also observes native composition events for semantics mode; controller/reset ownership is retained.

Application request cancellation, physical OS IME keyboards and native mobile certification remain separate work. See the editor manuals and [verification](verification.md).

## Date range presets and clearing (0.58)

Named presets apply both endpoints atomically through one range callback. Bounds, disabled endpoint rules, explicit preset locks and read-only/disabled state guard activation. Reapplying a preset or clearing repairs both invalid drafts; clear emits null. Removed/replaced descriptors and disposed Flutter callbacks are guarded. Presets wrap on narrow containers.

Relative periods remain application-owned. Interior dates are not checked, and resetting both editors closes pickers and loses local focus/selection. Shared dual-calendar highlighting, native targets and accessibility certification remain open. See [DateRangePicker manual](manual/NgDateRangePicker.md).

## Configurable text counters (0.59)

TextBox and TextArea support native/hidden/used/remaining counter modes and plain-text localization callbacks. Counters update for drafts, clear, external replacement and IME without changing binding or notification timing. Hidden counters retain length enforcement; remaining mode requires a limit. Existing default platform presentation is preserved.

Counts follow native limits: UTF-16 in Blazor, grapheme clusters in Flutter. Overlong external values are not truncated. Server length rules and physical screen-reader verification remain application-owned or unverified. See both editor manuals.

## Remote Grid and lazy hierarchy (0.60)

Grid async adapters receive page, size, search and ordered sort descriptors; return a page and filtered total. Stable local multi-sort shares the same descriptors. Loading, localized error/retry, source-version invalidation and stale-response guards are implemented on both Web platforms. Blazor supplies cancellation tokens; Flutter discards obsolete futures without transport cancellation. Shrinking totals trigger a corrected page read.

TreeView/TreeList load HasChildren branches on explicit expansion and cache successful results, including empty branches. Root/loader/version replacement invalidates pending work and cache. Duplicate IDs are rejected across resolved data. Lazy branches start collapsed; search sees only loaded records. Selection/expansion remain controlled and guarded after awaits.

Remaining: Grid virtualization, grouping, built-in CRUD; tree virtualization, full-remote cascading checkbox selection, drag/drop, remote filtering/sorting and complete keyboard/accessibility parity. The examples simulate network latency in their adapters; no backend protocol or database provider is bundled.

Public reference audit: [Grid manual operations](https://www.telerik.com/blazor-ui/documentation/components/grid/manual-operations), [TreeView load on demand](https://www.telerik.com/blazor-ui/documentation/components/treeview/data-binding/load-on-demand). These guide behavior, not API compatibility.

## Independent tree checkboxes (0.61)

TreeView and TreeList expose opt-in, controlled checked-ID sets on both Web platforms. Checking is independent of row selection and expansion. Read-only state, a node predicate, disabled nodes and absent callbacks protect changes. Each accepted request supplies a fresh set without pruning hidden, collapsed or unknown IDs. Localized accessible labels and keyboard Space are supported. Checking unloaded parents never fetches or checks children.

Loaded cascading/partial checks are delivered in 0.62. Loaded bulk actions are delivered in 0.63. Remaining: full-remote cascade, tree virtualization, drag/drop, remote filtering/sorting, native targets and full accessibility certification. Grid virtualization, grouping and built-in CRUD remain open. See both tree manuals.

## Cascading loaded tree checks (0.62)

Opt-in CheckChildren/checkChildren applies a single proposed checked-ID set to the parent record plus eligible loaded descendants. Mixed state means some of those records are checked; activating mixed selects the whole eligible branch, while activating checked clears it. Filtering and collapse do not change that scope. Protected/disabled nodes are subtree barriers and preserve their existing IDs. Unknown IDs are retained. Default independent behavior is unchanged.

Lazy loading never inherits checks or emits a checking callback. Newly loaded descendants can make the parent mixed. The parent record participates in aggregation; independently checking all children does not insert its ID. Mode/predicate/data changes recompute display without normalizing application state. Full-remote cascade, upward ID normalization, virtualization, drag/drop and native/accessibility certification remain open.

Current Flutter Web SDK maps its internal mixed checkbox state to aria-checked=false in the legacy DOM role; a localized partialCheckText spoken value supplies partial-state information. Native Flutter semantics tests see CheckedState.mixed. Exact Web ARIA parity and physical screen-reader behavior remain unverified.

## Bulk loaded-tree checking (0.63)

TreeView and TreeList expose opt-in check-loaded and clear-loaded actions. Their scope is the entire eligible loaded forest, independent of filtering, expansion and per-node cascade mode. Protected/disabled roots and subtrees are skipped; unknown/protected IDs are preserved. One fresh set is proposed per action, with parent acceptance/rejection. No-op, empty, read-only and missing-callback actions are disabled. Current data and permissions are rechecked when invoked. Lazy loads update availability without inheriting checks. Labels are localizable.

Full-remote checking, upward ID normalization, virtualization, drag/drop and native/accessibility certification remain open. The Flutter mixed-state ARIA limitation documented in 0.62 is unchanged.

## Local Grid grouping (0.64)

GroupBy/groupBy enables one local grouping level. Search and stable sorting run before grouping; groups follow first appearance and retain row order within each group. Paging counts data rows only. Headers repeat when a group crosses a page boundary and display the full filtered count, with a customizable plain-text caption. Group headers cannot be selected; page selection affects only eligible visible data rows and preserves off-page IDs.

Enabling/disabling grouping resets the page; use DataVersion/dataVersion after changing a grouping rule. Empty string keys are valid and keys are case-sensitive. Selectors must be pure. Combining grouping with ReadData/readData is rejected before requests because server pages cannot supply whole-group counts. Collapse, multiple grouping levels, aggregates, remote grouping, virtualization and built-in CRUD remain open.

## Local Grid grouping workspace (0.65)

Local grouping now supports up to eight ordered levels, controlled per-path collapse/expand, filtered expand-all/collapse-all, localized actions and independent expansion locks. Full-path IDs distinguish repeated child labels and preserve hidden/unknown state. Changing rules uses DataVersion. Collapse happens after record paging, retaining page ranges and repeated ancestor headers. Selection includes eligible rendered data rows only and retains hidden selections. Rejected and stale actions do not bypass current state or permissions.

Numeric group summaries support sum, average, min, max and count with custom formatting. Every level aggregates its full filtered records before paging/collapse; parent averages are record-weighted. Null and nonfinite values are excluded. Count counts finite numeric values; group headers count all records. Calculations use double precision. Demo controls switch grouping, nesting, totals and expansion locks on both platforms. See the Grid manual for complete contracts.

Remote grouping requires a separate group-aware loading protocol and remains unsupported. Virtualization, built-in CRUD, drag-to-group UI, aggregate footers/templates and native/accessibility certification remain open. This is a complete bounded local grouping block, not a claim of full Telerik parity.

## Remote Grid grouping and HTTP adapters (0.66)

A separate grouped request/response protocol carries ordered field keys, paged records with full group paths, full filtered counts and server numeric summaries. Both platforms validate an entire envelope before showing it. Malformed paths, counts, missing/duplicate metadata, nonfinite summaries and interleaved groups fail into error/retry. Requests are snapshotted; reader/key/version changes invalidate older results. Shrinking totals trigger a corrected page request. Blazor propagates cancellation; Flutter discards obsolete futures.

Controlled collapse keeps record page ranges and never requests data. Bulk actions explicitly affect current page groups, preserving off-page IDs. Selection covers eligible rendered rows. Both Web galleries use a shared real HTTP fixture endpoint with delay, failure, malformed-response and smaller-dataset controls. Reference in-memory adapter helpers and JSON contracts are documented in the remote grouped-data manual.

Database providers/query translation, lazy group paging, virtualization, CRUD/export and native/accessibility certification remain separate work. Server totals are checked for consistency, not independently recomputed by the client. The next data-management block should be scoped as a complete workflow rather than individual parameters.
## Grid create, edit and delete workflows (0.67)

Both platforms now provide an opt-in single-record inline editor with isolated string drafts, required/custom validation, asynchronous persistence, safe application errors and retry, cancellation, confirmed deletion and current-record permissions. Persistence remains application-owned. Repeated submissions are blocked; removed records, source changes and obsolete completions cannot apply stale UI results. Successful writes refresh local grouping or the current remote query and clamp shrinking pages. Selection remains caller-owned.

The editable inventory demonstrates the whole workflow, protected rows, duplicate-name validation and delayed failures. See [Grid editing](manual/grid-editing.md). Custom editor templates, batch/cell editing, database providers, export, virtualization and native/accessibility certification remain open. The next substantial block is Grid export with query/column scope, formatting, escaping and runnable examples on both Web platforms.
## Grid CSV/TSV export workflows (0.68)

Both Web platforms provide opt-in page, full-filtered and selected-filtered export, ordered column subsets and plain-text formatting. Group headers and aggregate rows are excluded. Page scope exports rendered records; full scopes include collapsed/off-page local records. Full remote scopes require a separate bounded adapter carrying query, sort, grouping and selection snapshots. Export never mislabels a downloaded page as a complete server dataset.

CSV/TSV generation includes UTF-8/BOM options, headers, quoting, CRLF records, Unicode and formula-like text protection. Row/character caps fail without truncation. Single-flight preparation supports cancellation, safe errors, retry and invalidation on source/permission changes. Both demos preview the result and download a real file. See [Grid export](manual/grid-export.md).

XLSX/PDF output, streaming server exports, database providers, virtual scrolling, batch/cell editing and native/accessibility certification remain open. The next substantial data block is virtual scrolling for large Grid and tree datasets, with explicit local/remote boundaries, selection/focus behavior and performance verification.
## Virtual data rendering (0.69)

Blazor and Flutter Web support opt-in fixed-height virtualization for Grid, TreeView and TreeList. Local Grid covers all filtered expanded records; remote Grid keeps its existing page contract and pager; trees cover loaded expanded nodes. Selection remains caller-owned, and TreeView keyboard navigation crosses virtual windows. See [Virtual data](manual/virtual-data.md) for runnable 10,000-record demos and exact boundaries.

Remaining: continuous remote range loading, lazy group paging, variable-height rows, column virtualization, full treegrid keyboard semantics and native/screen-reader certification. This is bounded rendering, not bounded application data memory.
## Continuous remote Grid ranges (0.70)

Both Web platforms offer a separate ReadRange/readRange adapter for flat results up to 100,000 records. Exact offset/count envelopes, bounded windows, error/retry, stale-result rejection and query resets preserve caller-owned selection. Window selection/export includes overscan; full remote export still needs an explicit adapter. Existing paged adapters are backward compatible. See [Remote ranges](manual/remote-ranges.md).

Remote grouped ranges, variable row heights, column virtualization and native/screen-reader certification remain open.

## Grouped remote ranges (0.71)

ReadGroupedRange/readGroupedRange adds group-aware visible-slot windows after controlled server collapse. Exact metadata validation, bounded client retention, stale-response rejection, retry, shrink correction and record-only window selection/export are covered by tests. Existing paging and flat-range adapters remain compatible. See [Grouped remote ranges](manual/grouped-remote-ranges.md).

Variable-height rows, column virtualization, batch/cell editing and native/accessibility validation remain open. See [work plan](roadmap.md). Earlier release sections describe historical checkpoints; later sections supersede their Remaining lists.


## Cell editing and custom editors (0.72)

Paired Blazor/Flutter Web cell editors reuse full-record validation and asynchronous persistence. Custom templates/builders receive guarded string values and disabled state. One active cell, retained drafts, explicit Save/Cancel, conflict/retry and stale-callback rejection. Full-row editing remains available. Batch edits, spreadsheet keyboard navigation and variable-height rows remain open. See [Grid editing](manual/grid-editing.md#cell-editing-and-custom-editors).


## Batch editing (0.73)

Both Web platforms provide an opt-in bounded create/update/delete queue, full-record review, per-entry undo, discard and one immutable persistence callback. Success clears and refreshes; failure retains; permissions/validation are rechecked, stale completions ignored. Off-page remote records retain their original UI permission snapshot; authorization, atomicity, concurrency and idempotency belong to the application. Released with website 1.0.15 and three native installer checks on 2026-10-30. Spreadsheet keyboard navigation, variable row heights, column virtualization and durable mutation queues remain separate.

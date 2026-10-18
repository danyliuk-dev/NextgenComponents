"""Keep the reference inventory explicit: foundation is never a full-parity verdict."""
import json
from pathlib import Path
root = Path(__file__).resolve().parents[1]
catalog = json.loads((root/'docs/catalog.json').read_text())
lines = ['# Feature parity with Telerik UI for Blazor', '',
'Verification target: Blazor Web and Flutter Web. Reference audit date: 2026-10-18.', '',
'An implemented component is not a completed Telerik equivalent. The catalogue status describes availability only. No component currently has verified full feature parity. Public behavior is the target; API compatibility, exact theme pixels and commercial tooling integration are separate concerns.', '',
'## Completion rule', '',
'A component can be marked complete only after every reference feature is recorded, both implementations and detailed English examples exist, meaningful automated checks and visible Chrome scenarios pass, and remaining differences are explicitly accepted. Unknown is not complete. A test pass proves the tested behavior, not all reference behavior.', '',
'## Current work order', '',
'1. Chip/ChipList remaining gaps stay tracked below; do not mark full parity or silently accept them. Work is delivered in component blocks, not one release per parameter.',
'2. Active block: ToggleButton and ButtonGroup together (commands, selection, events, templates, appearance and accessibility). Then audit Menu/Drawer and Stepper/Wizard as paired blocks.',
'3. Continue through existing editors/forms, data management, visualization and complex editors. Add new component names only after closing the active group or recording a user-approved exception.', '',
'## Chip and ChipList feature matrix', '',
'Sources: [Chip API](https://www.telerik.com/blazor-ui/documentation/api/telerik.blazor.components.telerikchip), [Chip appearance](https://www.telerik.com/blazor-ui/documentation/components/chip/appearance), [Chip events](https://www.telerik.com/blazor-ui/documentation/components/chip/events), [ChipList binding](https://www.telerik.com/blazor-ui/documentation/components/chiplist/data-bind), [ChipList templates](https://www.telerik.com/blazor-ui/documentation/components/chiplist/templates), [ChipList appearance](https://www.telerik.com/blazor-ui/documentation/components/chiplist/appearance), [keyboard demo](https://demos.telerik.com/blazor-ui/chiplist/keyboard-navigation), [RTL reference](https://www.telerik.com/blazor-ui/documentation/globalization/rtl-support), [ARIA reference](https://www.telerik.com/blazor-ui/documentation/components/chiplist/accessibility/wai-aria-support).', '',
'| Feature | Blazor | Flutter Web | Verification / remaining difference |',
'|---|---|---|---|']
rows = [
('Text and disabled state','Implemented','Implemented','Rendering/widget tests; Chrome. Static Flutter labels have no artificial checked state in 0.15.'),
('Single/multiple/none selection','Implemented','Implemented','Controlled IDs; tests and Chrome. Defaults differ from Telerik ChipList.'),
('Remove request and cancellation','Equivalent contract','Equivalent contract','Parent accepts/rejects, owns removal. Tested; no Telerik event-args API.'),
('Independent click event','Implemented','Implemented','0.15: click follows selection, removal is separate; disabled action tests.'),
('Conditional per-item removal','Implemented','Implemented','CanRemove predicate; no property-name reflection. Tests and Chrome.'),
('Three sizes','Implemented','Implemented','sm/md/lg; tests and Chrome. Exact pixel parity not claimed.'),
('Rounded corners','Implemented','Implemented','sm/md/lg/full; tests and Chrome. Default full retained for compatibility.'),
('Solid/outline fill','Implemented','Implemented','Tests and Chrome; default outline differs from Telerik.'),
('Five semantic colors','Implemented','Implemented','base/info/success/warning/error; light/dark palette, tests and Chrome.'),
('Per-item color/fill','Equivalent contract','Equivalent contract','NgChipAppearance callback inherits unspecified list defaults.'),
('Custom chip/list content','Implemented','Implemented','RenderFragment / Widget builders with stable accessible labels; compiled manual and Chrome.'),
('Leading icon/avatar and removal icon','Equivalent slots','Equivalent slots','Application-supplied content; no Telerik icon registry/variant API. No image loader is supplied.'),
('Keyboard activation and list movement','Implemented core','Implemented core','0.16: Enter/Space, Delete/Backspace, arrows and Home/End. 0.17 adds one remembered Tab entry and forward/reverse exit; selection-only Blazor semantics added in 0.24.'),
('Focus after removal / public focus API','Implemented / FocusAsync','Implemented / public controller','0.16: next/previous/container recovery; rejection, outside-focus protection and disabled neighbors tested. 0.18: Flutter public controller supports first-action and stable-ID focus, detachment and ownership guards.'),
('Selection listbox/option semantics','Partial: selection-only','Remaining','0.24: Blazor uses listbox/options with selected state when Selectable and no OnRemove callback. Removable lists retain group/buttons so removal stays accessible. Flutter SDK has no listbox/option roles. Type-ahead and screen-reader validation remain open.'),
('Application-model binding','Typed adapter','Typed adapter','NgChipData<T> maps fields through typed selectors and resolves original records by ID. String property-name reflection differs from Telerik; icons use existing templates.'),
('Large collections','No fixed cap / tested 500','No fixed cap / tested 500','0.19 removes the ChipList 50-item guard. Eager rendering; no virtualization or unlimited performance claim. Other component caps unchanged.'),
('Independent Chip accessible name','Implemented','Implemented','0.25: AriaLabel / semanticLabel override the standalone main-chip name independently of visible text and removal. Blazor labelled-by takes precedence; runtime changes preserve selection. Per-item list names still use NgOption.Label.'),
('Public identity, naming and help hooks','Implemented','Platform-specific contract','0.22: Id/Class and AriaLabelledBy/AriaDescribedBy on Blazor; semanticIdentifier/semanticHint on Flutter. Flutter shared heading uses the same application string as label; no DOM-class or labelled-by API equivalence.'),
('Configurable TabIndex','Limited contract: -1/0','Limited contract: -1/0','0.23: Chip actions and the ChipList remembered entry can be skipped during Tab traversal without disabling interaction. Positive indices are not supported; Telerik Chip exposes an integer. List-level setting is a Nextgen extension.'),
('ChipList gap sizing','Implemented presets','Implemented presets','0.23: sm/md/lg spacing (4/8/12) applies to columns and wrapped rows. Default md preserves existing spacing. Original tokens, not exact theme pixels.'),
('RTL/localized action labels','Scoped RTL layout / label hooks','Scoped RTL layout / label hooks','0.21: inherited direction mirrors chip order, wrapped rows, leading/removal placement and Blazor divider; runtime switches preserve selection and focus. Application supplies translations and directional icons. Screen-reader audit remains.'),
('Screen readers / WCAG certification','Not verified','Not verified','Browser inspection is not certification. Keyboard/focus semantics must be completed first.'),
('ThemeBuilder / Telerik icon packages','Not compatible','Not compatible','Original themes/content slots; no commercial tooling compatibility claim.'),
('Native mobile platforms','Deferred','Deferred','User chose Web first. Native validation is a separate phase.')]
lines += ['| '+' | '.join(row)+' |' for row in rows]
lines += ['', '## ToggleButton and ButtonGroup audit (0.26)', '',
'Sources: [ToggleButton overview](https://www.telerik.com/blazor-ui/documentation/components/togglebutton/overview), [ToggleButton appearance](https://www.telerik.com/blazor-ui/documentation/components/togglebutton/appearance), [ButtonGroup overview](https://www.telerik.com/blazor-ui/documentation/components/buttongroup/overview), [button kinds and visibility](https://www.telerik.com/blazor-ui/documentation/components/buttongroup/buttons), [events](https://www.telerik.com/blazor-ui/documentation/components/buttongroup/events).', '',
'| Feature | Blazor and Flutter Web | Remaining difference |', '|---|---|---|',
'| Controlled single/multiple selection and disabled state | Implemented; existing rules retained | Defaults and callback API differ; 50-item cap remains |',
'| Mixed commands and toggles, independent click | Implemented in 0.26 | NgOption predicates and ID callbacks, not declarative Telerik child types/event args |',
'| Visibility without losing selected state | Implemented in 0.26 | Application owns focus after hiding the focused item |',
'| Decorative icons/images and custom content | Implemented slots in 0.26 | No Telerik icon package or built-in image loader |',
'| Size, rounded, five fill modes, eleven color tokens | Implemented in 0.26; shared per-item override | Original theme values/defaults; no exact pixel or ThemeBuilder compatibility |',
'| Identity, accessible names/help, toggle focus | Implemented platform contracts in 0.26 | CSS/DOM hooks are Blazor-only; Flutter uses Semantics and FocusNode |',
'| Keyboard activation | Native Tab/Shift+Tab and Enter/Space | No composite arrow navigation; TabIndex limited to -1/0 |',
'| Layout | Horizontal wrapping and vertical groups | Width belongs to application layout; no dedicated Width parameter |',
'| Other reference APIs | Not complete | Native submit/reset type, arbitrary HTML attributes and full inherited API audit remain; screen-reader certification unverified |',
'', 'No full-parity verdict: the component block is usable and documented, with remaining reference/API gaps recorded above.']
lines += ['', 'Dragging, editable tag input and virtualization are not established requirements in the audited Chip/ChipList references. They are optional extension proposals, not invented parity gaps.', '', 'See [capability notes](chips.md), [verification evidence](verification.md) and the [manual](manual/README.md).', '', '## Complete catalogue inventory', '', 'The inventory includes chart modes as separate entries. “Not assessed” means the full reference feature checklist has not yet been completed; earlier capability documents remain useful evidence for implemented subsets.', '', '| Reference component | Blazor availability | Flutter availability | Full feature audit |', '|---|---|---|---|']
for c in catalog['components']:
    cells=[]
    for platform in ('blazor','flutter'):
        v=c[platform];cells.append('Implemented subset: '+v['component'] if v['component'] else 'Not implemented')
    lines.append(f"| [{c['name']}]({c['reference']}) | {' | '.join(cells)} | "+('Partial — matrix above' if c['name'] in ('Chip','ChipList','ToggleButton','ButtonGroup') else 'Not assessed')+' |')
(root/'docs/parity.md').write_text('\n'.join(lines)+'\n')
print(f"Generated {len(catalog['components'])} parity inventory entries")

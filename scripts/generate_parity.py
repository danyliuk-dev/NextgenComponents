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
'1. Finish the Chip/ChipList audit below: single-tab-stop listbox and selection semantics, model binding and sizing limits, then accessibility and remaining public API differences.',
'2. Audit the existing selection/navigation group (ToggleButton, ButtonGroup, Menu, Drawer, Stepper, Wizard) against complete public reference pages.',
'3. Continue through existing editors/forms, data management, visualization and complex editors. Add new component names only after closing the active group or recording a user-approved exception.', '',
'## Chip and ChipList feature matrix', '',
'Sources: [Chip API](https://www.telerik.com/blazor-ui/documentation/api/telerik.blazor.components.telerikchip), [Chip appearance](https://www.telerik.com/blazor-ui/documentation/components/chip/appearance), [Chip events](https://www.telerik.com/blazor-ui/documentation/components/chip/events), [ChipList binding](https://www.telerik.com/blazor-ui/documentation/components/chiplist/data-bind), [ChipList templates](https://www.telerik.com/blazor-ui/documentation/components/chiplist/templates), [ChipList appearance](https://www.telerik.com/blazor-ui/documentation/components/chiplist/appearance), [keyboard demo](https://demos.telerik.com/blazor-ui/chiplist/keyboard-navigation), [ARIA reference](https://www.telerik.com/blazor-ui/documentation/components/chiplist/accessibility/wai-aria-support).', '',
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
('Keyboard activation and list movement','Implemented core','Implemented core','0.16: Enter/Space, Delete/Backspace, arrows and Home/End. Tab pattern still differs; no single-tab-stop listbox.'),
('Focus after removal / public focus API','Implemented / FocusAsync','Implemented / controller pending','0.16: next/previous/container recovery; rejection, outside-focus protection and disabled neighbors tested. Flutter public controller remains.'),
('Selection listbox/option semantics','Remaining','Remaining','Current group of individual controls differs from reference listbox. Do not claim ARIA parity.'),
('Generic field-name model binding','Remaining','Remaining','NgOption adapters only; additional record fields resolved by stable ID.'),
('Large collections','Remaining','Remaining','Current 50-item guard is an explicit limitation; reference has no documented equivalent cap.'),
('Public ID/class/tab index/labelled-by hooks','Remaining','Remaining','Current Label naming only; platform-specific APIs need a documented equivalent.'),
('RTL/localized action labels','Remaining','Remaining','Remove/empty labels are currently English. RTL keyboard behavior not verified.'),
('Screen readers / WCAG certification','Not verified','Not verified','Browser inspection is not certification. Keyboard/focus semantics must be completed first.'),
('ThemeBuilder / Telerik icon packages','Not compatible','Not compatible','Original themes/content slots; no commercial tooling compatibility claim.'),
('Native mobile platforms','Deferred','Deferred','User chose Web first. Native validation is a separate phase.')]
lines += ['| '+' | '.join(row)+' |' for row in rows]
lines += ['', 'Dragging, editable tag input and virtualization are not established requirements in the audited Chip/ChipList references. They are optional extension proposals, not invented parity gaps.', '', 'See [capability notes](chips.md), [verification evidence](verification.md) and the [manual](manual/README.md).', '', '## Complete catalogue inventory', '', 'The inventory includes chart modes as separate entries. “Not assessed” means the full reference feature checklist has not yet been completed; earlier capability documents remain useful evidence for implemented subsets.', '', '| Reference component | Blazor availability | Flutter availability | Full feature audit |', '|---|---|---|---|']
for c in catalog['components']:
    cells=[]
    for platform in ('blazor','flutter'):
        v=c[platform];cells.append('Implemented subset: '+v['component'] if v['component'] else 'Not implemented')
    lines.append(f"| [{c['name']}]({c['reference']}) | {' | '.join(cells)} | "+('Partial — matrix above' if c['name'] in ('Chip','ChipList') else 'Not assessed')+' |')
(root/'docs/parity.md').write_text('\n'.join(lines)+'\n')
print(f"Generated {len(catalog['components'])} parity inventory entries")

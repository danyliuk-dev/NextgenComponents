"""Generate English manuals from curated examples and current public API declarations."""
from pathlib import Path
import re
from manual_content import D
root=Path(__file__).resolve().parents[1]
out=root/'docs/manual';out.mkdir(exist_ok=True)
help={
'gap':'ChipList spacing preset: sm=4, md=8 (default), lg=12; applies to columns and wrapped rows.',
'tabindex':'0 keeps normal Tab participation; -1 skips forward/reverse Tab while preserving pointer/application focus. Other values are rejected.',
'arialabelledby':'Space-separated existing DOM IDs for the accessible name; takes precedence over Label.',
'ariadescribedby':'Space-separated existing DOM IDs for contextual guidance; see target-element rules.',
'semanticidentifier':'Optional nonblank automation identifier in the Flutter semantics tree; not a widget Key or DOM id.',
'semantichint':'Optional nonblank contextual guidance in the semantics tree; not a visible tooltip.',

'focuscontroller':'Application-owned NgChipListController; one list per controller. See lifecycle and focus rules.',
'removelabel':'Complete nonblank accessible removal name; for ChipList, a callback receiving NgOption.',
'removelabelbuilder':'Pure callback supplying a complete accessible removal name for each NgOption.',
'itemappearance':'Per-item nullable presentation overrides; unspecified values inherit list defaults.',
'canremove':'Pure predicate controlling whether an item offers a remove action.',
'leadingtemplate':'Decorative leading content for an item; no nested interactive elements.',
'leadingbuilder':'Decorative leading widget for an item; no nested interactive controls.',
'removecontent':'Decorative replacement for the remove symbol; accessible action label is retained.',
'removeicon':'Replacement widget for the remove symbol; accessible action label is retained.',
'fillmode':'Chip fill: solid or outline; see the documented defaults.',
'rounded':'Chip corners: sm, md, lg or full.',
'themecolor':'Chip semantic color: base, info, success, warning or error.',
'arialabel':'Optional nonblank main-chip accessible name; labelled-by takes precedence. Visible text and removal names are unchanged.',
'semanticlabel':'Optional nonblank native accessible name for the main chip; null uses label.',
'label':'Visible label or accessible name.','title':'Heading for the section or dialog.',
'value':'Current value; see state ownership and model rules above.',
'valuechanged':'New value for the parent to store and pass back.',
'onchanged':'Store the new value using setState or your state manager.',
'valueexpression':'Expression identifying the model field; @bind-Value supplies it automatically.',
'items':'Input collection. Replace it when changing records or configuration.',
'disabled':'Disable user interaction.','readonly':'Prevent changes while retaining supported viewing actions.',
'childcontent':'Razor content; for a wizard, a RenderFragment<int> receiving the active index.',
'contentbuilder':'Build content for the current zero-based step; keep durable draft state in the parent.',
'validatestep':'Async current-step validation; null/empty allows forward navigation or completion.',
'onfinish':'Completion handler; success disables subsequent completion until reset.',
'linear':'Restrict forward navigation to the next enabled step; earlier steps remain accessible.',
'vertical':'Use a vertical root layout; see the component keyboard and layout rules.',
'selectedid':'Current selected item ID; the parent owns this value.',
'selectedidchanged':'Selected item ID for the parent to store.',
'onselectedidchanged':'Selected item ID for the parent to store.',
'oninvoke':'Enabled leaf command ID; dispatch the application action in this handler.',
'expanded':'Whether the drawer is open; controlled by the parent.',
'expandedchanged':'Requested open state; store it in the parent.',
'onexpandedchanged':'Requested open state; store it with setState or your state manager.',
'overlay':'Use a modal overlay instead of a Push panel.',
'multiple':'Allow multiple selected IDs instead of a single choice.',
'allowempty':'Allow the user to clear the last selection; does not create an initial value.',
'onclick':'Application click handler.','onpressed':'Application action; null disables the button.',
'initialvalue':'Starting field value, not continuous controlled state.',
'controller':'Text controller; do not combine with initialValue. Dispose in its owner.',
'validator':'Return null when valid or a user-facing validation error.',
'required':'Require a nonempty/selected value during form validation.',
'min':'Inclusive minimum.','max':'Inclusive maximum.','placeholder':'Hint displayed for empty input.',
'columns':'Column definitions; see the data model and example.',
'additionalattributes':'Additional HTML/ARIA attributes; do not bypass component validation.',
'generate':'Application-owned async response handler; provider credentials belong on the backend.',
'oncompleted':'Accepted successful response callback; not called for failed/cancelled requests.',
'onfeedback':'Response and helpful/not-helpful/cleared vote.',
'busy':'Request in progress; the parent owns it for a standalone PromptBox.',
'onsubmit':'Trimmed nonempty prompt submitted by the user.',
'oncancel':'Request cancellation; the application owns stopping its transport.',
}
flutter={}
for p in (root/'packages/nextgen_components/lib/src').glob('*.dart'):
 s=p.read_text()
 for m in re.finditer(r'class (Ng\w+)(?:<[^\n]+>)? extends (?:StatefulWidget|StatelessWidget)',s):
  end=s.find('@override',m.end());flutter[m[1]]=(p,s[m.end():end])
def md(s):return s.replace('|','\\|').replace('\n',' ')
index=['# Nextgen Components manual','','Version 0.49.0. Detailed guidance for every public Blazor and Flutter Web component. This documents the implemented API, not full Telerik feature parity.','','Start with [Getting started](getting-started.md) and [Code examples](code-examples.md). See [data models and formulas](models.md) for shared model contracts and [verification](../verification.md) for tested behavior.','','Each page includes a live appearance preview with Blazor / Flutter Web switching, followed by the exact source examples, API tables and integration rules. Start both demos through the desktop launcher to use the embedded previews. Flutter snippets belong inside a State class with the Material and Nextgen imports; the getting-started page supplies the full application shell.','','| Component | Purpose |','|---|---|']
for p in sorted((root/'src/NextgenComponents.Blazor').glob('Ng*.razor')):
 n=p.stem;d=D[n];source=p.read_text();fp,fs=flutter[n]
 lines=[f'# {n} — {d["title"]}','','[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)','','## When to use it','',d['use'],'','## Appearance and live example','',f'[Try the Blazor example](http://127.0.0.1:5180/preview/{n}) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview={n})','','The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.','','## Behavior and practical rules','',d['notes'],'','## Blazor example','','```razor',d['blazor'],'```','','## Flutter example','','```dart',d['dart'],'```','','## Blazor parameters and events','','Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.','','| Parameter | Type | Default / requirement | Purpose |','|---|---|---|---|']
 for m in re.finditer(r'\[Parameter([^\]]*)\]\s*public\s+([^\n{}]+?)\s+(\w+)\s*\{\s*get;\s*set;\s*\}\s*(?:=\s*([^;]+);)?',source):
  attrs,typ,name,default=m.groups();lines.append(f'| `{name}` | `{md(typ)}` | {md("required" if "EditorRequired" in attrs else default or ("false" if typ=="bool" else "0" if typ in ["int","double","decimal"] else "not set"))} | {help.get(name.lower(),"See the behavior rules and model contract above.")} |')
 inherited=re.search(r'@inherits InputBase<(.+)>',source)
 if inherited:
  typ=inherited[1];lines.extend([f'| `Value` | `{typ}` | model value | Current field value. |',f'| `ValueChanged` | `EventCallback<{typ}>` | not set | Value change callback. |',f'| `ValueExpression` | `Expression<Func<{typ}>>` | required | Supplied by @bind-Value; pass explicitly with manual binding. |','| `AdditionalAttributes` | HTML attribute dictionary | null | Extra HTML/ARIA attributes. |'])
 lines+=['','## Flutter parameters and events','','`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.','','| Argument | Type | Purpose |','|---|---|---|']
 for m in re.finditer(r'final\s+(.+?)\s+(\w+(?:,\s*\w+)*)\s*;',fs,re.S):
  typ,names=m.groups()
  for name in re.split(r',\s*',names):lines.append(f'| `{name}` | `{md(typ.strip())}` | {help.get(name.lower(),"See the behavior rules and model contract above.")} |')
 ctor=re.search(r'(?:const )?'+n+r'\(\{.*?\}\);',fs,re.S)
 lines+=['','```dart',ctor[0] if ctor else '// See the source linked below.','```','','## Integration and troubleshooting','','If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.','','Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.','','## Source and complete examples','',f'- [Blazor source]({"../../"+str(p.relative_to(root))})',f'- [Flutter source]({"../../"+str(fp.relative_to(root))})','- [Galleries and launch commands](../../README.md#run)','- [Capability matrix](../catalog.md)','','API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.','']
 (out/(n+'.md')).write_text('\n'.join(lines));index.append(f'| [{n}]({n}.md) | {d["title"]} |')
assert set(D)=={p.stem for p in (root/'src/NextgenComponents.Blazor').glob('Ng*.razor')},'Every public component needs curated manual content'
(out/'README.md').write_text('\n'.join(index)+'\n')
print(f'Generated {len(D)} component manuals')
# The demo browsers use the same reviewed snippets as the manual and compiler checks.
import json
from code_highlight import tokenize
example_data={name:{'title':d['title'],'blazor':d['blazor'],'flutter':d['dart'],'blazorTokens':tokenize(d['blazor'],'razor'),'flutterTokens':tokenize(d['dart'],'dart')} for name,d in sorted(D.items())}
# One generated record per line keeps token assets compact and diffs reviewable.
examples='{\n'+',\n'.join(json.dumps(name)+': '+json.dumps(data,ensure_ascii=False,separators=(',',':')) for name,data in example_data.items())+'\n}\n'
(root/'examples/BlazorGallery/wwwroot/component-examples.json').write_text(examples)
asset=root/'examples/flutter_gallery/assets/component-examples.json';asset.parent.mkdir(exist_ok=True);asset.write_text(examples)

from generate_previews import generate
generate()

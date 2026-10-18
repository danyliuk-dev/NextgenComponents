"""Import the published Telerik component index from a saved HTML page.
Usage: python3 scripts/import_catalog.py /path/to/blazor-ui.html
The source is an inventory reference, not source code or a parity claim.
"""
import sys, re, json
from html import unescape
from pathlib import Path
from urllib.parse import urljoin
root = Path(__file__).resolve().parents[1]
raw = Path(sys.argv[1]).read_text()
section = raw[raw.index('Explore All'):]
section = section[:section.index('<h2', 20)]
previous_path=root/'docs/catalog.json'
previous={i['name']:i for i in json.loads(previous_path.read_text())['components']} if previous_path.exists() else {}
items=[]
first={'Buttons':'NgButton','TextBox':'NgTextBox','Numeric TextBox':'NgNumericTextBox','CheckBox':'NgCheckBox','RadioGroup':'NgRadioGroup','Switch':'NgSwitch','DropDownList':'NgDropDownList','TabStrip':'NgTabs','Dialog':'NgDialog','Tooltip':'NgTooltip','Notification':'NgNotification'}
for match in re.finditer(r'<h3[^>]*>(.*?)</h3>|<a\b([^>]*)>\s*<span>(.*?)</span>', section, re.S):
 if match[1]:
  category=unescape(re.sub('<[^>]+>','',match[1])).strip()
 elif 'category' in locals():
  href=re.search(r'href="([^"]+)"',match[2])
  if not href: continue
  name=unescape(match[3]).strip()
  impl=first.get(name)
  phase=1 if impl else (4 if category in ['Data Visualization','Gauges','Scheduling'] else 3 if category=='Data Management' else 2)
  if name in ['PivotGrid','Spreadsheet','PDF Viewer','Rich Text Editor','Diagram','Map','File Manager'] or category=='AI Interface': phase=5
  items.append(dict(name=name,category=category,reference=urljoin('https://www.telerik.com',href[1]),phase=phase,blazor={'status':'foundation' if impl else 'planned','component':impl},flutter={'status':'foundation' if impl else 'planned','component':impl},featureSpec='docs/foundation.md' if impl else 'Not yet audited; reference page defines the target, no feature parity claimed.'))
for item in items:
 old=previous.get(item['name'])
 if old:
  for key in ['phase','blazor','flutter','featureSpec']: item[key]=old[key]
assert len(items)>100, len(items)
assert len({i['name'] for i in items})==len(items)
(root/'docs/catalog.json').write_text(json.dumps({'source':'https://www.telerik.com/blazor-ui','retrieved':'2026-10-18','scope':'Published Blazor component index, including chart variants; not the union of all Telerik product suites.','components':items},indent=2)+'\n')
lines=['# Component coverage','',f'Snapshot: 2026-10-18. {len(items)} named entries from the [Telerik Blazor index](https://www.telerik.com/blazor-ui). Chart variants count separately.','', '`foundation` means the limited working subset documented in [foundation.md](foundation.md) [forms-and-dates.md](forms-and-dates.md) and [data-workspace.md](data-workspace.md), not Telerik feature parity. `planned` has no implementation yet.','', '| Category | Telerik entry | Blazor | Flutter | Phase |','|---|---|---|---|---|']
for i in items:
 s=i['blazor']['status'];c=i['blazor']['component'];status=f'foundation: `{c}`' if c else s
 lines.append(f"| {i['category']} | [{i['name']}]({i['reference']}) | {status} | {status} | {i['phase']} |")
(root/'docs/catalog.md').write_text('\n'.join(lines)+'\n')
print(f'Imported {len(items)} entries; {sum(i["blazor"]["status"]=="foundation" for i in items)} foundation entries')

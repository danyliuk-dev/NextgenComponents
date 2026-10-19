"""PivotGrid 0.40 checks in dedicated visible Chrome on CDP 9341."""
from chrome_cdp import CDP
from pathlib import Path
import time, sys
c=CDP(); flutter='flutter' in sys.argv
out=Path('artifacts/browser'); out.mkdir(parents=True,exist_ok=True)
def control(label): return f"([...document.querySelectorAll('[aria-label]')].find(e=>e.getAttribute('aria-label')==={label!r})??[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}))"
def check(expr,label):
 assert c.eval(expr),label
 print('PASS',label,flush=True)
def click(label):
 expr=control(label)
 if flutter:c.eval(f'{expr}.click()')
 else:
  xy=c.eval(f'(()=>{{const e={expr};e.scrollIntoView({{block:"center"}});const r=e.getBoundingClientRect();return {{x:r.x+r.width/2,y:r.y+r.height/2}};}})()')
  for t in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=t,button='left',clickCount=1,**xy))
 time.sleep(.45)
def has(text):return f"(document.body.innerText+[...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' ')).includes({text!r})"
def shot(name):c.shot(str(out/f'pivot040-{"flutter" if flutter else "blazor"}-{name}.png'))
c.call('Page.enable');c.call('Page.bringToFront')
c.call('Page.navigate',{'url':'http://127.0.0.1:5181/?preview=NgPivotGrid' if flutter else 'http://127.0.0.1:5180/preview/NgPivotGrid'});time.sleep(3)
if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.6)
check(has('Unassigned'),'blank dimension label')
click('Team A / Period Q1: 40.0 credits');check(has('A / Q1 · 2 records · IDs: a,b'),'raw keys and records')
click('All / All: 130.0 credits');check(has('(total) / (total) · 4 records · IDs: a,b,c,d'),'grand total records')
click('Toggle selection lock')
check(f"{control('Team A / Period Q1: 40.0 credits')}."+('getAttribute("aria-disabled")==="true"' if flutter else 'disabled'),'locked action disabled')
click('Team A / Period Q1: 40.0 credits');check(has('(total) / (total) · 4 records'),'locked click leaves selection')
click('Update values');check(has('260.0 credits'),'replacement values');shot('locked')
click('Toggle selection lock');click('Team A / Period Q1: 80.0 credits');check(has('A / Q1 · 2 records'),'replacement drilldown')
click('Toggle average');check(has('86.7 credits'),'source weighted average')
click('Toggle row totals');check(f"!{control('All / All: 86.7 credits')}",'grand total removed');check(f"!!{control('All / Period Q1: 40.0 credits')}",'column totals retained')
click('Toggle column totals');check(f"!{control('All / Period Q1: 40.0 credits')}",'both totals hidden');shot('totals')
click('Toggle row totals');check(f"!!{control('Team A / All: 40.0 credits')}",'row totals independently restored')
click('Toggle column totals');check(has('86.7 credits'),'grand total restored')
click('Toggle empty data');check(has('No matching deliveries'),'custom empty state');click('Toggle empty data');check(has('86.7 credits'),'restore data')
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});c.call('Page.reload');time.sleep(3)
check('document.documentElement.scrollWidth<=innerWidth','narrow page no overflow');shot('narrow')
c.call('Emulation.clearDeviceMetricsOverride');c.s.close()

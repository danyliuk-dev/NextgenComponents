"""Scheduler 0.38 interaction in dedicated foreground Chrome (CDP 9341)."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
c=CDP();flutter='flutter' in sys.argv
out=Path('artifacts/browser');out.mkdir(parents=True,exist_ok=True)
def check(expr,label):
 assert c.eval(expr),label
 print('PASS',label,flush=True)
def control(label):return f"([...document.querySelectorAll('[aria-label]')].find(e=>e.getAttribute('aria-label')==={label!r})??[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}))"
def click(label):
 expr=control(label)
 if flutter:c.eval(f'{expr}.click()')
 else:
  xy=c.eval(f'(()=>{{const e={expr};e.scrollIntoView({{block:"center"}});const r=e.getBoundingClientRect();return {{x:r.x+r.width/2,y:r.y+r.height/2}};}})()')
  for t in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=t,button='left',clickCount=1,**xy))
 time.sleep(.5)
def content():return "document.body.innerText + [...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' ')"
def has(text):return f'({content()}).includes({text!r})'
def shot(name):c.shot(str(out/f'scheduler038-{"flutter" if flutter else "blazor"}-{name}.png'))
c.call('Page.enable');c.call('Page.bringToFront')
c.call('Page.navigate',{'url':'http://127.0.0.1:5181/?preview=NgScheduler' if flutter else 'http://127.0.0.1:5180/preview/NgScheduler'});time.sleep(3)
if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.5)
click('Toggle acceptance');click('Day');check(has('Next week'),'rejected view proposal')
click('Toggle acceptance');click('Day');check(has('Next day'),'controlled day view')
check(has('Shift: Review'),'formatted event label')
click('Toggle acceptance');click('Next day');check(has('Shift: Review'),'rejected date proposal');click('Toggle acceptance')
click('+ Add');check(has('Last action: Create: 2026-10-19'),'create visible day')
click('Toggle editing lock');click('Next day');check(has('Shift: Overnight'),'navigation while editing locked')
check('!'+has('Shift: Review'),'day intersection removes prior event')
shot('day-locked')
click('Toggle editing lock');click('Toggle navigation lock')
# Event caption includes a time span, so match the event button by contained text.
expr="[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.includes('Shift: Overnight')||(e.getAttribute('aria-label')||'').includes('Shift: Overnight'))"
if flutter:c.eval(f'{expr}.click()')
else:c.eval(f'{expr}.click()')
time.sleep(.5);check(has('Last action: Edit: Overnight'),'editing while navigation locked')
click('Reset date');check(has('Next week'),'programmatic view update under navigation lock')
check(has('Navigation locked'),'lock retained after programmatic update')
click('Toggle navigation lock');click('Toggle week start');check(has('Week starts Sunday'),'custom week start')
if not flutter:check("document.querySelector('.ng-schedule-day').getAttribute('aria-label')==='2026-10-18'",'Sunday first day')
else:check(has('Sun 18'),'Sunday first day')
click('Toggle events');check(has('No shifts planned'),'custom empty text');shot('empty-week')
click('Toggle events');click('Day');shot('day')
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});c.call('Page.reload');time.sleep(3)
check('document.documentElement.scrollWidth<=innerWidth','narrow page no overflow');shot('narrow')
c.call('Emulation.clearDeviceMetricsOverride');c.s.close()

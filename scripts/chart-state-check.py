"""Chart 0.36 controlled legend and point state in foreground Chrome (CDP 9341)."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
c=CDP();flutter='flutter' in sys.argv
out=Path('artifacts/browser');out.mkdir(parents=True,exist_ok=True)
def pause():time.sleep(.5)
def check(expr,label):
 assert c.eval(expr),label
 print('PASS',label,flush=True)
def control(label):return f"([...document.querySelectorAll('[aria-label]')].find(e=>e.getAttribute('aria-label')==={label!r})??[...document.querySelectorAll('button,summary,[role=button],[role=checkbox]')].find(e=>e.textContent.trim()==={label!r}))"
def click(expr):
 if flutter:
  c.eval(f'(()=>{{const e={expr};if(!e)throw Error("Missing control");e.click();}})()');pause();return
 xy=c.eval(f'(()=>{{const e={expr};if(!e)throw Error("Missing control");e.scrollIntoView({{block:"center"}});const r=e.getBoundingClientRect();return {{x:r.x+r.width/2,y:r.y+r.height/2}};}})()')
 for t in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=t,button='left',clickCount=1,**xy))
 pause()
def toggle(label):click(control(label) if flutter else f"[...document.querySelectorAll('label')].find(e=>e.textContent.trim()==={label!r}).querySelector('input')")
def shot(name):c.shot(str(out/f'chart036-{"flutter" if flutter else "blazor"}-{name}.png'))
c.call('Page.enable');c.call('Page.bringToFront')
c.call('Page.navigate',{'url':'http://127.0.0.1:5181/?preview=NgChart' if flutter else 'http://127.0.0.1:5180/preview/NgChart'});time.sleep(3)
if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");pause()
click(control('Chart data'))
# Prefer the text data action over an SVG mark.
def point(label):return f"[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}||e.getAttribute('aria-label')==={label!r})"
click(point('Orders / Mon: 10 orders'))
check("document.body.innerText.includes('Last callback: Orders / Mon: 10 orders')",'formatted point callback')
toggle('Selection read-only');click(point('Orders / Tue: 20 orders'))
check("document.body.innerText.includes('Last callback: Orders / Mon: 10 orders')",'selection lock')
toggle('Accept legend changes');click(control('Orders'))
check(f"({control('Orders')}).getAttribute('aria-checked')==='true'",'legend proposal rejected') if flutter else check("document.body.innerText.includes('Orders / Tue: 20 orders')",'legend proposal rejected')
if not flutter:check("document.querySelector('.ng-chart-legend button').getAttribute('aria-pressed')==='true'",'rejected proposal keeps visibility')
toggle('Accept legend changes');click(control('Orders'));click(control('Target'))
check("document.body.innerText.includes('All series hidden.')",'legend changes independent of selection lock')
shot('hidden')
click(control('Show all series'));toggle('Legend read-only');toggle('Selection read-only')
click(control('Orders'));click(control('Update values'))
# Data panel may be recreated after empty state.
if flutter:
 if c.eval("[...document.querySelectorAll('[role=button]')].some(e=>e.textContent==='Chart data')"):click(control('Chart data'))
else:
 if not c.eval("document.querySelector('details').open"):click(control('Chart data'))
click(point('Orders / Mon: 40 orders'))
check("document.body.innerText.includes('Last callback: Orders / Mon: 40 orders')",'fresh data selectable under legend lock')
shot('selected')
click(control('Toggle invalid data'))
check("!document.body.innerText.includes('Orders / Tue: 20 orders')",'invalid data removes point actions')
shot('invalid');click(control('Toggle invalid data'))
if not flutter:check("!document.querySelector('.ng-chart-selection')",'error recovery does not resurrect selection')
# Clean narrow rendering.
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});c.call('Page.reload');time.sleep(3)
check('document.documentElement.scrollWidth<=innerWidth','narrow no page overflow');shot('narrow');c.call('Emulation.clearDeviceMetricsOverride');c.s.close()

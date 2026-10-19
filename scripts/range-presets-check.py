"""Date range preset checks in dedicated foreground local Chrome, CDP 9341."""
from chrome_cdp import CDP
from pathlib import Path
import sys,time,json
c=CDP();flutter='flutter' in sys.argv
Path('artifacts/browser').mkdir(parents=True,exist_ok=True)
def check(ok,label):
 assert ok,label
 print('PASS',label,flush=True)
def button(label):return f"[...document.querySelectorAll('button,[role=button]')].find(e=>(e.getAttribute('aria-label')||e.textContent).trim()==={json.dumps(label)})"
def click(label):c.eval(button(label)+'.click()');time.sleep(.2)
def disabled(label):return c.eval(f"(()=>{{const e={button(label)};return !!e&&(e.disabled||e.getAttribute('aria-disabled')==='true');}})()")
def fields():return "[...document.querySelectorAll('input[data-semantics-role=text-field]')]" if flutter else "[...document.querySelectorAll('.ng-range input[type=text]')]"
def values():
 if flutter:
  for i in [0,1]:focus(i)
 return c.eval(fields()+'.map(e=>e.value)')
def status():return c.eval("(()=>{const e=[...document.querySelectorAll('p,flt-semantics')].find(e=>(e.getAttribute('aria-label')||e.textContent).startsWith('Changes: '));return e?.getAttribute('aria-label')||e?.textContent})()")
def count():return int(status().split()[1])
def validated():return c.eval("[...document.querySelectorAll('p,flt-semantics')].some(e=>(e.getAttribute('aria-label')||e.textContent).toLowerCase()==='validated: true')")
def focus(index=0):
 c.eval(fields()+f"[{index}].scrollIntoView({{block:'center'}})");time.sleep(.3)
 p=c.eval(f"(()=>{{const r={fields()}[{index}].getBoundingClientRect();return {{x:r.x+25,y:r.y+15}};}})()")
 for kind in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=kind,button='left',clickCount=1,**p))
 time.sleep(.1)
def enter(value):
 focus()
 for kind in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',dict(type=kind,key='a',code='KeyA',windowsVirtualKeyCode=65,modifiers=2))
 c.call('Input.insertText',{'text':value});time.sleep(.2)
c.call('Page.enable');c.call('Page.bringToFront')
c.call('Page.navigate',{'url':'http://127.0.0.1:5181/?preview=NgDateRangePicker' if flutter else 'http://127.0.0.1:5180/preview/NgDateRangePicker'});time.sleep(3)
if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.5)
check(count()==0 and values()==['2026-10-20','2026-10-23'],'initial render does not notify')
for name in ['Sunday start','Outside bounds','Unavailable preset']:check(disabled(name),name+' is disabled')
click('Work week');check(count()==1 and values()==['2026-10-19','2026-10-23'],'preset applies both dates once')
enter('invalid');click('Validate range');check(not validated() and count()==1,'invalid draft blocks validation without changing model')
click('Work week');check(count()==2 and values()==['2026-10-19','2026-10-23'],'same preset repairs invalid draft')
click('Validate range');check(validated(),'repaired range validates')
click('Across weekend');check(count()==3 and values()==['2026-10-23','2026-10-26'],'interior Sunday does not block valid endpoints')
click('Toggle read only');check(disabled('Work week') and disabled('Clear range'),'readonly guards actions');click('Work week');check(count()==3,'readonly does not notify');click('Toggle read only')
click('Toggle disabled');check(disabled('Work week') and disabled('Clear range'),'disabled guards actions');click('Clear range');check(count()==3,'disabled does not clear');click('Toggle disabled')
click('Toggle bounds');check(disabled('Work week') and disabled('Across weekend') and count()==3,'changed bounds guard actions and retain value')
click('Validate range');check(not validated(),'changed bounds invalidate range');click('Toggle bounds')
click('Clear range');check(count()==4 and values()==['',''],'clear applies null once');click('Validate range');check(validated(),'optional empty range validates')
click('Clear range');check(count()==5,'clear can reset an already empty range')
enter('2026-10-20');click('Validate range');check(not validated(),'partial range blocks validation')
click('Work week');check(count()==7 and values()==['2026-10-19','2026-10-23'],'preset repairs partial range with one callback')
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});time.sleep(.6)
check(c.eval('document.documentElement.scrollWidth<=innerWidth+1'),'narrow viewport has no horizontal overflow')
c.shot(f'artifacts/browser/range058-{sys.argv[1]}-narrow.png')
c.call('Emulation.clearDeviceMetricsOverride');time.sleep(.3)
c.shot(f'artifacts/browser/range058-{sys.argv[1]}.png');c.s.close()

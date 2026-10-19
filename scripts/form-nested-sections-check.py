"""Nested form section checks in foreground Chrome, CDP port 9341."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
c=CDP();flutter='flutter' in sys.argv
Path('artifacts/browser').mkdir(parents=True,exist_ok=True)
def check(ok,label):
 assert ok,label
 print('PASS',label,flush=True)
def fields():return "[...document.querySelectorAll('input[data-semantics-role=text-field],textarea[data-semantics-role=text-field]')]" if flutter else "[...document.querySelectorAll('.ng-form-cell .ng-input')]"
def rect(i):return c.eval(f"(()=>{{const r={fields()}[{i}].getBoundingClientRect();return {{x:r.x,y:r.y,w:r.width,h:r.height}};}})()")
def click(label):
 c.eval(f"[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}||e.getAttribute('aria-label')==={label!r}).click()");time.sleep(.35)
def content():return c.eval("document.body.innerText+' '+[...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' ')")
def focus(i):
 c.eval(f"{fields()}[{i}].scrollIntoView({{block:'center'}})");r=rect(i)
 for kind in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=kind,button='left',clickCount=1,x=r['x']+25,y=r['y']+15))
 time.sleep(.15)
def enter(i,text):
 focus(i)
 for kind in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',dict(type=kind,key='a',code='KeyA',windowsVirtualKeyCode=65,modifiers=2))
 c.call('Input.insertText',{'text':text});time.sleep(.3)
def value(i):focus(i);return c.eval(f'{fields()}[{i}].value')
def shot(name):c.shot(f'artifacts/browser/form055-{sys.argv[1]}-{name}.png')
c.call('Page.enable');c.call('Page.bringToFront');c.call('Page.navigate',{'url':'http://127.0.0.1:5181/?preview=NgForm' if flutter else 'http://127.0.0.1:5180/preview/NgForm'});time.sleep(3)
if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.4)
click('Nest sections')
check('Application workspace' in content(),'parent group renders')
check('One form validates every nested section.' in content(),'parent description renders')
check('Application details' in content() and 'Delivery instructions' in content(),'both named sections render')
check('Name and owner are required.' in content(),'section description renders')
if not flutter:
 check(c.eval("document.querySelectorAll('form').length===1"),'one HTML form serves all sections')
 check(c.eval("document.querySelectorAll('.ng-form-section>legend').length===3"),'nested legends label fieldsets')
check(abs(rect(0)['y']-rect(1)['y'])<25,'identity fields share a row')
check(rect(2)['w']>rect(0)['w']*1.8,'delivery section spans independently')
enter(2,'Keep these instructions');click('Save application');check('Review 2 issue(s)' in content(),'one summary validates both required fields')
focus(2);click('Reverse sections')
if not flutter:check(c.eval("document.activeElement.tagName==='TEXTAREA'"),'section reorder preserves DOM focus')
check(value(0)=='Keep these instructions','section reorder preserves draft')
check('Review 2 issue(s)' in content(),'section reorder preserves errors')
check(rect(2)['y']>rect(0)['y'],'section order changes visibly');shot('reordered')
click('Use three columns');click('Change notes span')
check(1.8<rect(0)['w']/rect(1)['w']<2.3,'section owns responsive span rules')
check(value(0)=='Keep these instructions','section layout change retains draft')
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});time.sleep(.5)
check(rect(3)['y']>rect(2)['y'],'narrow section stacks fields')
check(c.eval('document.documentElement.scrollWidth<=innerWidth'),'narrow sections have no horizontal overflow')
check(value(0)=='Keep these instructions','narrow resize retains draft');shot('narrow')
c.call('Emulation.clearDeviceMetricsOverride');time.sleep(.4)
enter(2,'Atlas');enter(3,'Owner');click('Save application');time.sleep(1.2)
check('Saved: Atlas' in content(),'shared submit saves after section changes')
click('Reverse sections');check(value(0)=='Atlas','repeated reorder retains name');check(value(2)=='Keep these instructions','repeated reorder retains note')
if not flutter:
 c.eval("document.querySelectorAll('input[type=checkbox]')[1].click()");time.sleep(.3)
 check(c.eval("[...document.querySelectorAll('.ng-form-cell .ng-input')].every(e=>e.matches(':disabled'))"),'disabled parent guards nested fields')
c.s.close()

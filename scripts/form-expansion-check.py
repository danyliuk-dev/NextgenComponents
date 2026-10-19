"""Controlled section expansion checks in foreground Chrome, CDP port 9341."""
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
 c.eval(f"[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim().endsWith({label!r})||e.getAttribute('aria-label')==={label!r}).click()");time.sleep(.35)
def content():return c.eval("document.body.innerText+' '+[...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' ')")
def focus(i):
 c.eval(f"{fields()}[{i}].scrollIntoView({{block:'center'}})");time.sleep(.3);r=rect(i)
 for kind in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=kind,button='left',clickCount=1,x=r['x']+25,y=r['y']+15))
 time.sleep(.15)
def enter(i,text):
 focus(i)
 for kind in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',dict(type=kind,key='a',code='KeyA',windowsVirtualKeyCode=65,modifiers=2))
 c.call('Input.insertText',{'text':text});time.sleep(.3)
def value(i):focus(i);return c.eval(f'{fields()}[{i}].value')
def shot(name):c.shot(f'artifacts/browser/form056-{sys.argv[1]}-{name}.png')
def visible():return c.eval(fields()+".filter(e=>e.getClientRects().length>0).length")
c.call('Page.enable');c.call('Page.bringToFront');c.call('Page.navigate',{'url':'http://127.0.0.1:5181/?preview=NgForm' if flutter else 'http://127.0.0.1:5180/preview/NgForm'});time.sleep(3)
if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.4)
click('Nest sections');check(visible()==4,'nested fields initially expanded')
enter(2,'Retained folded note');click('Delivery instructions');check(visible()==2,'leaf collapse hides only its fields')
click('Application details');check(visible()==0,'both leaves collapse')
click('Save application');check('Review 2 issue(s)' in content(),'collapsed required fields still validate');check('Saved: Atlas' not in content(),'invalid collapsed form does not save')
if not flutter:
 check(c.eval(fields()+'.length')==4,'hidden editors remain mounted')
 check(c.eval("[...document.querySelectorAll('.ng-section-toggle')].every(e=>document.getElementById(e.getAttribute('aria-controls'))!==null)"),'disclosure controls link to content')
 check(c.eval("[...document.querySelectorAll('.ng-section-toggle')].filter(e=>e.getAttribute('aria-expanded')==='false').length") == 2,'leaf disclosure states exposed')
shot('collapsed-errors');click('Application workspace');check(visible()==0,'parent collapses descendants')
click('Application workspace');check(visible()==0,'reopening parent preserves collapsed children')
click('Delivery instructions');check(visible()==2,'one child reopens independently')
# Blazor keeps hidden controls in DOM; Flutter keeps them mounted outside its semantic DOM.
check(value(0 if flutter else 2)=='Retained folded note','reopening retains note')
check('Review 2 issue(s)' in content(),'reopening retains errors')
click('Reverse sections');check(visible()==2,'reorder preserves collapsed state');check(value(0)=='Retained folded note','reorder retains folded draft')
click('Application details');check(visible()==4,'required section reopens')
enter(2,'Atlas');enter(3,'Owner');click('Application details');check(visible()==2,'valid fields can remain collapsed')
click('Save application');check('Saving' in content(),'shared submit enters busy state')
click('Application workspace');check(visible()==2,'busy form rejects collapse')
time.sleep(1.2);check('Saved: Atlas' in content(),'valid collapsed fields save successfully')
click('Application details');check(visible()==4,'values reopen after save');check(value(2)=='Atlas','saved name retained')
if not flutter:
 c.eval("[...document.querySelectorAll('.ng-section-toggle')].find(e=>e.textContent.includes('Application details')).focus()")
 for kind in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',dict(type=kind,key=' ',code='Space',windowsVirtualKeyCode=32))
 time.sleep(.4);check(visible()==2,'Space toggles focused disclosure');click('Application details')
c.eval("document.querySelectorAll('input[type=checkbox],[role=checkbox]')[1].click()");time.sleep(.3)
click('Application workspace');check(visible()==4,'disabled form rejects collapse')
c.eval("document.querySelectorAll('input[type=checkbox],[role=checkbox]')[1].click()");time.sleep(.3)
click('Application details');check(visible()==2,'enabled form can collapse again')
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});time.sleep(.5)
check(c.eval('document.documentElement.scrollWidth<=innerWidth'),'collapsed nested layout fits narrow width');check(value(0)=='Retained folded note','narrow resize retains draft');shot('narrow')
c.call('Emulation.clearDeviceMetricsOverride');c.s.close()

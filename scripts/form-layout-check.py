"""Responsive form and custom action checks in foreground Chrome (CDP 9341)."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
c=CDP();flutter='flutter' in sys.argv
validation_error='Enter an application name.' if flutter else 'The Name field is required.'
Path('artifacts/browser').mkdir(parents=True,exist_ok=True)
def check(ok,label):
 assert ok,label
 print('PASS',label,flush=True)
def fields():return "[...document.querySelectorAll('input[data-semantics-role=text-field],textarea[data-semantics-role=text-field]')]" if flutter else "[...document.querySelectorAll('.ng-form-cell .ng-input')]"
def field(i):return f'{fields()}[{i}]'
def click(label):
 c.eval(f"[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}||e.getAttribute('aria-label')==={label!r}).click()");time.sleep(.2)
def content():return c.eval("document.body.innerText+' '+[...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' ')")
def focus(i):
 p=c.eval(f"(()=>{{const e={field(i)};e.scrollIntoView({{block:'center'}});const r=e.getBoundingClientRect();return {{x:r.x+25,y:r.y+15}};}})()")
 for kind in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=kind,button='left',clickCount=1,**p))
 time.sleep(.05)
def enter(i,text):
 focus(i)
 for kind in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',dict(type=kind,key='a',code='KeyA',windowsVirtualKeyCode=65,modifiers=2))
 c.call('Input.insertText',{'text':text});time.sleep(.2)
def value(i):focus(i);return c.eval(field(i)+'.value')
def same_row():return c.eval(f'Math.abs({field(0)}.getBoundingClientRect().y-{field(1)}.getBoundingClientRect().y)<3')
def checkbox(i):c.eval(f"document.querySelectorAll('input[type=checkbox],[role=checkbox]')[{i}].click()");time.sleep(.2)
def shot(name):c.shot(f'artifacts/browser/form050-{sys.argv[1]}-{name}.png')
c.call('Page.enable');c.call('Page.bringToFront');c.call('Page.navigate',{'url':'http://127.0.0.1:5181/?preview=NgForm' if flutter else 'http://127.0.0.1:5180/preview/NgForm'});time.sleep(3)
if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.4)
check(c.eval(fields()+'.length')==4,'four explicit fields render');check(same_row(),'wide form has two columns')
click('Save application');check(validation_error in content(),'custom save validates fields');check('Not saved' in content(),'invalid form is not saved')
enter(1,'Draft owner');click('Change columns');check(not same_row(),'one-column option stacks fields');check(value(1)=='Draft owner','column switch preserves draft')
click('Change spacing');click('Change columns');check(same_row(),'two-column option restores row');check(value(1)=='Draft owner','spacing preserves draft')
check(validation_error in content(),'layout preserves validation error');shot('wide')
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});time.sleep(.5)
check(not same_row(),'narrow container stacks fields');check(value(1)=='Draft owner','resize preserves draft');check(c.eval('document.documentElement.scrollWidth<=innerWidth'),'narrow page has no horizontal overflow');shot('narrow')
c.call('Emulation.clearDeviceMetricsOverride');time.sleep(.5);check(same_row(),'wide container restores two columns')
enter(0,'Atlas');click('Save application');check('Saving' in content(),'custom save shows busy state');time.sleep(1.1);check('Saved: Atlas' in content(),'valid form saves through custom action')
checkbox(0);click('Save application');time.sleep(1.1);check('Unable to save' in content(),'save failure permits retry');checkbox(0);click('Save application');time.sleep(1.1);check('Unable to save' not in content(),'retry clears error')
click('Reset application');check(value(1)=='','reset clears retained draft');enter(0,'Disabled draft');checkbox(1);click('Save application');time.sleep(1.1);check('Not saved' in content(),'disabled form cannot submit');shot('disabled')
c.s.close()

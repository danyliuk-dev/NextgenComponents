"""Live form summary checks in foreground Chrome (local CDP 9341)."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
c=CDP();flutter='flutter' in sys.argv
Path('artifacts/browser').mkdir(parents=True,exist_ok=True)
def check(ok,label):
 assert ok,label
 print('PASS',label,flush=True)
def fields():return "[...document.querySelectorAll('input[data-semantics-role=text-field],textarea[data-semantics-role=text-field]')]" if flutter else "[...document.querySelectorAll('.ng-form-cell .ng-input')]"
def click(label):
 c.eval(f"[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}||e.getAttribute('aria-label')==={label!r}).click()");time.sleep(.25)
def content():return c.eval("document.body.innerText+' '+[...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' ')")
def enter(i,text):
 p=c.eval(f"(()=>{{const e={fields()}[{i}];e.scrollIntoView({{block:'center'}});const r=e.getBoundingClientRect();return {{x:r.x+25,y:r.y+15}};}})()")
 for kind in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=kind,button='left',clickCount=1,**p))
 time.sleep(.15)
 for kind in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',dict(type=kind,key='a',code='KeyA',windowsVirtualKeyCode=65,modifiers=2))
 if text:c.call('Input.insertText',{'text':text})
 else:
  for kind in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',dict(type=kind,key='Backspace',code='Backspace',windowsVirtualKeyCode=8))
 time.sleep(.35)
def shot(name):c.shot(f'artifacts/browser/form051-{sys.argv[1]}-{name}.png')
c.call('Page.enable');c.call('Page.bringToFront');c.call('Page.navigate',{'url':'http://127.0.0.1:5181/?preview=NgForm' if flutter else 'http://127.0.0.1:5180/preview/NgForm'});time.sleep(3)
if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.4)
check('Review 0 issue(s)' not in content(),'empty custom summary hidden')
click('Save application');check('Review 2 issue(s)' in content(),'custom summary receives two errors');check('Enter an owner.' in content(),'validator message included');check('Not saved' in content(),'invalid form stays unsaved');shot('two-errors')
enter(1,'Owner');check('Review 1 issue(s)' in content(),'correcting one field updates summary');check('Enter an owner.' not in content(),'resolved error removed')
click('Toggle summary visibility');check('Review 1 issue(s)' not in content(),'summary can be hidden');click('Save application');check('Not saved' in content(),'hidden summary still validates');check('Review 1 issue(s)' not in content(),'submit respects hidden summary')
click('Toggle summary visibility');check('Review 1 issue(s)' in content(),'showing summary restores current errors')
click('Toggle custom summary');check('Review this application' in content(),'default summary uses configured heading');check('Review 1 issue(s)' not in content(),'custom presentation replaced')
enter(0,'Atlas');check('Review this application' not in content(),'last correction hides empty summary');check('Not saved' in content(),'live validation does not save')
enter(0,'');check('Review this application' in content(),'new invalid edit restores summary');click('Change columns');check('Review this application' in content(),'layout change preserves summary')
click('Toggle custom summary');check('Review 1 issue(s)' in content(),'custom template sees current errors')
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});time.sleep(.5)
check(c.eval('document.documentElement.scrollWidth<=innerWidth'),'narrow summary has no horizontal overflow');shot('narrow')
c.call('Emulation.clearDeviceMetricsOverride');time.sleep(.4)
enter(0,'Atlas');click('Save application');time.sleep(1.1);check('Saved: Atlas' in content(),'valid submission succeeds');check('Review 1 issue(s)' not in content(),'successful submission has no errors')
click('Reset application');check('Review 1 issue(s)' not in content() and 'Review 2 issue(s)' not in content(),'reset discards old summary');click('Save application');check('Review 2 issue(s)' in content(),'replacement form validates independently')
c.s.close()

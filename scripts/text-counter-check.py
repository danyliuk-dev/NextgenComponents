"""Character counter checks in visible local Chrome, CDP 9341."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
c=CDP();flutter='flutter' in sys.argv
Path('artifacts/browser').mkdir(parents=True,exist_ok=True)
def check(ok,label):
 assert ok,label
 print('PASS',label,flush=True)
def field():return "document.querySelector('input[data-semantics-role=text-field],textarea[data-semantics-role=text-field]')" if flutter else "document.querySelector('.ng-text-editor .ng-input')"
def click(label):
 c.eval(f"[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}||e.getAttribute('aria-label')==={label!r}).click()")
 time.sleep(.05)
def native_click(label):
 selector=f"[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}||e.getAttribute('aria-label')==={label!r})"
 c.eval(f"{selector}.scrollIntoView({{block:'center'}})");time.sleep(.3)
 p=c.eval(f"(()=>{{const e={selector};const r=e.getBoundingClientRect();return {{x:r.x+r.width/2,y:r.y+r.height/2}};}})()")
 for kind in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=kind,button='left',clickCount=1,**p))
 time.sleep(.05)
def status():
 return c.eval("(()=>{const nodes=[...document.querySelectorAll('p,flt-semantics')];const e=nodes.find(e=>(e.getAttribute('aria-label')||e.textContent).match(/^Delay: \\d+ ms · Notifications:/));const s=e?.getAttribute('aria-label')||e?.textContent;return s?s.match(/\\d+/g).map(Number):null})()")
def focus():
 c.eval(f"{field()}.scrollIntoView({{block:'center'}})");time.sleep(.3)
 p=c.eval(f"(()=>{{const e={field()};const r=e.getBoundingClientRect();return {{x:r.x+25,y:r.y+15}};}})()")
 for kind in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=kind,button='left',clickCount=1,**p))
 time.sleep(.03)
def enter(value):
 focus()
 for kind in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',dict(type=kind,key='a',code='KeyA',windowsVirtualKeyCode=65,modifiers=2))
 c.call('Input.insertText',{'text':value});time.sleep(.05)
def lock():c.eval("document.querySelector('input[type=checkbox],[role=checkbox]').click()");time.sleep(.05)
def counter(label):
 return c.eval(f"[...document.querySelectorAll('.ng-text-counter,flt-semantics')].some(e=>(e.getAttribute('aria-label')||e.textContent)==={label!r})")
# Use native clicks: semantics-only .click() can be swallowed after editor focus.
click=native_click
c.call('Page.enable');c.call('Page.bringToFront')
for component,label,initial in [('NgTextBox','Project name',13),('NgTextArea','Delivery notes',10)]:
 c.call('Page.navigate',{'url':f'http://127.0.0.1:5181/?preview={component}' if flutter else f'http://127.0.0.1:5180/preview/{component}'});time.sleep(3)
 if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.4)
 check(counter(f'{initial} / 80'),component+' initial used counter')
 if not flutter:check(c.eval(f"{field()}.getAttribute('aria-describedby').includes('-count')"),component+' counter is described by input')
 click('Load emoji');time.sleep(.2);check(counter('1 / 80' if flutter else '11 / 80'),component+' native Unicode length policy')
 click('Load over limit');time.sleep(.2);check(counter('85 / 80') and status()[1]==0,component+' external overflow counted without notification')
 focus();check(len(c.eval(field()+'.value'))==85,component+' external overflow is not truncated')
 click('Change counter');time.sleep(.1);check(counter('5 over limit'),component+' remaining mode shows overflow')
 click('Custom counter');time.sleep(.1);check(counter('Used: 85; limit: 80'),component+' custom plain text formatter')
 click('Change counter');time.sleep(.1);check(not counter('Used: 85; limit: 80'),component+' hidden suppresses counter')
 click('Change counter');time.sleep(.1);check(counter('No characters remaining') if flutter else c.eval("document.querySelector('.ng-text-counter')===null"),component+' native mode preserves platform default')
 click('Change counter');click('Custom counter');click('Clear '+label);time.sleep(.2);check(counter('0 / 80'),component+' clear updates counter immediately');time.sleep(.8)
 enter('ABC');check(counter('3 / 80'),component+' typing updates counter immediately');click('Change counter');time.sleep(.1);check(counter('77 remaining'),component+' remaining allowance');time.sleep(.8);check(status()[1]==2,component+' mode change retains pending notification')
 focus()
 for kind in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',dict(type=kind,key='a',code='KeyA',windowsVirtualKeyCode=65,modifiers=2))
 c.call('Input.imeSetComposition',{'text':'ni','selectionStart':2,'selectionEnd':2});time.sleep(.2);check(counter('78 remaining'),component+' composition updates draft counter');time.sleep(.8);check(status()[1]==2,component+' counter does not bypass IME suppression')
 c.call('Input.insertText',{'text':'你好'});time.sleep(.8);check(counter('78 remaining') and status()[1]==3,component+' committed composition counted and notified once')
 lock();click('Replace draft');time.sleep(.2);check(counter('60 remaining'),component+' readonly external replacement counted');lock()
 click('Change counter');enter('x'*85);time.sleep(.2);check(len(c.eval(field()+'.value'))==80,component+' hidden counter retains native length enforcement')
 click('Change counter');click('Change counter');time.sleep(.1);check(counter('80 / 80'),component+' mode changes preserve final value')
 c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});time.sleep(.5)
 c.eval(field()+".scrollIntoView({block:'center'})");time.sleep(.4)
 check(c.eval('document.documentElement.scrollWidth<=innerWidth+1'),component+' narrow viewport without overflow')
 c.shot(f'artifacts/browser/count059-{sys.argv[1]}-{component}.png');c.call('Emulation.clearDeviceMetricsOverride');time.sleep(.3)
c.s.close()

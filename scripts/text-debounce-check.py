"""Delayed text notification checks in visible local Chrome, CDP 9341."""
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
c.call('Page.enable');c.call('Page.bringToFront')
for component,label in [('NgTextBox','Project name'),('NgTextArea','Delivery notes')]:
 c.call('Page.navigate',{'url':f'http://127.0.0.1:5181/?preview={component}' if flutter else f'http://127.0.0.1:5180/preview/{component}'});time.sleep(3)
 if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.3)
 check(status()==[600,0,0],component+' initial render does not notify')
 enter('One');check(c.eval(field()+'.value')=='One',component+' binding remains immediate')
 enter('Latest draft');check(status()[1]==0,component+' burst has not notified early')
 time.sleep(.8);check(status()==[600,1,12],component+' burst delivers latest value once')
 enter('Cancelled by replacement');click('Replace draft');time.sleep(.8);check(status()[1]==1,component+' external replacement cancels')
 enter('Cancelled by lock');lock();time.sleep(.8);check(status()[1]==1,component+' readonly cancels');lock()
 enter('Cancelled by delay');click('Change delay');time.sleep(.8);check(status()==[0,1,12],component+' delay change cancels')
 enter('Now');time.sleep(.2);check(status()==[0,2,3],component+' zero delay notifies')
 click('Change delay');enter('Keep on appearance');click('Change size');time.sleep(.8);check(status()==[600,3,18],component+' appearance rebuild retains pending notification')
 click('Clear '+label);check(status()[1]==3,component+' clear notification is delayed');time.sleep(.8);check(status()==[600,4,0],component+' clear notifies empty value once')
 enter('Blur keeps pending');native_click('Change fill');check(status()[1]==4,component+' blur does not flush');time.sleep(.8);check(status()==[600,5,18],component+' blur does not cancel notification')
 c.shot(f'artifacts/browser/text049-{sys.argv[1]}-{component}.png')
c.s.close()

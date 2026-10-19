"""IME composition notification checks in visible local Chrome, CDP 9341."""
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
 check(status()==[600,0,0],component+' initial')
 focus()
 for kind in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',dict(type=kind,key='a',code='KeyA',windowsVirtualKeyCode=65,modifiers=2))
 c.eval("window.imeEvents=[];for(const name of ['compositionstart','compositionupdate','compositionend'])document.addEventListener(name,e=>imeEvents.push([e.type,e.data]),true)")
 def compose(value):
  c.call('Input.imeSetComposition',{'text':value,'selectionStart':len(value),'selectionEnd':len(value)});time.sleep(.08)
 def commit(value):
  c.call('Input.insertText',{'text':value});time.sleep(.08)
 compose('ni');check(c.eval(field()+'.value')=='ni',component+' composing value is immediate')
 time.sleep(.8);check(status()[1]==0,component+' intermediate text suppressed')
 compose('你');time.sleep(.8);check(status()[1]==0,component+' updated composition suppressed')
 commit('你');check(status()[1]==0,component+' completion restarts delay')
 time.sleep(.8);check(status()==[600,1,1],component+' unchanged composition text notifies once')
 check(c.eval("imeEvents.some(e=>e[0]==='compositionstart')&&imeEvents.some(e=>e[0]==='compositionend')"),component+' native composition events observed')
 click('Change delay');focus();compose('好');time.sleep(.3);check(status()[1]==1,component+' zero delay still suppresses composition')
 commit('好');time.sleep(.3);check(status()[1]==2,component+' zero delay completion notifies')
 click('Change delay');focus();compose('文');commit('文');click('Replace draft');time.sleep(.8);check(status()[1]==2,component+' replacement cancels completion')
 focus();compose('字');commit('字');lock();time.sleep(.8);check(status()[1]==2,component+' readonly cancels completion');lock()
 click('Clear '+label);time.sleep(.8);check(status()[1:]==[3,0],component+' clear delivers empty edit')
 focus();compose('中');click('Clear '+label);time.sleep(.8);check(status()[1:]==[4,0],component+' clear during composition cancels draft')
 click('Change delay');enter('zero clear');time.sleep(.2);before=status()[1];click('Clear '+label);time.sleep(.3);check(status()[1:]==[before+1,0],component+' zero delay clear notifies once')
 c.shot(f'artifacts/browser/text057-{sys.argv[1]}-{component}.png')
c.s.close()

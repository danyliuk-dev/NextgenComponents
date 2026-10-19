"""Visible Chrome date-editor regression checks; use the dedicated CDP 9341 profile."""
from chrome_cdp import CDP
from pathlib import Path
import time
c=CDP();out=Path('artifacts/browser');out.mkdir(parents=True,exist_ok=True)
def pause():time.sleep(.6)
def check(expression,label):
 assert c.eval(expression),label
 print('PASS',label,flush=True)
def click(expr):
 xy=c.eval(f'(()=>{{const r=({expr}).getBoundingClientRect();return {{x:r.x+r.width/2,y:r.y+r.height/2}};}})()')
 for t in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=t,button='left',clickCount=1,**xy))
 pause()
def fill(value):
 click("document.querySelector('input')")
 for t in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',{'type':t,'key':'a','code':'KeyA','windowsVirtualKeyCode':65,'modifiers':2})
 if value:c.call('Input.insertText',{'text':value})
 else:
  for t in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',{'type':t,'key':'Backspace','code':'Backspace','windowsVirtualKeyCode':8})
 pause()
for name in ['NgDateInput','NgDatePicker']:
 c.call('Page.navigate',{'url':'http://127.0.0.1:5181/?preview='+name});time.sleep(3)
 c.eval("document.querySelector('flt-semantics-placeholder')?.click()");pause()
 fill('2026-10-25')
 check("document.body.innerText.includes('Accepted date: 2026-10-20')",name+' retains accepted model on excluded Sunday')
 check("[...document.querySelectorAll('[aria-label]')].some(e=>e.getAttribute('aria-label').includes('This date is not available.'))||document.body.innerText.includes('This date is not available.')",name+' displays exclusion error')
 c.shot(str(out/('dates032-flutter-'+name+'-invalid.png')))
 fill('')
 check("document.body.innerText.includes('Accepted date: null')",name+' optional clearing')
 fill('2026-10-23')
 click("[...document.querySelectorAll('[role=button]')].find(e=>e.textContent==='Read only')")
 click("document.querySelector('input')")
 check("document.querySelector('input').readOnly",name+' readonly')
 c.shot(str(out/('dates032-flutter-'+name+'-readonly.png')))
c.call('Page.navigate',{'url':'http://127.0.0.1:5182/desktop?page=manual'})
c.s.close()

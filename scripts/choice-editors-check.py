"""Foreground Chrome regression for choice editor previews (CDP 9341)."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
flutter='flutter' in sys.argv
c=CDP();out=Path('artifacts/browser');out.mkdir(parents=True,exist_ok=True)
def pause():time.sleep(.6)
def check(expr,label):
 assert c.eval(expr),label
 print('PASS',label,flush=True)
def click(expr):
 xy=c.eval(f'(()=>{{const e={expr};if(!e)throw Error("Missing control");const r=e.getBoundingClientRect();return {{x:r.x+r.width/2,y:r.y+r.height/2}};}})()')
 for t in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=t,button='left',clickCount=1,**xy))
 pause()
def button(text):
 return f"[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={text!r}||e.getAttribute('aria-label')==={text!r})"
def open_preview(name):
 c.call('Page.navigate',{'url':f'http://127.0.0.1:5181/?preview={name}' if flutter else f'http://127.0.0.1:5180/preview/{name}'})
 time.sleep(3)
 if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");pause()
def shot(name):c.shot(str(out/f'choices033-{ "flutter" if flutter else "blazor"}-{name}.png'))
c.call('Page.enable');c.call('Page.bringToFront')
open_preview('NgDropDownList')
click(button('Remove selected option'));click(button('Save team'))
check("!document.body.innerText.includes('Saved team:')",'missing selection cannot save')
check("document.body.innerText.includes('Choose an available option.')||[...document.querySelectorAll('[aria-label]')].some(e=>e.getAttribute('aria-label').includes('Choose an available option.'))",'missing selection form error')
if not flutter:check("document.querySelector('select').value==='design'&&document.querySelector('select').selectedOptions[0].textContent.includes('Unavailable selection')",'missing model and displayed selection agree')
shot('missing')
if flutter:
 click("[...document.querySelectorAll('[role=button]')].find(e=>e.textContent.includes('Unavailable selection')||e.getAttribute('aria-label')?.includes('Unavailable selection'))")
 click("[...document.querySelectorAll('[role=menuitem],[role=option],[role=button]')].find(e=>e.textContent==='Engineering'||e.getAttribute('aria-label')==='Engineering')")
else:
 c.eval("(()=>{const e=document.querySelector('select');e.value='dev';e.dispatchEvent(new Event('change',{bubbles:true}));})()");pause()
click(button('Save team'))
check("document.body.innerText.includes('Saved team: dev')",'existing selection saves')
click(button('Read only'))
if not flutter:check("document.querySelector('select').disabled",'dropdown readonly')
shot('readonly')
open_preview('NgRadioGroup')
if flutter:
 click("[...document.querySelectorAll('[role=radio]')].find(e=>e.getAttribute('aria-label')?.includes('Engineering')||e.textContent.includes('Engineering'))")
else:click("document.querySelector('input[value=dev]')")
check("document.body.innerText.includes('Selected team: dev')",'radio template selection')
click(button('Change layout'));click(button('Read only'))
if not flutter:check("document.querySelector('fieldset').disabled",'radio readonly')
shot('radio')
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False})
open_preview('NgRadioGroup');check('document.documentElement.scrollWidth<=innerWidth','narrow no overflow');shot('narrow')
c.call('Emulation.clearDeviceMetricsOverride');c.s.close()

"""Editor 0.41 checks in dedicated visible Chrome on CDP 9341."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
c=CDP();flutter='flutter' in sys.argv
out=Path('artifacts/browser');out.mkdir(parents=True,exist_ok=True)
def control(label):return f"([...document.querySelectorAll('[aria-label]')].find(e=>e.getAttribute('aria-label')==={label!r})??[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}))"
def check(expr,label):
 assert c.eval(expr),label
 print('PASS',label,flush=True)
def pause():time.sleep(.5)
def click(label):
 expr=control(label)
 if flutter:c.eval(f'{expr}.click()')
 else:
  xy=c.eval(f'(()=>{{const e={expr};e.scrollIntoView({{block:"center"}});const r=e.getBoundingClientRect();return {{x:r.x+r.width/2,y:r.y+r.height/2}};}})()')
  for t in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=t,button='left',clickCount=1,**xy))
 pause()
def has(value):return f"(document.body.innerText+[...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' ')).includes({value!r})"
def field():return "document.querySelector('textarea')"
def fill(value):
 c.eval(f'{field()}.focus()')
 for t in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',{'type':t,'key':'a','code':'KeyA','windowsVirtualKeyCode':65,'modifiers':2})
 c.call('Input.insertText',{'text':value});pause()
def editor(value,label):
 c.eval(f'{field()}.focus()');pause();check(f'{field()}.value==={value!r}',label)
def shot(name):c.shot(str(out/f'editor041-{"flutter" if flutter else "blazor"}-{name}.png'))
c.call('Page.enable');c.call('Page.bringToFront');c.call('Page.navigate',{'url':'http://127.0.0.1:5181/?preview=NgEditor' if flutter else 'http://127.0.0.1:5180/preview/NgEditor'});time.sleep(3)
if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");pause()
editor('Project plan','initial text')
click('Toggle acceptance');fill('Draft brief');click('Bold');check(has('Accepted first block: Project plan'),'rejected formatting keeps document');editor('Draft brief','rejected draft retained')
click('2. bullet: Agree on requirements' if flutter else '2. Bullet: Agree on requirements');check(has('Block 1 of 3'),'rejected selection retains block');editor('Draft brief','selection retains draft')
click('Add block');check(has('Block 1 of 3'),'rejected insertion retains count');shot('rejected')
if not flutter:
 c.eval("(()=>{const e=document.querySelector('[aria-label=\"Block type\"]');e.value='Quote';e.dispatchEvent(new Event('change',{bubbles:true}));})()");pause();check("document.querySelector('[aria-label=\"Block type\"]').value==='Heading1'",'rejected kind resets native control')
click('Toggle acceptance');click('Bold');check(has('Accepted first block: Draft brief'),'accepted text and formatting')
click('Undo');check(has('Accepted first block: Project plan'),'accepted undo');editor('Project plan','undo updates field')
click('Redo');check(has('Accepted first block: Draft brief'),'accepted redo')
click('Toggle acceptance');fill('Unaccepted');click('Undo');check(has('Accepted first block: Draft brief'),'rejected undo');editor('Unaccepted','rejected history retains draft')
click('Discard draft');editor('Draft brief','discard restores accepted text')
click('Toggle acceptance');click('Add block');check(has('Block 2 of 4'),'accepted insertion selects new block');fill('New block');click('Move down');check(has('Block 3 of 4'),'move retains logical selection');editor('New block','move applies draft')
click('Delete block');check(has('Block 3 of 3'),'delete updates block count')
click('Replace document');editor('Review imported content','replacement clamps selection');check(has('Imported brief'),'replacement preview');shot('replacement')
click('Delete block');click('Delete block');editor('','final block stays empty');fill('Discard on delete');click('Delete block');editor('','delete empty block discards draft');click('Replace document')
click('Toggle read-only');check(has('Block text, read-only') if flutter else f'{field()}.readOnly','readonly text exposed')
click('1. paragraph: Imported brief' if flutter else '1. Paragraph: Imported brief');check(has('Block 1 of 2'),'readonly inspection');shot('readonly')
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});c.call('Page.reload');time.sleep(3)
check('document.documentElement.scrollWidth<=innerWidth','narrow no page overflow');shot('narrow')
c.call('Emulation.clearDeviceMetricsOverride');c.s.close()

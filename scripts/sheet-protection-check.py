"""Spreadsheet 0.39 checks in dedicated foreground Chrome on CDP 9341."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
c=CDP();flutter='flutter' in sys.argv
out=Path('artifacts/browser');out.mkdir(parents=True,exist_ok=True)
def pause():time.sleep(.45)
def check(expr,label):
 assert c.eval(expr),label
 print('PASS',label,flush=True)
def control(label):return f"([...document.querySelectorAll('[aria-label]')].find(e=>e.getAttribute('aria-label')==={label!r})??[...document.querySelectorAll('button,summary,[role=button]')].find(e=>e.textContent.trim()==={label!r}))"
def click(label):
 expr=control(label)
 if flutter:c.eval(f'{expr}.click()')
 else:
  xy=c.eval(f'(()=>{{const e={expr};e.scrollIntoView({{block:"center"}});const r=e.getBoundingClientRect();return {{x:r.x+r.width/2,y:r.y+r.height/2}};}})()')
  for t in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=t,button='left',clickCount=1,**xy))
 pause()
def field(paste=False):return "document.querySelector('textarea')" if paste else "document.querySelector('input')"
def fill(value,paste=False):
 c.eval(f'{field(paste)}.focus()')
 for t in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',{'type':t,'key':'a','code':'KeyA','windowsVirtualKeyCode':65,'modifiers':2})
 c.call('Input.insertText',{'text':value});pause()
def editor(value,label):
 if flutter:c.eval(f'{field()}.focus()');pause()
 check(f'{field()}.value==={value!r}',label)
def content():return "document.body.innerText + [...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' ')"
def has(text):return f'({content()}).includes({text!r})'
def shot(name):c.shot(str(out/f'sheet039-{"flutter" if flutter else "blazor"}-{name}.png'))
c.call('Page.enable');c.call('Page.bringToFront')
c.call('Page.navigate',{'url':'http://127.0.0.1:5181/?preview=NgSpreadsheet' if flutter else 'http://127.0.0.1:5180/preview/NgSpreadsheet'});time.sleep(3)
if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");pause()
fill('35');click('Apply cell');check(has('Accepted A1: 35'),'accepted edit');check(has('C1: 55'),'protected formula recalculated')
click('Toggle acceptance');fill('90');click('Apply cell');check(has('Accepted A1: 35'),'rejected edit retains sheet');check(f'{field()}.value===\'90\'','rejected draft retained')
click('Undo');check(has('Accepted A1: 35'),'rejected undo retains sheet')
click('Toggle acceptance');click('Undo');check(has('Accepted A1: 10'),'accepted undo');editor('10','undo updates formula editor');click('Redo');check(has('Accepted A1: 35'),'accepted redo');editor('35','redo updates formula editor')
click('Toggle A1 lock');check(has('Cell value or formula, read-only') if flutter else f'{field()}.readOnly','protected formula input readonly')
if not flutter:check(f'{control("Undo")}.disabled','history checks new protection')
shot('protected');click('Toggle A1 lock')
click('Paste cells');fill('4\t5\t6',True);click('Paste at A1');check(has('Cell C1 is protected. Paste was not applied.'),'paste rejected atomically');check(has('Accepted A1: 35'),'failed paste leaves model intact');shot('paste-rejected')
click('Toggle protection');click('Paste at A1');check(has('Accepted A1: 4'),'unprotected paste accepted');click('Undo');check(has('Accepted A1: 35'),'paste is one undo step')
click('Toggle protection');click('C1: 55 · Protected');check(has('Cell value or formula, read-only') if flutter else f'{field()}.readOnly','protected cell remains inspectable');check(has('=SUM(A1:B1)') if flutter else f'{field()}.value===\'=SUM(A1:B1)\'','raw formula readable')
click('Shrink sheet');editor('','replacement repairs selection');shot('replacement')
click('Reset sheet');click('Toggle read-only');check(has('Cell value or formula, read-only') if flutter else f'{field()}.readOnly','readonly retains inspection')
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});c.call('Page.reload');time.sleep(3)
check('document.documentElement.scrollWidth<=innerWidth','narrow page no overflow');shot('narrow')
c.call('Emulation.clearDeviceMetricsOverride');c.s.close()

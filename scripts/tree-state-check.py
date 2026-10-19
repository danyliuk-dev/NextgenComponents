"""Tree state regression in foreground Chrome, dedicated profile/CDP 9341."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
c=CDP();flutter='flutter' in sys.argv
out=Path('artifacts/browser');out.mkdir(parents=True,exist_ok=True)
def pause():time.sleep(.5)
def check(expr,label):
 assert c.eval(expr),label
 print('PASS',label,flush=True)
def click(expr):
 xy=c.eval(f'(()=>{{const e={expr};if(!e)throw Error("Missing control: "+{expr!r});e.scrollIntoView({{block:"center"}});const r=e.getBoundingClientRect();return {{x:r.x+r.width/2,y:r.y+r.height/2}};}})()')
 for t in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=t,button='left',clickCount=1,**xy))
 pause()
def control(label):return f"([...document.querySelectorAll('[aria-label]')].find(e=>e.getAttribute('aria-label')==={label!r})??[...document.querySelectorAll('button,[role=button],[role=checkbox],[role=treeitem]')].find(e=>e.textContent.trim()==={label!r}))"

def toggle(label):
 click(control(label) if flutter else f"[...document.querySelectorAll('label')].find(e=>e.textContent.trim()==={label!r}).querySelector('input')")
def search(value):
 expr="document.querySelector('input[type=text],input:not([type])')"
 click(expr)
 c.call('Input.dispatchKeyEvent',{'type':'keyDown','key':'a','code':'KeyA','modifiers':2,'windowsVirtualKeyCode':65})
 c.call('Input.dispatchKeyEvent',{'type':'keyUp','key':'a','code':'KeyA','modifiers':2,'windowsVirtualKeyCode':65})
 if value:c.call('Input.insertText',{'text':value})
 else:
  c.call('Input.dispatchKeyEvent',{'type':'keyDown','key':'Backspace','windowsVirtualKeyCode':8});c.call('Input.dispatchKeyEvent',{'type':'keyUp','key':'Backspace','windowsVirtualKeyCode':8})
 pause()
def shot(name):c.shot(str(out/f'tree035-{"flutter" if flutter else "blazor"}-{name}.png'))
c.call('Page.enable');c.call('Page.bringToFront')
for name in ['NgTreeView','NgTreeList']:
 c.call('Page.navigate',{'url':f'http://127.0.0.1:5181/?preview={name}' if flutter else f'http://127.0.0.1:5180/preview/{name}'});time.sleep(3)
 if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");pause()
 click(control('Design'))
 check("document.body.innerText.includes('Selected team: a')",name+' selects templated node')
 toggle('Selection read-only');click(control('Engineering'))
 check("document.body.innerText.includes('Selected team: a')",name+' selection lock')
 click(control('Collapse Projects'))
 check("!(document.body.innerText+' '+[...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' ')).includes('Engineering')",name+' expansion independent of selection')
 toggle('Expansion read-only');toggle('Selection read-only')
 click(control('Projects'))
 check("document.body.innerText.includes('Selected team: root')",name+' selection independent of expansion')
 search('Engineering')
 check("(document.body.innerText+' '+[...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' ')).includes('Engineering')",name+' search reveals descendant under locked parent')
 shot(name+'-search')
 search('')
 check("!(document.body.innerText+' '+[...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' ')).includes('Engineering')",name+' clearing search restores collapsed state')
 toggle('Expansion read-only');search('   ');click(control('Expand Projects'))
 check("(document.body.innerText+' '+[...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' ')).includes('Engineering')",name+' whitespace search allows expansion')
 shot(name)
 search('missing')
 check("document.body.innerText.includes('No teams found.')",name+' custom empty content')
c.s.close()

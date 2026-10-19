"""Remote Grid/lazy trees in the dedicated foreground review Chrome."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
c=CDP();flutter='flutter' in sys.argv
out=Path('artifacts/browser');out.mkdir(parents=True,exist_ok=True)
def check(expr,label):
 assert c.eval(expr),label
 print('PASS',label,flush=True)
def control(label):return f"([...document.querySelectorAll('[aria-label]')].find(e=>e.getAttribute('aria-label')==={label!r})??[...document.querySelectorAll('button,[role=button],[role=checkbox],[role=treeitem]')].find(e=>e.textContent.trim()==={label!r}))"
def click(expr):
 c.eval(f'({expr}).scrollIntoView({{block:"center"}})');time.sleep(.3)
 xy=c.eval(f'(()=>{{const r=({expr}).getBoundingClientRect();return {{x:r.x+r.width/2,y:r.y+r.height/2}};}})()')
 for t in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=t,button='left',clickCount=1,**xy))
 time.sleep(.7)
def button(label):click(control(label))
def toggle(label):click(control(label) if flutter else f"[...document.querySelectorAll('label')].find(e=>e.textContent.trim()==={label!r}).querySelector('input')")
def text(value):
 click("document.querySelector('input[type=text],input:not([type])')")
 for t in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',{'type':t,'key':'a','code':'KeyA','modifiers':2,'windowsVirtualKeyCode':65})
 c.call('Input.insertText',{'text':value});time.sleep(.8)
def content():return "(document.body.innerText+' '+[...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' '))"
def has(text,label):check(content()+f'.includes({text!r})',label)
def visit(name):
 c.call('Page.navigate',{'url':f'http://127.0.0.1:5181/?preview={name}' if flutter else f'http://127.0.0.1:5180/preview/{name}'});time.sleep(3)
 if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.8)
def shot(name):c.shot(str(out/f'data060-{"flutter" if flutter else "blazor"}-{name}.png'))
c.call('Page.enable');c.call('Page.bringToFront');visit('NgDataGrid')
has('Chair','server page loaded');has('40','filtered total')
button('Next page');has('6','next page range')
# Click sorted headers using visible labels.
click("[...document.querySelectorAll('button,[role=button],[role=columnheader]')].find(e=>/^Name(?: |$)/.test(e.textContent.trim())||e.getAttribute('aria-label')==='Name')")
click("[...document.querySelectorAll('button,[role=button],[role=columnheader]')].find(e=>/^Quantity(?: |$)/.test(e.textContent.trim())||e.getAttribute('aria-label')==='Quantity')")
has('2','sort priority displayed')
button('Clear sorting');text('Desk');has('20','remote search total');check('!'+content()+".includes('Chair')",'remote filtering')
toggle('Fail requests');button('Reload source');has('Unable to load records.','load error')
toggle('Fail requests');button('Retry');has('Desk','retry recovered')
shot('grid')
for name in ['NgTreeView','NgTreeList']:
 visit(name);check('!'+content()+".includes('Engineering')",name+' initially unloaded')
 toggle('Fail requests');button('Expand Projects');has('Unable to load children.',name+' child failure')
 toggle('Fail requests');button('Expand Projects');has('Engineering',name+' retry children')
 button('Expand Engineering');has('API',name+' second level')
 button('Collapse Projects');button('Expand Projects');has('API',name+' cache and retained expansion')
 button('Design');has('Selected team: a',name+' loaded selection')
 toggle('Selection read-only');button('Engineering');has('Selected team: a',name+' locked selection')
 shot(name)
 button('Reset tree');check('!'+content()+".includes('Engineering')",name+' source invalidation')
c.s.close()

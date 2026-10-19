"""Grid 0.34 regression in the dedicated foreground Chrome (CDP 9341)."""
from chrome_cdp import CDP
from pathlib import Path
import time, sys
c=CDP(); flutter='flutter' in sys.argv
out=Path('artifacts/browser');out.mkdir(parents=True,exist_ok=True)
def check(expression,label):
 assert c.eval(expression),label
 print('PASS',label,flush=True)
def click(expression):
 xy=c.eval(f'(()=>{{const e={expression};if(!e)throw Error("Missing control");e.scrollIntoView({{block:"center"}});const r=e.getBoundingClientRect();return {{x:r.x+r.width/2,y:r.y+r.height/2}};}})()')
 for t in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=t,button='left',clickCount=1,**xy))
 time.sleep(.5)
def control(label):
 return f"[...document.querySelectorAll('input,button,[role=checkbox],[role=button]')].find(e=>(e.getAttribute('aria-label')==={label!r}||e.getAttribute('aria-label')?.startsWith({label!r}+' ('))||e.textContent.trim()==={label!r})"
def shot(name):c.shot(str(out/f'grid034-{"flutter" if flutter else "blazor"}-{name}.png'))
c.call('Page.enable');c.call('Page.bringToFront')
c.call('Page.navigate',{'url':'http://127.0.0.1:5181/' if flutter else 'http://127.0.0.1:5180/data'});time.sleep(3)
if flutter:
 c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(1)
 click(control('Data workspace'));time.sleep(1)
else:
 check("document.querySelector('[aria-label=\"Select P004\"]').disabled",'paused row protected')
click(control('Select page'))
check("document.body.innerText.includes('4 selected')",'page selects four eligible rows')
click(control('Select P001'))
check("document.body.innerText.includes('3 selected')",'row toggle')
check("[...document.querySelectorAll('[aria-label]')].some(e=>e.getAttribute('aria-label')==='Select page (partially selected)'||(e.getAttribute('aria-label')==='Select page'&&e.getAttribute('aria-checked')==='mixed'))",'partial page state announced')
click(control('Select page'))
check("document.body.innerText.includes('4 selected')",'partial page fills remaining eligible rows')
click(control('Next page'))
click(control('Select page'))
check("document.body.innerText.includes('8 selected')",'selection retained across pages')
click(control('Select page'))
check("document.body.innerText.includes('4 selected')",'deselect page preserves hidden IDs')
if flutter:click(control('Selection read-only'))
else:click("[...document.querySelectorAll('label')].find(e=>e.textContent.includes('Selection read-only')).querySelector('input')")
if not flutter:check("[...document.querySelectorAll('.ng-data-table input[type=checkbox]')].every(e=>e.disabled)",'all selection frozen')
shot('readonly')
click(control('Previous page'))
check("document.body.innerText.includes('4 selected')",'readonly permits navigation and preserves selection')
shot('selected')
c.s.close()

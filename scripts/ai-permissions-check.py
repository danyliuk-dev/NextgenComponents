"""AI permissions and PromptBox length recovery in dedicated foreground Chrome."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
c=CDP();flutter='flutter' in sys.argv
Path('artifacts/browser').mkdir(parents=True,exist_ok=True)
def pause():time.sleep(.25)
def control(label):return f"([...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}||e.getAttribute('aria-label')==={label!r}))"
def click(label):c.eval(control(label)+'.click()');pause()
def content():return "(document.body.innerText+[...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' '))"
def has(text):return content()+f'.includes({text!r})'
def enabled(label):return f"(()=>{{const e={control(label)};return !!e&&!e.disabled&&e.getAttribute('aria-disabled')!=='true';}})()"
def check(expr,label):
 assert c.eval(expr),label
 print('PASS',label,flush=True)
def wait(expr):
 for _ in range(80):
  if c.eval(expr):return
  time.sleep(.1)
 raise AssertionError(expr)
def visit(name):
 c.call('Page.navigate',{'url':f'http://127.0.0.1:5181/?preview={name}' if flutter else f'http://127.0.0.1:5180/preview/{name}'});time.sleep(3)
 if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");pause()
def shot(name):c.shot(f'artifacts/browser/ai045-{sys.argv[1]}-{name}.png')
def type_text(text):
 point=c.eval("(()=>{const e=document.querySelector('textarea,input');e.scrollIntoView({block:'center'});const r=e.getBoundingClientRect();return {x:r.x+30,y:r.y+20};})()")
 for kind in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=kind,button='left',clickCount=1,**point))
 c.call('Input.dispatchKeyEvent',{'type':'keyDown','key':'a','code':'KeyA','windowsVirtualKeyCode':65,'modifiers':2})
 c.call('Input.dispatchKeyEvent',{'type':'keyUp','key':'a','code':'KeyA','windowsVirtualKeyCode':65,'modifiers':2})
 c.call('Input.insertText',{'text':text});pause()
c.call('Page.enable');c.call('Page.bringToFront');visit('NgAIPrompt')
click('Send');wait(has('Completed: 1'));check(has('History (1 / 20)'),'successful request kept in history')
click('Helpful');check(has('Feedback events: 1'),'feedback delivered')
click('Toggle history lock');check('!'+enabled('Clear history'),'history lock disables clearing')
check(enabled('Send'),'history lock allows generation')
click('Toggle feedback lock');check('!'+enabled('Helpful'),'feedback lock disables voting')
click('Toggle generation lock');check('!'+enabled('Send'),'generation lock disables send')
check('!'+enabled('Suggest next steps'),'generation lock disables suggestions')
check(enabled('Copy response'),'copy remains available under locks');shot('locked')
click('Toggle generation lock');click('Send');wait(has('Generating'))
click('Toggle generation lock');wait(has('Cancelled.'));time.sleep(1.4)
check(has('Completed: 1')+' && '+has('History (1 / 20)'),'generation lock cancels pending request without losing history')
click('Toggle history lock');check(enabled('Clear history'),'history clear independent from generation lock')
click('Clear history');check(has('No responses yet.'),'clear removes history while generation locked')
click('Toggle generation lock');click('Send');wait(has('Completed: 2'))
check(has('Response 2'),'new request works after cancellation and clear')
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});time.sleep(.6)
check('document.documentElement.scrollWidth<=innerWidth','narrow AI preview fits');shot('narrow');c.call('Emulation.clearDeviceMetricsOverride')
visit('NgPromptBox');type_text('Long prompt draft');click('Toggle length limit')
check(has('Shorten the prompt to 8'),'reduced limit exposes validation message')
check("document.querySelector('textarea,input').value==='Long prompt draft'",'oversized draft preserved')
check('!'+enabled('Send'),'oversized draft cannot send');shot('length')
type_text('short');check(enabled('Send'),'corrected draft enables Send');click('Send')
check(enabled('Cancel'),'busy request offers cancel');click('Cancel');time.sleep(.8)
check(has('Cancelled'),'cancel prevents delayed result');click('Send');wait(has('Received prompt: short'))
check(has('Received prompt: short'),'corrected draft submitted successfully');shot('recovered')
c.s.close()

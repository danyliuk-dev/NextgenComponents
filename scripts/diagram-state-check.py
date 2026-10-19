"""Diagram 0.42 checks using foreground Chrome and native pointer/keyboard events."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
c=CDP();flutter='flutter' in sys.argv
out=Path('artifacts/browser');out.mkdir(parents=True,exist_ok=True)
def pause():time.sleep(.6)
def control(label):return f"([...document.querySelectorAll('[aria-label]')].find(e=>e.getAttribute('aria-label')==={label!r})??[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}||e.textContent.trim().endsWith('\\n'+{label!r})))"
def check(expr,label):
 assert c.eval(expr),label
 print('PASS',label,flush=True)
def has(value):return f"(document.body.innerText+[...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' ')).includes({value!r})"
def xy(label):return c.eval(f'(()=>{{const e={control(label)};const r=e.getBoundingClientRect();return {{x:r.x+r.width/2,y:r.y+r.height/2}};}})()')
def click(label,semantic=False):
 if flutter or semantic:c.eval(f'{control(label)}.click()')
 else:
  p=xy(label)
  for t in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=t,button='left',clickCount=1,**p))
 pause()
def begin():
 p=xy('Node Task Start');c.call('Input.dispatchMouseEvent',dict(type='mousePressed',button='left',clickCount=1,**p))
 for dx,dy in [(20,10),(40,30)]:c.call('Input.dispatchMouseEvent',{'type':'mouseMoved','button':'left','buttons':1,'x':p['x']+dx,'y':p['y']+dy});time.sleep(.1)
 pause();return {'x':p['x']+40,'y':p['y']+30}
def end(p):c.call('Input.dispatchMouseEvent',dict(type='mouseReleased',button='left',clickCount=1,**p));pause()
def drag():end(begin())
def position(value,label):check(has('Start position: '+value),label)
def shot(name):c.shot(str(out/f'diagram042-{"flutter" if flutter else "blazor"}-{name}.png'))
c.call('Page.enable');c.call('Page.bringToFront');c.call('Page.navigate',{'url':'http://127.0.0.1:5181/?preview=NgDiagram' if flutter else 'http://127.0.0.1:5180/preview/NgDiagram'});time.sleep(3)
if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");pause()
check(has('Task Start'),'formatted node label');position('40, 100','initial coordinates');drag();position('80, 130','accepted native drag');check(has('Move proposals: 1'),'one drag callback');check(has('Node: start'),'raw node ID')
click('Node Task Start')
for t in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',{'type':t,'key':'ArrowRight','code':'ArrowRight','windowsVirtualKeyCode':39})
pause();position('90, 130','keyboard move')
click('Toggle selection lock');click('Node Task Processing');check(has('Node: start'),'selection lock keeps ID');drag();position('130, 160','movement works with selection locked');check(has('Move proposals: 3'),'independent movement callback')
click('Toggle selection lock');click('Toggle move lock');drag();position('130, 160','movement lock blocks drag');click('Node Task Processing');check(has('Node: work'),'selection works while movement locked');click('Zoom out');check(has('75%'),'navigation under lock');click('100%');shot('locked')
click('Toggle move lock');click('Toggle acceptance');drag();position('130, 160','rejected drag retains graph');check(has('Move proposals: 4'),'rejected proposal emitted once');shot('rejected')
click('Toggle acceptance');p=begin();click('Replace graph',True);end(p);position('120, 140','replacement during drag wins');check(has('Move proposals: 4'),'stale drag has no callback')
p=begin();click('Toggle move lock',True);end(p);position('120, 140','locking during drag cancels');check(has('Move proposals: 4'),'lock rejects drag completion')
click('Toggle empty graph');check(has('Nothing to connect'),'custom empty state');click('Toggle empty graph');position('40, 100','data restored');click('Fit diagram');shot('restored')
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});c.call('Page.reload');time.sleep(3)
check('document.documentElement.scrollWidth<=innerWidth','narrow no page overflow');shot('narrow');c.call('Emulation.clearDeviceMetricsOverride');c.s.close()

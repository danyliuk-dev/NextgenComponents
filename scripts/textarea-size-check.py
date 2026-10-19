"""Bounded TextArea sizing checks in foreground Chrome (local CDP 9341)."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys,json
c=CDP();flutter='flutter' in sys.argv
Path('artifacts/browser').mkdir(parents=True,exist_ok=True)
def field():return "document.querySelector('textarea[data-semantics-role=text-field]')" if flutter else "document.querySelector('.ng-text-editor textarea')"
def control(label):return f"([...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}||e.getAttribute('aria-label')==={label!r}))"
def click(label):c.eval(control(label)+'.click()');time.sleep(.4)
def height():return c.eval(field()+'.getBoundingClientRect().height')
def check(condition,label):
 assert condition,label
 print('PASS',label,flush=True)
def focus():
 p=c.eval(f"(()=>{{const e={field()};e.scrollIntoView({{block:'center'}});const r=e.getBoundingClientRect();return {{x:r.x+25,y:r.y+15}};}})()")
 for kind in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=kind,button='left',clickCount=1,**p))
 time.sleep(.2)
def value():
 focus();return c.eval(field()+'.value')
def enter(text):
 focus()
 for kind in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',dict(type=kind,key='a',code='KeyA',windowsVirtualKeyCode=65,modifiers=2))
 c.call('Input.insertText',{'text':text});time.sleep(.45)
def lock():c.eval("document.querySelector('input[type=checkbox],[role=checkbox]').click()");time.sleep(.3)
def shot(name):c.shot(f'artifacts/browser/text047-{sys.argv[1]}-{name}.png')
c.call('Page.enable');c.call('Page.bringToFront');c.call('Page.navigate',{'url':'http://127.0.0.1:5181/?preview=NgTextArea' if flutter else 'http://127.0.0.1:5180/preview/NgTextArea'});time.sleep(3)
if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.4)
focus();minimum=height();check(minimum>20,'minimum visible editor')
click('Load long text');maximum=height();check(maximum>minimum+30,'external multiline text grows editor')
check(len(value().split('\n'))==14,'long text retains all lines');shot('capped')
enter('\n'.join('Line '+str(i) for i in range(30)));check(abs(height()-maximum)<2,'additional lines stay at maximum height')
if not flutter:check(c.eval(field()+'.scrollHeight>'+field()+'.clientHeight'),'overflow scrolls internally')
click('Load short text');check(abs(height()-minimum)<2,'external short text shrinks editor')
enter('One\nTwo\nThree\nFour');check(minimum<height()<maximum,'typing grows within bounds')
click('Clear Delivery notes');check(abs(height()-minimum)<2,'clear shrinks to minimum');check(value()=='','clear preserves empty binding')
enter('Wrapping text for a responsive note. '*10);wide=height()
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});time.sleep(.6)
check(height()>wide,'narrow width grows wrapped text');check(height()<=maximum+2,'wrapped text respects maximum');check(c.eval('document.documentElement.scrollWidth<=innerWidth'),'narrow parent has no overflow');shot('narrow')
c.call('Emulation.clearDeviceMetricsOverride');time.sleep(.6);check(abs(height()-wide)<2,'widening shrinks wrapped text')
lock();click('Load long text');check(abs(height()-maximum)<2,'readonly external content grows');click('Load short text');check(abs(height()-minimum)<2,'readonly external content shrinks');lock()
click('Load long text');click('Toggle automatic height');fixed=height();check(fixed<maximum,'fixed mode restores row height');check(len(value().split('\n'))==14,'mode switch preserves text')
click('Toggle automatic height');check(abs(height()-maximum)<2,'automatic mode restores measured height');stable=height();time.sleep(.7);check(abs(height()-stable)<1,'height remains stable after layout');shot('restored')
if not flutter:
 c.eval('window.removedArea='+field()+';window.removedArea.remove()');time.sleep(.3)
 check(c.eval("window.removedArea.style.height===''"),'DOM removal detaches sizing and restores inline style')
c.s.close()

"""Responsive field span checks in foreground Chrome, CDP port 9341."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
c=CDP();flutter='flutter' in sys.argv
Path('artifacts/browser').mkdir(parents=True,exist_ok=True)
def check(ok,label):
 assert ok,label
 print('PASS',label,flush=True)
def fields():return "[...document.querySelectorAll('input[data-semantics-role=text-field],textarea[data-semantics-role=text-field]')]" if flutter else "[...document.querySelectorAll('.ng-form-cell .ng-input')]"
def rect(i):return c.eval(f"(()=>{{const r={fields()}[{i}].getBoundingClientRect();return {{x:r.x,y:r.y,w:r.width,h:r.height}};}})()")
def click(label):
 c.eval(f"[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}||e.getAttribute('aria-label')==={label!r}).click()");time.sleep(.35)
def content():return c.eval("document.body.innerText+' '+[...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' ')")
def focus(i):
 c.eval(f"{fields()}[{i}].scrollIntoView({{block:'center'}})");r=rect(i)
 for kind in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=kind,button='left',clickCount=1,x=r['x']+25,y=r['y']+15))
 time.sleep(.15)
def enter(i,text):
 focus(i)
 for kind in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',dict(type=kind,key='a',code='KeyA',windowsVirtualKeyCode=65,modifiers=2))
 c.call('Input.insertText',{'text':text});time.sleep(.3)
def value(i):focus(i);return c.eval(f'{fields()}[{i}].value')
def shot(name):c.shot(f'artifacts/browser/form052-{sys.argv[1]}-{name}.png')
c.call('Page.enable');c.call('Page.bringToFront');c.call('Page.navigate',{'url':'http://127.0.0.1:5181/?preview=NgForm' if flutter else 'http://127.0.0.1:5180/preview/NgForm'});time.sleep(3)
if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.4)
check(rect(2)['w']>rect(0)['w']*1.8,'notes fill the complete row');check(rect(3)['y']>rect(2)['y']+rect(2)['h'],'following field starts after full row')
click('Save application');check('Review 2 issue(s)' in content(),'validation works with full-row fields');enter(2,'A retained note')
click('Use three columns');check(rect(2)['w']>rect(0)['w']*2.7,'full row adapts to three columns')
click('Change notes span');check(1.8<rect(2)['w']/rect(3)['w']<2.3,'two-column span has expected width');check(abs(rect(2)['y']-rect(3)['y'])<25,'remaining field uses the last column in the row');check(value(2)=='A retained note','span change preserves note');check('Review 2 issue(s)' in content(),'span change preserves errors');shot('two-columns')
click('Change notes span');check(rect(2)['x']>rect(1)['x'],'single-cell note follows owner in source order');check(abs(rect(2)['w']-rect(0)['w'])<5,'single-cell width restored');check(value(2)=='A retained note','repeated span change preserves note')
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});time.sleep(.5)
check(rect(1)['y']>rect(0)['y'],'narrow form collapses columns');click('Change notes span');check(abs(rect(2)['w']-rect(0)['w'])<5,'full span fits narrow column');click('Change notes span');check(abs(rect(2)['w']-rect(0)['w'])<5,'two-column request clamps to narrow column');check(c.eval('document.documentElement.scrollWidth<=innerWidth'),'narrow spans have no horizontal overflow');check(value(2)=='A retained note','narrow resize preserves note');shot('narrow')
c.call('Emulation.clearDeviceMetricsOverride');time.sleep(.5);check(rect(2)['w']>rect(3)['w']*1.8,'widening restores requested span')
enter(0,'Atlas');enter(1,'Owner');click('Save application');time.sleep(1.1);check('Saved: Atlas' in content(),'form saves after span transitions')
c.s.close()

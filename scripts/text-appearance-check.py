"""Text size/fill interaction checks in foreground Chrome, CDP port 9341."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
c=CDP();flutter='flutter' in sys.argv
Path('artifacts/browser').mkdir(parents=True,exist_ok=True)
def check(ok,label):
 assert ok,label
 print('PASS',label,flush=True)
def field():return "document.querySelector('input[data-semantics-role=text-field],textarea[data-semantics-role=text-field]')" if flutter else "document.querySelector('.ng-text-editor .ng-input')"
def click(label):
 c.eval(f"[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}||e.getAttribute('aria-label')==={label!r}).click()")
 time.sleep(.4)
def focus():
 p=c.eval(f"(()=>{{const e={field()};e.scrollIntoView({{block:'center'}});const r=e.getBoundingClientRect();return {{x:r.x+25,y:r.y+15}};}})()")
 for kind in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=kind,button='left',clickCount=1,**p))
 time.sleep(.15)
def value():focus();return c.eval(field()+'.value')
def height():return c.eval(field()+'.getBoundingClientRect().height')
c.call('Page.enable');c.call('Page.bringToFront')
for component,label in [('NgTextBox','Project name'),('NgTextArea','Delivery notes')]:
 c.call('Page.navigate',{'url':f'http://127.0.0.1:5181/?preview={component}' if flutter else f'http://127.0.0.1:5180/preview/{component}'});time.sleep(3)
 if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.4)
 original=value();medium=height()
 click('Change size');check(value()==original,component+' large preserves value');large=height()
 check(large>medium,component+' large increases editor height')
 click('Change fill');check(value()==original,component+' filled preserves value')
 c.shot(f'artifacts/browser/text048-{sys.argv[1]}-{component}-large.png')
 click('Change size');check(height()<large,component+' small reduces editor height');check(value()==original,component+' small preserves value')
 click('Change fill');check(value()==original,component+' outline preserves value')
 if not flutter:
  check(c.eval("getComputedStyle("+field()+").backgroundColor==='rgba(0, 0, 0, 0)'"),component+' outline transparent')
 click('Change size');check(abs(height()-medium)<2,component+' medium restores metrics')
 click('Change fill');check(value()==original,component+' theme restores original value')
 if component=='NgTextArea':
  click('Load long text');cap=height();click('Change size');check(height()>cap,'autosize recalculates large line metrics');check(len(value().split('\n'))==14,'autosize keeps all lines')
 c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});time.sleep(.5)
 check(c.eval('document.documentElement.scrollWidth<=innerWidth'),component+' narrow layout no document overflow')
 c.shot(f'artifacts/browser/text048-{sys.argv[1]}-{component}-narrow.png')
 c.call('Emulation.clearDeviceMetricsOverride');time.sleep(.3)
 click('Clear '+label);check(value()=='',component+' clear works after appearance switches')
c.s.close()

"""Rounded/flat text editor checks in foreground Chrome on port 9341."""
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
 time.sleep(.3)
def focus():
 p=c.eval(f"(()=>{{const e={field()};e.scrollIntoView({{block:'center'}});const r=e.getBoundingClientRect();return {{x:r.x+25,y:r.y+15}};}})()")
 for kind in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=kind,button='left',clickCount=1,**p))
 time.sleep(.15)
def value():focus();return c.eval(field()+'.value')
def style(prop):return c.eval('getComputedStyle('+field()+').'+prop)
c.call('Page.enable');c.call('Page.bringToFront')
for component,label in [('NgTextBox','Project name'),('NgTextArea','Delivery notes')]:
 c.call('Page.navigate',{'url':f'http://127.0.0.1:5181/?preview={component}' if flutter else f'http://127.0.0.1:5180/preview/{component}'});time.sleep(3)
 if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.4)
 original=value();originalRadius=style('borderTopLeftRadius') if not flutter else None
 click('Toggle flat fill');check(value()==original,component+' flat preserves value')
 if not flutter:
  c.eval(field()+'.blur()');check(style('borderTopColor')=='rgba(0, 0, 0, 0)',component+' flat idle border hidden')
  focus();check(style('borderTopColor')!='rgba(0, 0, 0, 0)',component+' flat focus border visible')
 for rounded,radius in [('large','16px'),('none','0px'),('small','4px'),('medium','8px'),('full','9999px'),('theme',originalRadius)]:
  click('Change corners');check(value()==original,component+' '+rounded+' retains draft')
  if not flutter:check(style('borderTopLeftRadius')==radius,component+' '+rounded+' radius applied')
  if rounded=='large':c.shot(f'artifacts/browser/text053-{sys.argv[1]}-{component}-flat.png')
 click('Toggle flat fill');check(value()==original,component+' theme restores value')
 if component=='NgTextArea':
  click('Load long text');click('Change corners');click('Toggle flat fill');check(len(value().split('\n'))==14,'autosize text retained with flat rounded border')
 c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});time.sleep(.4)
 check(c.eval('document.documentElement.scrollWidth<=innerWidth'),component+' narrow layout fits')
 c.shot(f'artifacts/browser/text053-{sys.argv[1]}-{component}-narrow.png')
 c.call('Emulation.clearDeviceMetricsOverride');time.sleep(.3)
 click('Clear '+label);check(value()=='',component+' clear works after shape switches')
c.s.close()

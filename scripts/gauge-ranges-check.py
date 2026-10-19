"""Gauge 0.37 checks in dedicated foreground Chrome on port 9341."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
c=CDP();flutter='flutter' in sys.argv
out=Path('artifacts/browser');out.mkdir(parents=True,exist_ok=True)
def check(expr,label):
 assert c.eval(expr),label
 print('PASS',label,flush=True)
def click(label):
 expr=f"([...document.querySelectorAll('[aria-label]')].find(e=>e.getAttribute('aria-label')==={label!r})??[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}))"
 if flutter:c.eval(f'{expr}.click()')
 else:
  xy=c.eval(f'(()=>{{const e={expr};e.scrollIntoView({{block:"center"}});const r=e.getBoundingClientRect();return {{x:r.x+r.width/2,y:r.y+r.height/2}};}})()')
  for t in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=t,button='left',clickCount=1,**xy))
 time.sleep(.4)
def shot(name):c.shot(str(out/f'gauge037-{"flutter" if flutter else "blazor"}-{name}.png'))
def text():return "document.body.innerText + [...document.querySelectorAll('[aria-valuetext],[aria-label]')].map(e=>(e.getAttribute('aria-valuetext')||'')+' '+(e.getAttribute('aria-label')||'')).join(' ')"
c.call('Page.enable');c.call('Page.bringToFront')
for name in ['NgLinearGauge','NgArcGauge']:
 url=f'http://127.0.0.1:5181/?preview={name}' if flutter else f'http://127.0.0.1:5180/preview/{name}'
 c.call('Page.navigate',{'url':url});time.sleep(3)
 if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.5)
 check(f"({text()}).includes('72.5 %')",name+' fractional reading')
 click('Above maximum');check(f"({text()}).includes('125.0 %')",name+' retains actual reading')
 check(f"({text()}).includes('High · Above maximum')",name+' out-of-scale status')
 if not flutter:check("document.querySelector('[role=meter]').getAttribute('aria-valuenow')==='100'",name+' bounded numeric meter')
 shot(name+'-above')
 click('Below minimum');check(f"({text()}).includes('Normal · Below minimum')",name+' lower bound status')
 click('Toggle ranges');check(f"!({text()}).includes('Normal · Below minimum')",name+' dynamic range removal')
 click('Toggle ranges');click('Normal');check(f"({text()}).includes('42.5 %')",name+' external update')
 shot(name+'-normal')
 c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});c.call('Page.reload');time.sleep(3)
 check('document.documentElement.scrollWidth<=innerWidth',name+' narrow page');shot(name+'-narrow')
 c.call('Emulation.clearDeviceMetricsOverride')
c.s.close()

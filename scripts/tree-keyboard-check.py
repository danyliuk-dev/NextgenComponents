"""Foreground Chrome keyboard, narrow tree preview and desktop manual checks (CDP 9341)."""
from chrome_cdp import CDP
import time
c=CDP()
def click(label):
 xy=c.eval(f'(()=>{{const e=[...document.querySelectorAll("[aria-label]")].find(e=>e.getAttribute("aria-label")==={label!r})??[...document.querySelectorAll("[role=button]")].find(e=>e.textContent.trim()==={label!r});const r=e.getBoundingClientRect();return {{x:r.x+r.width/2,y:r.y+r.height/2}}}})()')
 for t in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=t,button='left',clickCount=1,**xy))
 time.sleep(.3)
def key(k,n):
 for t in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',{'type':t,'key':k,'windowsVirtualKeyCode':n})
 time.sleep(.3)
for fw in ['blazor','flutter']:
 url='http://127.0.0.1:5180/preview/NgTreeView' if fw=='blazor' else 'http://127.0.0.1:5181/?preview=NgTreeView'
 c.call('Page.navigate',{'url':url});time.sleep(3)
 if fw=='flutter':c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.5)
 click('Design');key('ArrowRight',39);key('Enter',13)
 assert c.eval("document.body.innerText.includes('Selected team: a')")
 key('ArrowDown',40);key('Enter',13)
 assert c.eval("document.body.innerText.includes('Selected team: b')")
 key('ArrowLeft',37);key('Enter',13)
 assert c.eval("document.body.innerText.includes('Selected team: root')")
 print('PASS',fw,'tree keyboard leaf, sibling and parent',flush=True)
 c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});c.call('Page.navigate',{'url':url});time.sleep(3)
 assert c.eval('document.documentElement.scrollWidth<=innerWidth')
 c.shot('artifacts/browser/tree035-'+fw+'-narrow.png');c.call('Emulation.clearDeviceMetricsOverride')
c.call('Page.navigate',{'url':'http://127.0.0.1:5182/desktop?page=manual'});time.sleep(1);c.eval("document.querySelector('iframe').contentWindow.location.href='/docs/manual/NgTreeView.md'");time.sleep(1);c.eval("document.querySelector('iframe').contentDocument.querySelector('#appearance-and-live-example').scrollIntoView()");time.sleep(2);c.shot('artifacts/browser/tree035-desktop.png')
print('PASS desktop manual live preview',flush=True);c.s.close()

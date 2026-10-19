"""Map 0.43 integration checks in foreground Chrome, with no external tiles."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys,json
c=CDP();flutter='flutter' in sys.argv
out=Path('artifacts/browser');out.mkdir(parents=True,exist_ok=True)
f="document.querySelector('iframe')";d=f+'.contentDocument';w=f+'.contentWindow'
def pause():time.sleep(.65)
def check(expr,label):
 assert c.eval(expr),label
 print('PASS',label,flush=True)
def has(text):return f"(document.body.innerText+[...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label')).join(' ')).includes({text!r})"
def control(label):return f"([...document.querySelectorAll('[aria-label]')].find(e=>e.getAttribute('aria-label')==={label!r})??[...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}))"
def click(label):c.eval(f'{control(label)}.click()');pause()
def inner(selector):c.eval(f'{d}.querySelector({selector!r}).click()');pause()
def selected(id):return f"{d}.querySelector('[data-id=\"{id}\"]').getAttribute('aria-pressed')==='true'"
def zoom(n):return f"{d}.querySelector('#position').textContent.includes('zoom {n}')"
def background():
 p=c.eval(f'(()=>{{const a={f}.getBoundingClientRect(),b={d}.querySelector("#map").getBoundingClientRect();return {{x:a.x+b.x+80,y:a.y+b.y+70}};}})()')
 for t in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=t,button='left',clickCount=1,**p))
 pause()
def shot(name):c.shot(str(out/f'map043-{"flutter" if flutter else "blazor"}-{name}.png'))
def send(payload):c.eval(f'{w}.eval({("parent.postMessage({type:\"ng-map-event\",payload:"+json.dumps(json.dumps(payload))+"},location.origin)")!r})');pause()
c.call('Page.enable');c.call('Page.bringToFront');c.call('Page.navigate',{'url':'http://127.0.0.1:5181/?preview=NgMap' if flutter else 'http://127.0.0.1:5180/preview/NgMap'});time.sleep(4)
if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");pause()
check(f"{d}.body.innerText.includes('No basemap configured')",'no external basemap');check(zoom(13),'initial view')
c.eval(f"{w}.addEventListener('message',e=>{{if(e.data?.type==='ng-map-config')window.lastMapConfig=JSON.parse(e.data.payload);}})")
click('Toggle acceptance');inner('[data-id="office"]');check(has('Selected: none'),'rejected selection stays unselected');check('!('+selected('office')+')','rejected highlight unchanged')
inner('.leaflet-control-zoom-in');check(zoom(13),'rejected zoom restored');check(has('View requests: 1'),'one view proposal, no feedback loop');shot('rejected')
click('Toggle acceptance');inner('[data-id="office"]');check(has('Selected: office'),'accepted selection');check(selected('office'),'accepted highlight');inner('.leaflet-control-zoom-in');check(zoom(14),'accepted zoom')
click('Toggle navigation lock');check(f"{d}.querySelector('#fit').disabled",'fit disabled under navigation lock');inner('.leaflet-control-zoom-in');check(zoom(14),'zoom lock enforced');inner('[data-id="park"]');check(has('Selected: park'),'selection works under navigation lock')
click('Reset view');check(zoom(10),'external view applies under lock');check(has('View requests: 2'),'external update emits no callback')
click('Toggle selection lock');check(f"{d}.querySelector('[data-id=office]').disabled",'object list disabled');inner('[data-id="office"]');check(has('Selected: park'),'selection lock retains ID');check(f"{d}.querySelector('#clear').disabled",'clear disabled');background();check(has('Map clicks: 1'),'background clicks independent')
click('Toggle click lock');background();check(has('Map clicks: 1'),'click lock enforced');shot('locked')
click('Toggle selection lock');c.eval(f"window.oldMapButton={d}.querySelector('[data-id=office]')");old=c.eval('window.lastMapConfig.revision');click('Replace objects');send({'kind':'selection','revision':old,'id':'office'});check(has('Selected: park'),'stale packet with reused ID rejected')
c.eval('window.oldMapButton.click()');pause();check(has('Selected: park'),'detached object action ignored');revision=c.eval('window.lastMapConfig.revision');send({'kind':'selection','revision':revision,'id':'missing'});check(has('Selected: park'),'unknown ID rejected');click('Toggle navigation lock');revision=c.eval('window.lastMapConfig.revision');send({'kind':'view','revision':revision,'latitude':90,'longitude':0,'zoom':5});check(zoom(10),'invalid coordinates rejected');click('Toggle navigation lock')
inner('#clear');check(has('Selected: none'),'clear accepted');inner('.ng-cluster');check(f"!!{d}.querySelector('.ng-cluster-list')",'chooser opens with navigation locked');inner('[data-member="office"]');check(has('Selected: office'),'cluster member selection');check(f"{d}.body.innerText.includes('Office updated')",'replacement label');shot('cluster')
click('Toggle empty map');check(f"{d}.body.innerText.includes('No delivery points')",'custom empty state');click('Toggle empty map');check(f"!!{d}.querySelector('[data-id=office]')",'objects restored')
c.eval(f"window.localMapConfig={{...window.lastMapConfig,navigationReadOnly:false,selectionEnabled:false,clickEnabled:false,controlledView:false}};{w}.postMessage({{type:'ng-map-config',payload:JSON.stringify(window.localMapConfig)}},location.origin)");pause()
inner('.leaflet-control-zoom-in');check(zoom(11),'local navigation without view callback');c.eval(f"{w}.postMessage({{type:'ng-map-config',payload:JSON.stringify({{...window.localMapConfig,dark:true}})}},location.origin)");pause();check(zoom(11),'local view survives unrelated config');check(f"{d}.querySelector('[data-id=office]').disabled",'missing selection handler disables action')
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});c.call('Page.reload');time.sleep(4)
check('document.documentElement.scrollWidth<=innerWidth','narrow parent no overflow');check(f'{d}.documentElement.scrollWidth<={w}.innerWidth','narrow iframe no overflow');shot('narrow');c.call('Emulation.clearDeviceMetricsOverride');c.s.close()

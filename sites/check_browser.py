"""Visible Chrome layout/navigation checks; pass live after publication."""
import sys,time,json
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'scripts'))
from chrome_cdp import CDP
c=CDP();out=Path('artifacts/sites');out.mkdir(parents=True,exist_ok=True)
live='live' in sys.argv
checks=0
def check(expr,label):
 global checks
 assert c.eval(expr),label
 checks+=1;print('PASS',label,flush=True)
def visit(url):
 c.call('Page.navigate',{'url':url});time.sleep(1.6)
def shot(name):c.shot(str(out/(name+'.png')))
c.call('Page.enable');c.call('Page.bringToFront')
for kind,port in [('components',5290),('reports',5291)]:
 origin=f'https://{kind}.softwarenextgen.com' if live else f'http://127.0.0.1:{port}'
 c.call('Emulation.setDeviceMetricsOverride',{'width':1440,'height':1000,'deviceScaleFactor':1,'mobile':False})
 visit(origin+'/')
 check(f"document.title.includes('Nextgen {kind.title()}')",kind+' title')
 check('document.documentElement.scrollWidth<=innerWidth',kind+' desktop fits')
 check('[...document.images].every(i=>i.complete&&i.naturalWidth>0)',kind+' real screenshots loaded')
 check("!document.documentElement.outerHTML.includes('daniluk.devel@gmail.com')",kind+' no private email in HTML')
 check("document.querySelectorAll('[download]').length===0",kind+' no downloads')
 shot(kind+'-desktop')
 c.eval("document.querySelector('#preorder').scrollIntoView()");time.sleep(.25)
 check("document.querySelector('input[type=email]').required && document.querySelector('input[name=consent]').required",kind+' required email and consent')
 shot(kind+'-form')
 visit(origin+'/docs/')
 check("document.querySelector('.sidebar')&&document.querySelectorAll('.sidebar a').length>10",kind+' documentation tree')
 query='grid' if kind=='components' else 'data'
 c.eval(f"(()=>{{const e=document.querySelector('#doc-search');e.value={query!r};e.dispatchEvent(new Event('input',{{bubbles:true}}));}})()")
 check("[...document.querySelectorAll('.sidebar a[data-search]')].filter(a=>!a.hidden).length>0 && [...document.querySelectorAll('.sidebar a[data-search]')].some(a=>a.hidden)",kind+' docs search filters')
 visit(origin+('/docs/NgDataGrid/' if kind=='components' else '/docs/template-format/'))
 check("!!document.querySelector('pre.highlight span')",kind+' syntax highlighted examples')
 check('document.documentElement.scrollWidth<=innerWidth',kind+' documentation fits')
 shot(kind+'-docs')
 c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':True})
 visit(origin+'/')
 check('document.documentElement.scrollWidth<=innerWidth',kind+' mobile fits')
 shot(kind+'-mobile')
 c.eval("document.querySelector('#preorder').scrollIntoView()");time.sleep(.2);shot(kind+'-mobile-form')
 visit(origin+'/docs/')
 check("document.querySelector('.sidebar').hidden",kind+' mobile navigation starts folded')
 c.eval("document.querySelector('.mobile-docs').click()")
 check("!document.querySelector('.sidebar').hidden",kind+' mobile navigation opens')
 check('document.documentElement.scrollWidth<=innerWidth',kind+' mobile docs fits')
c.call('Emulation.clearDeviceMetricsOverride');c.s.close();print('PASS',checks,'visible Chrome site checks')

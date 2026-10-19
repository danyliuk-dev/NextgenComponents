"""PDF thumbnail regression in the dedicated visible Chrome (CDP 9341)."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys,base64
c=CDP();flutter='flutter' in sys.argv
f="document.querySelector('iframe')";d=f+'.contentDocument';w=f+'.contentWindow'
def wait(expr):
 for _ in range(100):
  if c.eval(expr):return
  time.sleep(.15)
 raise AssertionError(expr)
def check(expr,label):
 assert c.eval(expr),label
 print('PASS',label,flush=True)
def q(id):return d+f'.getElementById({id!r})'
def click(id):c.eval(q(id)+'.click()');time.sleep(.3)
def ready():wait(q('status')+".textContent.startsWith('Page ')")
def load(data,name):
 encoded=base64.b64encode(data).decode()
 c.eval(f"(()=>{{const dt=new DataTransfer();dt.items.add(new File([Uint8Array.from(atob('{encoded}'),x=>x.charCodeAt(0))],'{name}'));{q('file')}.files=dt.files;{q('file')}.dispatchEvent(new Event('change'));}})()")
def shot(name):c.shot(f'artifacts/browser/pdf044-{sys.argv[1]}-{name}.png')
Path('artifacts/browser').mkdir(parents=True,exist_ok=True)
c.call('Page.enable');c.call('Page.bringToFront');c.call('Page.navigate',{'url':'http://127.0.0.1:5181/?preview=NgPdfViewer' if flutter else 'http://127.0.0.1:5180/preview/NgPdfViewer'});time.sleep(4)
wait(f"!!{f}?.contentDocument?.getElementById('status')");ready()
check(q('thumbnails')+'.hidden','rail starts closed');click('thumbnails-toggle')
wait(q('thumbnails')+".querySelectorAll('canvas').length>0")
check(q('thumbnails')+".children.length===3",'one button per page')
c.eval(q('thumbnails')+".querySelector('[data-page=\"2\"]').focus()")
for kind in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',{'type':kind,'key':'Enter','code':'Enter','windowsVirtualKeyCode':13,**({'text':'\r'} if kind=='keyDown' else {})})
wait(q('status')+".textContent.startsWith('Page 2 ')")
check(q('thumbnails')+".querySelector('[aria-current]').dataset.page==='2'",'keyboard thumbnail navigation selects page')
click('next');ready();check(q('thumbnails')+".querySelector('[aria-current]').dataset.page==='3'",'toolbar synchronizes selected thumbnail')
c.eval(q('query')+".value='approval';"+q('search-form')+'.requestSubmit()')
wait(q('search-status')+".textContent==='3 matching pages.'")
c.eval(q('results')+'.firstElementChild.click()');ready()
check(q('thumbnails')+".querySelector('[aria-current]').dataset.page==='1'",'search synchronizes selected thumbnail')
check(w+".CSS.highlights.get('pdf-search').size>0",'page search highlights retained')
c.eval(q('text-panel')+'.open=false');shot('thumbnails')
click('thumbnails-toggle');check(q('thumbnails')+".querySelectorAll('canvas').length===0",'closing rail releases canvases')
# Minimal original 30-page fixture, no external generator dependency.
objects=['<< /Type /Catalog /Pages 2 0 R >>',
 '<< /Type /Pages /Count 30 /Kids ['+' '.join(f'{4+n*2} 0 R' for n in range(30))+'] >>',
 '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>']
for n in range(30):
 content=f'BT /F1 20 Tf 40 700 Td (Thumbnail regression page {n+1}) Tj ET'
 objects.extend([f'<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 3 0 R >> >> /Contents {5+n*2} 0 R >>',f'<< /Length {len(content)} >>\nstream\n{content}\nendstream'])
data=b'%PDF-1.4\n';offsets=[0]
for n,obj in enumerate(objects,1):
 offsets.append(len(data));data+=f'{n} 0 obj\n{obj}\nendobj\n'.encode()
xref=len(data);data+=f'xref\n0 {len(objects)+1}\n0000000000 65535 f \n'.encode()
for offset in offsets[1:]:data+=f'{offset:010d} 00000 n \n'.encode()
data+=f'trailer << /Size {len(objects)+1} /Root 1 0 R >>\nstartxref\n{xref}\n%%EOF'.encode()
load(data,'thirty-pages.pdf');ready();click('thumbnails-toggle')
wait(q('thumbnails')+".querySelectorAll('canvas').length>0")
check(q('thumbnails')+".children.length===30 && "+q('thumbnails')+".querySelectorAll('canvas').length<8",'long document renders only visible thumbnails')
c.eval(q('page')+".value=30;"+q('page')+".dispatchEvent(new Event('change'))")
wait(q('status')+".textContent.startsWith('Page 30 ')");wait(q('thumbnails')+".querySelector('[data-page=\"30\"] canvas')!==null")
check(q('thumbnails')+".querySelector('[data-page=\"1\"] canvas')===null",'scrolling releases earlier raster')
check(q('thumbnails')+".querySelector('[aria-current]').dataset.page==='30'",'direct page reveals final thumbnail')
check(f"[...{q('thumbnails')}.querySelectorAll('canvas')].every(e=>e.width<=224&&e.height<=288)",'thumbnail raster bounds')
c.eval(f"window.oldThumbnail={q('thumbnails')}.lastElementChild")
load(b'broken','broken.pdf');wait(q('status')+".classList.contains('error')")
check(q('thumbnails')+".children.length===0 && "+q('thumbnails-toggle')+'.disabled','invalid replacement clears rail')
load(Path('examples/BlazorGallery/wwwroot/samples/nextgen-guide.pdf').read_bytes(),'recovered.pdf');ready()
c.eval('window.oldThumbnail.click()');time.sleep(.2);check(q('page')+".value==='1'",'detached old document action ignored')
click('thumbnails-toggle');wait(q('thumbnails')+".querySelector('canvas')!==null")
c.eval(d+".documentElement.dataset.theme='dark'");shot('dark')
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});time.sleep(1)
check('document.documentElement.scrollWidth<=innerWidth','narrow parent fits')
check(d+'.documentElement.scrollWidth<='+w+'.innerWidth','narrow iframe fits')
check(q('viewport')+'.clientWidth>100','narrow page remains usable');shot('narrow')
c.call('Emulation.clearDeviceMetricsOverride');c.s.close()

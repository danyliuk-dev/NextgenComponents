"""Run against the isolated foreground review Chrome on CDP 9341."""
from chrome_cdp import CDP
from pathlib import Path
import time

c = CDP()
out = Path('artifacts/browser'); out.mkdir(parents=True, exist_ok=True)
def check(expression, label):
    assert c.eval(expression), label
    print('PASS', label)
def pause(): time.sleep(.7)
def open_page(url):
    c.call('Page.navigate', {'url': url}); time.sleep(2)
def click(expression):
    c.eval(f'({expression}).click()'); pause()

def frame_eval(port, expression):
    frames=c.call('Page.getFrameTree')['frameTree']['childFrames']
    frame=next(f['frame'] for f in frames if f['frame']['url'].startswith(f'http://127.0.0.1:{port}/'))
    context=c.call('Page.createIsolatedWorld',{'frameId':frame['id'],'worldName':'nextgen-review'})['executionContextId']
    result=c.call('Runtime.evaluate',{'expression':expression,'contextId':context,'returnByValue':True})
    assert 'exceptionDetails' not in result,result
    return result['result'].get('value')

c.call('Page.enable'); c.call('Page.bringToFront')
open_page('http://127.0.0.1:5182/desktop?page=manual')
check("document.querySelector('iframe').contentDocument.querySelector('#component-search')!==null", 'documentation search in app')
c.eval("document.querySelector('iframe').contentWindow.location.href='/docs/manual/NgDatePicker.md'");pause()
click("document.querySelector('[data-page=blazor]')")
assert frame_eval(5180,"document.body.innerText.includes('Workspace settings')"),'Blazor embedded'
frame_eval(5180,"document.querySelector('input:not([type=checkbox])').value='Desktop retained draft'")
click("document.querySelector('[data-page=flutter]')");time.sleep(3)
assert frame_eval(5181,"document.querySelector('flutter-view')!==null"),'Flutter embedded'
c.shot(str(out/'desktop032-flutter.png'))
click("document.querySelector('[data-page=blazor]')")
assert frame_eval(5180,"document.querySelector('input:not([type=checkbox])').value==='Desktop retained draft'"),'Blazor draft retained'
c.shot(str(out/'desktop032-blazor.png'))
click("document.querySelector('[data-page=manual]')")
check("document.querySelector('iframe:not([hidden])').contentWindow.location.pathname.endsWith('/NgDatePicker.md')",'documentation page retained')
check("document.querySelectorAll('iframe').length===3",'one retained frame per section')
c.shot(str(out/'desktop032-manual.png'))
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False})
check('document.documentElement.scrollWidth<=innerWidth','narrow shell has no overflow')
c.shot(str(out/'desktop032-narrow.png'))
c.call('Emulation.clearDeviceMetricsOverride')
for name in ['NgDateInput','NgDatePicker']:
    open_page('http://127.0.0.1:5180/preview/'+name)
    c.eval("(()=>{const e=document.querySelector('input');e.value='2026-10-25';e.dispatchEvent(new Event('input',{bubbles:true}));})()");pause()
    check("document.body.innerText.includes('This date is not available.')",name+' rejects Sunday')
    c.eval("(()=>{const e=document.querySelector('input');e.value='';e.dispatchEvent(new Event('input',{bubbles:true}));})()");pause()
    check("!document.body.innerText.includes('This date is not available.')&&!document.body.innerText.includes('Enter a valid date')",name+' optional clearing')
    click("[...document.querySelectorAll('button')].find(b=>b.textContent==='Read only')")
    check("document.querySelector('input').readOnly",name+' readonly')
    c.shot(str(out/('dates032-'+name+'.png')))
open_page('http://127.0.0.1:5180/preview/NgCalendar')
click("[...document.querySelectorAll('button')].find(b=>b.textContent==='Read only')")
check("[...document.querySelectorAll('.ng-calendar button')].every(b=>b.disabled)",'calendar read-only blocks navigation and selection')
open_page('http://127.0.0.1:5182/desktop?page=manual')
print('PASS desktop navigation, retained state, both embedded galleries, narrow layout and Blazor date editing')
c.s.close()

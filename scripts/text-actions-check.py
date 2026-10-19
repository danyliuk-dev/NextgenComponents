"""Text clear/password regression in foreground Chrome on the local iMac."""
from chrome_cdp import CDP
from pathlib import Path
import time,sys
c=CDP();flutter='flutter' in sys.argv
Path('artifacts/browser').mkdir(parents=True,exist_ok=True)
def control(label):return f"([...document.querySelectorAll('button,[role=button]')].find(e=>e.textContent.trim()==={label!r}||e.getAttribute('aria-label')==={label!r}))"
def click(label):c.eval(control(label)+'.click()');time.sleep(.35)
def native_click(label):
 p=c.eval(f"(()=>{{const r={control(label)}.getBoundingClientRect();return {{x:r.x+r.width/2,y:r.y+r.height/2}};}})()")
 for kind in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=kind,button='left',clickCount=1,**p))
 time.sleep(.3)
def field():return "document.querySelector('input[data-semantics-role=text-field],textarea[data-semantics-role=text-field]')" if flutter else "document.querySelector('.ng-text-editor .ng-input')"
def check(expr,label):
 assert c.eval(expr),label
 print('PASS',label,flush=True)
def enabled(label):return f"(()=>{{const e={control(label)};return !!e&&!e.disabled&&e.getAttribute('aria-disabled')!=='true';}})()"
def locked():c.eval("document.querySelector('input[type=checkbox],[role=checkbox]').click()");time.sleep(.35)
def visit(component):
 c.call('Page.navigate',{'url':f'http://127.0.0.1:5181/?preview={component}' if flutter else f'http://127.0.0.1:5180/preview/{component}'});time.sleep(3)
 if flutter:c.eval("document.querySelector('flt-semantics-placeholder')?.click()");time.sleep(.4)
 click('Focus editor')
def shot(name):c.shot(f'artifacts/browser/text046-{sys.argv[1]}-{name}.png')
def enter(text):
 p=c.eval(f"(()=>{{const e={field()};e.scrollIntoView({{block:'center'}});const r=e.getBoundingClientRect();return {{x:r.x+30,y:r.y+15}};}})()")
 for kind in ['mousePressed','mouseReleased']:c.call('Input.dispatchMouseEvent',dict(type=kind,button='left',clickCount=1,**p))
 for kind in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',dict(type=kind,key='a',code='KeyA',windowsVirtualKeyCode=65,modifiers=2))
 c.call('Input.insertText',{'text':text});time.sleep(.35)
c.call('Page.enable');c.call('Page.bringToFront');visit('NgTextBox')
check(field()+".type==='password'",'password starts masked')
click('Show password');check(field()+".type!=='password'",'explicit reveal shows text')
check(field()+".value==='Design review'",'reveal preserves value');shot('revealed')
locked();check(field()+".type==='password'",'read-only hides password')
check('!'+enabled('Show password'),'read-only disables reveal');check('!'+enabled('Clear Project name'),'read-only disables clear')
locked();click('Clear Project name');check(field()+".value===''",'clear empties value');check('!'+enabled('Clear Project name'),'empty clear disabled')
check(field()+'.matches(":focus")','clear restores focus')
enter('Sample 046');native_click('Show password');check(field()+".type!=='password'",'native click reveals password')
for _ in range(2):
 for kind in ['keyDown','keyUp']:c.call('Input.dispatchKeyEvent',dict(type=kind,key='Tab',code='Tab',windowsVirtualKeyCode=9))
time.sleep(.35);check(field()+".type==='password'",'keyboard focus exit hides password')
click('Focus editor');click('Show password');click('Hide password');check(field()+".type==='password'",'explicit hide restores mask')
click('Toggle password mode');check(field()+".type!=='password'",'plain-text mode');check('!'+control('Show password'),'plain mode omits reveal');shot('plain')
c.call('Emulation.setDeviceMetricsOverride',{'width':390,'height':844,'deviceScaleFactor':1,'mobile':False});click('Toggle password mode');time.sleep(.4)
check('document.documentElement.scrollWidth<=innerWidth','narrow field and actions fit');shot('narrow');c.call('Emulation.clearDeviceMetricsOverride')
visit('NgTextArea');check(field()+".value==='Design review'",'multiline starts with bound value')
locked();check('!'+enabled('Clear Delivery notes'),'multiline lock disables clear');locked();click('Clear Delivery notes')
check(field()+".value===''",'multiline clear empties value');check(field()+'.matches(":focus")','multiline clear restores focus')
enter('First line\nSecond line');check(field()+".value==='First line\\nSecond line'",'multiline editing survives clear');shot('multiline')
c.s.close()

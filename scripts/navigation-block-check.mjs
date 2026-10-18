// Visible Chrome/CDP: node scripts/navigation-block-check.mjs [blazor|flutter].
import {mkdir, writeFile} from 'node:fs/promises';
const tabs=await(await fetch('http://127.0.0.1:9341/json/list')).json();
const target=tabs.find(t=>t.type==='page');
const flutter=process.argv[2]==='flutter';
if(!target)throw Error('Open a gallery in the visible review Chrome first');
const ws=new WebSocket(target.webSocketDebuggerUrl);let id=0;const pending=new Map();
await new Promise((resolve,reject)=>{ws.onopen=resolve;ws.onerror=reject;});
ws.onmessage=e=>{const d=JSON.parse(e.data);const p=pending.get(d.id);if(p){pending.delete(d.id);d.error?p.reject(Error(JSON.stringify(d.error))):p.resolve(d.result);}};
const command=(method,params={})=>new Promise((resolve,reject)=>{pending.set(++id,{resolve,reject});ws.send(JSON.stringify({id,method,params}));});
const evaluate=async(expression)=>{const r=await command('Runtime.evaluate',{expression,returnByValue:true,awaitPromise:true});if(r.exceptionDetails)throw Error(JSON.stringify(r.exceptionDetails));return r.result.value;};
const wait=()=>evaluate('new Promise(r=>setTimeout(r,500))');
const click=async(expression)=>{
 const {x,y}=await evaluate(`(()=>{const el=${expression};if(!el)throw Error('Missing click target');const r=el.getBoundingClientRect();return {x:r.x+r.width/2,y:r.y+r.height/2};})()`);
 for(const type of ['mousePressed','mouseReleased'])await command('Input.dispatchMouseEvent',{type,x,y,button:'left',clickCount:1});await wait();
};
const control=(name)=>flutter?`[...document.querySelectorAll('[role=button],[role=checkbox],[role=switch],[role=menuitem]')].find(e=>e.getAttribute('aria-label')===${JSON.stringify(name)}||e.textContent===${JSON.stringify(name)})`:`[...document.querySelectorAll('button,input')].find(e=>e.getAttribute('aria-label')===${JSON.stringify(name)}||e.textContent.trim()===${JSON.stringify(name)}||e.closest('label')?.textContent.trim()===${JSON.stringify(name)})`;
const key=async(key,code,windowsVirtualKeyCode)=>{for(const type of ['keyDown','keyUp'])await command('Input.dispatchKeyEvent',{type,key,code,windowsVirtualKeyCode});await wait();};
const check=async(expr,message)=>{if(!await evaluate(expr))throw Error(message);};
const clickControl=async(name)=>{
 const expr=control(name);
 if(!flutter)await evaluate(`(${expr})?.scrollIntoView({block:'center',behavior:'instant'})`);
 else {const y=await evaluate(`(()=>{const e=${expr};if(!e)throw Error('Missing '+${JSON.stringify(name)});return e.getBoundingClientRect().y;})()`);if(y>900||y<0){await command('Input.dispatchMouseEvent',{type:'mouseWheel',x:1000,y:700,deltaX:0,deltaY:y-450});await wait();}}
 await click(expr);
};
const shot=async(label)=>{await mkdir('artifacts/browser',{recursive:true});const r=await command('Page.captureScreenshot',{format:'png'});await writeFile(`artifacts/browser/navigation027-${flutter?'flutter':'blazor'}-${label}.png`,Buffer.from(r.data,'base64'));};
try{
 await command('Page.enable');await command('Runtime.enable');await command('Page.bringToFront');await command('Network.enable');await command('Network.setCacheDisabled',{cacheDisabled:true});
 await command('Emulation.setDeviceMetricsOverride',{width:1440,height:1000,deviceScaleFactor:1,mobile:false});
 await command('Page.navigate',{url:flutter?'http://127.0.0.1:5181/':'http://127.0.0.1:5180/navigation'});await evaluate('new Promise(r=>setTimeout(r,2500))');
 if(flutter){await evaluate("document.querySelector('flt-semantics-placeholder')?.click()");await wait();await clickControl('Menu and drawer');}
 await clickControl('Keep menu open');await clickControl('Workspace');await clickControl('Create request');
 await check("document.body.innerText.includes('Command: create · Invocations: 1')",'command callback');
 await check(flutter?`!!(${control('Create request')})`:"document.querySelectorAll('[popover]:popover-open').length===1",'keep menu open');
 await check("!document.body.innerText.includes('Internal command')",'hidden item');
 await key('Escape','Escape',27);await clickControl('Right-to-left');
 if(!flutter){await evaluate("document.querySelector('[data-menu-id=workspace]').focus()");await key('ArrowLeft','ArrowLeft',37);await check("document.activeElement.getAttribute('data-menu-id')==='help'",'RTL skips disabled sibling');await key('ArrowRight','ArrowRight',39);await check("document.activeElement.getAttribute('data-menu-id')==='workspace'",'RTL reverse');}
 await clickControl('Workspace');
 if(flutter){const r=await evaluate(`(()=>{const r=(${control('Export')}).getBoundingClientRect();return {x:r.x+r.width/2,y:r.y+r.height/2};})()`);await command('Input.dispatchMouseEvent',{type:'mouseMoved',...r});await wait();}else await clickControl('Export');
 await clickControl('PDF document');
 await check("document.body.innerText.includes('Command: pdf · Invocations: 2')",'nested leaf');await shot('menu');await key('Escape','Escape',27);await key('Escape','Escape',27);
 await clickControl('Right-to-left');await clickControl('End position');await clickControl('Keep drawer open');await clickControl('Open navigation');
 await clickControl('Reports');await check("document.body.innerText.includes('Reports')",'drawer retained after selection');
 if(!flutter){await check("document.querySelector('dialog').open && document.querySelector('dialog').getBoundingClientRect().left>innerWidth/2",'end LTR overlay');await check("document.querySelector('dialog [aria-current=page]').textContent.includes('Reports')",'selected Reports');}
 else await check("[...document.querySelectorAll('flt-semantics')].some(e=>e.textContent==='Project workspace'&&e.getBoundingClientRect().x>innerWidth/2)",'end LTR overlay');
 await shot('end');await key('Escape','Escape',27);
 await clickControl('Right-to-left');await clickControl('Dark theme');await clickControl('Open navigation');
 if(!flutter)await check("document.querySelector('dialog').getBoundingClientRect().left<2",'end RTL overlay');
 else await check("[...document.querySelectorAll('flt-semantics')].some(e=>e.textContent==='Project workspace'&&e.getBoundingClientRect().x<innerWidth/2)",'end RTL overlay');
 await shot('rtl-dark');await key('Escape','Escape',27);await clickControl('Hide Reports');await clickControl('Open navigation');
 if(!flutter)await check("!document.querySelector('dialog button[aria-label=Reports]')",'hidden destination');else await check(`!(${control('Reports')})`,'hidden destination');await key('Escape','Escape',27);
 await clickControl('Overlay mode');await clickControl('Open navigation');await clickControl('Disable drawer');
 if(!flutter)await check("document.querySelector('aside button[aria-label=Overview]').disabled",'disabled destination');
 await shot('push');
 await command('Emulation.setDeviceMetricsOverride',{width:390,height:844,deviceScaleFactor:1,mobile:false});await command('Page.reload');await evaluate('new Promise(r=>setTimeout(r,2500))');
 if(flutter){await evaluate("document.querySelector('flt-semantics-placeholder')?.click()");await wait();await clickControl('Menu and drawer');}
 await check('document.documentElement.scrollWidth<=innerWidth','narrow document overflow');await shot('narrow');
 console.log('PASS '+(flutter?'Flutter':'Blazor')+' templates, nested keep-open commands, hidden entries, end/RTL overlays, selection, Escape, dark, push and narrow gallery');
}finally{ws.close();}

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
const shot=async(label)=>{await mkdir('artifacts/browser',{recursive:true});const r=await command('Page.captureScreenshot',{format:'png'});await writeFile(`artifacts/browser/steps028-${flutter?'flutter':'blazor'}-${label}.png`,Buffer.from(r.data,'base64'));};
const pause=async(ms=1300)=>evaluate(`new Promise(r=>setTimeout(r,${ms}))`);
const fill=async()=>{const e="document.querySelector('input[aria-label=\"Applicant name\"]')";if(!flutter)await evaluate(`(${e}).scrollIntoView({block:'center'})`);await click(e);await command('Input.insertText',{text:'Alex Example'});await wait();};
try {
 await command('Page.enable');await command('Runtime.enable');await command('Page.bringToFront');
 await command('Emulation.setDeviceMetricsOverride',{width:1440,height:1000,deviceScaleFactor:1,mobile:false});
 await command('Page.navigate',{url:flutter?'http://127.0.0.1:5181/':'http://127.0.0.1:5180/steps'});await pause(3000);
 if(flutter){await evaluate("document.querySelector('flt-semantics-placeholder')?.click()");await wait();await clickControl('Steps and wizard');}
 await clickControl('Block transitions');await clickControl('Continue');await pause();
 await check("document.body.innerText.includes('Guard: Blocked')",'blocked transition');
 await clickControl('Block transitions');await clickControl('Continue');await pause();
 await check("document.body.innerText.includes('Enter an applicant name')",'validation error');
 await fill();await clickControl('Continue');await clickControl('Reset wizard');await pause();
 await check("document.body.innerText.includes('Saved: 0 · Guard: Ready') && document.body.innerText.includes('Contact details')",'reset pending transition');
 await fill();await clickControl('Custom actions');await clickControl('Continue');await pause();
 await check("document.body.innerText.includes('This optional step')",'skip disabled step');
 await clickControl('Previous');await pause();await check("document.body.innerText.includes('Contact details')",'back');
 await clickControl('Continue');await pause();await clickControl('Continue');await pause();
 await check("document.body.innerText.includes('Review application')",'review');await clickControl('Submit application');await pause(1800);
 await check("document.body.innerText.includes('Saved: 1') && document.body.innerText.includes('Application complete')",'finish once');await shot('completed');
 await clickControl('Reset wizard');await clickControl('Right-to-left');await clickControl('Dark theme');await shot('rtl-dark');
 await command('Emulation.setDeviceMetricsOverride',{width:390,height:844,deviceScaleFactor:1,mobile:false});await command('Page.reload');await pause(3000);
 if(flutter){await evaluate("document.querySelector('flt-semantics-placeholder')?.click()");await wait();await clickControl('Steps and wizard');}
 await clickControl('Custom actions');await check('document.documentElement.scrollWidth<=innerWidth','narrow overflow');await shot('narrow');
 console.log('PASS '+(flutter?'Flutter':'Blazor')+' guard, validation, pending reset, custom actions, disabled step, back, finish, RTL, dark, narrow');
} finally {ws.close();}

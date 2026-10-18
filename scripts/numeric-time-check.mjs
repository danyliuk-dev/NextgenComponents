// Visible Chrome/CDP: node scripts/numeric-time-check.mjs [blazor|flutter].
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
const shot=async(label)=>{await mkdir('artifacts/browser',{recursive:true});const r=await command('Page.captureScreenshot',{format:'png'});await writeFile(`artifacts/browser/numeric031-${flutter?'flutter':'blazor'}-${label}.png`,Buffer.from(r.data,'base64'));};
const pause=async(ms=1000)=>evaluate(`new Promise(r=>setTimeout(r,${ms}))`);
const open=async(name)=>{await command('Page.navigate',{url:flutter?`http://127.0.0.1:5181/?preview=${name}`:`http://127.0.0.1:5180/preview/${name}`});await pause(2500);if(flutter){await evaluate("document.querySelector('flt-semantics-placeholder')?.click()");await wait();}};
const field="document.querySelector('input:not([type=checkbox]):not([type=hidden]),textarea')";
const fill=async(text)=>{await click(field);await command('Input.dispatchKeyEvent',{type:'keyDown',key:'a',code:'KeyA',windowsVirtualKeyCode:65,modifiers:2});await command('Input.dispatchKeyEvent',{type:'keyUp',key:'a',code:'KeyA',windowsVirtualKeyCode:65,modifiers:2});await command('Input.insertText',{text});await wait();};
try{
await command('Page.enable');await command('Runtime.enable');await command('Page.bringToFront');await command('Emulation.setDeviceMetricsOverride',{width:1000,height:800,deviceScaleFactor:1,mobile:false});
await open('NgNumericTextBox');await fill('99');await key('Tab','Tab',9);await clickControl('Save amount');
await check("!document.body.innerText.includes('Saved amount:')&&document.body.innerText.includes('Accepted amount: 2')",'invalid draft cannot save or change model');await shot('invalid');
await clickControl('Increase Amount');await clickControl('Save amount');await check("document.body.innerText.includes('Saved amount: 2.5')",'spin repairs invalid draft');
await fill('9.9');await clickControl('Increase Amount');await check("document.body.innerText.includes('Accepted amount: 10')",'clamp at maximum');
await fill('garbage');await key('Tab','Tab',9);await clickControl('Save amount');await clickControl('Decrease Amount');await check("document.body.innerText.includes('Accepted amount: 9.5')",'invalid syntax retains model and decrement repairs');
await clickControl('Read only');await click(field);await command('Input.insertText',{text:'NO'});await check(`(${field}).readOnly && (${field}).value==='9.5'`,'readonly preserves value');await shot('readonly');
for(const name of ['NgTimePicker','NgDateTimePicker']){
 await open(name);const prefix=name==='NgTimePicker'?'':'2026-10-20 ';
 await fill(prefix+'09:17');await key('Tab','Tab',9);
 await check("document.body.innerText.includes('15-minute intervals')||[...document.querySelectorAll('[aria-label]')].some(e=>e.getAttribute('aria-label').includes('15-minute intervals'))",name+' rejects off-step time');await shot(name+'-error');
 await fill(prefix+'09:45');await key('Tab','Tab',9);await check("!document.body.innerText.includes('15-minute intervals')",name+' accepts on-step time');
}
await command('Emulation.setDeviceMetricsOverride',{width:390,height:844,deviceScaleFactor:1,mobile:false});await open('NgNumericTextBox');await check('document.documentElement.scrollWidth<=innerWidth','narrow overflow');await shot('narrow');
console.log('PASS '+(flutter?'Flutter':'Blazor')+' numeric validation, draft retention, spin recovery/clamping, read-only, time intervals and narrow layout');
}finally{ws.close();}

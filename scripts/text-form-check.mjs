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
const shot=async(label)=>{await mkdir('artifacts/browser',{recursive:true});const r=await command('Page.captureScreenshot',{format:'png'});await writeFile(`artifacts/browser/forms029-${flutter?'flutter':'blazor'}-${label}.png`,Buffer.from(r.data,'base64'));};
const pause=async(ms=1400)=>evaluate(`new Promise(r=>setTimeout(r,${ms}))`);
const open=async(name)=>{await command('Page.navigate',{url:flutter?`http://127.0.0.1:5181/?preview=${name}`:`http://127.0.0.1:5180/preview/${name}`});await pause(2500);if(flutter){await evaluate("document.querySelector('flt-semantics-placeholder')?.click()");await wait();}};
const field="document.querySelector('input:not([type=checkbox]):not([type=hidden]),textarea')";
try{
 await command('Page.enable');await command('Runtime.enable');await command('Page.bringToFront');await command('Emulation.setDeviceMetricsOverride',{width:1000,height:800,deviceScaleFactor:1,mobile:false});
 for(const name of ['NgTextBox','NgTextArea']){
 await open(name);await clickControl('Read only');await clickControl('Focus editor');
 await check(`document.activeElement===(${field})`,'focus hook '+name);
 await command('Input.insertText',{text:'SHOULD NOT CHANGE'});await wait();
 await check(`(${field}).value==='Design review'`,'readonly retains value '+name);
 await clickControl('Read only');await clickControl('Focus editor');await command('Input.insertText',{text:' edited'});await key('Tab','Tab',9);
 await check(`(${field}).value.includes('edited')`,'typing '+name);await shot(name);
 }
 await open('NgForm');await clickControl('Save application');await pause();
 await check("document.body.innerText.includes('required')||document.body.innerText.includes('Enter an application name')",'validation blocks save');
 await click(field);await command('Input.insertText',{text:'Alex review'});await key('Tab','Tab',9);
 await clickControl('Simulate save failure');await clickControl('Save application');await pause();
 await check("document.body.innerText.includes('Unable to save. Try again.')",'recoverable save failure');
 await check(`(${field}).value==='Alex review'`,'draft retained after validation and save error');await shot('error');
 await clickControl('Simulate save failure');await clickControl('Save application');await pause();
 await check("document.body.innerText.includes('Saved: Alex review')",'retry saves');await shot('saved');
 await clickControl('Save application');await clickControl('Reset application');await pause();
 await check("document.body.innerText.includes('Not saved')&&!document.body.innerText.includes('Saved: Alex review')",'reset ignores pending save');
 await command('Emulation.setDeviceMetricsOverride',{width:390,height:844,deviceScaleFactor:1,mobile:false});await open('NgForm');await check('document.documentElement.scrollWidth<=innerWidth','narrow overflow');await shot('narrow');
 console.log('PASS '+(flutter?'Flutter':'Blazor')+' text focus, readonly, editing, validation, failed save, retained draft, retry, pending reset, narrow');
}finally{ws.close();}

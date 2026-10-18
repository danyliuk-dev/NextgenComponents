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
const pause=()=>evaluate('new Promise(r=>setTimeout(r,2500))');
const select=async(label,text,index)=>{
 if(flutter){await clickControl(label+'\n'+(label==='Stepper position'?'Top':'Indicators and labels'));await clickControl(text);}
 else{const expr=`[...document.querySelectorAll('label')].find(e=>e.textContent.trim().startsWith(${JSON.stringify(label)})).querySelector('select')`;await evaluate(`(${expr}).scrollIntoView({block:'center'})`);await click(expr);await key('Home','Home',36);for(let i=0;i<index;i++)await key('ArrowDown','ArrowDown',40);await key('Enter','Enter',13);}
};
try{
 await command('Page.enable');await command('Runtime.enable');await command('Page.bringToFront');await command('Emulation.setDeviceMetricsOverride',{width:1440,height:1000,deviceScaleFactor:1,mobile:false});
 await command('Page.navigate',{url:flutter?'http://127.0.0.1:5181/':'http://127.0.0.1:5180/steps'});await pause();
 if(flutter){await evaluate("document.querySelector('flt-semantics-placeholder')?.click()");await wait();await clickControl('Steps and wizard');}
 await clickControl('Custom actions');await select('Stepper position','End side',3);await select('Step display','Indicators only',2);await clickControl('Right-to-left');await clickControl('Dark theme');
 await check(flutter?"document.body.innerText.includes('Step 1: Contact')":"document.querySelector('.ng-wizard [aria-label=\"Step 1: Contact\"]')!==null",'indicator-only accessible name');
 if(!flutter)await check("[...document.querySelectorAll('.ng-stepper[data-display-mode=indicators] li')].every(e=>e.getBoundingClientRect().width>=56)",'indicator buttons must not collapse');
 await shot('side-indicators');
 await command('Emulation.setDeviceMetricsOverride',{width:390,height:844,deviceScaleFactor:1,mobile:false});await wait();
 if(!flutter)await evaluate("document.querySelector('.ng-wizard-actions').scrollIntoView({block:'center'})");else{await command('Input.dispatchMouseEvent',{type:'mouseWheel',x:300,y:700,deltaX:0,deltaY:650});await wait();}
 await check('document.documentElement.scrollWidth<=innerWidth','narrow side overflow');await shot('side-narrow');console.log('PASS side placement, indicator-only accessible names, RTL/dark, narrow actions');
}finally{ws.close();}

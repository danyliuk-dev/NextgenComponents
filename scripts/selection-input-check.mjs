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
const shot=async(label)=>{await mkdir('artifacts/browser',{recursive:true});const r=await command('Page.captureScreenshot',{format:'png'});await writeFile(`artifacts/browser/selection030-${flutter?'flutter':'blazor'}-${label}.png`,Buffer.from(r.data,'base64'));};
const pause=async(ms=1000)=>evaluate(`new Promise(r=>setTimeout(r,${ms}))`);
const open=async(name)=>{await command('Page.navigate',{url:flutter?`http://127.0.0.1:5181/?preview=${name}`:`http://127.0.0.1:5180/preview/${name}`});await pause(2500);if(flutter){await evaluate("document.querySelector('flt-semantics-placeholder')?.click()");await wait();}};
const field="document.querySelector('input:not([type=checkbox]):not([type=hidden]),textarea')";
const fill=async(text)=>{await click(field);await command('Input.dispatchKeyEvent',{type:'keyDown',key:'a',code:'KeyA',windowsVirtualKeyCode:65,modifiers:2});await command('Input.dispatchKeyEvent',{type:'keyUp',key:'a',code:'KeyA',windowsVirtualKeyCode:65,modifiers:2});await command('Input.insertText',{text});await wait();};
try{
await command('Page.enable');await command('Runtime.enable');await command('Page.bringToFront');await command('Emulation.setDeviceMetricsOverride',{width:1000,height:800,deviceScaleFactor:1,mobile:false});
await open('NgAutoComplete');await fill('L');
await check(flutter?"!document.body.innerText.includes('London')":"document.querySelectorAll('datalist option').length===0",'minimum query');await fill('Lo');
await check(flutter?"document.body.innerText.includes('London')&&!document.body.innerText.includes('Lisbon')":"[...document.querySelectorAll('datalist option')].map(o=>o.value).join('|')==='London|Los Angeles'",'prefix suggestions');await shot('autocomplete');
await fill('Anywhere');await key('Tab','Tab',9);await clickControl('Read only');await click(field);await command('Input.insertText',{text:'NO'});await check(`(${field}).value==='Anywhere'`,'free text retained readonly');
await open('NgComboBox');await clickControl('Rename selected');await click(field);await check(`(${field}).value==='Alex Morgan'`,'selected label refresh');
await fill('Unknown');await key('Tab','Tab',9);await clickControl('Save selection');await check("document.body.innerText.includes('Choose an option from the list.')&&!document.body.innerText.includes('Saved ID:')",'invalid draft blocks save');
await clickControl('Clear Assignee');await fill('Be');await key('ArrowDown','ArrowDown',40);await shot('combo-options');await key('Enter','Enter',13);await key('Tab','Tab',9);await clickControl('Save selection');await check("document.body.innerText.includes('Saved ID: b')",'keyboard selects matching ID');
await clickControl('Read only');await click(field);await check(flutter?`(${field}).readOnly`:`(${field}).readOnly && (${control('Clear Assignee')}).disabled`,'readonly combo');await shot('combo');
await open('NgMultiSelect');await clickControl('Select filtered');await check("document.body.innerText.includes('Select at most 3 options.')&&document.body.innerText.includes('Selected IDs: locked')",'atomic limit');
await fill('Be');await clickControl('Select filtered');await check("document.body.innerText.includes('Selected IDs: locked, b')",'filtered selection');await shot('multi');
await clickControl('Clear selection');await check("document.body.innerText.includes('Selected IDs: locked')&&!document.body.innerText.includes('Selected IDs: locked, b')",'locked selection retained');
await clickControl('Read only');await fill('zz');await check("document.body.innerText.includes('No matching services')||[...document.querySelectorAll('[aria-label]')].some(e=>e.getAttribute('aria-label').includes('No matching services'))",'readonly filtering and empty text');
await command('Emulation.setDeviceMetricsOverride',{width:390,height:844,deviceScaleFactor:1,mobile:false});await open('NgMultiSelect');await check('document.documentElement.scrollWidth<=innerWidth','narrow overflow');await shot('narrow');
console.log('PASS '+(flutter?'Flutter':'Blazor')+' minimum/prefix filter, free text, readonly, label refresh, invalid draft, clear, keyboard selection, atomic bulk, locked clear, narrow');
}finally{ws.close();}

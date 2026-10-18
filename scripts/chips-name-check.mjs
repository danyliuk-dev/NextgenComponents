// Headed Chrome/CDP: node scripts/chips-name-check.mjs [blazor|flutter]. Starts a fresh gallery page.
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
const checkTree=async(name,selected)=>{
 const {nodes}=await command('Accessibility.getFullAXTree');
 const matches=nodes.filter(n=>!n.ignored&&n.role?.value===(flutter?'checkbox':'button')&&n.name?.value===name);
 if(matches.length!==1)throw Error('Expected one named chip: '+name);
 const state=matches[0].properties.find(p=>p.name===(flutter?'checked':'pressed'))?.value.value;
 if(state!==String(selected))throw Error('Selection mismatch: '+state);
 console.log('PASS '+JSON.stringify({platform:flutter?'Flutter':'Blazor',name,selected}));
};
try {
 await command('Page.enable');await command('Runtime.enable');await command('Page.bringToFront');
 await command('Network.enable');await command('Network.setCacheDisabled',{cacheDisabled:true});
 await command('Page.navigate',{url:flutter?'http://127.0.0.1:5181/':'http://127.0.0.1:5180/chips'});
 await evaluate('new Promise(r=>setTimeout(r,2300))');
 if(flutter){
  await evaluate("document.querySelector('flt-semantics-placeholder')?.click()");await wait();
  await click("[...document.querySelectorAll('[role=button]')].find(e=>e.textContent==='Chips and tags')");
  await command('Input.dispatchMouseEvent',{type:'mouseWheel',x:700,y:650,deltaX:0,deltaY:650});await wait();
 }else{await evaluate("document.querySelector('#chip-name-example').scrollIntoView({block:'center',behavior:'instant'})");}
 await checkTree('CI — Continuous integration',false);
 await click(flutter?"document.querySelector('[aria-label=\"CI — Continuous integration\"]')":"document.querySelector('#ci-chip button')");
 await checkTree('CI — Continuous integration',true);
 await click(flutter?"[...document.querySelectorAll('[role=button]')].find(e=>e.textContent==='Update chip name')":"[...document.querySelectorAll('#chip-name-example button')].find(e=>e.textContent==='Update chip name')");
 await checkTree('CI — Continuous integration, build completed',true);
 const visible=await evaluate(flutter?"[...document.querySelectorAll('flt-semantics')].some(e=>e.textContent==='CI selected: true')":"document.querySelector('#ci-chip button').textContent==='CI'");
 if(!visible)throw Error('Visible label/state changed unexpectedly');
 await mkdir('artifacts/browser',{recursive:true});
 const shot=await command('Page.captureScreenshot',{format:'png',captureBeyondViewport:false});
 await writeFile(`artifacts/browser/chips025-${flutter?'flutter':'blazor'}.png`,Buffer.from(shot.data,'base64'));
}finally{ws.close();}

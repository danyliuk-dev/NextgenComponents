// Visible Chrome/CDP: Flutter appearance, dark theme and narrow viewport review.
import {mkdir, writeFile} from 'node:fs/promises';
const tabs=await(await fetch('http://127.0.0.1:9341/json/list')).json();
const target=tabs.find(t=>t.type==='page');
const flutter=true;
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
const choose=async(label,value)=>{
 await click(`[...document.querySelectorAll('[role=button]')].find(e=>e.textContent.startsWith(${JSON.stringify(label+'\n')}))`);
 await click(`document.querySelector('[role=menuitem][aria-label="${value}"]')`);
};
const shot=async(name)=>{const r=await command('Page.captureScreenshot',{format:'png',captureBeyondViewport:false});await mkdir('artifacts/browser',{recursive:true});await writeFile('artifacts/browser/'+name,Buffer.from(r.data,'base64'));};
try{
 await command('Page.enable');await command('Runtime.enable');await command('Page.bringToFront');await command('Network.enable');await command('Network.setCacheDisabled',{cacheDisabled:true});
 await command('Page.navigate',{url:'http://127.0.0.1:5181/'});await evaluate('new Promise(r=>setTimeout(r,2300))');await evaluate("document.querySelector('flt-semantics-placeholder')?.click()");await wait();
 await click("[...document.querySelectorAll('[role=button]')].find(e=>e.textContent==='Toggle buttons')");
 await command('Input.dispatchMouseEvent',{type:'mouseWheel',x:700,y:650,deltaX:0,deltaY:700});await wait();
 await choose('Button size','lg');await choose('Button corners','full');await choose('Button fill','solid');await choose('Button color','tertiary');
 const summary=await evaluate("[...document.querySelectorAll('[role=button]')].filter(e=>e.textContent.startsWith('Button ')).map(e=>e.textContent)");
 if(!summary.includes('Button size\nlg')||!summary.includes('Button color\ntertiary'))throw Error('Settings did not update');
 await command('Input.dispatchMouseEvent',{type:'mouseWheel',x:700,y:400,deltaX:0,deltaY:-2000});await wait();
 await click("document.querySelector('[role=switch][aria-label=\"Dark theme\"]')");
 await command('Input.dispatchMouseEvent',{type:'mouseWheel',x:700,y:650,deltaX:0,deltaY:700});await wait();await shot('selection026-flutter-dark.png');
 await command('Emulation.setDeviceMetricsOverride',{width:390,height:844,deviceScaleFactor:1,mobile:false});
 // Flutter canvas needs a reload after changing the viewport.
 await command('Page.reload');await evaluate('new Promise(r=>setTimeout(r,2300))');await evaluate("document.querySelector('flt-semantics-placeholder')?.click()");await wait();
 await click("[...document.querySelectorAll('[role=button]')].find(e=>e.textContent==='Toggle buttons')");
 await command('Input.dispatchMouseEvent',{type:'mouseWheel',x:220,y:600,deltaX:0,deltaY:1200});await wait();await shot('selection026-flutter-narrow.png');
 console.log('PASS actual dropdown changes '+JSON.stringify(summary)+'; dark and narrow screenshots captured for inspection.');
}finally{await command('Emulation.clearDeviceMetricsOverride');ws.close();}

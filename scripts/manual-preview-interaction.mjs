// Verify embedded preview switching/reset, modal triggers and narrow manual layout.
import {writeFile,mkdir} from 'node:fs/promises';
const tabs=await(await fetch('http://127.0.0.1:9341/json/list')).json();
const ws=new WebSocket(tabs.find(t=>t.type==='page').webSocketDebuggerUrl);
await new Promise(r=>ws.onopen=r);let id=0;const pending=new Map();
ws.onmessage=e=>{const d=JSON.parse(e.data);if(d.id){const p=pending.get(d.id);pending.delete(d.id);d.error?p.reject(Error(JSON.stringify(d.error))):p.resolve(d.result);}};
const send=(method,params={})=>new Promise((resolve,reject)=>{const n=++id;pending.set(n,{resolve,reject});ws.send(JSON.stringify({id:n,method,params}));});
const pause=ms=>new Promise(r=>setTimeout(r,ms));
async function evaluate(expression,contextId){const r=await send('Runtime.evaluate',{expression,contextId,returnByValue:true,awaitPromise:true});if(r.exceptionDetails)throw Error(JSON.stringify(r.exceptionDetails));return r.result.value;}
async function frameContext(){const tree=await send('Page.getFrameTree');const f=tree.frameTree.childFrames?.find(f=>f.frame.url.includes('preview'));if(!f)throw Error('Preview iframe missing');return (await send('Page.createIsolatedWorld',{frameId:f.frame.id,worldName:'manual-check'})).executionContextId;}
async function pointer(x,y){await send('Input.dispatchMouseEvent',{type:'mousePressed',x,y,button:'left',clickCount:1});await send('Input.dispatchMouseEvent',{type:'mouseReleased',x,y,button:'left',clickCount:1});await pause(500);}
async function click(selector,child=false){const offset=child?await evaluate("(()=>{const r=document.querySelector('iframe').getBoundingClientRect();return {x:r.x,y:r.y}})()"): {x:0,y:0};const contextId=child?await frameContext():undefined;const r=await evaluate(`(()=>{const e=document.querySelector(${JSON.stringify(selector)});if(!e)throw Error('Missing click target');const r=e.getBoundingClientRect();return {x:r.x+r.width/2,y:r.y+r.height/2};})()`,contextId);await pointer(r.x+offset.x,r.y+offset.y);}
async function open(name){await send('Page.navigate',{url:`http://127.0.0.1:5182/docs/manual/${name}.md`});await pause(700);await evaluate("document.querySelector('#appearance-and-live-example').scrollIntoView()");await pause(1000);}
async function assert(expr,child=false){if(!await evaluate(expr,child?await frameContext():undefined))throw Error('Assertion failed: '+expr);}
async function screenshot(name){const r=await send('Page.captureScreenshot',{format:'png'});await writeFile(`artifacts/browser/${name}.png`,Buffer.from(r.data,'base64'));}
try{
 await mkdir('artifacts/browser',{recursive:true});await send('Page.enable');await send('Page.bringToFront');
 await send('Emulation.setDeviceMetricsOverride',{width:1440,height:1000,deviceScaleFactor:1,mobile:false});
 await open('NgButton');await click('button',true);await assert("document.body.innerText.includes('Clicked 1 times')",true);
 await click('.preview-toolbar button');await pause(900);await assert("document.body.innerText.includes('Clicked 0 times')",true);
 await click('.preview-toolbar select');await send('Input.dispatchKeyEvent',{type:'keyDown',key:'ArrowDown',code:'ArrowDown',windowsVirtualKeyCode:40});await send('Input.dispatchKeyEvent',{type:'keyDown',key:'Enter',code:'Enter',windowsVirtualKeyCode:13});await send('Input.dispatchKeyEvent',{type:'keyUp',key:'Enter',code:'Enter',windowsVirtualKeyCode:13});await pause(3500);
 await assert("document.querySelector('iframe').src.includes('5181/?preview=NgButton')");
 await evaluate("document.querySelector('flt-semantics-placeholder')?.click()",await frameContext());await pause(300);
 await click('[role=button]',true);await assert("document.body.innerText.includes('Clicked 1 times')",true);
 await screenshot('manual-live-flutter');
 await open('NgDialog');await click('button',true);await assert("!!document.querySelector('dialog[open]')",true);await screenshot('manual-live-dialog');
 await send('Input.dispatchKeyEvent',{type:'keyDown',key:'Escape',code:'Escape',windowsVirtualKeyCode:27});await send('Input.dispatchKeyEvent',{type:'keyUp',key:'Escape',code:'Escape',windowsVirtualKeyCode:27});
 await open('NgDrawer');await click('button',true);await assert("!!document.querySelector('dialog[open]')",true);await screenshot('manual-live-drawer');
 await open('NgButtonGroup');await screenshot('manual-live-blazor');
 await send('Emulation.setDeviceMetricsOverride',{width:390,height:844,deviceScaleFactor:1,mobile:false});await send('Page.reload');await pause(1100);await evaluate("document.querySelector('#appearance-and-live-example').scrollIntoView()");await pause(900);await assert("document.documentElement.scrollWidth <= innerWidth");await screenshot('manual-live-narrow');
 console.log('PASS embedded Blazor/Flutter interaction, framework switch, reload reset, dialog/drawer opening, narrow manual layout');
}finally{ws.close();}

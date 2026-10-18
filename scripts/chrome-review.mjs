// Local headed Chrome/CDP review helper. Chrome is started separately after queue coordination.
// Usage: node scripts/chrome-review.mjs actions.json
// clickSelector sends pointer events at a visible target (useful for Flutter headers).
import {readFile,writeFile,mkdir} from 'node:fs/promises';
const spec=JSON.parse(await readFile(process.argv[2],'utf8'));
const tabs=await (await fetch('http://127.0.0.1:9341/json/list')).json();
const target=tabs.find(t=>t.type==='page' && (!spec.urlContains || t.url.includes(spec.urlContains)));
if(!target)throw Error('Requested review tab not found');
const ws=new WebSocket(target.webSocketDebuggerUrl);let id=0;const pending=new Map();
await new Promise((resolve,reject)=>{ws.onopen=resolve;ws.onerror=reject;});
ws.onmessage=event=>{const data=JSON.parse(event.data);const callback=pending.get(data.id);if(callback){pending.delete(data.id);data.error?callback.reject(Error(JSON.stringify(data.error))):callback.resolve(data.result);}};
const command=(method,params={})=>new Promise((resolve,reject)=>{const n=++id;pending.set(n,{resolve,reject});ws.send(JSON.stringify({id:n,method,params}));});
try {
 await command('Page.enable');await command('Runtime.enable');await command('Page.bringToFront');
 for(const action of spec.actions){
  if(action.evaluate){const r=await command('Runtime.evaluate',{expression:action.evaluate,returnByValue:true,awaitPromise:true});if(r.exceptionDetails)throw Error(JSON.stringify(r.exceptionDetails));console.log(JSON.stringify(r.result.value));}
  else if(action.clickSelector){
   const r=await command('Runtime.evaluate',{expression:`(()=>{const e=document.querySelector(${JSON.stringify(action.clickSelector)});if(!e)throw Error('Click target missing');const r=e.getBoundingClientRect();return {x:r.x+r.width/2,y:r.y+r.height/2};})()`,returnByValue:true});
   if(r.exceptionDetails)throw Error(JSON.stringify(r.exceptionDetails));
   const {x,y}=r.result.value;
   await command('Input.dispatchMouseEvent',{type:'mousePressed',x,y,button:'left',clickCount:1});
   await command('Input.dispatchMouseEvent',{type:'mouseReleased',x,y,button:'left',clickCount:1});
   console.log('clicked '+action.clickSelector);
  }
  else if(action.screenshot){await mkdir('artifacts/browser',{recursive:true});const r=await command('Page.captureScreenshot',{format:'png',captureBeyondViewport:false});await writeFile('artifacts/browser/'+action.screenshot,Buffer.from(r.data,'base64'));console.log(action.screenshot);}
  else {console.log(JSON.stringify(await command(action.method,action.params)));}
 }
}finally{ws.close();}

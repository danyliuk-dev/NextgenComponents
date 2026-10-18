// Visible Chrome/CDP smoke check of every runnable manual example.
// Start a dedicated foreground Chrome on port 9341 after coordinating its use.
import {readFile,writeFile,mkdir} from 'node:fs/promises';
const framework=process.argv[2]||'blazor';
if(!['blazor','flutter'].includes(framework))throw Error('Use blazor or flutter');
const names=Object.keys(JSON.parse(await readFile('examples/BlazorGallery/wwwroot/component-examples.json','utf8')));
const targets=await(await fetch('http://127.0.0.1:9341/json/list')).json();
const ws=new WebSocket(targets.find(t=>t.type==='page').webSocketDebuggerUrl);
await new Promise(r=>ws.onopen=r);let id=0;const pending=new Map();let errors=[];
ws.onmessage=e=>{const d=JSON.parse(e.data);if(d.id){const p=pending.get(d.id);pending.delete(d.id);d.error?p.reject(Error(JSON.stringify(d.error))):p.resolve(d.result);}else if(d.method==='Runtime.exceptionThrown')errors.push(d.params.exceptionDetails.text+' '+(d.params.exceptionDetails.exception?.description||''));else if(d.method==='Runtime.consoleAPICalled'&&d.params.type==='error')errors.push(d.params.args.map(a=>a.value||a.description||'').join(' '));};
const send=(method,params={})=>new Promise((resolve,reject)=>{const n=++id;pending.set(n,{resolve,reject});ws.send(JSON.stringify({id:n,method,params}));});
const evaluate=async expression=>{const r=await send('Runtime.evaluate',{expression,returnByValue:true,awaitPromise:true});if(r.exceptionDetails)throw Error(JSON.stringify(r.exceptionDetails));return r.result.value;};
const pause=ms=>new Promise(r=>setTimeout(r,ms));
const folder=`artifacts/browser/manual-${framework}`;await mkdir(folder,{recursive:true});
try{
 await send('Page.enable');await send('Runtime.enable');await send('Page.bringToFront');
 await send('Emulation.setDeviceMetricsOverride',{width:1000,height:800,deviceScaleFactor:1,mobile:false});
 const results=[];
 for(const name of names){
  errors=[];
  await send('Page.navigate',{url:framework==='blazor'?`http://127.0.0.1:5180/preview/${name}`:`http://127.0.0.1:5181/?preview=${name}`});
  let ready=false;
  for(let i=0;i<60;i++){await pause(150);ready=await evaluate(framework==='blazor'?"!!document.querySelector('.manual-preview')":"!!document.querySelector('flt-glass-pane')");if(ready)break;}
  await pause(framework==='flutter'?1300:450);
  if(framework==='flutter'){await evaluate("document.querySelector('flt-semantics-placeholder')?.click()");await pause(150);}
  const text=await evaluate("document.body.innerText");
  const errorPanel=await evaluate("!!document.querySelector('.blazor-error-boundary') || document.body.innerText.includes('This example could not render')");
  const shot=await send('Page.captureScreenshot',{format:'png',captureBeyondViewport:false});await writeFile(`${folder}/${name}.png`,Buffer.from(shot.data,'base64'));
  const result={name,ready,errorPanel,errors:[...errors],text:text.slice(0,160)};results.push(result);console.log(JSON.stringify(result));
 }
 await writeFile(`${folder}/results.json`,JSON.stringify(results,null,2));
 if(results.some(r=>!r.ready||r.errorPanel||r.errors.length))process.exitCode=1;
}finally{ws.close();}

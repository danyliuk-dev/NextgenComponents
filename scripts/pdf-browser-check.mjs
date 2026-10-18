// Visible Chrome/CDP 9341 regression. Start the app and coordinate the Chrome slot first.
// Usage: node scripts/pdf-browser-check.mjs blazor|flutter
import {mkdir,writeFile,readFile,unlink} from 'node:fs/promises';
import {createHash} from 'node:crypto';
const flutter=process.argv[2]==='flutter',base=flutter?'http://127.0.0.1:5181':'http://127.0.0.1:5180';
const tabs=await(await fetch('http://127.0.0.1:9341/json/list')).json();
const tab=tabs.find(t=>t.type==='page'),ws=new WebSocket(tab.webSocketDebuggerUrl);
let serial=0;const pending=new Map();
await new Promise((r,j)=>{ws.onopen=r;ws.onerror=j;});
ws.onmessage=e=>{const d=JSON.parse(e.data),p=pending.get(d.id);if(p){pending.delete(d.id);d.error?p.reject(Error(JSON.stringify(d.error))):p.resolve(d.result);}};
const call=(method,params={})=>new Promise((resolve,reject)=>{const id=++serial;pending.set(id,{resolve,reject});ws.send(JSON.stringify({id,method,params}));});
const evaluate=async expression=>{const r=await call('Runtime.evaluate',{expression,returnByValue:true,awaitPromise:true});if(r.exceptionDetails)throw Error(JSON.stringify(r.exceptionDetails));return r.result.value;};
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
const wait=async expression=>{for(let i=0;i<80;i++){if(await evaluate(expression))return;await sleep(150);}throw Error('Timed out: '+expression);};
const assert=async(expression,label)=>{if(!await evaluate(expression))throw Error(label);console.log('PASS '+label);};
const d="document.querySelector('iframe').contentDocument";
const q=id=>d+".getElementById("+JSON.stringify(id)+")";
const click=async id=>{await evaluate(q(id)+'.click()');await sleep(180);};
const ready=()=>wait(q('status')+".textContent.startsWith('Page ')");
const screenshot=async name=>{const r=await call('Page.captureScreenshot',{format:'png',captureBeyondViewport:false});await writeFile('artifacts/browser/'+name,Buffer.from(r.data,'base64'));};
try{
 await mkdir('artifacts/browser',{recursive:true});await mkdir('/tmp/nextgen-pdf-downloads',{recursive:true});
 await call('Page.enable');await call('Runtime.enable');await call('Page.bringToFront');
 await call('Browser.setDownloadBehavior',{behavior:'allow',downloadPath:'/tmp/nextgen-pdf-downloads'});
 await call('Page.navigate',{url:base+(flutter?'':'/pdf')});await sleep(1800);
 if(flutter){
  await evaluate("document.querySelector('flt-semantics-placeholder')?.click()");await sleep(400);
  await evaluate("[...document.querySelectorAll('[role=button]')].find(e=>e.textContent==='PDF Viewer').click()");await sleep(600);
 }
 await wait("!!document.querySelector('iframe')?.contentDocument?.getElementById('status')");
 await ready();await assert(q('pages')+".textContent==='of 3'",'sample has three pages');
 await click('next');await ready();await assert(q('page')+".value==='2' && "+q('text')+".textContent.includes('Release checklist')",'next page renders real PDF text');
 await evaluate(q('page')+".value=999;"+q('page')+".dispatchEvent(new Event('change'))");
 await assert(q('page')+".value==='2'",'invalid page preserves current page');
 await click('previous');await ready();
 await evaluate(q('query')+".value='approval';"+q('search-form')+".requestSubmit()");
 await wait(q('search-status')+".textContent==='3 matching pages.'");
 await evaluate(q('results')+".querySelectorAll('button')[1].click()");await ready();
 await assert(q('page')+".value==='2' && "+q('text-panel')+".open",'search result navigates and exposes text');
 await click('clear');await assert(q('results')+".children.length===0",'clear search');
 await evaluate(q('text-panel')+".open=false");await click('width');await ready();
 const widthScale=await evaluate(q('zoom')+'.textContent');
 await click('fit');await ready();await assert(q('zoom')+'.textContent!=='+JSON.stringify(widthScale),'fit width differs from fit page');
 await click('in');await ready();await click('out');await ready();
 await unlink('/tmp/nextgen-pdf-downloads/nextgen-guide.pdf').catch(()=>{});
 await click('download');await sleep(700);
 const expected=await readFile('examples/BlazorGallery/wwwroot/samples/nextgen-guide.pdf');
 const downloaded=await readFile('/tmp/nextgen-pdf-downloads/nextgen-guide.pdf');
 if(createHash('sha256').update(expected).digest('hex')!==createHash('sha256').update(downloaded).digest('hex'))throw Error('Download bytes changed');
 console.log('PASS downloaded original bytes');
 // Exercise browser File API, malformed document recovery recovery.
 await evaluate("(async()=>{const d="+d+",dt=new DataTransfer();dt.items.add(new File(['bad pdf'],'broken.pdf'));d.getElementById('file').files=dt.files;d.getElementById('file').dispatchEvent(new Event('change'));})()");
 await wait(q('status')+".classList.contains('error')");
 await assert(q('download')+".disabled && "+q('canvas')+".hidden",'malformed PDF clears previous document');
 await evaluate("(async()=>{const d="+d+",data=await(await fetch('/samples/nextgen-guide.pdf')).arrayBuffer(),dt=new DataTransfer();dt.items.add(new File([data],'local-review.pdf',{type:'application/pdf'}));d.getElementById('file').files=dt.files;d.getElementById('file').dispatchEvent(new Event('change'));})()");
 await ready();await assert(q('name')+".textContent==='local-review.pdf'",'local file recovers after invalid PDF');
 await evaluate("document.querySelector('iframe').scrollIntoView({block:'center'})");await sleep(300);
 await screenshot('pdf-'+(flutter?'flutter':'blazor')+'.png');
 console.log('PASS '+(flutter?'Flutter Web':'Blazor')+' visible PDF review');
}finally{ws.close();}

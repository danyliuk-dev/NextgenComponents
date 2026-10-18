// Visible Chrome/CDP: node scripts/selection-block-check.mjs [blazor|flutter].
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
const node=async(name)=>{const {nodes}=await command('Accessibility.getFullAXTree');return nodes.filter(n=>!n.ignored&&n.name?.value===name&&['button','checkbox'].includes(n.role?.value));};
const expectState=async(name,selected)=>{const found=await node(name);if(found.length!==1)throw Error('Expected one '+name);const key=flutter?'checked':'pressed';const actual=found[0].properties?.find(p=>p.name===key)?.value.value;if(selected===null?actual!==undefined:actual!==String(selected))throw Error('Wrong selected state '+name+':'+actual);};
const action=(name)=>flutter?`[...document.querySelectorAll('[role=button],[role=checkbox]')].find(e=>e.getAttribute('aria-label')===${JSON.stringify(name)}||e.textContent===${JSON.stringify(name)})`:`[...document.querySelectorAll('#mixed-example button')].find(e=>e.getAttribute('aria-label')===${JSON.stringify(name)})`;
const check=(name)=>flutter?`document.querySelector('[role=checkbox][aria-label="${name}"]')`:`[...document.querySelectorAll('#mixed-example label')].find(e=>e.textContent.trim()===${JSON.stringify(name)}).querySelector('input')`;
const status=()=>evaluate(flutter?"[...document.querySelectorAll('flt-semantics')].map(e=>e.textContent).find(t=>t.startsWith('Selected: ')&&t.length<250)":"document.querySelector('#mixed-status').textContent");
try{
 await command('Page.enable');await command('Runtime.enable');await command('Page.bringToFront');await command('Network.enable');await command('Network.setCacheDisabled',{cacheDisabled:true});
 await command('Page.navigate',{url:flutter?'http://127.0.0.1:5181/':'http://127.0.0.1:5180/selection'});await evaluate('new Promise(r=>setTimeout(r,2300))');
 if(flutter){await evaluate("document.querySelector('flt-semantics-placeholder')?.click()");await wait();await click("[...document.querySelectorAll('[role=button]')].find(e=>e.textContent==='Toggle buttons')");await command('Input.dispatchMouseEvent',{type:'mouseWheel',x:700,y:650,deltaX:0,deltaY:750});await wait();}
 else await evaluate("document.querySelector('#mixed-example').scrollIntoView({block:'center',behavior:'instant'})");
 await expectState('Strong',true);await expectState('Clear formatting',null);
 await click(action('Emphasis'));await expectState('Emphasis',true);
 if(!(await status()).includes('changed:strong,emphasis | clicked:emphasis'))throw Error('Callback order');
 await click(check('Hide Emphasis'));if((await node('Emphasis')).length)throw Error('Hidden action remains');if(!(await status()).includes('Selected: strong,emphasis'))throw Error('Hidden selection lost');
 await click(check('Hide Emphasis'));await expectState('Emphasis',true);
 await click(action('Clear formatting'));await expectState('Strong',false);await expectState('Emphasis',false);if(!(await status()).includes('Selected: none'))throw Error('Command parent reset');
 await click(action('Strong'));await expectState('Strong',true);
 for(const type of ['keyDown','keyUp'])await command('Input.dispatchKeyEvent',{type,key:' ',code:'Space',windowsVirtualKeyCode:32});await wait();await expectState('Strong',false);
 await click(check('Disable formatting'));const disabled=await node('Strong');if(!disabled[0].properties.some(p=>p.name==='disabled'&&p.value.value===true))throw Error('Disabled state');
 await click(check('Disable formatting'));await click(check('Vertical formatting'));
 await mkdir('artifacts/browser',{recursive:true});const shot=await command('Page.captureScreenshot',{format:'png',captureBeyondViewport:false});await writeFile(`artifacts/browser/selection026-${flutter?'flutter':'blazor'}.png`,Buffer.from(shot.data,'base64'));
 console.log('PASS '+(flutter?'Flutter':'Blazor')+' mixed commands, selected states, event order, visibility, keyboard Space, disabled and vertical layout. '+await status());
}finally{ws.close();}

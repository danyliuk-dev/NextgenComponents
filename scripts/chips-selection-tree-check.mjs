// Run after chips-selection-blazor-checks.json in the visible review Chrome.
import {mkdir, writeFile} from 'node:fs/promises';
const tabs=await(await fetch('http://127.0.0.1:9341/json/list')).json();
const target=tabs.find(t=>t.type==='page' && /127\.0\.0\.1:5180/.test(t.url));
if(!target)throw Error('Open a gallery in the visible review Chrome first');
const ws=new WebSocket(target.webSocketDebuggerUrl);let id=0;const pending=new Map();
await new Promise((resolve,reject)=>{ws.onopen=resolve;ws.onerror=reject;});
ws.onmessage=e=>{const d=JSON.parse(e.data);const p=pending.get(d.id);if(p){pending.delete(d.id);d.error?p.reject(Error(JSON.stringify(d.error))):p.resolve(d.result);}};
const command=(method,params={})=>new Promise((resolve,reject)=>{pending.set(++id,{resolve,reject});ws.send(JSON.stringify({id,method,params}));});
try {
 await command('Page.bringToFront');
 const {nodes}=await command('Accessibility.getFullAXTree');
 const live=nodes.filter(n=>!n.ignored);
 const requireNode=(role,name)=>{const found=live.filter(n=>n.role?.value===role&&n.name?.value===name);if(found.length!==1)throw Error(`Expected one ${role} ${name}, got ${found.length}`);return found[0];};
 const box=requireNode('listbox','Categories');
 const option=requireNode('option','Documentation');
 const disabled=requireNode('option','Locked');
 const property=(node,key)=>node.properties?.find(p=>p.name===key)?.value.value;
 if(property(box,'orientation')!=='horizontal'||property(option,'selected')!==true||property(disabled,'disabled')!==true)throw Error('Listbox AX metadata mismatch');
 if(property(box,'multiselectable')===true)throw Error('Single-select mode should not be multiselectable');
 const proof={role:box.role.value,name:box.name.value,orientation:property(box,'orientation'),selectedOption:option.name.value,disabledOption:disabled.name.value};
 await mkdir('artifacts/browser',{recursive:true});
 await writeFile('artifacts/browser/chips024-accessibility.json',JSON.stringify(proof,null,2));
 console.log('PASS '+JSON.stringify(proof));
} finally {ws.close();}

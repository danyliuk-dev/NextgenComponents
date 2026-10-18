// Run after chips-accessibility-{blazor,flutter}-checks.json in the visible review Chrome.
import {mkdir, writeFile} from 'node:fs/promises';
const tabs=await(await fetch('http://127.0.0.1:9341/json/list')).json();
const target=tabs.find(t=>t.type==='page' && /127\.0\.0\.1:518[01]/.test(t.url));
if(!target)throw Error('Open a gallery in the visible review Chrome first');
const flutter=target.url.includes(':5181');
const ws=new WebSocket(target.webSocketDebuggerUrl);let id=0;const pending=new Map();
await new Promise((resolve,reject)=>{ws.onopen=resolve;ws.onerror=reject;});
ws.onmessage=e=>{const d=JSON.parse(e.data);const p=pending.get(d.id);if(p){pending.delete(d.id);d.error?p.reject(Error(JSON.stringify(d.error))):p.resolve(d.result);}};
const command=(method,params={})=>new Promise((resolve,reject)=>{pending.set(++id,{resolve,reject});ws.send(JSON.stringify({id,method,params}));});
try {
 await command('Page.bringToFront');
 const {nodes}=await command('Accessibility.getFullAXTree');
 const live=nodes.filter(n=>!n.ignored);
 const requireNode=(role,name)=>{const found=live.filter(n=>n.role?.value===role&&n.name?.value===name);if(found.length!==1)throw Error(`Expected one ${role} ${name}, got ${found.length}`);return found[0];};
 const group=requireNode('group','Assigned business records');
 if(group.description?.value!=='Choose assigned topics for this workspace.')throw Error('Group description did not update');
 const activity=requireNode('button','Open activity');
 if(activity.description?.value!=='Opens the activity summary.')throw Error('Command description missing');
 if(!flutter){const status=requireNode('group','Published');if(status.description?.value!=='This status is read-only.'||status.properties.some(p=>p.name==='focusable'&&p.value.value))throw Error('Static description or focus changed');}
 const selection=requireNode(flutter?'checkbox':'button','Operations');
 if(!selection.properties.some(p=>p.name===(flutter?'checked':'pressed')&&p.value.value==='true'))throw Error('Selection lost');
 requireNode('button','Remove Operations');
 const selector=flutter?'[flt-semantics-identifier="business-topics"]':'#business-topics';
 const result=await command('Runtime.evaluate',{expression:`document.querySelectorAll(${JSON.stringify(selector)}).length`,returnByValue:true});
 if(result.result.value!==1)throw Error('Stable identity missing or duplicated');
 const proof={platform:flutter?'Flutter Web':'Blazor Web',group:{name:group.name.value,description:group.description.value},command:{name:activity.name.value,description:activity.description.value},selectionRole:selection.role.value,selected:true,removeAction:'Remove Operations',identity:selector};
 await mkdir('artifacts/browser',{recursive:true});
 await writeFile(`artifacts/browser/chips022-${flutter?'flutter':'blazor'}-accessibility.json`,JSON.stringify(proof,null,2));
 console.log('PASS '+JSON.stringify(proof));
} finally {ws.close();}

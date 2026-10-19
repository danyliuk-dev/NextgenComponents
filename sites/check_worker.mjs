import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {DatabaseSync} from 'node:sqlite';
const source=readFileSync(new URL('./shared/worker.js',import.meta.url),'utf8').replace("import { EmailMessage } from 'cloudflare:email';","class EmailMessage { constructor(from,to,raw){Object.assign(this,{from,to,raw});} }");
const {default:worker}=await import('data:text/javascript;base64,'+Buffer.from(source).toString('base64'));
const sql=new DatabaseSync(':memory:');
const DB={
 exec:async s=>sql.exec(s),
 prepare:s=>({bind(...v){return {
  first:async()=>sql.prepare(s).get(...v)??null,
  all:async()=>({results:sql.prepare(s).all(...v)}),
  run:async()=>({meta:{changes:sql.prepare(s).run(...v).changes}})
 };}})
};
let emailFails=false;const sent=[];const tasks=[];const ctx={waitUntil:p=>tasks.push(p)};
const env={DB,PRODUCT:'Components',SITE_ORIGIN:'https://components.softwarenextgen.com',SENDER:'preorders@example.com',NOTIFY_EMAIL:'private@example.com',FORM_SECRET:'unit-test-secret',EMAIL:{send:async m=>{if(emailFails)throw Error('temporary provider failure');sent.push(m);}},ASSETS:{fetch:async()=>new Response('site')}};
let checks=0;const ok=(v,m)=>{assert.ok(v,m);console.log('PASS',m);checks++;};
async function token(){const r=await worker.fetch(new Request(env.SITE_ORIGIN+'/api/form-token'),env,ctx);return{token:(await r.json()).token,cookie:r.headers.get('set-cookie').split(';')[0]};}
async function post(session,extra={},ip='192.0.2.1'){const data={name:'Example Visitor',email:'visitor@example.com',company:'Sample Team',interest:'Components',message:'A fictional test enquiry',consent:'yes',website:'',token:session.token,...extra};return worker.fetch(new Request(env.SITE_ORIGIN+'/api/preorder',{method:'POST',headers:{Origin:env.SITE_ORIGIN,'Content-Type':'application/json',Cookie:session.cookie,'CF-Connecting-IP':ip},body:JSON.stringify(data)}),env,ctx);}
const t=await token();let r=await post(t);ok(r.status===201,'valid request saved');const response=await r.text();ok(!response.includes(env.NOTIFY_EMAIL),'private recipient absent from response');await Promise.all(tasks);ok(sent.length===1&&sent[0].to===env.NOTIFY_EMAIL,'notification goes only to configured recipient');
r=await post(t);ok(r.status===200&&sql.prepare('SELECT COUNT(*) n FROM requests').get().n===1,'retry token is idempotent');
r=await post({...t,cookie:'__Host-ng_form=wrong'});ok(r.status===403,'CSRF cookie mismatch rejected');
r=await post(await token(),{consent:''});ok(r.status===400,'explicit consent required');
r=await post(await token(),{email:'victim@example.com\r\nBcc:someone@example.com'});ok(r.status===400,'header injection rejected');
r=await post(await token(),{message:'x'.repeat(2001)});ok(r.status===400,'message bound enforced');
r=await post(await token(),{website:'spam.example'});ok(r.status===200&&sql.prepare('SELECT COUNT(*) n FROM requests').get().n===1,'honeypot does not create a request');
emailFails=true;r=await post(await token(),{},'192.0.2.2');ok(r.status===201,'email failure does not lose submission');await Promise.all(tasks);ok(sql.prepare('SELECT COUNT(*) n FROM requests WHERE notified=0').get().n===1,'failed email remains in private outbox');
emailFails=false;sql.exec('UPDATE requests SET lease_until=0');await worker.scheduled({},env,ctx);ok(sql.prepare('SELECT COUNT(*) n FROM requests WHERE notified=0').get().n===0,'scheduled retry delivers pending notification');
for(let i=0;i<4;i++)await post(await token());r=await post(await token());ok(r.status===429,'five submissions per IP per hour enforced');await Promise.all(tasks);
r=await worker.fetch(new Request(env.SITE_ORIGIN+'/api/preorder'),env,ctx);ok(r.status===405,'GET cannot create requests');
r=await worker.fetch(new Request('https://unrelated.example/'),env,ctx);ok(r.status===404,'unexpected hostname rejected');
r=await worker.fetch(new Request(env.SITE_ORIGIN+'/'),env,ctx);ok(r.headers.get('content-security-policy').includes("frame-ancestors 'none'"),'security headers applied');
console.log(`${checks} worker checks passed`);

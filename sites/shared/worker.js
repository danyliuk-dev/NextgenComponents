import { EmailMessage } from 'cloudflare:email';
const encoder=new TextEncoder();
const json=(data,status=200,headers={})=>new Response(JSON.stringify(data),{status,headers:{'Content-Type':'application/json; charset=utf-8','Cache-Control':'no-store',...headers}});
const hex=buffer=>[...new Uint8Array(buffer)].map(x=>x.toString(16).padStart(2,'0')).join('');
async function signature(value,secret){const key=await crypto.subtle.importKey('raw',encoder.encode(secret),{name:'HMAC',hash:'SHA-256'},false,['sign']);return hex(await crypto.subtle.sign('HMAC',key,encoder.encode(value)));}
function secure(response){const result=new Response(response.body,response);for(const [k,v] of Object.entries({'X-Content-Type-Options':'nosniff','Referrer-Policy':'strict-origin-when-cross-origin','X-Frame-Options':'DENY','Permissions-Policy':'camera=(), microphone=(), geolocation=()','Strict-Transport-Security':'max-age=31536000','Content-Security-Policy':"default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self'; base-uri 'none'; frame-ancestors 'none'; form-action 'self'"}))result.headers.set(k,v);return result;}
let initialized;
async function schema(env){return initialized??=env.DB.exec(`CREATE TABLE IF NOT EXISTS requests (id TEXT PRIMARY KEY, product TEXT NOT NULL, name TEXT NOT NULL, email TEXT NOT NULL, company TEXT NOT NULL, interest TEXT NOT NULL, message TEXT NOT NULL, created INTEGER NOT NULL, ip_hash TEXT NOT NULL, notified INTEGER NOT NULL DEFAULT 0, attempts INTEGER NOT NULL DEFAULT 0, lease_until INTEGER NOT NULL DEFAULT 0); CREATE INDEX IF NOT EXISTS requests_abuse ON requests(ip_hash,created); CREATE INDEX IF NOT EXISTS requests_outbox ON requests(product,notified,lease_until);`).catch(e=>{initialized=null;throw e;});}
function clean(value,max){return typeof value==='string'?value.trim().slice(0,max+1):'';}
async function notify(env,row){
 const now=Math.floor(Date.now()/1000);
 const claimed=await env.DB.prepare('UPDATE requests SET lease_until=?, attempts=attempts+1 WHERE id=? AND notified=0 AND lease_until<? RETURNING id').bind(now+120,row.id,now).first();
 if(!claimed)return;
 try{
  const content=`New ${row.product} preorder enquiry\n\nReference: ${row.id}\nName: ${row.name}\nEmail: ${row.email}\nCompany: ${row.company||'-'}\nInterest: ${row.interest}\n\n${row.message||'No message supplied.'}\n\nThis is a non-binding enquiry, not a paid order.\nConsent: contact about this request; privacy notice version 2026-10-19.\nReceived: ${new Date(row.created*1000).toISOString()}\n`;
  const payload=btoa(String.fromCharCode(...encoder.encode(content)));
  const raw=`From: Nextgen Enquiries <${env.SENDER}>\r\nTo: ${env.NOTIFY_EMAIL}\r\nReply-To: ${row.email}\r\nSubject: [Nextgen ${row.product}] Preorder enquiry\r\nMessage-ID: <${row.id}@${new URL(env.SITE_ORIGIN).hostname}>\r\nDate: ${new Date().toUTCString()}\r\nMIME-Version: 1.0\r\nContent-Type: text/plain; charset=UTF-8\r\nContent-Transfer-Encoding: base64\r\n\r\n${payload.match(/.{1,76}/g).join('\r\n')}`;
  await env.EMAIL.send(new EmailMessage(env.SENDER,env.NOTIFY_EMAIL,raw));
  await env.DB.prepare('UPDATE requests SET notified=1,lease_until=0 WHERE id=?').bind(row.id).run();
 }catch(_){await env.DB.prepare('UPDATE requests SET lease_until=? WHERE id=?').bind(now+900,row.id).run();}
}
async function handle(request,env,ctx){
 const url=new URL(request.url);
 if(url.protocol==='http:'){url.protocol='https:';return Response.redirect(url.href,308);}
 if(url.origin!==env.SITE_ORIGIN)return new Response('Not found',{status:404});
 if(url.pathname==='/api/form-token'){
  if(request.method!=='GET')return json({error:'Method not allowed'},405,{'Allow':'GET'});
  if(request.headers.get('Sec-Fetch-Site')==='cross-site')return json({error:'Open the form on this website.'},403);
  const value=`${Date.now()}.${crypto.randomUUID()}`;const token=value+'.'+await signature(value,env.FORM_SECRET);
  return json({token},200,{'Set-Cookie':`__Host-ng_form=${token}; Path=/; Max-Age=3600; Secure; HttpOnly; SameSite=Strict`});
 }
 if(url.pathname==='/api/preorder'){
  if(request.method!=='POST')return json({error:'Method not allowed'},405,{'Allow':'POST'});
  if(request.headers.get('Origin')!==env.SITE_ORIGIN)return json({error:'Submit the form from this website.'},403);
  if(!request.headers.get('Content-Type')?.startsWith('application/json'))return json({error:'Invalid request format.'},415);
  // Bound the stream even when Content-Length is absent or incorrect.
  if(Number(request.headers.get('Content-Length'))>12000)return json({error:'Request is too large.'},413);
  const reader=request.body?.getReader();if(!reader)return json({error:'Empty request.'},400);
  const chunks=[];let length=0;
  while(true){const part=await reader.read();if(part.done)break;length+=part.value.length;if(length>12000){await reader.cancel();return json({error:'Request is too large.'},413);}chunks.push(part.value);}
  const bytes=new Uint8Array(length);let offset=0;for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}
  let data;try{data=JSON.parse(new TextDecoder().decode(bytes));}catch{return json({error:'Invalid request.'},400);}
  if(!data||typeof data!=='object'||Array.isArray(data))return json({error:'Invalid request.'},400);
  const token=clean(data.token,200);const cookie=request.headers.get('Cookie')?.split(';').map(s=>s.trim()).find(s=>s.startsWith('__Host-ng_form='))?.slice(15);
  const [time,nonce,sig]=token.split('.');const age=Date.now()-Number(time);
  if(!cookie||cookie!==token||!nonce||age<0||age>3600000||sig!==await signature(`${time}.${nonce}`,env.FORM_SECRET))return json({error:'Your form session expired. Please submit again.'},403);
  if(clean(data.website,200))return json({ok:true});
  const row={id:nonce,product:env.PRODUCT,name:clean(data.name,100),email:clean(data.email,254),company:clean(data.company,160),interest:clean(data.interest,50),message:clean(data.message,2000),created:Math.floor(Date.now()/1000)};
  if(!row.name||row.name.length>100||!/^[-a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~]+@[a-zA-Z0-9](?:[a-zA-Z0-9.-]*[a-zA-Z0-9])?\.[a-zA-Z]{2,63}$/.test(row.email)||row.email.length>254||row.company.length>160||row.message.length>2000||![env.PRODUCT,'Both products'].includes(row.interest)||data.consent!=='yes'||/[\r\n]/.test(row.email))return json({error:'Please check your name, email, message length and consent.'},400);
  await schema(env);
  const ipHash=await signature(request.headers.get('CF-Connecting-IP')||'unknown',env.FORM_SECRET);
  // Atomic insert enforces the rate limit even for concurrent submissions.
  const result=await env.DB.prepare('INSERT OR IGNORE INTO requests(id,product,name,email,company,interest,message,created,ip_hash) SELECT ?,?,?,?,?,?,?,?,? WHERE (SELECT COUNT(*) FROM requests WHERE ip_hash=? AND created>?)<5').bind(row.id,row.product,row.name,row.email,row.company,row.interest,row.message,row.created,ipHash,ipHash,row.created-3600).run();
  if(!result.meta.changes){const existing=await env.DB.prepare('SELECT id FROM requests WHERE id=?').bind(row.id).first();if(existing)return json({ok:true,reference:row.id});return json({error:'Too many requests. Please try again in an hour.'},429,{'Retry-After':'3600'});}
  ctx.waitUntil(notify(env,row));
  return json({ok:true,reference:row.id},201,{'Set-Cookie':'__Host-ng_form=; Path=/; Max-Age=0; Secure; HttpOnly; SameSite=Strict'});
 }
 if(url.pathname.startsWith('/api/'))return json({error:'Not found'},404);
 if(!['GET','HEAD'].includes(request.method))return new Response('Method not allowed',{status:405});
 return env.ASSETS.fetch(request);
}
export default {
 async fetch(request,env,ctx){try{return secure(await handle(request,env,ctx));}catch{return secure(json({error:'The service is temporarily unavailable. Please try again.'},503));}},
 async scheduled(event,env,ctx){await schema(env);const now=Math.floor(Date.now()/1000);const {results}=await env.DB.prepare('SELECT * FROM requests WHERE product=? AND notified=0 AND attempts<20 AND lease_until<? ORDER BY created LIMIT 20').bind(env.PRODUCT,now).all();for(const row of results)await notify(env,row);await env.DB.prepare("UPDATE requests SET ip_hash='' WHERE created<? AND ip_hash<>''").bind(now-86400).run();await env.DB.prepare('DELETE FROM requests WHERE created<?').bind(now-365*86400).run();}
};

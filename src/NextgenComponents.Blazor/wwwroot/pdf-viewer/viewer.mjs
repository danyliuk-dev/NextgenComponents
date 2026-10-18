import { getDocument, GlobalWorkerOptions } from './vendor/pdf.min.mjs';
GlobalWorkerOptions.workerSrc = new URL('./vendor/pdf.worker.min.mjs', import.meta.url).href;
const $ = id => document.getElementById(id);
const params = new URLSearchParams(location.search);
document.documentElement.dataset.theme = params.get('theme') === 'dark' ? 'dark' : 'light';
const LIMIT = 20 * 1024 * 1024;
let doc, task, renderTask, bytes, filename='document.pdf', page=1, scale=1, mode='fit', generation=0, renderVersion=0, searchVersion=0, request;
const texts = new Map();
const status = (text, error=false) => { $('status').textContent=text; $('status').classList.toggle('error',error); };
function controls() {
  for (const id of ['page','out','in','width','fit','query','search','download']) $(id).disabled=!doc;
  $('previous').disabled=!doc||page<=1; $('next').disabled=!doc||page>=doc.numPages;
  $('page').value=page; $('page').max=doc?.numPages??1; $('pages').textContent='of '+(doc?.numPages??0);
}
async function textFor(pdf, number) {
  if (pdf===doc && texts.has(number)) return texts.get(number);
  const p=await pdf.getPage(number), content=await p.getTextContent();
  const text=content.items.map(item=>item.str+(item.hasEOL?'\n':' ')).join('');
  if(pdf===doc)texts.set(number,text);
  return text;
}
async function render() {
  if(!doc)return;
  const version=++renderVersion, current=doc, number=page;
  renderTask?.cancel(); controls(); status('Rendering page '+number+'…');
  try {
    const p=await current.getPage(number);
    if(version!==renderVersion||current!==doc)return;
    const base=p.getViewport({scale:1}), area=$('viewport');
    if(mode==='width') scale=(area.clientWidth-26)/base.width;
    if(mode==='fit') scale=Math.min((area.clientWidth-26)/base.width,(area.clientHeight-26)/base.height);
    scale=Math.max(.1,Math.min(3,scale));
    const viewport=p.getViewport({scale});
    // Bound raster memory independently of logical zoom and device pixel ratio.
    const ratio=Math.min(devicePixelRatio||1,2,8192/viewport.width,8192/viewport.height,Math.sqrt(16000000/(viewport.width*viewport.height)));
    const canvas=$('canvas');canvas.hidden=false;canvas.width=Math.max(1,Math.floor(viewport.width*ratio));canvas.height=Math.max(1,Math.floor(viewport.height*ratio));
    canvas.style.width=viewport.width+'px';canvas.style.height=viewport.height+'px';
    canvas.setAttribute('aria-label','PDF page '+number+' of '+current.numPages);
    $('zoom').textContent=Math.round(scale*100)+'%';$('text').textContent='';
    renderTask=p.render({canvasContext:canvas.getContext('2d'),viewport,transform:[ratio,0,0,ratio,0,0]});
    await renderTask.promise;
    const text=await textFor(current,number);
    if(version!==renderVersion||current!==doc)return;
    $('text').textContent=text||'No extractable text on this page. Scanned PDFs require OCR.';
    status('Page '+number+' of '+current.numPages+' · '+filename);
  }catch(e){if(version===renderVersion&&e.name!=='RenderingCancelledException')status('Unable to render this page.',true);}
}
async function reset() {
  const version=++generation; renderVersion++; searchVersion++; request?.abort();request=undefined;
  renderTask?.cancel(); const old=task; task=undefined;doc=undefined;bytes=undefined;texts.clear();page=1;
  $('canvas').hidden=true;$('canvas').width=1;$('canvas').height=1;$('text').textContent='';$('results').replaceChildren();$('search-status').textContent='';$('name').textContent='No document';controls();
  if(old)await old.destroy().catch(()=>{});
  return version;
}
async function load(data,name,version) {
  if(version!==generation)return;
  try {
    if(!data.length||data.length>LIMIT)throw Error('size');
    // Keep a private copy for download: PDF.js transfers its own buffer to the worker.
    bytes=data.slice(); filename=name.replace(/[\x00-\x1f/\\]/g,'_').slice(0,150)||'document.pdf';
    task=getDocument({data:data.slice(),cMapUrl:new URL('./vendor/cmaps/',import.meta.url).href,cMapPacked:true,standardFontDataUrl:new URL('./vendor/standard_fonts/',import.meta.url).href,wasmUrl:new URL('./vendor/wasm/',import.meta.url).href,isEvalSupported:false,enableXfa:false});
    const pdf=await task.promise;
    if(version!==generation)return;
    if(pdf.numPages>200){await reset();status('Use a PDF with at most 200 pages.',true);return;}
    doc=pdf;page=1;mode='fit';$('name').textContent=filename;controls();await render();
  }catch(e){
    if(version!==generation)return;
    await reset();
    status(e.name==='PasswordException'?'Password-protected PDFs are not supported.':e.message==='size'?'Choose a non-empty PDF up to 20 MiB.':'Unable to open PDF. The document may be damaged or unsupported.',true);
  }
}
async function openFile(file){
  if(!file)return; const version=await reset();if(version!==generation)return;status('Opening PDF…');
  if(file.size>LIMIT||!file.size){status('Choose a non-empty PDF up to 20 MiB.',true);return;}
  try{await load(new Uint8Array(await file.arrayBuffer()),file.name,version);}
  catch{if(version===generation)status('Unable to read this file.',true);}
}
async function openUrl(source){
  const version=await reset();if(version!==generation)return;request=new AbortController();status('Loading PDF…');
  try{
    const url=new URL(source);
    if(!['http:','https:'].includes(url.protocol))throw Error();
    const response=await fetch(url,{signal:request.signal,credentials:'same-origin'});
    if(!response.ok||Number(response.headers.get('content-length'))>LIMIT)throw Error();
    const reader=response.body.getReader(), chunks=[];let length=0;
    while(true){const {done,value}=await reader.read();if(done)break;length+=value.length;if(length>LIMIT){await reader.cancel();throw Error();}chunks.push(value);}
    const data=new Uint8Array(length);let offset=0;for(const chunk of chunks){data.set(chunk,offset);offset+=chunk.length;}
    await load(data,decodeURIComponent(url.pathname.split('/').pop()||'document.pdf'),version);
  }catch(e){if(version===generation&&e.name!=='AbortError')status('Unable to load PDF. Check the URL, access, CORS and 20 MiB limit.',true);}
}
$('file').onchange=e=>{openFile(e.target.files[0]);e.target.value='';};
$('previous').onclick=()=>{page--;render();};$('next').onclick=()=>{page++;render();};
$('page').onchange=()=>{const value=Number($('page').value);if(!Number.isInteger(value)||value<1||value>doc.numPages){$('page').value=page;status('Enter a page from 1 to '+doc.numPages+'.',true);return;}page=value;render();};
$('out').onclick=()=>{mode='manual';scale=Math.max(.1,scale-.25);render();};
$('in').onclick=()=>{mode='manual';scale=Math.min(3,scale+.25);render();};
$('width').onclick=()=>{mode='width';render();};$('fit').onclick=()=>{mode='fit';render();};
$('download').onclick=()=>{if(!bytes)return;const url=URL.createObjectURL(new Blob([bytes],{type:'application/pdf'})),a=document.createElement('a');a.href=url;a.download=filename;a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);};
$('clear').onclick=()=>{searchVersion++;$('query').value='';$('results').replaceChildren();$('search-status').textContent='';};
$('search-form').onsubmit=async e=>{
  e.preventDefault();const query=$('query').value.trim().toLocaleLowerCase();const current=doc,version=++searchVersion;
  $('results').replaceChildren();if(!query||!current){$('search-status').textContent='';return;}$('search-status').textContent='Searching…';let count=0;
  try{for(let number=1;number<=current.numPages;number++){
    const text=await textFor(current,number);if(version!==searchVersion||current!==doc)return;
    if(text.toLocaleLowerCase().includes(query)){count++;const button=document.createElement('button');button.type='button';button.textContent='Page '+number;button.onclick=()=>{page=number;render();$('text-panel').open=true;};$('results').append(button);}
  }if(version===searchVersion)$('search-status').textContent=count+' matching pages.';}
  catch{if(version===searchVersion)$('search-status').textContent='Unable to search this document.';}
};
let resizeTimer;new ResizeObserver(()=>{clearTimeout(resizeTimer);resizeTimer=setTimeout(()=>{if(doc&&mode!=='manual')render();},120);}).observe($('viewport'));
window.addEventListener('pagehide',()=>{request?.abort();task?.destroy();});
controls();$('canvas').hidden=true;
if(params.get('source'))openUrl(params.get('source'));

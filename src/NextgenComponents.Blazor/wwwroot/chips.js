const lists = new WeakMap();
export function bind(root) {
 if(lists.has(root))return;
 let current=null, position=0, entry=null;
 const sync=()=>{
  const all=entries();
  if(!all.includes(entry)||!target(entry))entry=all.find(x=>target(x)?.getAttribute('aria-pressed')==='true')??all.find(x=>target(x));
  for(const item of all)for(const button of item.querySelectorAll('button.ng-chip-label,button.ng-chip-remove'))button.tabIndex=item===entry&&button===target(item)?0:-1;
 };
 const entries=()=>[...root.querySelectorAll('[data-chip-id]')];
 const target=item=>item?.querySelector('button.ng-chip-label:not(:disabled)')??item?.querySelector('button.ng-chip-remove:not(:disabled)');
 const remember=e=>{const item=e.target.closest('[data-chip-id]');if(item&&root.contains(item)){current=item;entry=item;position=entries().indexOf(item);sync();}};
 const key=e=>{
  if(e.altKey||e.ctrlKey||e.metaKey||e.target.closest('input,textarea,select,[contenteditable=true]'))return;
  const item=e.target.closest('[data-chip-id]');if(!item)return;
  if(e.key==='Delete'||e.key==='Backspace'){
   e.preventDefault();e.stopPropagation();if(!e.repeat)item.querySelector('button.ng-chip-remove:not(:disabled)')?.click();return;
  }
  const all=entries().filter(x=>target(x));const index=all.indexOf(item);let next;
  const rtl=getComputedStyle(root).direction==='rtl';
  if(e.key==='ArrowRight')next=index+(rtl?-1:1);
  else if(e.key==='ArrowLeft')next=index+(rtl?1:-1);
  else if(e.key==='Home')next=0;
  else if(e.key==='End')next=all.length-1;
  else return;
  e.preventDefault();e.stopPropagation();if(all.length)target(all[Math.max(0,Math.min(all.length-1,next))])?.focus();
 };
 const observer=new MutationObserver(()=>{
  sync();
  if(!current)return;
  const active=document.activeElement;
  if(root.contains(current)&&target(current)){position=entries().indexOf(current);return;}
  // Never pull focus back from another control during a delayed parent update.
  if(active!==document.body&&active!==root&&!current.contains(active)){current=null;return;}
  const all=entries();const next=all.slice(position).find(x=>target(x))??all.slice(0,position).reverse().find(x=>target(x));
  current=null;(target(next)??root).focus();
 });
 sync();
 root.addEventListener('focusin',remember);root.addEventListener('keydown',key);
 observer.observe(root,{childList:true,subtree:true,attributes:true,attributeFilter:['disabled']});
 lists.set(root,{observer,remember,key});
}
export function dispose(root){const s=lists.get(root);if(!s)return;s.observer.disconnect();root.removeEventListener('focusin',s.remember);root.removeEventListener('keydown',s.key);lists.delete(root);}
export function focus(root){const el=root.querySelector('button.ng-chip-label:not(:disabled),button.ng-chip-remove:not(:disabled)');(el??root).focus();}

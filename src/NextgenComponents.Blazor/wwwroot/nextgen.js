export function dialog(element, open) {
 if (open && !element.open) element.showModal();
 if (!open && element.open) element.close();
}
export function tabs(element) {
 element.addEventListener('keydown', event => {
  if (event.target.getAttribute('role') !== 'tab') return;
  const tabs = [...element.querySelectorAll('[role="tab"]')].filter(t => !t.disabled);
  const index = tabs.indexOf(event.target);
  let next;
  if (event.key === 'ArrowRight') next = (index + 1) % tabs.length;
  if (event.key === 'ArrowLeft') next = (index - 1 + tabs.length) % tabs.length;
  if (event.key === 'Home') next = 0;
  if (event.key === 'End') next = tabs.length - 1;
  if (next !== undefined) { event.preventDefault(); tabs[next].focus(); tabs[next].click(); }
 });
}

export function calendar(root) {
 root.addEventListener('keydown', event => {
  if (!event.target.matches('[data-ng-day]')) return;
  const all = [...root.querySelectorAll('[data-ng-day]')];
  let index=all.indexOf(event.target), next=index;
  if(event.key==='ArrowRight')next++;
  else if(event.key==='ArrowLeft')next--;
  else if(event.key==='ArrowDown')next+=7;
  else if(event.key==='ArrowUp')next-=7;
  else if(event.key==='Home')next-=index%7;
  else if(event.key==='End')next+=6-index%7;
  else return;
  event.preventDefault();
  const direction=next>=index?1:-1;
  while(next>=0&&next<all.length&&all[next].disabled)next+=direction;
  if(next>=0&&next<all.length)all[next].focus();
 });
}

export function combo(root) {
 root.addEventListener('keydown', e => {
  if(e.target.getAttribute('role')==='combobox' && ['Enter','ArrowUp','ArrowDown'].includes(e.key) && e.target.getAttribute('aria-expanded')==='true') e.preventDefault();
 });
 root.addEventListener('focusout', () => setTimeout(() => {
  if(!root.contains(document.activeElement)) root.dispatchEvent(new KeyboardEvent('keydown',{key:'Escape',bubbles:true}));
 },0));
}

export function tree(root) {
 root.addEventListener('keydown', e => {
  const item=e.target.closest('[role=treeitem]');if(!item || e.target!==item)return;
  if(root.classList.contains('ng-virtual-tree')) { if(['ArrowDown','ArrowUp','Home','End','ArrowRight','ArrowLeft',' '].includes(e.key))e.preventDefault(); return; }
  const items=[...root.querySelectorAll('[role=treeitem]')].filter(x=>x.getAttribute('aria-disabled')!=='true');
  const index=items.indexOf(item);let next;
  if(e.key==='ArrowDown')next=items[index+1];
  if(e.key==='ArrowUp')next=items[index-1];
  if(e.key==='Home')next=items[0];
  if(e.key==='End')next=items.at(-1);
  if(e.key==='ArrowRight'&&item.getAttribute('aria-expanded')==='true')next=items.slice(index+1).find(x=>x.dataset.parent===item.dataset.treeId);
  if(e.key==='ArrowLeft'&&item.getAttribute('aria-expanded')!=='true')next=items.find(x=>x.dataset.treeId===item.dataset.parent);
  if(['ArrowDown','ArrowUp','Home','End','ArrowRight','ArrowLeft',' '].includes(e.key))e.preventDefault();
  next?.focus();
 });
}

// Native checkbox indeterminate is a DOM property, not an HTML attribute.
const observedTreeChecks=new WeakSet();
export function treeChecks(root) {
 const sync=()=>{
  for (const box of root.querySelectorAll('input.ng-tree-check')) {
   box.indeterminate=box.getAttribute('aria-checked')==='mixed';
   box.checked=box.getAttribute('aria-checked')==='true';
  }
 };
 sync();
 if(!observedTreeChecks.has(root)){
  observedTreeChecks.add(root);
  new MutationObserver(sync).observe(root,{childList:true,subtree:true,attributes:true,attributeFilter:['aria-checked']});
 }
}

// A keyboard request can target an item not yet rendered by Virtualize.
export function virtualTreeFocus(root, index, id, height) {
 const focused=document.activeElement;
 const apply=()=>{
  const item=[...root.querySelectorAll('[data-tree-id]')].find(x=>x.dataset.treeId===id);
  if(!item)return false;
  if(document.activeElement===focused || document.activeElement===root || document.activeElement===document.body) item.focus({preventScroll:true});
  return true;
 };
 const top=index*height;
 if(top<root.scrollTop || top+height>root.scrollTop+root.clientHeight)root.scrollTop=top;
 if(apply())return;
 const observer=new MutationObserver(()=>{if(apply())observer.disconnect();});
 observer.observe(root,{childList:true,subtree:true});
 setTimeout(()=>observer.disconnect(),1500);
}

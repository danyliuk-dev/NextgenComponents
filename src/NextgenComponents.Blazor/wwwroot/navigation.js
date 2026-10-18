const menus=new WeakMap(),drawers=new WeakMap();
const entries=level=>[...level.children].flatMap(e=>[...e.children].filter(b=>b.matches('button[role=menuitem]')&&!b.disabled));
const panel=b=>b?.getAttribute('aria-controls')?document.getElementById(b.getAttribute('aria-controls')):null;
export function menu(root,disabled){
 if(!menus.has(root)){
  const controller=new AbortController(),opt={signal:controller.signal};
  const popups=()=>[...root.querySelectorAll('[popover]')];
  const close=()=>popups().reverse().forEach(p=>{if(p.matches(':popover-open'))p.hidePopover();});
  const opener=p=>[...root.querySelectorAll('button[aria-controls]')].find(b=>b.getAttribute('aria-controls')===p.id);
  const focus=b=>{if(!b)return;const level=b.parentElement.parentElement;if(level.getAttribute('role')==='menubar')entries(level).forEach(x=>x.tabIndex=x===b?0:-1);b.focus();};
  const position=p=>{const b=opener(p);if(!b)return;const r=b.getBoundingClientRect(),sub=b.closest('[role=menu]');const w=p.offsetWidth,h=p.offsetHeight;let x=sub?r.right:r.left,y=sub?r.top:r.bottom;if(x+w>innerWidth-8)x=sub?r.left-w:innerWidth-w-8;if(y+h>innerHeight-8)y=Math.max(8,innerHeight-h-8);p.style.left=Math.max(8,x)+'px';p.style.top=Math.max(8,y)+'px';};
  root.addEventListener('toggle',e=>{const p=e.target;if(!p.matches('[popover]'))return;const b=opener(p);b?.setAttribute('aria-expanded',p.matches(':popover-open')?'true':'false');if(p.matches(':popover-open')){position(p);focus(entries(p)[0]);}}, {...opt,capture:true});
  root.addEventListener('click',e=>{const b=e.target.closest('[role=menuitem]');if(!b||b.disabled)return;focus(b);if(!panel(b)){const top=root.querySelector('[role=menubar]');const parent=b.closest('[popover]');close();if(parent){let p=parent,trigger=opener(p);while(trigger?.closest('[popover]')){p=trigger.closest('[popover]');trigger=opener(p);}focus(trigger||entries(top)[0]);}}},opt);
  root.addEventListener('keydown',e=>{
   const b=e.target.closest('button[role=menuitem]');if(!b||b.disabled)return;
   const level=b.parentElement.parentElement,top=level.getAttribute('role')==='menubar',vertical=!top||level.getAttribute('aria-orientation')==='vertical',list=entries(level),i=list.indexOf(b),p=panel(b);let next;
   if(e.key==='Tab'){close();return;}
   if(e.key==='Home')next=list[0];else if(e.key==='End')next=list.at(-1);
   else if(e.key===(vertical?'ArrowDown':'ArrowRight'))next=list[(i+1)%list.length];
   else if(e.key===(vertical?'ArrowUp':'ArrowLeft'))next=list[(i-1+list.length)%list.length];
   else if(p&&(e.key===(top&&!vertical?'ArrowDown':'ArrowRight'))){e.preventDefault();if(!p.matches(':popover-open'))p.showPopover();else focus(entries(p)[0]);return;}
   else if(!top&&(e.key==='Escape'||e.key==='ArrowLeft')){e.preventDefault();level.hidePopover();focus(opener(level));return;}
   if(next){e.preventDefault();focus(next);}
  },opt);
  window.addEventListener('resize',close,opt);
  document.addEventListener('scroll',e=>{if(!e.target.closest?.('.ng-menu-popup'))close();},{...opt,capture:true});
  menus.set(root,{controller,close});
 }
 if(disabled)menus.get(root).close();
 for(const b of root.querySelectorAll('button[aria-controls]'))b.setAttribute('aria-expanded',panel(b)?.matches(':popover-open')?'true':'false');
 for(const p of root.querySelectorAll('[popover]:popover-open')){const b=root.querySelector(`[aria-controls="${p.id}"]`);if(!b||b.disabled)p.hidePopover();}
}
export function disposeMenu(root){const m=menus.get(root);m?.close();m?.controller.abort();menus.delete(root);}
export function drawer(element,open,reference){
 if(!drawers.has(element)){
  const controller=new AbortController();element.addEventListener('click',e=>{if(e.target!==element)return;const r=element.getBoundingClientRect();if(e.clientX<r.left||e.clientX>r.right||e.clientY<r.top||e.clientY>r.bottom)reference.invokeMethodAsync('Dismiss');},{signal:controller.signal});drawers.set(element,controller);
 }
 if(open&&!element.open)element.showModal();else if(!open&&element.open)element.close();
}
export function disposeDrawer(element){if(element.open)element.close();drawers.get(element)?.abort();drawers.delete(element);}

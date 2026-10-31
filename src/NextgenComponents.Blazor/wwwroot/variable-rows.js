// Measured local/page rows. Unknown heights use the configured minimum estimate.
const views = new WeakMap();
export function create(top, bottom, receiver) {
 if(views.has(top))return views.get(top);
 const root=top.closest('.ng-table-scroll');
 let total=0,estimate=48,start=0,count=16,epoch=-1,heights=[],prefix=[0],frame=0,dead=false,pending=false,pinnedEnd=false,width=root.clientWidth;
 const rebuild=()=>{prefix=[0];for(let i=0;i<total;i++)prefix.push(prefix[i]+(heights[i]??estimate));};
 const indexAt=offset=>{let lo=0,hi=total;while(lo<hi){const mid=(lo+hi)>>1;if(prefix[mid+1]<=offset)lo=mid+1;else hi=mid;}return Math.min(lo,Math.max(0,total-1));};
 const origin=()=>top.parentElement.getBoundingClientRect().top-root.getBoundingClientRect().top+root.scrollTop;
 const schedule=()=>{if(!dead && !frame)frame=requestAnimationFrame(layout);};
 const resize=new ResizeObserver(schedule);
 resize.observe(root);
 function layout(){
  frame=0;if(dead || !top.isConnected)return;
  let offset=Math.max(0,root.scrollTop-origin());
  const anchor=indexAt(offset),before=prefix[anchor]??0;
  const atEnd=pinnedEnd || root.scrollTop>0 && root.scrollHeight-root.clientHeight-root.scrollTop<2;
  if(width!==root.clientWidth){width=root.clientWidth;heights=[];}
  let i=start;
  for(let row=top.nextElementSibling;row && row!==bottom;row=row.nextElementSibling){
   const h=row.getBoundingClientRect().height;
   if(h>0)heights[i]=Math.max(estimate,h);i++;
  }
  rebuild();
  top.style.height=`${prefix[start]??0}px`;
  bottom.style.height=`${Math.max(0,prefix[total]-(prefix[Math.min(total,start+count)]??0))}px`;
  if(atEnd)root.scrollTop=root.scrollHeight-root.clientHeight;
  else if(total)root.scrollTop+=prefix[anchor]-before;
  offset=Math.max(0,root.scrollTop-origin());
  const first=Math.max(0,indexAt(offset)-4);
  const last=Math.min(total,indexAt(offset+root.clientHeight)+5);
  const length=Math.max(1,last-first);
  if(!pending && (first!==start || length!==count)){
   pending=true;
   receiver.invokeMethodAsync('Window',first,length,epoch).catch(()=>{}).finally(()=>{pending=false;schedule();});
  }
 }
 const scroll=()=>{if(root.scrollTop>0 && root.scrollHeight-root.clientHeight-root.scrollTop<2)pinnedEnd=true;schedule();};
 const unpin=()=>{pinnedEnd=false;};
 root.addEventListener('scroll',scroll,{passive:true});
 for(const event of ['wheel','pointerdown','keydown'])root.addEventListener(event,unpin,{passive:true});
 const removed=new MutationObserver(()=>{if(!root.isConnected)api.dispose();});
 removed.observe(document.body,{childList:true,subtree:true});
 const api={
  update(n,height,first,length,version){
   if(dead)return;
   if(epoch!==version || estimate!==height){epoch=version;total=n;estimate=height;heights=[];pinnedEnd=false;rebuild();root.scrollTop=0;}
   total=n;start=first;count=length;
   resize.disconnect();resize.observe(root);
   for(let row=top.nextElementSibling;row && row!==bottom;row=row.nextElementSibling)resize.observe(row);
   schedule();
  },
  dispose(){if(dead)return;dead=true;views.delete(top);cancelAnimationFrame(frame);resize.disconnect();removed.disconnect();root.removeEventListener('scroll',scroll);for(const event of ['wheel','pointerdown','keydown'])root.removeEventListener(event,unpin);}
 };
 views.set(top,api);
 return api;
}

// Render only intersecting thumbnails, sequentially, independently of the main page.
export class Thumbnails {
  constructor(rail, toggle, navigate) {
    this.rail=rail; this.toggle=toggle; this.navigate=navigate;
    this.version=0; this.visible=new Set(); this.busy=false;
    toggle.onclick=()=>this.show(rail.hidden);
  }
  reset(pdf) {
    this.version++; this.observer?.disconnect(); this.job?.cancel();
    this.visible.clear(); this.rail.replaceChildren(); this.pdf=pdf;
    this.toggle.disabled=!pdf;
    if(!pdf){this.show(false);return;}
    for(let n=1;n<=pdf.numPages;n++) {
      const button=document.createElement('button');button.type='button';
      button.dataset.page=n;button.setAttribute('aria-label','Go to page '+n);
      const preview=document.createElement('span');preview.className='thumbnail-image';
      preview.setAttribute('aria-hidden','true');preview.textContent='Preview';
      const label=document.createElement('span');label.textContent='Page '+n;
      button.append(preview,label);
      const version=this.version;
      button.onclick=()=>{if(version===this.version)this.navigate(n);};
      this.rail.append(button);
    }
    this.select(1);this.show(false);
  }
  select(number) {
    this.current=number;
    for(const button of this.rail.children) {
      if(Number(button.dataset.page)===number)button.setAttribute('aria-current','page');
      else button.removeAttribute('aria-current');
    }
    if(!this.rail.hidden)this.reveal();
  }
  reveal() {
    const button=this.rail.querySelector('[aria-current]');
    if(!button)return;
    const r=button.getBoundingClientRect(),area=this.rail.getBoundingClientRect();
    if(r.top<area.top)this.rail.scrollTop+=r.top-area.top-6;
    else if(r.bottom>area.bottom)this.rail.scrollTop+=r.bottom-area.bottom+6;
  }
  show(open) {
    this.rail.hidden=!open;this.toggle.setAttribute('aria-expanded',String(open));
    this.version++;this.observer?.disconnect();this.job?.cancel();this.visible.clear();
    for(const button of this.rail.children)this.clear(button);
    if(!open||!this.pdf)return;
    // Button handlers guard document identity, not panel visibility.
    const pdf=this.pdf;
    for(const button of this.rail.children)button.onclick=()=>{if(pdf===this.pdf)this.navigate(Number(button.dataset.page));};
    this.reveal();
    const version=this.version;
    this.observer=new IntersectionObserver(entries=>{
      if(version!==this.version)return;
      for(const entry of entries) {
        if(entry.isIntersecting)this.visible.add(entry.target);
        else {this.visible.delete(entry.target);this.clear(entry.target);}
      }
      this.pump();
    },{root:this.rail});
    for(const button of this.rail.children)this.observer.observe(button);
  }
  clear(button) {
    const preview=button.firstElementChild;
    for(const canvas of preview.querySelectorAll('canvas')){canvas.width=1;canvas.height=1;}
    preview.textContent='Preview';delete button.dataset.rendered;
  }
  async pump() {
    if(this.busy)return;
    this.busy=true;
    try {
      while(!this.rail.hidden&&this.pdf) {
        const button=[...this.visible].find(b=>!b.dataset.rendered);
        if(!button)break;
        const version=this.version,pdf=this.pdf;
        button.dataset.rendered='pending';
        try {
          const page=await pdf.getPage(Number(button.dataset.page));
          if(version!==this.version||!this.visible.has(button))continue;
          const base=page.getViewport({scale:1});
          const viewport=page.getViewport({scale:Math.min(112/base.width,144/base.height)});
          const canvas=document.createElement('canvas');
          canvas.width=Math.max(1,Math.ceil(viewport.width*2));canvas.height=Math.max(1,Math.ceil(viewport.height*2));
          canvas.style.width=viewport.width+'px';canvas.style.height=viewport.height+'px';
          this.job=page.render({canvasContext:canvas.getContext('2d'),viewport,transform:[2,0,0,2,0,0]});
          await this.job.promise;
          if(version===this.version&&this.visible.has(button)){
            button.firstElementChild.replaceChildren(canvas);button.dataset.rendered='ready';
          }
        }catch(e){
          if(version===this.version&&this.visible.has(button)){
            button.firstElementChild.textContent='Preview unavailable';button.dataset.rendered='error';
          }
        }finally{this.job=undefined;}
      }
    }finally{this.busy=false;}
  }
}

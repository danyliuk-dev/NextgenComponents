// Pointer capture stays in the browser; only the completed move crosses Blazor interop.
const states = new WeakMap();
export function size(element) { return [element.clientWidth, element.clientHeight]; }
export function scroll(element, x, y) { element.scrollTo({left:x, top:y, behavior:"instant"}); }
export function width(element) { return element.clientWidth; }
export function cancel(svg) { states.get(svg)?.cancel(); }
export function attach(svg, reference) {
  detach(svg);
  let drag;
  const stop = () => {
    if (!drag) return;
    const previous = drag; drag = undefined;
    previous.ghost.remove();
    if (svg.hasPointerCapture(previous.pointer)) svg.releasePointerCapture(previous.pointer);
  };
  const down = e => {
    const node = e.target.closest('[data-node]');
    if (!node || e.button !== 0 || svg.dataset.readonly === 'true') return;
    stop();
    const box = svg.getBoundingClientRect();
    const ghost = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
    const x = +node.dataset.x, y = +node.dataset.y, w = +node.dataset.width, h = +node.dataset.height;
    ghost.setAttribute('class', 'ng-diagram-ghost');
    ghost.setAttribute('x', x); ghost.setAttribute('y', y);
    ghost.setAttribute('width', w); ghost.setAttribute('height', h);
    svg.append(ghost);
    drag = {id: node.dataset.node, pointer:e.pointerId, ghost, x, y, nextX:x, nextY:y, w, h, cx:e.clientX, cy:e.clientY, scale:box.width/svg.viewBox.baseVal.width, rectX:box.x, rectY:box.y};
    node.focus(); svg.setPointerCapture(e.pointerId); e.preventDefault();
  };
  const move = e => {
    if (!drag || drag.pointer !== e.pointerId) return;
    const box = svg.getBoundingClientRect();
    drag.nextX = Math.max(0, Math.min(svg.viewBox.baseVal.width-drag.w, drag.x+(e.clientX-drag.cx+drag.rectX-box.x)/drag.scale));
    drag.nextY = Math.max(0, Math.min(svg.viewBox.baseVal.height-drag.h, drag.y+(e.clientY-drag.cy+drag.rectY-box.y)/drag.scale));
    drag.ghost.setAttribute('x', drag.nextX); drag.ghost.setAttribute('y', drag.nextY);
  };
  const up = e => {if (!drag || drag.pointer!==e.pointerId) return;move(e);const d=drag;stop();reference.invokeMethodAsync('MoveNode',d.id,d.nextX,d.nextY).catch(()=>{});};
  const key = e => {
    if (e.key==='Escape') stop();
    if ((e.target.closest('[data-node]') && ['ArrowLeft','ArrowRight','ArrowUp','ArrowDown'].includes(e.key)) || (e.key === ' ' && e.target.closest('[data-node],.ng-diagram-edge'))) e.preventDefault();
  };
  const lost = () => stop();
  svg.addEventListener('pointerdown',down);svg.addEventListener('pointermove',move);svg.addEventListener('pointerup',up);svg.addEventListener('pointercancel',lost);svg.addEventListener('lostpointercapture',lost);svg.addEventListener('keydown',key);
  const observer=new MutationObserver(stop);observer.observe(svg,{attributes:true,attributeFilter:['data-readonly','width','height']});
  states.set(svg,{cancel:stop,detach:()=>{stop();observer.disconnect();svg.removeEventListener('pointerdown',down);svg.removeEventListener('pointermove',move);svg.removeEventListener('pointerup',up);svg.removeEventListener('pointercancel',lost);svg.removeEventListener('lostpointercapture',lost);svg.removeEventListener('keydown',key);}});
}
export function detach(svg) { states.get(svg)?.detach(); states.delete(svg); }

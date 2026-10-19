const states = new WeakMap();
export function detach(element) {
  const state = states.get(element);
  if (!state) return;
  state.stopped = true;
  cancelAnimationFrame(state.frame);
  state.resize.disconnect();
  state.removal.disconnect();
  element.removeEventListener('input', state.schedule);
  document.fonts?.removeEventListener('loadingdone', state.schedule);
  element.style.height = state.height;
  element.style.overflowY = state.overflow;
  states.delete(element);
}
export function update(element, enabled, rows, maxRows) {
  if (!enabled) { detach(element); return; }
  let state = states.get(element);
  if (!state) {
    state = {height:element.style.height, overflow:element.style.overflowY, stopped:false, frame:0, width:-1};
    state.measure = () => {
      if (state.stopped || !element.isConnected || element.getClientRects().length === 0) return;
      const style = getComputedStyle(element);
      const line = parseFloat(style.lineHeight);
      if (!Number.isFinite(line) || line <= 0) return;
      const padding = parseFloat(style.paddingTop) + parseFloat(style.paddingBottom);
      const border = parseFloat(style.borderTopWidth) + parseFloat(style.borderBottomWidth);
      const min = line * state.rows + padding + border;
      const max = line * state.maxRows + padding + border;
      const scroll = element.scrollTop;
      element.style.height = '0px';
      element.style.overflowY = 'hidden';
      const wanted = element.scrollHeight + border;
      element.style.height = Math.max(min, Math.min(max, wanted)) + 'px';
      element.style.overflowY = wanted > max + 1 ? 'auto' : 'hidden';
      element.scrollTop = scroll;
    };
    state.schedule = () => {
      cancelAnimationFrame(state.frame);
      state.frame = requestAnimationFrame(state.measure);
    };
    state.resize = new ResizeObserver(entries => {
      const width = entries[0]?.contentRect.width;
      if (width !== state.width) {state.width=width;state.schedule();}
    });
    state.removal = new MutationObserver(() => {if (!element.isConnected) detach(element);});
    state.resize.observe(element);
    state.removal.observe(document.documentElement, {childList:true,subtree:true});
    element.addEventListener('input', state.schedule);
    document.fonts?.addEventListener('loadingdone', state.schedule);
    states.set(element, state);
  }
  state.rows = rows;
  state.maxRows = maxRows;
  state.schedule();
}

const states=new WeakMap();
export function attach(frame,reference){const state={payload:null,listener:e=>{if(e.source!==frame.contentWindow||e.origin!==location.origin)return;if(e.data?.type==='ng-map-ready'&&state.payload)update(frame,state.payload);if(e.data?.type==='ng-map-event')reference.invokeMethodAsync('MapEvent',e.data.payload).catch(()=>{});}};states.set(frame,state);window.addEventListener('message',state.listener);}
export function update(frame,payload){const state=states.get(frame);if(!state)return;state.payload=payload;frame.contentWindow?.postMessage({type:'ng-map-config',payload},location.origin);}
export function detach(frame){const state=states.get(frame);if(state)window.removeEventListener('message',state.listener);states.delete(frame);}

const $ = id => document.getElementById(id);
const map = L.map('map', {minZoom:0,maxZoom:19,maxBounds:[[-85.05112878,-180],[85.05112878,180]],maxBoundsViscosity:1}).setView([0,0],2);
const group = L.layerGroup().addTo(map);
let config, tile, objects = new Map(), selected = null, dataKey = '', providerKey = '', incomingView = '', errors = 0;
const send = (kind, value) => parent.postMessage({type:'ng-map-event',payload:JSON.stringify({kind,...value})},location.origin);
const point = p => [p.latitude,p.longitude];
const node = (tag,text) => {const n=document.createElement(tag);n.textContent=text;return n;};
function selection(id, notify=true) {
 selected=objects.has(id)?id:null;
 for (const [key,o] of objects) {
  o.button.setAttribute('aria-pressed',String(key===selected));
  if(o.marker) o.layer.getElement()?.classList.toggle('selected',key===selected);
  else o.layer.setStyle({color:key===selected?'#1260a8':'#c3423b',weight:key===selected?5:3});
 }
 if(!selected)map.closePopup();
 if(notify)send('selection',{id:selected});
}
function add(item, marker) {
 const layer=marker?L.marker(point(item.position),{icon:L.divIcon({className:'ng-pin',iconSize:[24,24],iconAnchor:[12,12]}),title:item.text,alt:item.text,bubblingMouseEvents:false}):
  (item.closed?L.polygon:L.polyline)(item.points.map(point),{color:'#c3423b',weight:3,bubblingMouseEvents:false});
 layer.bindPopup(node('span',item.text)).addTo(group);
 layer.on('click',()=>selection(item.id));
 const button=node('button',item.text);button.dataset.id=item.id;
 button.onclick=()=>{selection(item.id);if(marker)map.panTo(layer.getLatLng());else map.fitBounds(layer.getBounds(),{padding:[24,24],maxZoom:14});layer.openPopup();};
 $('objects').append(button);objects.set(item.id,{layer,button,marker});
 if(!marker){const el=layer.getElement();el.setAttribute('tabindex','0');el.setAttribute('role','button');el.setAttribute('aria-label',item.text);el.addEventListener('keydown',e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();button.click();}});}
}
function configure(c) {
 config=c; document.body.classList.toggle('dark',c.dark);
 const key=JSON.stringify(c.model);
 if(key!==dataKey){dataKey=key;group.clearLayers();objects=new Map();$('objects').replaceChildren();c.model.markers.forEach(m=>add(m,true));c.model.paths.forEach(p=>add(p,false));if(!objects.size)$('objects').append(node('p','No objects'));}
 selection(c.selectedId,false);
 $('fit').disabled=!objects.size;$('count').textContent=`${c.model.markers.length} markers · ${c.model.paths.length} paths`;
 const provider=JSON.stringify([c.tileUrlTemplate,c.attribution,c.attributionUrl]);
 if(provider!==providerKey){providerKey=provider;if(tile)map.removeLayer(tile);tile=null;errors=0;
  $('status').textContent='No basemap configured';
  if(c.tileUrlTemplate){
   const attribution=node(c.attributionUrl?'a':'span',c.attribution);
   if(c.attributionUrl){attribution.href=c.attributionUrl;attribution.target='_blank';attribution.rel='noopener noreferrer';}
   const current=L.tileLayer(c.tileUrlTemplate,{attribution:attribution.outerHTML,maxZoom:19,noWrap:true});tile=current;
   current.on('loading',()=>{if(tile===current){errors=0;$('status').textContent='Loading tiles…';}});
   current.on('tileerror',()=>{if(tile===current){errors++;$('status').textContent='Some map tiles unavailable. Objects remain usable.';}});
   current.on('load',()=>{if(tile===current)$('status').textContent=errors?'Some map tiles unavailable. Objects remain usable.':'Tiles loaded';});current.addTo(map);
  }
 }
 const view=JSON.stringify(c.view);
 if(view!==incomingView){incomingView=view;const center=map.getCenter();if(Math.abs(center.lat-c.view.latitude)>1e-7||Math.abs(center.lng-c.view.longitude)>1e-7||map.getZoom()!==c.view.zoom)map.setView(point(c.view),c.view.zoom,{animate:false});}
 position();
}
function position(){const p=map.getCenter();$('position').textContent=`${p.lat.toFixed(4)}, ${p.lng.toFixed(4)} · zoom ${map.getZoom()}`;}
map.on('moveend',()=>{position();if(config){const p=map.getCenter();send('view',{latitude:Math.max(-85.05112878,Math.min(85.05112878,p.lat)),longitude:Math.max(-180,Math.min(180,p.lng)),zoom:map.getZoom()});}});
map.on('click',e=>send('click',{latitude:e.latlng.lat,longitude:((e.latlng.lng+180)%360+360)%360-180}));
$('clear').onclick=()=>selection(null);
$('fit').onclick=()=>{const points=[...config.model.markers.map(m=>point(m.position)),...config.model.paths.flatMap(p=>p.points.map(point))];if(points.length)map.fitBounds(points,{padding:[30,30],maxZoom:14});};
new ResizeObserver(()=>map.invalidateSize({pan:false})).observe($('map'));
window.addEventListener('message',e=>{if(e.source!==parent||e.origin!==location.origin||e.data?.type!=='ng-map-config')return;try{configure(JSON.parse(e.data.payload));}catch{ $('status').textContent='Invalid map configuration';}});
parent.postMessage({type:'ng-map-ready'},location.origin);

import {clusterPoints} from './clusters.mjs';
const $ = id => document.getElementById(id);
const map = L.map('map', {minZoom:0,maxZoom:19,maxBounds:[[-85.05112878,-180],[85.05112878,180]],maxBoundsViscosity:1}).setView([0,0],2);
const group = L.layerGroup().addTo(map);
const markers = L.layerGroup().addTo(map);
let markerKey = '';
let config, tile, objects = new Map(), selected = null, dataKey = '', providerKey = '', incomingView = '', errors = 0;
const send = (kind, value) => parent.postMessage({type:'ng-map-event',payload:JSON.stringify({kind,...value})},location.origin);
const point = p => [p.latitude,p.longitude];
const node = (tag,text) => {const n=document.createElement(tag);n.textContent=text;return n;};
function selection(id, notify=true) {
 const previous=selected;
 selected=objects.has(id)?id:null;
 renderMarkers();
 for (const [key,o] of objects) {
  o.button.setAttribute('aria-pressed',String(key===selected));
  if(o.marker) o.layer.getElement()?.classList.toggle('selected',key===selected);
  else o.layer.setStyle({color:key===selected?'#1260a8':'#c3423b',weight:key===selected?5:3});
 }
 if(!selected&&(notify||previous!==selected))map.closePopup();
 if(notify)send('selection',{id:selected});
}
function add(item, marker) {
 const layer=marker?L.marker(point(item.position),{icon:L.divIcon({className:'ng-pin',iconSize:[24,24],iconAnchor:[12,12]}),title:item.text,alt:item.text,bubblingMouseEvents:false}):
  (item.closed?L.polygon:L.polyline)(item.points.map(point),{color:'#c3423b',weight:3,bubblingMouseEvents:false});
 layer.bindPopup(node('span',item.text));
 if(!marker)layer.addTo(group);
 layer.on('click',()=>{selection(item.id);layer.openPopup();});
 const button=node('button',item.text);button.dataset.id=item.id;
 button.onclick=()=>{selection(item.id);if(marker)map.panTo(layer.getLatLng());else map.fitBounds(layer.getBounds(),{padding:[24,24],maxZoom:14});layer.openPopup();};
 $('objects').append(button);objects.set(item.id,{layer,button,marker});
 if(!marker){const el=layer.getElement();el.setAttribute('tabindex','0');el.setAttribute('role','button');el.setAttribute('aria-label',item.text);el.addEventListener('keydown',e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();button.click();}});}
}
function configure(c) {
 config=c; document.body.classList.toggle('dark',c.dark);
 const key=JSON.stringify(c.model);
 if(key!==dataKey){dataKey=key;group.clearLayers();objects=new Map();$('objects').replaceChildren();markerKey='';c.model.markers.forEach(m=>add(m,true));c.model.paths.forEach(p=>add(p,false));if(!objects.size)$('objects').append(node('p','No objects'));}
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
 renderMarkers();
 position();
}
function renderMarkers() {
 if(!config)return;
 const key=JSON.stringify([dataKey,config.clusterMarkers,config.clusterRadius,map.getZoom(),selected]);
 if(key===markerKey)return;
 markerKey=key;markers.clearLayers();
 // Marker coordinates live in position, unlike view coordinates.
 const projected=config.model.markers.filter(m=>m.id!==selected).map(m=>({...map.project(point(m.position),map.getZoom()),id:m.id}));
 const clusters=config.clusterMarkers?clusterPoints(projected,config.clusterRadius??60):projected.map(p=>({members:[p],x:p.x,y:p.y}));
 for(const cluster of clusters){
  if(cluster.members.length===1){objects.get(cluster.members[0].id).layer.addTo(markers);continue;}
  const count=cluster.members.length;
  const icon=L.divIcon({className:'ng-cluster',html:node('span',String(count)),iconSize:[40,40],iconAnchor:[20,20]});
  const label=`${count} markers. Zoom or choose a location`;
  const marker=L.marker(map.unproject([cluster.x,cluster.y],map.getZoom()),{icon,title:label,alt:label,bubblingMouseEvents:false}).addTo(markers);
  marker.getElement().setAttribute('aria-label',label);
  marker.getElement().addEventListener('keydown',e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();e.stopPropagation();marker.fire('click');}});
  marker.on('click',()=>{
   const locations=cluster.members.map(p=>objects.get(p.id).layer.getLatLng());
   const identical=locations.every(p=>p.equals(locations[0],1e-10));
   if(map.getZoom()<19&&!identical){const bounds=L.latLngBounds(locations);const zoom=Math.min(19,Math.max(map.getZoom()+1,map.getBoundsZoom(bounds,false,[60,60])));map.setView(bounds.getCenter(),zoom);return;}
   const list=node('div','');list.className='ng-cluster-list';list.append(node('strong',`${count} locations`));
   for(const p of cluster.members){const item=objects.get(p.id);const button=node('button',item.button.textContent);button.dataset.member=p.id;button.onclick=()=>item.button.click();list.append(button);}
   marker.bindPopup(list,{maxHeight:240}).openPopup();
  });
 }
 if(selected&&objects.get(selected)?.marker){const layer=objects.get(selected).layer;layer.addTo(markers);layer.getElement()?.classList.add('selected');}
}
map.on('zoomend',renderMarkers);
function position(){const p=map.getCenter();$('position').textContent=`${p.lat.toFixed(4)}, ${p.lng.toFixed(4)} · zoom ${map.getZoom()}`;}
map.on('moveend',()=>{position();if(config){const p=map.getCenter();send('view',{latitude:Math.max(-85.05112878,Math.min(85.05112878,p.lat)),longitude:Math.max(-180,Math.min(180,p.lng)),zoom:map.getZoom()});}});
map.on('click',e=>send('click',{latitude:e.latlng.lat,longitude:((e.latlng.lng+180)%360+360)%360-180}));
$('clear').onclick=()=>selection(null);
$('fit').onclick=()=>{const points=[...config.model.markers.map(m=>point(m.position)),...config.model.paths.flatMap(p=>p.points.map(point))];if(points.length)map.fitBounds(points,{padding:[30,30],maxZoom:14});};
new ResizeObserver(()=>map.invalidateSize({pan:false})).observe($('map'));
window.addEventListener('message',e=>{if(e.source!==parent||e.origin!==location.origin||e.data?.type!=='ng-map-config')return;try{configure(JSON.parse(e.data.payload));}catch{ $('status').textContent='Invalid map configuration';}});
parent.postMessage({type:'ng-map-ready'},location.origin);

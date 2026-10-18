// Deterministic screen-distance grouping. Coordinates are projected world pixels,
// so panning cannot change membership. Each group is bounded by its first point.
export function clusterPoints(points, radius) {
 if (!Number.isFinite(radius) || radius < 20 || radius > 120) throw new RangeError('Cluster radius must be 20–120 pixels.');
 const groups=[];
 for(const point of [...points].sort((a,b)=>a.id<b.id?-1:a.id>b.id?1:0)) {
  const group=groups.find(g=>Math.hypot(point.x-g.anchor.x,point.y-g.anchor.y)<=radius);
  if(group){group.members.push(point);group.x+=point.x;group.y+=point.y;}
  else groups.push({anchor:point,members:[point],x:point.x,y:point.y});
 }
 return groups.map(g=>({members:g.members,x:g.x/g.members.length,y:g.y/g.members.length}));
}

import {test} from 'node:test';
import assert from 'node:assert/strict';
import {clusterPoints} from '../../shared/map-viewer/clusters.mjs';

test('empty, singleton and exact radius boundary',()=>{
 assert.deepEqual(clusterPoints([],60),[]);
 const groups=clusterPoints([{id:'a',x:0,y:0},{id:'b',x:60,y:0},{id:'c',x:121,y:0}],60);
 assert.deepEqual(groups.map(g=>g.members.map(p=>p.id)),[['a','b'],['c']]);
 assert.equal(groups[0].x,30);
});
test('membership is stable across input order and pan, without chaining',()=>{
 const points=[{id:'c',x:100,y:0},{id:'b',x:50,y:0},{id:'a',x:0,y:0}];
 const ids=p=>clusterPoints(p,60).map(g=>g.members.map(m=>m.id));
 assert.deepEqual(ids(points),[['a','b'],['c']]);
 assert.deepEqual(ids(points),ids([...points].reverse()));
 assert.deepEqual(ids(points),ids(points.map(p=>({...p,x:p.x+555,y:p.y-42}))));
 assert.equal(points[0].id,'c');
});
test('zoom separates points; coincident points remain selectable as one group',()=>{
 const points=[{id:'a',x:0,y:0},{id:'b',x:30,y:0}];
 assert.equal(clusterPoints(points,60).length,1);
 assert.equal(clusterPoints(points.map(p=>({...p,x:p.x*4})),60).length,2);
 assert.equal(clusterPoints(Array.from({length:500},(_,i)=>({id:`m${i}`,x:0,y:0})),60)[0].members.length,500);
});
test('invalid radii fail explicitly',()=>{
 for(const r of [NaN,Infinity,19,121])assert.throws(()=>clusterPoints([],r),RangeError);
});

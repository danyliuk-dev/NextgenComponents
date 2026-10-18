import {test} from 'node:test';
import assert from 'node:assert/strict';
import {findTextMatches,indexTextItems,matchSegments} from '../../shared/pdf-viewer/text-search.mjs';
test('matches across adjacent PDF text runs without inventing spaces',()=>{
 const indexed=indexTextItems([{str:'App'},{str:'roval',hasEOL:true},{str:'next page'}]);
 assert.equal(indexed.text,'Approval\nnext page');
 assert.deepEqual(findTextMatches(indexed.text,'approval next'),[{start:0,end:13}]);
 assert.deepEqual(indexed.segments,[{start:0,end:3},{start:3,end:8},{start:9,end:18}]);
});
test('normalizes whitespace without losing original offsets',()=>{
 const text='A\n  B\tC';
 assert.deepEqual(findTextMatches(text,'a b c'),[{start:0,end:text.length}]);
});
test('case expansion and surrogate pairs preserve selection offsets',()=>{
 assert.deepEqual(findTextMatches('İ 😀 Approval','approval'),[{start:5,end:13}]);
 assert.deepEqual(findTextMatches('İ','i'),[{start:0,end:1}]);
 assert.deepEqual(findTextMatches('a😀b','😀'),[{start:1,end:3}]);
});
test('all nonoverlapping matches, bounded result count and literal metacharacters',()=>{
 assert.deepEqual(findTextMatches('a.a.a.','a.'),[{start:0,end:2},{start:2,end:4},{start:4,end:6}]);
 assert.equal(findTextMatches('a a a','a',2).length,2);
 assert.deepEqual(findTextMatches('aa',' '),[]);
 assert.deepEqual(findTextMatches('aa','z'),[]);
});
test('marked-content metadata and empty runs keep textDiv alignment',()=>{
 assert.deepEqual(indexTextItems([{type:'beginMarkedContent'},{str:''},{str:'A'}, {type:'endMarkedContent'}]),
 {text:'A',segments:[{start:0,end:0},{start:0,end:1}]});
});

test('range mapping splits cross-run matches and retains repeated matches inside a run',()=>{
 const segments=[{start:0,end:0},{start:0,end:3},{start:4,end:10},{start:10,end:10}];
 assert.deepEqual([...matchSegments(segments,[{start:1,end:6},{start:8,end:10}])],
 [{index:1,start:1,end:3},{index:2,start:0,end:2},{index:2,start:4,end:6}]);
});

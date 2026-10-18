// Keep offsets in original UTF-16 text while normalizing case and whitespace.
function normalize(text) {
  let value='', starts=[], ends=[];
  for(let offset=0;offset<text.length;){
    const char=String.fromCodePoint(text.codePointAt(offset)), end=offset+char.length;
    if(/\s/u.test(char)){
      if(value.endsWith(' '))ends[ends.length-1]=end;
      else {value+=' ';starts.push(offset);ends.push(end);}
    }else{
      const folded=char.toLowerCase();
      value+=folded;
      for(let i=0;i<folded.length;i++){starts.push(offset);ends.push(end);}
    }
    offset=end;
  }
  return {value,starts,ends};
}

export function findTextMatches(text, query, limit=1000) {
  const needle=normalize(query.trim()).value;
  if(!needle||limit<=0)return [];
  const haystack=normalize(text), result=[];
  let from=0;
  while(result.length<limit){
    const at=haystack.value.indexOf(needle,from);
    if(at<0)break;
    result.push({start:haystack.starts[at],end:haystack.ends[at+needle.length-1]});
    from=at+needle.length;
  }
  return result;
}

// PDF.js textDivs correspond to entries with a string, including empty entries.
export function indexTextItems(items) {
  let text='';const segments=[];
  for(const item of items){
    if(typeof item.str!=='string')continue;
    const start=text.length;text+=item.str;
    segments.push({start,end:text.length});
    if(item.hasEOL)text+='\n';
  }
  return {text,segments};
}

// Inputs are in document order. Walk each segment only as far as needed.
export function* matchSegments(segments,matches) {
  let first=0;
  for(const match of matches){
    while(first<segments.length&&segments[first].end<=match.start)first++;
    for(let i=first;i<segments.length&&segments[i].start<match.end;i++){
      const segment=segments[i],start=Math.max(match.start,segment.start),end=Math.min(match.end,segment.end);
      if(start<end)yield {index:i,start:start-segment.start,end:end-segment.start};
    }
  }
}

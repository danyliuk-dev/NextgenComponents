using NextgenComponents.Blazor;
public static class GroupedRangeChecks {
 public static int Run() {
  var checks=0;
  void Assert(bool yes,string message){if(!yes)throw new Exception(message);checks++;}
  void Reject(Action action){var failed=false;try{action();}catch(ArgumentException){failed=true;}Assert(failed,"Malformed grouped window accepted");}
  var source=Enumerable.Range(1,30).ToArray();
  Func<int,string>[] keys=[i=>i<=15?"North":"South",i=>i%2==0?"Even":"Odd"];
  var q=new NgGroupedRangeRequest(0,100,"",[],["region","kind"],[]);
  var all=NgGroupedRange.Window(source,keys,[],q);
  Assert(all.Total==36 && all.RecordTotal==30,"Slot and record totals");
  foreach(var collapse in new string[][]{[],[NgDataOperations.GroupId(["North"])],[NgDataOperations.GroupId(["North","Even"])],[NgDataOperations.GroupId(["North"]),NgDataOperations.GroupId(["South"])],["unknown"]}) {
   var full=NgGroupedRange.Window(source,keys,[],q with{CollapsedGroups=collapse});
   for(var start=0;start<=full.Total+1;start++)foreach(var take in new[]{1,2,5,32}){
    var request=q with{StartIndex=start,Count=take,CollapsedGroups=collapse};
    var answer=NgGroupedRange.Window(source,keys,[],request);
    var valid=NgGroupedRange.Validate(answer,request,i=>i.ToString());
    Assert(valid.Entries.Count==Math.Min(take,Math.Max(0,full.Total-start)),"Boundary window");
   }
  }
  Reject(()=>NgGroupedRange.Validate(all with{StartIndex=1},q,i=>i.ToString()));
  Reject(()=>NgGroupedRange.Validate(all with{Entries=all.Entries.Skip(1).ToArray()},q,i=>i.ToString()));
  Reject(()=>NgGroupedRange.Validate(all with{Total=100001},q,i=>i.ToString()));
  Reject(()=>NgGroupedRange.Validate(all with{Groups=all.Groups.Skip(1).ToArray()},q,i=>i.ToString()));
  Reject(()=>NgGroupedRange.Validate(all with{Groups=[..all.Groups,all.Groups[0]]},q,i=>i.ToString()));
  Reject(()=>NgGroupedRange.Validate(all,q with{CollapsedGroups=[NgDataOperations.GroupId(["North"])]},i=>i.ToString()));
  Reject(()=>NgGroupedRange.Validate(all,q,_=>"duplicate"));
  Reject(()=>NgGroupedRange.Validate(all with{Groups=all.Groups.Select(g=>g with{Count=1}).ToArray()},q,i=>i.ToString()));
  Reject(()=>NgGroupedRange.ValidateRequest(q with{GroupKeys=[]}));
  Reject(()=>NgGroupedRange.ValidateRequest(q with{Count=513}));
  Reject(()=>NgGroupedRange.ValidateRequest(q with{CollapsedGroups=["same","same"]}));
  var onlyHeaders=NgGroupedRange.Window(source,keys,[],q with{CollapsedGroups=[NgDataOperations.GroupId(["North"]),NgDataOperations.GroupId(["South"])]});
  Assert(onlyHeaders.Entries.Count==2 && onlyHeaders.Entries.All(e=>e.IsGroup),"Collapse hides server records");
  Console.WriteLine($"PASS grouped ranges: {checks} contract checks");return checks;
 }
}

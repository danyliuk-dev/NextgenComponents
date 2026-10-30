using NextgenComponents.Blazor;
using System.Reflection;
#pragma warning disable BL0005
internal static class GridBatchChecks {
 public static async Task<int> Run(){
  int checks=0,calls=0;bool locked=false,invalid=false;var rows=new List<string>{"Alpha","Beta"};
  var pending=new TaskCompletionSource<string?>();IReadOnlyList<NgGridChange>? captured=null;CancellationToken token=default;
  NgGridEditing<string> Config(int limit=2)=>new(){CellEditing=true,MaxPendingChanges=limit,Fields=[new("name","Name",true),new("other","Other",true)],Draft=r=>new Dictionary<string,string>{{"name",r??""},{"other","original"}},CanUpdate=_=>!locked,CanDelete=_=>!locked,Validate=_=>invalid?"Invalid":null,Commit=(_,_,_,_)=>throw new Exception("Single commit in batch mode"),CommitBatch=(changes,t)=>{calls++;captured=changes;token=t;return pending.Task;}};
  var grid=new NgDataGrid<string>{Items=rows,RowId=r=>r,Columns=[new("name","Name",r=>r),new("other","Other",r=>r)],Editing=Config()};
  var flags=BindingFlags.Instance|BindingFlags.NonPublic|BindingFlags.Public;
  object? Call(string name,params object?[] args)=>grid.GetType().GetMethod(name,flags)!.Invoke(grid,args);
  object? Get(string name)=>grid.GetType().GetField(name,flags)!.GetValue(grid);
  void Assert(bool ok,string msg){if(!ok)throw new Exception("Batch: "+msg);checks++;}
  int Count()=>((System.Collections.ICollection)Get("batchChanges")!).Count;
  void Set(string key,string val)=>((Dictionary<string,string>)Get("draft")!)[key]=val;
  Task Stage()=> (Task)Call("CommitEdit")!;
  Task Save()=> (Task)Call("SaveBatch")!;
  Call("OnInitialized");Call("Refresh");
  Call("BeginEdit",NgGridEditOperation.Create,null);await Stage();Assert(Count()==0 && Get("editError") is not null,"required validation before queue");Call("CloseEdit");
  Call("BeginCell","Alpha","name");Set("name","Changed");await Stage();Assert(Count()==1 && calls==0 && rows[0]=="Alpha","staging leaves source unchanged");
  Call("BeginCell","Alpha","other");Assert(((Dictionary<string,string>)Get("draft")!)["name"]=="Changed","second cell retains first draft");Set("other","Second");await Stage();Assert(Count()==1,"same row consolidated");
  Call("BeginEdit",NgGridEditOperation.Delete,"Alpha");Call("CloseEdit");Assert(Count()==1,"delete cancel retains update");
  Call("BeginEdit",NgGridEditOperation.Create,null);Set("name","New");await Stage();Assert(Count()==2,"create queued");
  Call("BeginEdit",NgGridEditOperation.Create,null);Set("name","Overflow");await Stage();Assert(Count()==2 && (string?)Get("editError")==grid.Editing.BatchLimitText,"queue bounded");Call("CloseEdit");
  locked=true;await Save();Assert(calls==0 && (string?)Get("editError")==grid.Editing.BatchConflictText,"permissions rechecked");locked=false;
  invalid=true;await Save();Assert(calls==0 && (string?)Get("editError")=="Invalid","validator rechecked");invalid=false;
  rows.Remove("Alpha");await Save();Assert(calls==0,"missing local row rejected");rows.Insert(0,"Alpha");
  var save=Save();await Save();Call("DiscardBatch");Call("BeginEdit",NgGridEditOperation.Create,null);Assert(calls==1 && Count()==2 && Get("editOperation") is null,"single flight locks all mutation");
  Assert(captured![0].Values["name"]=="Changed" && captured[0].Values["other"]=="Second" && captured[1].Id is null,"complete snapshots");
  bool immutable=false;try{((IDictionary<string,string>)captured[0].Values)["name"]="bad";}catch(NotSupportedException){immutable=true;}Assert(immutable,"immutable values");
  immutable=false;try{((IList<NgGridChange>)captured).Clear();}catch(NotSupportedException){immutable=true;}Assert(immutable,"immutable list");
  pending.SetResult("Conflict");await save;Assert(Count()==2 && (string?)Get("editError")=="Conflict","failed save retains batch");
  var newKey=captured[1].Key;Call("BeginQueued",newKey);Set("name","Revised");await Stage();Assert(Count()==2,"edit staged create retains key");
  Call("UndoChange",captured[0].Key);Assert(Count()==1,"individual undo");
  pending=new();save=Save();Assert(captured!.Single().Key==newKey && captured[0].Values["name"]=="Revised","retry revised create");pending.SetResult(null);await save;Assert(Count()==0,"success clears once");
  Call("BeginEdit",NgGridEditOperation.Update,"Alpha");await Stage();Call("BeginEdit",NgGridEditOperation.Delete,"Alpha");await Stage();
  pending=new();save=Save();Assert(captured!.Single().Operation==NgGridEditOperation.Delete && captured[0].Values.Count==0,"delete replaces update");pending.SetException(new Exception("PRIVATE"));await save;Assert((string?)Get("editError")==grid.Editing.ErrorText && Count()==1,"safe exception retains batch");
  pending=new();save=Save();Call("InvalidateEdit");Assert(token.IsCancellationRequested && Count()==0,"invalidation cancels and clears");pending.SetResult("Stale");await save;Assert(Get("editError") is null,"obsolete completion ignored");
  Call("BeginEdit",NgGridEditOperation.Create,null);Set("name","Discard");await Stage();Call("DiscardBatch");Assert(Count()==0,"discard all");grid.Dispose();
  foreach(var limit in new[]{0,501}){bool rejected=false;try{Config(limit).Check();}catch(ArgumentOutOfRangeException){rejected=true;}Assert(rejected,"invalid bound rejected");}
  // Off-page queued edits remain reviewable; the adapter still owns authorization.
  rows.Clear();rows.Add("Alpha");grid=new NgDataGrid<string>{Items=[],RowId=r=>r,Columns=[new("name","Name",r=>r)],Editing=Config(),ReadData=(_,_)=>Task.FromResult(new NgDataResult<string>(rows.ToArray(),rows.Count))};
  Call("OnInitialized");grid.GetType().GetField("filtered",flags)!.SetValue(grid,rows.ToArray());
  Call("BeginEdit",NgGridEditOperation.Update,"Alpha");Set("name","Offpage");await Stage();
  rows.Clear();rows.Add("Beta");grid.GetType().GetField("filtered",flags)!.SetValue(grid,rows.ToArray());
  pending=new();save=Save();Assert(captured!.Single().Id=="Alpha","off-page queued change submits");pending.SetResult("Conflict");await save;
  Call("BeginQueued",captured[0].Key);Assert((bool)grid.GetType().GetProperty("CanCommit",flags)!.GetValue(grid)!,"off-page draft remains editable");Set("name","Offpage revised");await Stage();
  pending=new();save=Save();Assert(captured[0].Values["name"]=="Offpage revised","off-page revision retained");pending.SetResult("Reviewed");await save;grid.Dispose();
  return checks;
 }
}

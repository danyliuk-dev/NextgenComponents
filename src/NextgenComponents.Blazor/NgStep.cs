namespace NextgenComponents.Blazor;

public sealed record NgStep(string Label, bool Disabled=false, bool Optional=false, bool? Valid=null);

public static class NgStepRules {
 public static void Validate(IReadOnlyList<NgStep> items,int value){
  if(items is null||items.Count is <1 or >30||items.Any(s=>s is null||string.IsNullOrWhiteSpace(s.Label)||s.Label.Length>120))throw new ArgumentException("Use 1–30 steps with labels of 1–120 characters.");
  if(value<0||value>=items.Count||items[value].Disabled)throw new ArgumentException("Value must identify an enabled step.");
 }
 public static void ValidatePresentation(string label,string displayMode="all",string position="top"){
  if(string.IsNullOrWhiteSpace(label)||label.Length>120)throw new ArgumentException("Use a nonempty label of at most 120 characters.");
  if(displayMode is not ("all" or "labels" or "indicators"))throw new ArgumentException("DisplayMode must be all, labels or indicators.");
  if(position is not ("top" or "bottom" or "start" or "end"))throw new ArgumentException("Position must be top, bottom, start or end.");
 }
 public static int Adjacent(IReadOnlyList<NgStep> items,int value,int direction){if(direction is not (-1 or 1))throw new ArgumentOutOfRangeException(nameof(direction));for(var i=value+direction;i>=0&&i<items.Count;i+=direction)if(!items[i].Disabled)return i;return -1;}
 public static bool CanMove(IReadOnlyList<NgStep> items,int value,int target,bool linear)=>target>=0&&target<items.Count&&!items[target].Disabled&&target!=value&&(!linear||target<value||target==Adjacent(items,value,1));
}

public sealed record NgStepContext(NgStep Step,int Index,bool Current);
public sealed record NgWizardChange(int Current,int Target,bool IsFinish);
public sealed record NgWizardActions(int Value,bool Busy,bool Finished,bool IsLast,bool CanBack,bool CanNext,bool CanFinish,
 Func<Task> BackAsync,Func<Task> NextAsync,Func<Task> FinishAsync);

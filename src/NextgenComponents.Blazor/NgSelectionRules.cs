namespace NextgenComponents.Blazor;

public static class NgSelectionRules {
 public static void Validate(IReadOnlyList<NgOption> items,IReadOnlyList<string> value,bool multiple){
  NgNavigationRules.ValidateDrawer(items,260);
  ArgumentNullException.ThrowIfNull(value);
  if(items.Count>50||(!multiple&&value.Count>1)||value.Distinct().Count()!=value.Count||value.Any(id=>!items.Any(x=>x.Value==id)))throw new ArgumentException("Use at most 50 options and unique known selected IDs; single selection accepts at most one ID.");
 }
 public static IReadOnlyList<string> Toggle(IReadOnlyList<NgOption> items,IReadOnlyList<string> value,string id,bool multiple,bool allowEmpty){
  Validate(items,value,multiple);
  if(!items.Any(x=>x.Value==id&&!x.Disabled))return value.ToArray();
  var selected=value.ToHashSet();
  if(selected.Contains(id)){if(!allowEmpty&&selected.Count==1)return value.ToArray();selected.Remove(id);}
  else {if(!multiple)selected.Clear();selected.Add(id);}
  return Array.AsReadOnly(items.Where(x=>selected.Contains(x.Value)).Select(x=>x.Value).ToArray());
 }
}

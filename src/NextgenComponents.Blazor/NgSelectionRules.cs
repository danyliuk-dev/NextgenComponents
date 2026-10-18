namespace NextgenComponents.Blazor;

public static class NgSelectionRules {
 public static void Validate(IReadOnlyList<NgOption> items,IReadOnlyList<string> value,bool multiple,int? maxItems=50){
  ArgumentNullException.ThrowIfNull(items);ArgumentNullException.ThrowIfNull(value);
  if(maxItems is <0||(maxItems is int limit&&items.Count>limit))throw new ArgumentException("Option count exceeds the configured limit.");
  var ids=new HashSet<string>(StringComparer.Ordinal);
  foreach(var item in items)if(item is null||string.IsNullOrEmpty(item.Value)||item.Value.Length>64||!item.Value.All(c=>char.IsAsciiLetterOrDigit(c)||c is '_' or '-')||string.IsNullOrWhiteSpace(item.Label)||item.Label.Length>120||!ids.Add(item.Value))throw new ArgumentException("Options require unique IDs and nonblank labels of at most 120 characters.");
  if((!multiple&&value.Count>1)||value.Distinct(StringComparer.Ordinal).Count()!=value.Count||value.Any(id=>!ids.Contains(id)))throw new ArgumentException("Use unique known selected IDs; single selection accepts at most one ID.");
 }
 public static IReadOnlyList<string> Toggle(IReadOnlyList<NgOption> items,IReadOnlyList<string> value,string id,bool multiple,bool allowEmpty,int? maxItems=50){
  Validate(items,value,multiple,maxItems);
  if(!items.Any(x=>x.Value==id&&!x.Disabled))return value.ToArray();
  var selected=value.ToHashSet();
  if(selected.Contains(id)){if(!allowEmpty&&selected.Count==1)return value.ToArray();selected.Remove(id);}
  else {if(!multiple)selected.Clear();selected.Add(id);}
  return Array.AsReadOnly(items.Where(x=>selected.Contains(x.Value)).Select(x=>x.Value).ToArray());
 }
}

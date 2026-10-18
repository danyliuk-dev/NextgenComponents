namespace NextgenComponents.Blazor;

/// <summary>A validated snapshot mapping application records to ChipList options.</summary>
/// <remarks>Selectors run once per record. Records retain identity and are not deep-cloned.
/// Rebuild the adapter after changing model fields or collection membership.</remarks>
public sealed class NgChipData<TItem> where TItem : notnull {
 private sealed record Entry(TItem Item, bool Removable, NgChipAppearance Appearance);
 private readonly Dictionary<string,Entry> entries = new(StringComparer.Ordinal);
 public IReadOnlyList<NgOption> Items { get; }
 public NgChipData(IEnumerable<TItem> source, Func<TItem,string> value, Func<TItem,string> text,
  Func<TItem,bool>? disabled=null, Func<TItem,bool>? removable=null,
  Func<TItem,NgChipAppearance?>? appearance=null) {
  ArgumentNullException.ThrowIfNull(source);ArgumentNullException.ThrowIfNull(value);ArgumentNullException.ThrowIfNull(text);
  var options=new List<NgOption>();
  foreach(var item in source){
   if(item is null)throw new ArgumentException("Chip records must not be null.",nameof(source));
   var id=value(item);var label=text(item);var blocked=disabled?.Invoke(item)??false;
   var canRemove=removable?.Invoke(item)??true;var style=appearance?.Invoke(item)??new();
   NgChipRules.Validate(style.Size??"md",style.Rounded??"full",style.FillMode??"outline",style.ThemeColor??"base");
   if(id is null||!entries.TryAdd(id,new(item,canRemove,style)))throw new ArgumentException("Chip records require unique nonnull IDs.",nameof(source));
   options.Add(new(id,label,blocked));
  }
  NgSelectionRules.Validate(options,[],true,maxItems:null);
  Items=options.AsReadOnly();
 }
 /// <summary>Resolve the original record. Unknown IDs throw KeyNotFoundException.</summary>
 public TItem GetItem(string id)=>entries[id].Item;
 /// <summary>Pass as ChipList.CanRemove. Disabled state is enforced by the component.</summary>
 public bool CanRemove(NgOption option)=>entries[option.Value].Removable;
 /// <summary>Pass as ChipList.ItemAppearance. Null overrides inherit list defaults.</summary>
 public NgChipAppearance GetAppearance(NgOption option)=>entries[option.Value].Appearance;
}

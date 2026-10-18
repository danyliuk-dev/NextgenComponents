namespace NextgenComponents.Blazor;
public static class NgFilterRules {
 public static void Validate(string mode,int minLength){if(mode is not("contains" or "startsWith" or "endsWith"))throw new ArgumentException("Use contains, startsWith or endsWith.");if(minLength<0)throw new ArgumentOutOfRangeException(nameof(minLength));}
 public static bool Matches(string label,string query,string mode,int minLength)=>query.Length>=minLength&&(mode switch{"startsWith"=>label.StartsWith(query,StringComparison.OrdinalIgnoreCase),"endsWith"=>label.EndsWith(query,StringComparison.OrdinalIgnoreCase),_=>label.Contains(query,StringComparison.OrdinalIgnoreCase)});
 public static void ValidateItems(IReadOnlyList<NgOption> items){if(items.Any(x=>string.IsNullOrWhiteSpace(x.Value)||string.IsNullOrWhiteSpace(x.Label))||items.Select(x=>x.Value).Distinct().Count()!=items.Count)throw new ArgumentException("Options need unique nonempty values and nonempty labels.");}
}

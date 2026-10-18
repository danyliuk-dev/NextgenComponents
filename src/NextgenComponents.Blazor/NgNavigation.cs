namespace NextgenComponents.Blazor;

public sealed class NgMenuItem {
 public string Id {get;} public string Text {get;} public bool Disabled {get;}
 public IReadOnlyList<NgMenuItem> Children {get;}
 public NgMenuItem(string id,string text,bool disabled=false,IEnumerable<NgMenuItem>? children=null){Id=id;Text=text;Disabled=disabled;Children=Array.AsReadOnly((children??[]).ToArray());}
}
public static class NgNavigationRules {
 public static void ValidateMenu(IReadOnlyList<NgMenuItem> items){
  ArgumentNullException.ThrowIfNull(items);var ids=new HashSet<string>();var count=0;
  void Walk(IReadOnlyList<NgMenuItem> nodes,int depth){if(depth>3&&nodes.Count>0)throw new ArgumentException("Menus support at most three levels.");foreach(var n in nodes){if(n is null||!ValidId(n.Id)||!ValidText(n.Text)||!ids.Add(n.Id)||++count>100)throw new ArgumentException("Use at most 100 unique menu IDs and nonempty labels.");Walk(n.Children,depth+1);}}
  Walk(items,1);
 }
 public static bool CanInvoke(IReadOnlyList<NgMenuItem> items,string id){foreach(var n in items){if(n.Disabled)continue;if(n.Id==id)return n.Children.Count==0;if(CanInvoke(n.Children,id))return true;}return false;}
 public static void ValidateDrawer(IReadOnlyList<NgOption> items,int width){
  if(items is null||items.Count>100||width is <200 or >400)throw new ArgumentException("Use at most 100 items and width 200–400.");var ids=new HashSet<string>();foreach(var n in items)if(n is null||!ValidId(n.Value)||!ValidText(n.Label)||!ids.Add(n.Value))throw new ArgumentException("Drawer items require unique IDs and nonempty labels.");
 }
 private static bool ValidId(string? id)=>id is {Length:>0 and <=64}&&id.All(c=>char.IsAsciiLetterOrDigit(c)||c is '_' or '-');
 private static bool ValidText(string? text)=>!string.IsNullOrWhiteSpace(text)&&text.Length<=120;
}

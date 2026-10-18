namespace NextgenComponents.Blazor;

public sealed class NgMenuItem {
 public string Id {get;} public string Text {get;} public bool Disabled {get;} public bool Visible {get;} public bool Separator {get;}
 public IReadOnlyList<NgMenuItem> Children {get;}
 public NgMenuItem(string id,string text,bool disabled=false,IEnumerable<NgMenuItem>? children=null,bool visible=true,bool separator=false){Id=id;Text=text;Disabled=disabled;Visible=visible;Separator=separator;Children=Array.AsReadOnly((children??[]).ToArray());}
}
public static class NgNavigationRules {
 public static void ValidateMenu(IReadOnlyList<NgMenuItem> items){
  ArgumentNullException.ThrowIfNull(items);var ids=new HashSet<string>();var count=0;
  void Walk(IReadOnlyList<NgMenuItem> nodes,int depth){if(depth>3&&nodes.Count>0)throw new ArgumentException("Menus support at most three levels.");foreach(var n in nodes){if(n is null||!ValidId(n.Id)||!ValidText(n.Text)||!ids.Add(n.Id)||++count>100)throw new ArgumentException("Use at most 100 unique menu IDs and nonempty labels.");if(n.Separator&&n.Children.Count>0)throw new ArgumentException("A separator cannot contain children.");Walk(n.Children,depth+1);}}
  Walk(items,1);
 }
 public static bool CanInvoke(IReadOnlyList<NgMenuItem> items,string id){foreach(var n in items){if(n.Disabled||!n.Visible||n.Separator)continue;if(n.Id==id)return n.Children.Count==0;if(CanInvoke(n.Children,id))return true;}return false;}
 public static void ValidateDrawer(IReadOnlyList<NgOption> items,int width){
  if(items is null||items.Count>100||width is <200 or >400)throw new ArgumentException("Use at most 100 items and width 200–400.");var ids=new HashSet<string>();foreach(var n in items)if(n is null||!ValidId(n.Value)||!ValidText(n.Label)||!ids.Add(n.Value))throw new ArgumentException("Drawer items require unique IDs and nonempty labels.");
 }
 public static void ValidatePresentation(string label,string position="start"){
  if(!ValidText(label))throw new ArgumentException("Use a nonempty navigation label of at most 120 characters.");
  if(position is not ("start" or "end"))throw new ArgumentException("Position must be start or end.");
 }
 private static bool ValidId(string? id)=>id is {Length:>0 and <=64}&&id.All(c=>char.IsAsciiLetterOrDigit(c)||c is '_' or '-');
 private static bool ValidText(string? text)=>!string.IsNullOrWhiteSpace(text)&&text.Length<=120;
}

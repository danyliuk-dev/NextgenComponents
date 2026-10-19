using System.Globalization;
using System.Text.RegularExpressions;
namespace NextgenComponents.Blazor;

public sealed record NgCellValue(string Text, double? Number = null, string? Error = null);
/// <summary>Immutable single-sheet model. Formula language is deliberately bounded; no code evaluation.</summary>
public sealed class NgSheet {
 public int Rows {get;} public int Columns {get;}
 public IReadOnlyDictionary<string,string> Cells {get;}
 public NgSheet(int rows=8,int columns=6,IReadOnlyDictionary<string,string>? cells=null){
  if(rows<1||rows>100||columns<1||columns>26)throw new ArgumentException("Sheet supports 1–100 rows and 1–26 columns.");
  Rows=rows;Columns=columns;var copy=new Dictionary<string,string>();
  foreach(var (key,value) in cells??new Dictionary<string,string>()){var a=key.ToUpperInvariant();Position(a);if(value.Length>1000)throw new ArgumentException("Cell text exceeds 1000 characters.");copy[a]=value;}
  Cells=new System.Collections.ObjectModel.ReadOnlyDictionary<string,string>(copy);
 }
 public static string Address(int row,int column)=>$"{(char)('A'+column)}{row+1}";
 public (int Row,int Column) Position(string address){var m=Regex.Match(address.ToUpperInvariant(),@"^([A-Z])([1-9][0-9]{0,2})$");if(!m.Success)throw new ArgumentException("Invalid cell address.");var r=int.Parse(m.Groups[2].Value)-1;var c=m.Groups[1].Value[0]-'A';if(r>=Rows||c>=Columns)throw new ArgumentException("Cell is outside the sheet.");return(r,c);}
 public string Raw(string address)=>Cells.GetValueOrDefault(address.ToUpperInvariant(),"");
 public NgSheet Set(string address,string value){Position(address);var copy=new Dictionary<string,string>(Cells){[address.ToUpperInvariant()]=value};return new(Rows,Columns,copy);}
 public NgSheet Paste(string origin,string text,Func<string,bool>? canEdit=null){var (r,c)=Position(origin);var lines=text.Replace("\r\n","\n").Replace('\r','\n').TrimEnd('\n').Split('\n');var matrix=lines.Select(l=>l.Split('\t')).ToArray();if(r+matrix.Length>Rows||matrix.Any(l=>c+l.Length>Columns))throw new ArgumentException("Pasted cells exceed sheet bounds.");var copy=new Dictionary<string,string>(Cells);for(var y=0;y<matrix.Length;y++)for(var x=0;x<matrix[y].Length;x++){var target=Address(r+y,c+x);if(canEdit is not null&&!canEdit(target))throw new ArgumentException($"Cell {target} is protected. Paste was not applied.");copy[target]=matrix[y][x];}return new(Rows,Columns,copy);}
 public IReadOnlyList<string> ChangedCells(NgSheet other){if(Rows!=other.Rows||Columns!=other.Columns)throw new ArgumentException("Sheet dimensions must match.");var result=new List<string>();for(var r=0;r<Rows;r++)for(var c=0;c<Columns;c++){var a=Address(r,c);if(Raw(a)!=other.Raw(a))result.Add(a);}return result.AsReadOnly();}
 public NgCellValue Evaluate(string address)=>Evaluate(address.ToUpperInvariant(),new HashSet<string>(),new Dictionary<string,NgCellValue>());
 private NgCellValue Evaluate(string address,HashSet<string> path,Dictionary<string,NgCellValue> cache){if(cache.TryGetValue(address,out var cached))return cached;var result=Calculate(address,path,cache);cache[address]=result;return result;}
 private NgCellValue Calculate(string address,HashSet<string> path,Dictionary<string,NgCellValue> cache){
  try{Position(address);}catch(ArgumentException){return new("#REF!",Error:"#REF!");}
  if(!path.Add(address))return new("#CYCLE!",Error:"#CYCLE!");
  try {var raw=Raw(address);if(!raw.StartsWith('=')){if(double.TryParse(raw,NumberStyles.Float,CultureInfo.InvariantCulture,out var n)&&double.IsFinite(n))return new(Format(n),n);return new(raw);}
   if(path.Count>100)throw new FormulaError("#LIMIT!");var parser=new FormulaParser(raw[1..],this,path,cache);var value=parser.Parse();if(!double.IsFinite(value))throw new FormulaError("#NUM!");return new(Format(value),value);
  }catch(FormulaError e){return new(e.Message,Error:e.Message);}finally{path.Remove(address);}
 }
 public static string Format(double n)=>n.ToString("G10",CultureInfo.InvariantCulture);
 private sealed class FormulaError(string message):Exception(message);
 private sealed class FormulaParser(string text,NgSheet sheet,HashSet<string> path,Dictionary<string,NgCellValue> cache){
  private int at,depth;
  private void Space(){while(at<text.Length&&char.IsWhiteSpace(text[at]))at++;}
  private bool Take(char c){Space();if(at<text.Length&&text[at]==c){at++;return true;}return false;}
  public double Parse(){var v=Expression();Space();if(at!=text.Length)throw new FormulaError("#FORMULA!");return v;}
  private double Expression(){var v=Product();while(true){if(Take('+'))v+=Product();else if(Take('-'))v-=Product();else return v;}}
  private double Product(){var v=Atom();while(true){if(Take('*'))v*=Atom();else if(Take('/')){var d=Atom();if(d==0)throw new FormulaError("#DIV/0!");v/=d;}else return v;}}
  private double Atom(){if(++depth>64)throw new FormulaError("#LIMIT!");try{
   if(Take('+'))return Atom();if(Take('-'))return -Atom();if(Take('(')){var v=Expression();if(!Take(')'))throw new FormulaError("#FORMULA!");return v;}
   Space();var m=Regex.Match(text[at..],@"^(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?");if(m.Success){at+=m.Length;if(!double.TryParse(m.Value,NumberStyles.Float,CultureInfo.InvariantCulture,out var n)||!double.IsFinite(n))throw new FormulaError("#NUM!");return n;}
   m=Regex.Match(text[at..],@"^[A-Za-z]+[0-9]*");if(!m.Success)throw new FormulaError("#FORMULA!");var token=m.Value.ToUpperInvariant();at+=m.Length;
   if(!Take('('))return Cell(token,false)??0;
   if(token is not ("SUM" or "AVERAGE" or "MIN" or "MAX" or "COUNT"))throw new FormulaError("#NAME?");
   var values=new List<double>();if(!Take(')')){do{
    Space();var range=Regex.Match(text[at..],@"^([A-Za-z][1-9][0-9]{0,2})\s*:\s*([A-Za-z][1-9][0-9]{0,2})");
    if(range.Success){at+=range.Length;(int Row,int Column) a,b;try{a=sheet.Position(range.Groups[1].Value);b=sheet.Position(range.Groups[2].Value);}catch(ArgumentException){throw new FormulaError("#REF!");}for(var r=Math.Min(a.Row,b.Row);r<=Math.Max(a.Row,b.Row);r++)for(var c=Math.Min(a.Column,b.Column);c<=Math.Max(a.Column,b.Column);c++){var n=Cell(Address(r,c),true);if(n.HasValue)values.Add(n.Value);}}
    else values.Add(Expression());
   }while(Take(','));if(!Take(')'))throw new FormulaError("#FORMULA!");}
   return token switch{"SUM"=>values.Sum(),"COUNT"=>values.Count,"AVERAGE"=>values.Count>0?values.Sum(x=>x/values.Count):throw new FormulaError("#DIV/0!"),"MIN"=>values.Count>0?values.Min():0,"MAX"=>values.Count>0?values.Max():0,_=>0};
  }finally{depth--;}}
  private double? Cell(string a,bool aggregate){var v=sheet.Evaluate(a,path,cache);if(v.Error!=null)throw new FormulaError(v.Error);if(v.Number.HasValue)return v.Number;if(aggregate)return null;if(v.Text.Length==0)return 0;throw new FormulaError("#VALUE!");}
 }
}

public enum NgAggregate { Sum, Count, Average, Min, Max }
public sealed record NgPivotRecord(string Id,IReadOnlyDictionary<string,string> Dimensions,double? Value);
public sealed record NgPivotSelection(string? Row,string? Column,IReadOnlyList<NgPivotRecord> Records);
public static class NgPivotMath {
 public static void Validate(IReadOnlyList<NgPivotRecord> items){if(items.Select(x=>x.Id).Distinct().Count()!=items.Count||items.Any(x=>string.IsNullOrWhiteSpace(x.Id)||x.Value.HasValue&&!double.IsFinite(x.Value.Value)))throw new ArgumentException("Pivot records require unique nonblank IDs and finite numeric values or null.");}
 public static string Dimension(NgPivotRecord r,string field)=>r.Dimensions.GetValueOrDefault(field,"");
 public static IReadOnlyList<NgPivotRecord> Filter(IReadOnlyList<NgPivotRecord> items,string rowField,string columnField,string? row,string? column)=>items.Where(x=>(row==null||Dimension(x,rowField)==row)&&(column==null||Dimension(x,columnField)==column)).ToArray();
 public static double? Aggregate(IEnumerable<NgPivotRecord> items,NgAggregate aggregate){var records=items.ToArray();if(aggregate==NgAggregate.Count)return records.Length;var values=records.Where(x=>x.Value.HasValue).Select(x=>x.Value!.Value).ToArray();if(values.Length==0)return null;var v=aggregate switch{NgAggregate.Sum=>values.Sum(),NgAggregate.Average=>values.Sum(x=>x/values.Length),NgAggregate.Min=>values.Min(),NgAggregate.Max=>values.Max(),_=>0};return double.IsFinite(v)?v:null;}
}

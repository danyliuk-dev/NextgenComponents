using System.Text;
namespace NextgenComponents.Blazor;

public enum NgGridExportScope { Page, Filtered, Selected }
public sealed record NgGridExportRequest(NgGridExportScope Scope,string Search,IReadOnlyList<NgSortDescriptor> Sorts,IReadOnlyList<string> GroupKeys,IReadOnlyList<string> SelectedIds,int MaxRows);
public sealed record NgGridExportFile(string FileName,string Content,string MimeType,int RowCount,IReadOnlyList<string> ColumnKeys) {
 public byte[] Bytes=>Encoding.UTF8.GetBytes(Content);
}
public sealed record NgGridExport<T> {
 public required Func<NgGridExportFile,CancellationToken,Task> OnExport {get;init;}
 public Func<NgGridExportRequest,CancellationToken,Task<IReadOnlyList<T>>>? ReadExportData {get;init;}
 public IReadOnlyList<string> ColumnKeys {get;init;}=[];
 public Func<string,T,string>? Format {get;init;}
 public string FileName {get;init;}="records.csv";
 public string Delimiter {get;init;}=",";
 public bool IncludeHeaders {get;init;}=true;
 public bool IncludeBom {get;init;}=true;
 public bool ReadOnly {get;init;}
 public int MaxRows {get;init;}=10000;
 public int MaxCharacters {get;init;}=5000000;
 public string ScopeText {get;init;}="Export scope";
 public string PageText {get;init;}="Current page";
 public string FilteredText {get;init;}="Filtered records";
 public string SelectedText {get;init;}="Selected filtered records";
 public string ExportText {get;init;}="Prepare export";
 public string CancelText {get;init;}="Cancel export";
 public string BusyText {get;init;}="Preparing export…";
 public string ReadyText {get;init;}="Export ready.";
 public string ErrorText {get;init;}="Unable to export records. Check limits and retry.";
 public IReadOnlyList<NgDataColumn<T>> Resolve(IReadOnlyList<NgDataColumn<T>> columns){
   if(MaxRows<1 || MaxCharacters<1 || Delimiter is not ("," or ";" or "\t"))throw new ArgumentException("Invalid export limits or delimiter.");
   if(string.IsNullOrWhiteSpace(FileName) || FileName.IndexOfAny(['/', '\\', '\r', '\n', '\0'])>=0)throw new ArgumentException("Export requires a plain file name.");
   var keys=ColumnKeys.Count==0?columns.Select(c=>c.Key).ToArray():ColumnKeys.ToArray();
   if(keys.Length==0 || keys.Distinct().Count()!=keys.Length || keys.Any(k=>columns.Count(c=>c.Key==k)!=1))throw new ArgumentException("Export column keys must exist and be unique.");
   return keys.Select(k=>columns.Single(c=>c.Key==k)).ToArray();
 }
}
public static class NgGridCsv {
 // Quote every cell, including headers. Prefix formula-like text before quoting.
 public static string Cell(string value){
   var first=value.AsSpan();while(first.Length>0 && "\u0009\u000A\u000B\u000C\u000D\u0020\u0085\u00A0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u2028\u2029\u202F\u205F\u3000\uFEFF".Contains(first[0]))first=first[1..];
   if(first.Length>0 && "=+-@".Contains(first[0]) || value.Length>0 && "\t\r\n".Contains(value[0]))value="'"+value;
   return "\""+value.Replace("\"","\"\"")+"\"";
 }
 public static NgGridExportFile Create<T>(IReadOnlyList<T> rows,IReadOnlyList<NgDataColumn<T>> columns,NgGridExport<T> options){
   var selected=options.Resolve(columns);
   if(rows.Count>options.MaxRows)throw new ArgumentException("Export row limit exceeded.");
   var content=new StringBuilder(options.IncludeBom?"\uFEFF":"");
   void Line(IEnumerable<string> cells){foreach(var cell in cells.Select((v,i)=>(v,i))){if(cell.i>0)content.Append(options.Delimiter);if(cell.v.Length>options.MaxCharacters)throw new ArgumentException("Export character limit exceeded.");content.Append(Cell(cell.v));if(content.Length>options.MaxCharacters)throw new ArgumentException("Export character limit exceeded.");}content.Append("\r\n");if(content.Length>options.MaxCharacters)throw new ArgumentException("Export character limit exceeded.");}
   if(options.IncludeHeaders)Line(selected.Select(c=>c.Title));
   foreach(var row in rows)Line(selected.Select(c=>options.Format?.Invoke(c.Key,row)??c.Text(row)));
   return new(options.FileName,content.ToString(),options.Delimiter=="\t"?"text/tab-separated-values;charset=utf-8":"text/csv;charset=utf-8",rows.Count,Array.AsReadOnly(selected.Select(c=>c.Key).ToArray()));
 }
}

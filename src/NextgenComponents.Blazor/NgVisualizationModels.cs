using System.Globalization;
namespace NextgenComponents.Blazor;
public enum NgChartKind { Column, Bar, Line, Area, Pie, Donut }
public sealed record NgChartSeries(string Name,IReadOnlyList<double?> Values);
public sealed record NgChartSelection(int SeriesIndex,int CategoryIndex,string Series,string Category,double Value) { public string Label=>$"{Series} · {Category}: {Value:G6}"; }
public sealed record NgChartMark(string Kind,double[] Coordinates,string Color,NgChartSelection? Point=null);
public sealed record NgChartText(double X,double Y,string Text);
public sealed record NgChartScene(IReadOnlyList<NgChartMark> Marks,IReadOnlyList<NgChartText> Labels);
public static class NgChartMath {
 public static readonly string[] Colors=["#c73e32","#2878b8","#218468","#8b5bb6","#b66d16","#55717d"];
 public static string F(double n)=>n.ToString("0.###",CultureInfo.InvariantCulture);
 public static string Points(double[] p)=>string.Join(" ",Enumerable.Range(0,p.Length/2).Select(i=>$"{F(p[i*2])},{F(p[i*2+1])}"));
 public static double Fraction(double value,double min,double max){if(!double.IsFinite(value)||!double.IsFinite(min)||!double.IsFinite(max)||max<=min)throw new ArgumentException("Gauge requires finite values and Min < Max.");if(value<=min)return 0;if(value>=max)return 1;var span=max-min;return double.IsFinite(span)?(value-min)/span:(value/2-min/2)/(max/2-min/2);}
 public static NgChartScene Build(NgChartKind kind,IReadOnlyList<string> categories,IReadOnlyList<NgChartSeries> series,ISet<int>? hidden=null){
  if(series.Any(s=>s.Values.Count!=categories.Count||s.Values.Any(v=>v.HasValue&&!double.IsFinite(v.Value))))throw new ArgumentException("Series must match categories and contain finite values or null.");
  var active=Enumerable.Range(0,series.Count).Where(i=>hidden?.Contains(i)!=true).ToArray();var marks=new List<NgChartMark>();var labels=new List<NgChartText>();
  if(categories.Count==0||active.Length==0)return new(marks,labels);
  if(kind is NgChartKind.Pie or NgChartKind.Donut){
   if(series.Count>1)throw new ArgumentException("Pie and donut currently accept one series.");
   var s=active[0];if(series[s].Values.Any(v=>v<0))throw new ArgumentException("Pie and donut require nonnegative values.");
   var total=series[s].Values.Sum(v=>v??0);if(!double.IsFinite(total))throw new ArgumentException("Chart total exceeds supported range.");if(total==0)return new(marks,labels);
   var angle=-Math.PI/2;for(var i=0;i<categories.Count;i++){var value=series[s].Values[i]??0;if(value<=0)continue;var sweep=value/total*Math.PI*2;var steps=Math.Max(2,(int)Math.Ceiling(sweep*32));var poly=new List<double>();
    void Add(double a,double r){poly.Add(320+Math.Cos(a)*r);poly.Add(145+Math.Sin(a)*r);}
    for(var k=0;k<=steps;k++)Add(angle+sweep*k/steps,120);
    if(kind==NgChartKind.Donut){for(var k=steps;k>=0;k--)Add(angle+sweep*k/steps,64);}else{poly.Add(320);poly.Add(145);}
    marks.Add(new("polygon",poly.ToArray(),Colors[i%Colors.Length],new(s,i,series[s].Name,categories[i],value)));angle+=sweep;
   }return new(marks,labels);
  }
  var values=active.SelectMany(i=>series[i].Values).Where(v=>v.HasValue).Select(v=>v!.Value).ToArray();if(values.Length==0)return new(marks,labels);
  var min=Math.Min(0,values.Min());var max=Math.Max(0,values.Max());if(min==max)max=min+1;var span=max-min;if(!double.IsFinite(span))throw new ArgumentException("Chart range exceeds supported values.");
  double Y(double v)=>260-(v-min)/span*230;double X(double v)=>100+(v-min)/span*510;
  for(var t=0;t<=4;t++){var value=min+span*(t/4.0);var y=Y(value);if(kind==NgChartKind.Bar){var x=X(value);marks.Add(new("line",[x,20,x,260],"grid"));labels.Add(new(x,286,value.ToString("G3",CultureInfo.InvariantCulture)));}else{marks.Add(new("line",[55,y,620,y],"grid"));labels.Add(new(27,y+4,value.ToString("G3",CultureInfo.InvariantCulture)));}}
  for(var c=0;c<categories.Count;c++){if(kind==NgChartKind.Bar)labels.Add(new(47,30+(c+.5)*230/categories.Count,categories[c]));else labels.Add(new(55+(c+.5)*565/categories.Count,286,categories[c]));}
  for(var si=0;si<active.Length;si++){var s=active[si];var color=Colors[s%Colors.Length];var segment=new List<double>();
   void Flush(){if(segment.Count>=4){if(kind==NgChartKind.Area){var area=new List<double>{segment[0],Y(0)};area.AddRange(segment);area.Add(segment[^2]);area.Add(Y(0));marks.Add(new("area",area.ToArray(),color));}marks.Add(new("line",segment.ToArray(),color));}segment.Clear();}
   for(var c=0;c<categories.Count;c++){var value=series[s].Values[c];if(value is null){Flush();continue;}var point=new NgChartSelection(s,c,series[s].Name,categories[c],value.Value);var x=55+(c+.5)*565/categories.Count;var y=Y(value.Value);
    if(kind==NgChartKind.Column){var band=565.0/categories.Count;var width=band*.72/active.Length;marks.Add(new("rect",[55+c*band+band*.14+si*width,Math.Min(y,Y(0)),width*.92,Math.Max(1,Math.Abs(y-Y(0)))],color,point));}
    else if(kind==NgChartKind.Bar){var band=230.0/categories.Count;var height=band*.72/active.Length;marks.Add(new("rect",[Math.Min(X(value.Value),X(0)),30+c*band+band*.14+si*height,Math.Max(1,Math.Abs(X(value.Value)-X(0))),height*.92],color,point));}
    else{segment.Add(x);segment.Add(y);marks.Add(new("dot",[x,y,5],color,point));}
   }Flush();
  }
  // Lines and areas go behind point targets so every point remains clickable.
  return new(marks.OrderBy(m=>m.Point is null?0:1).ToArray(),labels);
 }
}
public sealed record NgScheduleEvent(string Id,string Title,DateTime Start,DateTime End);
public static class NgScheduleRules {
 public static DateTime WeekStart(DateTime day)=>day.Date.AddDays(-((int)day.DayOfWeek+6)%7);
 public static string? Validate(NgScheduleEvent item)=>string.IsNullOrWhiteSpace(item.Title)?"Title is required.":item.End<=item.Start?"End must be after start.":null;
 public static IReadOnlyList<NgScheduleEvent> ForDay(IEnumerable<NgScheduleEvent> items,DateTime day)=>items.Where(e=>e.Start<day.Date.AddDays(1)&&e.End>day.Date).OrderBy(e=>e.Start).ThenBy(e=>e.Id,StringComparer.Ordinal).ToArray();
}

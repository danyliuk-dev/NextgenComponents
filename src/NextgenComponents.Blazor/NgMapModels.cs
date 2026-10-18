namespace NextgenComponents.Blazor;

public sealed record NgMapPoint {
 public double Latitude { get; }
 public double Longitude { get; }
 public NgMapPoint(double latitude,double longitude) {
  if(!double.IsFinite(latitude)||Math.Abs(latitude)>85.05112878||!double.IsFinite(longitude)||Math.Abs(longitude)>180)throw new ArgumentOutOfRangeException(nameof(latitude),"Use Web Mercator latitude ±85.05112878 and longitude ±180.");
  Latitude=latitude;Longitude=longitude;
 }
}
public sealed record NgMapView {
 public double Latitude { get; }
 public double Longitude { get; }
 public int Zoom { get; }
 public NgMapView(double latitude=0,double longitude=0,int zoom=2){var p=new NgMapPoint(latitude,longitude);if(zoom<0||zoom>19)throw new ArgumentOutOfRangeException(nameof(zoom));Latitude=p.Latitude;Longitude=p.Longitude;Zoom=zoom;}
}
public sealed record NgMapMarker {
 public string Id {get;} public string Text {get;} public NgMapPoint Position {get;}
 public NgMapMarker(string id,string text,NgMapPoint position){NgMapModel.CheckLabel(id,text);Id=id;Text=text;Position=position??throw new ArgumentNullException(nameof(position));}
}
public sealed record NgMapPath {
 public string Id {get;} public string Text {get;} public IReadOnlyList<NgMapPoint> Points {get;} public bool Closed {get;}
 public NgMapPath(string id,string text,IEnumerable<NgMapPoint> points,bool closed=false){NgMapModel.CheckLabel(id,text);var copy=points.ToArray();if(copy.Length<(closed?3:2)||copy.Length>5000||copy.Any(p=>p is null))throw new ArgumentException("Paths need 2 points; polygons need 3. Maximum 5000 points.");Id=id;Text=text;Points=Array.AsReadOnly(copy);Closed=closed;}
}
public sealed record NgMapModel {
 public IReadOnlyList<NgMapMarker> Markers {get;} public IReadOnlyList<NgMapPath> Paths {get;}
 public NgMapModel(IEnumerable<NgMapMarker>? markers=null,IEnumerable<NgMapPath>? paths=null){var m=markers?.ToArray()??[];var p=paths?.ToArray()??[];if(m.Length>500||p.Length>100||m.Any(x=>x is null)||p.Any(x=>x is null)||p.Sum(x=>x.Points.Count)>5000)throw new ArgumentException("Map supports 500 markers, 100 paths and 5000 path points.");if(m.Select(x=>x.Id).Concat(p.Select(x=>x.Id)).Distinct().Count()!=m.Length+p.Length)throw new ArgumentException("Map IDs must be unique across markers and paths.");Markers=Array.AsReadOnly(m);Paths=Array.AsReadOnly(p);}
 internal static void CheckLabel(string id,string text){if(string.IsNullOrWhiteSpace(id)||id.Length>64||!id.All(c=>char.IsAsciiLetterOrDigit(c)||c is '-' or '_')||string.IsNullOrWhiteSpace(text)||text.Length>200)throw new ArgumentException("Use an ASCII ID (1–64 letters, digits, - or _) and text (1–200 characters).");}
}

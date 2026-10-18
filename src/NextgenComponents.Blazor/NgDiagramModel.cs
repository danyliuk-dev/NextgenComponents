using System.Text.Json;
using System.Text.Json.Serialization;

namespace NextgenComponents.Blazor;

public enum NgDiagramShape { Rectangle, Ellipse, Diamond }
public sealed record NgDiagramNode([property: JsonRequired] string Id, [property: JsonRequired] string Text, [property: JsonRequired] double X, [property: JsonRequired] double Y, double Width = 160, double Height = 80, NgDiagramShape Shape = NgDiagramShape.Rectangle);
public sealed record NgDiagramEdge([property: JsonRequired] string Id, [property: JsonRequired] string From, [property: JsonRequired] string To, string Text = "", bool Directed = true);
public sealed record NgDiagramPoint(double X, double Y);
public sealed record NgDiagramView(double Zoom, double ScrollX, double ScrollY);
public sealed record NgDiagramLine(NgDiagramPoint Start, NgDiagramPoint End);

/// <summary>Immutable, validated graph. Removing a node also removes its incident edges.</summary>
public sealed class NgDiagramModel
{
    public double Width { get; }
    public double Height { get; }
    public IReadOnlyList<NgDiagramNode> Nodes { get; }
    public IReadOnlyList<NgDiagramEdge> Edges { get; }
    public NgDiagramModel(IEnumerable<NgDiagramNode>? nodes = null, IEnumerable<NgDiagramEdge>? edges = null, double width = 1000, double height = 600)
    {
        if (!double.IsFinite(width) || !double.IsFinite(height) || width < 200 || width > 5000 || height < 200 || height > 5000) throw new ArgumentException("Canvas dimensions must be 200–5000.");
        var ns = (nodes ?? []).ToArray(); var es = (edges ?? []).ToArray();
        if (ns.Length > 100 || es.Length > 200) throw new ArgumentException("Use at most 100 nodes and 200 connections.");
        var ids = new HashSet<string>(StringComparer.Ordinal);
        foreach (var n in ns)
        {
            if (n is null || !ValidId(n.Id) || !ids.Add(n.Id) || string.IsNullOrWhiteSpace(n.Text) || n.Text.Length > 100 || !Enum.IsDefined(n.Shape)) throw new ArgumentException("Nodes need unique IDs, text (1–100 characters) and a valid shape.");
            if (!double.IsFinite(n.X) || !double.IsFinite(n.Y) || !double.IsFinite(n.Width) || !double.IsFinite(n.Height) || n.Width < 60 || n.Width > 400 || n.Height < 40 || n.Height > 240 || n.X < 0 || n.Y < 0 || n.X + n.Width > width || n.Y + n.Height > height) throw new ArgumentException("Node bounds must fit the canvas; size is 60–400 × 40–240.");
        }
        var edgeIds = new HashSet<string>(StringComparer.Ordinal);
        foreach (var e in es)
            if (e is null || !ValidId(e.Id) || !edgeIds.Add(e.Id) || e.From is null || e.To is null || !ids.Contains(e.From) || !ids.Contains(e.To) || e.From == e.To || e.Text is null || e.Text.Length > 100) throw new ArgumentException("Connections need unique IDs, two different existing nodes and text up to 100 characters.");
        Width = width; Height = height; Nodes = Array.AsReadOnly(ns); Edges = Array.AsReadOnly(es);
    }
    private static bool ValidId(string? id) => id is { Length: > 0 and <= 64 } && id.All(c => char.IsAsciiLetterOrDigit(c) || c is '-' or '_');
    public NgDiagramModel UpsertNode(NgDiagramNode node) => new(Nodes.Any(n => n.Id == node.Id) ? Nodes.Select(n => n.Id == node.Id ? node : n) : Nodes.Append(node), Edges, Width, Height);
    public NgDiagramModel UpsertEdge(NgDiagramEdge edge) => new(Nodes, Edges.Any(e => e.Id == edge.Id) ? Edges.Select(e => e.Id == edge.Id ? edge : e) : Edges.Append(edge), Width, Height);
    public NgDiagramModel RemoveNode(string id) => new(Nodes.Where(n => n.Id != id), Edges.Where(e => e.From != id && e.To != id), Width, Height);
    public NgDiagramModel RemoveEdge(string id) => new(Nodes, Edges.Where(e => e.Id != id), Width, Height);
    public NgDiagramModel Move(string id, double x, double y)
    {
        var n = Nodes.FirstOrDefault(n => n.Id == id) ?? throw new ArgumentException("Unknown node ID.");
        if (!double.IsFinite(x) || !double.IsFinite(y)) throw new ArgumentException("Coordinates must be finite.");
        return UpsertNode(n with { X = Math.Clamp(x, 0, Width - n.Width), Y = Math.Clamp(y, 0, Height - n.Height) });
    }
    /// <summary>Fits occupied node bounds with 24px padding, at 25–200% zoom. Empty graphs return the origin at 100%.</summary>
    public NgDiagramView FitView(double viewportWidth, double viewportHeight)
    {
        if (!double.IsFinite(viewportWidth) || !double.IsFinite(viewportHeight) || viewportWidth <= 0 || viewportHeight <= 0) throw new ArgumentException("Viewport dimensions must be positive and finite.");
        if (Nodes.Count == 0) return new(1, 0, 0);
        var left = Nodes.Min(n => n.X); var top = Nodes.Min(n => n.Y);
        var right = Nodes.Max(n => n.X + n.Width); var bottom = Nodes.Max(n => n.Y + n.Height);
        var scale = Math.Clamp(Math.Min((viewportWidth - 48) / (right - left), (viewportHeight - 48) / (bottom - top)), .25, 2);
        return new(scale,
            Math.Clamp((left + right) / 2 * scale - viewportWidth / 2, 0, Math.Max(0, Width * scale - viewportWidth)),
            Math.Clamp((top + bottom) / 2 * scale - viewportHeight / 2, 0, Math.Max(0, Height * scale - viewportHeight)));
    }
    public NgDiagramLine Line(NgDiagramEdge edge)
    {
        var a = Nodes.First(n => n.Id == edge.From); var b = Nodes.First(n => n.Id == edge.To);
        var dx = b.X + b.Width / 2 - a.X - a.Width / 2; var dy = b.Y + b.Height / 2 - a.Y - a.Height / 2;
        if (dx == 0 && dy == 0) return new(new(a.X + a.Width / 2, a.Y + a.Height / 2), new(b.X + b.Width / 2, b.Y + b.Height / 2));
        return new(Anchor(a, dx, dy), Anchor(b, -dx, -dy));
    }
    private static NgDiagramPoint Anchor(NgDiagramNode n, double dx, double dy)
    {
        var x = Math.Abs(dx) / (n.Width / 2); var y = Math.Abs(dy) / (n.Height / 2);
        var scale = 1 / (n.Shape switch { NgDiagramShape.Ellipse => Math.Sqrt(x * x + y * y), NgDiagramShape.Diamond => x + y, _ => Math.Max(x, y) });
        return new(n.X + n.Width / 2 + dx * scale, n.Y + n.Height / 2 + dy * scale);
    }
    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase, WriteIndented = true, UnmappedMemberHandling = JsonUnmappedMemberHandling.Disallow, Converters = { new JsonStringEnumConverter(JsonNamingPolicy.CamelCase, false) } };
    private sealed record Data(int Version, double Width, double Height, NgDiagramNode[] Nodes, NgDiagramEdge[] Edges);
    public string ToJson() => JsonSerializer.Serialize(new Data(1, Width, Height, Nodes.ToArray(), Edges.ToArray()), JsonOptions);
    public static NgDiagramModel FromJson(string json)
    {
        if (json.Length > 1000000) throw new ArgumentException("Diagram JSON exceeds 1000000 characters.");
        try {
            var d = JsonSerializer.Deserialize<Data>(json, JsonOptions);
            if (d is null || d.Version != 1 || d.Nodes is null || d.Edges is null) throw new ArgumentException("Expected diagram version 1, nodes and edges.");
            return new(d.Nodes, d.Edges, d.Width, d.Height);
        } catch (JsonException) { throw new ArgumentException("Invalid diagram JSON."); }
    }
}

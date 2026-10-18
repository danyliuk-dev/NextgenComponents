using System.Net;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace NextgenComponents.Blazor;

public enum NgBlockKind { Paragraph, Heading1, Heading2, Bullet, Numbered, Quote }
public enum NgTextAlign { Left, Center, Right }
public sealed record NgDocumentBlock(string Text = "", NgBlockKind Kind = NgBlockKind.Paragraph,
    bool Bold = false, bool Italic = false, bool Underline = false, NgTextAlign Align = NgTextAlign.Left);

/// <summary>Immutable, bounded plain-text blocks. No raw HTML is accepted.</summary>
public sealed class NgDocument
{
    public IReadOnlyList<NgDocumentBlock> Blocks { get; }
    public int CharacterCount => Blocks.Sum(b => b.Text.Length);
    public NgDocument(IEnumerable<NgDocumentBlock>? blocks = null)
    {
        var data = (blocks ?? [new NgDocumentBlock()]).Select(b => b is null || b.Text is null ? b! : b with { Text = b.Text.Replace("\r\n", "\n").Replace('\r', '\n') }).ToArray();
        if (data.Length is < 1 or > 100) throw new ArgumentException("Use 1–100 blocks.");
        if (data.Any(b => b is null || b.Text is null || b.Text.Length > 10000 || !Enum.IsDefined(b.Kind) || !Enum.IsDefined(b.Align)))
            throw new ArgumentException("Invalid block or text longer than 10000 characters.");
        if (data.Sum(b => b.Text.Length) > 100000) throw new ArgumentException("Document exceeds 100000 characters.");
        Blocks = Array.AsReadOnly(data);
    }
    public NgDocument Replace(int index, NgDocumentBlock block)
    {
        ValidateIndex(index); var data = Blocks.ToArray(); data[index] = block; return new(data);
    }
    public NgDocument InsertAfter(int index)
    {
        ValidateIndex(index); var data = Blocks.ToList(); data.Insert(index + 1, new()); return new(data);
    }
    public NgDocument Remove(int index)
    {
        ValidateIndex(index); var data = Blocks.ToList(); data.RemoveAt(index); return new(data.Count == 0 ? null : data);
    }
    public NgDocument Move(int index, int target)
    {
        ValidateIndex(index); ValidateIndex(target); var data = Blocks.ToList(); var block = data[index]; data.RemoveAt(index); data.Insert(target, block); return new(data);
    }
    private void ValidateIndex(int index) { if (index < 0 || index >= Blocks.Count) throw new ArgumentOutOfRangeException(nameof(index)); }
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase, WriteIndented = true,
        Converters = { new JsonStringEnumConverter(JsonNamingPolicy.CamelCase, allowIntegerValues: false) },
        UnmappedMemberHandling = JsonUnmappedMemberHandling.Disallow
    };
    private sealed record DocumentData(int Version, NgDocumentBlock[] Blocks);
    public string ToJson() => JsonSerializer.Serialize(new DocumentData(1, Blocks.ToArray()), JsonOptions);
    public static NgDocument FromJson(string json)
    {
        if (json.Length > 1000000) throw new ArgumentException("JSON exceeds 1000000 characters.");
        try
        {
            var data = JsonSerializer.Deserialize<DocumentData>(json, JsonOptions);
            if (data is null || data.Version != 1 || data.Blocks is null) throw new ArgumentException("Expected document version 1 and blocks.");
            return new(data.Blocks);
        }
        catch (JsonException) { throw new ArgumentException("Invalid document JSON."); }
    }
    public string ToHtml()
    {
        var html = new StringBuilder(); string? list = null;
        foreach (var b in Blocks)
        {
            var nextList = b.Kind == NgBlockKind.Bullet ? "ul" : b.Kind == NgBlockKind.Numbered ? "ol" : null;
            if (nextList != list) { if (list is not null) html.Append($"</{list}>"); if (nextList is not null) html.Append($"<{nextList}>"); list = nextList; }
            var tag = b.Kind switch { NgBlockKind.Heading1 => "h1", NgBlockKind.Heading2 => "h2", NgBlockKind.Quote => "blockquote", NgBlockKind.Bullet or NgBlockKind.Numbered => "li", _ => "p" };
            var text = WebUtility.HtmlEncode(b.Text).Replace("\n", "<br>");
            if (b.Underline) text = $"<u>{text}</u>";
            if (b.Italic) text = $"<em>{text}</em>";
            if (b.Bold) text = $"<strong>{text}</strong>";
            html.Append($"<{tag} style=\"text-align:{b.Align.ToString().ToLowerInvariant()};white-space:pre-wrap\">{text}</{tag}>");
        }
        if (list is not null) html.Append($"</{list}>");
        return html.ToString();
    }
}

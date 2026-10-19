using Microsoft.AspNetCore.Components;
namespace NextgenComponents.Blazor;

/// <summary>An explicit, keyed section within a single NgForm validation context.</summary>
public sealed record NgFormSection(string Id, string Title, IReadOnlyList<RenderFragment> Fields,
 string? Description = null, int Columns = 1, int MinColumnWidth = 240, int Gap = 16,
 IReadOnlyList<int>? FieldSpans = null)
{
 internal void Validate()
 {
  if(string.IsNullOrWhiteSpace(Id)||string.IsNullOrWhiteSpace(Title))throw new ArgumentException("A section needs a nonempty ID and title.");
  if(Fields is null||Fields.Any(field=>field is null))throw new ArgumentException("Section fields cannot be null.");
  if(Columns is <1 or >4||MinColumnWidth is <120 or >1200||Gap is <0 or >64)throw new ArgumentException("Invalid section layout limits.");
  if(FieldSpans is not null&&(FieldSpans.Count!=Fields.Count||FieldSpans.Any(span=>span is <0 or >4)))throw new ArgumentException("Supply one span (0–4) per section field.");
 }
}

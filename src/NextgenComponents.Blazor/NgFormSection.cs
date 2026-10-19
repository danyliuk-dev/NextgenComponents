using Microsoft.AspNetCore.Components;
namespace NextgenComponents.Blazor;

/// <summary>An explicit, keyed section within a single NgForm validation context.</summary>
public sealed record NgFormSection(string Id, string Title, IReadOnlyList<RenderFragment>? Fields = null,
 string? Description = null, int Columns = 1, int MinColumnWidth = 240, int Gap = 16,
 IReadOnlyList<int>? FieldSpans = null, IReadOnlyList<NgFormSection>? Sections = null, bool Expanded = true, EventCallback<bool> OnExpandedChanged = default)
{
 internal void Validate(int depth = 1)
 {
  if(depth>8)throw new ArgumentException("Sections must be acyclic and at most eight levels deep.");
  if(string.IsNullOrWhiteSpace(Id)||string.IsNullOrWhiteSpace(Title))throw new ArgumentException("A section needs a nonempty ID and title.");
  if((Fields is null)==(Sections is null))throw new ArgumentException("Supply either Fields or Sections for each section.");
  if(Fields?.Any(field=>field is null)==true)throw new ArgumentException("Section fields cannot be null.");
  if(Columns is <1 or >4||MinColumnWidth is <120 or >1200||Gap is <0 or >64)throw new ArgumentException("Invalid section layout limits.");
  if(FieldSpans is not null&&(Fields is null||FieldSpans.Count!=Fields.Count||FieldSpans.Any(span=>span is <0 or >4)))throw new ArgumentException("Supply one span (0–4) per section field.");
  if(Sections is not null){
   if(Sections.Any(section=>section is null)||Sections.Select(section=>section.Id).Distinct(StringComparer.Ordinal).Count()!=Sections.Count)throw new ArgumentException("Sibling sections need unique IDs.");
   foreach(var section in Sections)section.Validate(depth+1);
  }
 }
}

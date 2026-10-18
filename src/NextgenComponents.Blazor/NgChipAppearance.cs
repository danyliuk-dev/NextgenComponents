namespace NextgenComponents.Blazor;

/// <summary>Shared chip presentation values. Null item overrides inherit list values.</summary>
public sealed record NgChipAppearance(string? Size = null, string? Rounded = null, string? FillMode = null, string? ThemeColor = null);

public static class NgChipRules {
 public static void ValidateAccessibility(string? id,string? labelledBy,string? describedBy){
  if(id is not null&&(string.IsNullOrWhiteSpace(id)||id.Any(char.IsWhiteSpace)))throw new ArgumentException("Id must be nonblank and contain no whitespace.",nameof(id));
  if(labelledBy is not null&&string.IsNullOrWhiteSpace(labelledBy))throw new ArgumentException("AriaLabelledBy must contain an element ID.",nameof(labelledBy));
  if(describedBy is not null&&string.IsNullOrWhiteSpace(describedBy))throw new ArgumentException("AriaDescribedBy must contain an element ID.",nameof(describedBy));
 }

 public static void Validate(string size,string rounded,string fillMode,string themeColor){
  if(!new[]{"sm","md","lg"}.Contains(size)||!new[]{"sm","md","lg","full"}.Contains(rounded)||!new[]{"solid","outline"}.Contains(fillMode)||!new[]{"base","info","success","warning","error"}.Contains(themeColor))
   throw new ArgumentException("Invalid chip appearance. Use documented size, rounded, fill mode and theme color values.");
 }
}

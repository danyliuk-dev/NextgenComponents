namespace NextgenComponents.Blazor;

/// <summary>Null item settings inherit the group's appearance.</summary>
public sealed record NgButtonAppearance(string? Size=null,string? Rounded=null,string? FillMode=null,string? ThemeColor=null);
public static class NgButtonRules {
 public static void Validate(string size,string rounded,string fillMode,string themeColor){
  if(!new[]{"sm","md","lg"}.Contains(size)||!new[]{"sm","md","lg","full"}.Contains(rounded)||!new[]{"solid","outline","flat","link","clear"}.Contains(fillMode)||!new[]{"base","primary","secondary","tertiary","info","success","warning","error","dark","light","inverse"}.Contains(themeColor))throw new ArgumentException("Invalid button appearance. Use documented size, rounded, fill mode and theme color values.");
 }
 public static string Classes(string size,string rounded,string fillMode,string themeColor){Validate(size,rounded,fillMode,themeColor);return $"ng-button-style ng-button-size-{size} ng-button-rounded-{rounded} ng-button-fill-{fillMode} ng-button-tone-{themeColor}";}
}

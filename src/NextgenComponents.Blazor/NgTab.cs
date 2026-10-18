using Microsoft.AspNetCore.Components;
namespace NextgenComponents.Blazor;
public sealed record NgTab(string Label, RenderFragment Content, bool Disabled = false);

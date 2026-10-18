using System.Globalization;
namespace NextgenComponents.Blazor;
/// <summary>ISO wall-clock values, deliberately independent of UTC/time-zone conversion.</summary>
public static class NgDateRules
{
    public static bool TryDate(string? text, out DateOnly value) => DateOnly.TryParseExact(text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out value);
    public static bool TryTime(string? text, out TimeOnly value) => TimeOnly.TryParseExact(text, "HH:mm", CultureInfo.InvariantCulture, DateTimeStyles.None, out value);
    public static bool TryDateTime(string? text, out DateTime value) => DateTime.TryParseExact(text, new[] { "yyyy-MM-dd HH:mm", "yyyy-MM-ddTHH:mm" }, CultureInfo.InvariantCulture, DateTimeStyles.None, out value);
    public static bool Allowed(DateOnly value, DateOnly? min, DateOnly? max, Func<DateOnly,bool>? disabled = null) => (min is null || value >= min) && (max is null || value <= max) && disabled?.Invoke(value) != true;
    public static string? RangeError(NgDateRange? value) => value is null || (value.Start is null && value.End is null) ? null : value.Start is null || value.End is null ? "Enter both start and end dates." : value.End < value.Start ? "End date must not precede start date." : null;
}
public sealed record NgDateRange(DateOnly? Start, DateOnly? End);

namespace NextgenComponents.Blazor;

public sealed record NgGaugeRange(double From, double To, string Color, string Label);
public static class NgGaugeRules
{
    public static IReadOnlyList<NgGaugeRange> Validate(IReadOnlyList<NgGaugeRange> ranges, double min, double max)
    {
        NgChartMath.Fraction(min, min, max);
        var ordered = ranges.OrderBy(r => r.From).ToArray();
        double end = min;
        foreach (var range in ordered)
        {
            if (!double.IsFinite(range.From) || !double.IsFinite(range.To) || range.From < min || range.To > max || range.From >= range.To || range.From < end)
                throw new ArgumentException("Gauge ranges must be finite, nonoverlapping and inside Min/Max with From < To.");
            if (string.IsNullOrWhiteSpace(range.Label) || !System.Text.RegularExpressions.Regex.IsMatch(range.Color ?? "", @"\A#[0-9a-fA-F]{6}\z"))
                throw new ArgumentException("Gauge ranges need a label and a six-digit hex color (#RRGGBB).");
            end = range.To;
        }
        return ordered;
    }
    public static NgGaugeRange? Active(IReadOnlyList<NgGaugeRange> ranges, double value, double min, double max)
    {
        var clamped = Math.Clamp(value, min, max);
        return ranges.FirstOrDefault(r => clamped >= r.From && (clamped < r.To || clamped == max && r.To == max));
    }
    public static string Status(NgGaugeRange? active, double value, double min, double max) =>
        string.Join(" · ", new[]{active?.Label, value < min ? "Below minimum" : value > max ? "Above maximum" : null}.Where(x => !string.IsNullOrEmpty(x)));
    public static string Arc(double from, double to)
    {
        var a = Math.PI * (1 + from); var b = Math.PI * (1 + to);
        return $"M {NgChartMath.F(120+110*Math.Cos(a))} {NgChartMath.F(125+110*Math.Sin(a))} A 110 110 0 0 1 {NgChartMath.F(120+110*Math.Cos(b))} {NgChartMath.F(125+110*Math.Sin(b))}";
    }
}

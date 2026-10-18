# Analytics and scheduling (0.4)

Four new public controls on both platforms: `NgChart`, `NgLinearGauge`, `NgArcGauge`, `NgScheduler`. The library now has **31 controls** per platform. The catalogue has **37 foundation entries** because Chart and its six modes are separate reference entries; these modes are not seven independently implemented controls.

References audited: [Chart](https://www.telerik.com/blazor-ui/chart), [Linear Gauge](https://www.telerik.com/blazor-ui/linear-gauge), [Arc Gauge](https://www.telerik.com/blazor-ui/arc-gauge), [Scheduler](https://www.telerik.com/blazor-ui/scheduler). These are capability/visual references only. All implementation here is original.

| Area | Implemented on Blazor and Flutter Web | Remaining reference capabilities |
|---|---|---|
| Chart | Column, horizontal bar, line, area, pie and donut; shared geometry; categorical axes; signed numeric values; null gaps; series legend toggle; point selection callback; tooltip; empty/error states | Stacking, mixed series, custom axes/scales/ticks, zoom/pan, animation, export, templates, localization, remote data, other chart families |
| Pie/donut | One nonnegative series; category colors/legend; null/zero values skipped; zero total is empty | Multi-ring charts, labels on slices, explosion, custom formatting |
| Linear/arc gauges | Label, numeric value, configurable finite Min/Max, unit, clamped fill with original value displayed; theme-aware tracks | Colored ranges, pointers, advanced scale/ticks, animation and export |
| Scheduler | Monday-based week of daily agenda cards, previous/next/today, event add/edit callbacks, stable event IDs, overlap across midnight, sorted day entries, narrow vertical layout | Time-slot grid, day/month/year views, recurrence, resources, drag/drop, resize, collision constraints, timezone conversion, remote persistence |
| Gallery workflow | Create/edit/delete, isolated draft with Cancel, required title and valid dates, end-after-start validation; data stays in memory | Backend storage, concurrent edit conflicts, recurrence editor |
| Accessibility | Blazor SVG point buttons with Enter/Space; both platforms expose point actions under Chart data; named navigation and event controls; gauge value semantics | Full screen-reader certification, exhaustive keyboard/browser matrix |

## Usage and contracts

Blazor `NgChart` takes `Kind`, `Categories`, `Series`, `OnPointSelected`; Flutter uses the equivalent lowercase parameters. Each `NgChartSeries` has a name and nullable numeric values with exactly one entry per category. Nonfinite numbers and mismatched lengths are rejected. Every point callback contains series/category indices, names and value. The chart owns legend visibility and current selection. Replace lists when changing data; do not mutate Flutter input lists in place. Legend identity is the series index.

`NgLinearGauge` / `NgArcGauge` accept `Value`, `Min`, `Max`, `Label`, `Unit` (lowercase in Flutter). Max must exceed Min. Values outside the range clamp the drawing but remain visible as the supplied number.

`NgScheduler` is controlled: supply `Date`, `Items`, `DateChanged`, `OnCreate`, `OnEdit` in Blazor; `date`, `items`, `onDateChanged`, `onCreate`, `onEdit` in Flutter. The application handles editing and replaces the event list. See the Analytics gallery for the complete form workflow. Event IDs must be unique, titles nonblank and end strictly later than start. Calendar dates use local wall-clock values; callers must normalize timezones before passing data. An event ending exactly at midnight is excluded from the following day. Blazor supports week starts in years 2–9998.

The SVG/canvas plot scales with its container. Dense/long axis labels and very narrow plots are not automatically laid out; Chart data provides readable values independently of plot size. This release targets small categorical datasets and weekly schedules, not large-data virtualization. Styling shares the Nextgen tokens and approximates the reference; no pixel-level Telerik equivalence is claimed.

## Validation

See [verification](verification.md#analytics-and-schedule-04) for real visible Chrome tests on Linux on iMac and committed screenshots. Native mobile verification remains deferred.

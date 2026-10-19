# Analytics and scheduling (0.4)

Four new public controls on both platforms: `NgChart`, `NgLinearGauge`, `NgArcGauge`, `NgScheduler`. The library now has **31 controls** per platform. The catalogue has **37 foundation entries** because Chart and its six modes are separate reference entries; these modes are not seven independently implemented controls.

References audited: [Chart](https://www.telerik.com/blazor-ui/chart), [Linear Gauge](https://www.telerik.com/blazor-ui/linear-gauge), [Arc Gauge](https://www.telerik.com/blazor-ui/arc-gauge), [Scheduler](https://www.telerik.com/blazor-ui/scheduler). These are capability/visual references only. All implementation here is original.

| Area | Implemented on Blazor and Flutter Web | Remaining reference capabilities |
|---|---|---|
| Chart | Column, horizontal bar, line, area, pie and donut; shared geometry; categorical axes; signed numeric values; null gaps; series legend toggle; point selection callback; tooltip; empty/error states | Stacking, mixed series, custom axes/scales/ticks, zoom/pan, animation, export, templates, localization, remote data, other chart families |
| Pie/donut | One nonnegative series; category colors/legend; null/zero values skipped; zero total is empty | Multi-ring charts, labels on slices, explosion, custom formatting |
| Linear/arc gauges | Label, numeric value, configurable finite Min/Max, unit, clamped fill with original value displayed; theme-aware tracks; colored ranges, formatted readings and out-of-scale status | Pointers, advanced scale/ticks, animation and export |
| Scheduler | Day/week agenda cards, configurable week start, independent editing/navigation locks, formatted labels, previous/next/today, event add/edit callbacks, stable event IDs, overlap across midnight, sorted day entries, narrow vertical layout | Time-slot grid, month/year views, recurrence, resources, drag/drop, resize, collision constraints, timezone conversion, remote persistence |
| Gallery workflow | Create/edit/delete, isolated draft with Cancel, required title and valid dates, end-after-start validation; data stays in memory | Backend storage, concurrent edit conflicts, recurrence editor |
| Accessibility | Blazor SVG point buttons with Enter/Space; both platforms expose point actions under Chart data; named navigation and event controls; gauge value semantics | Full screen-reader certification, exhaustive keyboard/browser matrix |

## Usage and contracts

Blazor `NgChart` takes `Kind`, `Categories`, `Series`, `OnPointSelected`; Flutter uses the equivalent lowercase parameters. Each `NgChartSeries` has a name and nullable numeric values with exactly one entry per category. Nonfinite numbers and mismatched lengths are rejected. Every point callback contains series/category indices, names and value. The chart owns current selection and, by default, legend visibility; 0.36 also supports controlled legend visibility. Replace lists when changing data; do not mutate Flutter input lists in place. Legend identity is the series index.

`NgLinearGauge` / `NgArcGauge` accept `Value`, `Min`, `Max`, `Label`, `Unit` (lowercase in Flutter). Max must exceed Min. Values outside the range clamp the drawing but remain visible as the supplied number.

`NgScheduler` is controlled: supply `Date`, `View`, `Items`, `DateChanged`, `ViewChanged`, `OnCreate`, `OnEdit` in Blazor; use the equivalent lowercase parameters and `onDateChanged`, `onViewChanged`, `onCreate`, `onEdit` in Flutter. The application handles editing and replaces the event list. See the Analytics gallery for the complete form workflow. Event IDs must be unique, titles nonblank and end strictly later than start. Calendar dates use local wall-clock values; callers must normalize timezones before passing data. An event ending exactly at midnight is excluded from the following day. Both platforms require all displayed days to fall in years 2–9998.

The SVG/canvas plot scales with its container. Dense/long axis labels and very narrow plots are not automatically laid out; Chart data provides readable values independently of plot size. This release targets small categorical datasets and weekly schedules, not large-data virtualization. Styling shares the Nextgen tokens and approximates the reference; no pixel-level Telerik equivalence is claimed.

## Validation

See [verification](verification.md#analytics-and-schedule-04) for real visible Chrome tests on Linux on iMac and committed screenshots. Native mobile verification remains deferred.

## Chart state and point labels (0.36)

Omit HiddenSeries/hiddenSeries for internal legend state. Supply a set of zero-based series indices for controlled state and accept HiddenSeriesChanged/onHiddenSeriesChanged to apply a change. Proposals are fresh sets; rejected proposals do not change the chart or clear selection. Without a controlled callback legend buttons are disabled. Unknown indices are ignored by drawing and retained in controlled proposals. The parent owns pruning and reordering; series identity remains index-based. Keep the ownership mode stable for each chart instance. Returning to internal mode resumes its previous internal visibility.

LegendReadOnly/legendReadOnly and SelectionReadOnly/selectionReadOnly independently guard legend and point actions. Point data, hover text and Chart data stay readable. Programmatic visibility updates work while locked.

PointLabel/pointLabel formats plain text consistently in hover/tooltips, accessible point actions and current selection. It receives the full numeric selection record; axes and callback payloads remain numeric and unchanged. EmptyText/emptyText customizes the no-data message. Selection stays only while an identical visible point (indices, names and value) exists. Hiding/changing/removing that point or invalid data clears selection; later recovery does not resurrect it. Stale callbacks cannot select a changed or hidden point. The example's Last callback is application-owned history and deliberately persists independently of current chart selection.

Six existing chart modes are covered; pie/donut still require a single nonnegative series. Gauges, axis formatting, tooltip widgets, zoom/pan, stacking, export and additional chart families are outside this stage.

## Gauge ranges and formatted readings (0.37)

Min must be less than Max; all numbers must be finite. Even finite bounds whose difference overflows are supported. Drawing clamps outside values; the displayed original value and Above maximum/Below minimum status preserve the supplied reading. Ranges/ranges accepts NgGaugeRange(From, To, Color, Label), lowercase fields in Flutter. Colors must be six-digit hex (#RRGGBB), labels nonblank, ranges inside the scale with From < To and no overlap. Input order is immaterial; validation sorts a copy. Gaps are allowed and use the theme primary color. Shared endpoints belong to the next range; Max belongs to the range ending at Max. Active color uses the clamped value. Stripes/arcs and a text legend show all ranges. ValueFormatter/valueFormatter formats current value, bounds and legend as plain text; Unit is appended only to the current value. Defaults preserve six significant digits, including fractional values. Replace lists when updating Flutter inputs. This is a read-only single-scale indicator; pointers, ticks, animation and export are not implemented.

## Scheduler state and day/week agendas (0.38)

Date/date and View/view are controlled; accept DateChanged/onDateChanged and ViewChanged/onViewChanged to apply proposals. Week is the default, Day shows one agenda. Previous/Next move by seven or one calendar days; Today proposes local midnight. A rejected proposal keeps the current display. FirstDayOfWeek/firstDayOfWeek uses ISO 1–7 (Monday–Sunday), default 1, and only changes weekly alignment. All displayed days must fall in years 2–9998; invalid configuration is rejected and navigation across the boundary is disabled. ReadOnly/readOnly disables create/edit; NavigationReadOnly/navigationReadOnly independently disables date/view actions. Programmatic date/view updates still work. Missing callbacks disable the related actions. Stale callbacks after date/view changes, editing locks, event removal/change or disposal cannot edit old data. NgScheduleEvent requires a unique nonblank ID, nonblank title and End > Start. Events intersect days using [Start, End), so an event ending at midnight is excluded from the next day; overnight events appear on every intersected day. EventLabel/eventLabel formats plain text without changing callback data; EmptyText/emptyText replaces the empty-day message. Replace input lists instead of mutating them. Times are local wall-clock values; callers normalize zones before passing data. The application owns the editor and persistence. This is an agenda layout, not a time-slot grid; month/year views, recurrence, resources, drag/resize and timezone conversion remain open.

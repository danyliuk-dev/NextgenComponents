# NgPager — Pagination

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Navigate a known number of records.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgPager) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgPager)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

Page is one-based; PageSize is positive, Total is the count before paging. Store PageChanged and PageSizeChanged, and reset/clamp the page when the filter or size changes. The pager does not fetch or slice data: the example performs Skip/Take or equivalent application slicing. Disable impossible navigation at the first/last page. Server paging must provide a consistent total and handle stale asynchronous responses.

## Blazor example

```razor
<NgPager Total="items.Length" @bind-Page="page" @bind-PageSize="size"/>
@foreach(var item in items.Skip((page-1)*size).Take(size)){<p>@item</p>}
@code { private int page=1,size=5; private string[] items=Enumerable.Range(1,18).Select(i=>$"Row {i}").ToArray(); }
```

## Flutter example

```dart
int page = 1, size = 5;
Widget build(BuildContext context) => NgPager(total: 18, page: page, pageSize: size,
  onPageChanged: (v) => setState(() => page = v),
  onPageSizeChanged: (v) => setState(() { size = v; page = 1; }));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Total` | `int` | 0 | See the behavior rules and model contract above. |
| `Page` | `int` | 1 | See the behavior rules and model contract above. |
| `PageSize` | `int` | 10 | See the behavior rules and model contract above. |
| `Sizes` | `IReadOnlyList<int>` | [5,10,25,50] | See the behavior rules and model contract above. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `Label` | `string` | "Pagination" | Visible label or accessible name. |
| `PageChanged` | `EventCallback<int>` | not set | See the behavior rules and model contract above. |
| `PageSizeChanged` | `EventCallback<int>` | not set | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `total` | `int` | See the behavior rules and model contract above. |
| `page` | `int` | See the behavior rules and model contract above. |
| `pageSize` | `int` | See the behavior rules and model contract above. |
| `sizes` | `List<int>` | See the behavior rules and model contract above. |
| `onPageChanged` | `ValueChanged<int>` | See the behavior rules and model contract above. |
| `onPageSizeChanged` | `ValueChanged<int>` | See the behavior rules and model contract above. |
| `enabled` | `bool` | See the behavior rules and model contract above. |

```dart
const NgPager({
    super.key,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    this.sizes = const [5, 10, 25, 50],
    this.enabled = true,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgPager.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/data.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.

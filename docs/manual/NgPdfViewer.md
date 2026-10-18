# NgPdfViewer — PDF viewer

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Open, navigate, search and copy text from PDF documents.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgPdfViewer) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgPdfViewer)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### Hosting and sources
Source is a relative or HTTP(S) URL resolved from the app base URI. Host the file yourself in wwwroot/samples (Blazor) or web/samples (Flutter). Empty source opens the viewer with Open PDF. Browser requests send same-origin cookies only to their origin; remote servers must allow CORS. Open PDF reads a local file without upload. PDF.js, worker, CMaps and fonts are packaged locally; no CDN or additional script tag is needed.

Blazor serves _content/NextgenComponents.Blazor/pdf-viewer/. With UseStaticFiles map .mjs to text/javascript and .bcmap/.pfb to application/octet-stream (see gallery Program.cs). The iframe works under SSR; parent parameter changes require interactivity. Flutter package assets supply the viewer. CSP must permit the required local frame/scripts/styles/workers/fonts and source connections, including blob workers/fonts where used; configure it in the host.

### Navigation, search and state
Previous/Next and Page use one-based page numbers. Zoom is 10–300%, with 25-point button increments. Fit width/page recomputes on viewport resize. Enlarged pages scroll internally. Height is 400–1600, default 640; the toolbar wraps on narrow widths and leaves at least 100 px for the page.

Find searches a case-insensitive substring across every page, normalizing whitespace and matching across text items/lines. Results list page numbers; selecting one opens that page and Page text. Clear removes query/results/highlights. Page text supports ordinary selection/copy. Text can also be selected over the rendered page; Ctrl/Cmd+C uses the browser clipboard. Current-page matches are highlighted (up to 1,000 non-overlapping matches), surviving zoom/navigation/fit. Find applies a changed query; Clear, an empty Find and document changes reset it. Redrawing clears ordinary selection. Highlight geometry depends on PDF fonts/text; CSS Custom Highlight API is used in Chrome, with page search and selection as fallback. No OCR: scanned PDFs without text cannot be searched. Hyphenation, ligatures and source text order may affect matching.

Download saves the original bytes, including locally opened files. Filenames from URLs/files are stripped of control characters/path separators. The viewer does not edit PDF. Page/zoom/search/local-file state belongs to the iframe. Source or theme changes recreate it and reset state; reopen local files after a theme change. Identical parent rebuilds preserve it. Page/load callbacks and controlled page binding are not implemented.

### Limits and failures
At most 20 MiB and 200 pages, including streamed URL downloads. One page is rendered at a time; raster output is capped at 16 million pixels and an 8192-pixel side, reducing quality at extreme zoom if necessary. Corrupt files, CORS/access errors and password-protected documents show an error and allow another file. No passwords, forms, annotations, signatures, PDF links, print, OCR, thumbnails or built-in localization. PDF JavaScript/actions are not executed.

Flutter currently supports this component on Web only; native displays an explicit unsupported message. Native support and full screen-reader certification are not part of this release.

## Blazor example

```razor
<NgPdfViewer Label="Guide" Source="samples/nextgen-guide.pdf" Height="720" Dark="false"/>
<p>PDF must be hosted by the application at this address.</p>
```

## Flutter example

```dart
Widget build(BuildContext context) => const NgPdfViewer(
  label: 'Guide', source: 'samples/nextgen-guide.pdf', height: 720);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "PDF viewer" | Visible label or accessible name. |
| `Source` | `string?` | not set | See the behavior rules and model contract above. |
| `Height` | `int` | 640 | See the behavior rules and model contract above. |
| `Dark` | `bool` | false | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `source` | `String?` | See the behavior rules and model contract above. |
| `height` | `double` | See the behavior rules and model contract above. |

```dart
const NgPdfViewer({
    super.key,
    this.label = 'PDF viewer',
    this.source,
    this.height = 640,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgPdfViewer.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/pdf_viewer.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.

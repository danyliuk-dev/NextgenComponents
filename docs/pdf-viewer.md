# PDF Viewer capabilities — 0.8.1

Reference audit (2026-10-18): [Telerik PDF Viewer overview](https://www.telerik.com/blazor-ui/documentation/components/pdfviewer/overview). Its feature set includes navigation, zoom, search/selection, file open/download, printing, annotations and form filling. This implementation provides the subset below, without API compatibility.

| Capability | Blazor | Flutter Web |
|---|---|---|
| URL / local file open; empty/loading/error states | Implemented | Implemented |
| Previous/next and direct page input | Implemented | Implemented |
| Zoom 10–300%, fit page/width, scrolling | Implemented | Implemented |
| Case-insensitive text search, matching page buttons | Implemented | Implemented |
| Extracted page text for selection/copy | Separate text panel | Separate text panel |
| Download original document | Implemented | Implemented |
| Local PDF.js worker, fonts, CMaps, WASM | Packaged | Packaged |
| Dark theme, narrow layout | Implemented | Implemented |
| Passwords, print, annotations/forms/signatures, links, OCR | Planned | Planned |
| Text selection over page, exact search highlights | Implemented | Implemented |
| Thumbnails | Planned | Planned |
| Page/load callbacks and controlled navigation | Planned | Planned |
| Native platforms | Not verified | Explicit unsupported placeholder |

Shared renderer runs in an iframe, independent of SignalR and Flutter rendering. Limits: 20 MiB, 200 pages, one rendered page, maximum 16 million raster pixels and 8192px per side. Fit modes recompute on resize. Source or theme changes reset the iframe; a locally opened document must be reopened after a theme change. No PDF data is uploaded by the viewer.

[Detailed Russian manual](manual/NgPdfViewer.md). Gallery /pdf / Foundation → PDF Viewer. [PDF.js](https://mozilla.github.io/pdf.js/) 6.4.299 is Apache-2.0; pinned distribution and notices are included. Original toolbar/behavior/styles live in shared/pdf-viewer, copied into both packages by scripts/sync_pdf_assets.py. No Telerik implementation/assets were copied.

## Text layer (0.8.1)

PDF.js TextLayer overlays the rendered page at the same scale and page rotation. Native browser selection supports copy; changing page/zoom rerenders and clears selection. CSS Custom Highlight ranges mark up to 1000 non-overlapping matches on the visible page without modifying the text nodes. Search ignores case and folds whitespace; matches can span adjacent PDF text runs and line breaks. Clear/empty search/new document removes highlights. Scans still require OCR. Browsers without the CSS Highlight API retain selection and page search; highlights were verified in Chrome.

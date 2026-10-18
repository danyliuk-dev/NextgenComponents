# Document editor capabilities — 0.6

Reference audit (2026-10-18): [Telerik Editor overview](https://demos.telerik.com/blazor-ui/editor/overview) and [tools](https://demos.telerik.com/blazor-ui/editor/tools). The reference is a WYSIWYG HTML editor with configurable tools and paste cleanup. NgEditor is an original, narrower structured-block implementation with a separate editing field and preview; it does not claim rich-text/HTML parity or API compatibility.

| Capability | Blazor | Flutter Web |
|---|---|---|
| Immutable document model; controlled callback | Implemented | Implemented |
| Paragraph, H1/H2, quote, bullet, numbered blocks | Implemented | Implemented |
| Bold, italic, underline, alignment for whole block | Implemented | Implemented |
| Select/add/delete/reorder blocks | Implemented | Implemented |
| Apply draft, 50-operation undo/redo | Implemented | Implemented |
| Independent parent replacement resets draft/history | Implemented | Implemented |
| Read-only, keyboard-accessible native fields/buttons | Implemented | Implemented |
| Bounded JSON v1 roundtrip | Implemented | Implemented |
| Escaped HTML export, grouped lists, preserved newlines | Implemented | Implemented |
| Light/dark, compact and narrow layout | Implemented | Implemented |
| Inline ranges, rich paste/HTML import, images, links, tables | Planned | Planned |
| Nested lists, custom fonts/tools, PDF/Word, collaboration | Planned | Planned |
| Screen reader audit, native mobile tests | Not verified | Not verified |

[Manual with code examples and detailed draft/history rules](manual/NgEditor.md). Gallery: `/editor` in Blazor; Foundation → Editor in Flutter. Source JSON and HTML are shown as editable/selectable text; persistence and download belong to the host application. Reference software source and assets were not copied.

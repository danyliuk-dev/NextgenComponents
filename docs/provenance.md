# Source provenance

Reviewed 2026-10-18:

- https://github.com/telerik/blazor-ui — examples repository; its README explicitly states that it does not contain the actual component source.
- https://github.com/telerik/kendo-themes — public Sass themes. Its README License section states Apache 2.0 use when no commercial license is held. Individual package/version terms must be checked and pinned before importing anything.
- https://www.telerik.com/blazor-ui — source of the component names/categories/links in the coverage index.
- https://www.telerik.com/products — product index; no Flutter UI suite was identified.

No third-party component code, CSS, icons or theme assets were imported into the libraries in this stage. Both implementations and the token generator were written for this project. Telerik/Progress names identify the comparison target, not authorship or affiliation. A license for distributing this project's own source has not yet been selected by the owner; do not infer MIT/Apache from the upstream references.

The catalog is an index snapshot, not copied documentation. Names, categories and links are extracted by `scripts/import_catalog.py`; future imports should preserve independently maintained feature specifications/status rather than overwrite them.

## PDF engine (0.8)
NgPdfViewer uses unmodified PDF.js 6.4.299 under Apache-2.0. Distribution files, license and bundled font/WASM notices are retained in shared/pdf-viewer/vendor and copied to both component packages. See vendor/PROVENANCE.md. The toolbar, framework wrappers and gallery PDF are original project code/content. The component has a documented limited feature set; this does not import Telerik code.

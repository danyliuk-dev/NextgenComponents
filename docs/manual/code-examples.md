# Code examples

[Getting started](getting-started.md) · [All component manuals](README.md)

Every component manual contains **Blazor example** and **Flutter example** sections with real API calls. The galleries' **Code examples** screen displays these same maintained snippets, including Copy buttons; choose a component and a framework. The examples are compiled/analyzed by `scripts/check_manual_examples.py`.

## Choose a task

| Task | Examples and full contract |
|---|---|
| Install and create an application | [Getting started](getting-started.md) |
| Submit validated data | [NgForm](NgForm.md), [NgDateRangePicker](NgDateRangePicker.md) |
| Build a multi-step workflow | [NgWizard](NgWizard.md), [NgStepper](NgStepper.md) |
| Display and select business records | [NgDataGrid](NgDataGrid.md), [NgTreeList](NgTreeList.md) |
| Aggregate local data | [NgPivotGrid](NgPivotGrid.md), [NgChart](NgChart.md) |
| Calculate and edit worksheet values | [NgSpreadsheet](NgSpreadsheet.md), [formula reference](models.md#formula-language) |
| Save structured documents | [NgEditor](NgEditor.md), [document model](models.md#ngdocument) |
| Edit a process diagram | [NgDiagram](NgDiagram.md) |
| Display an existing PDF | [NgPdfViewer](NgPdfViewer.md) |
| Add geographic objects and respond to clicks | [NgMap](NgMap.md) |
| Connect an application-owned AI handler | [NgAIPrompt](NgAIPrompt.md), [NgPromptBox](NgPromptBox.md) |

## Complete working source

Snippets focus on one component. For a complete page with state, errors, themes and actions, use the matching gallery source:

| Workflow | Blazor | Flutter |
|---|---|---|
| Foundation | [Home.razor](../../examples/BlazorGallery/Components/Pages/Home.razor) | [main.dart](../../examples/flutter_gallery/lib/main.dart) |
| Multi-step application | [Steps.razor](../../examples/BlazorGallery/Components/Pages/Steps.razor) | [steps_gallery.dart](../../examples/flutter_gallery/lib/steps_gallery.dart) |
| AI request lifecycle | [AI.razor](../../examples/BlazorGallery/Components/Pages/AI.razor) | [ai_gallery.dart](../../examples/flutter_gallery/lib/ai_gallery.dart) |
| Map selection and updates | [Map.razor](../../examples/BlazorGallery/Components/Pages/Map.razor) | [map_gallery.dart](../../examples/flutter_gallery/lib/map_gallery.dart) |

## NextgenReportEngine is a separate library

NgPdfViewer displays an existing PDF; it does not generate reports. NextgenReportEngine owns report templates, data preparation, rendering and exports. Its Developer guide covers C#, HTTP, Blazor and Flutter integration. Keep report generation in that engine and pass the resulting hosted PDF URL to NgPdfViewer. The Components AI examples likewise do not invoke a report engine or a paid AI provider.

## Validate your integration

Check an empty value, a valid submission, invalid input, callback-driven updates, asynchronous failure/retry, dark theme and a narrow viewport. Do not copy demo delays or local-only saves into a production service: replace them with your authenticated backend and appropriate idempotency/cancellation.

"""Generate runnable previews from the exact curated manual snippets.
Called by generate_manual.py: adding a component manual also adds both previews.
"""
from pathlib import Path
from manual_content import D
ROOT = Path(__file__).resolve().parents[1]

def generate():
    folder = ROOT / 'examples/BlazorGallery/Components/ManualPreviews'
    folder.mkdir(exist_ok=True)
    for old in folder.glob('*Example.razor'):
        old.unlink()
    for name, data in D.items():
        (folder / f'{name}Example.razor').write_text('@* Generated from scripts/manual_content.py *@\n' + data['blazor'].rstrip() + '\n')
    choices = '\n'.join(f'"{name}" => typeof(ManualPreviews.{name}Example),' for name in sorted(D))
    (ROOT / 'examples/BlazorGallery/Components/Pages/ComponentPreview.razor').write_text('''@page "/preview/{Name}"
<PageTitle>@Name preview</PageTitle>
<div class="ng-scope manual-preview" data-ng-theme="light">
@if (ExampleType is {} type) {
    <ErrorBoundary @key="Name"><ChildContent><DynamicComponent Type="type" /></ChildContent>
    <ErrorContent><p role="alert">This example could not render. Reload the preview or open the gallery.</p></ErrorContent></ErrorBoundary>
} else { <p role="alert">Unknown component.</p> }
</div>
<style>body { margin:0; } .manual-preview { box-sizing:border-box; padding:24px; min-height:100vh; background:var(--ng-background); color:var(--ng-text); } .manual-preview > * { max-width:100%; }</style>
@code {
    [Parameter] public string Name { get; set; } = "";
    private Type? ExampleType => Name switch {
''' + choices + '\n_ => null\n};\n}\n')
    dart = "// GENERATED from scripts/manual_content.py. Do not edit.\nimport 'package:flutter/material.dart';\nimport 'package:nextgen_components/nextgen_components.dart';\n"
    dart += '\n'.join(sorted({item for data in D.values() for item in data.get('dart_imports',[])}))+'\n'
    dart += '''class ComponentPreview extends StatelessWidget {
  final String name;
  const ComponentPreview({super.key, required this.name});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '$name preview', debugShowCheckedModeBanner: false,
    theme: NgTheme.light(), home: Scaffold(body: SafeArea(
      child: SingleChildScrollView(padding: const EdgeInsets.all(24),
        child: SizedBox(width: double.infinity, child: switch (name) {
'''
    dart += '\n'.join(f"'{name}' => const {name}Example()," for name in sorted(D))
    dart += "_ => const Text('Unknown component.'),\n})),\n)));\n}\n"
    for name, data in D.items():
        dart += f'class {name}Example extends StatefulWidget {{ const {name}Example({{super.key}}); @override State<{name}Example> createState()=>_{name}ExampleState(); }}\nclass _{name}ExampleState extends State<{name}Example> {{\n' + data['dart'] + '\n}\n'
    (ROOT / 'examples/flutter_gallery/lib/manual_previews.g.dart').write_text(dart)
    print(f'Generated {len(D) * 2} runnable component previews')

if __name__ == '__main__':
    generate()

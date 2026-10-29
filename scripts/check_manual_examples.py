"""Compile all curated Blazor examples and analyze all Flutter examples.
Uses dotnet/dart on PATH (override --dotnet/--dart), and existing project restores.
Generated build files stay in ignored artifacts; transient Dart fixture is removed.
"""
from pathlib import Path
import argparse,subprocess,re
from manual_content import D
root=Path(__file__).resolve().parents[1]
D=dict(D)
range_manual=(root/'docs/manual/remote-ranges.md').read_text()
D['RemoteRanges']={'blazor':re.search(r'```razor\n(.*?)```',range_manual,re.S).group(1),'dart':re.search(r'```dart\n(.*?)```',range_manual,re.S).group(1)}
grouped_manual=(root/'docs/manual/grouped-remote-ranges.md').read_text()
D['GroupedRemoteRanges']={'blazor':re.search(r'```razor\n(.*?)```',grouped_manual,re.S).group(1),'dart':re.search(r'```dart\n(.*?)```',grouped_manual,re.S).group(1)}
parser=argparse.ArgumentParser();parser.add_argument('--dotnet',default='dotnet');parser.add_argument('--dart',default='dart');args=parser.parse_args()
folder=root/'artifacts/manual-check';folder.mkdir(parents=True,exist_ok=True)
(folder/'ManualCheck.csproj').write_text('<Project Sdk="Microsoft.NET.Sdk.Razor"><PropertyGroup><TargetFramework>net10.0</TargetFramework><Nullable>enable</Nullable><ImplicitUsings>enable</ImplicitUsings></PropertyGroup><ItemGroup><FrameworkReference Include="Microsoft.AspNetCore.App"/><ProjectReference Include="../../src/NextgenComponents.Blazor/NextgenComponents.Blazor.csproj"/></ItemGroup></Project>')
(folder/'_Imports.razor').write_text('@using NextgenComponents.Blazor\n@using Microsoft.AspNetCore.Components\n@using Microsoft.AspNetCore.Components.Forms\n')
for n,d in D.items():(folder/(n+'Example.razor')).write_text(d['blazor'])
fixture=root/'examples/flutter_gallery/test/manual_examples.g.dart';fixture.parent.mkdir(exist_ok=True)
code="import 'package:flutter/material.dart';\nimport 'package:nextgen_components/nextgen_components.dart';\n"
code+='\n'.join(sorted({item for d in D.values() for item in d.get('dart_imports',[])}))+'\n'
for n,d in D.items():code+=f'class {n}Example extends StatefulWidget {{ const {n}Example({{super.key}}); @override State<{n}Example> createState()=>_{n}ExampleState(); }}\nclass _{n}ExampleState extends State<{n}Example> {{\n'+d['dart']+'\n}\n'
try:
 fixture.write_text(code)
 subprocess.run([args.dotnet,'build',str(folder/'ManualCheck.csproj'),'-m:1','-p:NuGetAudit=false','--ignore-failed-sources','--nologo'],cwd=root,check=True)
 subprocess.run([args.dart,'analyze',str(fixture)],cwd=root,check=True)
finally:fixture.unlink(missing_ok=True)
print(f'PASS {len(D)} Blazor and {len(D)} Flutter manual examples')

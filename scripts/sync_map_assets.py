"""Copy the shared Map viewer and its pinned engine into both framework packages."""
from pathlib import Path
import shutil, sys
root=Path(__file__).resolve().parents[1]
source=root/'shared/map-viewer'
for target in [root/'src/NextgenComponents.Blazor/wwwroot/map-viewer',root/'packages/nextgen_components/assets/map-viewer']:
    if '--check' in sys.argv:
        expected={p.relative_to(source):p.read_bytes() for p in source.rglob('*') if p.is_file()}
        actual={p.relative_to(target):p.read_bytes() for p in target.rglob('*') if p.is_file()}
        assert expected==actual, f'Map assets out of sync: {target}'
        continue
    if target.exists(): shutil.rmtree(target)
    shutil.copytree(source,target)
print('Map viewer assets verified' if '--check' in sys.argv else 'Map viewer assets synchronized')

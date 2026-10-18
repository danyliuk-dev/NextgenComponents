"""Verify chip semantic palettes in CSS against Dart and enabled text contrast."""
import re
from pathlib import Path
from check_theme import luminance
root=Path(__file__).resolve().parents[1]
css=(root/'src/NextgenComponents.Blazor/wwwroot/nextgen.css').read_text()
dart=(root/'packages/nextgen_components/lib/src/chips.dart').read_text().lower()
pairs=re.findall(r'--chip-tone:(#[0-9a-f]{6});--chip-bg:(#[0-9a-f]{6})',css)
assert len(pairs)==8
for fg,bg in pairs:
    assert '0xff'+fg[1:] in dart and '0xff'+bg[1:] in dart, 'CSS/Dart chip palette drift'
    a,b=sorted((luminance(fg),luminance(bg)))
    ratio=(b+.05)/(a+.05)
    assert ratio>=4.5,(fg,bg,ratio)
    print(f'PASS chip {fg}/{bg}: {ratio:.2f}:1')

"""Check generated assets and core WCAG text contrast without dependencies."""
import json
import subprocess
import sys
from pathlib import Path
root = Path(__file__).resolve().parents[1]
outputs = [root/'src/NextgenComponents.Blazor/wwwroot/tokens.css', root/'packages/nextgen_components/lib/src/tokens.dart']
before = [p.read_bytes() for p in outputs]
subprocess.run([sys.executable, str(root/'scripts/generate_theme.py')], check=True)
assert before == [p.read_bytes() for p in outputs], 'Generated theme drift; review and retain regenerated assets'
tokens = json.loads((root/'design/tokens.json').read_text())
def luminance(color):
    values = [int(color[i:i+2],16)/255 for i in (1,3,5)]
    values = [v/12.92 if v <= .04045 else ((v+.055)/1.055)**2.4 for v in values]
    return sum(v*w for v,w in zip(values,(.2126,.7152,.0722)))
for mode in ('light','dark'):
    colors = tokens[mode]
    pairs = [('text','surface'),('muted','surface'),('text','background'),('error','surface')]
    for fg,bg in pairs:
        a,b = sorted((luminance(colors[fg]),luminance(colors[bg])))
        ratio = (b+.05)/(a+.05)
        assert ratio >= 4.5, (mode,fg,bg,ratio)
        print(f'PASS {mode} {fg}/{bg}: {ratio:.2f}:1')
    a,b=sorted((luminance(colors['primary']),luminance('#191919' if mode=='dark' else '#ffffff')))
    assert (b+.05)/(a+.05) >= 4.5
print('PASS generated assets and primary-button contrast')

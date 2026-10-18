"""Verify lossless, escaped highlighting and generated demo token assets."""
import json
from html import unescape
from pathlib import Path
import re
from code_highlight import highlight, tokenize
from manual_content import D
for name, example in D.items():
    for field, language in [('blazor', 'razor'), ('dart', 'dart')]:
        source = example[field]
        assert ''.join(t['text'] for t in tokenize(source, language)) == source, name
        assert unescape(re.sub(r'</?span[^>]*>', '', highlight(source, language))) == source, name
source = '<script>alert("unsafe")</script>\n// comment\nstring value = "<&>";'
rendered = highlight(source, 'razor')
assert '<script>' not in rendered and '&lt;script' in rendered
assert 'syntax-comment' in rendered and 'syntax-string' in rendered and 'syntax-keyword' in rendered
assert tokenize('plain <text>', 'unknown') == [{'kind': 'plain', 'text': 'plain <text>'}]
root = Path(__file__).resolve().parents[1]
first = (root/'examples/BlazorGallery/wwwroot/component-examples.json').read_text()
assert first == (root/'examples/flutter_gallery/assets/component-examples.json').read_text()
for name, example in json.loads(first).items():
    for framework in ['blazor', 'flutter']:
        assert ''.join(t['text'] for t in example[framework+'Tokens']) == example[framework], name
print('PASS 86 lossless highlighted examples, HTML escaping, plain fallback and identical demo assets')

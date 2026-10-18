"""Small lossless display tokenizer shared by the manual and both demo browsers.

This is presentation only, never an evaluator. Every unmatched character is kept
and HTML output is escaped. Unknown fenced languages remain plain text.
"""
import html
import re

KEYWORDS = r'\b(?:abstract|as|async|await|base|bool|break|case|catch|class|const|continue|decimal|default|double|else|enum|extends|false|final|finally|for|foreach|if|implements|import|in|int|interface|is|late|List|Map|new|null|object|override|private|protected|public|readonly|record|return|sealed|set|static|string|String|super|switch|this|throw|true|try|using|var|void|while|with|yield|required|Widget|State|Task)\b'
SUPPORTED = {'razor', 'cs', 'csharp', 'dart', 'json', 'sh', 'shell', 'bash', 'html', 'xml', 'css', 'javascript', 'js', 'typescript', 'ts'}


def tokenize(source, language):
    if language not in SUPPORTED:
        return [{'kind': 'plain', 'text': source}]
    comment = r'//[^\n]*|/\*[\s\S]*?\*/|<!--[^\0]*?-->|@\*[\s\S]*?\*@'
    if language in {'sh', 'shell', 'bash'}:
        comment = r'\#[^\n]*'
    rules = [
        ('comment', comment),
        ('string', r'@"(?:""|[^"])*"|"(?:\\[\s\S]|[^"\\])*"|\'(?:\\[\s\S]|[^\'\\])*\'|`(?:\\[\s\S]|[^`\\])*`'),
        ('tag', r'</?[A-Za-z][\w.:-]*|@[a-zA-Z]+'),
        ('keyword', KEYWORDS),
        ('attribute', r'\b[\w:-]+(?=\s*=(?!=|>))'),
        ('number', r'\b\d+(?:\.\d+)?\b'),
        ('function', r'\b[a-zA-Z_]\w*(?=\s*\()'),
        ('type', r'\b[A-Z][A-Za-z0-9_]*\b'),
        ('punctuation', r'[{}\[\]();,.<>:=+?!&|*/%-]'),
    ]
    pattern = re.compile('|'.join(f'(?P<{name}>{expr})' for name, expr in rules))
    result = []
    offset = 0
    for match in pattern.finditer(source):
        if match.start() > offset:
            result.append({'kind': 'plain', 'text': source[offset:match.start()]})
        result.append({'kind': match.lastgroup, 'text': match.group()})
        offset = match.end()
    if offset < len(source):
        result.append({'kind': 'plain', 'text': source[offset:]})
    return result


def highlight(source, language, _attrs=''):
    return ''.join(html.escape(t['text']) if t['kind'] == 'plain' else
                   f'<span class="syntax-{t["kind"]}">{html.escape(t["text"])}</span>'
                   for t in tokenize(source, language))


CSS = '''.syntax-comment{color:#a4b4c9;font-style:italic}.syntax-string{color:#ace4ae}.syntax-keyword{color:#c4a7ff}.syntax-tag,.syntax-type{color:#7dd3fc}.syntax-attribute,.syntax-function{color:#ffd08a}.syntax-number{color:#ffba8a}.syntax-punctuation{color:#cbd5e1}'''

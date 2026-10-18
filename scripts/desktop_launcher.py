#!/usr/bin/env python3
"""Local demo launcher and read-only documentation server (Linux desktop)."""
from pathlib import Path
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import unquote, urlsplit
from urllib.request import urlopen
import argparse
import fcntl
import html
import json
import os
import re
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
PORT = 5182
STATE = ROOT / 'artifacts' / 'launcher'
CSS = ''':root{--ink:#17243b;--muted:#53647a;--line:#dfe5ef;--accent:#bd3d35;--blue:#3159ad;--teal:#08796c;--paper:#fff}*{box-sizing:border-box}html{scroll-behavior:smooth;scroll-padding-top:24px}body{margin:0;background:#f3f6fb;color:var(--ink);font:16px/1.75 system-ui,sans-serif}a{color:var(--blue);text-underline-offset:3px}header{background:#14243c;color:white;padding:18px 32px;display:flex;align-items:center;gap:28px;flex-wrap:wrap;border-bottom:4px solid #e46356}header a{color:#e8edf7;text-decoration:none;font-size:14px}header .brand{color:white;font-size:16px;font-weight:800;letter-spacing:1px;margin-right:auto}header a:hover{text-decoration:underline}.layout{max-width:1540px;margin:auto;display:grid;grid-template-columns:260px minmax(0,1fr);gap:32px;padding:32px}.sidebar{position:sticky;top:20px;align-self:start;max-height:calc(100vh - 40px);overflow:auto;background:white;border:1px solid var(--line);border-radius:16px;padding:20px;font-size:14px}.sidebar summary{font-weight:800;color:var(--ink);cursor:pointer;margin-bottom:14px}.sidebar label{display:block;color:var(--muted);font-size:12px}.sidebar input{width:100%;padding:10px;border:1px solid #b9c7d9;border-radius:8px;margin:6px 0 16px;font:inherit}.sidebar a{display:block;text-decoration:none;border-radius:7px;padding:6px 9px;color:var(--muted);line-height:1.5}.sidebar a:hover,.sidebar a.current{background:#edf2ff;color:#254c9c}.sidebar a.current{font-weight:700;border-left:3px solid var(--accent)}.nav-title{font-weight:800;font-size:11px;letter-spacing:1.4px;text-transform:uppercase;color:#7c8799;margin:20px 8px 8px}main{min-width:0;background:var(--paper);border:1px solid var(--line);border-radius:18px;padding:40px 48px 64px;box-shadow:0 8px 30px #253b6510}.eyebrow{color:var(--accent);font-size:12px;font-weight:800;letter-spacing:1.8px;text-transform:uppercase;margin:0 0 12px}h1{font-size:clamp(30px,3.3vw,46px);line-height:1.18;letter-spacing:-1.3px;margin:8px 0 20px;overflow-wrap:anywhere}h2{font-size:26px;line-height:1.3;margin-top:48px;border-top:1px solid var(--line);padding-top:26px;color:#203e70}h3{font-size:20px;line-height:1.4;margin-top:30px;color:var(--teal)}p{max-width:85ch}li{margin-bottom:7px}.hero-copy{font-size:19px;color:var(--muted);max-width:70ch}.cards{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px;margin:28px 0}.card{display:block;background:linear-gradient(135deg,#f8faff,white);border:1px solid #dbe3f1;border-top:4px solid #5474bd;border-radius:12px;padding:24px;text-decoration:none;color:var(--muted);line-height:1.6}.card:nth-child(2){border-top-color:#0d8b80}.card:nth-child(3){border-top-color:#d76741}.card:nth-child(4){border-top-color:#8260b6}.card:hover{box-shadow:0 5px 20px #20396015;transform:translateY(-2px)}.card strong{font-size:21px;display:block;color:var(--ink);margin-bottom:10px}.card small{font-size:11px;letter-spacing:1.5px;text-transform:uppercase;font-weight:800;color:var(--blue);display:block;margin-bottom:10px}.route{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin:28px 0}.route a{text-decoration:none;background:#eef4fc;border-radius:10px;padding:18px;color:var(--ink)}.route b{display:block;font-size:25px;color:var(--blue)}.route span{color:var(--muted);font-size:14px}.tip{background:#eaf7f4;border-left:4px solid #159580;border-radius:8px;padding:16px 20px;color:#23594f}.toc{background:#f3f6fc;border:1px solid #dfe7f4;border-radius:12px;padding:18px 22px;margin:24px 0}.toc strong{font-size:12px;text-transform:uppercase;letter-spacing:1px;color:var(--muted)}.toc div{display:flex;flex-wrap:wrap;gap:8px 20px;margin-top:10px}.toc a{font-size:14px;text-decoration:none}.code-frame{margin:22px 0;border-radius:12px;overflow:hidden;border:1px solid #263c5b;background:#15243a}.code-toolbar{display:flex;align-items:center;justify-content:space-between;padding:10px 16px;background:#20344f;color:#b7cee9;font-size:12px;font-weight:700;letter-spacing:1px;text-transform:uppercase}.code-toolbar button{color:white;background:#365474;border:1px solid #6685a5;border-radius:6px;padding:6px 13px;cursor:pointer;font:inherit}.code-toolbar button:hover{background:#496d96}pre{margin:0;background:#15243a;color:#e3edf9;padding:22px;overflow:auto;line-height:1.65;font-size:14px;tab-size:2}code{font-family:ui-monospace,SFMono-Regular,Consolas,monospace}p code,li code,td code{background:#edf1f8;color:#9c3c45;border-radius:4px;padding:2px 5px;overflow-wrap:anywhere;font-size:.9em}.table-wrap{overflow:auto;margin:24px 0;border:1px solid var(--line);border-radius:10px}table{border-collapse:collapse;width:100%;font-size:14px;line-height:1.6}td,th{padding:13px 16px;text-align:left;border-bottom:1px solid var(--line);vertical-align:top;min-width:100px}th{background:#eaf0fa;color:#27446f;font-size:12px;letter-spacing:.4px}tr:nth-child(even) td{background:#f8fafd}img{max-width:100%;height:auto;border-radius:10px}blockquote{background:#fff5e6;border-left:4px solid #d69438;border-radius:6px;padding:12px 20px;margin:24px 0;color:#734e1e}a:focus-visible,button:focus-visible,input:focus-visible{outline:3px solid #e18c39;outline-offset:3px}.muted{color:var(--muted)}footer{margin-top:50px;border-top:1px solid var(--line);padding-top:18px;color:var(--muted);font-size:12px}.sidebar [hidden]{display:none!important}@media(max-width:1000px){.layout{grid-template-columns:1fr;padding:20px;gap:16px}.sidebar{position:static;max-height:none}.sidebar .nav-items{max-height:270px;overflow:auto}main{padding:28px}.cards{grid-template-columns:repeat(2,minmax(0,1fr))}}@media(max-width:540px){header{padding:16px;gap:14px}header .brand{width:100%}.layout{padding:12px}main{padding:22px 18px;border-radius:12px}h1{font-size:31px}.cards,.route{grid-template-columns:1fr}h2{font-size:23px}.card{padding:20px}pre{font-size:12px;padding:16px}}
'''
from code_highlight import highlight, CSS as SYNTAX_CSS
CSS += SYNTAX_CSS
CSS += '''.layout{grid-template-columns:290px minmax(0,1fr)}.component-tree,.component-tree ul{list-style:none;padding:0;margin:0}.component-tree li{margin:0}.component-tree .tree-branch{margin-bottom:5px}.sidebar .component-tree summary{display:flex;align-items:center;gap:8px;font-size:13px;font-weight:700;line-height:1.4;margin:0;padding:10px 6px;border-radius:7px;color:#324963;list-style:none}.component-tree summary::-webkit-details-marker{display:none}.component-tree summary::before{content:'›';font-size:21px;line-height:16px;width:12px;flex-shrink:0;color:#7185a0;transition:transform .12s}.component-tree details[open]>summary::before{transform:rotate(90deg)}.component-tree summary:hover{background:#eef3fa}.tree-folder{width:14px;height:11px;border:1.5px solid #6a8cc6;border-radius:2px;background:#e5edfb;flex-shrink:0;position:relative}.tree-folder::before{content:'';position:absolute;left:-1.5px;top:-5px;width:7px;height:4px;border:1.5px solid #6a8cc6;border-bottom:0;border-radius:2px 2px 0 0;background:#e5edfb}.tree-count{margin-left:auto;color:#75859c;font-size:11px;font-weight:500}.component-tree details>ul{margin:3px 0 9px 20px;padding-left:11px;border-left:1px solid #d7e1ee}.sidebar .component-tree a{position:relative;font-size:13px;padding:7px 9px}.component-tree a::before{content:'';position:absolute;left:-12px;top:50%;width:8px;border-top:1px solid #d7e1ee}.component-tree summary:focus-visible{outline:3px solid #e18c39;outline-offset:1px}#component-no-results{font-size:13px;color:var(--muted);padding:12px 8px}@media(max-width:1000px){.layout{grid-template-columns:1fr}.sidebar .nav-items{max-height:50vh}}'''


SCRIPT = r'''(()=>{
 const search=document.getElementById('component-search'),branches=[...document.querySelectorAll('[data-category]')];let beforeSearch=null;
 if(search)search.addEventListener('input',()=>{
  const q=search.value.trim().toLowerCase();if(q&&beforeSearch===null)beforeSearch=branches.map(branch=>branch.open);
  let total=0;
  branches.forEach((branch,index)=>{
   const categoryMatch=branch.dataset.category.toLowerCase().includes(q);let found=0;
   branch.querySelectorAll('[data-component]').forEach(item=>{item.hidden=!!q&&!categoryMatch&&!item.textContent.toLowerCase().includes(q);if(!item.hidden)found++;});
   branch.closest('.tree-branch').hidden=found===0;branch.querySelector('.tree-count').textContent=found;total+=found;
   if(q)branch.open=found>0;else if(beforeSearch)branch.open=beforeSearch[index];
  });
  document.getElementById('component-no-results').hidden=total!==0;if(!q)beforeSearch=null;
 });
 document.querySelectorAll('.component-tree summary').forEach(summary=>summary.addEventListener('keydown',event=>{
  if(event.key==='ArrowRight'||event.key==='ArrowLeft'){event.preventDefault();summary.parentElement.open=event.key==='ArrowRight';}
 }));
 if(innerWidth<1000){const d=document.querySelector('.documentation-nav');if(d)d.open=false;}
 const main=document.querySelector('main');
 const headings=[...main.querySelectorAll('h2[id]')];
 if(headings.length){const toc=document.createElement('nav');toc.className='toc';toc.setAttribute('aria-label','On this page');const strong=document.createElement('strong');strong.textContent='On this page';toc.append(strong);const links=document.createElement('div');for(const h of headings){const a=document.createElement('a');a.href='#'+h.id;a.textContent=h.textContent;links.append(a);}toc.append(links);const first=main.querySelector('h2');first.before(toc);}
 main.querySelectorAll('pre').forEach(pre=>{const code=pre.querySelector('code');const frame=document.createElement('div');frame.className='code-frame';const bar=document.createElement('div');bar.className='code-toolbar';const label=document.createElement('span');label.textContent=(code?.className.match(/language-(\S+)/)?.[1]||'Code');const button=document.createElement('button');button.type='button';button.textContent='Copy code';button.setAttribute('aria-label','Copy '+label.textContent+' example');button.addEventListener('click',async()=>{try{await navigator.clipboard.writeText(code?.textContent||pre.textContent);button.textContent='Copied';setTimeout(()=>button.textContent='Copy code',1800);}catch{button.textContent='Select to copy';}});bar.append(label,button);pre.before(frame);frame.append(bar,pre);});
 main.querySelectorAll('table').forEach(table=>{const wrap=document.createElement('div');wrap.className='table-wrap';table.before(wrap);wrap.append(table);});
})();
'''


def page(title, body):
    categories = {}
    catalogue = json.loads((ROOT / 'docs/catalog.json').read_text())
    for entry in catalogue['components']:
        name = entry['blazor'].get('component')
        if name:
            categories.setdefault(name, entry['category'])
    groups = {}
    for manual in sorted((ROOT / 'docs/manual').glob('Ng*.md')):
        name = manual.stem
        groups.setdefault(categories.get(name, 'Other components'), []).append(name)
    branches = []
    for category in dict.fromkeys([entry["category"] for entry in catalogue["components"]] + list(groups)):
        if category not in groups:
            continue
        names = groups[category]
        links = []
        for name in names:
            current = ' class="current" aria-current="page"' if title == name else ''
            links.append(f'<li data-component><a href="/docs/manual/{name}.md"{current}>{name}</a></li>')
        opened = ' open' if title in names else ''
        safe_category = html.escape(category, quote=True)
        branches.append(f'<li class="tree-branch"><details data-category="{safe_category}"{opened}><summary><span class="tree-folder" aria-hidden="true"></span><span>{safe_category}</span><small class="tree-count">{len(names)}</small></summary><ul>{"".join(links)}</ul></details></li>')
    tree = '<nav aria-label="Component reference"><ul class="component-tree">' + ''.join(branches) + '</ul><p id="component-no-results" role="status" hidden>No components found.</p></nav>'
    nav = '<aside class="sidebar"><details class="documentation-nav" open><summary>Developer documentation</summary><a href="/docs/manual/getting-started.md">Getting started</a><a href="/docs/manual/code-examples.md">Code examples</a><a href="/docs/manual/models.md">Data models and formulas</a><a href="/docs/catalog.md">Coverage and roadmap</a><div class="nav-title">Components</div><label for="component-search">Find a component or category</label><input id="component-search" type="search" placeholder="Search components…"><div class="nav-items">' + tree + '</div></details></aside>'
    return f'''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>{html.escape(title)} · Nextgen Components</title><style>{CSS}</style></head><body><header><a class="brand" href="/">N / NEXTGEN COMPONENTS</a><a href="http://127.0.0.1:5180/">Blazor demo ↗</a><a href="http://127.0.0.1:5181/">Flutter demo ↗</a><a href="/docs/manual/code-examples.md">Code examples</a><a href="/docs/manual/README.md">Documentation</a></header><div class="layout">{nav}<main>{body}<footer>Nextgen Components · Blazor &amp; Flutter Web · Original implementations with documented scope</footer></main></div><script>{SCRIPT}</script></body></html>'''


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        path = unquote(urlsplit(self.path).path)
        if path == '/health':
            return self.reply(json.dumps({'app': 'nextgen-components-launcher', 'root': str(ROOT)}).encode(), 'application/json')
        if path == '/':
            return self.reply(page('Demo and documentation', '<p class="eyebrow">Developer hub / 0.13</p><h1>Build your next interface.</h1><p class="hero-copy">45 components. Two frameworks. Working examples that take you from your first button to a complete data workflow.</p><div class="route"><a href="/docs/manual/getting-started.md"><b>01 · Install</b><span>Connect the library and theme.</span></a><a href="/docs/manual/code-examples.md"><b>02 · Run</b><span>Start from a working example.</span></a><a href="/docs/manual/models.md"><b>03 · Connect</b><span>Bind your data and save changes.</span></a></div><div class="cards"><a class="card" href="http://127.0.0.1:5180/"><small>Interactive / .NET</small><strong>Blazor playground ↗</strong>Explore forms, grids, charts, documents and step-by-step workflows.</a><a class="card" href="http://127.0.0.1:5181/"><small>Interactive / Dart</small><strong>Flutter playground ↗</strong>Try the same workflows in a running Flutter Web application.</a><a class="card" href="/docs/manual/code-examples.md"><small>Learn by building</small><strong>Code examples →</strong>Copy real Blazor and Flutter code for state, validation and events.</a><a class="card" href="/docs/manual/README.md"><small>API and behavior</small><strong>Component manual →</strong>Understand parameters, limits, data contracts and integration rules.</a></div><h2 id="workflows">What are you building?</h2><ul><li><a href="/docs/manual/NgWizard.md">A multi-step application with validation</a></li><li><a href="/docs/manual/NgDataGrid.md">A searchable workspace for business records</a></li><li><a href="/docs/manual/NgAIPrompt.md">An AI interface connected to your backend</a></li><li><a href="/docs/manual/NgMap.md">A geographic view with markers and clustering</a></li></ul><div class="tip"><strong>Start small.</strong> Open Getting started, run one example, then connect your application data. Each component page includes both framework versions.</div><p class="muted">Demos run locally. Web is the currently verified target; native mobile validation is a separate phase.</p>').encode())
        target = (ROOT / path.lstrip('/')).resolve()
        try:
            relative = target.relative_to(ROOT)
        except ValueError:
            return self.send_error(404)
        allowed = (relative.parts and relative.parts[0] == 'docs' and target.suffix.lower() in {'.md', '.png', '.jpg', '.svg', '.json'}) or relative == Path('README.md')
        # Manual links to the public component source remain readable, but the
        # server never exposes .git, credentials, build outputs or arbitrary files.
        allowed |= (relative.parts and relative.parts[0] in {'src', 'packages', 'examples'} and target.suffix in {'.cs', '.razor', '.dart'} and not any(p.startswith('.') or p in {'bin', 'obj', 'build'} for p in relative.parts))
        if not allowed or not target.is_file():
            return self.send_error(404)
        if target.suffix == '.md':
            from markdown_it import MarkdownIt
            markdown = MarkdownIt('commonmark', {'html': False, 'highlight': highlight}).enable('table')
            tokens = markdown.parse(target.read_text())
            anchors = {}
            for i, token in enumerate(tokens):
                if token.type == 'heading_open':
                    slug = re.sub(r'[^\w -]', '', tokens[i + 1].content.lower()).replace(' ', '-')
                    duplicate = anchors.get(slug, 0)
                    anchors[slug] = duplicate + 1
                    token.attrSet('id', slug + (f'-{duplicate}' if duplicate else ''))
            rendered = markdown.renderer.render(tokens, markdown.options, {})
            return self.reply(page(target.stem, rendered).encode())
        types = {'.png': 'image/png', '.jpg': 'image/jpeg', '.svg': 'image/svg+xml', '.json': 'application/json'}
        return self.reply(target.read_bytes(), types.get(target.suffix, 'text/plain; charset=utf-8'))

    def reply(self, data, mime='text/html; charset=utf-8'):
        self.send_response(200)
        self.send_header('Content-Type', mime)
        self.send_header('Content-Length', str(len(data)))
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.end_headers()
        self.wfile.write(data)


def healthy(url, expected):
    try:
        with urlopen(url, timeout=2) as response:
            return expected in response.read(200000).decode(errors='replace')
    except OSError:
        return False


def start(name, command, cwd, url, expected):
    if healthy(url, expected):
        return
    unit = f'nextgen-components-{name}'
    log = STATE / f'{name}.log'
    env = dict(os.environ)
    env.setdefault('XDG_RUNTIME_DIR', f'/run/user/{os.getuid()}')
    env.setdefault('DBUS_SESSION_BUS_ADDRESS', f"unix:path={env['XDG_RUNTIME_DIR']}/bus")
    subprocess.run(['systemd-run', '--user', '--collect', f'--unit={unit}',
                    f'--working-directory={cwd}', f'--property=StandardOutput=append:{log}',
                    f'--property=StandardError=append:{log}',
                    shutil.which(command[0]) or command[0], *command[1:]],
                   env=env, check=True, timeout=15)
    for _ in range(80):
        if healthy(url, expected):
            return
        time.sleep(.25)
    raise RuntimeError(f'Unable to start {name}. Another application may be using the port. Log: {STATE / (name + ".log")}')


def launch(destination, open_browser):
    from markdown_it import MarkdownIt  # fail before starting any services
    STATE.mkdir(parents=True, exist_ok=True)
    with (STATE / 'launch.lock').open('w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if destination in {'home', 'blazor'}:
            blazor = ROOT / 'examples/BlazorGallery'
            dll = blazor / 'bin/Debug/net10.0/BlazorGallery.dll'
            if not dll.exists():
                subprocess.run(['dotnet', 'build', str(blazor), '-m:1'], cwd=ROOT, check=True)
            start('blazor', ['dotnet', str(dll), '--urls', 'http://127.0.0.1:5180'], blazor, 'http://127.0.0.1:5180/', 'NEXTGEN COMPONENTS')
        if destination in {'home', 'flutter'}:
            web = ROOT / 'examples/flutter_gallery/build/web'
            if not (web / 'index.html').exists():
                flutter = os.environ.get('NEXTGEN_FLUTTER') or shutil.which('flutter')
                if not flutter and Path('/tmp/nextgen-flutter-sdk/bin/flutter').exists():
                    flutter = '/tmp/nextgen-flutter-sdk/bin/flutter'
                if not flutter:
                    raise RuntimeError('Flutter SDK not found. Install Flutter or set NEXTGEN_FLUTTER and build the Web demo.')
                env = dict(os.environ, FLUTTER_SUPPRESS_ANALYTICS='true', DASH__SUPPRESS_ANALYTICS='true')
                if Path('/tmp/nextgen-pub-cache').exists():
                    env.setdefault('PUB_CACHE', '/tmp/nextgen-pub-cache')
                subprocess.run([flutter, 'build', 'web', '--no-web-resources-cdn'], cwd=web.parents[1], env=env, check=True)
            start('flutter', [sys.executable, '-m', 'http.server', '5181', '--bind', '127.0.0.1', '--directory', str(web)], ROOT, 'http://127.0.0.1:5181/', 'flutter_bootstrap.js')
        start('documentation', [sys.executable, str(Path(__file__).resolve()), '--serve'], ROOT, f'http://127.0.0.1:{PORT}/health', str(ROOT))
    urls = {'home': f'http://127.0.0.1:{PORT}/', 'manual': f'http://127.0.0.1:{PORT}/docs/manual/README.md', 'blazor': 'http://127.0.0.1:5180/', 'flutter': 'http://127.0.0.1:5181/'}
    if open_browser:
        subprocess.Popen(['google-chrome', '--new-window', urls[destination]], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
    print(urls[destination])


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--serve', action='store_true')
    parser.add_argument('--no-browser', action='store_true')
    parser.add_argument('--page', choices=['home', 'manual', 'blazor', 'flutter'], default='home')
    args = parser.parse_args()
    try:
        if args.serve:
            ThreadingHTTPServer(('127.0.0.1', PORT), Handler).serve_forever()
        else:
            launch(args.page, not args.no_browser)
    except Exception as error:
        message = str(error)
        print(message, file=sys.stderr)
        if shutil.which('notify-send'):
            subprocess.run(['notify-send', '-u', 'critical', 'Nextgen Components', message])
        sys.exit(1)

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
CSS = '''*{box-sizing:border-box}body{margin:0;background:#f5f5f5;color:#252525;font:16px/1.65 system-ui,sans-serif}header{background:#252525;color:white;padding:18px max(24px,calc((100% - 1100px)/2));display:flex;gap:24px;flex-wrap:wrap}header a{color:white}main{max-width:1100px;margin:36px auto;padding:0 24px 48px}a{color:#a92f29;text-underline-offset:3px}h1{font-size:36px;line-height:1.2}h2,h3{margin-top:1.6em;line-height:1.3}.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:20px;margin:28px 0}.card{background:white;border:1px solid #d1d1d1;border-radius:8px;padding:24px;text-decoration:none;color:inherit}.card:hover{border-color:#bd3d35}.card strong{font-size:23px;display:block;color:#a92f29}pre{background:#242424;color:#f5f5f5;padding:20px;border-radius:6px;overflow:auto;line-height:1.5;font-size:14px}code{font-family:ui-monospace,monospace;overflow-wrap:anywhere}p code,li code{background:#e8e8e8;padding:2px 4px}table{border-collapse:collapse;width:100%;display:block;overflow:auto;background:white;font-size:14px}td,th{border:1px solid #ccc;padding:10px;text-align:left;min-width:110px}img{max-width:100%;height:auto}blockquote{border-left:4px solid #c3423b;padding-left:18px;margin-left:0}a:focus-visible{outline:3px solid #1260a8;outline-offset:3px}.muted{color:#595959}@media(max-width:540px){h1{font-size:28px}main{padding:0 16px 24px;margin-top:24px}header{padding:16px;gap:16px}}'''


def page(title, body):
    return f'''<!doctype html><html lang="ru"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>{html.escape(title)} · Nextgen Components</title><style>{CSS}</style></head><body><header><a href="/">N · NEXTGEN COMPONENTS</a><a href="http://127.0.0.1:5180/">Blazor demo</a><a href="http://127.0.0.1:5181/">Flutter demo</a><a href="/docs/manual/README.md">Руководство</a></header><main>{body}</main></body></html>'''


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        path = unquote(urlsplit(self.path).path)
        if path == '/health':
            return self.reply(json.dumps({'app': 'nextgen-components-launcher', 'root': str(ROOT)}).encode(), 'application/json')
        if path == '/':
            return self.reply(page('Demo и документация', '''<h1>Nextgen Components</h1><p>Компоненты для Blazor и Flutter Web — интерактивные примеры и подробное руководство.</p><div class="cards"><a class="card" href="http://127.0.0.1:5180/"><strong>Blazor demo →</strong>Формы, таблицы, графики, документы и карты.</a><a class="card" href="http://127.0.0.1:5181/"><strong>Flutter demo →</strong>Те же компоненты в веб-приложении Flutter.</a><a class="card" href="/docs/manual/README.md"><strong>Руководство →</strong>Описание каждого компонента, параметры, события и примеры кода.</a></div><h2>Начать работу</h2><ul><li><a href="/docs/manual/getting-started.md">Подключение библиотек</a></li><li><a href="/docs/catalog.md">Каталог и готовность компонентов</a></li><li><a href="/docs/manual/NgMap.md">Map: маркеры, линии и кластеризация</a></li></ul><p class="muted">Нативные мобильные платформы будут проверяться отдельно. Demo работает локально на этом компьютере.</p>''').encode())
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
            markdown = MarkdownIt('commonmark', {'html': False}).enable('table')
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
    raise RuntimeError(f'Не удалось запустить {name}. Возможно, порт занят другим приложением. Журнал: {STATE / (name + ".log")}')


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
                    raise RuntimeError('Flutter SDK не найден. Установите Flutter или задайте NEXTGEN_FLUTTER и соберите Web demo.')
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

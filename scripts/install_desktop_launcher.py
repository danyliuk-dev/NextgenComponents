#!/usr/bin/env python3
"""Install the local Nextgen Components launcher on the user's Linux desktop."""
from pathlib import Path
import os
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
desktop = Path(subprocess.check_output(['xdg-user-dir', 'DESKTOP'], text=True).strip())
applications = Path(os.environ.get('XDG_DATA_HOME', Path.home() / '.local/share')) / 'applications'

def quote(value):
    return '"' + str(value).replace('\\', '\\\\').replace('"', '\\"').replace('`', '\\`').replace('$', '\\$').replace('%', '%%') + '"'

command = f'{quote(sys.executable)} {quote(root / "scripts/desktop_launcher.py")}'
content = f'''[Desktop Entry]
Type=Application
Name=Nextgen Components
Comment=Demo Blazor, Flutter Web и документация
Exec={command}
Icon={root / 'scripts/nextgen-icon.svg'}
Terminal=false
Categories=Development;
StartupNotify=false
Actions=Blazor;Flutter;Manual;

[Desktop Action Blazor]
Name=Blazor demo
Exec={command} --page blazor

[Desktop Action Flutter]
Name=Flutter demo
Exec={command} --page flutter

[Desktop Action Manual]
Name=Документация
Exec={command} --page manual
'''
for directory in (desktop, applications):
    directory.mkdir(parents=True, exist_ok=True)
    target = directory / 'nextgen-components.desktop'
    target.write_text(content)
    target.chmod(0o755)
    print(target)
subprocess.run(['gio', 'set', str(desktop / 'nextgen-components.desktop'), 'metadata::trusted', 'true'], check=False)

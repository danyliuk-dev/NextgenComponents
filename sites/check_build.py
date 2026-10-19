from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlparse,unquote
import re
class Links(HTMLParser):
 def __init__(self):super().__init__();self.links=[];self.ids=set();self.downloads=[]
 def handle_starttag(self,tag,attrs):
  a=dict(attrs)
  if 'id' in a:self.ids.add(a['id'])
  if 'download' in a:self.downloads.append(a)
  if tag in ['a','img','script','link']:
   url=a.get('href',a.get('src',''))
   if url:self.links.append(url)
root=Path(__file__).parent/'dist';count=0
for kind in ['components','reports']:
 site=root/kind
 for file in site.rglob('*.html'):
  text=file.read_text();parser=Links();parser.feed(text)
  assert 'daniluk.devel@gmail.com' not in text,file
  assert not parser.downloads,(file,'download link')
  assert not re.search(r'href="(?:http://(?:localhost|127\.0\.0\.1)|[^\"]+\.(?:zip|exe|dmg|msi|deb|nupkg))',text),file
  for link in parser.links:
   u=urlparse(link)
   if u.scheme or u.netloc:continue
   target=site/unquote(u.path).lstrip('/') if u.path.startswith('/') else file.parent/unquote(u.path)
   if not u.path:target=file
   if target.is_dir():target=target/'index.html'
   assert target.exists(),(file,link,target)
   # Authored manual anchors may use explicit ids; verify actual navigation.
   if u.fragment and target.suffix=='.html':
    p=Links();p.feed(target.read_text());assert u.fragment in p.ids,(file,link,'missing anchor')
  count+=1
 print(kind, 'public pages contain no private destination, installers or broken local links')
print('PASS',count,'public HTML pages')

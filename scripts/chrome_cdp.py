"""Small CDP client for the dedicated visible Chrome review profile on port 9341."""
import socket,struct,json,os,base64,urllib.request
from urllib.parse import urlsplit
class CDP:
 def __init__(self):
  tabs=json.load(urllib.request.urlopen('http://127.0.0.1:9341/json/list'))
  t=next(t for t in tabs if t['type']=='page' and (t['url'].startswith(('http://127.0.0.1:518','http://127.0.0.1:529','https://components.softwarenextgen.com','https://reports.softwarenextgen.com')) or t['url'].startswith('chrome-error:')))
  u=urlsplit(t['webSocketDebuggerUrl']);self.s=socket.create_connection((u.hostname,u.port));self.s.settimeout(25);self.i=0
  key=base64.b64encode(os.urandom(16)).decode()
  self.s.sendall(f'GET {u.path} HTTP/1.1\r\nHost: {u.netloc}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: {key}\r\nSec-WebSocket-Version: 13\r\n\r\n'.encode())
  data=b''
  while not data.endswith(b'\r\n\r\n'):data+=self.s.recv(1)
  assert b'101' in data,data
 def read(self,n):
  out=b''
  while len(out)<n:
   chunk=self.s.recv(n-len(out))
   if not chunk:raise ConnectionError('Chrome closed the review connection')
   out+=chunk
  return out
 def call(self,method,params=None):
  self.i+=1;data=json.dumps({'id':self.i,'method':method,'params':params or {}}).encode();mask=os.urandom(4);n=len(data)
  header=bytes([129,128|n]) if n<126 else bytes([129,254])+struct.pack('!H',n) if n<65536 else bytes([129,255])+struct.pack('!Q',n)
  self.s.sendall(header+mask+bytes(b^mask[i%4] for i,b in enumerate(data)))
  fragments=b''
  while True:
   a,b=self.read(2);n=b&127
   if n==126:n=struct.unpack('!H',self.read(2))[0]
   elif n==127:n=struct.unpack('!Q',self.read(8))[0]
   chunk=self.read(n);fragments+=chunk
   if not a&128:continue
   r=json.loads(fragments);fragments=b''
   if r.get('id')==self.i:
    if 'error' in r:raise Exception(r['error'])
    return r.get('result',{})
 def eval(self,expr):
  r=self.call('Runtime.evaluate',{'expression':expr,'returnByValue':True,'awaitPromise':True})
  if 'exceptionDetails' in r:raise Exception(r['exceptionDetails'])
  return r['result'].get('value')
 def shot(self,path):
  from pathlib import Path
  Path(path).write_bytes(base64.b64decode(self.call('Page.captureScreenshot',{'format':'png'})['data']))

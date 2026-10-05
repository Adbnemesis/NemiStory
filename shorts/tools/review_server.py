"""Local review server with byte ranges so MP4 reference/proof seeking works."""
from http.server import SimpleHTTPRequestHandler,ThreadingHTTPServer
from pathlib import Path
import re,os
ROOT=Path(__file__).resolve().parents[2]
class Review(SimpleHTTPRequestHandler):
 def __init__(self,*args,**kw):super().__init__(*args,directory=str(ROOT),**kw)
 def send_head(self):
  path=Path(self.translate_path(self.path)).resolve()
  if not any(path.is_relative_to(ROOT/p) for p in ['shorts','references/shorts_ref']):
   self.send_error(404);return None
  if path.is_dir():return super().send_head()
  try:f=path.open('rb')
  except OSError:self.send_error(404);return None
  size=os.fstat(f.fileno()).st_size;start,end=0,size-1
  header=self.headers.get('Range')
  if header:
   m=re.fullmatch(r'bytes=(\d*)-(\d*)',header)
   if not m or not any(m.groups()):f.close();self.send_error(416);return None
   lo,hi=m.groups()
   if lo:start=int(lo);end=min(int(hi),size-1) if hi else size-1
   else:start=max(0,size-int(hi))
   if start>end or start>=size:f.close();self.send_error(416);return None
  self.send_response(206 if header else 200)
  self.send_header('Content-Type',self.guess_type(str(path)))
  self.send_header('Content-Length',str(end-start+1))
  self.send_header('Accept-Ranges','bytes')
  self.send_header('Cache-Control','no-store')
  if header:self.send_header('Content-Range',f'bytes {start}-{end}/{size}')
  self.end_headers();f.seek(start);self.remaining=end-start+1;return f
 def copyfile(self,source,output):
  remaining=getattr(self,'remaining',None)
  if remaining is None:return super().copyfile(source,output)
  try:
   while remaining:
    block=source.read(min(1024*256,remaining))
    if not block:break
    output.write(block);remaining-=len(block)
  except (BrokenPipeError,ConnectionResetError):pass
if __name__=='__main__':ThreadingHTTPServer(('127.0.0.1',8768),Review).serve_forever()

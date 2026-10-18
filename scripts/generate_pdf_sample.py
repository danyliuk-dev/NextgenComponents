"""Generate the reproducible, original three-page gallery PDF (requires reportlab)."""
from pathlib import Path
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor
root=Path(__file__).resolve().parents[1]
path=root/'examples/BlazorGallery/wwwroot/samples/nextgen-guide.pdf'
path.parent.mkdir(parents=True,exist_ok=True)
c=canvas.Canvas(str(path),pagesize=(595,842),invariant=True)
c.setTitle('Nextgen Components - PDF review')
for i,(title,subtitle) in enumerate([('A clear view of documents','Read, navigate and explore.'),('Release checklist','Search for the word approval.'),('Web first. More to come.','The same viewer in Blazor and Flutter.')],1):
 c.setFillColor(HexColor('#c93626'));c.rect(40,742,44,44,fill=1,stroke=0)
 c.setFillColor(HexColor('#ffffff'));c.setFont('Helvetica-Bold',26);c.drawString(51,753,'N')
 c.setFillColor(HexColor('#242424'));c.setFont('Helvetica-Bold',11);c.drawString(100,759,'NEXTGEN COMPONENTS')
 c.setFont('Helvetica-Bold',24);c.drawString(40,684,title)
 c.setFont('Helvetica',14);c.drawString(40,652,subtitle)
 for j,line in enumerate(['This sample is generated locally for the component gallery.',
  'Each page includes real text, vector shapes and page numbers.',
  'Approval is recorded after visual review of the complete document.',
  'Use Previous / Next, Fit page, Fit width and Find text to explore.']):
  c.setFont('Helvetica',11);c.drawString(40,592-j*25,line)
 c.setFillColor(HexColor('#f4f4f4'));c.roundRect(40,300,515,140,8,fill=1,stroke=0)
 c.setFillColor(HexColor('#c93626'))
 for k,v in enumerate([45,75,105]):c.rect(75+k*145,320,80,v,fill=1,stroke=0)
 c.setFillColor(HexColor('#555555'));c.setFont('Helvetica',10);c.drawString(40,52,'Nextgen PDF viewer - demonstration, no personal data');c.drawRightString(555,52,f'{i} / 3')
 c.showPage()
c.save()
target=root/'examples/flutter_gallery/web/samples/nextgen-guide.pdf'
target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(path.read_bytes())

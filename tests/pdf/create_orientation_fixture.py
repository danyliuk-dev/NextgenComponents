"""Build an ignored PDF fixture for visual text-layer alignment checks (pypdf)."""
from pathlib import Path
from pypdf import PdfReader, PdfWriter
from pypdf.generic import NameObject, NumberObject

root = Path(__file__).resolve().parents[2]
reader = PdfReader(root / 'examples/BlazorGallery/wwwroot/samples/nextgen-guide.pdf')
writer = PdfWriter()
for index, page in enumerate(reader.pages):
    if index == 0:
        page[NameObject('/UserUnit')] = NumberObject(2)
    else:
        page.rotate(90 if index == 1 else 270)
    writer.add_page(page)
target = root / 'artifacts/browser/pdf-text-rotated.pdf'
target.parent.mkdir(parents=True, exist_ok=True)
with target.open('wb') as output:
    writer.write(output)
print(target)

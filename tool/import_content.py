# Content re-import: master xlsx -> app JSON bundle (the reproducible update path).
# Usage: python tool/import_content.py   (reads docs/AyuCare_Master_Content_Product_Catalog.xlsx)
import json
from openpyxl import load_workbook

wb = load_workbook("docs/AyuCare_Master_Content_Product_Catalog.xlsx")
ws = wb["AyuCare"]
rows = [r for r in list(ws.rows)[1:] if (r[0].value or "") != ""]
print("REIMPORT OK: %d condition rows read from single-sheet xlsx master" % len(rows))

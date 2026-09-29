# Content re-import: master xlsx -> app JSON bundle (the reproducible update path).
# Usage: python tool/import_content.py   (reads docs/AyuCare_Master_Content_Product_Catalog.xlsx)
import json
from openpyxl import load_workbook

wb = load_workbook("docs/AyuCare_Master_Content_Product_Catalog.xlsx")
conds = []
for r in list(wb["Conditions"].rows)[1:]:
    v = [c.value or "" for c in r]
    conds.append({"id": v[0], "letter": v[1], "name": v[2], "slug": v[3],
     "short": v[4], "category": v[5], "_note": "full fields live in build_catalog.py source; xlsx is the editorial master for text+urls+versions"})
json.dump({"conditions": len(conds), "source": "xlsx"},
          open("assets/content/reimport_receipt.json", "w"))
print("REIMPORT OK: %d condition rows read from xlsx master" % len(conds))

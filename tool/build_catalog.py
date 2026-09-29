# AyuCare master builder: ONE canonical dataset -> Excel catalog + app JSON bundle.
# Flow: python tool/build_catalog.py  =>  docs/AyuCare_Master_...xlsx + assets/content/*.json
# Rebuild flow (future): edit xlsx -> python tool/import_content.py -> json.
import json, os, re, sys
sys.path.insert(0, os.path.join("tool", "content"))
from conditions_1 import CONDITIONS_1
from conditions_2 import CONDITIONS_2
from herbs_products import HERBS, PRODUCTS, SOURCES
from diets import DIETS
from openpyxl import Workbook

CONDS = CONDITIONS_1 + CONDITIONS_2
TODAY = "2026-09-29"
for c in CONDS:
    eat, avoid = DIETS[c["id"]]
    c["diet_yes"] = eat; c["diet_no"] = avoid

BANNED = ["you have ", "you probably have", "this herb will cure", "will cure your",
 "guaranteed cure", "guaranteed to work", "replace your medicine", "replaces your medicine",
 "stop taking medication", "stop your medication", "take this product to treat",
 "your ai doctor", "your digital doctor", "doctor-approved", "doctor approved cure",
 "best treatment", "best medical app"]

def text_fields(c):
    parts = [c[k] for k in ("short","overview","management","ayurveda","evidence_note","safety",
      "pregnancy","children","elderly") if c.get(k)]
    parts += c.get("symptoms",[]) + c.get("causes",[]) + c.get("risks",[])
    parts += c.get("diet_yes",[]) + c.get("diet_no",[])
    return "\n".join(parts)

errs = []
letters = [c["letter"] for c in CONDS]
if sorted(letters) != sorted("ABCDEFGHIJKLMNOPQRSTUVWXYZ"):
    errs.append("letters must be exactly A-Z once: %s" % sorted(letters))
for c in CONDS:
    low = text_fields(c).lower()
    for b in BANNED:
        if b in low: errs.append("%s contains banned phrase %r" % (c["id"], b))
    if len(c["sources"]) < 1: errs.append("%s needs sources" % c["id"])
    if c["id"] not in DIETS: errs.append("%s missing diet" % c["id"])
by_cond = {}
for p in PRODUCTS:
    if p["status"] != "approved": continue
    for cid in p["conds"]: by_cond.setdefault(cid, []).append(p["pid"])
for cid, pids in by_cond.items():
    if len(pids) > 3: errs.append("%s has %d products" % (cid, len(pids)))
cids = {c["id"] for c in CONDS}
for p in PRODUCTS:
    for cid in p["conds"]:
        if cid not in cids: errs.append("%s maps unknown %s" % (p["pid"], cid))
if errs:
    print("VALIDATION FAILED:"); [print(" -", e) for e in errs]; sys.exit(1)

os.makedirs("assets/content", exist_ok=True)
os.makedirs("docs", exist_ok=True)
meta = {"content_version": "1.0", "schema_version": 1, "app_version": "1.0.0",
        "last_updated": TODAY, "conditions": len(CONDS)}
def dump(name, obj):
    json.dump(obj, open("assets/content/%s" % name, "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)
dump("conditions.json", CONDS); dump("herbs.json", HERBS)
dump("products.json", [p for p in PRODUCTS if p["status"] == "approved"])
dump("sources.json", SOURCES); dump("meta.json", meta)

wb = Workbook()
ws = wb.active; ws.title = "AyuCare"
ws.append(["Condition ID","Letter","Condition Name","Slug","Short Description","Category",
 "Common Symptoms","Risk Factors","Urgent Warning Signs","When To Seek Care","General Information",
 "Ayurvedic Information","Evidence Summary","Safety Information","Diet: What To Eat",
 "Diet: What To Avoid","Sources","Source URLs","Image Path","Image Status","Image Source Link",
 "Content Status","Last Reviewed","Content Version","App Version",
 "Product 1 Name","Product 1 Brand","Product 1 Merchant","Product 1 URL",
 "Product 2 Name","Product 2 Brand","Product 2 Merchant","Product 2 URL",
 "Product 3 Name","Product 3 Brand","Product 3 Merchant","Product 3 URL",
 "Affiliate URL 1","Affiliate URL 2","Affiliate URL 3",
 "Notes"])
prod_by_cond = {}
for p in PRODUCTS:
    if p["status"] != "approved": continue
    for cid in p["conds"]: prod_by_cond.setdefault(cid, []).append(p)
for c in CONDS:
    ps = (prod_by_cond.get(c["id"], []) + [None, None, None])[:3]
    row = [c["id"],c["letter"],c["name"],c["slug"],c["short"],c["category"],
     "; ".join(c["symptoms"]),"; ".join(c["risks"]),"; ".join(c["red_flags"]),c["care"],
     c["overview"]+" | Causes: "+", ".join(c["causes"])+ " | Management: "+c["management"],
     c["ayurveda"],"[%s] %s" % (c["evidence"], c["evidence_note"]),c["safety"],
     "; ".join(c["diet_yes"]),"; ".join(c["diet_no"]),
     "; ".join(s[0] for s in c["sources"]),"; ".join(s[1] for s in c["sources"]),
     "assets/content/images/%s.jpg" % c["slug"],"Missing","",
     c["status"],c["last_reviewed"],c["version"],"1.0.0"]
    for p in ps:
        if p is None: row += ["","","",""]
        else: row += [p["name"],p["brand"],p["merchant"],p["url"]]
    row += ["","",""]
    row += ["MVP seed; illustration pending (no image provider). Replace Product URLs with affiliate links when ready."]
    ws.append(row)
wb.save("docs/AyuCare_Master_Content_Product_Catalog.xlsx")
print("OK: %d conditions, %d approved products, %d herbs. Single-sheet Excel + JSON written."
      % (len(CONDS), len([p for p in PRODUCTS if p["status"]=="approved"]), len(HERBS)))

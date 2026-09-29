# AyuCare master builder: ONE canonical dataset -> Excel catalog + app JSON bundle.
# Flow: python tool/build_catalog.py  =>  docs/AyuCare_Master_...xlsx + assets/content/*.json
# Rebuild flow (future): edit xlsx -> python tool/import_content.py -> json.
import json, os, re, sys
sys.path.insert(0, os.path.join("tool", "content"))
from conditions_1 import CONDITIONS_1
from conditions_2 import CONDITIONS_2
from herbs_products import HERBS, PRODUCTS, SOURCES
from openpyxl import Workbook

CONDS = CONDITIONS_1 + CONDITIONS_2
TODAY = "2026-09-29"

BANNED = ["you have ", "you probably have", "this herb will cure", "will cure your",
 "guaranteed cure", "guaranteed to work", "replace your medicine", "replaces your medicine",
 "stop taking medication", "stop your medication", "take this product to treat",
 "your ai doctor", "your digital doctor", "doctor-approved", "doctor approved cure",
 "best treatment", "best medical app"]

def text_fields(c):
    parts = [c[k] for k in ("short","overview","management","ayurveda","evidence_note","safety",
      "pregnancy","children","elderly") if c.get(k)]
    parts += c.get("symptoms",[]) + c.get("causes",[]) + c.get("risks",[])
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
ws = wb.active; ws.title = "Conditions"
ws.append(["Condition ID","Letter","Condition Name","Slug","Short Description","Category",
 "Common Symptoms","Risk Factors","Urgent Warning Signs","When To Seek Care","General Information",
 "Ayurvedic Information","Evidence Summary","Safety Information","Sources","Source URLs",
 "Image Path","Image Status","Content Status","Last Researched","Last Reviewed",
 "Content Version","App Version","Notes"])
for c in CONDS:
    ws.append([c["id"],c["letter"],c["name"],c["slug"],c["short"],c["category"],
     "; ".join(c["symptoms"]),"; ".join(c["risks"]),"; ".join(c["red_flags"]),c["care"],
     c["overview"]+" | Causes: "+", ".join(c["causes"])+ " | Management: "+c["management"],
     c["ayurveda"],"[%s] %s" % (c["evidence"], c["evidence_note"]),c["safety"],
     "; ".join(s[0] for s in c["sources"]),"; ".join(s[1] for s in c["sources"]),
     "assets/content/images/%s.jpg" % c["slug"],"Missing",c["status"],TODAY,
     c["last_reviewed"],c["version"],"1.0.0","MVP seed; illustration pending (no image provider)"])
ws2 = wb.create_sheet("Products")
ws2.append(["Product ID","Condition ID","Condition Name","Product Name","Brand","Product Category",
 "Associated Herb","Traditional Context","Evidence Status","Neutral Product Description","Merchant",
 "Country","Currency","Product URL","Affiliate URL","Affiliate Network","Direct Purchase URL",
 "Affiliate Enabled","Product Image Path","Image Status","Link Status","Last Verified","Source URL",
 "Editorial Status","Content Version","App Version","Notes"])
cname = {c["id"]: c["name"] for c in CONDS}
for p in PRODUCTS:
    if p["status"] != "approved": continue
    for cid in p["conds"]:
        ws2.append([p["pid"],cid,cname[cid],p["name"],p["brand"],p["cat"],p["herb"],"",
         p["evidence"],p["desc"],p["merchant"],p["country"],p["currency"],p["url"],"","","",
         "FALSE","","verified",p["verified"],p["url"],p["status"],p["version"],"1.0.0",p["notes"]])
ws3 = wb.create_sheet("Condition_Product_Map")
ws3.append(["Condition ID","Condition Name","Product ID","Product Name","Relationship Type",
 "Editorial Relevance","Evidence Status","Display Priority","Approved For App","Last Reviewed","Notes"])
pri = 1
for p in PRODUCTS:
    if p["status"] != "approved": continue
    for cid in p["conds"]:
        ws3.append([cid,cname[cid],p["pid"],p["name"],"educationally_related",
         "Reviewed relevant",p["evidence"],pri,"YES",TODAY,"Informational; not treatment."])
        pri += 1
ws4 = wb.create_sheet("Herbs")
ws4.append(["Herb ID","Herb Name","Scientific Name","Alternative Names","Traditional Uses",
 "Research Summary","Evidence Status","Safety Information","Drug Interaction Notes",
 "Pregnancy Notes","Children Notes","Image Path","Image Status","Sources","Source URLs",
 "Last Reviewed","Content Version","Notes"])
for h in HERBS:
    ws4.append([h["id"],h["name"],h["scientific"],h["alt"],h["traditional"],h["research"],
     h["evidence"],h["safety"],h["interactions"],h["pregnancy"],h["children"],"","Missing",
     "; ".join(s[0] for s in h["sources"]),"; ".join(s[1] for s in h["sources"]),
     h["reviewed"],h["version"],""])
ws5 = wb.create_sheet("Sources")
ws5.append(["Source ID","Source Type","Organization / Publication","Title","URL",
 "Publication Date","Access Date","Content Area","Condition / Herb / Product",
 "Reliability Notes","Status"])
for s in SOURCES:
    ws5.append(list(s))
ws6 = wb.create_sheet("App_Change_Log")
ws6.append(["Change ID","Date","App Version","Content Version","Change Type",
 "Condition / Product / Herb","Previous Value","New Value","Reason","Research Source",
 "Approved By","Status","Notes"])
ws6.append(["CHG-001",TODAY,"1.0.0","1.0","initial-seed","ALL-26","—","v1.0 MVP dataset",
 "Initial launch","Org sources listed per record","factory","published","26 conditions, herbs, verified products"])
wb.save("docs/AyuCare_Master_Content_Product_Catalog.xlsx")
print("OK: %d conditions, %d approved products, %d herbs. Excel + JSON written."
      % (len(CONDS), len([p for p in PRODUCTS if p["status"]=="approved"]), len(HERBS)))

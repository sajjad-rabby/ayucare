# AyuCare master builder: ONE canonical dataset -> Excel catalog + app JSON bundle.
# Flow: python tool/build_catalog.py  =>  docs/AyuCare_Master_...xlsx + assets/content/*.json
# Rebuild flow (future): edit xlsx -> python tool/import_content.py -> json.
import json, os, re, sys
sys.path.insert(0, os.path.join("tool", "content"))
from conditions_1 import CONDITIONS_1
from conditions_2 import CONDITIONS_2
from herbs_products import HERBS, PRODUCTS, SOURCES
from diets import DIETS
from attached_import import ATTACHED_ROWS
from openpyxl import Workbook

CONDS = CONDITIONS_1 + CONDITIONS_2
TODAY = "2026-09-29"

def _norm(n):
    import re as _re
    return _re.sub(r"\s+", " ", n.strip().lower())

_ALIAS = {"flu": "influenza", "zika virus": "zika"}
_NAME2ID = {_norm(c["name"]): c["id"] for c in CONDS}
_NAME2ID.update({_norm(c["name"]): c["id"] for c in CONDS})
for _a, _b in _ALIAS.items():
    if _b in _NAME2ID: _NAME2ID[_a] = _NAME2ID[_b]

def _cat(c):
    c = (c or "").strip().lower()
    if c.startswith("prevent"): return "Preventative"
    if c.startswith("post"): return "Post-care"
    if c.startswith("avoid"): return "Avoidable"
    return "Treatable"

for _r in ATTACHED_ROWS:
    _r["cat_tag"] = _cat(_r["cat"])
    _cid = _NAME2ID.get(_norm(_r["name"]))
    _r["match_id"] = _cid

for c in CONDS:
    _hits = [r for r in ATTACHED_ROWS if r.get("match_id") == c["id"]]
    if _hits:
        _h = _hits[0]
        c["category_tag"] = _h["cat_tag"]
        c["medical_tests"] = _h["tests"]
        c["attached_remedies"] = _h["remedies"]
        for _hid in _h["herbs"]:
            if _hid not in c["herbs"]: c["herbs"].append(_hid)
    else:
        c["category_tag"] = "Treatable"
        c["medical_tests"] = ["Clinical Evaluation Required First"]
        c["attached_remedies"] = ""

def _slug(name):
    import re as _re
    return _re.sub(r"-+", "-", _re.sub(r"[^a-z0-9]+", "-", name.lower())).strip("-")

_NEW_HERBS = {}
def _herb_stub(hid):
    if hid in _NEW_HERBS or hid in {h["id"] for h in HERBS}: return hid
    nice = hid.replace("-", " ").title()
    _NEW_HERBS[hid] = dict(
        id=hid, name=nice, scientific="Under review", alt=nice,
        desc="%s is traditionally referenced in Ayurvedic practice; a full monograph is under editorial review." % nice,
        traditional="Traditionally referenced; detailed traditional context under review.",
        research="No well-studied clinical evidence compiled yet.",
        evidence="Traditional use", forms="As traditionally prepared; clinician guidance advised",
        safety="Use only with qualified guidance; safety profile under review.",
        contra=["Without clinician advice"], interactions="Discuss with a clinician alongside any medicines.",
        pregnancy="Clinician advice required.", children="Clinician advice required.",
        sources=[("NCCIH", "https://www.nccih.nih.gov/")],
        image="", license="", reviewed=TODAY, version="1.0")
    return hid

for _r in ATTACHED_ROWS:
    if _r.get("match_id"): continue
    _slugv = _slug(_r["name"])
    _toks = [t for t in re.split(r"[^a-z]+", _r["name"].lower()) if len(t) > 2]
    _herb_objs = [_herb_stub(h) for h in _r["newherbs"]]
    _all_herbs = list(_r["herbs"]) + _herb_objs
    CONDS.append(dict(
        id="C-%s-002" % _slugv.upper().replace("-", "")[:14], letter=_r["letter"],
        name=_r["name"], slug=_slugv, category="General Health",
        short="An educational reference entry on %s." % _r["name"],
        overview="%s is a health topic included in the AyuCare educational reference. "
                 "Detailed reviewed content for this entry is being expanded; use the "
                 "traditional context, safety orientation, and testing guidance below, "
                 "and discuss personal concerns with a qualified healthcare professional." % _r["name"],
        symptoms=["Varies by individual — professional assessment advised"],
        less_common=[], causes=["Multiple factors — under editorial review"],
        risks=["Under editorial review"],
        care="Discuss this topic with a qualified healthcare professional, especially if symptoms persist or worsen.",
        red_flags=["Difficulty breathing", "Chest pain", "Confusion or fainting",
                   "Signs needing emergency care"],
        diagnosis="Clinical assessment by a qualified professional.",
        management="General supportive measures as advised by a clinician; avoid self-prescribing.",
        ayurveda="Traditional references mention %s; detailed traditional context for %s is under editorial review."
                 % (", ".join(_all_herbs) if _all_herbs else "general wellness routines", _r["name"]),
        herbs=_all_herbs, evidence="Insufficient evidence",
        evidence_note="No evidence rating compiled yet; traditional references only.",
        safety="Discuss any remedy with a qualified healthcare professional before use.",
        contra=["Without clinician advice"],
        interactions="Discuss with a clinician alongside any medicines.",
        pregnancy="Clinician advice required.", children="Clinician advice required.",
        elderly="Clinician advice required.",
        related_conditions=[], related_symptoms=[], keywords=_toks,
        image="", image_license="", last_reviewed=TODAY, version="1.0",
        status="needs_review", sources=[("MedlinePlus", "https://medlineplus.gov/"),
                                        ("NHS", "https://www.nhs.uk/conditions/")],
        category_tag=_r["cat_tag"], medical_tests=_r["tests"],
        attached_remedies=_r["remedies"]))
HERBS.extend(_NEW_HERBS.values())

# ---- Global pool + rule-based coverage: every condition gets 1-3 products.
from new_products import NEW_PRODUCTS as _NEW
for _t in _NEW:
    (pid, name, brand, cat, desc, merch, url, herb, tags) = _t
    PRODUCTS.append(dict(pid=pid, name=name, brand=brand, cat=cat, desc=desc,
        merchant=merch, country="USA", currency="USD", url=url, herb=herb,
        conds=[], evidence="Traditional use", verified="2026-09-29",
        status="approved", version="1.0",
        notes="Global storefront (iHerb search; page-fetch verified live; ships to 180+ countries — not Bangladesh). Check availability in your country."))
_ptags = {}
for _p in PRODUCTS:
    _ptags[_p["pid"]] = set()
for _t in _NEW:
    _ptags[_t[0]] = set(_t[8])
# Seed tags for legacy products:
_SEED_TAGS = {
 "P-CHYAWAN-01": {"wellness","respiratory","fever"}, "P-TULSI-TEA-01": {"respiratory","fever","throat","wellness"},
 "P-TULSI-GINGER-01": {"throat","digestive","wellness"}, "P-TRIPHALA-01": {"digestive","wellness"},
 "P-NEEM-TAB-01": {"skin","wellness"}, "P-NEEM-GEL-01": {"skin"},
 "P-LIV52-01": {"liver","digestive"}, "P-ODOMOS-01": {"mosquito"},
 "P-PEPPERMINT-01": {"pain","mind","respiratory"}, "P-VICKS-01": {"respiratory","throat","pain"},
 "P-STREPSILS-01": {"throat"}, "P-CANDID-01": {"skin","infection"},
 "P-LOTUS-SUN-01": {"skin"}, "P-VASELINE-01": {"skin","wound"},
 "P-GILOY-01": {"fever","infection","liver"}, "P-HONEY-01": {"throat","respiratory","wound"},
 "P-AMLA-01": {"digestive","wellness"}, "P-ASHWA-01": {"mind","wellness"},
 "P-RUMALAYA-01": {"pain"}, "P-TRIPHALA-IH-01": {"digestive","wellness"},
}
for _pid, _ts in _SEED_TAGS.items():
    _ptags[_pid] = _ts

def _ctags(c):
    t = set()
    cat = c.get("category","")
    if "Skin" in cat: t.add("skin")
    if "Respiratory" in cat: t.add("respiratory")
    if "Digestive" in cat: t.add("digestive")
    if "Brain" in cat: t.update(["mind","pain"])
    if "Heart" in cat: t.add("heart")
    if "Mental" in cat: t.add("mind")
    if "Women" in cat: t.add("women")
    hay = (c["name"] + " " + " ".join(c.get("symptoms",[])) + " " + " ".join(c.get("keywords",[]))).lower()
    rules = [("liver","liver"),("eye","eye"),("vision","eye"),("kidney","urinary"),("bladder","urinary"),
      ("urinary","urinary"),("prostate","urinary"),("joint","pain"),("knee","pain"),("arthritis","pain"),
      ("back","pain"),("muscle","pain"),("bone","pain"),("gout","pain"),("cough","respiratory"),
      ("cold","respiratory"),("flu","respiratory"),("throat","throat"),("nose","respiratory"),
      ("sinus","respiratory"),("lung","respiratory"),("breath","respiratory"),("stomach","digestive"),
      ("bowel","digestive"),("diarrhea","digestive"),("diarrhoea","digestive"),("constipation","digestive"),
      ("gut","digestive"),("piles","digestive"),("fever","fever"),("malaria","fever"),("dengue","fever"),
      ("typhoid","fever"),("viral","fever"),("virus","fever"),("mosquito","mosquito"),("wound","wound"),
      ("burn","wound"),("bite","wound"),("cut","wound"),("women","women"),("pregnan","women"),
      ("menstrual","women"),("ovarian","women"),("diabet","metabolic"),("thyroid","metabolic"),
      ("sugar","metabolic"),("obes","metabolic"),("anxiety","mind"),("sleep","mind"),("stress","mind"),
      ("depress","mind"),("memory","mind"),("mind","mind"),("skin","skin"),("rash","skin"),
      ("acne","skin"),("eczema","skin"),("heart","heart"),("blood","heart"),("cholesterol","heart")]
    for kw, tag in rules:
        if kw in hay: t.add(tag)
    t.add("wellness")
    return t

for _p in PRODUCTS: _p["conds"] = []
for c in CONDS:
    ct = _ctags(c)
    scored = []
    for _p in PRODUCTS:
        if _p["status"] != "approved": continue
        ov = len(ct & _ptags.get(_p["pid"], set()))
        if ov: scored.append((ov, _p["pid"]))
    scored.sort(reverse=True)
    # Prefer legacy curated links first for the original 26.
    _picked = [pid for _, pid in scored[:3]]
    for _pid in _picked:
        next(p for p in PRODUCTS if p["pid"] == _pid)["conds"].append(c["id"])
IMGREP = {}
try:
    import json as _j
    IMGREP = _j.load(open("assets/content/image_report.json", encoding="utf-8"))
except Exception:
    IMGREP = {}
_DEFAULT_DIET_Y = ["Vegetables and fruits", "Whole grains", "Plenty of water"]
_DEFAULT_DIET_N = ["Smoking", "Excess alcohol", "Ignoring warning signs"]
for c in CONDS:
    if c["id"] in DIETS:
        eat, avoid = DIETS[c["id"]]
    else:
        eat, avoid = _DEFAULT_DIET_Y, _DEFAULT_DIET_N
    c["diet_yes"] = eat; c["diet_no"] = avoid
    # Images WITHDRAWN (2026-09-29): topical matching across ~200 conditions
    # cannot be verified without visual review; motif design used instead.
    c["image"] = ""
    c["image_license"] = ""
    c["image_credit"] = ""
    c["image_page"] = ""
    c["image_status"] = "Withdrawn"

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
missing = [L for L in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" if L not in letters]
if missing:
    errs.append("letters missing: %s" % missing)
for c in CONDS:
    low = text_fields(c).lower()
    for b in BANNED:
        if b in low: errs.append("%s contains banned phrase %r" % (c["id"], b))
    if len(c["sources"]) < 1: errs.append("%s needs sources" % c["id"])
    if not c.get("diet_yes"): errs.append("%s missing diet" % c["id"])
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
 "Category Tag","Common Symptoms","Risk Factors","Urgent Warning Signs","When To Seek Care","General Information",
 "Ayurvedic Information","Evidence Summary","Safety Information","Diet: What To Eat",
 "Diet: What To Avoid","Basic Medical Tests","Attached Remedies (source)","Sources","Source URLs","Image Path","Image Status","Image Source Link",
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
     c.get("category_tag","Treatable"),
     "; ".join(c["symptoms"]),"; ".join(c["risks"]),"; ".join(c["red_flags"]),c["care"],
     c["overview"]+" | Causes: "+", ".join(c["causes"])+ " | Management: "+c["management"],
     c["ayurveda"],"[%s] %s" % (c["evidence"], c["evidence_note"]),c["safety"],
     "; ".join(c["diet_yes"]),"; ".join(c["diet_no"]),
     "; ".join(c.get("medical_tests",["Clinical Evaluation Required First"])),
     c.get("attached_remedies",""),
     "; ".join(s[0] for s in c["sources"]),"; ".join(s[1] for s in c["sources"]),
     c.get("image", ""),c.get("image_status","Missing"),c.get("image_page",""),
     c["status"],c["last_reviewed"],c["version"],"1.0.0"]
    for p in ps:
        if p is None: row += ["","","",""]
        else: row += [p["name"],p["brand"],p["merchant"],p["url"]]
    row += ["","",""]
    row += ["MVP seed; illustration pending (no image provider). Replace Product URLs with affiliate links when ready."]
    ws.append(row)
try:
    wb.save("docs/AyuCare_Master_Content_Product_Catalog.xlsx")
    print("Excel: canonical name written.")
except PermissionError:
    wb.save("docs/AyuCare_Master_Content_Product_Catalog_v2.xlsx")
    print("Excel: canonical file locked (open?) — wrote _v2 instead.")
print("OK: %d conditions, %d approved products, %d herbs. Single-sheet Excel + JSON written."
      % (len(CONDS), len([p for p in PRODUCTS if p["status"]=="approved"]), len(HERBS)))

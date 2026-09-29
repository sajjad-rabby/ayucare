# Pass 2: distinct image per condition. Skips already-used IDs, broader pool.
import json, os, time, urllib.request, urllib.parse

UA = {"User-Agent": "AyuCare/1.0 (Windows NT 10.0; Win64; x64)"}
PX_KEY = os.environ["PIXABAY_KEY"]
PEX_KEY = os.environ.get("PEXELS_KEY", "")
OUT = "assets/content/images"

QUERIES = {
 "acne": ["acne face skin", "pimple skin closeup", "facial skin care"],
 "bronchitis": ["lungs anatomy", "respiratory system", "breathing lungs"],
 "constipation": ["digestive system", "intestines anatomy", "stomach digestion"],
 "dengue": ["mosquito bite", "aedes mosquito", "mosquito closeup"],
 "eczema": ["dry skin hands", "skin rash arm", "moisturizer skin"],
 "fever": ["thermometer fever", "ill thermometer", "temperature check"],
 "gastritis": ["stomach anatomy", "gastric", "abdomen pain"],
 "headache": ["headache woman", "head pain stress", "migraine head"],
 "influenza": ["flu virus", "virus microscope", "cold flu tissue"],
 "jaundice": ["liver anatomy", "liver health", "yellow skin"],
 "kidney-stones": ["kidney anatomy", "kidneys", "back pain kidney"],
 "laryngitis": ["throat sore", "neck throat", "voice throat"],
 "migraine": ["migraine pain", "headache dark", "head ache"],
 "neuropathy": ["nerves anatomy", "nervous system", "foot pain"],
 "osteoarthritis": ["knee joint", "knee pain", "joint anatomy"],
 "psoriasis": ["skin scales", "dry skin patches", "skin closeup"],
 "q-fever": ["farm sheep", "cattle farm", "goat farm"],
 "ringworm": ["skin infection", "fungal", "itchy skin"],
 "sinusitis": ["sinuses", "nasal congestion", "face sinuses"],
 "tonsillitis": ["sore throat", "throat pain", "swallowing"],
 "ulcerative-colitis": ["intestines", "colon anatomy", "digestive health"],
 "vitiligo": ["diverse hands", "skin diversity", "hands together"],
 "whooping-cough": ["coughing child", "cough", "child cough"],
 "xeroderma": ["dry skin cream", "moisturizer hands", "skin hydration"],
 "yellow-fever": ["mosquito net", "tropical mosquito", "travel vaccine"],
 "zika": ["mosquito repellent", "mosquito", "tropical travel"],
}

def px_search(q):
    params = urllib.parse.urlencode({"key": PX_KEY, "q": q, "image_type": "photo",
        "orientation": "horizontal", "safesearch": "true", "per_page": 10, "min_width": 640})
    with urllib.request.urlopen(
            urllib.request.Request("https://pixabay.com/api/?" + params, headers=UA),
            timeout=30) as r:
        return json.load(r)

def download(url, dest):
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=60) as r, open(dest, "wb") as f:
        f.write(r.read())

rep_path = "assets/content/image_report.json"
report = {}
if os.path.exists(rep_path):
    try: report = json.load(open(rep_path))
    except Exception: report = {}
used = {v.get("id") for v in report.values() if v.get("src") == "pixabay"}

for slug, qs in QUERIES.items():
    dest = os.path.join(OUT, slug + ".jpg")
    done = False
    for q in qs:
        try:
            hits = px_search(q).get("hits", [])
        except Exception as e:
            print("api miss:", slug, str(e)[:60]); continue
        for h in hits:
            if h["id"] in used: continue
            try:
                download(h["webformatURL"], dest)
            except Exception as e:
                print("dl miss:", slug, str(e)[:60]); continue
            used.add(h["id"])
            report[slug] = {"src": "pixabay", "id": h["id"],
                "page": h["pageURL"], "credit": "%s via Pixabay" % h["user"]}
            print("OK", slug, h["id"], h["user"], "|", q); done = True; break
        if done: break
        time.sleep(1)
    if not done:
        print("MISSING", slug)
    time.sleep(2)

json.dump(report, open(rep_path, "w"), indent=1)
ok = sum(1 for v in report.values() if v.get("src") != "missing")
print("IMAGES OK: %d/26" % ok)

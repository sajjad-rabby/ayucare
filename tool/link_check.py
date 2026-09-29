# Link verifier: HEAD/GET every product + source URL. Prints PASS/FAIL table.
import sys, urllib.request
sys.path.insert(0, "tool/content")
from conditions_1 import CONDITIONS_1
from conditions_2 import CONDITIONS_2
from herbs_products import PRODUCTS, SOURCES

def check(url):
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "AyuCare-linkcheck/1.0"}, method="HEAD")
        r = urllib.request.urlopen(req, timeout=20)
        return r.status
    except Exception:
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "AyuCare-linkcheck/1.0"})
            r = urllib.request.urlopen(req, timeout=25)
            return r.status
        except Exception as e:
            return "ERR %s" % (getattr(e, "code", "?"),)

fails = 0
for p in PRODUCTS:
    s = check(p["url"]); ok = (s == 200)
    fails += (not ok)
    print(("PASS " if ok else "FAIL "), p["pid"], s, p["url"])
for cond in CONDITIONS_1 + CONDITIONS_2:
    for org, url in cond["sources"]:
        s = check(url); ok = (s == 200)
        fails += (not ok)
        print(("PASS " if ok else "FAIL "), cond["id"], s, url)
print("FAILURES:", fails)

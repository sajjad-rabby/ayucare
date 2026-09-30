# Inositol enrichment (researched 2026-09-30): myo- + D-chiro (40:1 plasma ratio)
# studied for PCOS endocrine/metabolic profile; insulin-mediation studied in T2D.
INOSITOL_HERB = dict(
    id="inositol", name="Inositol", scientific="Myo-inositol / D-chiro-inositol",
    alt="Vitamin B8 (nutrient, not a vitamin)",
    desc="A vitamin-like nutrient found in cell membranes; myo-inositol is the most abundant form. Studied mainly as myo- + D-chiro combination.",
    traditional="Not a traditional Ayurvedic herb; included as a researched nutrient supplement for education.",
    research="Randomized trials and reviews report myo-inositol alone, or myo + D-chiro at the physiological 40:1 plasma ratio, improved endocrine and insulin-resistance markers in PCOS; D-chiro alone has insufficient/controversial evidence. Insulin-mediation also studied in type 2 diabetes.",
    evidence="Some evidence",
    forms="capsules (typically 500 mg myo-inositol), powder",
    safety="Generally tolerated in trials; use with clinician guidance, especially with diabetes medicines or pregnancy.",
    contra=["Without clinician advice alongside diabetes medicines"],
    interactions="May add to glucose-lowering medicines; clinician review needed.",
    pregnancy="Clinician advice required.", children="Clinician advice required.",
    sources=[("PubMed", "https://pubmed.ncbi.nlm.nih.gov/27898267")],
    image="", license="", reviewed="2026-09-30", version="1.0")

INOSITOL_PRODUCTS = [
 dict(pid="P-INOSITOL-01", name="NOW Inositol Capsules 500mg (100)", brand="NOW Foods", cat="Supplement",
  desc="Myo-inositol capsules for everyday nutrient routines.",
  merchant="Swanson Vitamins", country="USA", currency="USD",
  url="https://www.swansonvitamins.com/collections/letter-vitamins-97/p/now-foods-inositol-capsules-500-mg-100-caps",
  herb="inositol", conds=["C-PCOS-002", "C-OVARIANCYSTS-002", "C-DIABETES-002"],
  evidence="Some evidence", verified="2026-09-30", status="approved", version="1.0",
  notes="Direct fetch 200 on 2026-09-30. Myo-inositol form."),
 dict(pid="P-INOSITOL-02", name="NOW Inositol Powder", brand="NOW Foods", cat="Supplement",
  desc="Myo-inositol powder for flexible daily routines.",
  merchant="iHerb (global shipping)", country="USA", currency="USD",
  url="https://www.iherb.com/search?kw=now+inositol",
  herb="inositol", conds=["C-PCOS-002", "C-OVARIANCYSTS-002", "C-DIABETES-002"],
  evidence="Some evidence", verified="2026-09-30", status="approved", version="1.0",
  notes="Search-verified global storefront (direct fetch bot-blocked)."),
]

INOSITOL_NOTE = (" Inositol research: of nine stereoisomers, myo-inositol (MYO) and "
 "D-chiro-inositol (DCI) are studied for PCOS. Healthy plasma holds MYO:DCI near "
 "40:1 while PCOS ovaries can invert toward 0.2:1; trials of MYO alone or MYO+DCI "
 "at 40:1 report improved endocrine and insulin-resistance markers, while DCI alone "
 "has insufficient evidence. Insulin-mediation is also studied in type 2 diabetes. "
 "Product forms here are myo-inositol; any use belongs under clinician guidance, "
 "especially with diabetes medicines or in pregnancy.")

CONDITION_OVERRIDES = {
 "C-PCOS-002": {
   "evidence": "Some evidence",
   "herbs_add": ["inositol"],
   "evidence_note_suffix": INOSITOL_NOTE,
   "sources_add": [("PubMed", "https://pubmed.ncbi.nlm.nih.gov/27898267")]},
 "C-OVARIANCYSTS-002": {
   "evidence": "Limited evidence",
   "herbs_add": ["inositol"],
   "evidence_note_suffix": " Ovarian cysts have many causes needing diagnosis first." + INOSITOL_NOTE,
   "sources_add": [("PubMed", "https://pubmed.ncbi.nlm.nih.gov/27898267")]},
 "C-DIABETES-002": {
   "evidence": "Some evidence",
   "herbs_add": ["inositol"],
   "evidence_note_suffix": " Glucose control belongs to the treating clinician; never adjust diabetes medicines based on app content." + INOSITOL_NOTE,
   "sources_add": [("PubMed", "https://pubmed.ncbi.nlm.nih.gov/27898267")]},
}

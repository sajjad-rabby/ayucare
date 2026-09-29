# MONETIZATION_ROADMAP
PHASE 1 (now): no ads, no affiliate. Product sections show direct retailer
links only, affiliate_url blank, disclosure component ready but hidden
(FeatureFlags.affiliateEnabled=false). PHASE 2: populate affiliate_url per
product (no redesign — routing is affiliate→direct→hide). PHASE 3: AdMob via
factory monetization-addon (MONETIZATION_MODE, test IDs, manifest placeholder);
sensitive categories managed in AdMob console (health = sensitive). PHASE 4:
premium (advanced encyclopedia, collections, offline packs) — architecture
supports feature flags already.

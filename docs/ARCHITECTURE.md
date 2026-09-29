# ARCHITECTURE (AyuCare 1.0.0)
Layers: configuration/ (AppConfig, FeatureFlags all-false, DisclaimerConfig),
theme/ (AyuColors/tokens, light+dark), data/ (models, ContentRepository JSON
bundle loader + search index, SavedRepository prefs), ui/screens (splash via
native launch, home, az, letter, search, condition, herb, saved, more+legal),
ui/widgets (SafetyNotice 3-level, SectionCard, BulletList), l10n via central
strings (English canonical; widgets reference shared copy where practical).
ContentRepository: LocalContentRepository now; RemoteContentRepository later
implements same shape. Offline-first: JSON bundle in assets, zero network for
core flows. Monetization/affiliate: flags + routing stubs only (no SDKs).

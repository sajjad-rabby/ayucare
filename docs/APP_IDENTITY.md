# APP_IDENTITY — AyuCare (tracked, stable — approval required to change)

PACKAGE_NAME=com.xeloxy.ayucare
PLAY_REGISTERED=UNKNOWN
UPLOAD_CERT_SHA256=EC:85:47:32:CA:03:10:66:BC:AE:93:AB:86:D1:C1:FD:6A:72:4F:21:AA:E3:82:47:44:7D:42:BC:15:49:BC:04
SIDE_KEYS=none
KEY_HISTORY=
  - 2026-09-29: debug keys only (development). No production key created yet.
  - 2026-09-30: upload key created (CN=Sajjad Rabby, O=Symcora, valid to 2054); first signed AAB built + verified. Play registration still pending.

Notes:
- Title "AyuCare: Health & Ayurveda" (26 chars) — verify at submission.
- Before first production release: register package (automatic flow where
  applicable), generate upload key via documented keytool step, record its
  SHA-256 above, and flip PLAY_REGISTERED only after Play Console confirms.

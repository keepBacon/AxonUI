#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f android/app/src/main/AndroidManifest.xml ]]; then
  echo 'Android scaffold missing. Run flutter create --platforms=android --org com.axon --project-name axon_flclash_flutter --no-pub . first' >&2
  exit 1
fi

TARGET='android/app/src/main/kotlin/com/axon/axon_flclash_flutter/MainActivity.kt'
mkdir -p "$(dirname "$TARGET")"
cp scripts/MainActivity.kt "$TARGET"
# Flutter create may add an obsolete MyApp example test; this project owns its tests.
if [[ -f test/widget_test.dart ]] && grep -q 'MyApp' test/widget_test.dart; then
  rm test/widget_test.dart
fi
# Only mutate the Flutter-generated Android host. No existing Axon app files are used.
python3 - <<'PY_ANDROID'
from pathlib import Path
m = Path('android/app/src/main/AndroidManifest.xml')
s = m.read_text(encoding='utf-8')
s = s.replace('android:label="axon_flclash_flutter"', 'android:label="控件展示"')
m.write_text(s,encoding='utf-8')
PY_ANDROID

echo 'Standalone Flutter Android host + persistent MethodChannel prepared.'

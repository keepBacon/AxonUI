#!/usr/bin/env bash
set -euo pipefail

# Flutter 3.47.7 generates android/app/build.gradle.kts using flutter.ndkVersion.
# Use that exact revision rather than overriding the project's toolchain.
NDK_VERSION="28.2.13676358"
SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"

if [[ -z "$SDK_ROOT" || ! -d "$SDK_ROOT" ]]; then
  echo "::error::ANDROID_SDK_ROOT / ANDROID_HOME is not configured" >&2
  exit 1
fi

SDKMANAGER="$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"
NDK_DIR="$SDK_ROOT/ndk/$NDK_VERSION"

if [[ ! -x "$SDKMANAGER" ]]; then
  echo "::error::Android sdkmanager is missing at $SDKMANAGER" >&2
  exit 1
fi

ndk_healthy() {
  [[ -f "$NDK_DIR/source.properties" ]] &&
    grep -Eq '^Pkg.Revision[[:space:]]*=[[:space:]]*28\.2\.13676358[[:space:]]*$' "$NDK_DIR/source.properties" &&
    [[ -x "$NDK_DIR/toolchains/llvm/prebuilt/linux-x86_64/bin/clang" ]]
}

if ndk_healthy; then
  echo "NDK $NDK_VERSION is already installed and verified."
  exit 0
fi

# sdkmanager occasionally receives a truncated archive from the CDN.
# Isolate this retry to the required NDK and its SDK download scratch space.
for attempt in 1 2 3 4; do
  echo "::group::Installing NDK $NDK_VERSION (attempt $attempt/4)"
  rm -rf "$NDK_DIR" "$SDK_ROOT/.temp"

  if timeout 480 "$SDKMANAGER" --sdk_root="$SDK_ROOT" "ndk;$NDK_VERSION"; then
    if ndk_healthy; then
      echo "NDK $NDK_VERSION installed successfully and passed integrity checks."
      echo "::endgroup::"
      exit 0
    fi
    echo "::warning::sdkmanager returned success but the NDK is incomplete."
  else
    echo "::warning::NDK install attempt $attempt failed (download, archive, or timeout)."
  fi

  echo "::endgroup::"
  if (( attempt < 4 )); then
    sleep $(( attempt * 15 ))
  fi
done

echo "::error::Could not install a complete NDK $NDK_VERSION after 4 attempts." >&2
exit 1

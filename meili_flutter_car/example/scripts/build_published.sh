#!/usr/bin/env bash
#
# Build the example app against the PUBLISHED meili_flutter from pub.dev
# (i.e. with the local path overrides disabled), for a Play Store release.
#
# Day-to-day local development needs nothing — pubspec_overrides.yaml makes
# `flutter run` use the in-repo plugin source by default. This script is only
# for producing a release artifact that consumes the published plugin.
#
# Usage:
#   scripts/build_published.sh                 # release App Bundle (.aab)
#   scripts/build_published.sh apk             # release APK instead
#   scripts/build_published.sh appbundle --no-tree-shake-icons
#
# Requires MEILI_GITHUB_USERNAME / MEILI_GITHUB_TOKEN in the environment (the
# native Android SDK is pulled from GitHub Packages).
set -euo pipefail

cd "$(dirname "$0")/.."   # → example/

overrides="pubspec_overrides.yaml"
backup="pubspec_overrides.yaml.localdev"

target="${1:-appbundle}"
if [ "$#" -gt 0 ]; then shift; fi

restore() {
  if [ -f "$backup" ]; then
    mv -f "$backup" "$overrides"
    # Reset the lockfile back to local-dev mode so the next `flutter run` is
    # unaffected. Non-fatal if it fails.
    flutter pub get >/dev/null 2>&1 || true
    echo "Restored local path overrides."
  fi
}
trap restore EXIT

if [ -f "$overrides" ]; then
  mv -f "$overrides" "$backup"
  echo "Disabled local path overrides — resolving meili_flutter from pub.dev."
fi

flutter pub get
flutter build "$target" --release "$@"

# meili_flutter_example

Demonstrates how to use the meili_flutter plugin. The app is a small host that
configures launch settings (PTID, environment, flow, etc.) inline and opens the
Meili SDK — see `lib/widgets/launch_view.dart`.

## Local development vs published plugin

The example can build against either the **in-repo plugin source** (for testing
local changes) or the **published `meili_flutter`** from pub.dev (what a real
consumer gets, used for Play Store releases). This is controlled by
`pubspec_overrides.yaml`, not by the build mode (`--debug`/`--release`).

### Local development (default)

`pubspec_overrides.yaml` is committed and redirects `meili_flutter` and the
federated platform packages to the in-repo source. Nothing extra to do:

```bash
flutter pub get
flutter run            # or: flutter build apk --release
```

`flutter pub get` resolves the plugin packages to local paths (verify in
`pubspec.lock`).

### Published plugin (Play Store release)

1. Publish the plugin (`meili_flutter`) to pub.dev.
2. Bump the `meili_flutter:` constraint in `pubspec.yaml` to the published
   version.
3. Build with the overrides disabled:

```bash
export MEILI_GITHUB_USERNAME=... MEILI_GITHUB_TOKEN=...   # native Android SDK
scripts/build_published.sh            # release .aab against the published plugin
# scripts/build_published.sh apk      # release .apk instead
```

The script temporarily sidelines `pubspec_overrides.yaml`, runs `flutter pub
get` (resolving `meili_flutter` from pub.dev), builds the release artifact, then
restores local-dev mode.

> Note: the example's release build type is signed with the debug keystore. Add
> a real `signingConfig` (keystore + `key.properties`) in
> `android/app/build.gradle` before uploading to the Play Store.

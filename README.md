# locafy-magento2click

Locafy customer app (Flutter), pointed at the `https://locafy.magento2.click` Magento backend.

The backend is configured in one place — `serverConfig.url` in [lib/env.dart](lib/env.dart).
Catalog media (`kMediaDomain` in `lib/common/constants/general.dart`) derives from it.

## Build-time secrets

The Magento integration token is **not** in source — this repo is public. It is
supplied as a `--dart-define` and read by `kMagentoAccessToken` in
[lib/env.dart](lib/env.dart).

Local setup, once:

```bash
cp configs/dart-defines.example.json configs/dart-defines.json
```

Paste the real token into that file (it is gitignored), then build or run with:

```bash
flutter run --dart-define-from-file=configs/dart-defines.json
```

CI passes it instead from the `MAGENTO_ACCESS_TOKEN` repository secret, which
must be set under Settings -> Secrets and variables -> Actions.

If the token is missing the app still starts, but every authenticated Magento
call returns 401 — `main.dart` logs a `MAGENTO_ACCESS_TOKEN is empty` warning at
startup so that is not a mystery.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

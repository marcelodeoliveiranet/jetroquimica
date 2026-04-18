# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app `jetroquimica` (Dart SDK `^3.11.1`). Currently scaffolded from the default `flutter create` template — `lib/main.dart` is still the counter-app demo, and there is no custom architecture yet. When adding features, expect to establish conventions (state management, routing, folder layout) rather than follow existing ones.

Targets configured: `android/`, `ios/`, `web/`. No desktop targets are present.

## Commands

- Install deps: `flutter pub get`
- Run (default device): `flutter run`
- Run on a specific device: `flutter run -d chrome` / `flutter run -d windows` / `flutter run -d <deviceId>` (list with `flutter devices`)
- Static analysis: `flutter analyze` (config in `analysis_options.yaml`, extends `package:flutter_lints/flutter.yaml`)
- Format: `dart format .`
- Tests: `flutter test`
- Single test file: `flutter test test/widget_test.dart`
- Single test by name: `flutter test --plain-name "Counter increments smoke test"`
- Build release: `flutter build apk` / `flutter build ios` / `flutter build web`
- Clean artifacts: `flutter clean`

## Notes

- `lib/main.dart` currently contains two expressions that look truncated (`.fromSeed(...)` with no `ColorScheme` prefix at line 31, `.center` with no `MainAxisAlignment` prefix at line 105). If you run into analyzer errors here, these are likely the cause — confirm with the user before "fixing" in case it's intentional in-progress editing.
- Shell on this machine is bash on Windows — use Unix paths (`/dev/null`, forward slashes) in commands.

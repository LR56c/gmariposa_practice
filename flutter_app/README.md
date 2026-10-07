# flutter_app

Product catalog built with Flutter and Riverpod (Android).

## Versions

| Tool | Version |
| --- | --- |
| Flutter | 3.47.6 (stable), pinned in `.fvmrc` |
| Dart | 3.13.5 |

## Run

```sh
dart pub global activate fvm   # skip if fvm is already installed
fvm install                    # reads .fvmrc
fvm flutter pub get
fvm flutter run               # with an Android emulator running
```

Without fvm, any Flutter 3.47.x stable works.

## Checks

```sh
fvm dart format --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
```

## Integration test

`integration_test/main_flow_test.dart` covers search → detail → add to cart → cart, with a fake repository (no network).
It needs an emulator or device, so CI does not run it.

```sh
fvm flutter test integration_test -d emulator-5554   # any running device id
```

Verified twice in a row on an Android emulator (`sdk gphone16k x86 64`, API 36).

## Settings

The gear icon next to the cart opens a modal with the theme (system, light, dark) and the language (Español, English).
Both choices are saved with `shared_preferences` through `SettingsRepository`; the Cart uses the same pattern
(`CartRepository` and `SharedPreferenceCartData`).

## Release APK

CI builds `app-release.apk` and uploads it as the `app-release-apk` artifact (signed with the debug key, for testing only).

## Extra dependencies

- `toastification`: the brief "Agregado al carrito" toast (UX-DR9). It shows from the button callback via `ToastificationWrapper`, with no provider and no `SnackBar`.
- `infinite_scroll_pagination`: renders the Catalog list and asks for the next page. It does not own the state: `Catalog` (Riverpod) keeps `items`, `total` and `loadMore`, and the page builds a `PagingState` from it. While a page loads it shows skeleton rows, not a spinner.

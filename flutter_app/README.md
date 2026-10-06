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

## Extra dependencies

- `toastification`: the brief "Agregado al carrito" toast (UX-DR9). It shows from the button callback via `ToastificationWrapper`, with no provider and no `SnackBar`.

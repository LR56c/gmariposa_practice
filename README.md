# gmariposa_practice

[![CI](https://github.com/LR56c/gmariposa_practice/actions/workflows/ci.yml/badge.svg)](https://github.com/LR56c/gmariposa_practice/actions/workflows/ci.yml)

Prueba técnica Jr Flutter (Riverpod) + Angular. Cada carpeta es independiente (lint, test y lockfile propios).

## CI

`.github/workflows/ci.yml` corre en cada `push` y `pull_request` hacia `main`, con dos jobs independientes:

- **flutter** (Flutter 3.47.6): `flutter pub get`, `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`.
- **flutter-apk** (tras `flutter`): `flutter build apk --release` y sube `app-release.apk` como artifact (firmado con la clave debug, solo para probar).
- **angular** (Node 24): `npm ci`, `npx ng test --no-watch`, `npx ng build`.

No ejecuta la prueba de integración de Flutter (`integration_test/`), porque requiere emulador o dispositivo.
Para reproducirlo en local, corre esos mismos comandos dentro de `flutter_app/` y `angular_app/`.

## Demo (GitHub Pages)

La app Angular se despliega en https://lr56c.github.io/gmariposa_practice/ con `.github/workflows/pages.yml` (en cada push a `main`
o a mano). Es un extra de demostración, no parte del CI. El build está localizado: la raíz redirige a `/es/` o `/en/` según el
idioma del navegador, y `404.html` carga el `index.html` del idioma para que los enlaces profundos (`/es/orders/3`) funcionen al recargar.

Para verlo en local como en producción: `cd angular_app && npx ng build` y servir `dist/angular_app/browser/es` con un servidor estático
(por ejemplo `npx http-server dist/angular_app/browser/es -p 8080 --proxy http://localhost:8080?`).

## angular_app

Panel de Órdenes. Angular 22.2 (standalone, zoneless, TypeScript 6.0 `strict`), runner de pruebas Vitest, Node 24.

```bash
cd angular_app
npm install
ng serve      # http://localhost:4200
ng test
ng build
```

Si no tienes el CLI global, usa `npx ng <comando>`.

### Dependencias

- **Tailwind 4.3** (`tailwindcss`, `@tailwindcss/postcss`, `postcss`): estilado con utilidades y los tokens de
  `DESIGN.md` en un bloque `@theme`, para compartir identidad visual con la app Flutter sin escribir CSS propio.

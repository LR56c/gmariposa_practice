# gmariposa_practice

Prueba técnica Jr Flutter (Riverpod) + Angular. Cada carpeta es independiente (lint, test y lockfile propios).

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
- **`@ngrx/store`, `@ngrx/effects`, `@ngrx/store-devtools`**: instaladas, sin uso por ahora. El estado del panel es un
  servicio-store manual; la justificación completa llega con el Epic 5.

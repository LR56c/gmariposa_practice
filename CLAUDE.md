# gmariposa_practice — Prueba técnica Jr Flutter (Riverpod) + Angular

## Modo de trabajo (BMAD)
- **Coaching en decisiones técnicas**: ante cada decisión técnica (arquitectura, librería, patrón, trade-off),
  DETENERSE, explicar opciones y razones, y dejar que el usuario decida/entienda antes de implementar.
- Comunicación y documentos en español; código e identificadores consistentes (inglés).
- No hay negocio real: no inventar contexto de negocio; priorizar calidad y criterio sobre cantidad.

### Proceso BMAD (estado y flujo)
- Planning completo en `_bmad-output/planning-artifacts/`: `briefs/`, `prds/`, `ux-designs/` (DESIGN.md, EXPERIENCE.md,
  stitch-index.md), `architecture/.../ARCHITECTURE-SPINE.md` (AD-1..AD-15) y `epics.md` (5 epics, 19 stories).
- Seguimiento en `_bmad-output/implementation-artifacts/sprint-status.yaml` (generado con `bmad-sprint-planning`;
  re-ejecutar la skill para refrescarlo si cambian los epics). Actualizar el status de la story al empezar y al cerrar.
- **Flujo por story: spec + implementación, SIN review por story** (decisión del usuario, para agilizar).
  La review se hace al final, por porciones. Sigue valiendo: rama por story, commits convencionales, merge a `main`.
- Stories 5.2–5.5 son bonus (`optional`); la 5.1 verifica el MVP.

## Git: reglas obligatorias
- **Modelo de ramas `main` ← `dev` ← `sprint/<epic>` ← story** (desde Epic 2; el Epic 1 se fusionó directo a `main`):
  - `main`: solo versiones **verificadas** (analyze + test + prueba en emulador). Nunca se commitea directo.
  - `dev`: integración; recibe cada sprint ya cerrado.
  - `sprint/<epic>` (ej. `sprint/e2`): se crea desde `dev` al empezar el epic; recibe las stories con `--no-ff`.
  - **Una rama por cada item (story) de cada epic**, desde su `sprint/<epic>`: `<tipo>/<epic>-<story>-<slug>`
    (ej. `feat/e2-s3-cart-notifier`). Merge `--no-ff` a la rama del sprint al cerrar la story (historial real).
  - Cierre de sprint: verificar en la rama del sprint (`dart format`, `flutter analyze`, `flutter test`, emulador) →
    merge a `dev` → merge a `main` (mensaje `merge: sprint/<epic>`). Un fix tras el cierre va en `fix/...` desde `dev`.
- **Conventional Commits** en todos los commits: `feat|fix|docs|test|refactor|chore|ci(scope): resumen`
  (scope = `flutter`, `angular`, `docs`, `repo`). Commits pequeños y frecuentes dentro de la rama.
- Cada story BMAD debe incluir en sus tareas: crear rama, commits convencionales, merge.

## Estructura y convenciones por carpeta
- `flutter_app/` (Flutter/Dart): crear con `flutter create`; `snake_case` en archivos, `UpperCamelCase` en tipos,
  Effective Dart, `flutter_lints`/`very_good_analysis`, `dart format`, widgets `const` y pequeños, capas
  data/domain/presentation por feature (estructura sugerida en el PRD). Skills: `flutter-apply-architecture-best-practices`,
  `flutter-add-widget-test`, `flutter-implement-json-serialization`, `flutter-use-http-package`,
  `flutter-setup-declarative-routing`, `flutter-fix-layout-issues`, `ecc:dart-flutter-patterns`, `ecc:flutter-dart-code-review`.
- `angular_app/` (Angular 17+): crear con `ng new` (standalone, TS `strict`); guía de estilo oficial de Angular
  (archivos `*.component.ts`, `*.service.ts`, kebab-case), `inject()`, signals, `@if/@for` con `track`, OnPush en
  presentacionales. Skills: `angular-developer`, `angular-new-app`, `angular-component`, `angular-signals`, `angular-forms`,
  `angular-http`, `angular-routing`, `angular-di`, `angular-testing`.
- Cada carpeta es independiente (su propio lint/test/CI); no mezclar convenciones entre ambas.

## UX / Diseño (incluido, alcance pequeño)
- Usar `bmad-ux` (DESIGN.md + EXPERIENCE.md) con revisión de **direcciones visuales** antes de construir UI.
- Hacer un **Stitch pequeño**: pocas pantallas clave (listado, detalle, carrito; panel de pedidos Angular) y un
  índice pantalla ↔ story (checklist §6) usado como gate en las stories de UI.
- El PRD no exige diseño elaborado: UI ordenada y consistente; no sobreinvertir.

## Aplicación del checklist a este proyecto
Aplican: §4 Flutter (solo lo compatible con el PRD), §5 patrón de errores (como `Failure`/`Result`),
§6 Stitch + índice (versión mínima), §7 mantenimiento (indexar con codebase-memory-mcp al haber código).
No aplican (prueba técnica sin datos personales ni deploy): compliance Chile/ARCO, Clerk, Sevalla/Neon,
security-auditor por epic (opcional al final).

### Tensiones checklist vs PRD (decidir con coaching)
- El PRD exige estado **solo con Riverpod** (2.x/3.x): NO usar `flutter_hooks` para estado de negocio.
- El PRD pide modelos inmutables y errores tipados: `fpdart` (`Either`) o `Failure`/`Result` propio — decidir.
- `dio` vs `http`: el PRD acepta cualquiera; checklist sugiere `dio`.
- `envied`, `flutter_secure_storage`, `latlong2`, `shadcn_flutter`: sobran para el alcance; justificar si se usan.
- Debounce 400 ms: `easy_debounce` o `Timer` propio — decidir.
- Lints: `flutter_lints` o `very_good_analysis`; `flutter analyze` sin warnings.

# gmariposa_practice — Prueba técnica Jr Flutter (Riverpod) + Angular

Fuente de verdad del alcance: `Prueba técnica (para candidatos).pdf` (plazo 3 días, entrega: repo público
con `flutter_app/` y `angular_app/`, `README.md`, `RESPUESTAS.md`, historial de commits real).
Checklist general del usuario: `E:\dev\Projects\project-checklist.md` (aplicar solo lo pertinente, ver abajo).

## Modo de trabajo (BMAD)
- **Coaching en decisiones técnicas**: ante cada decisión técnica (arquitectura, librería, patrón, trade-off),
  DETENERSE, explicar opciones y razones, y dejar que el usuario decida/entienda antes de implementar.
  El PDF exige que el candidato explique cada línea en la entrevista.
- Comunicación y documentos en español; código e identificadores consistentes (inglés).
- No hay negocio real: no inventar contexto de negocio; priorizar calidad y criterio sobre cantidad.

## Git: reglas obligatorias
- **Una rama por cada item (story) de cada epic**, desde `main`: `<tipo>/<epic>-<story>-<slug>`
  (ej. `feat/e2-s3-cart-notifier`). Merge a `main` al cerrar la story (historial real, no commit único).
- **Conventional Commits** en todos los commits: `feat|fix|docs|test|refactor|chore|ci(scope): resumen`
  (scope = `flutter`, `angular`, `docs`, `repo`). Commits pequeños y frecuentes dentro de la rama.
- Cada story BMAD debe incluir en sus tareas: crear rama, commits convencionales, merge.

## Estructura y convenciones por carpeta
- `flutter_app/` (Flutter/Dart): crear con `flutter create`; `snake_case` en archivos, `UpperCamelCase` en tipos,
  Effective Dart, `flutter_lints`/`very_good_analysis`, `dart format`, widgets `const` y pequeños, capas
  data/domain/presentation por feature (estructura sugerida del PDF). Skills: `flutter-apply-architecture-best-practices`,
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
- El PDF no exige diseño elaborado: UI ordenada y consistente; no sobreinvertir.

## Aplicación del checklist a este proyecto
Aplican: §4 Flutter (solo lo compatible con el PDF), §5 patrón de errores (como `Failure`/`Result`),
§6 Stitch + índice (versión mínima), §7 mantenimiento (indexar con codebase-memory-mcp al haber código).
No aplican (prueba técnica sin datos personales ni deploy): compliance Chile/ARCO, Clerk, Sevalla/Neon,
security-auditor por epic (opcional al final).

### Tensiones checklist vs PDF (decidir con coaching)
- PDF exige estado **solo con Riverpod** (2.x/3.x): NO usar `flutter_hooks` para estado de negocio.
- PDF pide modelos inmutables y errores tipados: `fpdart` (`Either`) o `Failure`/`Result` propio — decidir.
- `dio` vs `http`: PDF acepta cualquiera; checklist sugiere `dio`.
- `envied`, `flutter_secure_storage`, `latlong2`, `shadcn_flutter`: sobran para el alcance; justificar si se usan.
- Debounce 400 ms: `easy_debounce` o `Timer` propio — decidir.
- Lints: `flutter_lints` o `very_good_analysis`; `flutter analyze` sin warnings.

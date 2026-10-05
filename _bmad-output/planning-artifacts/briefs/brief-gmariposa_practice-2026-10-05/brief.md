---
title: "Product Brief: Prueba técnica Jr Flutter (Riverpod) + Angular"
status: final
created: 2026-10-05
updated: 2026-10-05
---

# Product Brief: Prueba técnica Jr Flutter (Riverpod) + Angular

## Resumen ejecutivo

Entregar en un máximo de 3 días calendario la prueba técnica de Grupo Mariposa para Desarrollador Jr: una app Flutter con Riverpod ("Mini Catálogo": listado, búsqueda, detalle y carrito), un panel Angular de pedidos, respuestas escritas y un code review. Ambos proyectos consumen la API pública DummyJSON.

La evaluación premia el criterio y la calidad por encima de la cantidad de funcionalidades, y la entrevista de seguimiento exige que el candidato explique cada línea. Por eso el objetivo no es solo que el código funcione: es poder defenderlo.

## El problema

Poco tiempo, un alcance amplio (cuatro partes, 100 % evaluadas) y una evaluación que mide comprensión además de resultado. El riesgo principal es entregar código que el candidato no puede explicar, o llegar al final con los obligatorios sin cerrar y varios deseables o bonus a medias. El PDF dice que prefiere documentar lo pendiente a recibir código roto.

## La solución

Un repositorio público con `flutter_app/` y `angular_app/`, `README.md` y `RESPUESTAS.md`, construido paso a paso con el método BMAD y con modo coaching en cada decisión técnica: se detiene, se explican las opciones y el candidato decide. Cada story vive en su propia rama, con Conventional Commits, de modo que el historial muestra un proceso real y no un único commit final. No hay ventaja competitiva que fabricar: lo que distingue este trabajo es el proceso, con decisiones justificadas por escrito, listas para el README y la entrevista.

## A quién sirve

**Principal:** el candidato, que necesita aprobar la evaluación y salir de la entrevista de seguimiento sabiendo explicar cada decisión.

**Secundario:** el equipo evaluador de Grupo Mariposa, que leerá el repo, el README, `RESPUESTAS.md` y el historial de commits.

## Criterios de éxito

1. `flutter analyze` sin warnings, con `flutter_lints` o `very_good_analysis`.
2. El candidato explica sin mirar el código cómo fluye un provider, desde la UI hasta el repositorio.
3. Pruebas mínimas: 3 unitarias y 1 de widget en Flutter; 2 en Angular.
4. El README documenta cómo ejecutar cada proyecto, las decisiones de arquitectura, lo pendiente y lo que mejoraría.
5. Historial con una rama por story y Conventional Commits.
6. Entrega dentro del plazo de 3 días calendario desde la recepción (PDF fechado el 5 de octubre de 2026).

## Alcance

**Dentro (obligatorio según el PDF):**
- Parte 2, Flutter + Riverpod (50 %): requisitos 1 a 9 del PDF.
- Parte 3, Angular (20 %): requisitos 1 a 7 del PDF.
- Partes 1 y 4 (15 % cada una): 20 preguntas conceptuales y code review con reescritura del fragmento Flutter, en `RESPUESTAS.md`.

**Dentro (apoyo):** dirección visual con `bmad-ux` y un Stitch pequeño (listado, detalle, carrito y panel de pedidos), sin sobreinvertir.

**Deseables y bonus, con regla de corte.** Cada uno solo empieza cuando los obligatorios de su parte están cerrados, probados y con `analyze` limpio:
- Deseables de Flutter: paginación infinita, filtro por categoría, persistencia del carrito, `go_router`, errores tipados y tema claro/oscuro.
- Deseables de Angular: ruta de detalle con lazy loading, signals, control flow nuevo, pipe propio y OnPush.
- Bonus: `riverpod_generator` (decidido desde el inicio para evitar migrar al final), prueba de integración del flujo buscar → detalle → carrito, y GitHub Action con `analyze` y `test`.

**Fuera:** backend propio, autenticación, despliegue, compliance de datos personales y diseño visual elaborado.

## Riesgos y supuestos

- **Tiempo y bonus a medias:** sin plan de horas por día, y se intentan los tres bonus. Mitigación: la regla de corte y documentar lo no alcanzado.
- **`riverpod_generator` desde el inicio:** añade `build_runner` y esconde parte de lo que hay que explicar. Se valida en la arquitectura, con coaching.
- **Uso de IA:** cada línea debe poder explicarse. Mitigación: modo coaching.
- **Dependencia externa:** DummyJSON puede fallar o cambiar. Los repositorios se prueban con falsos.

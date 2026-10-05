# PRD Quality Review — Mini Catálogo (Flutter + Riverpod) y Panel de pedidos (Angular)

Calibración: prueba técnica de candidato, un solo desarrollador, 3 días, requisitos que vienen de un PDF fuera del repo. Se penaliza ambigüedad, requisitos no verificables, deriva del Glosario, FR sin consecuencias testables, IDs y referencias rotas, y supuestos sin indexar. No se penaliza la falta de secciones enterprise.

## Overall verdict

El PRD es sólido para su contexto. Tiene una tesis clara (calidad defendible sobre cantidad de funciones), FR-1..FR-21 contiguos con consecuencias mayormente verificables, una regla de corte honesta para deseables/bonus y un índice de supuestos que cierra el roundtrip. Los riesgos se concentran en tres puntos. UJ-2 promete un resultado (el pedido elegido se muestra con sus productos) que ningún FR entrega. Hay deriva del Glosario en términos que el propio §0 promete no mezclar. Y varios requisitos cuya verificabilidad depende de datos o de un PDF que el lector no tiene (conteos "9 obligatorios / 7 obligatorios", `usuario` de un Order).

## Decision-readiness — adequate

Las decisiones están separadas de las pendientes: el `addendum.md` registra T-1..T-5 con razón del candidato y qué falta validar, y las trade-offs de T-4/T-5 (costo de explicar código generado en la entrevista) están nombradas con honestidad. Las `[NOTE FOR PM]` caen en tensiones reales (Either vs AsyncValue, Either vs "estado solo con Riverpod").

Hay dos fallas. Primero, hay desfase entre PRD y addendum: el Glosario (§3, entrada Errors) dice "en qué capa vive ... se decide en el coaching de arquitectura", pero el addendum T-1 ya decidió que `Errors` vive en `core/` y FR-12 Notas lo repite. La nota está obsoleta o es contradictoria. Segundo, la tensión central del documento no se enfrenta como tal. La Visión exige poder "defender línea por línea" el código, pero se eligen `freezed`, `riverpod_generator`, `Either` y un paquete funcional en 3 días. Solo T-5 menciona el costo, y SM-4 no se contrapone a T-4/T-5 (tampoco aparece en §8 ni en las contramétricas).

### Findings
- **medium** Nota de PM obsoleta frente al addendum (§3 Errors vs addendum T-1 / FR-12 Notas) — el Glosario presenta como abierto lo que ya está decidido. *Fix:* quitar la nota del Glosario o reducirla a "validar T-1 en arquitectura".
- **medium** Tensión "defender cada línea" vs código generado y abstracciones (§1, SM-4, addendum T-4/T-5) — no hay mitigación ni criterio de retirada (por ejemplo, "si en el día 2 `freezed` no compila con la versión elegida, se usan modelos manuales"). *Fix:* añadir una pregunta abierta o un `[NOTE FOR PM]` con el plan B, y vincular SM-4 a T-4/T-5.
- **low** T-2 "puede devolver Either" no es una decisión verificable (addendum T-2, §3 Errors) — "puede" deja el requisito sin criterio de cumplimiento. *Fix:* "los métodos del Repository devuelven X" o declarar la decisión explícitamente pendiente (Q4 ya lo cubre).

## Substance over theater — strong

Sin teatro de personas: una persona con nombre (Lucía) que sí impulsa UJ-1/UJ-2 y los FR, más dos JTBD. La Visión no es intercambiable con otra. Los NFR llevan umbrales concretos (`flutter analyze` 0 warnings, ≥3+1 pruebas Flutter, ≥2 Angular, 400 ms). El único ruido es duplicación: los NFR de funcionalidad (§4.2, §4.4, §4.5, §4.6) se repiten casi literalmente en NFR-5/NFR-6 (§4.8). Eso es mobiliario que invita a deriva.

### Findings
- **low** NFR duplicados entre §4.x y §4.8 (NFR-5, NFR-6 vs "NFR específicos" de §4.2/§4.5/§4.6, y FR-13 "sin `any`") — un cambio en uno deja al otro desfasado. *Fix:* dejar la definición en §4.8 y que las secciones por funcionalidad solo la referencien por ID.

## Strategic coherence — strong

Hay tesis (calidad, arquitectura por capas, pruebas, defensa oral), el alcance sigue de ella (obligatorios primero, regla de corte §6.2) y hay contramétricas explícitas (SM-C1, SM-C2) que protegen a SM-4. SM-1..SM-3 miden cumplimiento y no la tesis; SM-4 es la única que valida de verdad la comprensión. Para una prueba técnica es aceptable.

### Findings
- **low** SM-7 flota sin requisito que valide (§7 SM-7) — la entrega en 3 días no aparece en ningún FR/NFR ni en §6; solo Q1 la toca. *Fix:* añadir "Valida: restricción de plazo del PDF" y enlazarla a Q1.
- **low** SM-4 se autoevalúa ("ensayo antes de entregar") sin criterio de aprobación (§7 SM-4) — *Fix:* fijar un criterio (por ejemplo, explicar el flujo completo en ≤5 min con 2 preguntas de seguimiento respondidas).

## Done-ness clarity — adequate

La mayoría de los FR tiene consecuencias comprobables con números, endpoints y condiciones (FR-1, FR-3, FR-6..FR-9, FR-14). Fallan sobre todo los NFR cualitativos, y el vínculo con la fuente externa.

### Findings
- **high** FR-16 no tiene consecuencia visible para el usuario y deja a UJ-2 sin cumplir (§4.6 FR-16 vs §2.3 UJ-2 "Resolución: el pedido elegido se muestra con sus productos") — FR-16 titula "Ver el detalle de un Order", pero sus consecuencias solo describen el contrato `input()/output()` del componente y dicen que "el contenedor decide qué hacer con el evento". La ruta `/orders/:id` es DA-1 (deseable, fuera del MVP). Resultado: el MVP no define qué ocurre al pulsar "ver detalle", y la Resolución de UJ-2 no se puede verificar. *Fix:* definir el comportamiento mínimo del MVP (por ejemplo, el contenedor muestra los productos del Order seleccionado en un panel o sección) o recortar UJ-2 (quitar "ver detalle" del Recorrido y la Resolución) y renombrar FR-16 a "Emitir selección de un Order".
- **medium** El campo "usuario" del Order es ambiguo (§3 Order, FR-13, UJ-2) — "cada tarjeta muestra ... el usuario y el total" no dice qué dato es. La API de `/carts` expone un identificador de usuario; hay que verificar si hay nombre. *Fix:* nombrar el campo (`userId`) y declarar el formato.
- **medium** FR-14 no dice sobre qué total filtra (FR-14 vs FR-13 supuesto de "total con descuento") — si la tarjeta muestra total y total con descuento, "total mínimo" es ambiguo. Tampoco define entrada no numérica o negativa. *Fix:* fijar el campo (`total`) y el tratamiento de entrada inválida.
- **medium** Los conteos "9 obligatorios de Flutter, 7 de Angular" (§7 SM-3) no se reconcilian con los FR (Flutter = FR-1..12, 12 FR; Angular = FR-13..17, 5 FR) — vienen del PDF, no se pueden contrastar dentro del PRD. *Fix:* mapear cada obligatorio del PDF a un FR/NFR (tabla corta) o reemplazar por "FR-1..FR-21 y NFR-1..NFR-8 cumplidos".
- **medium** Adjetivos sin umbral (NFR-7 "interfaz ordenada y consistente"; NFR-5 "nombres claros y consistentes", "valores mágicos"; FR-15 "mensaje de error comprensible") — no testables. *Fix:* acotar con una comprobación (por ejemplo, "el mensaje de error no contiene texto técnico ni stack trace"; "sin literales numéricos en `lib/` fuera de constantes") o marcarlos explícitamente como juicio del evaluador.
- **low** Dos detalles de comportamiento sin cerrar (FR-7: "disminuir desde 1" no dice si el botón se deshabilita o es no-op; FR-3: no indica cuántos resultados de búsqueda se muestran, a diferencia de los 20 de FR-1). *Fix:* una línea de consecuencia por caso.
- **low** FR-18/FR-19 no se pueden verificar sin el PDF ("20 preguntas", "Fragmento A y B", "numeradas igual que en el PDF") — aceptable por contexto, pero no hay lista de verificación en el repo. *Fix:* un `Notas:` con los títulos de las 20 preguntas en `RESPUESTAS.md`, o el hash/nombre del PDF como fuente.

## Scope honesty — strong

§5 hace trabajo real, y §6.2 con IDs (DF/DA/B) y la regla de corte evitan que los extras entren por la puerta de atrás. Todo `[ASSUMPTION]` en línea está indexado en §9 (ver notas mecánicas). La densidad de abiertos (9 preguntas, 11 etiquetas de supuesto, 4 notas de PM) es razonable para una prueba de 3 días, aunque Q5, Q6 y Q7 (cliente HTTP, debounce, lints) son decisiones menores más que preguntas abiertas.

### Findings
- **medium** Solapamiento entre FR-12 y DF-5 (§4.5 FR-12 vs §6.2 DF-5) — DF-5 se describe como "ya cubierto por FR-12; este ítem solo extiende su uso a todas las capas", lo que deja la frontera obligatorio/deseable sin criterio verificable. *Fix:* o eliminar DF-5 y dejar FR-12 completo, o definir con precisión el delta ("DF-5 = errores tipados también en la capa X").
- **medium** Sin procedencia de los requisitos: no se distingue qué viene del PDF y qué lo inventó el PRD (§4, todo) — varias consecuencias son inferencias sin etiqueta (FR-1 "marcador visual si falta la imagen", NFR-8 "desde un clon limpio", FR-21 "repositorio público", FR-12 una subclase por tipo de falla). Como el PDF no está en el repo, el lector no puede auditar. *Fix:* sufijo `(PDF)` o `[ASSUMPTION]` en cada consecuencia según su origen.

## Downstream usability — adequate

Los IDs son contiguos y únicos (FR-1..21, NFR-1..8, SM-1..8 + C1/C2, UJ-1..2, T-1..5, DF-1..6, DA-1..5, B-1..2). Las referencias internas resuelven (§0 → §3, §9; FR-3 → FR-2; FR-7 → FR-8; FR-11/FR-20 → T-4; Q2/Q4 → T-n). Los archivos referenciados existen: brief.md y borrador-respuestas-parte1.md. El Glosario es completo, pero se usa con deriva (ver mecánicas), y hay dos esquemas de NFR (numerados en §4.8, sin ID en §4.x).

### Findings
- **medium** Deriva del Glosario pese a la promesa de §0 ("se usan sin sinónimos") — "listado"/"lista" por Catalog (UJ-1, FR-1, §4.2 NFR, FR-9, DF-1); "repositorio" en minúscula por Repository (FR-2 Notas "repositorio falso", Q-lista) mezclado con "repositorio" git (FR-20, FR-21), lo que produce ambigüedad real; "usuario" como actor en FR-1..12, "evaluador" en FR-13..17 y también "usuario" como campo del Order; "AppBar" y "detalle" no están en el Glosario. *Fix:* añadir "Detalle" y "AppBar" al Glosario; usar "Catalog" siempre; "repositorio git" vs "Repository"; unificar el actor (Evaluador) o definir "Usuario".
- **low** Glosario contradice el alcance — Catalog se define como "lista paginada" (§3), pero la paginación es DF-1 (fuera del MVP) y FR-1 pide solo los primeros 20. *Fix:* "lista de Products (en el MVP, los primeros 20)".
- **low** NFR de funcionalidad sin ID (§4.2, §4.4, §4.5, §4.6) — §6.1 solo referencia NFR-1..8, y no se pueden citar desde stories. *Fix:* numerarlos NFR-9.. o fusionarlos en §4.8.
- **low** Trazabilidad ritual: FR-10, FR-11, FR-12 y FR-17 citan UJ-1/UJ-2, aunque no son pasos del viaje; mientras que UJ-1 menciona cosas sin FR dueño ("el carrito conserva su contenido al volver al listado", abrir la pantalla del carrito). *Fix:* citar UJ solo cuando el FR realiza un paso; añadir una consecuencia a FR-9 o FR-6 sobre la conservación del Cart al navegar.
- **low** FR-18..FR-21 no citan UJ; §4.7 los ancla en "el objetivo de entrega del brief" (referencia externa), aunque §2.1 ya tiene el JTBD del Evaluador. *Fix:* citar el JTBD del Evaluador (§2.1) en lugar del brief.

## Shape fit — adequate

Es una prueba técnica solo con un desarrollador: el formato (2 UJs, un Glosario, NFR-con-umbral, regla de corte) es proporcionado. El mayor desajuste es que el PRD prescribe detalles de implementación en los FR ("provider `family`", `providedIn: 'root'`, `HttpClient`, `input()/output()`), mientras que a la vez difiere decisiones al coaching de arquitectura. Es defendible porque muchos vienen del PDF, pero sin marcar procedencia (ver Scope honesty) no se distingue requisito de preferencia.

### Findings
- **low** Fuga de solución en FR (FR-4, FR-13, FR-16) — mezcla qué con cómo. *Fix:* marcar los detalles que son del PDF y mover el resto a notas o al addendum.

## Mechanical notes

- **Numeración global FR:** FR-1..FR-21 contigua, sin huecos ni duplicados, en orden por funcionalidad (FR-1/2 → §4.1, FR-3 → §4.2, FR-4/5 → §4.3, FR-6..9 → §4.4, FR-10..12 → §4.5, FR-13..17 → §4.6, FR-18..21 → §4.7). OK. §6.1 ("FR-1 a FR-21") y SM-3 ("Valida FR-1 a FR-21") son coherentes con eso.
- **FR citando UJ:** FR-1..FR-17 citan UJ-1 o UJ-2 correctamente (FR-1..12 → UJ-1, FR-13..17 → UJ-2). FR-18..FR-21 no citan ninguno (ver hallazgo de §4.7). Todos los UJ citados existen. Ambos UJ tienen protagonista nombrada (Lucía) con contexto en línea.
- **Coherencia §4 / §6 / §7:** §6.1 coincide con §4. Las referencias "(deseable, ver §6)" en FR-1, FR-9 y FR-16 resuelven a §6.2 (DF-1/2, DF-3, DA-1). SM-8 enumera DF-1..DF-6, DA-1..DA-5, B-1, B-2, igual que la tabla de §6.2. SM-1..SM-6 validan IDs que existen (NFR-2, NFR-3, NFR-4, FR-10, FR-12, NFR-1, FR-20, FR-21). Incoherencias: SM-3 usa conteos del PDF sin mapa a FR (9/7); SM-7 no valida ningún requisito; NFR-5..NFR-8 y FR-18/FR-19 no tienen SM propia (solo el cubrimiento global de SM-3); DF-5 se solapa con FR-12; UJ-2 vs FR-16/DA-1.
- **Índice de supuestos (§9), roundtrip:** las 11 etiquetas `[ASSUMPTION]` en línea (UJ-1 y UJ-2 en §2.3; FR-2; FR-3; FR-5; FR-7; FR-9 ×2; FR-13; FR-14; y la nota de FR-21 sobre FR-18/FR-19) están todas en §9, y todas las entradas del índice aparecen en línea. OK. Detalles menores: la entrada "§4.7" corresponde a una nota que está dentro de FR-21 (mejor "FR-21 Notas / FR-18, FR-19"); FR-9 agrupa dos supuestos en una entrada; el índice no tiene IDs (A-1..) para citar. Hay inferencias sin etiquetar (ver Scope honesty).
- **Referencias externas:** brief.md y borrador-respuestas-parte1.md existen en las rutas esperadas. El PDF queda fuera del repo, por diseño (FR-21 lo prohíbe); toda verificabilidad de FR-18/FR-19 y de los conteos de SM-3 depende de él.
- **Esquemas de ID:** DF-/DA-/B- mezclan dos criterios (parte vs tipo); sin impacto funcional. Las `[NOTE FOR PM]` de §3, FR-3, FR-12 y §6.2 son 4; la de §6.2 (riverpod_generator no figura) es explicativa, no una tensión real.
- **Formato:** la nota de §6.2 anida backticks dentro de un bloque con backticks (se rompe el render); FR-21 repite "Fuera de alcance" ya cubierto por §5.
- **Secciones requeridas:** para el tamaño y el contexto, presentes y suficientes (Visión, usuarios, Glosario, FR, No objetivos, MVP, SM, Preguntas abiertas, Índice de supuestos).

## Dimension verdicts (resumen)

- Decision-readiness — adequate
- Substance over theater — strong
- Strategic coherence — strong
- Done-ness clarity — adequate
- Scope honesty — strong
- Downstream usability — adequate
- Shape fit — adequate

Conteo de hallazgos: critical 0, high 1, medium 9, low 11 (en las secciones de dimensión).

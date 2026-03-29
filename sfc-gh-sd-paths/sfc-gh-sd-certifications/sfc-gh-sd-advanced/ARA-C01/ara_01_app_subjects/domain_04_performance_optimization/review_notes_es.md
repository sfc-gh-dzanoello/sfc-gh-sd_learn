# Dominio 4: Rendimiento — Herramientas, Mejores Prácticas y Solución de Problemas

> **Peso ARA-C01:** ~20-25% del examen. Este es un dominio de ALTA PRIORIDAD.
> Enfócate en: interpretación de Query Profile, dimensionamiento de warehouses, capas de caching, clustering y servicios de rendimiento.

---

## 4.1 QUERY PROFILE

El Query Profile es tu **herramienta de diagnóstico más importante** en Snowflake.

### Conceptos clave

- Acceso vía: **pestaña History → consulta → Query Profile** (o `GET_QUERY_OPERATOR_STATS()`)
- Muestra un **DAG (grafo acíclico dirigido)** de operadores — los datos fluyen de abajo hacia arriba
- Cada nodo de operador muestra: **% del tiempo total**, filas procesadas, bytes escaneados

**Operadores críticos que debes conocer:**

| Operador | Qué hace | Señal de alerta |
|----------|----------|-----------------|
| TableScan | Lee micro-partitions | Alta cantidad de particiones escaneadas vs. total = mal pruning |
| Filter | Aplica cláusulas WHERE | Debería aparecer DESPUÉS del pruning, no en lugar de él |
| Aggregate | GROUP BY / DISTINCT | Alta memoria = posible spilling |
| SortWithLimit | ORDER BY + LIMIT | Costoso en conjuntos de datos grandes |
| JoinFilter | Hash join / merge join | Explosión de filas = mala condición de join |
| ExternalScan | Tablas externas / stages | Siempre más lento que tablas nativas |
| WindowFunction | Cláusulas OVER() | Uso intensivo de memoria, atención al spilling |
| Flatten | Expansión de VARIANT/array | Riesgo de explosión de filas |

**Indicadores de spilling:**

- **Bytes spilled to local storage** — se usa el SSD del warehouse (problema moderado)
- **Bytes spilled to remote storage** — se usa S3/Azure Blob/GCS (problema SEVERO)
- Solución: usar un **warehouse más grande** (más memoria/SSD) u optimizar la consulta

**Estadísticas de pruning (en TableScan):**

- **Partitions scanned** vs. **Partitions total** — el objetivo es que escaneadas << total
- Si escaneadas ≈ total → falta la clustering key o el filtro no coincide con el clustering

### Por qué es importante

Tienes una consulta de reporte que tarda 45 minutos. Query Profile muestra un JoinFilter con 50B filas de salida de dos tablas de 10M filas. A la condición de join le falta una columna clave — join cartesiano. Sin Query Profile, simplemente aumentarías el tamaño del warehouse y desperdiciarías créditos.

### Mejores prácticas

- Revisa primero el panel **"Most Expensive Nodes"** — los 1-2 nodos principales suelen ser el cuello de botella
- Mira **Statistics → Spilling** antes de aumentar el tamaño de los warehouses
- Usa `SYSTEM$EXPLAIN_PLAN()` para verificaciones rápidas sin ejecutar la consulta
- Compara las estadísticas de pruning antes y después de agregar clustering keys

**Trampas del examen:**

- Trampa del examen: SI VES "La consulta es lenta, aumenta el tamaño del warehouse" → INCORRECTO porque deberías diagnosticar con Query Profile primero; el problema podría ser un mal join o un filtro faltante, no insuficiente cómputo
- Trampa del examen: SI VES "Spilling al disco local es un problema crítico" → INCORRECTO porque el spilling local es una preocupación moderada; el spilling a **almacenamiento remoto** es el severo
- Trampa del examen: SI VES "Query Profile muestra el plan de ejecución antes de ejecutar" → INCORRECTO porque Query Profile muestra estadísticas de **ejecución real**; usa `EXPLAIN_PLAN` para planes pre-ejecución

### Preguntas frecuentes (FAQ)

**P: ¿Puedo ver el Query Profile de consultas ejecutadas por otros usuarios?**
R: Sí, si tienes ACCOUNTADMIN o privilegio MONITOR en el warehouse. De lo contrario, solo ves tus propias consultas.

**P: ¿Cuánto tiempo se retienen los Query Profiles?**
R: 14 días en la interfaz web. Usa ACCOUNT_USAGE.QUERY_HISTORY para hasta 365 días (pero sin el DAG visual).


### Ejemplos de Preguntas de Escenario — Query Profile

**Escenario:** A nightly reporting job that used to complete in 10 minutes now takes 3 hours. The data engineering team's first instinct is to upsize the warehouse from Large to 2XL. Before approving the cost increase, what should the architect require?
**Respuesta:** Require a Query Profile analysis before any warehouse resizing. Open the Query Profile for the slow query and check: (1) the "Most Expensive Nodes" panel to identify the bottleneck operator, (2) spilling statistics — if the query spills to remote storage, upsizing may help; if there's no spilling, more compute won't help, (3) TableScan pruning stats — if partitions scanned is close to partitions total, the issue is poor pruning (fix with clustering keys, not bigger warehouse), (4) JoinFilter — check for row explosion from bad join conditions. The root cause is often a missing filter, a cartesian join, or degraded clustering — none of which are fixed by upsizing.

**Escenario:** An analyst reports that a join between two 10-million-row tables produces a Query Profile showing a JoinFilter operator with 50 billion output rows. The warehouse eventually runs out of memory and the query fails. What is the likely root cause and how should the architect fix it?
**Respuesta:** The 50 billion rows from a join of two 10M-row tables indicates a cartesian or near-cartesian join — the join condition is either missing a key column or using a non-selective predicate. Check the Query Profile's JoinFilter node for the join condition. The fix is correcting the SQL join logic (adding the missing key column), not upsizing the warehouse. Even a 6XL warehouse cannot efficiently process 50 billion rows from what should be a 10M-row result. Use `SYSTEM$EXPLAIN_PLAN()` to verify the corrected query plan before running it.

---

---

## 4.2 WAREHOUSES

Los warehouses son tus **motores de cómputo**. Dimensionarlos correctamente es la palanca de costo #1.

### Conceptos clave

**Tamaños de warehouse (tallas de camiseta):**

| Tamaño | Nodos | Créditos/hr | Caso de uso |
|--------|-------|-------------|-------------|
| X-Small | 1 | 1 | Desarrollo, consultas simples |
| Small | 2 | 2 | Analítica ligera |
| Medium | 4 | 4 | Cargas de trabajo moderadas |
| Large | 8 | 8 | Joins complejos, transformaciones |
| X-Large | 16 | 16 | ETL pesado |
| 2XL–6XL | 32–128 | 32–128 | Cargas de trabajo masivas |

**Regla del doble:** Cada tamaño superior = **2x nodos, 2x créditos, 2x memoria/SSD**. NO garantiza 2x de velocidad.

**Snowpark-Optimized Warehouses:**

- 16x más memoria por nodo que los estándar
- Propósito: entrenamiento de ML, UDFs grandes, Snowpark DataFrames, UDTFs en Java/Python
- Costo: ~1.5x más créditos por hora que un warehouse estándar del mismo tamaño

**Multi-cluster warehouses (Enterprise+):**

- Configuraciones de **Min clusters** y **Max clusters**
- **Políticas de escalamiento:**
  - **Standard (por defecto):** Inicia un nuevo cluster cuando una consulta queda en cola. Reducción conservadora.
  - **Economy:** Espera hasta que haya suficiente carga para mantener un nuevo cluster ocupado por 6 minutos. Ahorra créditos pero aumenta el tiempo en cola.

**Auto-suspend / Auto-resume:**

- Auto-suspend: se configura en **segundos** (mínimo 60s, o 0 para inmediato)
- Auto-resume: `TRUE` por defecto — el warehouse se inicia cuando una consulta lo necesita
- Los warehouses suspendidos consumen **cero créditos**
- Cada reanudación implica tiempo de aprovisionamiento (~1-2 segundos típicamente)

### Por qué es importante

Tu equipo de ingeniería de datos ejecuta ETL a las 2 AM en un warehouse 2XL que se auto-suspende después de 10 minutos. Pero 50 consultas pequeñas llegan cada pocos minutos durante el día, cada una reanudando el warehouse. Estás pagando créditos de 2XL para cargas de trabajo X-Small. Solución: separar warehouses por tipo de carga de trabajo.

### Mejores prácticas

- **Separa warehouses por carga de trabajo** (ETL vs. BI vs. ciencia de datos)
- Comienza pequeño, escala solo después de revisar Query Profile
- Auto-suspend: **60 segundos** para ETL, **300-600 segundos** para BI (evita reanudaciones constantes)
- Usa la política de escalamiento **Economy** para cargas tolerantes a latencia y sensibles al costo
- Usa la política de escalamiento **Standard** para cargas orientadas al usuario y sensibles a latencia

**Trampas del examen:**

- Trampa del examen: SI VES "Un warehouse más grande siempre significa consultas más rápidas" → INCORRECTO porque la velocidad de consulta depende del cuello de botella; un mal plan de consulta no mejorará con más cómputo
- Trampa del examen: SI VES "Multi-cluster warehouses ejecutan una sola consulta en múltiples clusters" → INCORRECTO porque cada cluster ejecuta consultas separadas; multi-cluster es para **concurrencia**, no paralelismo de una sola consulta
- Trampa del examen: SI VES "Snowpark-optimized warehouses siempre son mejores" → INCORRECTO porque cuestan más y solo ayudan con cargas de trabajo intensivas en memoria (ML, UDFs grandes); el estándar está bien para SQL
- Trampa del examen: SI VES "Auto-suspend 0 significa nunca suspender" → INCORRECTO porque `AUTO_SUSPEND = 0` significa suspender inmediatamente cuando esté inactivo; `NULL` deshabilita el auto-suspend

### Preguntas frecuentes (FAQ)

**P: ¿El tamaño del warehouse afecta el tiempo de compilación?**
R: No. La compilación ocurre en el cloud services layer, no en el warehouse.

**P: ¿Puedo redimensionar un warehouse mientras hay consultas ejecutándose?**
R: Sí. Las consultas en ejecución usan el tamaño anterior; las nuevas consultas usan el nuevo tamaño.


### Ejemplos de Preguntas de Escenario — Warehouses

**Escenario:** A company uses a single 2XL warehouse for all workloads: ETL at 2 AM, BI dashboards during business hours, and ad-hoc data science queries throughout the day. BI users complain about slow dashboards during ETL runs, and costs are high because the 2XL runs 24/7. How should the architect redesign the warehouse strategy?
**Respuesta:** Separate warehouses by workload type. Create a dedicated ETL warehouse (Large or XL, auto-suspend 60 seconds) that runs only during the 2 AM batch window. Create a BI warehouse (Medium, multi-cluster with Standard scaling policy, auto-suspend 300-600 seconds) for dashboard queries — the multi-cluster handles concurrency spikes during business hours, and the longer auto-suspend avoids constant resume overhead and preserves SSD cache. Create a data science warehouse (Snowpark-optimized if running ML/UDFs, standard otherwise, auto-suspend 120 seconds). This eliminates contention between workloads and right-sizes each warehouse independently.

**Escenario:** A data science team runs ML training jobs using Snowpark Python UDFs that process large in-memory datasets. Jobs frequently fail with out-of-memory errors on a standard XL warehouse. What should the architect recommend?
**Respuesta:** Switch to a Snowpark-optimized warehouse. Snowpark-optimized warehouses provide 16x more memory per node compared to standard warehouses — specifically designed for memory-intensive workloads like ML training, large UDFs, and Snowpark DataFrames. The cost is approximately 1.5x more credits per hour than a standard warehouse of the same size, but the increased memory eliminates OOM failures and reduces spilling. Do not simply upsize to a standard 4XL — that adds compute nodes but doesn't provide the same memory density per node as a Snowpark-optimized warehouse.

---

---

## 4.3 CACHING

Snowflake tiene **tres capas de caching**. Entenderlas es crítico para el examen y la vida real.

### Conceptos clave

**1. Result Cache (Cloud Services Layer)**

- Almacena **resultados exactos de consultas** por 24 horas
- Se reutiliza cuando: mismo texto de consulta + mismos datos (sin cambios subyacentes) + mismo rol
- **Gratuito** — no se necesita warehouse
- Persiste incluso si el warehouse está suspendido
- Se invalida cuando los datos subyacentes cambian (DML) o pasan 24 horas
- Se puede deshabilitar: `ALTER SESSION SET USE_CACHED_RESULT = FALSE;`

**2. Metadata Cache (Cloud Services Layer)**

- Almacena min/max/count/null_count por micro-partition por columna
- Potencia: `SELECT COUNT(*)`, `MIN()`, `MAX()` en tablas completas — **instantáneo, sin warehouse**
- Siempre activo, no se puede deshabilitar

**3. Local Disk Cache (SSD del Warehouse)**

- Almacena en caché **datos crudos de micro-partitions** en el SSD del warehouse
- Se pierde cuando el warehouse se suspende (SSD se limpia)
- Compartido entre consultas en el mismo warehouse
- Ayuda con escaneos repetidos de los mismos datos dentro de una sesión
- Razón por la cual un auto-suspend más largo a veces puede ahorrar dinero (evita re-obtener datos)

### Por qué es importante

Un dashboard se refresca cada 5 minutos con las mismas 10 consultas. Si los datos subyacentes no han cambiado, las 10 consultas usan el result cache — cero créditos de warehouse. Pero si alguien inserta una fila, los 10 cachés se invalidan y el warehouse se activa. Entender esto determina la programación de tu ELT.

### Mejores prácticas

- Programa las cargas de datos en intervalos predecibles para que el result cache se mantenga válido entre cargas
- No deshabilites el result cache a menos que estés depurando
- Equilibra el timeout de auto-suspend: muy corto = pierdes caché SSD; muy largo = desperdicias créditos
- Usa warehouses dedicados por carga de trabajo para maximizar los aciertos de caché SSD
- El metadata cache significa que `SELECT COUNT(*) FROM tabla_grande` siempre es instantáneo — no necesitas cachear esto por tu cuenta

**Trampas del examen:**

- Trampa del examen: SI VES "El result cache funciona entre diferentes roles" → INCORRECTO porque el result cache es **específico por rol**; misma consulta con diferentes roles = fallo de caché
- Trampa del examen: SI VES "Suspender un warehouse limpia el result cache" → INCORRECTO porque el result cache vive en el **cloud services layer**, no en el warehouse; el caché SSD/disco local es el que se limpia
- Trampa del examen: SI VES "El result cache dura 24 horas sin importar qué" → INCORRECTO porque cualquier DML en las tablas subyacentes **invalida** el caché inmediatamente

### Preguntas frecuentes (FAQ)

**P: ¿El result cache cuenta para la facturación de cloud services?**
R: No. La recuperación del result cache es gratuita. La facturación de cloud services solo se activa si cloud services excede el 10% del cómputo total.

**P: Si dos usuarios ejecutan la misma consulta con el mismo rol, ¿el usuario B se beneficia del result cache del usuario A?**
R: Sí — el result cache se comparte entre usuarios si el texto de la consulta, el rol y los datos son idénticos.


### Ejemplos de Preguntas de Escenario — Caching

**Escenario:** A BI dashboard refreshes 20 queries every 5 minutes. The underlying data is only updated once per hour via a scheduled ETL job. The architect notices the BI warehouse is consuming significant credits despite the data being mostly static. How should caching be optimized?
**Respuesta:** Between ETL runs (55 minutes out of every hour), all 20 queries should hit the result cache since the underlying data hasn't changed and the queries use the same role. The result cache is free — no warehouse credits consumed. Verify that: (1) result cache is not disabled (`USE_CACHED_RESULT = TRUE`), (2) all dashboard queries use the same role (result cache is role-specific), (3) the ETL job doesn't do unnecessary DML that would invalidate the cache prematurely. If the dashboard auto-refreshes with slightly different query text each time (e.g., dynamic timestamps), standardize the query text to maximize cache hits. This should reduce warehouse usage by ~90%.

**Escenario:** An analytics team sets warehouse auto-suspend to 10 seconds to save credits. However, they notice that recurring queries throughout the day are slower than expected, and the warehouse is constantly resuming and suspending. What is happening and how should the architect fix it?
**Respuesta:** The 10-second auto-suspend is clearing the local disk cache (warehouse SSD) too frequently. When the warehouse suspends, all cached micro-partition data on the SSD is lost. When it resumes, queries must re-fetch data from remote storage, making them slower. Increase the auto-suspend to 300-600 seconds for BI workloads — this keeps the SSD cache warm between queries, reducing remote storage reads. The slightly higher idle cost (a few minutes of credits) is offset by faster queries and fewer resume cycles. For ETL warehouses that run in discrete bursts, 60 seconds is appropriate since there's no cache to preserve between jobs.

---

---

## 4.4 CLUSTERING Y PRUNING

El pruning de micro-partitions es cómo Snowflake evita escaneos completos de tabla. El clustering controla cómo se organizan los datos.

### Conceptos clave

**Micro-partitions:**

- Snowflake almacena datos en micro-partitions comprimidas de 50-500 MB (inmutables, columnares)
- Cada partición tiene **metadatos**: valores min/max por columna
- Las consultas usan estos metadatos para **omitir** particiones irrelevantes = pruning

**Clustering natural:**

- Los datos se organizan por **orden de ingestión** por defecto
- Funciona muy bien si siempre filtras por una columna de timestamp y cargas datos cronológicamente
- Se degrada con inserciones aleatorias, actualizaciones o merges a lo largo del tiempo

**Clustering keys:**

- Se definen con `ALTER TABLE ... CLUSTER BY (col1, col2)`
- Mejor para: tablas grandes (multi-TB), columnas frecuentemente filtradas, cardinalidad baja a media
- El servicio **Automatic Clustering** de Snowflake reorganiza los datos en segundo plano (serverless, consume créditos)
- Verifica la calidad del clustering: `SYSTEM$CLUSTERING_INFORMATION('table', '(col)')`
  - `average_depth` — menor es mejor (1.0 = perfecto)
  - `average_overlap` — menor es mejor (0.0 = sin superposición)

**Guías para selección de claves:**

- Elige columnas usadas en WHERE, JOIN, ORDER BY
- Máximo 3-4 columnas en una clustering key
- Coloca **columnas de baja cardinalidad primero** (ej., `region` antes de `order_id`)
- Se permiten expresiones: `CLUSTER BY (TO_DATE(created_at), region)`

### Por qué es importante

Una tabla de hechos de 500 TB con `WHERE event_date = '2025-01-15'` escanea 500 TB sin clustering. Con `CLUSTER BY (event_date)`, escanea quizás 100 MB. Esa es la diferencia entre una consulta de 30 minutos y una consulta de 2 segundos.

### Mejores prácticas

- Solo aplica clustering a tablas > 1 TB (o con mal pruning visible en Query Profile)
- Monitorea los créditos de auto-clustering en ACCOUNT_USAGE.AUTOMATIC_CLUSTERING_HISTORY
- No hagas clustering por columnas de alta cardinalidad solas (ej., UUID) — ineficaz
- Combina con columnas basadas en tiempo para tablas de eventos/logs: `CLUSTER BY (TO_DATE(ts), category)`
- Reevalúa las clustering keys trimestralmente a medida que evolucionan los patrones de consulta

**Trampas del examen:**

- Trampa del examen: SI VES "Las clustering keys ordenan los datos como un índice tradicional" → INCORRECTO porque Snowflake no tiene índices; las clustering keys guían la **organización de micro-partitions** para mejor pruning
- Trampa del examen: SI VES "Deberías aplicar clustering a cada tabla" → INCORRECTO porque las tablas pequeñas no se benefician; el clustering tiene un costo de mantenimiento continuo (créditos de auto-clustering)
- Trampa del examen: SI VES "Las clustering keys son gratuitas de mantener" → INCORRECTO porque el Automatic Clustering es una **funcionalidad serverless que consume créditos**
- Trampa del examen: SI VES "Una columna de alta cardinalidad es la mejor clustering key" → INCORRECTO porque la cardinalidad baja a media proporciona mejor pruning de particiones; alta cardinalidad significa demasiados valores distintos por partición

### Preguntas frecuentes (FAQ)

**P: ¿Puedo tener múltiples clustering keys en una tabla?**
R: No. Una clustering key por tabla, pero puede ser una **clave compuesta** con múltiples columnas.

**P: ¿El clustering afecta el rendimiento de DML?**
R: No directamente. Pero el Automatic Clustering se ejecuta en segundo plano y consume créditos serverless cuando los datos cambian.


### Ejemplos de Preguntas de Escenario — Clustering & Pruning

**Escenario:** A 200 TB event log table is queried primarily by `event_date` and `region`. Queries filtering by `event_date` alone are fast, but queries filtering by both `event_date` and `region` still scan 60% of partitions. The table currently has `CLUSTER BY (event_date)`. How should the architect improve pruning?
**Respuesta:** Change the clustering key to a compound key: `ALTER TABLE events CLUSTER BY (TO_DATE(event_ts), region)`. Put the lower-cardinality column (`region`, perhaps 10-20 values) first for maximum pruning efficiency, followed by the date expression. This organizes micro-partitions so that data for a specific region and date is co-located, allowing queries with both filters to prune much more aggressively. After changing the key, monitor `SYSTEM$CLUSTERING_INFORMATION('events', '(TO_DATE(event_ts), region)')` — `average_depth` should decrease toward 1.0 and `average_overlap` toward 0.0 over time as Automatic Clustering reorganizes data. Monitor auto-clustering credits in `AUTOMATIC_CLUSTERING_HISTORY`.

**Escenario:** A product manager asks the architect to add clustering keys to all 500 tables in the analytics database to "make everything faster." What should the architect's response be?
**Respuesta:** Clustering should only be applied to large tables (typically >1 TB) with demonstrably poor pruning visible in Query Profile. Small tables fit in a few micro-partitions and don't benefit from clustering — Snowflake already scans all partitions quickly. Clustering also has ongoing maintenance costs: Automatic Clustering is a serverless feature that consumes credits whenever data changes. For the 500 tables, the architect should analyze Query Profile pruning statistics and `SYSTEM$CLUSTERING_INFORMATION` for the top 10-20 most-queried large tables first, then only apply clustering where partitions scanned is significantly higher than necessary. Re-evaluate clustering keys quarterly as query patterns evolve.

---

---

## 4.5 SERVICIOS DE RENDIMIENTO

Tres servicios serverless que aceleran patrones de consulta específicos.

### Conceptos clave

**1. Query Acceleration Service (QAS)**

- Descarga **porciones** de una consulta a cómputo serverless compartido
- Mejor para: consultas con escaneos grandes + filtros selectivos (analítica ad-hoc)
- Se habilita por warehouse: `ALTER WAREHOUSE SET ENABLE_QUERY_ACCELERATION = TRUE;`
- `QUERY_ACCELERATION_MAX_SCALE_FACTOR` — limita el cómputo serverless (0 = ilimitado, por defecto 8)
- Verifica elegibilidad: `SYSTEM$ESTIMATE_QUERY_ACCELERATION('query_id')`
- **No ayuda con:** consultas limitadas por operaciones de un solo hilo, escaneos pequeños o cuellos de botella de CPU

**2. Search Optimization Service (SOS)**

- Construye una **ruta de acceso de búsqueda persistente, mantenida por el servidor**
- Mejor para: **búsquedas puntuales selectivas** en tablas grandes (WHERE id = X, CONTAINS, GEO)
- Soporta: predicados de igualdad, IN, SUBSTRING, funciones GEOGRAPHY/GEOMETRY, campos VARIANT
- Se habilita por tabla o por columna: `ALTER TABLE t ADD SEARCH OPTIMIZATION ON EQUALITY(col)`
- Costos: créditos serverless para construcción + almacenamiento para estructuras de búsqueda
- **No ayuda con:** escaneos de rango, analítica de tabla completa, tablas pequeñas

**3. Materialized Views (MVs)**

- Resultados de consulta pre-computados, mantenidos automáticamente, almacenados como micro-partitions
- Mejor para: subconsultas repetidas, pre-agregaciones, subconjuntos comúnmente unidos
- Snowflake **auto-refresca** las MVs cuando la tabla base cambia (créditos serverless)
- El optimizador de consultas puede **auto-reescribir** consultas para usar MVs incluso si no se referencian directamente
- Limitaciones: solo una tabla base, sin joins, sin UDFs, sin HAVING, funciones de ventana limitadas
- Requiere Enterprise Edition

### Por qué es importante

Una plataforma de analítica tiene 200 usuarios ejecutando consultas ad-hoc en una tabla de 100 TB. Algunas consultas escanean 80 TB, otras escanean 100 MB. QAS ayuda a las consultas de escaneo grande a compartir cómputo serverless. SOS ayuda a las consultas de búsqueda puntual a ir directamente a las particiones correctas. Las MVs pre-computan las 10 agregaciones principales del dashboard.

### Mejores prácticas

- QAS: habilitar en warehouses que sirven patrones de consulta **impredecibles, ad-hoc**
- SOS: usar para patrones de búsqueda de **alta selectividad conocida** (búsquedas por ID, filtros de búsqueda)
- MVs: usar para agregaciones o vistas filtradas **estables y repetidas**
- Monitorea los tres en ACCOUNT_USAGE: historial de QAS, historial de SOS, historial de refresco de MVs
- No habilites los tres a ciegas — cada uno tiene costos serverless continuos

**Trampas del examen:**

- Trampa del examen: SI VES "QAS reemplaza el warehouse por completo" → INCORRECTO porque QAS **complementa** al warehouse; el warehouse aún ejecuta la consulta, QAS descarga las porciones intensivas en escaneo
- Trampa del examen: SI VES "Search Optimization es como un índice B-tree tradicional" → INCORRECTO porque es una **ruta de acceso de búsqueda** mantenida serverlessly; no es un índice administrado por el usuario
- Trampa del examen: SI VES "Las materialized views pueden unir múltiples tablas" → INCORRECTO porque las MVs en Snowflake soportan **solo una tabla base** — sin joins
- Trampa del examen: SI VES "Las materialized views deben ser referenciadas en la consulta para usarse" → INCORRECTO porque el optimizador puede **auto-reescribir** consultas para usar MVs de forma transparente

### Preguntas frecuentes (FAQ)

**P: ¿Se pueden usar QAS y Search Optimization juntos?**
R: Sí. Resuelven problemas diferentes — QAS para escaneos grandes, SOS para búsquedas puntuales.

**P: ¿Las materialized views consumen almacenamiento?**
R: Sí. Se almacenan como micro-partitions y contribuyen a tu factura de almacenamiento.


### Ejemplos de Preguntas de Escenario — Performance Services

**Escenario:** An analytics platform serves 200 analysts running ad-hoc queries on a 100 TB sales fact table. Some queries scan 80 TB (broad date ranges), while others look up individual orders by `order_id`. The warehouse is frequently overloaded. Which performance services should the architect enable?
**Respuesta:** Enable Query Acceleration Service (QAS) on the warehouse to help large-scan ad-hoc queries offload scan-intensive portions to shared serverless compute. For the point-lookup queries by `order_id`, add Search Optimization Service (SOS) on the `order_id` column: `ALTER TABLE sales ADD SEARCH OPTIMIZATION ON EQUALITY(order_id)`. SOS builds a persistent search access path for selective point lookups, skipping directly to the relevant partitions. For the most common dashboard aggregations that are queried repeatedly, create materialized views (MVs) on single-table aggregations — the optimizer auto-rewrites queries to use them. Each service addresses a different query pattern: QAS for large scans, SOS for point lookups, MVs for repeated aggregations. Monitor serverless costs for all three via ACCOUNT_USAGE.

**Escenario:** A BI team's top-10 dashboard shows pre-aggregated metrics (total sales by region, average order value by category) from a single large fact table. These queries run every 5 minutes and always return the same aggregation patterns. The architect wants to pre-compute these results. Should they use a materialized view or a dynamic table?
**Respuesta:** Use a materialized view (MV). MVs are purpose-built for single-table aggregations with no joins — exactly this use case. Snowflake auto-refreshes the MV when the base table changes (serverless credits) and the optimizer can auto-rewrite queries to use the MV even if the query doesn't reference it directly. A dynamic table would also work but is heavier — dynamic tables are better suited for multi-table transformations with joins, which MVs don't support. For simple single-table aggregations, MVs are more efficient and integrate transparently with the optimizer. Enterprise edition is required.

---

---

## 4.6 SOLUCIÓN DE PROBLEMAS

Saber dónde buscar y qué herramientas usar.

### Conceptos clave

**INFORMATION_SCHEMA vs. ACCOUNT_USAGE:**

| Característica | INFORMATION_SCHEMA | ACCOUNT_USAGE |
|----------------|-------------------|---------------|
| Latencia | Tiempo real | 15 min – 3 hr de retraso |
| Retención | 7 días–6 meses (varía) | **365 días** |
| Alcance | Base de datos actual | Toda la cuenta |
| Objetos eliminados | No incluidos | **Incluidos** |
| Acceso | Cualquier rol con acceso a la BD | ACCOUNTADMIN (o concedido) |

**Vistas clave de ACCOUNT_USAGE para rendimiento:**

- `QUERY_HISTORY` — todas las consultas, tiempo de ejecución, bytes escaneados, warehouse, errores
- `WAREHOUSE_METERING_HISTORY` — consumo de créditos por warehouse
- `AUTOMATIC_CLUSTERING_HISTORY` — uso de créditos de auto-clustering
- `SEARCH_OPTIMIZATION_HISTORY` — uso de créditos de SOS
- `MATERIALIZED_VIEW_REFRESH_HISTORY` — uso de créditos de refresco de MVs
- `QUERY_ACCELERATION_HISTORY` — uso de créditos de QAS
- `STORAGE_USAGE` — tendencias de almacenamiento a lo largo del tiempo
- `LOGIN_HISTORY` — problemas de autenticación

**Resource Monitors:**

- Rastrean **consumo de créditos** a nivel de cuenta o warehouse
- Acciones en umbrales: **Notify, Notify & Suspend, Notify & Suspend Immediately**
- Se configuran con: `CREATE RESOURCE MONITOR` + asignar a warehouse o cuenta
- Solo ACCOUNTADMIN puede crear monitores a nivel de cuenta
- Se puede establecer **hora de inicio, frecuencia (diaria/semanal/mensual), cuota de créditos**

**Alerts y Event Tables:**

- **Alerts** (`CREATE ALERT`): verificaciones programadas de condiciones SQL → activan acción (email, task, etc.)
- **Event Table**: almacén centralizado de **logs, traces, métricas** de UDFs, procedimientos, Streamlit
- Una event table por cuenta: `ALTER ACCOUNT SET EVENT_TABLE = db.schema.events`
- Consulta datos de eventos con SQL estándar: `SELECT * FROM db.schema.events WHERE ...`

**Logging y Tracing:**

- Configurar nivel de log: `ALTER SESSION SET LOG_LEVEL = 'INFO';` (OFF, TRACE, DEBUG, INFO, WARN, ERROR, FATAL)
- Configurar nivel de trace: `ALTER SESSION SET TRACE_LEVEL = 'ON_EVENT';` (OFF, ALWAYS, ON_EVENT)
- Los logs van a la **event table** — consultable vía SQL
- Disponible en UDFs (Python, Java, Scala, JavaScript), stored procedures, aplicaciones Streamlit

### Por qué es importante

El dashboard de producción está lento. Revisas ACCOUNT_USAGE.QUERY_HISTORY y encuentras 500 consultas en cola en un solo warehouse. Los resource monitors muestran que estás quemando 2x los créditos esperados. Los alerts que configuraste detectaron el pico y enviaron email al equipo. Sin estas herramientas, no te enterarías hasta que los usuarios se quejaran.

### Mejores prácticas

- Usa ACCOUNT_USAGE para análisis histórico (retención de 365 días)
- Usa INFORMATION_SCHEMA para depuración en tiempo real (sesión/base de datos actual)
- Configura resource monitors en **cada warehouse de producción** — no es negociable
- Crea alerts para: consultas de larga duración, spilling, profundidad de cola del warehouse, fallos de login
- Habilita logging (nivel INFO como mínimo) para todas las UDFs y procedimientos de producción
- Revisa WAREHOUSE_METERING_HISTORY semanalmente para detectar anomalías de costo temprano

**Trampas del examen:**

- Trampa del examen: SI VES "INFORMATION_SCHEMA tiene retención de 365 días" → INCORRECTO porque eso es **ACCOUNT_USAGE**; INFORMATION_SCHEMA varía (7 días a 6 meses por vista)
- Trampa del examen: SI VES "Los resource monitors pueden limitar costos de almacenamiento" → INCORRECTO porque los resource monitors solo rastrean **créditos de cómputo**, no almacenamiento
- Trampa del examen: SI VES "Los datos de ACCOUNT_USAGE son en tiempo real" → INCORRECTO porque ACCOUNT_USAGE tiene **15 minutos a 3 horas de latencia**
- Trampa del examen: SI VES "Cualquier rol puede crear resource monitors a nivel de cuenta" → INCORRECTO porque solo **ACCOUNTADMIN** puede crear resource monitors a nivel de cuenta

### Preguntas frecuentes (FAQ)

**P: ¿Puedo otorgar acceso a ACCOUNT_USAGE a roles que no sean ACCOUNTADMIN?**
R: Sí. Otorga los `IMPORTED PRIVILEGES` en la base de datos SNOWFLAKE a cualquier rol.

**P: ¿Los resource monitors impiden que las consultas se inicien?**
R: Con "Suspend Immediately", sí — las consultas en ejecución se terminan y las nuevas se bloquean. Con "Suspend", las consultas en ejecución terminan pero no se inician nuevas.

**P: ¿Cuál es la diferencia entre un Alert y un Task?**
R: Un Task se ejecuta en un horario de forma incondicional. Un Alert se ejecuta en un horario pero **solo activa su acción si una condición SQL es verdadera**.


### Ejemplos de Preguntas de Escenario — Troubleshooting

**Escenario:** A production data platform has no cost controls in place. Last month, a developer accidentally left a 4XL warehouse running over a weekend, consuming $15,000 in credits. The CFO demands guardrails. What monitoring and control mechanisms should the architect implement?
**Respuesta:** Create resource monitors on every production warehouse with tiered thresholds: Notify at 75% of the daily/weekly quota, Notify & Suspend at 100%. For the account level, create an account-level resource monitor (ACCOUNTADMIN only) as an overall safety net. Set up alerts (`CREATE ALERT`) to check for long-running queries (e.g., queries exceeding 30 minutes) and warehouse queue depth, triggering email notifications. Review `ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY` weekly to catch anomalies early. Resource monitors track compute credits only (not storage), so pair them with `STORAGE_USAGE` monitoring for complete cost visibility. Set appropriate auto-suspend timeouts on all warehouses (60s for ETL, 300-600s for BI).

**Escenario:** A Python UDF in production is intermittently failing with cryptic errors. The data engineering team has no visibility into what happens inside the UDF. How should the architect enable observability for UDFs and stored procedures?
**Respuesta:** Set up an event table for the account: `ALTER ACCOUNT SET EVENT_TABLE = db.schema.events`. Set the log level to at least INFO: `ALTER SESSION SET LOG_LEVEL = 'INFO'`. Inside the Python UDF, add structured logging using Python's `logging` module — these logs automatically flow to the event table. Set `TRACE_LEVEL = 'ON_EVENT'` for tracing. The event table is queryable via standard SQL: `SELECT * FROM db.schema.events WHERE RESOURCE_ATTRIBUTES['snow.executable.name'] = 'MY_UDF'`. This provides full observability — logs, traces, and metrics — for all UDFs, stored procedures, and Streamlit apps. Enable INFO-level logging as a minimum for all production code.

**Escenario:** An architect needs to investigate a performance issue from 3 months ago. INFORMATION_SCHEMA shows no data for that period. Where should they look?
**Respuesta:** Use `SNOWFLAKE.ACCOUNT_USAGE` views, which have 365-day retention. `INFORMATION_SCHEMA` retention varies by view (7 days to 6 months) and is scoped to the current database only. `ACCOUNT_USAGE.QUERY_HISTORY` provides all query details (execution time, bytes scanned, warehouse, errors) for up to 365 days across the entire account. Note that ACCOUNT_USAGE has 15 minutes to 3 hours of latency (not real-time), and access requires ACCOUNTADMIN or the `IMPORTED PRIVILEGES` grant on the SNOWFLAKE database. For real-time debugging of current issues, use INFORMATION_SCHEMA; for historical analysis, always use ACCOUNT_USAGE.

---

---

## TARJETAS DE REPASO — Dominio 4

**P1: ¿Cuáles son las tres capas de caching en Snowflake?**
R1: Result cache (cloud services, 24h, gratuito), Metadata cache (cloud services, siempre activo), Local disk cache (SSD del warehouse, se pierde al suspender).

**P2: Una consulta hace spilling a almacenamiento remoto. ¿Cuál es la solución?**
R2: Usar un **warehouse más grande** (más memoria/SSD). También verificar si la consulta se puede optimizar para reducir el volumen de datos.

**P3: ¿Qué política de escalamiento deberías usar para un warehouse de BI orientado al usuario?**
R3: **Standard** — escala rápidamente cuando las consultas se encolan. Economy es para cargas tolerantes a latencia y sensibles al costo.

**P4: ¿Cómo verificas si una tabla se beneficiaría del clustering?**
R4: `SYSTEM$CLUSTERING_INFORMATION('table', '(columns)')` — revisa `average_depth` y `average_overlap`. Valores altos = mal clustering.

**P5: ¿Cuál es el período máximo de retención para las vistas de ACCOUNT_USAGE?**
R5: **365 días**.

**P6: ¿Las materialized views pueden unir múltiples tablas base?**
R6: **No.** Las MVs de Snowflake soportan solo una tabla base.

**P7: ¿Qué hace el Query Acceleration Service (QAS)?**
R7: Descarga porciones intensivas en escaneo de consultas elegibles a cómputo serverless, complementando al warehouse.

**P8: El result cache se invalida cuando ____?**
R8: Los datos subyacentes cambian (DML), pasan 24 horas, o el usuario cambia de rol.

**P9: ¿Cuál es la configuración mínima de auto-suspend?**
R9: **60 segundos** (o 0 para suspensión inmediata).

**P10: Los Snowpark-optimized warehouses tienen ___x más memoria.**
R10: **16x** más memoria por nodo comparado con warehouses estándar.

**P11: INFORMATION_SCHEMA muestra datos para qué alcance?**
R11: Solo la **base de datos actual**. Para datos de toda la cuenta, usa ACCOUNT_USAGE.

**P12: ¿Cómo funciona el Search Optimization Service?**
R12: Construye una ruta de acceso de búsqueda persistente (mantenida serverlessly) para búsquedas puntuales selectivas, predicados de igualdad y funciones geo.

**P13: ¿Qué rastrean los resource monitors?**
R13: Solo **créditos de cómputo**. NO rastrean costos de almacenamiento.

**P14: ¿A dónde van los logs de UDFs/procedimientos?**
R14: A la **event table** — una tabla única a nivel de cuenta configurada vía `ALTER ACCOUNT SET EVENT_TABLE`.

**P15: ¿Qué columnas deben ir primero en una clustering key?**
R15: **Columnas de baja cardinalidad primero** (ej., region, status) para máxima eficiencia de pruning.

---

## EXPLÍCALO COMO SI TUVIERA 5 AÑOS — Dominio 4

**ELI5 #1: Query Profile**
Imagina que estás construyendo un castillo de LEGO y alguien toma una foto en cada paso. Query Profile son esas fotos — te muestra exactamente qué paso tomó más tiempo y dónde las cosas se atascaron.

**ELI5 #2: Dimensionamiento de Warehouses**
Un warehouse es como contratar trabajadores. X-Small = 1 trabajador, Small = 2, Medium = 4. Más trabajadores cuestan más dinero. Pero si el trabajo necesita una herramienta especial (mejor SQL), contratar más trabajadores no ayudará.

**ELI5 #3: Result Cache**
Le preguntas a tu mamá "¿Qué hay de cenar?" Ella dice "Pasta." Le preguntas otra vez 5 minutos después — ella recuerda y dice "Pasta" instantáneamente sin revisar la cocina. Eso es el result cache. Pero si ella empieza a cocinar otra cosa, la respuesta cambia.

**ELI5 #4: Pruning de Micro-partitions**
Tienes 1,000 cajas de juguetes etiquetadas. Cada etiqueta dice qué hay adentro (ej., "autos del 2020"). Cuando quieres "autos del 2020", solo abres las cajas etiquetadas "2020" en lugar de las 1,000.

**ELI5 #5: Clustering Keys**
Organizas tu librero por color primero, luego por tamaño. Ahora cuando alguien pide "todos los libros azules", vas directo a la sección azul en lugar de revisar cada estante.

**ELI5 #6: Spilling**
Tu escritorio es muy pequeño para tu rompecabezas. Derramas piezas al piso (disco local) — más lento pero está bien. Si el piso se llena, mueves piezas al garaje (almacenamiento remoto) — mucho más lento. Escritorio más grande = warehouse más grande.

**ELI5 #7: Multi-cluster Warehouses**
Una heladería con filas largas. Multi-cluster = abrir más tiendas cuando la fila se hace muy larga. Política Standard: abrir una nueva tienda apenas alguien espera. Política Economy: solo abrir si la fila es realmente, realmente larga.

**ELI5 #8: Search Optimization**
Tu maestra hizo un índice al final del libro de texto. En lugar de leer cada página para encontrar "dinosaurios", miras el índice, obtienes "página 42" y vas directo ahí.

**ELI5 #9: Resource Monitors**
Tus papás te dan $20 para juegos de arcade. Un resource monitor es como un rastreador: a los $15 te avisa, a los $20 te quita el dinero para que no gastes de más.

**ELI5 #10: Materialized Views**
Cada mañana tu maestra escribe "Menú del almuerzo de hoy" en el pizarrón. En lugar de que todos caminen a la cafetería a revisar, solo miran el pizarrón. Cuando el menú cambia, la maestra actualiza el pizarrón automáticamente.

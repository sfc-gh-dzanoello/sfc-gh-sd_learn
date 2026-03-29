# DOMINIO 4: OPTIMIZACIÓN DE RENDIMIENTO, CONSULTAS Y TRANSFORMACIÓN
## 21% del examen = ~21 preguntas

---

## 4.1 CACHÉ (MUY IMPORTANTE EN EL EXAMEN)

Snowflake tiene TRES capas de caché. Cada una funciona diferente.

### 1. Caché de Resultados de Consulta
- Almacena el RESULTADO de consultas ejecutadas previamente
- Duración: 24 horas (se reinicia si la misma consulta se ejecuta de nuevo, máximo 31 días de renovación)
- Alcance: COMPARTIDO entre todos los usuarios de la cuenta
- Ubicación: Capa de Cloud Services
- Costo: GRATIS (no se necesita warehouse para retornar resultado cacheado)
- Condiciones para hit de caché:
  - Exactamente el mismo texto SQL
  - Mismo rol
  - Los datos subyacentes NO han cambiado
  - Misma configuración de sesión
- Diferente usuario, mismo rol → AÚN usa caché
- Se puede deshabilitar: ALTER SESSION SET USE_CACHED_RESULT = FALSE

**Trampa del examen**: "¿Diferente usuario ejecuta la misma consulta?" → SÍ, usa Caché de Resultados (mismo rol + datos sin cambiar). SI VES "caché por usuario" o "cada usuario tiene su propio caché" → TRAMPA. El caché de resultados es COMPARTIDO entre usuarios.
**Trampa del examen**: "¿Duración del caché de resultados?" → 24 horas (renovable hasta 31 días). SI VES "indefinido" o "permanente" → TRAMPA. Máximo es 31 días, se reinicia después de 24hr sin reutilización.
**Trampa del examen**: "¿Dónde se almacena el caché de resultados?" → Capa de Cloud Services. SI VES "warehouse" o "SSD" o "disco local" → TRAMPA. El caché de resultados vive en Cloud Services, no en ningún warehouse.
**Trampa del examen**: "¿Costo del hit de caché de resultados?" → Cero (sin créditos de warehouse). SI VES "warehouse requerido" o "consume créditos" con caché de resultados → TRAMPA. El caché de resultados es GRATIS, servido por Cloud Services.

### 2. Caché de Warehouse (Disco Local / Caché SSD)
- Cachea datos crudos de tabla en el SSD local del warehouse
- Acelera consultas posteriores sobre los mismos datos
- Duración: mientras el warehouse esté EN EJECUCIÓN
- **SE PIERDE cuando el warehouse se suspende**
- Cada warehouse tiene su propio caché (no compartido)

**Trampa del examen**: "¿Warehouse se suspende → caché?" → El caché de disco local se PIERDE. SI VES "el caché persiste" o "sobrevive la suspensión" → TRAMPA. El caché SSD se borra en el momento en que suspendes.
**Trampa del examen**: "¿Qué caché se pierde al suspender?" → Caché de Warehouse / Disco Local (SSD). SI VES "caché de resultados" como respuesta → TRAMPA. El caché de resultados está en Cloud Services y nunca se pierde al suspender.

### 3. Caché de Metadatos
- Almacena metadatos de tabla (conteo de filas, mín/máx, tamaños en bytes)
- Usado para: COUNT(*), MIN, MAX en tabla completa (sin filtro)
- La capa de Cloud Services lo maneja
- No necesita warehouse para consultas puras de metadatos
- Siempre disponible, no se puede deshabilitar

### Flujo de Decisión de Caché:
```
La consulta llega →
  1. Verificar Caché de Resultados (¿coincidencia exacta?) → SÍ → retornar instantáneamente (gratis)
  2. Verificar Caché de Metadatos (¿consulta solo de metadatos?) → SÍ → retornar de metadatos (gratis)
  3. Ejecutar en Warehouse → usa Caché de Warehouse para lecturas de datos
```

### Por qué esto importa + Casos de uso

**¿Por qué los cachés importan tanto?** Porque Snowflake cobra por segundo por compute. Si un caché puede responder tu consulta GRATIS, eso es dinero real ahorrado — especialmente a escala con cientos de usuarios.

**Escenario real — "Nuestro dashboard cuesta $500/día en créditos de warehouse"**
Las mismas 10 consultas del dashboard se ejecutan cada 5 minutos para 50 usuarios. Pero los datos subyacentes solo cambian una vez por hora. Solución: El Caché de Resultados maneja el 95% de esas consultas GRATIS (sin encender warehouse). Solo la primera ejecución después de cambios de datos cuesta créditos.

**Escenario real — "Suspendimos el warehouse durante la noche para ahorrar dinero, pero las consultas de la mañana son lentas"**
El caché SSD del warehouse se borró al suspender. Las primeras consultas del día deben releer desde almacenamiento remoto. Esta es la penalización de "arranque en frío". Compensación: ahorrar créditos durante la noche vs. primeras consultas más lentas. Para dashboards críticos, considera un timeout de auto-suspensión más largo.

**Escenario real — "Nuestra consulta escanea 500GB pero solo retorna 100 filas"**
Problema clásico de pruning. La tabla tiene miles de millones de filas pero la cláusula WHERE no puede saltar particiones eficientemente. Solución: agregar una clave de clustering en la columna filtrada. Después del clustering, la misma consulta escanea 2GB en vez de 500GB.

**Escenario real — "La consulta gigante de un analista está bloqueando a todos los demás"**
50 usuarios están en cola detrás de un reporte masivo. Escala HORIZONTALMENTE (multi-cluster) para que la consulta grande tenga su propio cluster y todos los demás tengan los suyos. También configura STATEMENT_TIMEOUT para matar consultas que tarden demasiado.

---

### Mejores Prácticas — Rendimiento
- No deshabilitar el caché de resultados (USE_CACHED_RESULT = TRUE es el defecto — mantenlo)
- Evitar SELECT * — solo consulta las columnas que necesitas (pruning columnar)
- Usar claves de clustering SOLO en tablas multi-TB con patrones de filtro conocidos
- Verificar Query Profile para TableScan: si particiones escaneadas ≈ total, agregar clave de clustering
- Usar EXPLAIN USING TABULAR para previsualizar el plan de consulta sin ejecutarla
- Configurar STATEMENT_TIMEOUT a nivel de warehouse para matar consultas desbocadas


### Ejemplos de Preguntas de Escenario — Caching

**Escenario:** A retail company runs an executive dashboard that refreshes every 2 minutes. The same 5 SQL queries are executed by 30 different analysts throughout the day. The underlying sales data is loaded via a nightly ETL job (once every 24 hours). The team notices their warehouse is running all day and costing significant credits. How can they reduce costs without changing the dashboard?
**Respuesta:** Since the underlying data only changes once per day (nightly ETL), the **Result Cache** will serve all repeated queries for free after the first execution — as long as the SQL text is identical, the role is the same, and the data hasn't changed. The warehouse only needs to run for the first execution after each nightly load. The team should ensure USE_CACHED_RESULT = TRUE (the default) and that the dashboard uses parameterized queries with consistent SQL text. They can also set a short auto-suspend timeout (1-2 minutes) so the warehouse stops between the rare cache misses. This could eliminate 95%+ of warehouse credit consumption.

**Escenario:** A data engineering team suspends their XL warehouse every night at 8 PM to save credits. Every morning at 7 AM, the first batch of queries takes 3-4x longer than normal. By 8 AM, query performance is back to normal. What is causing this, and what are the trade-offs of fixing it?
**Respuesta:** When the warehouse is suspended, the **Warehouse Cache (SSD/Local Disk Cache)** is completely wiped. The first morning queries must re-read all data from remote storage (cold start), which is much slower. By 8 AM, the SSD cache is warm again from repeated reads. The trade-off: keeping the warehouse running overnight preserves the cache but costs credits for idle time. Options: (1) accept the cold start penalty and save overnight credits, (2) increase auto-suspend to a longer timeout so it only suspends after extended inactivity, or (3) schedule a lightweight "warm-up" query to run just before the 7 AM workload begins.

**Escenario:** An analyst runs `SELECT COUNT(*) FROM sales_fact;` on a 500 billion-row table. The query returns instantly in under 1 second without a warehouse running. Another analyst runs `SELECT COUNT(*) FROM sales_fact WHERE region = 'EMEA';` and it takes 45 seconds with a warehouse. Why the dramatic difference?
**Respuesta:** The first query (`COUNT(*)` with no filter) is answered by the **Metadata Cache**, which stores pre-computed statistics like row counts, min/max values, and byte sizes. This is served by the Cloud Services layer for free — no warehouse needed. The second query includes a WHERE clause, so Snowflake cannot use metadata alone; it must actually scan (and prune) micro-partitions on a running warehouse. The metadata cache only works for full-table aggregate operations without filters.

**Escenario:** User A (role: ANALYST_ROLE) runs a complex 20-table join query that takes 8 minutes. User B (role: ANALYST_ROLE) runs the exact same query 10 minutes later. User C (role: FINANCE_ROLE) runs the same query 5 minutes after User B. Which users benefit from the result cache?
**Respuesta:** **User B** gets a result cache hit — same SQL text, same role (ANALYST_ROLE), and data unchanged within 24 hours. The query returns instantly with zero warehouse cost. **User C** does NOT get a result cache hit, even though the SQL is identical, because User C is using a different role (FINANCE_ROLE). The result cache requires the same role, same SQL text, and unchanged underlying data. User C's query will execute fully on the warehouse.

---

---

## 4.2 QUERY PROFILE Y QUERY INSIGHTS (MUY PROBADO)

### Query Profile:
- Plan de ejecución visual en Snowsight
- Muestra: operadores, flujo de datos, estadísticas
- Usado para identificar cuellos de botella de rendimiento

### Métricas clave en Query Profile:

**Bytes Spilled to Local Storage (Derrame a Disco Local)**:
- La consulta necesitó más memoria de la disponible
- Datos derramados al SSD local
- Solución: AUMENTAR tamaño del warehouse (escalar VERTICALMENTE)

**Bytes Spilled to Remote Storage (Derrame a Disco Remoto)**:
- Aún peor — derramó más allá del SSD local al almacenamiento remoto
- Mucho más lento
- Solución: AUMENTAR tamaño del warehouse significativamente

**Pruning Ineficiente**:
- Demasiadas particiones escaneadas vs particiones necesitadas
- Ratio de escaneo-a-filtro es alto
- Solución: agregar clave de clustering, revisar cláusulas WHERE
- Causa común: usar funciones en columnas de filtro (ej. WHERE UPPER(col) = 'X')

**Joins Explosivos**:
- El join produce muchas más filas que la entrada
- Usualmente producto cartesiano o condición de join faltante
- Solución: revisar condiciones de join, agregar predicados adecuados

**Cola (Queuing)**:
- Consultas esperando recursos del warehouse
- Solución: escalar HORIZONTALMENTE (agregar clusters vía warehouse multi-cluster)
- No: escalar VERTICALMENTE (tamaño más grande no ayuda con la cola)

### Reglas clave:
- Derrame (local o remoto) → Escalar VERTICALMENTE (warehouse más grande)
- Cola / concurrencia → Escalar HORIZONTALMENTE (más clusters)
- Problemas de pruning → Mejor clustering, arreglar cláusulas WHERE

**Trampa del examen**: "¿Solución para Derrame a Disco Local?" → Aumentar tamaño del warehouse (escalar VERTICALMENTE). SI VES "agregar clusters" o "escalar horizontalmente" para derrame → TRAMPA. Derrame = problema de memoria = escalar VERTICALMENTE, no HORIZONTALMENTE.
**Trampa del examen**: "¿Solución para Derrame a Disco Remoto?" → Aumentar tamaño del warehouse aún más. SI VES "escalar horizontalmente" o "multi-cluster" para derrame remoto → TRAMPA. Derrame remoto es un problema de memoria peor = escalar VERTICALMENTE significativamente.
**Trampa del examen**: "¿Cola alta?" → Agregar clusters (escalar HORIZONTALMENTE). SI VES "warehouse más grande" o "escalar verticalmente" para cola → TRAMPA. Cola = problema de concurrencia = escalar HORIZONTALMENTE con más clusters.
**Trampa del examen**: "¿Privilegio MONITOR necesario para?" → Ver Query Profiles de otros usuarios. SI VES "OPERATE" o "USAGE" como el privilegio → TRAMPA. Solo MONITOR otorga acceso a Query Profiles de otros usuarios.

### Historial de Consultas:
- ACCOUNT_USAGE.QUERY_HISTORY → 365 días, hasta 3hr latencia
- INFORMATION_SCHEMA.QUERY_HISTORY() → 7 días, tiempo real
- Muestra: texto de consulta, duración, warehouse, bytes escaneados, filas retornadas

### Atribución de Consultas:
- Rastrear consumo de recursos por consulta
- Entender qué consultas usan más créditos/recursos


### Ejemplos de Preguntas de Escenario — Query Profile & Query Insights

**Escenario:** A financial services company has a nightly reconciliation query that normally takes 15 minutes. Last night it took 2.5 hours. The DBA opens the Query Profile and sees "Bytes Spilled to Local Storage: 85 GB" and "Bytes Spilled to Remote Storage: 210 GB." The warehouse is a Medium. What happened, and what is the correct fix?
**Respuesta:** The query ran out of memory on the Medium warehouse and **spilled** data first to local SSD (85 GB), then to much slower remote storage (210 GB). Remote spilling is extremely expensive in terms of performance. The fix is to **scale UP** — increase the warehouse size to Large or XL to provide more memory so the query can process in-memory without spilling. Scaling OUT (adding clusters) would NOT help here because spilling is a memory problem for a single query, not a concurrency problem. The DBA should also check if the query changed (new joins, more data) to understand why it suddenly needs more memory.

**Escenario:** A BI team reports that their morning dashboard queries are slow. The Query Profile shows that a query on the `orders` table scans 12,000 out of 12,500 total micro-partitions, but only returns 500 rows where `order_date = '2025-12-01'`. What is the issue, and how should it be fixed?
**Respuesta:** This is a **pruning problem**. The query is scanning nearly all micro-partitions (12,000/12,500 = 96%) but only needs a tiny fraction of the data. The `order_date` column is not well-clustered, so Snowflake cannot skip irrelevant partitions. The fix: add a **clustering key** on `order_date` with `ALTER TABLE orders CLUSTER BY (order_date)`. After automatic clustering reorganizes the data, the same query might scan only 50-100 partitions instead of 12,000. Also check that the WHERE clause doesn't wrap the column in a function (e.g., `WHERE DATE_TRUNC('day', order_date)`) — functions on filter columns prevent pruning.

**Escenario:** A SaaS company has 150 concurrent users running reports on a single Large multi-cluster warehouse (max 3 clusters, Standard scaling). Users complain that queries are "stuck" and taking much longer than usual. The Query Profile shows minimal spilling but significant time in the "Initialization" phase. What is the problem?
**Respuesta:** The queries are **queuing** — waiting for available compute resources. With 150 concurrent users, even 3 clusters may not be enough. The "Initialization" wait time indicates queries sitting in the queue before execution begins. The fix is to **scale OUT** — either increase the maximum cluster count beyond 3, or create separate warehouses for different user groups (e.g., finance vs. operations). Scaling UP (bigger warehouse) would NOT help because the problem is concurrency (too many queries), not memory. They should also check STATEMENT_QUEUED_TIMEOUT_IN_SECONDS to auto-cancel queries that wait too long.

**Escenario:** A developer writes a query joining `customers` (10M rows) with `addresses` (50M rows) but accidentally omits the join condition, writing `FROM customers, addresses` instead of using a proper ON clause. The Query Profile shows the output has 500 trillion rows. What happened?
**Respuesta:** This is an **exploding join** (Cartesian product). Without a join condition, every row in `customers` is matched with every row in `addresses`: 10M x 50M = 500 trillion rows. The Query Profile would show the join operator producing massively more rows than the input. The fix: add the proper join predicate (`ON customers.customer_id = addresses.customer_id`). Always check join conditions when the Query Profile shows output rows >> input rows. This is a common exam scenario — if a join produces way more rows than expected, the answer is almost always a missing or incorrect join condition.

---

---

## 4.3 SERVICIOS DE OPTIMIZACIÓN DE RENDIMIENTO

### Servicio de Aceleración de Consultas (QAS) — Enterprise+
- Descarga porciones de consultas de escaneo grande a compute serverless
- Mejor para: consultas que escanean muchos datos (escaneos de tablas grandes)
- Serverless (compute gestionado por Snowflake, facturado por uso)
- Se habilita en un warehouse: ALTER WAREHOUSE SET ENABLE_QUERY_ACCELERATION = TRUE
- Se puede configurar factor de escala (1-100) para controlar compute serverless máximo
- NO ayuda con: consultas pequeñas, consultas que ya son rápidas

**Cómo funciona**: La consulta tiene una porción de escaneo grande → QAS envía partes del escaneo a compute serverless extra → los resultados se fusionan → ejecución más rápida

### Servicio de Optimización de Búsqueda (SOS) — Enterprise+
- Estructura de datos persistente (como un índice secundario)
- Mejor para: consultas de búsqueda puntual en columnas de alta cardinalidad
- Ejemplo: buscar un ID de transacción específico en miles de millones de filas
- Mantenimiento en segundo plano (serverless, consume créditos)
- Snowflake automáticamente mantiene rutas de acceso de búsqueda
- Reduce necesidad de clustering manual en columnas de búsqueda

**Trampa del examen**: "¿Búsqueda de ID específico en miles de millones de filas?" → Servicio de Optimización de Búsqueda. SI VES "Aceleración de Consultas" para búsquedas puntuales → TRAMPA. QAS es para escaneos grandes. SOS es para búsquedas de ID/valor específico.
**Trampa del examen**: "¿SOS es como un...?" → Índice secundario / rutas de acceso. SI VES "vista materializada" o "resultado cacheado" → TRAMPA. SOS construye rutas de acceso de búsqueda (como un índice), no resultados pre-computados.
**Trampa del examen**: "¿QAS descarga a...?" → Recursos de compute serverless compartidos. SI VES "warehouse dedicado" o "compute gestionado por usuario" → TRAMPA. QAS usa compute serverless gestionado por Snowflake, no tu warehouse.
**Trampa del examen**: "¿Tanto QAS como SOS son...?" → Edición Enterprise+. SI VES "edición Standard" o "todas las ediciones" → TRAMPA. QAS, SOS y Vistas Materializadas requieren Enterprise+ como mínimo.

### Claves de Clustering
- Define por qué columnas agrupar
- ALTER TABLE ... CLUSTER BY (col1, col2)
- Clustering Automático: servicio en segundo plano mantiene el clustering
- Serverless (consume créditos por mantenimiento)
- Mejor para: tablas muy grandes donde las consultas filtran por columnas específicas
- Co-localiza datos similares en micro-particiones → mejor pruning

**Trampa del examen**: "¿Agregar clave de clustering a tabla existente?" → ALTER TABLE ... CLUSTER BY. SI VES "CREATE TABLE" o "recrear tabla" → TRAMPA. Se agregan claves de clustering a tablas existentes con ALTER TABLE, no se necesita reconstruir.
**Trampa del examen**: "¿Costo del clustering automático?" → Créditos serverless (mantenimiento en segundo plano). SI VES "gratis" o "sin costo" → TRAMPA. Definir la clave es gratis, pero el mantenimiento automático consume créditos serverless.

### Vistas Materializadas — Enterprise+
- Resultados de consulta pre-computados almacenados físicamente
- Auto-refrescados cuando los datos subyacentes cambian (servicio en segundo plano, consume créditos)
- Mejor para: consultas costosas en datos que cambian infrecuentemente
- Limitaciones: solo tabla única, funcionalidades SQL limitadas
- Se puede usar Optimización de Búsqueda en vistas materializadas


### Ejemplos de Preguntas de Escenario — Performance Optimization Services

**Escenario:** A logistics company has a 2 TB `shipments` table with 8 billion rows. Their operations team frequently searches for individual shipment tracking numbers (e.g., `WHERE tracking_id = 'TRK-2025-8847291'`). These lookup queries take 30-60 seconds each. The team is considering enabling Query Acceleration Service. Is this the right choice?
**Respuesta:** No — **Search Optimization Service (SOS)** is the correct choice, not QAS. This is a **point lookup** scenario: searching for a specific value in a high-cardinality column across billions of rows. SOS builds persistent search access paths (like a secondary index) optimized for equality predicates, IN lists, and LIKE patterns. QAS is designed for large table scans, not targeted lookups. Enable SOS with `ALTER TABLE shipments ADD SEARCH OPTIMIZATION ON EQUALITY(tracking_id)`. After the background service builds the access paths, these lookups should drop from 30-60 seconds to under 1 second. SOS requires Enterprise+ edition.

**Escenario:** A media company runs ad-hoc analytics queries against a 5 TB `user_events` table. Most queries are fast, but occasionally an analyst runs a query that scans the entire table and takes 20+ minutes, blocking other work. The team wants to speed up these outlier queries without permanently upsizing the warehouse. What service should they use?
**Respuesta:** **Query Acceleration Service (QAS)** is ideal here. QAS offloads the scan-heavy portions of eligible queries to Snowflake-managed serverless compute, letting the outlier query finish faster without affecting other queries on the warehouse. Enable it with `ALTER WAREHOUSE analytics_wh SET ENABLE_QUERY_ACCELERATION = TRUE` and set a scale factor (e.g., 8) to control the maximum serverless compute allowed. QAS is billed per-use (serverless credits) so it only costs money when those outlier queries actually trigger it. This avoids the cost of permanently running a larger warehouse just for occasional heavy queries. Enterprise+ required.

**Escenario:** A healthcare analytics team runs the same expensive aggregation — total patient visits by department, region, and month — dozens of times per day. The underlying `patient_visits` table (800 GB) is only updated once daily via a batch load. Each execution takes 4 minutes on a Large warehouse. What optimization would provide the best performance improvement?
**Respuesta:** A **Materialized View** is the best fit. Since the query is expensive (4 min), repeated frequently, and the underlying data changes infrequently (once daily), a materialized view will pre-compute and physically store the aggregation results. Subsequent reads of the MV will be nearly instant since Snowflake reads the pre-computed result rather than re-scanning 800 GB. Snowflake automatically refreshes the MV when the base table changes (after the daily load). The trade-off: MVs consume storage and serverless credits for auto-refresh maintenance. Limitations to remember: MVs can only reference a single base table and support limited SQL features (no joins, no UDFs). Enterprise+ required.

**Escenario:** A fintech company has a 10 TB `transactions` table. Queries always filter by `transaction_date` and the table grows by 500 million rows per day. Query performance has degraded over time — the Query Profile shows poor pruning (scanning 80% of partitions). They've already tried increasing warehouse size with no improvement. What should they do?
**Respuesta:** Add a **clustering key** on `transaction_date` with `ALTER TABLE transactions CLUSTER BY (transaction_date)`. As the table grows, new data is appended in ingestion order, which may not align with `transaction_date`. This causes date ranges to be scattered across many micro-partitions, resulting in poor pruning. A clustering key tells Snowflake's Automatic Clustering service to reorganize micro-partitions so rows with similar `transaction_date` values are co-located. After reclustering, queries filtering by date will skip most partitions. Note: clustering keys work on ALL editions, but the Automatic Clustering background maintenance consumes serverless credits. Scaling UP the warehouse wouldn't help here — the problem is I/O (reading too many partitions), not memory.

---

---

## 4.4 MEJORES PRÁCTICAS DE GESTIÓN DE CARGA DE TRABAJO

### Agrupar cargas de trabajo similares:
- Warehouses separados para: carga ETL, reportes BI, consultas ad-hoc, ciencia de datos
- Previene que una carga de trabajo prive de recursos a otra

### Dimensionar warehouses correctamente:
- Empezar pequeño, escalar si es necesario
- Consultas complejas → warehouse más grande
- Consultas simples → warehouse pequeño
- Carga → depende del número de archivos (no solo volumen de datos)

### Usar auto-suspensión:
- Ahorra créditos cuando el warehouse está inactivo
- Timeout corto para cargas interactivas (1-5 minutos)
- Timeout más largo para herramientas BI con consultas frecuentes

### Parámetros de timeout:
- STATEMENT_TIMEOUT_IN_SECONDS → matar consultas que tardan demasiado
- STATEMENT_QUEUED_TIMEOUT_IN_SECONDS → matar consultas que esperan demasiado en cola

**Trampa del examen**: "¿Política de escalado Economy vs Standard?" → Economy espera ~6 min antes de agregar clusters (ahorra créditos). Standard agrega inmediatamente. SI VES "Economy agrega clusters más rápido" o "inmediatamente" con Economy → TRAMPA. Economy ESPERA ~6 min. Standard es el rápido.
**Trampa del examen**: "¿Auto-suspensión configurada a 0?" → El warehouse NUNCA se auto-suspende. SI VES "suspensión inmediata" o "apagado instantáneo" para 0 → TRAMPA. 0 = deshabilitado = warehouse funciona para siempre hasta suspensión manual.
**Trampa del examen**: "¿STATEMENT_TIMEOUT vs STATEMENT_QUEUED_TIMEOUT?" → TIMEOUT mata consultas en ejecución. QUEUED_TIMEOUT mata consultas aún esperando en cola. SI VES estos intercambiados → TRAMPA. TIMEOUT = en ejecución. QUEUED_TIMEOUT = esperando.


### Ejemplos de Preguntas de Escenario — Workload Management Best Practices

**Escenario:** A company has a single XL warehouse shared by the ETL team (heavy nightly loads), the BI team (daytime dashboards), and the data science team (ad-hoc ML queries). The BI team complains that their dashboards are slow every morning while the ETL job is still finishing. What is the recommended architectural change?
**Respuesta:** Create **separate warehouses** for each workload type: one for ETL loading, one for BI reporting, and one for data science ad-hoc queries. This is Snowflake's core best practice for workload isolation — it prevents one workload from starving another. The ETL warehouse can be sized larger (XL) for heavy transforms, the BI warehouse can be a Medium multi-cluster warehouse for high concurrency, and the data science warehouse can be a Large with aggressive auto-suspend since usage is sporadic. Each team gets dedicated resources and predictable performance.

**Escenario:** An e-commerce company uses an Enterprise edition warehouse with Economy scaling policy (min 1, max 5 clusters). During Black Friday, users report that queries are queuing for several minutes before executing, even though the system is allowed up to 5 clusters. Support confirms only 2 clusters are running. What is happening?
**Respuesta:** The **Economy scaling policy** waits approximately 6 minutes of sustained queuing before adding a new cluster — it prioritizes cost savings over immediate performance. During a traffic spike like Black Friday, this 6-minute delay per cluster means it takes a long time to scale from 1 to 5 clusters. The fix: switch to **Standard scaling policy**, which adds clusters immediately when queries begin queuing. Standard is the right choice for performance-sensitive, user-facing workloads. Economy is better suited for cost-sensitive batch workloads where a few minutes of queuing is acceptable.

**Escenario:** A team has a warehouse that processes bursts of queries every 30 minutes (triggered by a scheduler) but sits completely idle in between. The auto-suspend is set to 10 minutes. They notice they're paying for 20 minutes of idle time per hour. What should they change?
**Respuesta:** Reduce the **auto-suspend timeout** to 1-2 minutes (e.g., `ALTER WAREHOUSE SET AUTO_SUSPEND = 60`). Since the workload is bursty with 30-minute gaps, a 10-minute timeout means the warehouse runs idle for 10 minutes after each burst before suspending — wasting credits. With a 1-minute timeout, it suspends almost immediately after the burst completes. Auto-resume (enabled by default) will automatically restart the warehouse when the next scheduled burst arrives. The trade-off: the first query of each burst will have a small cold-start delay (a few seconds for warehouse provisioning), but the credit savings from 28+ minutes of avoided idle time per hour far outweigh this.

**Escenario:** A data platform team discovers that a single analyst's query has been running for 14 hours, consuming an XL warehouse the entire time. It appears to be an accidental Cartesian join. How can they prevent this from happening again?
**Respuesta:** Set **STATEMENT_TIMEOUT_IN_SECONDS** at the warehouse level to automatically kill queries that exceed a reasonable duration. For example, `ALTER WAREHOUSE SET STATEMENT_TIMEOUT_IN_SECONDS = 3600` would kill any query running longer than 1 hour. They should also set **STATEMENT_QUEUED_TIMEOUT_IN_SECONDS** to prevent queries from waiting indefinitely in queue. These parameters can be set at the account, warehouse, or session level. For the immediate issue, the admin can manually cancel the running query. Important distinction: STATEMENT_TIMEOUT kills *running* queries, while STATEMENT_QUEUED_TIMEOUT kills queries *waiting in the queue* — don't confuse them on the exam.

---

---

## 4.5 TIPOS DE DATOS Y TRANSFORMACIÓN

### Datos Estructurados:
- Tipos SQL estándar: VARCHAR, NUMBER, DATE, TIMESTAMP, BOOLEAN, etc.
- Operaciones estándar de tabla

### Datos Semi-Estructurados:
- Almacenados en columnas VARIANT, OBJECT, ARRAY
- Navegar con notación de punto: col:clave.subclave
- Convertir con notación ::tipo: col:nombre::string
- Funciones clave:
  - PARSE_JSON() → string a VARIANT
  - FLATTEN() → expandir arrays/objetos en filas
  - LATERAL FLATTEN → unir salida aplanada con otras columnas
  - OBJECT_KEYS() → obtener todas las claves
  - ARRAY_SIZE() → contar elementos del array
  - TYPEOF() → verificar tipo VARIANT
  - GET_PATH() / GET() → extraer valores

### Datos No Estructurados:
- Imágenes, PDFs, audio, video
- Almacenados en stages internos/externos
- Tipo de dato FILE para referencias
- Procesar con UDFs, funciones externas, o Cortex AI

**Trampa del examen**: "¿FLATTEN vs PARSE_JSON?" → PARSE_JSON convierte un string A VARIANT. FLATTEN expande VARIANT EN filas. SI VES estos intercambiados o tratados como lo mismo → TRAMPA. PARSE_JSON = string→VARIANT. FLATTEN = VARIANT→filas. Direcciones opuestas.
**Trampa del examen**: "¿La notación de punto col:clave funciona en VARCHAR?" → INCORRECTO. SI VES "col:clave" en una columna VARCHAR → TRAMPA. La notación de punto solo funciona en VARIANT/OBJECT. Se debe PARSE_JSON primero si es un string.
**Trampa del examen**: "¿ARRAY y OBJECT son lo mismo que VARIANT?" → INCORRECTO. SI VES "intercambiables" o "idénticos" → TRAMPA. VARIANT es el contenedor genérico. ARRAY = lista ordenada, OBJECT = pares clave-valor. Tres tipos distintos.


### Ejemplos de Preguntas de Escenario — Data Types & Transformation

**Escenario:** A company ingests IoT sensor data as JSON into a `sensor_readings` table with a VARIANT column called `payload`. A typical record looks like: `{"device_id": "D-4421", "readings": [{"temp": 72.5, "humidity": 45}, {"temp": 73.1, "humidity": 44}], "timestamp": "2025-06-15T10:30:00Z"}`. An analyst needs to produce one row per individual reading with the device ID and timestamp. How should they write this query?
**Respuesta:** Use **LATERAL FLATTEN** to expand the nested `readings` array into individual rows, combined with dot notation and casting to extract the scalar values:
```sql
SELECT
  payload:device_id::STRING AS device_id,
  payload:timestamp::TIMESTAMP AS event_time,
  f.value:temp::FLOAT AS temperature,
  f.value:humidity::FLOAT AS humidity
FROM sensor_readings,
  LATERAL FLATTEN(input => payload:readings) f;
```
Key concepts: `payload:device_id` uses dot notation to navigate the VARIANT. `::STRING` casts the VARIANT element to a typed value. `LATERAL FLATTEN` expands the array so each element becomes its own row. `f.value` accesses the current array element. Without LATERAL, you'd lose the correlation back to the parent row's `device_id` and `timestamp`.

**Escenario:** A developer stores API response data as a VARCHAR column containing JSON strings (not VARIANT). They try to query it with `SELECT api_response:status_code FROM api_logs` and get an error. What is wrong, and how should they fix it?
**Respuesta:** Dot notation (`col:key`) only works on **VARIANT, OBJECT, or ARRAY** columns — not on VARCHAR. Even though the VARCHAR contains valid JSON text, Snowflake treats it as a plain string. The fix: use **PARSE_JSON()** to convert the string to VARIANT first: `SELECT PARSE_JSON(api_response):status_code::NUMBER FROM api_logs`. Alternatively, the better long-term fix is to change the column type to VARIANT during ingestion. Remember: PARSE_JSON converts string→VARIANT (parsing direction), while FLATTEN converts VARIANT→rows (expanding direction). These are opposite operations and a common exam confusion point.

**Escenario:** A data engineer is migrating a legacy system that stores customer preferences as deeply nested JSON. Some customers have preferences nested 5+ levels deep (e.g., `payload:settings:notifications:email:frequency:value`). They ask whether Snowflake's VARIANT column can handle this depth, and whether there are performance considerations for deeply nested semi-structured data.
**Respuesta:** Snowflake's VARIANT type can handle arbitrary nesting depth — there is no hard limit on JSON nesting levels. However, there are performance considerations. Snowflake automatically extracts and optimizes commonly accessed top-level keys in VARIANT columns into a columnar format for better pruning and performance. Deeply nested paths may not benefit from this automatic optimization. For frequently queried deep paths, consider: (1) using FLATTEN to normalize deeply nested structures into separate rows/columns at ingestion time, (2) creating a view that extracts commonly used paths with `GET_PATH()` or dot notation, or (3) materializing frequently accessed nested values into dedicated typed columns for better query performance and pruning.

---

---

## 4.6 TÉCNICAS DE CONSULTA SQL

### Funciones de Agregación:
- COUNT, SUM, AVG, MIN, MAX, LISTAGG
- GROUP BY, HAVING
- GROUPING SETS, ROLLUP, CUBE (para subtotales)

### Funciones de Ventana:
- Realizan cálculos a través de filas relacionadas
- Sintaxis: función() OVER (PARTITION BY col ORDER BY col)
- Comunes: ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, SUM, AVG
- ROWS BETWEEN / RANGE BETWEEN para especificación de marco
- Totales acumulados, promedios móviles, ranking

### Expresiones de Tabla Comunes (CTEs):
- Cláusula WITH para subconsultas legibles y reutilizables
- Mejoran la legibilidad de consultas complejas
- Pueden referenciar CTEs anteriores en el mismo bloque WITH

### LATERAL:
- Usado con FLATTEN para unir resultados aplanados con la fila fuente
- SELECT t.id, f.value FROM tabla t, LATERAL FLATTEN(input => t.col_array) f

### Consejos de Optimización de Consultas:
- Filtrar temprano (cláusulas WHERE se empujan hacia abajo)
- Evitar SELECT * (escanea columnas innecesarias)
- Usar claves de clustering para filtros de tablas grandes
- Evitar funciones en columnas filtradas (previene pruning)
- Usar LIMIT para consultas de exploración
- Evitar joins cartesianos (siempre tener condiciones de join)

**Trampa del examen**: "¿QUALIFY vs HAVING vs WHERE?" → WHERE = antes del agrupamiento. HAVING = después de GROUP BY. QUALIFY = después de funciones de ventana. SI VES "intercambiables" o cualquiera de estos intercambiados → TRAMPA. Cada uno filtra en una etapa diferente de ejecución de consulta.
**Trampa del examen**: "¿RANK vs DENSE_RANK vs ROW_NUMBER?" → ROW_NUMBER = siempre único (1,2,3). RANK = saltos en empates (1,1,3). DENSE_RANK = sin saltos (1,1,2). SI VES "RANK y DENSE_RANK son lo mismo" → TRAMPA. RANK salta números después de empates, DENSE_RANK no.
**Trampa del examen**: "¿PIVOT vs UNPIVOT?" → PIVOT = filas→columnas (alto→ancho). UNPIVOT = columnas→filas (ancho→alto). SI VES estos invertidos → TRAMPA. PIVOT lo hace más ancho, UNPIVOT lo hace más alto. Opuestos exactos.


### Ejemplos de Preguntas de Escenario — SQL Query Techniques

**Escenario:** A sales manager needs a report showing each salesperson's monthly revenue alongside a running total for the year. The output should keep every individual monthly row visible (not collapsed). A junior analyst suggests using `GROUP BY salesperson, month` with `SUM(revenue)`. Why is this approach incomplete, and what is the correct technique?
**Respuesta:** GROUP BY with SUM would give the monthly total per salesperson, but it cannot produce a **running total** across months while keeping each row visible. The correct approach is a **window function**:
```sql
SELECT salesperson, month, revenue,
  SUM(revenue) OVER (PARTITION BY salesperson ORDER BY month
    ROWS UNBOUNDED PRECEDING) AS ytd_revenue
FROM monthly_sales;
```
The window function calculates the running sum across all preceding months within each salesperson's partition, without collapsing rows. GROUP BY collapses rows; window functions preserve them. This is a key exam distinction — if the question says "keep all rows" or "running total," think window functions, not GROUP BY.

**Escenario:** A data team has a `user_logins` table with duplicate entries (same user can log in multiple times per day). They need to keep only the most recent login per user per day. An analyst writes a subquery with GROUP BY and MAX(login_time), then joins back to get the full row. A senior engineer suggests a simpler approach. What is it?
**Respuesta:** Use **QUALIFY** with **ROW_NUMBER()** — this is the idiomatic Snowflake approach for deduplication:
```sql
SELECT *
FROM user_logins
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY user_id, DATE(login_time)
  ORDER BY login_time DESC
) = 1;
```
QUALIFY filters the results of window functions directly, eliminating the need for a subquery or CTE wrapper. It executes after window functions are computed (just like HAVING executes after GROUP BY). The execution order is: WHERE → GROUP BY/HAVING → Window Functions → QUALIFY. Remember: QUALIFY is Snowflake-specific (not ANSI SQL standard) — this is a common exam point.

**Escenario:** A finance team has a `quarterly_results` table with columns: `company`, `Q1_revenue`, `Q2_revenue`, `Q3_revenue`, `Q4_revenue`. They need to transform this into a normalized format with columns: `company`, `quarter`, `revenue` — one row per company per quarter. What SQL technique should they use?
**Respuesta:** Use **UNPIVOT** to convert columns into rows (wide→tall):
```sql
SELECT company, quarter, revenue
FROM quarterly_results
  UNPIVOT(revenue FOR quarter IN (Q1_revenue, Q2_revenue, Q3_revenue, Q4_revenue));
```
UNPIVOT takes the four separate quarter columns and rotates them into rows, creating a `quarter` column (with the original column names as values) and a `revenue` column (with the corresponding values). The opposite operation — PIVOT — would convert rows back into columns (tall→wide) and requires an aggregate function. On the exam, remember: PIVOT = rows→columns (makes wider), UNPIVOT = columns→rows (makes taller).

**Escenario:** A product team needs a report showing total sales by region and product category, but they also need subtotal rows for each region and a grand total row at the bottom. Writing multiple UNION ALL queries for each subtotal level seems cumbersome. What is the efficient approach?
**Respuesta:** Use **ROLLUP** within GROUP BY to automatically generate hierarchical subtotals:
```sql
SELECT region, product_category, SUM(sales) AS total_sales
FROM sales_data
GROUP BY ROLLUP(region, product_category);
```
ROLLUP produces subtotals in a left-to-right hierarchy: (region, product_category), (region, NULL) for region subtotals, and (NULL, NULL) for the grand total. If they needed ALL possible combinations of subtotals (not just hierarchical), they'd use **CUBE** instead. If they only needed specific custom grouping combinations, they'd use **GROUPING SETS**. The exam tests the distinction: ROLLUP = hierarchical, CUBE = all combos, GROUPING SETS = you pick exactly which.

---

---

## 4.7 PROCEDIMIENTOS ALMACENADOS vs UDFs

### Procedimientos Almacenados:
- Ejecutan lógica procedimental
- Pueden incluir DDL/DML (CREATE, INSERT, etc.)
- Se llaman con CALL nombre_procedimiento()
- Lenguajes: SQL (Snowflake Scripting), JavaScript, Python, Java, Scala
- Pueden retornar un solo valor

### UDFs (Funciones Definidas por el Usuario):
- Retornan valores para uso en expresiones SQL
- Se pueden usar en SELECT, WHERE, etc.
- Lenguajes: SQL, JavaScript, Python, Java
- Pueden ser escalares (un valor) o tabulares (UDTF - retorna tabla)
- NO pueden ejecutar DDL/DML

### Funciones Externas:
- Llaman APIs externas (AWS Lambda, Azure Functions)
- Requieren Integración de API
- Los datos salen de Snowflake → se procesan externamente → retornan

**Trampa del examen**: "¿Ejecutar DDL dentro de una función?" → Usar Procedimiento Almacenado (no UDF). SI VES "UDF" con CREATE/INSERT/DDL → TRAMPA. Las UDFs no pueden ejecutar DDL/DML. Solo los Procedimientos Almacenados pueden.
**Trampa del examen**: "¿Usar en sentencia SELECT?" → UDF (no Procedimiento Almacenado). SI VES "CALL" dentro de SELECT o Procedimiento en SELECT → TRAMPA. Los procedimientos usan CALL, solo las UDFs funcionan dentro de SELECT/WHERE.
**Trampa del examen**: "¿NO es un lenguaje soportado para procedimientos almacenados?" → C++ (no soportado). SI VES "C++" como lenguaje válido → TRAMPA. Soportados: SQL, JavaScript, Python, Java, Scala. No C++.


### Ejemplos de Preguntas de Escenario — Stored Procedures vs UDFs

**Escenario:** A data engineering team needs to automate an end-of-month process that: (1) creates a new archive table with the current month's name, (2) inserts all transactions from the current month into that archive table, (3) deletes the archived transactions from the main table, and (4) returns a count of rows archived. Should they use a stored procedure or a UDF?
**Respuesta:** This requires a **Stored Procedure**. The process involves DDL (CREATE TABLE), DML (INSERT, DELETE), and procedural logic — none of which are allowed in a UDF. The procedure would be called with `CALL archive_monthly_transactions()`. UDFs are restricted to returning values and cannot execute DDL or DML statements. This is one of the most common exam distinctions: if the task involves CREATE, INSERT, UPDATE, DELETE, MERGE, or any schema changes, the answer is always Stored Procedure.

**Escenario:** A marketing team needs a reusable function that takes a customer's purchase history (total spend and number of orders) and returns a loyalty tier label ('Platinum', 'Gold', 'Silver', 'Bronze'). They want to use it directly in SELECT statements like: `SELECT customer_name, calculate_loyalty_tier(total_spend, order_count) FROM customers`. Should this be a procedure or a UDF?
**Respuesta:** This must be a **scalar UDF** (User-Defined Function). The requirement to use it inside a SELECT statement is the key indicator — only UDFs can be embedded in SQL expressions (SELECT, WHERE, HAVING, etc.). Stored procedures are invoked with CALL and cannot be used inside queries. The UDF would accept two numeric inputs and return a VARCHAR tier label. It could be written in SQL, Python, Java, or JavaScript. Example: `CREATE FUNCTION calculate_loyalty_tier(spend FLOAT, orders INT) RETURNS VARCHAR AS $$ ... $$`.

**Escenario:** A company needs to call an external fraud detection API (hosted on AWS Lambda) from within Snowflake during query execution. For each transaction row, they want to send the transaction details to the API and get back a fraud risk score. What type of function should they create, and what additional Snowflake object is required?
**Respuesta:** They need an **External Function** backed by an **API Integration**. External functions allow Snowflake to call external REST APIs (like AWS Lambda or Azure Functions) during query execution. The setup requires: (1) an API Integration object that defines the trusted external endpoint and authentication, (2) the external function definition that maps Snowflake input/output to the API request/response. Once created, the external function works like a UDF in SELECT statements: `SELECT transaction_id, fraud_check(amount, merchant, location) AS risk_score FROM transactions`. Key consideration: data leaves Snowflake to the external service, so security and latency must be evaluated. External functions are slower than native UDFs because of the network round-trip.

**Escenario:** A developer needs to write a function that takes a department ID and returns a table of all employees in that department with their calculated bonus amounts. The output needs to be used in a FROM clause: `SELECT * FROM TABLE(get_department_bonuses(101))`. What type of object should they create?
**Respuesta:** They need a **User-Defined Table Function (UDTF)** — a UDF that `RETURNS TABLE(...)`. UDTFs return multiple rows (unlike scalar UDFs which return a single value) and are invoked with the `TABLE()` wrapper in the FROM clause. This is NOT a stored procedure — procedures use CALL and return a single value, not a result set usable in FROM. The UDTF can be written in SQL, Python, Java, or JavaScript. Example skeleton: `CREATE FUNCTION get_department_bonuses(dept_id INT) RETURNS TABLE(emp_name VARCHAR, bonus FLOAT) AS $$ ... $$`. On the exam, if you see TABLE() in FROM, think UDTF. If you see CALL, think stored procedure.

---

---

## REPASO RÁPIDO — Dominio 4

1. Tres cachés: Resultados (24hr, compartido, gratis), Warehouse (SSD, se pierde al suspender), Metadatos (siempre activo)
2. Caché de resultados compartido entre usuarios (mismo rol + mismo SQL + datos sin cambiar)
3. Suspender warehouse = caché local PERDIDO
4. Derrame (local o remoto) = escalar VERTICALMENTE (warehouse más grande)
5. Cola = escalar HORIZONTALMENTE (más clusters)
6. Funciones en columnas WHERE = previene pruning
7. Servicio de Aceleración de Consultas = serverless, escaneos grandes, Enterprise+
8. Optimización de Búsqueda = búsquedas puntuales, como índice secundario, Enterprise+
9. Claves de clustering = co-localizar datos, mejor pruning, mantenimiento automático
10. Vistas materializadas = pre-computadas, auto-refrescadas, Enterprise+
11. STATEMENT_TIMEOUT_IN_SECONDS = matar consultas de larga duración
12. VARIANT = contenedor semi-estructurado
13. FLATTEN + LATERAL = expandir datos anidados en filas
14. Funciones de ventana = cálculos a través de particiones (ROW_NUMBER, RANK, etc.)
15. Procedimientos Almacenados = procedimental + DDL/DML. UDFs = retornan valores en SQL.
16. C++ NO es soportado para procedimientos almacenados o UDFs
17. Privilegio MONITOR = ver query profiles de otros usuarios
18. Query Profile muestra: operadores, derrame, eficiencia de pruning, explosiones de joins
19. Warehouses separados por tipo de carga de trabajo
20. Auto-suspensión ahorra créditos cuando está inactivo

**Trampa del examen**: "¿Las claves de clustering requieren Enterprise?" → INCORRECTO. Las claves de clustering funcionan en TODAS las ediciones. SI VES "Enterprise requerido" para claves de clustering → TRAMPA. Solo el mantenimiento de Clustering Automático se factura como serverless. La clave en sí funciona en cualquier edición.
**Trampa del examen**: "¿QUALIFY es una cláusula exclusiva de Snowflake?" → Correcto. SI VES "estándar ANSI SQL" con QUALIFY → TRAMPA. QUALIFY es específico de Snowflake, no es estándar ANSI SQL. Filtra resultados de funciones de ventana directamente.

---

## PARES CONFUSOS — Dominio 4

| Preguntan sobre... | La respuesta es... | NO es... |
|---|---|---|
| Caché se pierde al suspender | Caché de Warehouse (SSD) | Caché de Resultados |
| Caché compartido entre usuarios | Caché de Resultados | Caché de Warehouse |
| Caché sin costo | Caché de Resultados | Caché de Warehouse |
| Duración del caché de resultados | 24 horas (31 días máx renovación) | Indefinido |
| Solución para derrame | Escalar VERTICALMENTE (warehouse más grande) | Escalar HORIZONTALMENTE (más clusters) |
| Solución para cola | Escalar HORIZONTALMENTE (más clusters) | Escalar VERTICALMENTE (warehouse más grande) |
| Búsquedas puntuales en miles de millones | Optimización de Búsqueda | Aceleración de Consultas |
| Escaneos de tablas grandes | Aceleración de Consultas | Optimización de Búsqueda |
| Resultados pre-computados | Vista Materializada | Vista Estándar |
| Previene pruning | Funciones en columnas de filtro | Cláusulas WHERE simples |
| Costo de mantenimiento en segundo plano | Créditos serverless | Gratis |
| DDL dentro de lógica SQL | Procedimiento Almacenado | UDF |
| Usar en SELECT/WHERE | UDF | Procedimiento Almacenado |
| Matar consulta larga | STATEMENT_TIMEOUT_IN_SECONDS | Monitor de Recursos |
| Matar consulta en cola | STATEMENT_QUEUED_TIMEOUT_IN_SECONDS | Auto-suspensión |
| Aplanar array anidado | LATERAL FLATTEN | PARSE_JSON |
| Navegar JSON | Notación de punto (col:clave) | Indexación de array |

**Trampa del examen**: "¿Vista materializada vs caché de resultados?" → MV es una tabla física pre-computada (auto-refrescada, consume créditos). Caché de resultados es una respuesta de consulta almacenada (24hr, gratis). SI VES estos tratados como equivalentes → TRAMPA. MV = objeto físico persistente. Caché de resultados = respuesta cacheada temporal. Mecanismos totalmente diferentes.
**Trampa del examen**: "¿LATERAL FLATTEN vs solo FLATTEN?" → LATERAL se necesita para correlacionar la salida aplanada de vuelta a la fila fuente. SI VES FLATTEN sin LATERAL en una consulta con join → TRAMPA. Sin LATERAL pierdes el contexto de join con la fila padre.

---

## RESUMEN AMIGABLE — Dominio 4

### ÁRBOLES DE DECISIÓN POR ESCENARIO
Cuando leas una pregunta, encuentra el patrón:

**"El reporte de fin de mes de un banco está derramando a disco local..."**
→ Escalar VERTICALMENTE (warehouse más grande = más memoria)
→ NO escalar HORIZONTALMENTE (más clusters no ayudan a una consulta lenta)

**"El reporte de fin de mes de un banco está derramando a disco REMOTO..."**
→ Escalar VERTICALMENTE aún MÁS (derrame remoto = realmente necesita más memoria)
→ Misma solución, solo más urgente

**"Un sitio de e-commerce tiene 200 analistas consultando al mismo tiempo y las consultas están en cola..."**
→ Escalar HORIZONTALMENTE (warehouse multi-cluster, Enterprise+)
→ NO escalar VERTICALMENTE (warehouse más grande no reduce la cola)

**"Una empresa de salud ejecuta la misma consulta de pacientes miles de veces al día..."**
→ El Caché de Resultados maneja esto (24hr, gratis, sin warehouse necesario)
→ Mismo SQL + mismo rol + datos sin cambiar = hit de caché

**"Un analista diferente ejecuta exactamente la misma consulta que otro analista..."**
→ AÚN usa Caché de Resultados (compartido entre usuarios SI mismo rol)
→ Diferente usuario no importa — mismo rol + mismo SQL = hit de caché

**"Un admin suspende un warehouse para ahorrar costos. ¿Qué pasa con los datos cacheados?"**
→ Caché de Warehouse (SSD) se PIERDE
→ Caché de resultados está bien (está en Cloud Services, no en el warehouse)

**"Una empresa de telecomunicaciones busca un número de teléfono específico en 5 mil millones de registros de llamadas..."**
→ Servicio de Optimización de Búsqueda (búsqueda puntual, alta cardinalidad, Enterprise+)
→ NO Aceleración de Consultas (eso es para ESCANEOS grandes)

**"El dashboard de una empresa retail escanea toda la tabla de ventas cada mañana..."**
→ Servicio de Aceleración de Consultas (descarga porciones de escaneo grande, Enterprise+)
→ NO Optimización de Búsqueda (eso es para búsquedas de ID específico)

**"La cláusula WHERE de una consulta usa UPPER(email) = 'TEST@MAIL.COM'..."**
→ MALO — función en columna previene pruning
→ Solución: almacenar una columna pre-computada o reescribir el filtro

**"Un join produce 100x más filas que las tablas de entrada..."**
→ Join explosivo / producto cartesiano
→ Solución: verificar condiciones de join, agregar predicados adecuados

**"Un equipo de ciencia de datos ejecuta consultas ML costosas en datos que raramente cambian..."**
→ Vista Materializada (pre-computada, auto-refrescada, Enterprise+)
→ Mejor cuando: consulta costosa + cambios de datos infrecuentes

**"Un cliente quiere ejecutar lógica procedimental con CREATE TABLE dentro..."**
→ Procedimiento Almacenado (puede ejecutar DDL/DML)
→ NO UDF (las UDFs no pueden ejecutar DDL/DML)

**"Un cliente quiere una función reutilizable dentro de cláusulas SELECT y WHERE..."**
→ UDF (retorna valores usables en expresiones SQL)
→ NO Procedimiento Almacenado (se llama con CALL, no en SELECT)

**"Un cliente quiere llamar una función AWS Lambda externa desde Snowflake..."**
→ Función Externa + Integración de API
→ Los datos salen de Snowflake, se procesan externamente, retornan

**"La tabla de un cliente tiene 10 mil millones de filas. Las consultas siempre filtran por fecha pero es lento..."**
→ Agregar clave de clustering en la columna de fecha (ALTER TABLE ... CLUSTER BY (col_fecha))
→ El clustering automático la mantiene (créditos serverless)
→ Co-localiza fechas similares en las mismas micro-particiones → mejor pruning

**"Un cliente redimensionó un warehouse de Small a Large mientras una consulta estaba ejecutándose. ¿La consulta en ejecución se beneficia?"**
→ NO. Las consultas en ejecución usan el tamaño ANTERIOR.
→ Solo NUEVAS consultas después del redimensionamiento usan el warehouse Large.

**"El Query Profile de un cliente muestra alto 'Bytes Scanned' pero bajo 'Rows Returned'..."**
→ Pruning deficiente — escaneando mucho más datos de los necesarios
→ Solución: agregar/mejorar clave de clustering, verificar cláusulas WHERE

**"Un cliente necesita totales acumulados en datos de ventas mensuales..."**
→ Función de ventana: SUM(ventas) OVER (ORDER BY mes ROWS UNBOUNDED PRECEDING)
→ NO GROUP BY (eso colapsa filas, las funciones de ventana mantienen todas las filas)

**"Un cliente necesita rankear empleados por salario dentro de cada departamento..."**
→ RANK() o DENSE_RANK() OVER (PARTITION BY depto ORDER BY salario DESC)
→ RANK = saltos en ranking (empates saltan), DENSE_RANK = sin saltos

**"Un cliente tiene arrays JSON anidados en una columna VARIANT y necesita cada elemento del array como fila separada..."**
→ LATERAL FLATTEN(input => col:clave_array)
→ Cada elemento se convierte en su propia fila, unido de vuelta a la fuente

**"Un cliente pregunta: ¿cuál es la diferencia entre GROUPING SETS, ROLLUP y CUBE?"**
→ GROUPING SETS = combinaciones específicas que tú eliges
→ ROLLUP = subtotales jerárquicos (año → mes → día)
→ CUBE = TODAS las combinaciones posibles de subtotales

**"Un warehouse ETL y un warehouse de reportes BI compiten por recursos..."**
→ Usar warehouses SEPARADOS para cada carga de trabajo (mejores prácticas)
→ ETL = warehouse dedicado, BI = warehouse dedicado
→ Previene que una carga de trabajo prive de recursos a la otra

**"Un cliente quiere matar automáticamente consultas que tarden más de 30 minutos..."**
→ STATEMENT_TIMEOUT_IN_SECONDS = 1800
→ Configurar a nivel de warehouse, sesión, o cuenta

**"El warehouse de un cliente está inactivo la mayor parte del día pero recibe ráfagas de consultas cada hora..."**
→ Timeout de auto-suspensión corto (1-2 minutos) para ahorrar créditos durante inactividad
→ Auto-resume maneja las ráfagas automáticamente

**"Un cliente quiere una UDTF (función de tabla) que retorne múltiples filas..."**
→ Función de Tabla Definida por el Usuario (RETURNS TABLE)
→ Lenguajes: SQL, JavaScript, Python, Java
→ Se usa con TABLE() en cláusula FROM

---

### MNEMOTÉCNICOS PARA RECORDAR

**Tres cachés = "R-W-M" → "Resultados, Warehouse, Metadatos"**
- Caché de **R**esultados → 24hr, GRATIS, compartido, capa de Cloud Services
- Caché de **W**arehouse → SSD, se PIERDE al suspender, por warehouse
- Caché de **M**etadatos → siempre activo, COUNT(*)/MIN/MAX, gratis

**Flujo de caché = "R luego M luego W"**
- La consulta llega → verificar caché de Resultados primero → luego Metadatos → luego ejecutar en Warehouse

**Derrame vs Cola = "ARRIBA para Potencia, AFUERA para Personas"**
- Derrame (local o remoto) → escalar ARRIBA (warehouse más grande = más memoria)
- Cola (demasiadas consultas) → escalar AFUERA (más clusters = más espacio)

**Servicios de rendimiento = "QAS-SOS-CK-MV"**
- **Q**AS = Servicio de Aceleración de Consultas (escaneos grandes, serverless, Enterprise+)
- **S**OS = Servicio de Optimización de Búsqueda (búsquedas puntuales, como un índice, Enterprise+)
- **C**K = Claves de Clustering (co-localizar datos, mejor pruning, TODAS las ediciones)
- **M**V = Vistas Materializadas (resultados pre-computados, Enterprise+)

**Procedimientos vs UDFs = "Procedimientos HACEN, Funciones RETORNAN"**
- Procedimientos Almacenados → HACEN cosas (DDL, DML, lógica procedimental) → CALL
- UDFs → RETORNAN valores → se usan en SELECT/WHERE

**Navegación semi-estructurada = "Punto-Cast-Flat"**
- **Punto** notación → col:clave.subclave (navegar)
- **Cast** → ::string, ::number (convertir tipos)
- **Flat**ten → LATERAL FLATTEN (expandir arrays en filas)

---

### TRAMPAS PRINCIPALES — Dominio 4

1. **"El caché de resultados requiere un warehouse en ejecución"** → INCORRECTO. El caché de resultados es GRATIS, no necesita warehouse.
2. **"El caché de resultados es por usuario"** → INCORRECTO. Compartido entre usuarios (mismo rol + mismo SQL + datos sin cambiar).
3. **"El caché de warehouse sobrevive la suspensión"** → INCORRECTO. Caché SSD se PIERDE al suspender.
4. **"Derrame → agregar más clusters"** → INCORRECTO. Derrame → warehouse más grande (escalar VERTICALMENTE).
5. **"Cola → warehouse más grande"** → INCORRECTO. Cola → más clusters (escalar HORIZONTALMENTE).
6. **"QAS ayuda con búsquedas puntuales"** → INCORRECTO. QAS = escaneos grandes. SOS = búsquedas puntuales.
7. **"SOS es como una vista materializada"** → INCORRECTO. SOS = rutas de acceso/índice. MV = resultados pre-computados.
8. **"Las claves de clustering requieren Enterprise"** → INCORRECTO. TODAS las ediciones.
9. **"Clustering automático es gratis"** → INCORRECTO. Consume créditos serverless.
10. **"Las UDFs pueden ejecutar DDL"** → INCORRECTO. Solo los Procedimientos Almacenados.
11. **"Los Procedimientos Almacenados se usan en SELECT"** → INCORRECTO. Solo las UDFs van en SELECT.
12. **"C++ es un lenguaje soportado"** → INCORRECTO. SQL, JavaScript, Python, Java, Scala.

---

### ATAJOS DE PATRONES — "Si ves ___, la respuesta es ___"

| Si la pregunta menciona... | La respuesta casi siempre es... |
|---|---|
| "derrame a disco" | Escalar VERTICALMENTE (warehouse más grande) |
| "consultas en cola" | Escalar HORIZONTALMENTE (más clusters) |
| "misma consulta, sin costo" | Caché de Resultados |
| "caché perdido al suspender" | Caché de Warehouse (SSD) |
| "COUNT(*) sin warehouse" | Caché de Metadatos |
| "buscar ID específico en miles de millones" | Servicio de Optimización de Búsqueda (Enterprise+) |
| "escaneo de tabla grande" | Servicio de Aceleración de Consultas (Enterprise+) |
| "pre-computar resultados" | Vista Materializada (Enterprise+) |
| "mejorar pruning en tabla grande" | Clave de Clustering |
| "ejecutar DDL/DML en lógica" | Procedimiento Almacenado |
| "función en SELECT/WHERE" | UDF |
| "expandir array JSON en filas" | LATERAL FLATTEN |
| "filtrar después de función de ventana" | QUALIFY |
| "filtrar después de GROUP BY" | HAVING |
| "matar consultas largas" | STATEMENT_TIMEOUT_IN_SECONDS |
| "Economy vs Standard scaling" | Economy espera ~6min, Standard inmediato |

---

## CONSEJOS PARA EL DÍA DEL EXAMEN — Dominio 4 (21% = ~21 preguntas)

**Antes de estudiar este dominio:**
- Flashcards de los 3 cachés + sus propiedades (ubicación, duración, costo, alcance)
- Memoriza: Derrame = VERTICALMENTE, Cola = HORIZONTALMENTE
- Conoce QAS vs SOS vs Claves de Clustering vs Vistas Materializadas

**Durante el examen — Preguntas del Dominio 4:**
- Si mencionan "derrame" → escalar VERTICALMENTE (warehouse más grande)
- Si mencionan "cola" o "concurrencia" → escalar HORIZONTALMENTE (más clusters)
- Si mencionan "suspender" + "caché" → caché de Warehouse se pierde, caché de Resultados sobrevive
- Si mencionan "búsqueda puntual" → SOS. Si mencionan "escaneo grande" → QAS.
- Si mencionan "DDL dentro de lógica" → Procedimiento Almacenado
- Si mencionan "usar en SELECT" → UDF

---

## FLASHCARDS — Dominio 4

**P:** ¿Cuáles son los tres tipos de caché de Snowflake?
**R:** Caché de Resultados (24hr, gratis, compartido, Cloud Services), Caché de Warehouse (SSD, se pierde al suspender), Caché de Metadatos (siempre activo, COUNT/MIN/MAX).

**P:** ¿Qué pasa con el caché cuando suspendes un warehouse?
**R:** El caché de Warehouse (SSD) se pierde. El caché de Resultados (Cloud Services) NO se afecta.

**P:** ¿Cuándo debes escalar verticalmente vs horizontalmente?
**R:** VERTICALMENTE para derrame (más memoria). HORIZONTALMENTE para cola/concurrencia (más clusters, Enterprise+).

**P:** ¿Cuál es la diferencia entre QAS y SOS?
**R:** QAS = escaneos grandes de tabla (serverless, Enterprise+). SOS = búsquedas puntuales de ID/valor (como índice, Enterprise+).

**P:** ¿Procedimiento Almacenado vs UDF?
**R:** Procedimiento = puede ejecutar DDL/DML, se llama con CALL. UDF = retorna valores, se usa en SELECT/WHERE. Las UDFs NO pueden ejecutar DDL.

**P:** ¿Qué previene el pruning efectivo?
**R:** Funciones en columnas de filtro (ej. WHERE UPPER(col)). La función impide que Snowflake use min/max de metadatos para saltar particiones.

**P:** ¿Qué es QUALIFY?
**R:** Cláusula específica de Snowflake que filtra resultados de funciones de ventana. WHERE filtra antes de agrupar, HAVING después de GROUP BY, QUALIFY después de funciones de ventana.

**P:** ¿Cuándo usar Vistas Materializadas?
**R:** Consultas costosas en datos que cambian infrecuentemente. Enterprise+. Se auto-refrescan (consume créditos). Limitadas a tabla única.

---

## EXPLÍCALO COMO SI TUVIERA 5 AÑOS — Dominio 4

**Caché de Resultados**: Como recordar la respuesta a una pregunta de matemáticas. Si alguien pregunta "¿cuánto es 2+2?" y ya lo calculaste, solo dices "4" sin recalcular. Gratis y rápido.

**Caché de Warehouse**: Como tener tus libros favoritos en tu escritorio. Rápido de alcanzar. Pero si limpias tu escritorio (suspendes), tienes que ir a buscarlos de nuevo a la biblioteca.

**Caché de Metadatos**: Como saber cuántos libros tienes sin contarlos — solo miras el número en el estante.

**Escalar VERTICALMENTE**: Tu mochila es muy pequeña para cargar todos tus libros. Consigue una mochila MÁS GRANDE.

**Escalar HORIZONTALMENTE**: Demasiados niños quieren usar el columpio. Consigue MÁS COLUMPIOS.

**Clave de Clustering**: Organizar tus libros por color en el estante. Cuando quieres un libro rojo, solo buscas en la sección roja en vez de revisar todo el estante.

**Query Profile**: Una radiografía de tu consulta. Te muestra exactamente dónde está lenta y por qué.

**Procedimiento Almacenado**: Una receta de cocina — pasos a seguir en orden, puede crear platos nuevos (CREATE), modificar ingredientes (UPDATE), tirar lo que no sirve (DELETE).

**UDF**: Una calculadora — le das números, te da un resultado. No puede crear ni destruir nada, solo calcula.

**FLATTEN**: Tienes una caja con cajitas adentro. FLATTEN abre todas las cajitas y pone todo en una fila para que puedas verlo.

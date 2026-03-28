# Dominio 3: Ingeniería de Datos

> **Cobertura del Temario ARA-C01:** Carga/Descarga de Datos, Transformación de Datos, Herramientas del Ecosistema

---

## 3.1 CARGA DE DATOS

**COPY INTO (Carga Masiva)**

- Comando principal para carga masiva/por lotes desde stages hacia tablas
- Soporta: CSV, JSON, Avro, Parquet, ORC, XML
- Opciones clave: `ON_ERROR`, `PURGE`, `FORCE`, `MATCH_BY_COLUMN_NAME`
- `VALIDATION_MODE` — ejecución de prueba para verificar datos sin cargarlos
- Retorna metadatos: filas cargadas, errores, nombres de archivos
- Ideal para: cargas masivas programadas, migración inicial de datos, archivos grandes

**Snowpipe (Carga Continua)**

- Serverless, pipeline de auto-ingesta disparado por eventos en la nube (notificaciones S3, GCS Pub/Sub, Azure Event Grid)
- Casi en tiempo real (micro-batch, típicamente segundos a minutos de latencia)
- Usa un objeto PIPE: `CREATE PIPE ... AUTO_INGEST = TRUE AS COPY INTO ...`
- Facturado por segundo de cómputo serverless + overhead de notificaciones de archivos
- Semántica de exactamente una vez mediante metadatos de carga de archivos (ventana de deduplicación de 14 días)

**Snowpipe Streaming**

- Opción de menor latencia: las filas llegan en segundos, sin archivos involucrados
- Usa el Snowflake Ingest SDK (Java) — el cliente llama `insertRows()`
- Los datos se escriben en un área de staging, luego se migran automáticamente al almacenamiento de la tabla
- No necesita objeto pipe — usa objetos `CHANNEL`
- Ideal para: IoT, clickstream, datos de eventos en tiempo real
- Se combina con Dynamic Tables para transformación en tiempo real

**Detección y Evolución de Esquema**

- **Detección de esquema** (`INFER_SCHEMA`): detecta automáticamente nombres/tipos de columnas de archivos en stage
  - Funciona con Parquet, Avro, ORC, CSV (con encabezados)
  - `SELECT * FROM TABLE(INFER_SCHEMA(LOCATION => '@stage', FILE_FORMAT => 'fmt'))`
  - Usar con `CREATE TABLE ... USING TEMPLATE` para DDL automático
- **Evolución de esquema** (`ENABLE_SCHEMA_EVOLUTION = TRUE`): columnas nuevas en archivos fuente se agregan automáticamente a la tabla
  - Las columnas existentes NO se modifican ni eliminan
  - Requiere privilegio EVOLVE SCHEMA en el rol del archivo

### Por Qué Esto Importa
Una empresa de retail recibe 500 archivos CSV diarios de sus tiendas. Snowpipe los ingesta automáticamente cuando llegan a S3. La evolución de esquema maneja columnas nuevas (ej., "loyalty_tier") sin ALTER TABLE manual.

### Mejores Prácticas
- Usa Snowpipe para flujos constantes y orientados a eventos; COPY INTO para grandes cargas programadas
- Configura `ON_ERROR = CONTINUE` para cargas no críticas (con monitoreo de errores)
- Habilita la evolución de esquema en tablas de staging para manejar cambios en el esquema fuente
- Usa `MATCH_BY_COLUMN_NAME` cuando las columnas fuente no coinciden con el orden de la tabla
- Monitorea Snowpipe via `PIPE_USAGE_HISTORY` y `COPY_HISTORY`

**Trampa del examen:** SI VES "Snowpipe Streaming requiere un objeto PIPE" → **INCORRECTO** porque Streaming usa CHANNELS, no pipes.

**Trampa del examen:** SI VES "COPY INTO detecta automáticamente el esquema" → **INCORRECTO** porque debes usar explícitamente `INFER_SCHEMA` o `USING TEMPLATE`.

**Trampa del examen:** SI VES "la evolución de esquema puede eliminar columnas" → **INCORRECTO** porque solo AGREGA columnas nuevas; nunca elimina ni modifica las existentes.

**Trampa del examen:** SI VES "Snowpipe carga datos sincrónicamente" → **INCORRECTO** porque Snowpipe es asincrónico (serverless, orientado a eventos).

### Preguntas Frecuentes (FAQ)
**P: ¿Cuál es la ventana de deduplicación de Snowpipe?**
R: 14 días. Los archivos cargados en los últimos 14 días no se recargarán (basado en nombre de archivo + metadatos).

**P: ¿Puedo usar Snowpipe con stages internos?**
R: Sí, pero la auto-ingesta con notificaciones en la nube solo funciona con stages externos. Para stages internos, debes llamar la API REST `insertFiles` manualmente.

**P: ¿Cuándo debo usar Snowpipe Streaming vs Snowpipe regular?**
R: Usa Streaming cuando necesites latencia menor a un segundo y estés generando datos programáticamente (no archivos). Usa Snowpipe regular cuando los datos llegan como archivos en almacenamiento en la nube.


### Ejemplos de Preguntas de Escenario — Data Loading

**Escenario:** A retail chain has 2,000 stores, each uploading daily sales CSV files to S3 at unpredictable times throughout the day. The analytics team needs data available within 5 minutes of upload. Currently, a scheduled COPY INTO job runs hourly, causing up to 60 minutes of latency and occasionally missing late-arriving files. How should the architect redesign the ingestion?
**Respuesta:** Replace the scheduled COPY INTO with Snowpipe using auto-ingest. Configure S3 event notifications (SQS) on the bucket to trigger Snowpipe whenever a new file lands. Create a PIPE object with `AUTO_INGEST = TRUE` pointing to the S3 stage with the appropriate file format. Snowpipe processes files within seconds to minutes of arrival — well within the 5-minute SLA. It uses serverless compute (no dedicated warehouse), and the 14-day deduplication window prevents re-loading files. Enable schema evolution on the target table to handle any new columns stores may add over time.

**Escenario:** An IoT platform receives 50,000 sensor events per second from industrial equipment. Events must be queryable within 2 seconds for real-time monitoring dashboards. File-based ingestion cannot meet the latency requirement. What ingestion method should the architect use?
**Respuesta:** Use Snowpipe Streaming via the Snowflake Ingest SDK (Java). The application calls `insertRows()` to write events directly to Snowflake without creating intermediate files — achieving sub-second latency. Data lands in a staging area and is automatically migrated to table storage. No PIPE object is needed; the SDK uses CHANNEL objects. Combine Snowpipe Streaming with dynamic tables for real-time transformation — e.g., a dynamic table with a 1-minute target lag that aggregates raw sensor events into equipment health metrics for the monitoring dashboard.

**Escenario:** A data engineering team is onboarding a new data source that adds new columns to its JSON payloads every few weeks. They don't want to manually ALTER TABLE each time. How should the architect configure the pipeline to handle this automatically?
**Respuesta:** Enable schema evolution on the target table: `ALTER TABLE ... SET ENABLE_SCHEMA_EVOLUTION = TRUE`. Use `MATCH_BY_COLUMN_NAME = 'CASE_INSENSITIVE'` in the COPY INTO or Snowpipe definition so that columns are matched by name rather than position. When new columns appear in the source files, Snowflake automatically adds them to the table. Existing columns are never modified or removed. The role running the load must have the EVOLVE SCHEMA privilege on the table. Use `INFER_SCHEMA` for the initial table creation to detect the starting schema from a sample file.

---

---

## 3.2 STAGES Y FORMATOS DE ARCHIVO

**Stages Internos**

- **User stage** (`@~`): uno por usuario, no se puede alterar ni eliminar
- **Table stage** (`@%nombre_tabla`): uno por tabla, vinculado a esa tabla
- **Named internal stage** (`@mi_stage`): creado explícitamente, el más flexible
- Datos almacenados en almacenamiento administrado por Snowflake, cifrados en reposo

**Stages Externos**

- Apuntan a almacenamiento en la nube: S3, GCS, Azure Blob/ADLS
- Requieren un **storage integration** (mejor práctica) o credenciales inline (no recomendado)
- Soportan rutas de carpetas: `@ext_stage/ruta/a/carpeta/`

**Formatos de Archivo**

- Definiciones de formato reutilizables: `CREATE FILE FORMAT`
- Tipos: CSV, JSON, AVRO, PARQUET, ORC, XML
- Opciones clave de CSV: `FIELD_DELIMITER`, `SKIP_HEADER`, `NULL_IF`, `ERROR_ON_COLUMN_COUNT_MISMATCH`
- Opciones clave de JSON: `STRIP_OUTER_ARRAY`, `STRIP_NULL_VALUES`
- Se pueden especificar inline en COPY INTO o referenciar por nombre

**Directory Tables**

- Capa de metadatos sobre un stage: `ALTER STAGE @mi_stage SET DIRECTORY = (ENABLE = TRUE)`
- Permite consultar metadatos de archivos (nombre, tamaño, MD5, last_modified) via SQL
- Debe refrescarse: `ALTER STAGE @mi_stage REFRESH`
- Auto-refresh disponible para stages externos con notificaciones en la nube
- Útil para inventario de archivos, rastreo de nuevas llegadas, construcción de pipelines de procesamiento

### Por Qué Esto Importa
Un data lake tiene 2M de archivos Parquet en S3. Una directory table proporciona un inventario consultable sin listar objetos via AWS CLI. Combinado con streams, puedes detectar archivos nuevos automáticamente.

### Mejores Prácticas
- Siempre usa storage integrations para stages externos (sin credenciales inline)
- Usa named internal stages sobre table/user stages para cargas de producción
- Define formatos de archivo como objetos reutilizables, no especificaciones inline
- Habilita directory tables con auto-refresh para pipelines orientados a archivos

**Trampa del examen:** SI VES "los user stages se pueden compartir entre usuarios" → **INCORRECTO** porque el stage de cada usuario es privado y limitado a ese usuario.

**Trampa del examen:** SI VES "las directory tables almacenan los datos reales del archivo" → **INCORRECTO** porque solo almacenan metadatos sobre los archivos.

**Trampa del examen:** SI VES "los table stages soportan todas las funciones de stage" → **INCORRECTO** porque los table stages no pueden tener file formats y tienen opciones limitadas comparados con named stages.

### Preguntas Frecuentes (FAQ)
**P: ¿Puedo dar acceso (GRANT) a un user stage?**
R: No. Los user stages son por usuario y no se pueden otorgar a otros.

**P: ¿Las directory tables funcionan en stages internos?**
R: Sí, pero el auto-refresh solo está disponible para stages externos. Los stages internos requieren `REFRESH` manual.


### Ejemplos de Preguntas de Escenario — Stages & File Formats

**Escenario:** A data lake has 2 million Parquet files in S3 across hundreds of folders. The data engineering team needs to track which files have been processed, identify new arrivals, and build processing pipelines based on file metadata (size, last modified date). Currently, they run AWS CLI `ls` commands which take 30+ minutes. How should the architect improve this?
**Respuesta:** Create an external stage pointing to the S3 bucket with a storage integration (no inline credentials). Enable a directory table on the stage: `ALTER STAGE @data_lake SET DIRECTORY = (ENABLE = TRUE)`. Configure auto-refresh with S3 event notifications so the directory table updates automatically when new files land. The team can now query file metadata (name, size, MD5, last_modified) via standard SQL in seconds instead of running CLI commands. Combine the directory table with a stream to detect new file arrivals and trigger processing tasks automatically.

**Escenario:** A security audit reveals that several external stages in production were created with inline AWS access keys embedded directly in the stage definition. How should the architect remediate this and prevent recurrence?
**Respuesta:** Recreate all external stages using storage integrations instead of inline credentials. A storage integration uses IAM roles (on AWS) or service principals (on Azure) — no raw credentials in SQL. After migrating all stages, set the account-level parameter `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION = TRUE` to prevent anyone from creating stages with inline credentials in the future. Rotate the compromised AWS access keys immediately. Use named internal stages over table/user stages for any internally-staged data in production.

---

---

## 3.3 STREAMS Y TASKS

**Streams (Captura de Datos de Cambio)**

- Rastrean cambios DML (INSERT, UPDATE, DELETE) en una tabla fuente
- Tres tipos:
  - **Standard:** rastrean los tres tipos de DML, usan columnas ocultas
  - **Append-only:** solo rastrean INSERTs (más económico, más simple)
  - **Insert-only (en external tables):** rastrean archivos/filas nuevos en external tables
- Columnas de metadatos: `METADATA$ACTION`, `METADATA$ISUPDATE`, `METADATA$ROW_ID`
- El stream se "consume" cuando se usa en una transacción DML (avanza el offset)
- Un stream tiene una **ventana de caducidad** — si no se consume dentro de la retención de Time Travel, se vuelve obsoleto

**Change Tracking**

- Alternativa a streams: `ALTER TABLE ... SET CHANGE_TRACKING = TRUE`
- Consulta cambios via cláusula `CHANGES`: `SELECT * FROM tabla CHANGES(INFORMATION => DEFAULT) AT(...)`
- No tiene un offset consumible — consultas idempotentes
- Útil para consultas de cambios puntuales sin un objeto stream dedicado

**Tasks**

- Ejecución SQL programada (individual o en árboles de tasks/DAGs)
- Programación via expresión CRON o `SCHEDULE = 'N MINUTE'`
- Árboles de tasks: la task raíz dispara las hijas en orden de dependencia
- Las tasks usan cómputo serverless por defecto (o un warehouse especificado)
- Deben reanudarse explícitamente: `ALTER TASK ... RESUME`
- Cláusula `WHEN`: ejecución condicional (ej., `WHEN SYSTEM$STREAM_HAS_DATA('mi_stream')`)

**Árboles de Tasks (DAGs)**

- Task raíz → tasks hijas → tasks nietas
- Solo la task raíz tiene programación; las hijas se disparan automáticamente
- Task finalizadora: se ejecuta después de que todas las tasks del grafo terminen (éxito o fallo)
- Usa `ALLOW_OVERLAPPING_EXECUTION` para controlar ejecuciones concurrentes

### Por Qué Esto Importa
Una plataforma de e-commerce usa un stream en `raw_orders` y una task que se ejecuta cada 5 minutos. La task verifica `SYSTEM$STREAM_HAS_DATA`, y si es verdadero, hace merge de los cambios en `curated_orders`. CDC sin herramientas de terceros.

### Mejores Prácticas
- Usa `SYSTEM$STREAM_HAS_DATA` en la cláusula WHEN de la task para evitar ejecuciones vacías
- Configura `SUSPEND_TASK_AFTER_NUM_FAILURES` apropiadamente para detener errores descontrolados
- Usa tasks serverless a menos que necesites controlar el tamaño del warehouse
- Prefiere dynamic tables sobre stream+task para pipelines de transformación pura
- Monitorea tasks via `TASK_HISTORY` en ACCOUNT_USAGE

**Trampa del examen:** SI VES "los streams funcionan en vistas" → **INCORRECTO** porque los streams funcionan en tablas (y external tables), no en vistas.

**Trampa del examen:** SI VES "las tasks hijas pueden tener su propia programación" → **INCORRECTO** porque solo la task raíz tiene programación; las hijas se disparan por la finalización del padre.

**Trampa del examen:** SI VES "los streams nunca caducan" → **INCORRECTO** porque un stream caduca si no se consume dentro de la retención de Time Travel de la fuente + 14 días.

**Trampa del examen:** SI VES "las tasks se reanudan por defecto después de crearlas" → **INCORRECTO** porque las tasks se crean en estado SUSPENDED y deben reanudarse explícitamente.

### Preguntas Frecuentes (FAQ)
**P: ¿Pueden existir múltiples streams en la misma tabla?**
R: Sí. Cada stream rastrea independientemente con su propio offset.

**P: ¿Qué pasa si un stream caduca?**
R: Se vuelve inutilizable. Debes recrearlo. El offset se pierde y puede que necesites una recarga completa.

**P: ¿Las tasks pueden llamar stored procedures?**
R: Sí. El cuerpo de una task puede ser cualquier sentencia SQL individual, incluyendo `CALL mi_procedimiento()`.


### Ejemplos de Preguntas de Escenario — Streams & Tasks

**Escenario:** An e-commerce platform needs to merge incremental order updates (inserts, updates, deletes) from a raw orders table into a curated orders table every 5 minutes. The merge logic includes custom conflict resolution (e.g., latest timestamp wins for updates). What pipeline architecture should the architect use?
**Respuesta:** Create a standard stream on the raw orders table to capture all DML changes (inserts, updates, deletes). Create a task with a 5-minute schedule and a `WHEN SYSTEM$STREAM_HAS_DATA('orders_stream')` clause to avoid empty runs. The task body executes a MERGE statement that reads from the stream and applies custom conflict resolution logic (e.g., `WHEN MATCHED AND src.updated_at > tgt.updated_at THEN UPDATE`). Use serverless tasks unless the MERGE is complex enough to warrant a dedicated warehouse. Set `SUSPEND_TASK_AFTER_NUM_FAILURES` to stop runaway errors and monitor via `TASK_HISTORY`.

**Escenario:** A data platform has a complex ETL pipeline: raw data must be cleaned, then enriched with reference data, then aggregated into summary tables. Each step depends on the previous one completing successfully. If any step fails, a notification must be sent. How should the architect orchestrate this?
**Respuesta:** Build a task tree (DAG). The root task runs on a schedule and performs the cleaning step. A child task handles enrichment (triggered automatically on root success). A grandchild task handles aggregation. Add a finalizer task to the DAG — it runs after all tasks complete (whether they succeed or fail) and sends an email notification with the outcome. Only the root task has a schedule; children trigger on parent completion. Use `ALLOW_OVERLAPPING_EXECUTION = FALSE` on the root to prevent concurrent runs. Alternatively, if the pipeline is pure SQL transformations without custom merge logic, consider chaining dynamic tables instead — they handle scheduling and incremental refresh declaratively.

---

---

## 3.4 EXTERNAL TABLES E ICEBERG TABLES

**External Tables**

- Tabla de solo lectura sobre archivos en almacenamiento externo (S3, GCS, Azure)
- Snowflake solo almacena metadatos; los datos permanecen en tu almacenamiento en la nube
- Soporta auto-refresh de metadatos via notificaciones en la nube
- Rendimiento de consultas más lento que tablas nativas (sin clustering, sin optimización de micro-partitions)
- Soporte para particionamiento via columnas calculadas `PARTITION BY`
- Streams en external tables: solo insert (rastrean archivos nuevos)

**Managed Iceberg Tables**

- Snowflake administra el ciclo de vida de la tabla (ruta de escritura, compactación, snapshots)
- El external volume define DÓNDE se almacenan los datos (tu almacenamiento en la nube)
- DML completo: INSERT, UPDATE, DELETE, MERGE
- No se requiere catalog integration (Snowflake es el catálogo)
- Otros motores pueden leer los archivos de metadatos/datos Iceberg
- Soporta Time Travel, cloning, replicación

**Unmanaged Iceberg Tables (Vinculadas a Catálogo)**

- Un catálogo externo (Glue, Polaris/OpenCatalog, Unity, REST) administra los metadatos
- Snowflake lee el catálogo para entender la estructura de la tabla
- Solo lectura desde Snowflake (las escrituras van a través del motor externo)
- Requiere objeto CATALOG INTEGRATION
- Auto-refresh detecta cambios en el catálogo

**Incremental vs Full Refresh (Contexto Dynamic/Iceberg)**

- **Full refresh:** recalcula todo el dataset (costoso pero simple)
- **Incremental refresh:** solo procesa datos cambiados (más económico, requiere change tracking)
- Las dynamic tables usan incremental refresh cuando es posible (depende del operador)
- Algunas operaciones fuerzan full refresh (ej., funciones no determinísticas, joins complejos)

### Por Qué Esto Importa
Una empresa ejecuta tanto Spark como Snowflake. Las managed Iceberg tables permiten a Snowflake escribir datos en formato Iceberg a S3. Spark lee los mismos archivos directamente. Una copia de datos, dos motores.

### Mejores Prácticas
- Usa managed Iceberg para nuevos requisitos de "formato abierto" con Snowflake como motor principal
- Usa unmanaged/vinculadas a catálogo para datos propiedad de otro motor (Spark, Trino)
- Las external tables son legacy para acceso de solo lectura — prefiere Iceberg para proyectos nuevos
- Particiona external tables por fecha/región para query pruning

**Trampa del examen:** SI VES "las external tables soportan UPDATE/DELETE" → **INCORRECTO** porque las external tables son de solo lectura.

**Trampa del examen:** SI VES "las unmanaged Iceberg tables soportan MERGE" → **INCORRECTO** porque las escrituras deben pasar por el catálogo/motor externo.

**Trampa del examen:** SI VES "las managed Iceberg tables almacenan datos en el almacenamiento interno de Snowflake" → **INCORRECTO** porque escriben en un external volume (tu almacenamiento en la nube) en formato Iceberg.

**Trampa del examen:** SI VES "las dynamic tables siempre usan incremental refresh" → **INCORRECTO** porque ciertas operaciones fuerzan full refresh.

### Preguntas Frecuentes (FAQ)
**P: ¿Puedo convertir una external table a una tabla nativa?**
R: No directamente. Harías CTAS desde la external table hacia una nueva tabla nativa (o Iceberg).

**P: ¿Las managed Iceberg tables soportan clustering?**
R: Sí. Puedes definir clustering keys en managed Iceberg tables.

**P: ¿Cuál es la diferencia entre una external table y una unmanaged Iceberg table?**
R: Las external tables trabajan con archivos crudos (CSV, Parquet, etc.) con metadatos definidos por Snowflake. Las unmanaged Iceberg tables leen tablas en formato Iceberg administradas por un catálogo externo con capacidades completas de Iceberg (snapshots, evolución de esquema).


### Ejemplos de Preguntas de Escenario — External & Iceberg Tables

**Escenario:** A company's data science team uses Apache Spark on EMR to train ML models, and the analytics team uses Snowflake for reporting. Both teams need read/write access to the same feature store tables. Currently, data is duplicated in both Parquet files and Snowflake tables, causing consistency issues. How should the architect unify the data layer?
**Respuesta:** Migrate the feature store to managed Iceberg tables in Snowflake. Define an external volume pointing to S3 where the Iceberg data and metadata files will be stored. Snowflake manages the table lifecycle — full DML (INSERT, UPDATE, DELETE, MERGE), compaction, and snapshot management. The Spark team reads the same Iceberg metadata and data files from S3 directly using Spark's Iceberg connector. One copy of data, two engines, full consistency. Managed Iceberg tables also support Time Travel and clustering for the Snowflake analytics team.

**Escenario:** A partner organization manages their data catalog in AWS Glue and writes Iceberg tables from their Spark pipelines. Your company needs to query this data from Snowflake without taking ownership of the catalog. How should the architect set this up?
**Respuesta:** Create an unmanaged (catalog-linked) Iceberg table in Snowflake. Configure a catalog integration pointing to the partner's AWS Glue catalog. Snowflake reads the Glue-managed Iceberg metadata to understand the table structure and queries the data files directly from S3. This is read-only from Snowflake — all writes continue through the partner's Spark pipelines. Enable auto-refresh on the catalog integration so Snowflake detects when the partner updates the table. Do not use a managed Iceberg table here, as that would transfer catalog ownership to Snowflake and conflict with the partner's Spark writes.

---

---

## 3.5 TRANSFORMACIÓN DE DATOS

**FLATTEN**

- Convierte datos semi-estructurados (JSON, ARRAY, VARIANT) en filas
- Lateral join por defecto: `SELECT ... FROM tabla, LATERAL FLATTEN(input => col)`
- Parámetros clave: `INPUT`, `PATH`, `OUTER` (mantener filas con arrays vacíos), `RECURSIVE`, `MODE`
- Columnas de salida: `SEQ`, `KEY`, `PATH`, `INDEX`, `VALUE`, `THIS`

**UDFs (Funciones Definidas por el Usuario)**

- SQL, JavaScript, Python, Java, Scala
- UDFs escalares: retornan un valor por fila de entrada
- Deben ser determinísticas para uso en materialized views / clustering
- Secure UDFs: ocultan el cuerpo de la función a los consumidores

**UDTFs (Funciones de Tabla Definidas por el Usuario)**

- Retornan una tabla (múltiples filas por fila de entrada)
- Deben implementar: `PROCESS()` (lógica por fila) y opcionalmente `END_PARTITION()` (salida final)
- Se llaman con `TABLE()` en la cláusula FROM
- Útiles para: parsing, explosión, agregación personalizada

**External Functions**

- Llaman endpoints de API externos (ej., AWS Lambda, Azure Functions) desde SQL
- Requieren: API integration + definición de external function
- Sincrónicas: Snowflake llama la API por lote y espera
- Usar para: inferencia ML, enriquecimiento de terceros, lógica personalizada no disponible en Snowflake
- Siendo reemplazadas por UDFs basadas en contenedores (SPCS) para nuevos casos de uso

**Stored Procedures**

- Pueden contener flujo de control (IF, LOOP, BEGIN/END), múltiples sentencias SQL
- Lenguajes: SQL (Snowflake Scripting), JavaScript, Python, Java, Scala
- Pueden ejecutarse con derechos de CALLER o derechos de OWNER
- Usar para: tareas administrativas, ETL complejo, operaciones de múltiples pasos
- Diferencia clave con UDFs: los procedures pueden tener efectos secundarios (DML), las UDFs no

**Dynamic Tables**

- Transformación declarativa: define el objetivo como una consulta SQL + target lag
- Snowflake refresca automáticamente (incremental cuando es posible)
- Reemplazan cadenas complejas de stream+task para pipelines de transformación
- Target lag: `DOWNSTREAM` (cascada desde DTs upstream) o intervalo explícito
- No pueden usarse como fuente directa para streams

**Secure Functions**

- UDFs/UDTFs con palabra clave `SECURE`: el cuerpo se oculta a los consumidores
- Requeridas para funciones usadas en Secure Data Sharing
- Mismo fence del optimizador que las secure views

### Por Qué Esto Importa
Un pipeline aplana eventos JSON crudos, los enriquece via una external function (scoring ML), y deposita los resultados en una dynamic table con target lag de 5 minutos. Cero gestión de task/stream.

### Mejores Prácticas
- Prefiere dynamic tables sobre stream+task para pipelines solo de transformación
- Usa SQL UDFs para cálculos simples; Python UDFs para lógica compleja
- Minimiza las llamadas a external functions (overhead de red por lote)
- Usa stored procedures para flujos de trabajo administrativos, no para transformación de datos
- Configura el target lag de dynamic tables basándote en el SLA del negocio, no lo más bajo posible

**Trampa del examen:** SI VES "las UDFs pueden ejecutar sentencias DML" → **INCORRECTO** porque las UDFs son de solo lectura; solo los stored procedures pueden ejecutar DML.

**Trampa del examen:** SI VES "las dynamic tables pueden ser fuentes para streams" → **INCORRECTO** porque no puedes crear streams sobre dynamic tables.

**Trampa del examen:** SI VES "las external functions se ejecutan dentro del cómputo de Snowflake" → **INCORRECTO** porque llaman a un endpoint de API externo fuera de Snowflake.

**Trampa del examen:** SI VES "FLATTEN solo funciona con JSON" → **INCORRECTO** porque FLATTEN funciona con cualquier tipo semi-estructurado: VARIANT, ARRAY, OBJECT.

### Preguntas Frecuentes (FAQ)
**P: ¿Puedo usar Python UDFs en materialized views?**
R: No. Las MVs solo soportan expresiones SQL (sin UDFs, sin external functions).

**P: ¿Cuál es la diferencia entre target lag DOWNSTREAM y un intervalo específico?**
R: DOWNSTREAM significa "refrescar cada vez que mi dynamic table upstream se refresque." Un intervalo específico (ej., 5 MINUTES) significa "asegurar que los datos no tengan más de 5 minutos de antigüedad."

**P: ¿Las dynamic tables pueden referenciar otras dynamic tables?**
R: Sí. Esto crea un pipeline de dynamic tables (DAG), donde los refreshes upstream se propagan downstream.


### Ejemplos de Preguntas de Escenario — Data Transformation

**Escenario:** A data platform ingests raw JSON events with deeply nested arrays (e.g., an order contains an array of items, each item contains an array of discounts). The analytics team needs a flat, relational table with one row per discount. Some orders have no discounts and must still appear in the output. How should the architect design the transformation?
**Respuesta:** Use nested LATERAL FLATTEN to expand the multi-level arrays. First FLATTEN the items array, then FLATTEN the discounts array within each item. Use `OUTER => TRUE` on the discounts FLATTEN to preserve orders/items that have empty discount arrays (they appear as NULL discount rows instead of being dropped). The query pattern: `SELECT ... FROM orders, LATERAL FLATTEN(INPUT => items, OUTER => TRUE) AS i, LATERAL FLATTEN(INPUT => i.VALUE:discounts, OUTER => TRUE) AS d`. Materialize this as a dynamic table with an appropriate target lag so the flat table stays current as new events arrive.

**Escenario:** A company has a complex transformation pipeline: raw → cleaned → enriched → aggregated. Currently this is managed with 4 stream+task pairs, and the team spends significant time debugging task failures, managing stream staleness, and handling scheduling edge cases. How should the architect simplify this?
**Respuesta:** Replace the stream+task chain with a pipeline of dynamic tables. Define each layer as a dynamic table with a SQL query referencing the previous layer: `raw_dt → cleaned_dt → enriched_dt → aggregated_dt`. Set target lag based on business SLAs — the final aggregated table might use `TARGET_LAG = '5 MINUTES'` while intermediate tables use `TARGET_LAG = DOWNSTREAM` (refresh when downstream needs data). Snowflake handles scheduling, incremental refresh, and error management declaratively. This eliminates manual stream offset management, task scheduling, and staleness risks. Note: dynamic tables work best for pure SQL transformations; if you need custom merge logic or procedural control flow, stream+task remains appropriate.

**Escenario:** The data engineering team needs a stored procedure that loops through all databases in the account, creates a governance tag on each, and grants APPLY TAG privileges to a specific role. A junior engineer asks why they can't use a UDF for this. What should the architect explain?
**Respuesta:** UDFs cannot execute DML or DDL statements — they are read-only functions usable in SELECT. This task requires DDL (`CREATE TAG`) and DCL (`GRANT`) operations, which only stored procedures can perform. Create a stored procedure using Snowflake Scripting (SQL) with a RESULTSET cursor to iterate over `SHOW DATABASES`, then execute `CREATE TAG IF NOT EXISTS` and `GRANT APPLY TAG` for each database. The procedure should run with CALLER rights so it executes under the invoking role's permissions, ensuring proper authorization checks.

---

---

## 3.6 HERRAMIENTAS DEL ECOSISTEMA

**Kafka Connector**

- Transmite datos de topics de Kafka a tablas de Snowflake
- Dos versiones: **basada en Snowpipe** (archivos a stage, luego COPY) y **Snowpipe Streaming** (inserción directa de filas, menor latencia)
- Soporta semántica de exactamente una vez
- Maneja evolución de esquema (campos nuevos en JSON)
- Administrado por Snowflake o auto-hospedado

**Spark Connector**

- Bidireccional: leer desde y escribir a Snowflake desde Spark
- Empuja consultas a Snowflake cuando es posible (predicate pushdown)
- Soporta API de DataFrame y SQL
- Configuración clave: `sfURL`, `sfUser`, `sfPassword`, `sfDatabase`, `sfSchema`, `sfWarehouse`

**Python Connector**

- Librería nativa de Python (`snowflake-connector-python`)
- Soporta `write_pandas()` para carga masiva de DataFrames
- Se integra con SQLAlchemy
- Soporte de consultas asincrónicas para consultas de larga duración
- `snowflake-snowpark-python` — API de DataFrame que se ejecuta en cómputo de Snowflake

**JDBC / ODBC**

- Conectividad estándar de base de datos para Java (JDBC) y otros lenguajes (ODBC)
- Snowflake proporciona sus propios drivers JDBC y ODBC
- Soportan todas las operaciones SQL estándar
- Usados por la mayoría de herramientas de BI (Tableau, Power BI, Looker)

**SQL API (REST)**

- Endpoint HTTP REST para ejecutar SQL
- Enviar sentencias, verificar estado, obtener resultados via llamadas REST
- Usa OAuth o tokens de par de claves para autenticación
- Ejecución asincrónica: enviar → consultar estado → obtener resultados
- Útil para arquitecturas serverless, microservicios

**Snowpark**

- Framework de desarrollo para Python, Java, Scala
- API de DataFrame que se ejecuta en el cómputo de Snowflake (sin movimiento de datos)
- Soporta UDFs, UDTFs y stored procedures
- Ideal para pipelines de ML, transformaciones complejas
- Evaluación perezosa: las operaciones construyen un plan, se ejecutan en `.collect()` o acción

### Por Qué Esto Importa
Una plataforma de datos usa el Kafka connector para ingesta en tiempo real, Snowpark para ingeniería de features de ML, y JDBC para herramientas de BI. El arquitecto debe saber qué conector aplica a cada caso de uso.

### Mejores Prácticas
- Usa Kafka connector con Snowpipe Streaming para la menor latencia
- Usa Snowpark en lugar de extraer datos a Python/Spark cuando sea posible (el cómputo se queda en Snowflake)
- Usa SQL API para integraciones ligeras y apps serverless
- Siempre usa los drivers más recientes proporcionados por Snowflake (se actualizan frecuentemente)
- Usa autenticación key-pair para todas las conexiones programáticas/de servicio

**Trampa del examen:** SI VES "el Spark connector siempre mueve todos los datos a Spark" → **INCORRECTO** porque soporta predicate pushdown, empujando filtros a Snowflake.

**Trampa del examen:** SI VES "SQL API es solo sincrónico" → **INCORRECTO** porque soporta ejecución asincrónica (enviar → consultar → obtener).

**Trampa del examen:** SI VES "Snowpark requiere extraer datos de Snowflake" → **INCORRECTO** porque Snowpark se ejecuta en el cómputo de Snowflake; los datos se quedan en Snowflake.

**Trampa del examen:** SI VES "el Kafka connector solo soporta JSON" → **INCORRECTO** porque soporta JSON, Avro y Protobuf (con schema registry).

### Preguntas Frecuentes (FAQ)
**P: ¿Cuándo debo usar el Spark connector vs Snowpark?**
R: Usa el Spark connector cuando ya tengas infraestructura Spark y necesites integrar Snowflake en pipelines existentes. Usa Snowpark cuando quieras ejecutar todo el cómputo en Snowflake sin un cluster de Spark.

**P: ¿La SQL API puede manejar conjuntos de resultados grandes?**
R: Sí, via paginación de conjuntos de resultados. Los resultados grandes se retornan en particiones que obtienes incrementalmente.

**P: ¿El Kafka connector soporta evolución de esquema?**
R: Sí. Los campos nuevos en payloads JSON se cargan en la columna VARIANT. Si usas evolución de esquema en la tabla destino, las columnas se agregan automáticamente.


### Ejemplos de Preguntas de Escenario — Ecosystem Tools

**Escenario:** A company has an existing Spark-based ML pipeline on Databricks that processes 500 GB of features daily. They're migrating analytics to Snowflake but don't want to rewrite the Spark pipeline. The Spark pipeline needs to read from and write to Snowflake tables. How should the architect integrate the two systems?
**Respuesta:** Use the Snowflake Spark connector. Configure it with the Snowflake connection parameters (`sfURL`, `sfUser`, `sfWarehouse`, etc.) and use key-pair authentication for the service account. The Spark connector supports bidirectional data movement and pushes predicates down to Snowflake when reading (minimizing data transfer). For the longer-term, evaluate migrating the ML pipeline to Snowpark — which runs the DataFrame API directly on Snowflake compute without moving data out. But for immediate integration without rewriting, the Spark connector is the correct choice.

**Escenario:** A microservices architecture on AWS Lambda needs to execute Snowflake queries. The Lambda functions are stateless, short-lived, and cannot maintain persistent database connections. What connectivity approach should the architect recommend?
**Respuesta:** Use the Snowflake SQL API (REST). Lambda functions submit SQL statements via HTTP POST, then poll for status and fetch results asynchronously. The SQL API supports OAuth or key-pair tokens for authentication — no persistent database connections needed. This fits the stateless, ephemeral nature of Lambda. For larger result sets, the API returns paginated results that Lambda can fetch incrementally. Avoid JDBC/ODBC in Lambda since connection pooling is impractical in short-lived serverless functions.

**Escenario:** A data science team currently extracts 100 GB of data from Snowflake to their local Python environment using the Python connector and pandas for feature engineering. The extraction takes 45 minutes and overwhelms local memory. How should the architect improve this workflow?
**Respuesta:** Migrate the feature engineering logic to Snowpark. Snowpark provides a pandas-like DataFrame API that executes directly on Snowflake's compute — no data extraction needed. The data stays in Snowflake, operations are lazily evaluated and pushed down to the warehouse, and results are only materialized on `.collect()` or when writing to a table. This eliminates the 45-minute extraction, local memory constraints, and data movement costs. Snowpark supports Python UDFs and stored procedures for complex ML logic that can't be expressed in SQL.

---

---

## PARES CONFUSOS — Ingeniería de Datos

| Preguntan sobre... | La respuesta es... | NO... |
|---|---|---|
| **Snowpipe** vs **COPY INTO** | **Snowpipe** = serverless, orientado a eventos, continuo (archivos disparan la carga) | **COPY INTO** = comando manual/programado por lotes, lo ejecutas explícitamente |
| **Snowpipe** vs **Snowpipe Streaming** | **Snowpipe** = basado en archivos (notificaciones en la nube → micro-batch) | **Streaming** = basado en filas (Ingest SDK, sin archivos, latencia sub-segundo) |
| **Objeto PIPE** vs **objeto CHANNEL** | **PIPE** = usado por Snowpipe regular (`CREATE PIPE`) | **CHANNEL** = usado por Snowpipe Streaming (Ingest SDK, no necesita PIPE) |
| **Stream** vs **Task** | **Stream** = rastreador CDC (registra cambios en una tabla) | **Task** = ejecutor SQL programado (cron/intervalo). Son *socios*, no sustitutos |
| **Standard stream** vs **append-only stream** | **Standard** = rastrea INSERT + UPDATE + DELETE | **Append-only** = rastrea solo INSERTs (más económico, más simple) |
| **External table** vs **Iceberg table** | **External** = archivos crudos (CSV, Parquet), solo lectura, metadatos Snowflake | **Iceberg** = formato Iceberg, managed = DML completo, unmanaged = vinculada a catálogo |
| **Detección de esquema** vs **evolución de esquema** | **Detección** (`INFER_SCHEMA`) = lee archivo para descubrir columnas *una vez* | **Evolución** = agrega automáticamente columnas nuevas a la tabla *de forma continua* |
| **UDF** vs **UDTF** | **UDF** = un valor por fila (escalar) | **UDTF** = múltiples filas por entrada (función de tabla, usa PROCESS + END_PARTITION) |
| **UDF** vs **stored procedure** | **UDF** = solo lectura, sin efectos secundarios, usable en SELECT | **Procedure** = puede hacer DML, flujo de control, efectos secundarios, se llama via CALL |
| **External function** vs **UDF** | **External function** = llama una API *fuera* de Snowflake (Lambda, Azure Func) | **UDF** = se ejecuta *dentro* del cómputo de Snowflake |
| **Dynamic table** vs **stream + task** | **Dynamic table** = declarativa (define SQL + target lag, Snowflake administra el refresh) | **Stream + task** = imperativa (tú administras CDC + programación + manejo de errores) |
| **Directory table** vs **external table** | **Directory table** = metadatos sobre *archivos* en un stage (nombre, tamaño, fecha) | **External table** = *datos dentro de* archivos consultables en almacenamiento externo |
| **User stage** vs **table stage** vs **named stage** | **User** (`@~`) = por usuario, privado, no se puede compartir | **Table** (`@%t`) = por tabla, opciones limitadas | **Named** (`@s`) = explícito, el más flexible |
| **Target lag DOWNSTREAM** vs **intervalo explícito** | **DOWNSTREAM** = refrescar cuando la DT upstream se refresque | **Explícito** (ej., 5 MIN) = datos no más antiguos de N minutos |
| **VALIDATION_MODE** vs **ON_ERROR** | **VALIDATION_MODE** = ejecución de prueba, no se cargan datos | **ON_ERROR** = controla comportamiento *durante* la carga real (CONTINUE, ABORT, SKIP_FILE) |

---

## ÁRBOLES DE DECISIÓN POR ESCENARIO — Ingeniería de Datos

**Escenario 1: "500 archivos CSV llegan diariamente a S3 desde sistemas POS de tiendas..."**
- **CORRECTO:** **Snowpipe** con auto-ingesta (notificación de eventos S3 dispara la carga)
- TRAMPA: *"COPY INTO programado cada hora"* — **INCORRECTO**, pierde archivos entre ejecuciones, mayor latencia, más costo de warehouse

**Escenario 2: "Sensores IoT envían 10K eventos/segundo, necesitan latencia sub-segundo..."**
- **CORRECTO:** **Snowpipe Streaming** (Ingest SDK, nivel de fila, sin archivos)
- TRAMPA: *"Snowpipe regular"* — **INCORRECTO**, Snowpipe es basado en archivos con latencia de segundos a minutos; Streaming es sub-segundo

**Escenario 3: "La fuente agrega columnas nuevas frecuentemente, la tabla debe adaptarse automáticamente..."**
- **CORRECTO:** **Evolución de esquema** (`ENABLE_SCHEMA_EVOLUTION = TRUE`) + `MATCH_BY_COLUMN_NAME`
- TRAMPA: *"INFER_SCHEMA antes de cada carga"* — **INCORRECTO**, INFER_SCHEMA es detección de una vez, no evolución continua

**Escenario 4: "Necesito hacer merge de cambios incrementales de raw a curated cada 5 minutos..."**
- **CORRECTO:** **Stream en tabla raw** + **Task** con `SYSTEM$STREAM_HAS_DATA` + sentencia MERGE
- TRAMPA: *"Dynamic table"* — posible pero las dynamic tables no soportan lógica de MERGE con resolución de conflictos personalizada; stream+task da control total

**Escenario 5: "Construir un pipeline de transformación: raw → limpio → agregado, puro SQL..."**
- **CORRECTO:** **Dynamic tables** encadenadas (raw DT → cleaned DT → agg DT con target lag)
- TRAMPA: *"Tres pares de stream+task"* — **INCORRECTO**, innecesariamente complejo; las dynamic tables manejan esto declarativamente

**Escenario 6: "Llamar una API de scoring ML externa desde una consulta SQL..."**
- **CORRECTO:** **External function** (API integration + definición de función)
- TRAMPA: *"Python UDF"* — **INCORRECTO**, Python UDF se ejecuta dentro de Snowflake; no puede llamar APIs externas sin una external access integration

**Escenario 7: "Necesito aplanar arrays JSON anidados en filas para analítica..."**
- **CORRECTO:** **LATERAL FLATTEN** con `INPUT => columna`, opcionalmente `OUTER => TRUE` para arrays vacíos
- TRAMPA: *"PARSE_JSON + extracción manual"* — **INCORRECTO**, FLATTEN está diseñado para esto y maneja arrays anidados nativamente

**Escenario 8: "Tarea administrativa: recorrer bases de datos, crear tags, ejecutar grants..."**
- **CORRECTO:** **Stored procedure** (Snowflake Scripting con IF/LOOP/BEGIN-END)
- TRAMPA: *"UDF"* — **INCORRECTO**, las UDFs no pueden ejecutar DML (CREATE, GRANT, ALTER)

**Escenario 9: "Necesito rastrear qué archivos existen en un stage y cuándo llegaron..."**
- **CORRECTO:** **Directory table** en el stage (`ENABLE = TRUE`, auto-refresh para externo)
- TRAMPA: *"External table"* — **INCORRECTO**, las external tables consultan *contenidos* de archivos, no *metadatos* de archivos

**Escenario 10: "Topics de Kafka necesitan llegar a Snowflake con la menor latencia posible..."**
- **CORRECTO:** **Kafka connector con modo Snowpipe Streaming** (inserción directa de filas)
- TRAMPA: *"Kafka connector con modo Snowpipe"* — no es incorrecto, pero mayor latencia (basado en archivos); el modo Streaming es de menor latencia

**Escenario 11: "Validación de datos antes de cargar — verificar filas malas sin cargar realmente..."**
- **CORRECTO:** `COPY INTO ... VALIDATION_MODE = 'RETURN_ERRORS'` (ejecución de prueba)
- TRAMPA: *"Cargar con ON_ERROR = CONTINUE luego verificar errores"* — **INCORRECTO**, esto realmente carga datos; VALIDATION_MODE no carga nada

**Escenario 12: "Ingeniería de features ML en Python sobre datos ya en Snowflake..."**
- **CORRECTO:** **Snowpark** (API de DataFrame se ejecuta en cómputo de Snowflake, sin movimiento de datos)
- TRAMPA: *"Python connector + pandas"* — **INCORRECTO**, esto saca datos de Snowflake a la máquina local; Snowpark mantiene el cómputo en Snowflake

---

## FLASHCARDS -- Dominio 3

**P1:** ¿Cuál es la ventana de deduplicación de Snowpipe?
**R1:** 14 días. Los archivos cargados en los últimos 14 días se rastrean y no se reingerirán.

**P2:** ¿Qué objeto usa Snowpipe Streaming en lugar de un PIPE?
**R2:** Objetos CHANNEL (via el Ingest SDK).

**P3:** ¿La evolución de esquema puede eliminar columnas de una tabla?
**R3:** No. Solo agrega columnas nuevas.

**P4:** ¿Cuáles son los tres tipos de stream?
**R4:** Standard (todo DML), Append-only (solo inserts), Insert-only (external tables, archivos nuevos).

**P5:** ¿En qué estado se crean las tasks?
**R5:** SUSPENDED. Deben reanudarse explícitamente.

**P6:** ¿Las UDFs pueden ejecutar DML?
**R6:** No. Solo los stored procedures pueden ejecutar DML (INSERT, UPDATE, DELETE).

**P7:** ¿Cuál es la diferencia clave entre una external function y una UDF?
**R7:** Las external functions llaman un endpoint de API fuera de Snowflake; las UDFs se ejecutan dentro del cómputo de Snowflake.

**P8:** ¿Qué hace FLATTEN?
**R8:** Convierte datos semi-estructurados (VARIANT, ARRAY, OBJECT) en filas relacionales.

**P9:** ¿Cuál es el propósito de una storage integration?
**R9:** Proporciona acceso seguro y sin credenciales al almacenamiento externo en la nube usando IAM roles o service principals.

**P10:** ¿Cómo difiere Snowpark del Python connector?
**R10:** Snowpark ejecuta una API de DataFrame en el cómputo de Snowflake (sin movimiento de datos). El Python connector ejecuta consultas desde un cliente Python.

**P11:** ¿Puedes crear un stream sobre una dynamic table?
**R11:** No. Los streams no pueden crearse sobre dynamic tables.

**P12:** ¿Qué hace `VALIDATION_MODE` en COPY INTO?
**R12:** Realiza una ejecución de prueba — valida datos sin cargarlos realmente.

**P13:** ¿Qué es una directory table?
**R13:** Una capa de metadatos en un stage que permite consultar atributos de archivos (nombre, tamaño, last_modified) via SQL.

**P14:** ¿Qué dispara las tasks hijas en un árbol de tasks?
**R14:** La finalización exitosa de la task padre. Solo la task raíz tiene programación.

**P15:** ¿Qué es target lag DOWNSTREAM en una dynamic table?
**R15:** La dynamic table se refresca cada vez que su dynamic table upstream se refresca, propagándose a través del pipeline.

---

## EXPLICAR COMO SI TUVIERA 5 AÑOS -- Dominio 3

**1. COPY INTO**
Imagina que tienes una caja grande de piezas de rompecabezas (archivos). COPY INTO vuelca todas esas piezas en tu tablero de rompecabezas (tabla) de una vez. Lo haces cuando tienes toda una caja lista.

**2. Snowpipe**
Ahora imagina que alguien desliza piezas de rompecabezas por debajo de tu puerta una por una mientras las encuentra. Eso es Snowpipe — las piezas llegan y se colocan automáticamente sin que hagas nada.

**3. Snowpipe Streaming**
Aún más rápido: alguien está LANZANDO piezas de rompecabezas por tu ventana tan rápido como las recoge. Sin esperar a juntar una pila. Cada pieza llega instantáneamente.

**4. Streams (CDC)**
Un cuaderno mágico que anota cada vez que alguien agrega, cambia o quita un juguete de la caja de juguetes. Cuando lees el cuaderno, se borra solo y empieza de nuevo.

**5. Tasks**
Un reloj despertador que suena cada N minutos y dice "¡Hora de hacer tus tareas!" Tu tarea es una sentencia SQL. Puedes configurar una cadena: "Después de lavar los platos, barre el piso."

**6. FLATTEN**
Tienes una bolsa de bolsas de dulces. FLATTEN abre todas las bolsas internas y vierte todo en una gran pila para que puedas contar cada dulce individualmente.

**7. Dynamic Tables**
Una pizarra mágica que se actualiza automáticamente. Escribiste las reglas una vez ("muéstrame ventas totales por tienda"), y cada pocos minutos la pizarra se borra y se redibuja con los números más recientes.

**8. External Tables**
Mirar a través de una ventana al jardín de tu vecino. Puedes VER las flores (leer los datos) pero no puedes tocarlas ni reorganizarlas (sin escrituras). Las flores se quedan en su jardín.

**9. Stages**
Tu casillero en la escuela. Pones tu mochila (archivos) en tu casillero (stage) antes de sacar las cosas en clase (cargar en tablas). Algunos casilleros son tuyos (internos), otros son armarios de almacenamiento compartido (externos).

**10. Kafka Connector**
Una banda transportadora de una fábrica (Kafka) a tu almacén (Snowflake). Los artículos siguen llegando automáticamente. Si la banda usa la versión Streaming, los artículos llegan aún más rápido sin necesitar empaque primero.

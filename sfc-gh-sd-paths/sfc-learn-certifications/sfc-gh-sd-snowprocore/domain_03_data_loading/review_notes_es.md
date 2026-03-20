# DOMINIO 3: CARGA, DESCARGA Y CONECTIVIDAD DE DATOS
## 18% del examen = ~18 preguntas

---

## 3.1 STAGES (MUY IMPORTANTE EN EL EXAMEN)

Un stage = una ubicación donde los archivos de datos se almacenan antes/después de la carga.

### Tres tipos de stages INTERNOS:

| Stage | Símbolo | Alcance | Quién lo usa |
|---|---|---|---|
| Stage de usuario | @~ | Un usuario, muchas tablas | Almacenamiento personal de archivos |
| Stage de tabla | @%nombre_tabla | Muchos usuarios, UNA tabla | Vinculado a una tabla específica |
| Stage nombrado | @nombre_stage | Muchos usuarios, muchas tablas | Más flexible, recomendado |

### Reglas clave:
- **Stage de usuario** (@~): se crea automáticamente por usuario. No se puede alterar ni eliminar. No se puede configurar formato de archivo.
- **Stage de tabla** (@%tabla): se crea automáticamente por tabla. No se puede alterar ni eliminar. Sin privilegios otorgables. Debe ser propietario de la tabla.
- **Stage nombrado** (CREATE STAGE): objeto de base de datos. Se puede configurar formato de archivo, encriptación. Se pueden otorgar privilegios. Mayor control.

### Stages externos:
- Apuntan a almacenamiento en la nube: S3, Azure Blob, GCS
- Se crean con CREATE STAGE ... URL = 's3://bucket/ruta'
- Necesitan integración de almacenamiento O credenciales
- Se pueden usar independientemente de qué nube aloja tu cuenta de Snowflake

### Por qué esto importa + Casos de uso

**Escenario real — "Necesitamos datos disponibles en menos de 1 minuto desde que llegan a S3"**
COPY INTO se ejecuta en un horario (cada 15 min). No es suficientemente rápido. Solución: Snowpipe con auto-ingest. La notificación de evento de S3 activa Snowpipe, datos disponibles en ~1 minuto. Serverless, no necesita warehouse.

**Escenario real — "El comando PUT falla con 'external stage not supported'"**
PUT solo funciona con stages INTERNOS. Para stages externos (S3, Azure, GCS), sube archivos directamente a tu almacenamiento en la nube usando AWS CLI, Azure CLI, etc. Luego usa COPY INTO desde el stage externo.

**Escenario real — "La mitad de nuestras filas CSV tienen datos malos y la carga falla"**
Usa ON_ERROR = CONTINUE para cargar filas buenas y saltar las malas. O usa VALIDATION_MODE = RETURN_ERRORS primero para previsualizar qué fallaría sin cargar nada.

---

### Mejores Prácticas — Stages
- Stages nombrados sobre stages de tabla/usuario para producción (más control)
- Stages externos para almacenamiento en la nube que ya gestionas
- Siempre especificar FILE_FORMAT al crear un stage

### Subida/descarga de archivos:
- **PUT** → subir archivos DESDE máquina local HACIA stage interno
- **GET** → descargar archivos DESDE stage interno HACIA máquina local
- PUT/GET solo funcionan con SnowSQL o conectores de Snowflake (NO Snowsight)
- PUT comprime automáticamente los archivos (gzip por defecto)

**Trampa del examen**: "¿Subir archivo del laptop al stage?" → Comando PUT vía SnowSQL. SI VES "COPY INTO" para local-a-stage → INCORRECTO porque COPY INTO carga de stage-a-tabla, no de local-a-stage.
**Trampa del examen**: "¿Descargar archivo del stage al laptop?" → Comando GET. SI VES "COPY INTO" para stage-a-local → INCORRECTO porque COPY INTO descarga a un stage, no a tu máquina local.
**Trampa del examen**: "¿Qué tipo de stage NO se puede alterar?" → Stages de usuario y tabla. SI VES "ALTER STAGE @~" o "ALTER STAGE @%tabla" → INCORRECTO porque stages de usuario/tabla no se pueden alterar ni eliminar.
**Trampa del examen**: "¿NO es un tipo de stage válido?" → Stage de Warehouse (no existe). SI VES "warehouse stage" → trampa. Solo existen stages de Usuario (@~), Tabla (@%t) y Nombrado (@s).


### Ejemplos de Preguntas de Escenario — Stages

**Escenario:** A data engineer at a retail company needs to load daily sales CSV files from their laptop into a Snowflake table. They try running `COPY INTO sales_table FROM file:///tmp/sales.csv` but it fails. What is the correct approach?
**Respuesta:** Files must first be uploaded to an internal stage using the PUT command via SnowSQL (e.g., `PUT file:///tmp/sales.csv @~`), and then loaded with `COPY INTO sales_table FROM @~`. COPY INTO loads from a stage to a table — it cannot read directly from a local filesystem. PUT is the only way to move files from local to an internal stage, and it only works through SnowSQL or Snowflake connectors (not Snowsight).

**Escenario:** A team has 15 analysts who each need to upload their own data files to Snowflake, but the data all ends up in the same shared table. The DBA wants to control file format and grant access to other roles. Which stage type should they use?
**Respuesta:** A named internal stage (CREATE STAGE) is the best choice. Named stages are database objects that support setting file format options, encryption, and grantable privileges — so the DBA can control access via RBAC. User stages (@~) are per-user and cannot have file formats set. Table stages (@%table) cannot be granted to other roles and cannot be altered. Named stages provide the most flexibility for shared, production workloads.

**Escenario:** A company hosts their Snowflake account on Azure but stores raw data files in an AWS S3 bucket. Can they create a stage in Snowflake that points to S3?
**Respuesta:** Yes. External stages can point to any supported cloud provider (S3, Azure Blob, GCS) regardless of which cloud hosts the Snowflake account. They would create an external stage with `CREATE STAGE ... URL = 's3://bucket/path'` and use either a storage integration or direct credentials. Cross-cloud stages are fully supported.

---

---

## 3.2 FORMATOS DE ARCHIVO

### Formatos soportados para CARGA:
- CSV (por defecto)
- JSON
- Avro
- ORC
- Parquet
- XML

### NO soportados: HTML, PDF, Excel

### Objetos de Formato de Archivo:
- CREATE FILE FORMAT → definición de formato reutilizable
- Se puede configurar: delimitador, compresión, formato de fecha, saltar encabezados, etc.
- Se puede adjuntar a un stage o usar inline en COPY INTO

### Compresión:
- Por defecto para descarga: gzip
- Soportados: gzip, bz2, Brotli, Zstandard, deflate, raw_deflate, none
- Snowflake auto-detecta compresión en la carga

**Trampa del examen**: "¿Snowflake puede cargar archivos Excel?" → NO. SI VES "Excel" + "cargar" o "COPY INTO" → INCORRECTO porque solo CSV, JSON, Avro, ORC, Parquet, XML son soportados.
**Trampa del examen**: "¿Formato de archivo por defecto para COPY INTO?" → CSV. SI VES "JSON" o "Parquet" como defecto → INCORRECTO porque CSV es siempre el formato por defecto.
**Trampa del examen**: "¿Necesitas especificar compresión al cargar?" → NO. SI VES "debe especificar compresión" → INCORRECTO porque Snowflake auto-detecta la compresión en la carga.


### Ejemplos de Preguntas de Escenario — File Formats

**Escenario:** A partner sends your team a batch of Excel (.xlsx) files containing inventory data. The data engineer tries to load them directly with COPY INTO but gets an error. What should they do?
**Respuesta:** Snowflake does not support loading Excel files. The supported file formats are CSV, JSON, Avro, ORC, Parquet, and XML only. The partner must first convert the Excel files to a supported format (typically CSV) before uploading to a stage and loading with COPY INTO. Tools like Python (pandas) or Excel's "Save As CSV" can handle the conversion.

**Escenario:** A data pipeline sends gzip-compressed JSON files to an S3 bucket. The engineer creating the COPY INTO statement is unsure whether to specify `COMPRESSION = GZIP` in the file format. Is it required?
**Respuesta:** No. Snowflake auto-detects compression during loading, so specifying `COMPRESSION = GZIP` is optional. Snowflake will recognize the gzip format automatically and decompress the files. You only need to explicitly set compression if you want to override the auto-detection behavior (e.g., `COMPRESSION = NONE` to skip decompression).

**Escenario:** A team frequently loads CSV files with the same format settings (pipe-delimited, UTF-8, skip 2 header rows) across many different COPY INTO statements. What is the recommended approach to avoid repeating format options every time?
**Respuesta:** Create a reusable file format object with `CREATE FILE FORMAT my_csv_format TYPE = CSV FIELD_DELIMITER = '|' SKIP_HEADER = 2 ENCODING = 'UTF8'`. This format can then be referenced in stage definitions or directly in COPY INTO statements with `FILE_FORMAT = my_csv_format`. File format objects are database objects that can be shared across teams via grants and ensure consistency across all load operations.

---

---

## 3.3 COPY INTO (MUY PROBADO)

### Carga: COPY INTO tabla FROM stage
### Descarga: COPY INTO stage FROM tabla/consulta

### Comportamiento de carga:
- Por defecto: si HAY CUALQUIER error → toda la carga falla y se revierte
- Rastrea qué archivos ya se cargaron (previene duplicados dentro de 64 días)
- Solo carga archivos que no se han cargado antes (a menos que FORCE = TRUE)

### Parámetros clave:

**ON_ERROR** (qué hacer cuando ocurre error):
- `ABORT_STATEMENT` (por defecto) → falla toda la carga
- `CONTINUE` → salta filas malas, carga el resto
- `SKIP_FILE` → salta archivos con errores
- `SKIP_FILE_n` → salta archivo si n+ errores
- `SKIP_FILE_n%` → salta archivo si n% errores

**VALIDATION_MODE** (verificar sin cargar):
- `RETURN_ERRORS` → muestra todos los errores
- `RETURN_n_ROWS` → parsea las primeras n filas
- NO carga datos realmente

**PURGE = TRUE**: eliminar archivos fuente después de carga exitosa

**FORCE = TRUE**: recargar archivos aunque ya se hayan cargado

**MATCH_BY_COLUMN_NAME**: coincidir columnas fuente con columnas de tabla por nombre (no posición)

**ERROR_ON_COLUMN_COUNT_MISMATCH**:
- TRUE (por defecto) → error si el conteo de columnas difiere
- FALSE → permitir diferencia (columnas extra ignoradas, faltantes = NULL)

### Transformaciones durante la carga:
- Reordenamiento de columnas
- Omisión de columnas (saltar columnas)
- Conversión de tipos
- Truncamiento de texto
- Usar SELECT en COPY INTO: `COPY INTO tabla FROM (SELECT $1, $2::date FROM @stage)`

### Columnas METADATA disponibles durante la carga:
- METADATA$FILENAME → nombre del archivo fuente
- METADATA$FILE_ROW_NUMBER → número de fila en el archivo fuente
- METADATA$FILE_CONTENT_KEY → hash del contenido
- METADATA$FILE_LAST_MODIFIED → timestamp del archivo
- METADATA$START_SCAN_TIME → hora de inicio del escaneo

### Mejores Prácticas — Carga de Datos
- Usar Snowpipe para carga continua/tiempo real, COPY INTO para lotes
- Tamaño ideal de archivo: 100-250 MB comprimido para paralelismo óptimo
- Usar PURGE = TRUE para auto-eliminar archivos staged después de carga exitosa
- VALIDATION_MODE antes de la primera carga para detectar problemas de formato
- Warehouses separados para carga vs consultas
- Usar objetos de formato de archivo (reutilizables) en vez de opciones de formato inline

**Trampa del examen**: "¿Incluir nombre de archivo en tabla durante carga?" → METADATA$FILENAME en SELECT. SI VES "después de cargar" + "obtener nombre de archivo" → INCORRECTO porque las columnas METADATA$ solo están disponibles DURANTE el COPY INTO, no después.
**Trampa del examen**: "¿Verificar errores sin cargar?" → VALIDATION_MODE. SI VES "ON_ERROR" para verificación pre-carga → INCORRECTO porque ON_ERROR controla comportamiento DURANTE la carga; VALIDATION_MODE verifica SIN cargar.
**Trampa del examen**: "¿Eliminar archivos fuente después de carga?" → PURGE = TRUE. SI VES "REMOVE" o "DROP" para limpieza post-carga → INCORRECTO porque PURGE = TRUE es el parámetro de COPY INTO que elimina archivos fuente.
**Trampa del examen**: "¿Compresión por defecto en descarga?" → gzip. SI VES "none" o "sin comprimir" como defecto → INCORRECTO porque gzip es siempre el defecto para descarga.


### Ejemplos de Preguntas de Escenario — COPY INTO

**Escenario:** A healthcare company loads patient records nightly from CSV files in S3. One night, a file contains 50,000 rows but 200 rows have malformed date fields. The team wants to load the valid rows and investigate the bad ones later. What parameters should they use?
**Respuesta:** Use `ON_ERROR = CONTINUE` to skip the bad rows and load the remaining valid rows. After the load completes, use the `VALIDATE(table_name, job_id => '_last')` function to retrieve details about which rows failed and why. The default `ON_ERROR = ABORT_STATEMENT` would reject the entire file, losing all 49,800 good rows.

**Escenario:** A data engineer is loading files from an external stage but notices the same files keep getting loaded every time the COPY INTO runs, creating duplicates. What is happening and how can they fix it?
**Respuesta:** COPY INTO tracks loaded files for 64 days to prevent re-loading. If duplicates are occurring, possible causes include: (1) FORCE = TRUE is set, which overrides duplicate detection; (2) the files were modified after the initial load (different content hash); or (3) more than 64 days passed since the last load. Remove FORCE = TRUE if set, and ensure files are not being modified after initial load. The 64-day load metadata window is automatic and cannot be extended.

**Escenario:** Before loading a large batch of 10 million rows from Parquet files for the first time, the team wants to verify the data will parse correctly without actually inserting anything into the target table. How should they proceed?
**Respuesta:** Use `VALIDATION_MODE = RETURN_ERRORS` in the COPY INTO statement. This parses all files and returns any errors found without loading a single row. Alternatively, `VALIDATION_MODE = RETURN_n_ROWS` (e.g., RETURN_10_ROWS) parses just the first n rows as a quick sanity check. This is distinct from ON_ERROR, which controls behavior during an actual load — VALIDATION_MODE prevents any data from being loaded at all.

**Escenario:** A logistics company loads shipment data from CSV files but the CSV columns are ordered differently than the target Snowflake table. The CSV has columns: shipment_date, tracking_id, weight — but the table expects: tracking_id, shipment_date, weight. How can they handle this without changing the source files?
**Respuesta:** Use a SELECT transformation in the COPY INTO statement to reorder columns: `COPY INTO shipments FROM (SELECT $2, $1, $3 FROM @my_stage) FILE_FORMAT = (TYPE = CSV)`. The $N references correspond to the positional columns in the source file. Alternatively, if the CSV has headers, use `MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE` to match source columns to target columns by name instead of position.

---

---

## 3.4 FUNCIÓN VALIDATE

- VALIDATE(tabla, job_id) → revisar errores de un COPY INTO anterior
- Muestra qué filas fallaron y por qué
- Usar después de una carga con ON_ERROR = CONTINUE

**Trampa del examen**: "¿VALIDATE vs VALIDATION_MODE?" → VALIDATE = después de carga. VALIDATION_MODE = antes de carga. SI VES "VALIDATE" para verificación pre-carga → INCORRECTO porque VALIDATE revisa errores PASADOS; VALIDATION_MODE verifica SIN cargar.
**Trampa del examen**: "¿VALIDATE(tabla, job_id) requiere qué ON_ERROR?" → CONTINUE. SI VES "ABORT_STATEMENT" con VALIDATE → INCORRECTO porque cargas abortadas no tienen filas saltadas para revisar; CONTINUE salta filas malas para que VALIDATE pueda encontrarlas.


### Ejemplos de Preguntas de Escenario — Validate Function

**Escenario:** A data engineer loaded 500 CSV files into a transactions table using `ON_ERROR = CONTINUE`. The load completed but they know some rows were skipped. How can they find out exactly which rows failed and why?
**Respuesta:** Use `SELECT * FROM TABLE(VALIDATE(transactions, job_id => '_last'))` to retrieve all rejected rows from the most recent COPY INTO job. The VALIDATE function returns the row data, the error message, and the file/line information for each rejected row. The `_last` shortcut references the most recent load job, or a specific job_id can be provided. This only works when ON_ERROR = CONTINUE was used because ABORT_STATEMENT stops the load entirely, leaving no skipped rows to review.

**Escenario:** A junior engineer runs `VALIDATE(orders, job_id => '_last')` but gets no results, even though they know there were errors in the source files. Their COPY INTO used the default ON_ERROR setting. What went wrong?
**Respuesta:** The default ON_ERROR setting is ABORT_STATEMENT, which causes the entire load to fail and roll back on the first error — no rows are loaded and no rows are "skipped." VALIDATE only returns rows that were skipped during a successful load with ON_ERROR = CONTINUE (or SKIP_FILE). Since the load was aborted, there are no skipped rows to review. The engineer should re-run the load with ON_ERROR = CONTINUE, or use VALIDATION_MODE = RETURN_ERRORS to preview errors without loading.

---

---

## 3.5 SNOWPIPE (MUY PROBADO)

### Qué es:
- Carga de datos continua y automatizada
- Serverless (Snowflake gestiona el compute)
- Carga archivos tan pronto como llegan al stage
- Casi tiempo real (en minutos)

### Cómo funciona:
1. Los archivos llegan al stage (S3, Azure, GCS, o interno)
2. La notificación activa Snowpipe (notificación de evento de nube O llamada API REST)
3. Snowpipe carga los datos usando un COPY INTO definido en el pipe
4. Los archivos se rastrean para prevenir recarga

### Facturación:
- Cargo de compute por segundo (serverless)
- Basado en número de archivos y compute usado
- NO se factura por créditos de warehouse (no necesita warehouse)

### Tamaño de archivo recomendado: 100-250 MB comprimido
- Archivos más pequeños = más overhead por archivo
- Archivos más grandes = más lento para comenzar la carga

### Objetos/funciones clave:
- CREATE PIPE ... AS COPY INTO tabla FROM @stage
- SYSTEM$PIPE_STATUS(nombre_pipe) → verificar salud del pipe
- COPY_HISTORY (INFORMATION_SCHEMA / ACCOUNT_USAGE) → historial de carga
- VALIDATE_PIPE_LOAD() → revisar errores de los últimos 14 días

### Snowpipe puede cargar desde:
- Stages externos (S3, Azure, GCS)
- Stages internos (sí, Snowpipe funciona con stages internos también)

### Auto-ingest:
- AUTO_INGEST = TRUE en la definición del pipe
- Requiere notificación de evento de nube (S3 SQS, Azure Event Grid, GCP Pub/Sub)

**Trampa del examen**: "¿Modelo de compute de Snowpipe?" → Serverless (gestionado por Snowflake). SI VES "warehouse" con Snowpipe → trampa. Snowpipe es SERVERLESS — no necesita warehouse.
**Trampa del examen**: "¿Tamaño de archivo recomendado para Snowpipe?" → 100-250 MB comprimido. SI VES "1 GB" o "10 MB" como recomendado → INCORRECTO porque 100-250 MB comprimido es el punto óptimo.
**Trampa del examen**: "¿Snowpipe puede cargar desde stage interno?" → SÍ. SI VES "solo externo" para Snowpipe → INCORRECTO porque Snowpipe funciona con AMBOS stages internos y externos.
**Trampa del examen**: "¿Verificación de salud del pipe?" → SYSTEM$PIPE_STATUS. SI VES "PIPE_USAGE_HISTORY" para verificación de salud → INCORRECTO porque SYSTEM$PIPE_STATUS verifica salud del pipe; PIPE_USAGE_HISTORY muestra facturación/historial.
**Trampa del examen**: "¿Estado STALLED_COMPILATION?" → El SQL en el pipe es inválido o hay desajuste de esquema. SI VES "problema de red" o "error de permisos" para STALLED_COMPILATION → INCORRECTO porque significa que el SQL del COPY INTO dentro del pipe no compila.


### Ejemplos de Preguntas de Escenario — Snowpipe

**Escenario:** An e-commerce company receives order files in an S3 bucket throughout the day and needs them loaded into Snowflake within minutes of arrival. They currently run a scheduled COPY INTO every hour from a warehouse. How should they redesign this for near-real-time loading?
**Respuesta:** Replace the scheduled COPY INTO with Snowpipe. Create a pipe with `CREATE PIPE ... AUTO_INGEST = TRUE AS COPY INTO orders FROM @s3_stage`. Configure an S3 event notification (SQS queue) on the bucket to trigger Snowpipe whenever a new file lands. Snowpipe is serverless (no warehouse needed), loads files within minutes of arrival, and bills per-second based on actual compute used — far more efficient than keeping a warehouse running hourly.

**Escenario:** A team sets up Snowpipe and notices their loading costs are higher than expected. They are sending thousands of 1 KB files per minute. What is the likely issue?
**Respuesta:** The files are far too small. Snowflake recommends 100-250 MB compressed files for Snowpipe. Each file incurs overhead for scheduling and processing, so thousands of tiny files create excessive per-file overhead. The team should batch or aggregate their source files before landing them in the stage — for example, buffer records and write larger files at intervals. This reduces the number of files Snowpipe processes and significantly lowers costs.

**Escenario:** A data engineer creates a Snowpipe and checks `SYSTEM$PIPE_STATUS('my_pipe')` which returns a status of STALLED_COMPILATION. Files are landing in the stage but nothing is being loaded. What should they investigate?
**Respuesta:** STALLED_COMPILATION means the SQL defined inside the pipe (the COPY INTO statement) is invalid or references objects that no longer match. Common causes: the target table was dropped or renamed, a column was removed from the table, the stage was altered, or the file format changed. The engineer should check that the COPY INTO statement in the pipe definition still compiles correctly by verifying the target table schema, stage, and file format all match the pipe's SQL.

---

---

## 3.6 SNOWPIPE STREAMING (NUEVO para COF-C03)

### Qué es:
- Carga datos a NIVEL DE FILA directamente a Snowflake (sin archivos necesarios)
- Usa SDK de Snowflake o API REST
- Opción de menor latencia (sub-segundo)
- No requiere archivos en stage

### Diferencia con Snowpipe regular:
| | Snowpipe | Snowpipe Streaming |
|---|---|---|
| Entrada | Archivos en stage | Filas vía SDK/API |
| Latencia | Minutos | Segundos |
| Staging | Requerido | No requerido |
| Disparador | Notificación de archivo | Llamada API |

### Conector Kafka:
- Conector de Snowflake para Kafka
- Se ejecuta en el entorno Kafka del CLIENTE (Confluent o auto-hospedado)
- Puede usar Snowpipe Streaming para menor latencia
- Lee de tópicos Kafka → escribe en tablas de Snowflake

**Trampa del examen**: "¿Snowpipe Streaming necesita archivos en un stage?" → INCORRECTO. SI VES "stage" + "Snowpipe Streaming" → trampa. Las filas se envían directamente vía SDK/API, NO requiere staging.
**Trampa del examen**: "¿Latencia de Snowpipe Streaming?" → Sub-segundo (segundos). SI VES "minutos" para latencia de Streaming → INCORRECTO porque "minutos" es Snowpipe regular; Streaming = SEGUNDOS.
**Trampa del examen**: "¿El conector Kafka se ejecuta dentro de Snowflake?" → INCORRECTO. SI VES "gestionado por Snowflake" + "conector Kafka" → trampa. Se ejecuta en el entorno Kafka del CLIENTE.


### Ejemplos de Preguntas de Escenario — Snowpipe Streaming

**Escenario:** A manufacturing company has IoT sensors on their assembly line that emit temperature readings every 100 milliseconds. They need this data in Snowflake with sub-second latency for real-time quality monitoring dashboards. Regular Snowpipe takes minutes. What should they use?
**Respuesta:** Snowpipe Streaming is the correct choice. It accepts row-level data directly via the Snowflake Ingest SDK (Java) or REST API — no files or staging required. Data arrives in Snowflake within seconds (sub-second latency), compared to minutes with regular Snowpipe. The application would use the SDK to stream individual sensor readings directly into a Snowflake table without writing intermediate files.

**Escenario:** A company uses Apache Kafka for their event streaming platform and wants to sink Kafka topic data into Snowflake. They want the lowest possible latency. Where does the Kafka connector run, and which ingestion mode should they configure?
**Respuesta:** The Snowflake Connector for Kafka runs in the customer's own Kafka environment (e.g., Confluent Cloud, self-hosted Kafka cluster) — not inside Snowflake. To achieve the lowest latency, configure the connector to use Snowpipe Streaming mode instead of the default Snowpipe (file-based) mode. With Snowpipe Streaming, rows from Kafka topics are sent directly to Snowflake tables without staging files, achieving seconds-level latency instead of minutes.

**Escenario:** A developer is evaluating whether to use Snowpipe or Snowpipe Streaming for their data pipeline. Their source system generates one 200 MB CSV file every 5 minutes and drops it in S3. Which option is more appropriate?
**Respuesta:** Regular Snowpipe with auto-ingest is the better fit. Snowpipe Streaming is designed for row-level, API-based ingestion where there are no files — it excels when applications emit individual records. Since this pipeline already produces well-sized files (200 MB is within the recommended 100-250 MB range) landing in S3, Snowpipe with S3 event notifications is the natural choice. Snowpipe Streaming would require rewriting the source system to send rows via the SDK instead of writing files.

---

---

## 3.7 STREAMS (Captura de Datos de Cambio)

### Qué son:
- Rastrean cambios (INSERT, UPDATE, DELETE) en una tabla
- "Change Data Capture" (CDC)
- Cuando consultas un stream, ves qué cambió desde el último consumo

### Columnas clave en la salida del stream:
- METADATA$ACTION → INSERT o DELETE
- METADATA$ISUPDATE → TRUE si es una actualización (se muestra como DELETE + INSERT)
- METADATA$ROW_ID → identificador único de fila

### Tipos de stream:
- **Standard**: rastrea todo DML (INSERT, UPDATE, DELETE)
- **Append-only**: rastrea solo INSERTs
- **Insert-only**: para tablas externas (solo filas nuevas)

### Streams + Tasks = pipeline:
- El stream detecta cambios
- La task verifica el stream (SYSTEM$STREAM_HAS_DATA)
- Si el stream tiene datos → la task se ejecuta y procesa los cambios
- Después del consumo, el stream avanza (los cambios se "consumen")

**Trampa del examen**: "¿La task se ejecuta solo cuando el stream tiene datos?" → WHEN SYSTEM$STREAM_HAS_DATA('nombre_stream') es una condición ADICIONAL, pero la task aún necesita un schedule CRON o intervalo para definir CUÁNDO verificar. Ambos trabajan juntos: el schedule define con qué frecuencia verificar, y el WHEN impide que la task se ejecute si no hay datos nuevos. SI VES "CRON no es necesario para tasks basadas en stream" → INCORRECTO porque la task aún requiere un schedule; el WHEN es una protección extra.
**Trampa del examen**: "¿Stream en tabla externa?" → Stream insert-only. SI VES "standard" o "append-only" para tablas externas → INCORRECTO porque las tablas externas solo soportan streams INSERT-ONLY.


### Ejemplos de Preguntas de Escenario — Streams

**Escenario:** A finance team needs to build an audit trail that captures every change to the `accounts` table — inserts, updates, and deletes — so they can replicate changes to a downstream reporting table. Which stream type should they use, and how do updates appear in the stream?
**Respuesta:** Use a Standard stream, which tracks all DML operations (INSERT, UPDATE, DELETE). Updates appear as two rows in the stream: one DELETE row (the old values) and one INSERT row (the new values), both with `METADATA$ISUPDATE = TRUE`. The `METADATA$ACTION` column shows INSERT or DELETE, while `METADATA$ISUPDATE` distinguishes true inserts/deletes from updates. Standard streams are the default type and provide the full CDC picture needed for audit trails.

**Escenario:** A data engineering team has a stream on their `web_events` table, but nobody queried it for 3 weeks. The table's DATA_RETENTION_TIME_IN_DAYS is set to 14 days. When they query the stream, they get a stale stream error. What happened?
**Respuesta:** Streams rely on the table's Time Travel retention to track their offset position. Since the stream wasn't consumed within the 14-day retention window, the stream's offset fell outside the available Time Travel data and became STALE. Once stale, the stream cannot recover its change history — the CDC data is lost. To prevent this, either consume streams regularly (within the retention period) or increase the table's DATA_RETENTION_TIME_IN_DAYS to a value longer than the maximum gap between stream consumption.

**Escenario:** A company has an external table pointing to Parquet files in S3. They want to create a stream on it to detect when new files are added. Which stream type is supported?
**Respuesta:** Only Insert-only streams are supported on external tables. External tables do not support Standard or Append-only streams. An Insert-only stream will detect new rows that appear when new files are added to the external stage. It cannot track updates or deletes because external tables are read-only views over files in cloud storage — Snowflake has no control over file modifications or deletions at the source.

---

---

## 3.8 TASKS

### Qué son:
- Programan ejecución de SQL
- Pueden ejecutarse en un horario (CRON o intervalo)
- Pueden depender de otras tasks (DAG / árbol de tasks)
- Pueden ser disparadas por datos de stream

### Árbol de tasks (DAG):
- Task raíz → tasks hijas → tasks nietas
- La task raíz tiene el horario
- Las tasks hijas se ejecutan después de que el padre complete
- Hasta 1000 tasks en un árbol

### Opciones de compute:
- Warehouse gestionado por usuario (pagas por el warehouse)
- Tasks serverless (Snowflake gestiona el compute, pago por uso)

### Clave: Las tasks deben ser REANUDADAS para ejecutarse (inician en estado SUSPENDIDO)
- ALTER TASK nombre_task RESUME

**Trampa del examen**: "¿Las tasks inician en estado RUNNING?" → INCORRECTO. SI VES "RUNNING" como estado inicial de task → trampa. Las tasks inician SUSPENDIDAS. Debes usar ALTER TASK ... RESUME.
**Trampa del examen**: "¿Dónde va el horario en un árbol de tasks?" → Solo en la task RAÍZ. SI VES "horario" en una task hija → INCORRECTO porque las tasks hijas se disparan DESPUÉS de que el padre complete, solo la raíz tiene horario.
**Trampa del examen**: "¿Opciones de compute para tasks?" → Warehouse gestionado por usuario O serverless. SI VES "solo serverless" o "solo warehouse" → INCORRECTO porque AMBAS opciones son válidas para tasks.


### Ejemplos de Preguntas de Escenario — Tasks

**Escenario:** A data engineer creates a task to aggregate daily sales data every night at midnight. They run `CREATE TASK nightly_agg WAREHOUSE = analytics_wh SCHEDULE = 'USING CRON 0 0 * * * America/New_York' AS INSERT INTO daily_summary SELECT ...`. The task is created successfully, but it never runs. What did they forget?
**Respuesta:** Tasks are created in a SUSPENDED state by default. The engineer must run `ALTER TASK nightly_agg RESUME` to activate it. This is a common pitfall — until a task is explicitly resumed, it will never execute regardless of the schedule or warehouse configuration. This applies to all tasks, both root tasks and child tasks in a DAG.

**Escenario:** A team builds a data pipeline with a root task that runs every 10 minutes and three child tasks that perform transformations after the root completes. A new requirement comes in to add a fourth child task. Where should the schedule be defined, and what happens if they try to put a schedule on the child task?
**Respuesta:** The schedule belongs only on the root task. Child tasks fire automatically after their parent completes — they inherit execution timing from the dependency chain, not from their own schedule. Attempting to set a SCHEDULE on a child task that has an AFTER clause will result in an error. The new fourth child task should be created with `AFTER root_task` (or after another child if there's a dependency) and no SCHEDULE parameter. The DAG supports up to 1,000 tasks.

**Escenario:** A company wants to process CDC changes from a stream only when new data arrives, rather than running a task on a fixed schedule that wastes compute when there are no changes. How should they configure the task?
**Respuesta:** Use the `WHEN SYSTEM$STREAM_HAS_DATA('my_stream')` condition on the task. The task still needs a schedule (CRON or interval) that defines how often to check the condition, but the SQL body only executes when the stream actually has unconsumed data. For example: `CREATE TASK process_changes WAREHOUSE = etl_wh SCHEDULE = '5 MINUTE' WHEN SYSTEM$STREAM_HAS_DATA('orders_stream') AS MERGE INTO ...`. This avoids unnecessary warehouse spin-up when the stream is empty.

---

---

## 3.9 TABLAS DINÁMICAS (NUEVO para COF-C03)

### Qué son:
- Pipelines de datos declarativos
- Define una consulta SQL, establece un "target lag" (frescura)
- Snowflake automáticamente mantiene los resultados actualizados
- Reemplaza muchos pipelines de Streams + Tasks

### Target lag:
- Tú estableces qué tan frescos necesitas los datos (ej. 1 minuto, 1 hora)
- Snowflake decide cuándo refrescar
- Puede ser refresh incremental o completo (Snowflake elige)

### Ventajas sobre Streams+Tasks:
- Más simple de definir (solo SQL + lag)
- Programación de refresh automática
- Puede encadenar tablas dinámicas (DT lee de DT)

### Disponible en TODAS las ediciones

**Trampa del examen**: "¿Las Tablas Dinámicas requieren Enterprise?" → INCORRECTO. SI VES "Enterprise" o "Business Critical" como requisito → trampa. Las Tablas Dinámicas están disponibles en TODAS las ediciones.
**Trampa del examen**: "¿Tabla Dinámica vs Streams+Tasks?" → Tabla Dinámica = declarativa (SQL + target lag). SI VES "Tabla Dinámica requiere programación manual" → INCORRECTO porque Snowflake maneja el refresh automáticamente; Streams+Tasks es el enfoque manual/imperativo.
**Trampa del examen**: "¿Quién decide cuándo se refresca una Tabla Dinámica — tú o Snowflake?" → Snowflake decide. SI VES "el usuario programa el refresh" → INCORRECTO porque tú estableces el TARGET LAG y Snowflake decide cuándo refrescar.


### Ejemplos de Preguntas de Escenario — Dynamic Tables

**Escenario:** A marketing team needs a summary table that joins customer data with purchase history and is never more than 10 minutes stale. They currently maintain this with a stream on the customers table, a stream on the purchases table, and a task that runs a complex MERGE every 5 minutes. The pipeline is brittle and hard to debug. What is a simpler alternative?
**Respuesta:** Replace the entire Streams + Tasks pipeline with a single Dynamic Table: `CREATE DYNAMIC TABLE customer_purchase_summary TARGET_LAG = '10 minutes' WAREHOUSE = analytics_wh AS SELECT c.*, p.total_spend FROM customers c JOIN purchases p ON c.id = p.customer_id`. Snowflake automatically determines when to refresh the table to meet the 10-minute target lag. This eliminates the need to manage streams, tasks, MERGE logic, and error handling — just define the SQL and the desired freshness.

**Escenario:** A data architect is building a multi-layer transformation pipeline: raw data → cleaned data → aggregated data. They want each layer to automatically stay fresh. Can Dynamic Tables be chained together?
**Respuesta:** Yes. Dynamic Tables can read from other Dynamic Tables, forming a chain. For example: `dt_clean` reads from a raw table, `dt_aggregated` reads from `dt_clean`. Each has its own TARGET_LAG. Snowflake coordinates refresh scheduling across the chain to ensure downstream tables stay within their lag targets. The upstream table refreshes first, then downstream tables refresh when their source changes. This creates a fully declarative, multi-layer pipeline with no manual orchestration.

**Escenario:** A colleague claims Dynamic Tables require Enterprise edition. A team on Standard edition wants to use them. Who is correct?
**Respuesta:** The colleague is wrong. Dynamic Tables are available on ALL Snowflake editions, including Standard. There is no edition restriction. The team on Standard edition can create and use Dynamic Tables with the same functionality — define a SQL query, set a target lag, and Snowflake handles the rest.

---

---

## 3.10 CONECTORES E INTEGRACIONES

### Conectores de Snowflake:
- Conector Python → apps Python se conectan a Snowflake
- Driver JDBC → apps Java
- Driver ODBC → Conectividad general de base de datos
- Driver Node.js → apps JavaScript
- Driver .NET → apps C#/.NET
- Driver Go → apps Go

### Snowflake CLI (snow):
- Herramienta de línea de comandos
- Ejecutar SQL, gestionar objetos, desplegar apps

### SnowSQL:
- Cliente de línea de comandos
- Ejecutar SQL
- PUT/GET archivos (única forma de subir/descargar desde local)

### Integración de Almacenamiento:
- Conecta de forma segura a almacenamiento externo en la nube
- Evita almacenar credenciales en definiciones de stage
- CREATE STORAGE INTEGRATION → definir una vez, usar en múltiples stages

### Integración de API:
- Conecta a APIs externas
- Usado para funciones externas
- CREATE API INTEGRATION

### Integración Git (NUEVO para COF-C03):
- Conecta repositorios Git a Snowflake
- Almacena código (UDFs, procedimientos, apps Streamlit) en Git
- CREATE GIT REPOSITORY
- Gestión de código con control de versiones

**Trampa del examen**: "¿Integración de Almacenamiento vs Integración de API?" → Almacenamiento = almacenamiento en nube (S3/Azure/GCS). API = APIs REST externas. SI VES "Integración de API" para acceso a S3 → INCORRECTO porque S3/Azure/GCS usan integración de ALMACENAMIENTO; Integración de API es para funciones externas.
**Trampa del examen**: "¿SnowSQL vs Snowflake CLI (snow)?" → Ambas son herramientas CLI. SI VES "SnowSQL despliega apps" o "snow CLI hace PUT/GET" → INCORRECTO porque SnowSQL = cliente SQL antiguo (PUT/GET); snow CLI = más nuevo, gestiona objetos + despliega apps.
**Trampa del examen**: "¿PUT/GET funcionan en la interfaz web Snowsight?" → INCORRECTO. SI VES "Snowsight" + "PUT" o "GET" → trampa. PUT/GET solo funcionan vía SnowSQL o conectores de Snowflake (Python, JDBC, etc.).


### Ejemplos de Preguntas de Escenario — Connectors & Integrations

**Escenario:** A company's data pipeline creates external stages pointing to multiple S3 buckets. Currently, each stage definition includes hardcoded AWS access keys and secret keys. The security team flags this as a risk. What is the recommended way to secure these connections?
**Respuesta:** Create a Storage Integration with `CREATE STORAGE INTEGRATION` that uses an IAM role-based trust relationship instead of embedded credentials. The integration is defined once and can be referenced by multiple stages. This eliminates hardcoded credentials from stage definitions, centralizes access management, and follows Snowflake's security best practices. The integration establishes trust between Snowflake's IAM identity and the customer's AWS IAM role.

**Escenario:** A DevOps engineer wants to store their Snowflake UDFs and stored procedures in a GitHub repository and deploy them through version-controlled workflows. Does Snowflake support native Git integration?
**Respuesta:** Yes. Snowflake supports Git Integration via `CREATE GIT REPOSITORY`, which connects a Git repository (GitHub, GitLab, etc.) directly to Snowflake. This allows teams to store UDFs, stored procedures, and Streamlit app code in Git with full version control. Code can be synced from the repository into Snowflake, enabling CI/CD-style deployments. This is a new feature for the COF-C03 exam and is separate from external tools like dbt.

**Escenario:** A new hire asks whether they should use SnowSQL or the Snowflake CLI (`snow`) to upload local CSV files to a Snowflake stage. Which tool supports PUT/GET?
**Respuesta:** SnowSQL is the correct tool for PUT/GET operations. The Snowflake CLI (`snow`) is a newer tool focused on managing Snowflake objects, deploying applications (Streamlit, Native Apps), and executing SQL — but it does not support PUT/GET file transfers. PUT and GET commands work only through SnowSQL or Snowflake language connectors (Python, JDBC, ODBC, etc.). They do not work in the Snowsight web UI either.

---

---

## 3.11 TABLAS DE DIRECTORIO

### Qué son:
- Catálogo integrado de archivos en un stage
- Consultar con SQL para ver metadatos de archivos
- Disponible para stages internos y externos
- Proporciona: nombre de archivo, tamaño, MD5, última modificación, etc.

### Habilitar en stage:
- CREATE STAGE ... DIRECTORY = (ENABLE = TRUE)
- Debe refrescarse: ALTER STAGE ... REFRESH

**Trampa del examen**: "¿Las tablas de directorio se auto-refrescan?" → NO para stages externos. SI VES "automático" + "refresh de tabla de directorio" en stages externos → INCORRECTO porque debes ejecutar ALTER STAGE ... REFRESH (o configurar auto-refresh explícitamente).
**Trampa del examen**: "¿Tabla de directorio vs comando LIST?" → Tabla de directorio = consultable con SQL. SI VES "LIST" para JOIN o filtrado WHERE → INCORRECTO porque LIST es un listado simple de archivos; las Tablas de Directorio soportan SQL completo (JOIN, WHERE, etc.).


### Ejemplos de Preguntas de Escenario — Directory Tables

**Escenario:** A media company stores thousands of image files in an external stage (S3). They want to build a SQL query that joins file metadata (name, size, last modified) with a tracking table to find files that haven't been processed yet. Can they do this with the LIST command?
**Respuesta:** No. The LIST command returns a simple file listing that cannot be used in SQL joins, WHERE clauses, or subqueries. Instead, enable a Directory Table on the stage with `ALTER STAGE my_stage SET DIRECTORY = (ENABLE = TRUE)`, then run `ALTER STAGE my_stage REFRESH` to populate it. The directory table can then be queried with full SQL: `SELECT * FROM DIRECTORY(@my_stage) d LEFT JOIN processed_files p ON d.RELATIVE_PATH = p.file_name WHERE p.file_name IS NULL`. Directory tables provide file name, size, MD5, last modified, and other metadata as queryable columns.

**Escenario:** A data engineer enables a directory table on an external stage pointing to GCS. New files land in the bucket daily, but the directory table doesn't show them. What is missing?
**Respuesta:** Directory tables on external stages do not auto-refresh by default. The engineer must run `ALTER STAGE my_stage REFRESH` to update the directory table with newly arrived files. This can be automated by configuring auto-refresh with cloud event notifications (similar to Snowpipe auto-ingest), or by scheduling a task to run the refresh command periodically. Without explicit refresh, the directory table only shows files that were present at the time of the last refresh.

---

---

## 3.12 URLs DE ARCHIVOS (PROBADO)

### Tres tipos de URLs para archivos en stages:

| Tipo de URL | Duración | Quién puede usarla | Función |
|---|---|---|---|
| File URL | Persistente (ID de 64 bits) | Usuarios de Snowflake con acceso | BUILD_STAGE_FILE_URL() |
| Scoped URL | Solo duración de sesión | Sesión del usuario actual | BUILD_SCOPED_FILE_URL() |
| Pre-signed URL | Expiración configurable | Cualquiera (sin login de Snowflake) | GET_PRESIGNED_URL() |

**Trampa del examen**: "¿Compartir archivo con socio externo (sin cuenta Snowflake)?" → Pre-signed URL. SI VES "File URL" o "Scoped URL" para compartir externamente → INCORRECTO porque esas requieren autenticación de Snowflake; Pre-signed URL NO necesita login.
**Trampa del examen**: "¿URL válida solo para la sesión actual?" → Scoped URL. SI VES "Pre-signed URL" como de alcance de sesión → INCORRECTO porque Pre-signed tiene expiración configurable; SCOPED URL muere cuando la sesión termina.
**Trampa del examen**: "¿Acceso persistente a archivos para usuarios de Snowflake?" → File URL. SI VES "Pre-signed URL" para acceso persistente → INCORRECTO porque las Pre-signed URLs expiran; FILE URL es persistente (vinculada a un ID de 64 bits).


### Ejemplos de Preguntas de Escenario — File URLs

**Escenario:** A consulting firm needs to share a PDF report stored in a Snowflake internal stage with a client who does not have a Snowflake account. The link should expire after 7 days. Which URL type should they use?
**Respuesta:** Use a Pre-signed URL generated with `GET_PRESIGNED_URL(@stage, 'report.pdf', 604800)` (604800 seconds = 7 days). Pre-signed URLs are the only URL type that works for users without a Snowflake account — anyone with the link can download the file. The expiry is configurable. File URLs and Scoped URLs both require Snowflake authentication, making them unsuitable for external sharing.

**Escenario:** A Streamlit app in Snowflake displays images stored in a stage. The app needs URLs that work only during the user's active session and cannot be shared or bookmarked for later use. Which URL type is appropriate?
**Respuesta:** Use Scoped URLs generated with `BUILD_SCOPED_FILE_URL(@stage, 'image.png')`. Scoped URLs are tied to the current user's session and expire when the session ends. They cannot be shared with other users or reused in a different session. This provides the tightest access control for session-bound use cases like in-app image rendering, where persistent or shareable access is not desired.

**Escenario:** An analytics team builds a dashboard that references report files in a stage. The file links need to work persistently across sessions for any Snowflake user who has access to the stage. Which URL type should they use?
**Respuesta:** Use File URLs generated with `BUILD_STAGE_FILE_URL(@stage, 'report.csv')`. File URLs are persistent (they use a 64-bit identifier) and work for any Snowflake user who has the appropriate privileges on the stage. Unlike Scoped URLs (which die with the session) or Pre-signed URLs (which expire), File URLs provide stable, long-lived access — ideal for dashboards, bookmarks, and shared references within the organization.

---

---

## 3.13 ENCRIPTACIÓN DEL LADO DEL SERVIDOR

### Stages internos:
- Snowflake gestiona la encriptación (AES-256)
- Automática, siempre activa

### Stages externos:
- Puede usar encriptación del lado del servidor en almacenamiento en nube (SSE-S3, SSE-KMS para AWS)
- Configurar en la definición del stage o integración de almacenamiento

**Trampa del examen**: "¿Necesitas habilitar encriptación para stages internos?" → NO. SI VES "habilitar encriptación" + "stage interno" → INCORRECTO porque los stages internos SIEMPRE están encriptados (AES-256) automáticamente — no se necesita acción.
**Trampa del examen**: "¿Quién gestiona las claves de encriptación para stages internos?" → Snowflake las gestiona. SI VES "claves gestionadas por el cliente" para stages internos → INCORRECTO porque Snowflake maneja la encriptación de stages internos; TÚ solo configuras encriptación para stages EXTERNOS.


### Ejemplos de Preguntas de Escenario — Server-Side Encryption

**Escenario:** A security auditor asks the data team to confirm that files in Snowflake's internal stages are encrypted at rest. The team hasn't configured any encryption settings. Should they be concerned?
**Respuesta:** No. Internal stages are always encrypted with AES-256 encryption, managed entirely by Snowflake. This encryption is automatic and always on — there is no configuration required and no way to disable it. The team does not need to take any action. Snowflake manages the encryption keys for internal stages as part of its built-in security model.

**Escenario:** A company stores sensitive financial data in an S3 bucket used as an external stage. Their compliance team requires that all data at rest in S3 is encrypted with AWS KMS customer-managed keys (SSE-KMS). How should they configure encryption for the external stage?
**Respuesta:** Configure server-side encryption in the external stage definition or storage integration by specifying the encryption type and KMS key. For example, in the stage definition: `CREATE STAGE my_s3_stage URL = 's3://bucket/path' ... ENCRYPTION = (TYPE = 'AWS_SSE_KMS' KMS_KEY_ID = 'aws/key')`. This ensures files written to S3 during unloading are encrypted with the specified KMS key. For loading, the files must already be encrypted at the source — Snowflake can read SSE-S3 and SSE-KMS encrypted files when proper IAM permissions are configured via a storage integration.

---

---

## 3.14 DESCARGA DE DATOS

### COPY INTO @stage FROM tabla/consulta:
- Exporta datos a archivos en un stage
- Compresión por defecto: gzip
- Formato por defecto: CSV
- Puede descargar a: stages internos, stages externos (S3, Azure, GCS)
- Soporta: CSV, JSON, Parquet
- Puede particionar archivos de salida: PARTITION BY expresión

### Opciones clave de descarga:
- SINGLE = TRUE → un solo archivo de salida
- MAX_FILE_SIZE → controlar tamaño del archivo
- HEADER = TRUE → incluir encabezados de columna
- OVERWRITE = TRUE → sobrescribir archivos existentes

**Trampa del examen**: "¿La descarga soporta Avro/ORC/XML?" → INCORRECTO. SI VES "Avro", "ORC", o "XML" para descarga → trampa. La descarga SOLO soporta CSV, JSON, Parquet. Los 6 formatos son solo para CARGA.
**Trampa del examen**: "¿Comportamiento por defecto de descarga — un archivo o muchos?" → Muchos archivos (divididos). SI VES "un solo archivo" como defecto → INCORRECTO porque por defecto se divide en múltiples archivos; usa SINGLE = TRUE para un solo archivo.
**Trampa del examen**: "¿COPY INTO @stage = carga o descarga?" → DESCARGA (exportación). SI VES "COPY INTO @stage" descrito como carga → INCORRECTO porque @stage como DESTINO = descarga; COPY INTO tabla = carga.


### Ejemplos de Preguntas de Escenario — Unloading Data

**Escenario:** A data team needs to export query results to Parquet files in an S3 bucket, partitioned by year and month, for consumption by a Spark cluster. They also want column headers included. How should they configure the COPY INTO?
**Respuesta:** Use `COPY INTO @s3_stage/export/ FROM (SELECT * FROM analytics_table) FILE_FORMAT = (TYPE = PARQUET) PARTITION BY ('year=' || YEAR(order_date) || '/month=' || MONTH(order_date)) HEADER = TRUE`. This exports data as Parquet files (one of three supported unload formats: CSV, JSON, Parquet), partitioned into S3 prefixes by year/month for efficient Spark reads. Default compression is gzip. Note that Avro, ORC, and XML are supported for loading only — not for unloading.

**Escenario:** A downstream system requires exactly one output file (not split across multiple files) when receiving data exports from Snowflake. The default COPY INTO unload produces many small files. How can the engineer produce a single file?
**Respuesta:** Set `SINGLE = TRUE` in the COPY INTO statement: `COPY INTO @my_stage/export.csv FROM my_table FILE_FORMAT = (TYPE = CSV) SINGLE = TRUE`. By default, Snowflake splits unloaded data into multiple files for parallelism. SINGLE = TRUE forces all output into one file. For large datasets, also consider setting `MAX_FILE_SIZE` to ensure the single file isn't too large for the downstream system. Note that single-file unloads may be slower since they cannot parallelize the write.

**Escenario:** A company unloads customer data to an internal stage weekly for backup purposes. Each week's export overwrites the previous one. They notice the old files still exist alongside new ones. What parameter controls this behavior?
**Respuesta:** Use `OVERWRITE = TRUE` in the COPY INTO statement to replace existing files in the stage. Without OVERWRITE = TRUE, Snowflake writes new files alongside existing ones (it does not automatically delete previous exports). Alternatively, the team can manually remove old files with `REMOVE @stage/path/` before each unload, but OVERWRITE = TRUE is the cleaner approach for recurring export workflows.

---

---

## REPASO RÁPIDO — Dominio 3

1. Tres stages internos: Usuario @~, Tabla @%t, Nombrado @s
2. PUT = subir local→stage. GET = descargar stage→local. Ambos necesitan SnowSQL.
3. Stages externos = S3, Azure, GCS
4. COPY INTO = carga masiva. Comportamiento de error por defecto = ABORTAR toda la carga.
5. VALIDATION_MODE = verificar errores sin cargar
6. PURGE = TRUE elimina archivos fuente después de la carga
7. METADATA$FILENAME = obtener nombre del archivo fuente durante la carga
8. Snowpipe = serverless, continuo, casi tiempo real (minutos)
9. Snowpipe Streaming = nivel de fila, sub-segundo, sin archivos necesarios
10. Tamaño de archivo recomendado: 100-250 MB comprimido
11. Streams = CDC (rastreo de INSERT, UPDATE, DELETE)
12. Tasks = ejecución SQL programada (CRON o intervalo)
13. Streams + Tasks = pipeline clásico. Tablas Dinámicas = reemplazo moderno.
14. Tablas Dinámicas = consulta SQL + target lag, refresh automático
15. Integración de Almacenamiento = conexión segura a almacenamiento en nube (sin credenciales incrustadas)
16. Integración Git = código con control de versiones en Snowflake (NUEVO)
17. Tablas de Directorio = catálogo de archivos para stages
18. Pre-signed URL = compartir con cualquiera (sin cuenta Snowflake necesaria)
19. Scoped URL = acceso solo de sesión
20. File URL = acceso persistente para usuarios de Snowflake
21. Conector Kafka se ejecuta en el entorno del CLIENTE
22. Formatos soportados: CSV, JSON, Avro, ORC, Parquet, XML. NO: HTML, Excel, PDF
23. Descarga por defecto: compresión gzip, formato CSV
24. Función VALIDATE() → revisar errores de carga anterior

---

## PARES CONFUSOS — Dominio 3

| Preguntan sobre... | La respuesta es... | NO es... |
|---|---|---|
| Subir archivo local al stage | PUT (vía SnowSQL) | COPY INTO |
| Cargar datos del stage a tabla | COPY INTO | PUT |
| Descargar archivo del stage a local | GET | COPY INTO |
| Descargar tabla al stage | COPY INTO @stage FROM tabla | GET |
| Compute de Snowpipe | Serverless (gestionado por Snowflake) | Basado en warehouse |
| Disparador de Snowpipe | Notificación de evento de nube o API REST | Horario manual |
| Entrada de Snowpipe Streaming | Filas vía SDK/API | Archivos |
| Tipo de stream para tabla externa | Insert-only | Standard |
| Las tasks inician en estado | SUSPENDIDO (debe REANUDAR) | RUNNING |
| Tabla Dinámica vs Streams+Tasks | Target lag (declarativo) | Programación manual |
| Pre-signed URL | Cualquiera, temporal | Solo usuarios de Snowflake |
| Scoped URL | Solo sesión actual | Persistente |
| File URL | Persistente, usuarios de Snowflake | Acceso externo |
| ON_ERROR por defecto | ABORT_STATEMENT | CONTINUE |
| FORCE = TRUE | Recargar archivos ya cargados | Comportamiento normal de carga |
| Conector Kafka se ejecuta donde | Entorno del cliente | Nube de Snowflake |
| Integración de Almacenamiento | Acceso seguro a nube, sin credenciales en stage | Stage con credenciales incrustadas |

---

## RESUMEN AMIGABLE — Dominio 3

### ÁRBOLES DE DECISIÓN POR ESCENARIO
Cuando leas una pregunta, encuentra el patrón:

**"El ingeniero de datos de un cliente necesita subir archivos CSV desde su laptop a Snowflake..."**
→ Paso 1: PUT archivo al stage (vía SnowSQL)
→ Paso 2: COPY INTO tabla FROM stage
→ NO solo "COPY INTO" (los archivos deben ser staged primero)

**"Una empresa retail quiere que los datos se carguen automáticamente cada vez que nuevos archivos de ventas llegan a su bucket S3..."**
→ Snowpipe con AUTO_INGEST = TRUE + notificación de evento S3 (SQS)
→ NO Tasks programadas (Snowpipe es basado en eventos, no polling)

**"Los sensores GPS de una flota logística de IoT envían registros individuales cada segundo..."**
→ Snowpipe Streaming (nivel de fila, sub-segundo, sin archivos necesarios)
→ NO Snowpipe regular (eso necesita que los archivos lleguen primero)

**"Un equipo de marketing quiere una tabla resumen para dashboard que nunca esté más de 10 minutos desactualizada..."**
→ Tabla Dinámica con TARGET_LAG = '10 minutes'
→ NO Streams + Tasks (funciona, pero Tabla Dinámica es más simple para esto)

**"Un equipo de finanzas necesita saber exactamente qué transacciones se insertaron, actualizaron o eliminaron desde ayer..."**
→ Stream (Change Data Capture) — tipo Standard
→ METADATA$ACTION te dice INSERT vs DELETE, METADATA$ISUPDATE te dice si fue UPDATE

**"Un pipeline de datos solo debería procesar datos nuevos cuando realmente llegan, no en un horario fijo..."**
→ Task con WHEN SYSTEM$STREAM_HAS_DATA('nombre_stream')
→ Combinación de Stream + Task

**"Una consultora necesita compartir un archivo de reporte con un cliente que no tiene Snowflake..."**
→ Pre-signed URL (GET_PRESIGNED_URL) — cualquiera puede usarla, sin login
→ NO File URL (requiere login de Snowflake)
→ NO Scoped URL (solo sesión actual)

**"Antes de cargar 50 millones de filas, el equipo quiere previsualizar cualquier error primero..."**
→ VALIDATION_MODE = RETURN_ERRORS (verifica sin cargar realmente)
→ NO ON_ERROR (eso es lo que pasa DURANTE la carga real)

**"Después de cargar, el analista quiere saber de qué archivo fuente vino cada fila..."**
→ METADATA$FILENAME en la cláusula SELECT de COPY INTO
→ Debe hacerse DURANTE la carga, no después

**"Una empresa de e-commerce transmite eventos desde Kafka a Snowflake..."**
→ Conector Kafka (se ejecuta en el entorno Kafka del CLIENTE, no en Snowflake)
→ Puede usar modo Snowpipe Streaming para menor latencia

**"Un ingeniero de datos accidentalmente cargó los mismos archivos dos veces..."**
→ COPY INTO rastrea archivos cargados por 64 días (previene duplicados automáticamente)
→ A menos que se use FORCE = TRUE (eso sobreescribe la verificación de duplicados)

**"Un equipo quiere limpiar archivos fuente de S3 después de carga exitosa..."**
→ PURGE = TRUE en COPY INTO
→ Elimina archivos fuente solo después de carga exitosa

**"Un cliente pregunta: ¿puedo subir archivos a través de la interfaz web Snowsight?"**
→ PUT/GET NO funcionan en Snowsight
→ Debe usar SnowSQL CLI o conectores de Snowflake

**"Un equipo de analítica quiere almacenar sus modelos dbt y código UDF con control de versiones..."**
→ Integración Git (CREATE GIT REPOSITORY — conecta GitHub/GitLab a Snowflake)
→ Esta es una funcionalidad nativa de Snowflake, separada de dbt en sí

**"Un cliente carga un CSV pero las columnas están en orden incorrecto comparado con la tabla..."**
→ Usar SELECT con reordenamiento de columnas en COPY INTO: COPY INTO tabla FROM (SELECT $3, $1, $2 FROM @stage)
→ O usar MATCH_BY_COLUMN_NAME para coincidir por nombres de encabezado

**"Un cliente carga datos y algunas filas tienen más columnas que la tabla destino..."**
→ ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE (columnas extra ignoradas, faltantes = NULL)
→ Por defecto es TRUE (dará error)

---

### MNEMOTÉCNICOS PARA RECORDAR

**Tres stages = "U-T-N" → "Usuario, Tabla, Nombrado"**
- **U**suario (@~) → personal, no se puede alterar
- **T**abla (@%t) → vinculado a una tabla, no se puede alterar
- **N**ombrado (@stage) → objeto de BD, más control, RECOMENDADO

**Snowpipe vs COPY INTO = "Continuo vs Lotes"**
- Snowpipe → datos llegan → se cargan automáticamente (minutos)
- COPY INTO → tú ejecutas manualmente o en horario (batch)

**Tipos de stream = "S-A-I" → "Standard, Append, Insert"**
- **S**tandard → todo DML (INSERT, UPDATE, DELETE)
- **A**ppend-only → solo INSERTs
- **I**nsert-only → solo para tablas externas

**URLs de archivos = "P-S-F" → "Pre-signed, Scoped, File"**
- **P**re-signed → cualquiera, expiración configurable
- **S**coped → solo sesión actual
- **F**ile → persistente, requiere login de Snowflake

**Formatos de carga = "CJAOPC" → Los 6: CSV, JSON, Avro, ORC, Parquet, XML**
**Formatos de descarga = solo "CJP" → CSV, JSON, Parquet**

---

### TRAMPAS PRINCIPALES — Dominio 3

1. **"PUT funciona en Snowsight"** → INCORRECTO. Solo SnowSQL o conectores.
2. **"COPY INTO sube archivos del laptop"** → INCORRECTO. PUT sube. COPY INTO carga de stage a tabla.
3. **"Snowpipe usa un warehouse"** → INCORRECTO. Serverless.
4. **"Snowpipe Streaming necesita archivos"** → INCORRECTO. Filas vía SDK/API.
5. **"Las tasks inician en RUNNING"** → INCORRECTO. Inician SUSPENDIDAS.
6. **"Tablas Dinámicas requieren Enterprise"** → INCORRECTO. TODAS las ediciones.
7. **"La descarga soporta Avro/ORC/XML"** → INCORRECTO. Solo CSV, JSON, Parquet.
8. **"VALIDATION_MODE carga datos"** → INCORRECTO. Solo verifica, no carga.
9. **"Conector Kafka se ejecuta en Snowflake"** → INCORRECTO. Entorno del cliente.
10. **"Stage de usuario se puede alterar"** → INCORRECTO. No se puede alterar ni eliminar.

---

### ATAJOS DE PATRONES — "Si ves ___, la respuesta es ___"

| Si la pregunta menciona... | La respuesta casi siempre es... |
|---|---|
| "subir archivo del laptop" | PUT (vía SnowSQL) |
| "cargar datos del stage a tabla" | COPY INTO |
| "carga continua/automática" | Snowpipe |
| "sub-segundo", "nivel de fila" | Snowpipe Streaming |
| "verificar errores antes de cargar" | VALIDATION_MODE |
| "revisar errores después de cargar" | VALIDATE() |
| "eliminar archivos después de cargar" | PURGE = TRUE |
| "nombre del archivo fuente en tabla" | METADATA$FILENAME |
| "compartir archivo sin cuenta Snowflake" | Pre-signed URL |
| "conectar a S3/Azure/GCS de forma segura" | Integración de Almacenamiento |
| "llamar API externa" | Integración de API + Función Externa |
| "código con control de versiones" | Integración Git |
| "pipeline declarativo" | Tabla Dinámica |
| "rastrear cambios en tabla" | Stream (CDC) |
| "SQL programado" | Task |
| "catálogo de archivos en stage" | Tabla de Directorio |

---

## CONSEJOS PARA EL DÍA DEL EXAMEN — Dominio 3 (18% = ~18 preguntas)

**Antes de estudiar este dominio:**
- Flashcards de los 3 tipos de stage + sus limitaciones
- Memoriza: PUT = local→stage, COPY INTO = stage→tabla, GET = stage→local
- Conoce Snowpipe vs COPY INTO vs Snowpipe Streaming (latencia, entrada, compute)

**Durante el examen — Preguntas del Dominio 3:**
- Si mencionan "laptop" o "local" → piensa PUT/GET (vía SnowSQL)
- Si mencionan "continuo" o "automático" o "tiempo real" → piensa Snowpipe
- Si mencionan "sub-segundo" o "sin archivos" → piensa Snowpipe Streaming
- Si mencionan "verificar errores" → ¿antes de cargar (VALIDATION_MODE) o después (VALIDATE)?
- Si mencionan "sin cuenta Snowflake" + "compartir archivo" → Pre-signed URL
- Si mencionan "declarativo" o "target lag" → Tabla Dinámica

---

## FLASHCARDS — Dominio 3

**P:** ¿Cuáles son los tres tipos de stages internos?
**R:** Usuario (@~), Tabla (@%nombre), Nombrado (@stage). Solo los nombrados se pueden alterar/eliminar y tienen privilegios otorgables.

**P:** ¿Cuál es la diferencia entre PUT y COPY INTO?
**R:** PUT sube archivos del local al stage. COPY INTO carga datos del stage a la tabla. Son dos pasos separados.

**P:** ¿Cuál es el comportamiento por defecto de ON_ERROR en COPY INTO?
**R:** ABORT_STATEMENT — toda la carga falla si hay cualquier error. Alternativas: CONTINUE (salta filas malas), SKIP_FILE (salta archivos malos).

**P:** ¿Cómo se diferencia Snowpipe de COPY INTO?
**R:** Snowpipe = serverless, continuo, disparado por eventos (minutos). COPY INTO = requiere warehouse, batch, ejecución manual/programada.

**P:** ¿Qué es Snowpipe Streaming?
**R:** Carga de datos nivel de fila directamente vía SDK/API. Sub-segundo de latencia. Sin archivos en stage necesarios. La menor latencia posible.

**P:** ¿Cuáles son los tres tipos de URLs de archivos?
**R:** File URL (persistente, requiere login SF), Scoped URL (solo sesión), Pre-signed URL (cualquiera, expiración configurable).

**P:** ¿Qué formatos soporta la descarga?
**R:** Solo CSV, JSON, Parquet. La carga soporta 6: CSV, JSON, Avro, ORC, Parquet, XML.

**P:** ¿Qué son las Tablas Dinámicas?
**R:** Pipelines declarativos: defines SQL + target lag, Snowflake refresca automáticamente. Reemplazan Streams+Tasks para muchos casos. TODAS las ediciones.

**P:** ¿En qué estado inician las Tasks?
**R:** SUSPENDIDO. Debes ALTER TASK ... RESUME para activarlas.

**P:** ¿Qué tipos de streams existen?
**R:** Standard (todo DML), Append-only (solo INSERTs), Insert-only (tablas externas solamente).

---

## EXPLÍCALO COMO SI TUVIERA 5 AÑOS — Dominio 3

**Stage**: Un casillero donde pones tus archivos antes de que Snowflake los ponga en una tabla. Como dejar tu equipaje en la cinta antes de que lo pongan en el avión.

**PUT**: Poner tu archivo en el casillero (desde tu computadora).

**COPY INTO**: Decirle a Snowflake "toma los archivos del casillero y ponlos en la tabla."

**Snowpipe**: Un robot que vigila el casillero. Cada vez que un archivo nuevo aparece, lo pone en la tabla automáticamente. No necesitas decirle nada.

**Snowpipe Streaming**: En vez de dejar archivos en el casillero, le pasas los datos directamente de mano en mano al robot. Más rápido que nunca.

**Stream**: Un diario que anota cada cambio en una tabla. "Se agregó la fila 5", "se eliminó la fila 3", "se actualizó la fila 7."

**Task**: Un despertador que le dice a Snowflake "ejecuta esta consulta SQL cada hora" (o cada que el diario tenga algo nuevo).

**Tabla Dinámica**: Le dices a Snowflake "quiero que esta tabla siempre muestre el resultado de esta consulta" y Snowflake se encarga de mantenerla actualizada. Tú solo dices QUÉ quieres, no CÓMO hacerlo.

**Pre-signed URL**: Un pase temporal para descargar un archivo. Cualquiera con el pase puede acceder, incluso si no tienen cuenta de Snowflake. El pase expira después de un tiempo.

**Integración de Almacenamiento**: En vez de darle a Snowflake las llaves de tu casillero de S3 cada vez, le das un pase permanente seguro. Más seguro y más fácil.

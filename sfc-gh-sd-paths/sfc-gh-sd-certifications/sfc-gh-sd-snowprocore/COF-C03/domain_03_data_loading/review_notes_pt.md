# DOMÍNIO 3: CARREGAMENTO, DESCARREGAMENTO E CONECTIVIDADE DE DADOS
## 18% do exame = ~18 questões

---

## 3.1 STAGES (MUITO TESTADO)

Um stage = um local onde arquivos de dados ficam antes/depois do carregamento.

### Três tipos de stages INTERNOS:

| Stage | Símbolo | Escopo | Quem usa |
|---|---|---|---|
| User stage | @~ | Um usuário, muitas tabelas | Armazenamento pessoal de arquivos |
| Table stage | @%table_name | Muitos usuários, UMA tabela | Vinculado a uma tabela específica |
| Named stage | @stage_name | Muitos usuários, muitas tabelas | Mais flexível, recomendado |

### Regras-chave:
- **User stage** (@~): auto-criado por usuário. Não pode ser alterado ou dropado. Não pode definir file format.
- **Table stage** (@%table): auto-criado por tabela. Não pode ser alterado ou dropado. Sem privilégios concedíveis. Deve ser dono da tabela.
- **Named stage** (CREATE STAGE): objeto de database. Pode definir file format, criptografia. Pode conceder privilégios. Maior controle.

### External stages:
- Apontam para armazenamento cloud: S3, Azure Blob, GCS
- Criados com CREATE STAGE ... URL = 's3://bucket/path'
- Precisam de storage integration OU credenciais
- Podem ser usados independentemente de qual cloud hospeda sua conta Snowflake

### Por Que Isso Importa + Casos de Uso

**Cenário real — "Precisamos dos dados disponíveis dentro de 1 minuto após chegarem no S3"**
COPY INTO executa em um schedule (a cada 15 min). Não é rápido o suficiente. Solução: Snowpipe com auto-ingest. Notificação de evento S3 dispara o Snowpipe, dados disponíveis em ~1 minuto. Serverless, sem warehouse necessário.

**Cenário real — "Comando PUT falha com 'external stage not supported'"**
PUT só funciona com stages INTERNOS. Para external stages (S3, Azure, GCS), faça upload de arquivos diretamente para seu armazenamento cloud usando AWS CLI, Azure CLI, etc. Então use COPY INTO do external stage.

**Cenário real — "Metade das linhas do nosso CSV tem dados ruins e o carregamento falha"**
Use ON_ERROR = CONTINUE para carregar linhas boas e pular as ruins. Ou use VALIDATION_MODE = RETURN_ERRORS primeiro para visualizar o que falharia sem carregar nada.

---

### Melhores Práticas — Stages
- Named stages em vez de table/user stages para produção (mais controle)
- External stages para armazenamento cloud que você já gerencia
- Sempre especifique FILE_FORMAT ao criar um stage

### Upload/download de arquivos:
- **PUT** → upload de arquivos DA máquina local PARA stage interno
- **GET** → download de arquivos DO stage interno PARA máquina local
- PUT/GET só funcionam com SnowSQL ou conectores Snowflake (NÃO Snowsight)
- PUT comprime arquivos automaticamente (gzip por padrão)

**Armadilha do exame**: "Upload de arquivo do laptop para stage?" → Comando PUT via SnowSQL. SE VOCÊ VIR "COPY INTO" para local-para-stage → ERRADO porque COPY INTO carrega stage-para-tabela, não local-para-stage.
**Armadilha do exame**: "Download de arquivo do stage para laptop?" → Comando GET. SE VOCÊ VIR "COPY INTO" para stage-para-local → ERRADO porque COPY INTO descarrega para um stage, não para sua máquina local.
**Armadilha do exame**: "Qual tipo de stage NÃO pode ser alterado?" → User e Table stages. SE VOCÊ VIR "ALTER STAGE @~" ou "ALTER STAGE @%table" → ERRADO porque user/table stages não podem ser alterados ou dropados.
**Armadilha do exame**: "NÃO é um tipo válido de stage?" → Warehouse Stage (não existe). SE VOCÊ VIR "warehouse stage" → armadilha! Apenas User (@~), Table (@%t) e Named (@s) stages existem.


### Exemplos de Perguntas de Cenário — Stages

**Cenário:** A data engineer at a retail company needs to load daily sales CSV files from their laptop into a Snowflake table. They try running `COPY INTO sales_table FROM file:///tmp/sales.csv` but it fails. What is the correct approach?
**Resposta:** Files must first be uploaded to an internal stage using the PUT command via SnowSQL (e.g., `PUT file:///tmp/sales.csv @~`), and then loaded with `COPY INTO sales_table FROM @~`. COPY INTO loads from a stage to a table — it cannot read directly from a local filesystem. PUT is the only way to move files from local to an internal stage, and it only works through SnowSQL or Snowflake connectors (not Snowsight).

**Cenário:** A team has 15 analysts who each need to upload their own data files to Snowflake, but the data all ends up in the same shared table. The DBA wants to control file format and grant access to other roles. Which stage type should they use?
**Resposta:** A named internal stage (CREATE STAGE) is the best choice. Named stages are database objects that support setting file format options, encryption, and grantable privileges — so the DBA can control access via RBAC. User stages (@~) are per-user and cannot have file formats set. Table stages (@%table) cannot be granted to other roles and cannot be altered. Named stages provide the most flexibility for shared, production workloads.

**Cenário:** A company hosts their Snowflake account on Azure but stores raw data files in an AWS S3 bucket. Can they create a stage in Snowflake that points to S3?
**Resposta:** Yes. External stages can point to any supported cloud provider (S3, Azure Blob, GCS) regardless of which cloud hosts the Snowflake account. They would create an external stage with `CREATE STAGE ... URL = 's3://bucket/path'` and use either a storage integration or direct credentials. Cross-cloud stages are fully supported.

---

---

## 3.2 FILE FORMATS

### Formatos suportados para CARREGAMENTO:
- CSV (padrão)
- JSON
- Avro
- ORC
- Parquet
- XML

### NÃO suportados: HTML, PDF, Excel

### Objetos File Format:
- CREATE FILE FORMAT → definição de formato reutilizável
- Pode definir: delimitador, compressão, formato de data, pular cabeçalhos, etc.
- Pode vincular a um stage ou usar inline no COPY INTO

### Compressão:
- Padrão para descarregamento: gzip
- Suportados: gzip, bz2, Brotli, Zstandard, deflate, raw_deflate, none
- Snowflake detecta compressão automaticamente no carregamento

**Armadilha do exame**: "Snowflake pode carregar arquivos Excel?" → NÃO. SE VOCÊ VIR "Excel" + "carregar" ou "COPY INTO" → ERRADO porque apenas CSV, JSON, Avro, ORC, Parquet, XML são suportados.
**Armadilha do exame**: "File format padrão para COPY INTO?" → CSV. SE VOCÊ VIR "JSON" ou "Parquet" como padrão → ERRADO porque CSV é sempre o formato padrão.
**Armadilha do exame**: "Precisa especificar compressão ao carregar?" → NÃO. SE VOCÊ VIR "deve especificar compressão" → ERRADO porque Snowflake detecta compressão automaticamente no carregamento.


### Exemplos de Perguntas de Cenário — File Formats

**Cenário:** A partner sends your team a batch of Excel (.xlsx) files containing inventory data. The data engineer tries to load them directly with COPY INTO but gets an error. What should they do?
**Resposta:** Snowflake does not support loading Excel files. The supported file formats are CSV, JSON, Avro, ORC, Parquet, and XML only. The partner must first convert the Excel files to a supported format (typically CSV) before uploading to a stage and loading with COPY INTO. Tools like Python (pandas) or Excel's "Save As CSV" can handle the conversion.

**Cenário:** A data pipeline sends gzip-compressed JSON files to an S3 bucket. The engineer creating the COPY INTO statement is unsure whether to specify `COMPRESSION = GZIP` in the file format. Is it required?
**Resposta:** No. Snowflake auto-detects compression during loading, so specifying `COMPRESSION = GZIP` is optional. Snowflake will recognize the gzip format automatically and decompress the files. You only need to explicitly set compression if you want to override the auto-detection behavior (e.g., `COMPRESSION = NONE` to skip decompression).

**Cenário:** A team frequently loads CSV files with the same format settings (pipe-delimited, UTF-8, skip 2 header rows) across many different COPY INTO statements. What is the recommended approach to avoid repeating format options every time?
**Resposta:** Create a reusable file format object with `CREATE FILE FORMAT my_csv_format TYPE = CSV FIELD_DELIMITER = '|' SKIP_HEADER = 2 ENCODING = 'UTF8'`. This format can then be referenced in stage definitions or directly in COPY INTO statements with `FILE_FORMAT = my_csv_format`. File format objects are database objects that can be shared across teams via grants and ensure consistency across all load operations.

---

---

## 3.3 COPY INTO (MUITO TESTADO)

### Carregamento: COPY INTO table FROM stage
### Descarregamento: COPY INTO stage FROM table/query

### Comportamento do carregamento:
- Padrão: se QUALQUER erro → carregamento inteiro falha e faz rollback
- Rastreia quais arquivos já foram carregados (previne duplicatas dentro de 64 dias)
- Só carrega arquivos que não foram carregados antes (a menos que FORCE = TRUE)

### Parâmetros-chave:

**ON_ERROR** (o que fazer quando ocorre erro):
- `ABORT_STATEMENT` (padrão) → falha no carregamento inteiro
- `CONTINUE` → pula linhas ruins, carrega o resto
- `SKIP_FILE` → pula arquivos com erros
- `SKIP_FILE_n` → pula arquivo se n+ erros
- `SKIP_FILE_n%` → pula arquivo se n% de erros

**VALIDATION_MODE** (verificar sem carregar):
- `RETURN_ERRORS` → mostra todos os erros
- `RETURN_n_ROWS` → analisa primeiras n linhas
- NÃO carrega dados de fato

**PURGE = TRUE**: deleta arquivos fonte após carregamento bem-sucedido

**FORCE = TRUE**: recarrega arquivos mesmo se já carregados

**MATCH_BY_COLUMN_NAME**: combina colunas fonte com colunas da tabela por nome (não posição)

**ERROR_ON_COLUMN_COUNT_MISMATCH**:
- TRUE (padrão) → erro se contagem de colunas diferir
- FALSE → permite incompatibilidade (colunas extras ignoradas, faltantes = NULL)

### Transformações durante o carregamento:
- Reordenação de colunas
- Omissão de colunas (pular colunas)
- Conversão de tipo
- Truncamento de texto
- Use SELECT no COPY INTO: `COPY INTO table FROM (SELECT $1, $2::date FROM @stage)`

### Colunas METADATA disponíveis durante o carregamento:
- METADATA$FILENAME → nome do arquivo fonte
- METADATA$FILE_ROW_NUMBER → número da linha no arquivo fonte
- METADATA$FILE_CONTENT_KEY → hash do conteúdo
- METADATA$FILE_LAST_MODIFIED → timestamp do arquivo
- METADATA$START_SCAN_TIME → hora de início do scan

### Melhores Práticas — Carregamento de Dados
- Use Snowpipe para carregamento contínuo/tempo real, COPY INTO para batch
- Tamanho ideal de arquivo: 100-250 MB comprimido para paralelismo ótimo
- Use PURGE = TRUE para auto-deletar arquivos do stage após carregamento bem-sucedido
- VALIDATION_MODE antes do primeiro carregamento para detectar problemas de formato
- Warehouses separados para carregamento vs consultas
- Use objetos file format (reutilizáveis) em vez de opções de formato inline

**Armadilha do exame**: "Incluir nome do arquivo na tabela durante carregamento?" → METADATA$FILENAME no SELECT. SE VOCÊ VIR "após carregamento" + "obter nome do arquivo" → ERRADO porque colunas METADATA$ só estão disponíveis DURANTE o COPY INTO, não depois.
**Armadilha do exame**: "Verificar erros sem carregar?" → VALIDATION_MODE. SE VOCÊ VIR "ON_ERROR" para verificação pré-carregamento → ERRADO porque ON_ERROR controla comportamento DURANTE carregamento; VALIDATION_MODE verifica SEM carregar.
**Armadilha do exame**: "Deletar arquivos fonte após carregamento?" → PURGE = TRUE. SE VOCÊ VIR "REMOVE" ou "DROP" para limpeza pós-carregamento → ERRADO porque PURGE = TRUE é o parâmetro do COPY INTO que deleta arquivos fonte.
**Armadilha do exame**: "Compressão padrão de descarregamento?" → gzip. SE VOCÊ VIR "none" ou "descomprimido" como padrão → ERRADO porque gzip é sempre o padrão para descarregamento.


### Exemplos de Perguntas de Cenário — COPY INTO

**Cenário:** A healthcare company loads patient records nightly from CSV files in S3. One night, a file contains 50,000 rows but 200 rows have malformed date fields. The team wants to load the valid rows and investigate the bad ones later. What parameters should they use?
**Resposta:** Use `ON_ERROR = CONTINUE` to skip the bad rows and load the remaining valid rows. After the load completes, use the `VALIDATE(table_name, job_id => '_last')` function to retrieve details about which rows failed and why. The default `ON_ERROR = ABORT_STATEMENT` would reject the entire file, losing all 49,800 good rows.

**Cenário:** A data engineer is loading files from an external stage but notices the same files keep getting loaded every time the COPY INTO runs, creating duplicates. What is happening and how can they fix it?
**Resposta:** COPY INTO tracks loaded files for 64 days to prevent re-loading. If duplicates are occurring, possible causes include: (1) FORCE = TRUE is set, which overrides duplicate detection; (2) the files were modified after the initial load (different content hash); or (3) more than 64 days passed since the last load. Remove FORCE = TRUE if set, and ensure files are not being modified after initial load. The 64-day load metadata window is automatic and cannot be extended.

**Cenário:** Before loading a large batch of 10 million rows from Parquet files for the first time, the team wants to verify the data will parse correctly without actually inserting anything into the target table. How should they proceed?
**Resposta:** Use `VALIDATION_MODE = RETURN_ERRORS` in the COPY INTO statement. This parses all files and returns any errors found without loading a single row. Alternatively, `VALIDATION_MODE = RETURN_n_ROWS` (e.g., RETURN_10_ROWS) parses just the first n rows as a quick sanity check. This is distinct from ON_ERROR, which controls behavior during an actual load — VALIDATION_MODE prevents any data from being loaded at all.

**Cenário:** A logistics company loads shipment data from CSV files but the CSV columns are ordered differently than the target Snowflake table. The CSV has columns: shipment_date, tracking_id, weight — but the table expects: tracking_id, shipment_date, weight. How can they handle this without changing the source files?
**Resposta:** Use a SELECT transformation in the COPY INTO statement to reorder columns: `COPY INTO shipments FROM (SELECT $2, $1, $3 FROM @my_stage) FILE_FORMAT = (TYPE = CSV)`. The $N references correspond to the positional columns in the source file. Alternatively, if the CSV has headers, use `MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE` to match source columns to target columns by name instead of position.

---

---

## 3.4 FUNÇÃO VALIDATE

- VALIDATE(table, job_id) → revisar erros de um COPY INTO anterior
- Mostra quais linhas falharam e por quê
- Use após um carregamento com ON_ERROR = CONTINUE

**Armadilha do exame**: "VALIDATE vs VALIDATION_MODE?" → VALIDATE = após carregamento. VALIDATION_MODE = antes do carregamento. SE VOCÊ VIR "VALIDATE" para verificação pré-carregamento → ERRADO porque VALIDATE revisa erros PASSADOS; VALIDATION_MODE verifica SEM carregar.
**Armadilha do exame**: "VALIDATE(table, job_id) requer qual ON_ERROR?" → CONTINUE. SE VOCÊ VIR "ABORT_STATEMENT" com VALIDATE → ERRADO porque carregamentos abortados não têm linhas puladas para revisar; CONTINUE pula linhas ruins para que VALIDATE possa encontrá-las.


### Exemplos de Perguntas de Cenário — Validate Function

**Cenário:** A data engineer loaded 500 CSV files into a transactions table using `ON_ERROR = CONTINUE`. The load completed but they know some rows were skipped. How can they find out exactly which rows failed and why?
**Resposta:** Use `SELECT * FROM TABLE(VALIDATE(transactions, job_id => '_last'))` to retrieve all rejected rows from the most recent COPY INTO job. The VALIDATE function returns the row data, the error message, and the file/line information for each rejected row. The `_last` shortcut references the most recent load job, or a specific job_id can be provided. This only works when ON_ERROR = CONTINUE was used because ABORT_STATEMENT stops the load entirely, leaving no skipped rows to review.

**Cenário:** A junior engineer runs `VALIDATE(orders, job_id => '_last')` but gets no results, even though they know there were errors in the source files. Their COPY INTO used the default ON_ERROR setting. What went wrong?
**Resposta:** The default ON_ERROR setting is ABORT_STATEMENT, which causes the entire load to fail and roll back on the first error — no rows are loaded and no rows are "skipped." VALIDATE only returns rows that were skipped during a successful load with ON_ERROR = CONTINUE (or SKIP_FILE). Since the load was aborted, there are no skipped rows to review. The engineer should re-run the load with ON_ERROR = CONTINUE, or use VALIDATION_MODE = RETURN_ERRORS to preview errors without loading.

---

---

## 3.5 SNOWPIPE (MUITO TESTADO)

### O que é:
- Carregamento de dados contínuo e automatizado
- Serverless (Snowflake gerencia a computação)
- Carrega arquivos assim que chegam no stage
- Quase tempo real (dentro de minutos)

### Como funciona:
1. Arquivos chegam no stage (S3, Azure, GCS ou interno)
2. Notificação dispara o Snowpipe (notificação de evento cloud OU chamada REST API)
3. Snowpipe carrega os dados usando um COPY INTO definido no pipe
4. Arquivos rastreados para prevenir recarregamento

### Cobrança:
- Cobrança de computação por segundo (serverless)
- Baseada em número de arquivos e computação usada
- NÃO cobrado por créditos de warehouse (sem warehouse necessário)

### Tamanho de arquivo recomendado: 100-250 MB comprimido
- Arquivos menores = mais overhead por arquivo
- Arquivos maiores = mais lento para começar a carregar

### Objetos/funções-chave:
- CREATE PIPE ... AS COPY INTO table FROM @stage
- SYSTEM$PIPE_STATUS(pipe_name) → verificar saúde do pipe
- COPY_HISTORY (INFORMATION_SCHEMA / ACCOUNT_USAGE) → histórico de carregamento
- VALIDATE_PIPE_LOAD() → revisar erros dos últimos 14 dias

### Snowpipe pode carregar de:
- External stages (S3, Azure, GCS)
- Internal stages (sim, Snowpipe funciona com stages internos também)

### Auto-ingest:
- AUTO_INGEST = TRUE na definição do pipe
- Requer notificação de evento cloud (S3 SQS, Azure Event Grid, GCP Pub/Sub)

**Armadilha do exame**: "Modelo de computação do Snowpipe?" → Serverless (gerenciado pelo Snowflake). SE VOCÊ VIR "warehouse" com Snowpipe → armadilha! Snowpipe é SERVERLESS — sem warehouse necessário.
**Armadilha do exame**: "Tamanho de arquivo recomendado para Snowpipe?" → 100-250 MB comprimido. SE VOCÊ VIR "1 GB" ou "10 MB" como recomendado → ERRADO porque 100-250 MB comprimido é o ponto ideal.
**Armadilha do exame**: "Snowpipe pode carregar de stage interno?" → SIM. SE VOCÊ VIR "apenas externo" para Snowpipe → ERRADO porque Snowpipe funciona com AMBOS stages internos e externos.
**Armadilha do exame**: "Verificação de saúde do pipe?" → SYSTEM$PIPE_STATUS. SE VOCÊ VIR "PIPE_USAGE_HISTORY" para verificação de saúde → ERRADO porque SYSTEM$PIPE_STATUS verifica saúde do pipe; PIPE_USAGE_HISTORY mostra cobrança/histórico.
**Armadilha do exame**: "Status STALLED_COMPILATION?" → SQL no pipe é inválido ou incompatibilidade de schema. SE VOCÊ VIR "problema de rede" ou "erro de permissão" para STALLED_COMPILATION → ERRADO porque significa que o SQL do COPY INTO dentro do pipe não compila.


### Exemplos de Perguntas de Cenário — Snowpipe

**Cenário:** An e-commerce company receives order files in an S3 bucket throughout the day and needs them loaded into Snowflake within minutes of arrival. They currently run a scheduled COPY INTO every hour from a warehouse. How should they redesign this for near-real-time loading?
**Resposta:** Replace the scheduled COPY INTO with Snowpipe. Create a pipe with `CREATE PIPE ... AUTO_INGEST = TRUE AS COPY INTO orders FROM @s3_stage`. Configure an S3 event notification (SQS queue) on the bucket to trigger Snowpipe whenever a new file lands. Snowpipe is serverless (no warehouse needed), loads files within minutes of arrival, and bills per-second based on actual compute used — far more efficient than keeping a warehouse running hourly.

**Cenário:** A team sets up Snowpipe and notices their loading costs are higher than expected. They are sending thousands of 1 KB files per minute. What is the likely issue?
**Resposta:** The files are far too small. Snowflake recommends 100-250 MB compressed files for Snowpipe. Each file incurs overhead for scheduling and processing, so thousands of tiny files create excessive per-file overhead. The team should batch or aggregate their source files before landing them in the stage — for example, buffer records and write larger files at intervals. This reduces the number of files Snowpipe processes and significantly lowers costs.

**Cenário:** A data engineer creates a Snowpipe and checks `SYSTEM$PIPE_STATUS('my_pipe')` which returns a status of STALLED_COMPILATION. Files are landing in the stage but nothing is being loaded. What should they investigate?
**Resposta:** STALLED_COMPILATION means the SQL defined inside the pipe (the COPY INTO statement) is invalid or references objects that no longer match. Common causes: the target table was dropped or renamed, a column was removed from the table, the stage was altered, or the file format changed. The engineer should check that the COPY INTO statement in the pipe definition still compiles correctly by verifying the target table schema, stage, and file format all match the pipe's SQL.

---

---

## 3.6 SNOWPIPE STREAMING (NOVO para COF-C03)

### O que é:
- Carregar dados no NÍVEL DE LINHA diretamente no Snowflake (sem arquivos necessários)
- Usa Snowflake SDK ou REST API
- Opção de menor latência (sub-segundo)
- Sem necessidade de arquivos no stage

### Diferença do Snowpipe regular:
| | Snowpipe | Snowpipe Streaming |
|---|---|---|
| Entrada | Arquivos no stage | Linhas via SDK/API |
| Latência | Minutos | Segundos |
| Staging | Necessário | Não necessário |
| Gatilho | Notificação de arquivo | Chamada API |

### Kafka Connector:
- Snowflake Connector for Kafka
- Executa no ambiente Kafka do CLIENTE (Confluent ou auto-hospedado)
- Pode usar Snowpipe Streaming para menor latência
- Lê de tópicos Kafka → escreve em tabelas Snowflake

**Armadilha do exame**: "Snowpipe Streaming precisa de arquivos em um stage?" → ERRADO. SE VOCÊ VIR "stage" + "Snowpipe Streaming" → armadilha! Linhas são enviadas diretamente via SDK/API, SEM staging necessário.
**Armadilha do exame**: "Latência do Snowpipe Streaming?" → Sub-segundo (segundos). SE VOCÊ VIR "minutos" para latência do Streaming → ERRADO porque "minutos" é Snowpipe regular; Streaming = SEGUNDOS.
**Armadilha do exame**: "Kafka connector executa dentro do Snowflake?" → ERRADO. SE VOCÊ VIR "gerenciado pelo Snowflake" + "Kafka connector" → armadilha! Executa no ambiente Kafka do CLIENTE.


### Exemplos de Perguntas de Cenário — Snowpipe Streaming

**Cenário:** A manufacturing company has IoT sensors on their assembly line that emit temperature readings every 100 milliseconds. They need this data in Snowflake with sub-second latency for real-time quality monitoring dashboards. Regular Snowpipe takes minutes. What should they use?
**Resposta:** Snowpipe Streaming is the correct choice. It accepts row-level data directly via the Snowflake Ingest SDK (Java) or REST API — no files or staging required. Data arrives in Snowflake within seconds (sub-second latency), compared to minutes with regular Snowpipe. The application would use the SDK to stream individual sensor readings directly into a Snowflake table without writing intermediate files.

**Cenário:** A company uses Apache Kafka for their event streaming platform and wants to sink Kafka topic data into Snowflake. They want the lowest possible latency. Where does the Kafka connector run, and which ingestion mode should they configure?
**Resposta:** The Snowflake Connector for Kafka runs in the customer's own Kafka environment (e.g., Confluent Cloud, self-hosted Kafka cluster) — not inside Snowflake. To achieve the lowest latency, configure the connector to use Snowpipe Streaming mode instead of the default Snowpipe (file-based) mode. With Snowpipe Streaming, rows from Kafka topics are sent directly to Snowflake tables without staging files, achieving seconds-level latency instead of minutes.

**Cenário:** A developer is evaluating whether to use Snowpipe or Snowpipe Streaming for their data pipeline. Their source system generates one 200 MB CSV file every 5 minutes and drops it in S3. Which option is more appropriate?
**Resposta:** Regular Snowpipe with auto-ingest is the better fit. Snowpipe Streaming is designed for row-level, API-based ingestion where there are no files — it excels when applications emit individual records. Since this pipeline already produces well-sized files (200 MB is within the recommended 100-250 MB range) landing in S3, Snowpipe with S3 event notifications is the natural choice. Snowpipe Streaming would require rewriting the source system to send rows via the SDK instead of writing files.

---

---

## 3.7 STREAMS (Change Data Capture)

### O que são:
- Rastreiam mudanças (INSERT, UPDATE, DELETE) em uma tabela
- "Change Data Capture" (CDC)
- Quando você consulta um stream, vê o que mudou desde a última consumição

### Colunas-chave na saída do stream:
- METADATA$ACTION → INSERT ou DELETE
- METADATA$ISUPDATE → TRUE se é uma atualização (aparece como DELETE + INSERT)
- METADATA$ROW_ID → identificador único da linha

### Tipos de stream:
- **Standard**: rastreia todos os DML (INSERT, UPDATE, DELETE)
- **Append-only**: rastreia apenas INSERTs
- **Insert-only**: para external tables (apenas novas linhas)

### Streams + Tasks = pipeline:
- Stream detecta mudanças
- Task verifica stream (SYSTEM$STREAM_HAS_DATA)
- Se stream tem dados → Task executa e processa mudanças
- Após consumo, stream avança (mudanças são "consumidas")

**Armadilha do exame**: "Task executa apenas quando stream tem dados?" → WHEN SYSTEM$STREAM_HAS_DATA('stream_name') é uma condição ADICIONAL, mas a task ainda precisa de um schedule CRON ou intervalo para definir QUANDO verificar. Ambos trabalham juntos: o schedule define com que frequência verificar, e o WHEN impede a task de executar se não houver dados novos. SE VOCÊ VIR "CRON não é necessário para tasks baseadas em stream" → ERRADO porque a task ainda requer um schedule; o WHEN é uma proteção extra.
**Armadilha do exame**: "Stream em external table?" → Stream insert-only. SE VOCÊ VIR "standard" ou "append-only" para external tables → ERRADO porque external tables só suportam streams INSERT-ONLY.


### Exemplos de Perguntas de Cenário — Streams

**Cenário:** A finance team needs to build an audit trail that captures every change to the `accounts` table — inserts, updates, and deletes — so they can replicate changes to a downstream reporting table. Which stream type should they use, and how do updates appear in the stream?
**Resposta:** Use a Standard stream, which tracks all DML operations (INSERT, UPDATE, DELETE). Updates appear as two rows in the stream: one DELETE row (the old values) and one INSERT row (the new values), both with `METADATA$ISUPDATE = TRUE`. The `METADATA$ACTION` column shows INSERT or DELETE, while `METADATA$ISUPDATE` distinguishes true inserts/deletes from updates. Standard streams are the default type and provide the full CDC picture needed for audit trails.

**Cenário:** A data engineering team has a stream on their `web_events` table, but nobody queried it for 3 weeks. The table's DATA_RETENTION_TIME_IN_DAYS is set to 14 days. When they query the stream, they get a stale stream error. What happened?
**Resposta:** Streams rely on the table's Time Travel retention to track their offset position. Since the stream wasn't consumed within the 14-day retention window, the stream's offset fell outside the available Time Travel data and became STALE. Once stale, the stream cannot recover its change history — the CDC data is lost. To prevent this, either consume streams regularly (within the retention period) or increase the table's DATA_RETENTION_TIME_IN_DAYS to a value longer than the maximum gap between stream consumption.

**Cenário:** A company has an external table pointing to Parquet files in S3. They want to create a stream on it to detect when new files are added. Which stream type is supported?
**Resposta:** Only Insert-only streams are supported on external tables. External tables do not support Standard or Append-only streams. An Insert-only stream will detect new rows that appear when new files are added to the external stage. It cannot track updates or deletes because external tables are read-only views over files in cloud storage — Snowflake has no control over file modifications or deletions at the source.

---

---

## 3.8 TASKS

### O que são:
- Agendam execução SQL
- Podem executar em um schedule (CRON ou intervalo)
- Podem depender de outras tasks (DAG / árvore de tasks)
- Podem ser disparadas por dados de stream

### Árvore de tasks (DAG):
- Root task → child tasks → grandchild tasks
- Root task tem o schedule
- Child tasks executam após parent completar
- Até 1000 tasks em uma árvore

### Opções de computação:
- Warehouse gerenciado pelo usuário (você paga pelo warehouse)
- Serverless tasks (Snowflake gerencia computação, pague por uso)

### Importante: Tasks devem ser RESUMIDAS para executar (começam no estado SUSPENDED)
- ALTER TASK task_name RESUME

**Armadilha do exame**: "Tasks começam no estado RUNNING?" → ERRADO. SE VOCÊ VIR "RUNNING" como estado inicial da task → armadilha! Tasks começam SUSPENDED. Deve ALTER TASK ... RESUME.
**Armadilha do exame**: "Onde fica o schedule em uma árvore de tasks?" → Apenas na ROOT task. SE VOCÊ VIR "schedule" em uma child task → ERRADO porque child tasks disparam APÓS parent completar, apenas a root tem schedule.
**Armadilha do exame**: "Opções de computação de tasks?" → Warehouse gerenciado pelo usuário OU serverless. SE VOCÊ VIR "apenas serverless" ou "apenas warehouse" → ERRADO porque AMBAS as opções são válidas para tasks.


### Exemplos de Perguntas de Cenário — Tasks

**Cenário:** A data engineer creates a task to aggregate daily sales data every night at midnight. They run `CREATE TASK nightly_agg WAREHOUSE = analytics_wh SCHEDULE = 'USING CRON 0 0 * * * America/New_York' AS INSERT INTO daily_summary SELECT ...`. The task is created successfully, but it never runs. What did they forget?
**Resposta:** Tasks are created in a SUSPENDED state by default. The engineer must run `ALTER TASK nightly_agg RESUME` to activate it. This is a common pitfall — until a task is explicitly resumed, it will never execute regardless of the schedule or warehouse configuration. This applies to all tasks, both root tasks and child tasks in a DAG.

**Cenário:** A team builds a data pipeline with a root task that runs every 10 minutes and three child tasks that perform transformations after the root completes. A new requirement comes in to add a fourth child task. Where should the schedule be defined, and what happens if they try to put a schedule on the child task?
**Resposta:** The schedule belongs only on the root task. Child tasks fire automatically after their parent completes — they inherit execution timing from the dependency chain, not from their own schedule. Attempting to set a SCHEDULE on a child task that has an AFTER clause will result in an error. The new fourth child task should be created with `AFTER root_task` (or after another child if there's a dependency) and no SCHEDULE parameter. The DAG supports up to 1,000 tasks.

**Cenário:** A company wants to process CDC changes from a stream only when new data arrives, rather than running a task on a fixed schedule that wastes compute when there are no changes. How should they configure the task?
**Resposta:** Use the `WHEN SYSTEM$STREAM_HAS_DATA('my_stream')` condition on the task. The task still needs a schedule (CRON or interval) that defines how often to check the condition, but the SQL body only executes when the stream actually has unconsumed data. For example: `CREATE TASK process_changes WAREHOUSE = etl_wh SCHEDULE = '5 MINUTE' WHEN SYSTEM$STREAM_HAS_DATA('orders_stream') AS MERGE INTO ...`. This avoids unnecessary warehouse spin-up when the stream is empty.

---

---

## 3.9 DYNAMIC TABLES (NOVO para COF-C03)

### O que são:
- Pipelines de dados declarativos
- Defina uma consulta SQL, defina um "target lag" (frescor)
- Snowflake mantém resultados atualizados automaticamente
- Substitui muitos pipelines de Streams + Tasks

### Target lag:
- Você define quão frescos precisa os dados (ex: 1 minuto, 1 hora)
- Snowflake decide quando atualizar
- Pode ser refresh incremental ou completo (Snowflake escolhe)

### Vantagens sobre Streams+Tasks:
- Mais simples de definir (apenas SQL + lag)
- Agendamento de refresh automático
- Pode encadear dynamic tables (DT lê de DT)

### Disponível em TODAS as edições

**Armadilha do exame**: "Dynamic Tables requerem edição Enterprise?" → ERRADO. SE VOCÊ VIR "Enterprise" ou "Business Critical" como requisito → armadilha! Dynamic Tables estão disponíveis em TODAS as edições.
**Armadilha do exame**: "Dynamic Table vs Streams+Tasks?" → Dynamic Table = declarativo (SQL + target lag). SE VOCÊ VIR "Dynamic Table requer agendamento manual" → ERRADO porque Snowflake gerencia refresh automaticamente; Streams+Tasks é a abordagem manual/imperativa.
**Armadilha do exame**: "Quem decide quando uma Dynamic Table atualiza — você ou o Snowflake?" → Snowflake decide. SE VOCÊ VIR "usuário agenda refresh" → ERRADO porque você define o TARGET LAG e o Snowflake decide quando atualizar.


### Exemplos de Perguntas de Cenário — Dynamic Tables

**Cenário:** A marketing team needs a summary table that joins customer data with purchase history and is never more than 10 minutes stale. They currently maintain this with a stream on the customers table, a stream on the purchases table, and a task that runs a complex MERGE every 5 minutes. The pipeline is brittle and hard to debug. What is a simpler alternative?
**Resposta:** Replace the entire Streams + Tasks pipeline with a single Dynamic Table: `CREATE DYNAMIC TABLE customer_purchase_summary TARGET_LAG = '10 minutes' WAREHOUSE = analytics_wh AS SELECT c.*, p.total_spend FROM customers c JOIN purchases p ON c.id = p.customer_id`. Snowflake automatically determines when to refresh the table to meet the 10-minute target lag. This eliminates the need to manage streams, tasks, MERGE logic, and error handling — just define the SQL and the desired freshness.

**Cenário:** A data architect is building a multi-layer transformation pipeline: raw data → cleaned data → aggregated data. They want each layer to automatically stay fresh. Can Dynamic Tables be chained together?
**Resposta:** Yes. Dynamic Tables can read from other Dynamic Tables, forming a chain. For example: `dt_clean` reads from a raw table, `dt_aggregated` reads from `dt_clean`. Each has its own TARGET_LAG. Snowflake coordinates refresh scheduling across the chain to ensure downstream tables stay within their lag targets. The upstream table refreshes first, then downstream tables refresh when their source changes. This creates a fully declarative, multi-layer pipeline with no manual orchestration.

**Cenário:** A colleague claims Dynamic Tables require Enterprise edition. A team on Standard edition wants to use them. Who is correct?
**Resposta:** The colleague is wrong. Dynamic Tables are available on ALL Snowflake editions, including Standard. There is no edition restriction. The team on Standard edition can create and use Dynamic Tables with the same functionality — define a SQL query, set a target lag, and Snowflake handles the rest.

---

---

## 3.10 CONECTORES E INTEGRAÇÕES

### Conectores Snowflake:
- Python Connector → apps Python conectam ao Snowflake
- JDBC Driver → apps Java
- ODBC Driver → Conectividade geral de database
- Node.js Driver → apps JavaScript
- .NET Driver → apps C#/.NET
- Go Driver → apps Go

### Snowflake CLI (snow):
- Ferramenta de linha de comando
- Execute SQL, gerencie objetos, faça deploy de apps

### SnowSQL:
- Cliente de linha de comando
- Execute SQL
- PUT/GET de arquivos (única forma de upload/download do local)

### Storage Integration:
- Conecte com segurança a armazenamento cloud externo
- Evita armazenar credenciais em definições de stage
- CREATE STORAGE INTEGRATION → defina uma vez, use em múltiplos stages

### API Integration:
- Conecte a APIs externas
- Usado para external functions
- CREATE API INTEGRATION

### Git Integration (NOVO para COF-C03):
- Conecte repositórios Git ao Snowflake
- Armazene código (UDFs, procedures, apps Streamlit) no Git
- CREATE GIT REPOSITORY
- Gerenciamento de código com controle de versão

**Armadilha do exame**: "Storage Integration vs API Integration?" → Storage = armazenamento cloud (S3/Azure/GCS). API = REST APIs externas. SE VOCÊ VIR "API Integration" para acesso S3 → ERRADO porque S3/Azure/GCS usam STORAGE Integration; API Integration é para external functions.
**Armadilha do exame**: "SnowSQL vs Snowflake CLI (snow)?" → Ambos são ferramentas CLI. SE VOCÊ VIR "SnowSQL faz deploy de apps" ou "snow CLI faz PUT/GET" → ERRADO porque SnowSQL = cliente SQL antigo (PUT/GET); snow CLI = mais novo, gerencia objetos + faz deploy de apps.
**Armadilha do exame**: "PUT/GET funcionam na interface web Snowsight?" → ERRADO. SE VOCÊ VIR "Snowsight" + "PUT" ou "GET" → armadilha! PUT/GET só funcionam via SnowSQL ou conectores Snowflake (Python, JDBC, etc.).


### Exemplos de Perguntas de Cenário — Connectors & Integrations

**Cenário:** A company's data pipeline creates external stages pointing to multiple S3 buckets. Currently, each stage definition includes hardcoded AWS access keys and secret keys. The security team flags this as a risk. What is the recommended way to secure these connections?
**Resposta:** Create a Storage Integration with `CREATE STORAGE INTEGRATION` that uses an IAM role-based trust relationship instead of embedded credentials. The integration is defined once and can be referenced by multiple stages. This eliminates hardcoded credentials from stage definitions, centralizes access management, and follows Snowflake's security best practices. The integration establishes trust between Snowflake's IAM identity and the customer's AWS IAM role.

**Cenário:** A DevOps engineer wants to store their Snowflake UDFs and stored procedures in a GitHub repository and deploy them through version-controlled workflows. Does Snowflake support native Git integration?
**Resposta:** Yes. Snowflake supports Git Integration via `CREATE GIT REPOSITORY`, which connects a Git repository (GitHub, GitLab, etc.) directly to Snowflake. This allows teams to store UDFs, stored procedures, and Streamlit app code in Git with full version control. Code can be synced from the repository into Snowflake, enabling CI/CD-style deployments. This is a new feature for the COF-C03 exam and is separate from external tools like dbt.

**Cenário:** A new hire asks whether they should use SnowSQL or the Snowflake CLI (`snow`) to upload local CSV files to a Snowflake stage. Which tool supports PUT/GET?
**Resposta:** SnowSQL is the correct tool for PUT/GET operations. The Snowflake CLI (`snow`) is a newer tool focused on managing Snowflake objects, deploying applications (Streamlit, Native Apps), and executing SQL — but it does not support PUT/GET file transfers. PUT and GET commands work only through SnowSQL or Snowflake language connectors (Python, JDBC, ODBC, etc.). They do not work in the Snowsight web UI either.

---

---

## 3.11 DIRECTORY TABLES

### O que são:
- Catálogo embutido de arquivos em um stage
- Consulte com SQL para ver metadados de arquivos
- Disponível para stages internos e externos
- Fornece: nome do arquivo, tamanho, MD5, última modificação, etc.

### Habilitar no stage:
- CREATE STAGE ... DIRECTORY = (ENABLE = TRUE)
- Deve atualizar: ALTER STAGE ... REFRESH

**Armadilha do exame**: "Directory tables atualizam automaticamente?" → NÃO para external stages. SE VOCÊ VIR "automático" + "atualização de directory table" em external stages → ERRADO porque você deve executar ALTER STAGE ... REFRESH (ou configurar auto-refresh explicitamente).
**Armadilha do exame**: "Directory table vs comando LIST?" → Directory table = consultável com SQL. SE VOCÊ VIR "LIST" para JOIN ou filtragem WHERE → ERRADO porque LIST é uma listagem simples de arquivos; Directory Tables suportam SQL completo (JOIN, WHERE, etc.).


### Exemplos de Perguntas de Cenário — Directory Tables

**Cenário:** A media company stores thousands of image files in an external stage (S3). They want to build a SQL query that joins file metadata (name, size, last modified) with a tracking table to find files that haven't been processed yet. Can they do this with the LIST command?
**Resposta:** No. The LIST command returns a simple file listing that cannot be used in SQL joins, WHERE clauses, or subqueries. Instead, enable a Directory Table on the stage with `ALTER STAGE my_stage SET DIRECTORY = (ENABLE = TRUE)`, then run `ALTER STAGE my_stage REFRESH` to populate it. The directory table can then be queried with full SQL: `SELECT * FROM DIRECTORY(@my_stage) d LEFT JOIN processed_files p ON d.RELATIVE_PATH = p.file_name WHERE p.file_name IS NULL`. Directory tables provide file name, size, MD5, last modified, and other metadata as queryable columns.

**Cenário:** A data engineer enables a directory table on an external stage pointing to GCS. New files land in the bucket daily, but the directory table doesn't show them. What is missing?
**Resposta:** Directory tables on external stages do not auto-refresh by default. The engineer must run `ALTER STAGE my_stage REFRESH` to update the directory table with newly arrived files. This can be automated by configuring auto-refresh with cloud event notifications (similar to Snowpipe auto-ingest), or by scheduling a task to run the refresh command periodically. Without explicit refresh, the directory table only shows files that were present at the time of the last refresh.

---

---

## 3.12 URLs DE ARQUIVO (TESTADO)

### Três tipos de URLs para arquivos em stages:

| Tipo de URL | Duração | Quem pode usar | Função |
|---|---|---|---|
| File URL | Persistente (ID 64-bit) | Usuários Snowflake com acesso | BUILD_STAGE_FILE_URL() |
| Scoped URL | Apenas duração da sessão | Sessão do usuário atual | BUILD_SCOPED_FILE_URL() |
| Pre-signed URL | Expiração configurável | Qualquer pessoa (sem login Snowflake) | GET_PRESIGNED_URL() |

**Armadilha do exame**: "Compartilhar arquivo com parceiro externo (sem conta Snowflake)?" → Pre-signed URL. SE VOCÊ VIR "File URL" ou "Scoped URL" para compartilhamento externo → ERRADO porque esses requerem autenticação Snowflake; Pre-signed URL NÃO precisa de login.
**Armadilha do exame**: "URL válida apenas para sessão atual?" → Scoped URL. SE VOCÊ VIR "Pre-signed URL" como escopo de sessão → ERRADO porque Pre-signed tem expiração configurável; SCOPED URL morre quando a sessão termina.
**Armadilha do exame**: "Acesso persistente a arquivo para usuários Snowflake?" → File URL. SE VOCÊ VIR "Pre-signed URL" para acesso persistente → ERRADO porque Pre-signed URLs expiram; FILE URL é persistente (vinculado a um ID 64-bit).


### Exemplos de Perguntas de Cenário — File URLs

**Cenário:** A consulting firm needs to share a PDF report stored in a Snowflake internal stage with a client who does not have a Snowflake account. The link should expire after 7 days. Which URL type should they use?
**Resposta:** Use a Pre-signed URL generated with `GET_PRESIGNED_URL(@stage, 'report.pdf', 604800)` (604800 seconds = 7 days). Pre-signed URLs are the only URL type that works for users without a Snowflake account — anyone with the link can download the file. The expiry is configurable. File URLs and Scoped URLs both require Snowflake authentication, making them unsuitable for external sharing.

**Cenário:** A Streamlit app in Snowflake displays images stored in a stage. The app needs URLs that work only during the user's active session and cannot be shared or bookmarked for later use. Which URL type is appropriate?
**Resposta:** Use Scoped URLs generated with `BUILD_SCOPED_FILE_URL(@stage, 'image.png')`. Scoped URLs are tied to the current user's session and expire when the session ends. They cannot be shared with other users or reused in a different session. This provides the tightest access control for session-bound use cases like in-app image rendering, where persistent or shareable access is not desired.

**Cenário:** An analytics team builds a dashboard that references report files in a stage. The file links need to work persistently across sessions for any Snowflake user who has access to the stage. Which URL type should they use?
**Resposta:** Use File URLs generated with `BUILD_STAGE_FILE_URL(@stage, 'report.csv')`. File URLs are persistent (they use a 64-bit identifier) and work for any Snowflake user who has the appropriate privileges on the stage. Unlike Scoped URLs (which die with the session) or Pre-signed URLs (which expire), File URLs provide stable, long-lived access — ideal for dashboards, bookmarks, and shared references within the organization.

---

---

## 3.13 CRIPTOGRAFIA DO LADO DO SERVIDOR

### Stages internos:
- Snowflake gerencia criptografia (AES-256)
- Automática, sempre ativa

### External stages:
- Pode usar criptografia do lado do servidor no armazenamento cloud (SSE-S3, SSE-KMS para AWS)
- Configure na definição do stage ou storage integration

**Armadilha do exame**: "Precisa habilitar criptografia para stages internos?" → NÃO. SE VOCÊ VIR "habilitar criptografia" + "stage interno" → ERRADO porque stages internos são SEMPRE criptografados (AES-256) automaticamente — nenhuma ação necessária.
**Armadilha do exame**: "Quem gerencia chaves de criptografia para stages internos?" → Snowflake gerencia. SE VOCÊ VIR "chaves gerenciadas pelo cliente" para stages internos → ERRADO porque Snowflake cuida da criptografia de stages internos; VOCÊ só configura criptografia para EXTERNAL stages.


### Exemplos de Perguntas de Cenário — Server-Side Encryption

**Cenário:** A security auditor asks the data team to confirm that files in Snowflake's internal stages are encrypted at rest. The team hasn't configured any encryption settings. Should they be concerned?
**Resposta:** No. Internal stages are always encrypted with AES-256 encryption, managed entirely by Snowflake. This encryption is automatic and always on — there is no configuration required and no way to disable it. The team does not need to take any action. Snowflake manages the encryption keys for internal stages as part of its built-in security model.

**Cenário:** A company stores sensitive financial data in an S3 bucket used as an external stage. Their compliance team requires that all data at rest in S3 is encrypted with AWS KMS customer-managed keys (SSE-KMS). How should they configure encryption for the external stage?
**Resposta:** Configure server-side encryption in the external stage definition or storage integration by specifying the encryption type and KMS key. For example, in the stage definition: `CREATE STAGE my_s3_stage URL = 's3://bucket/path' ... ENCRYPTION = (TYPE = 'AWS_SSE_KMS' KMS_KEY_ID = 'aws/key')`. This ensures files written to S3 during unloading are encrypted with the specified KMS key. For loading, the files must already be encrypted at the source — Snowflake can read SSE-S3 and SSE-KMS encrypted files when proper IAM permissions are configured via a storage integration.

---

---

## 3.14 DESCARREGAMENTO DE DADOS

### COPY INTO @stage FROM table/query:
- Exporta dados para arquivos em um stage
- Compressão padrão: gzip
- Formato padrão: CSV
- Pode descarregar para: stages internos, external stages (S3, Azure, GCS)
- Suporta: CSV, JSON, Parquet
- Pode particionar arquivos de saída: PARTITION BY expressão

### Opções-chave de descarregamento:
- SINGLE = TRUE → um arquivo de saída
- MAX_FILE_SIZE → controlar tamanho do arquivo
- HEADER = TRUE → incluir cabeçalhos de coluna
- OVERWRITE = TRUE → sobrescrever arquivos existentes

**Armadilha do exame**: "Descarregamento suporta Avro/ORC/XML?" → ERRADO. SE VOCÊ VIR "Avro", "ORC" ou "XML" para descarregamento → armadilha! Descarregamento APENAS suporta CSV, JSON, Parquet. Todos os 6 formatos são apenas para CARREGAMENTO.
**Armadilha do exame**: "Comportamento padrão de descarregamento — um arquivo ou muitos?" → Muitos arquivos (divididos). SE VOCÊ VIR "arquivo único" como padrão → ERRADO porque o padrão divide em múltiplos arquivos; use SINGLE = TRUE para um arquivo.
**Armadilha do exame**: "COPY INTO @stage = carregamento ou descarregamento?" → DESCARREGAMENTO (exportação). SE VOCÊ VIR "COPY INTO @stage" descrito como carregamento → ERRADO porque @stage como DESTINO = descarregamento; COPY INTO table = carregamento.


### Exemplos de Perguntas de Cenário — Unloading Data

**Cenário:** A data team needs to export query results to Parquet files in an S3 bucket, partitioned by year and month, for consumption by a Spark cluster. They also want column headers included. How should they configure the COPY INTO?
**Resposta:** Use `COPY INTO @s3_stage/export/ FROM (SELECT * FROM analytics_table) FILE_FORMAT = (TYPE = PARQUET) PARTITION BY ('year=' || YEAR(order_date) || '/month=' || MONTH(order_date)) HEADER = TRUE`. This exports data as Parquet files (one of three supported unload formats: CSV, JSON, Parquet), partitioned into S3 prefixes by year/month for efficient Spark reads. Default compression is gzip. Note that Avro, ORC, and XML are supported for loading only — not for unloading.

**Cenário:** A downstream system requires exactly one output file (not split across multiple files) when receiving data exports from Snowflake. The default COPY INTO unload produces many small files. How can the engineer produce a single file?
**Resposta:** Set `SINGLE = TRUE` in the COPY INTO statement: `COPY INTO @my_stage/export.csv FROM my_table FILE_FORMAT = (TYPE = CSV) SINGLE = TRUE`. By default, Snowflake splits unloaded data into multiple files for parallelism. SINGLE = TRUE forces all output into one file. For large datasets, also consider setting `MAX_FILE_SIZE` to ensure the single file isn't too large for the downstream system. Note that single-file unloads may be slower since they cannot parallelize the write.

**Cenário:** A company unloads customer data to an internal stage weekly for backup purposes. Each week's export overwrites the previous one. They notice the old files still exist alongside new ones. What parameter controls this behavior?
**Resposta:** Use `OVERWRITE = TRUE` in the COPY INTO statement to replace existing files in the stage. Without OVERWRITE = TRUE, Snowflake writes new files alongside existing ones (it does not automatically delete previous exports). Alternatively, the team can manually remove old files with `REMOVE @stage/path/` before each unload, but OVERWRITE = TRUE is the cleaner approach for recurring export workflows.

---

---

## REVISÃO RÁPIDA — Domínio 3

1. Três stages internos: User @~, Table @%t, Named @s
2. PUT = upload local→stage. GET = download stage→local. Ambos precisam do SnowSQL.
3. External stages = S3, Azure, GCS
4. COPY INTO = carregamento em massa. Comportamento de erro padrão = ABORTAR carregamento inteiro.
5. VALIDATION_MODE = verificar erros sem carregar
6. PURGE = TRUE deleta arquivos fonte após carregamento
7. METADATA$FILENAME = obter nome do arquivo fonte durante carregamento
8. Snowpipe = serverless, contínuo, quase tempo real (minutos)
9. Snowpipe Streaming = nível de linha, sub-segundo, sem arquivos necessários
10. Tamanho de arquivo recomendado: 100-250 MB comprimido
11. Streams = CDC (rastreamento de INSERT, UPDATE, DELETE)
12. Tasks = execução SQL agendada (CRON ou intervalo)
13. Streams + Tasks = pipeline clássico. Dynamic Tables = substituto moderno.
14. Dynamic Tables = consulta SQL + target lag, refresh automático
15. Storage Integration = conexão segura com armazenamento cloud (sem credenciais embutidas)
16. Git Integration = código com controle de versão no Snowflake (NOVO)
17. Directory Tables = catálogo de arquivos para stages
18. Pre-signed URL = compartilhar com qualquer pessoa (sem conta Snowflake necessária)
19. Scoped URL = acesso apenas na sessão
20. File URL = acesso persistente para usuários Snowflake
21. Kafka connector executa no ambiente do CLIENTE
22. Formatos suportados: CSV, JSON, Avro, ORC, Parquet, XML. NÃO: HTML, Excel, PDF
23. Padrão de descarregamento: compressão gzip, formato CSV
24. Função VALIDATE() → revisar erros de carregamento anterior

---

## PARES CONFUSOS — Domínio 3

| Eles perguntam sobre... | A resposta é... | NÃO... |
|---|---|---|
| Upload de arquivo local para stage | PUT (via SnowSQL) | COPY INTO |
| Carregar dados do stage para tabela | COPY INTO | PUT |
| Download de arquivo do stage para local | GET | COPY INTO |
| Descarregar tabela para stage | COPY INTO @stage FROM table | GET |
| Computação do Snowpipe | Serverless (gerenciado pelo Snowflake) | Baseado em warehouse |
| Gatilho do Snowpipe | Notificação de evento cloud ou REST API | Schedule manual |
| Entrada do Snowpipe Streaming | Linhas via SDK/API | Arquivos |
| Tipo de stream para external table | Insert-only | Standard |
| Task começa no estado | SUSPENDED (deve RESUME) | RUNNING |
| Dynamic Table vs Streams+Tasks | Target lag (declarativo) | Agendamento manual |
| Pre-signed URL | Qualquer pessoa, temporário | Apenas usuários Snowflake |
| Scoped URL | Apenas sessão atual | Persistente |
| File URL | Persistente, usuários Snowflake | Acesso externo |
| Padrão do ON_ERROR | ABORT_STATEMENT | CONTINUE |
| FORCE = TRUE | Recarregar arquivos já carregados | Comportamento normal de carga |
| Kafka connector executa onde | Ambiente do cliente | Cloud Snowflake |
| Storage Integration | Acesso cloud seguro, sem credenciais no stage | Stage com credenciais embutidas |

---

## RESUMO AMIGÁVEL — Domínio 3

### ÁRVORES DE DECISÃO POR CENÁRIO
Quando você ler uma questão, encontre o padrão:

**"O engenheiro de dados de um cliente precisa fazer upload de arquivos CSV do laptop para o Snowflake..."**
→ Passo 1: PUT arquivo para stage (via SnowSQL)
→ Passo 2: COPY INTO table FROM stage
→ NÃO apenas "COPY INTO" sozinho (arquivos devem ser colocados no stage primeiro)

**"Uma empresa de varejo quer que dados carreguem automaticamente sempre que novos arquivos de vendas chegam no bucket S3..."**
→ Snowpipe com AUTO_INGEST = TRUE + notificação de evento S3 (SQS)
→ NÃO Tasks agendadas (Snowpipe é orientado a eventos, não polling)

**"Sensores IoT da frota de logística de uma empresa enviam registros GPS individuais a cada segundo..."**
→ Snowpipe Streaming (nível de linha, sub-segundo, sem arquivos necessários)
→ NÃO Snowpipe regular (esse precisa de arquivos chegarem primeiro)

**"Uma equipe de marketing quer uma tabela resumo de dashboard que nunca fique mais de 10 minutos desatualizada..."**
→ Dynamic Table com TARGET_LAG = '10 minutes'
→ NÃO Streams + Tasks (funciona, mas Dynamic Table é mais simples para isso)

**"Uma equipe de finanças precisa saber exatamente quais transações foram inseridas, atualizadas ou deletadas desde ontem..."**
→ Stream (Change Data Capture) — tipo Standard
→ METADATA$ACTION diz INSERT vs DELETE, METADATA$ISUPDATE diz se foi UPDATE

**"Um pipeline de dados deve processar dados novos apenas quando realmente chegam, não em schedule fixo..."**
→ Task com WHEN SYSTEM$STREAM_HAS_DATA('stream_name')
→ Combinação Stream + Task

**"Uma consultoria precisa compartilhar um arquivo de relatório com um cliente que não tem Snowflake..."**
→ Pre-signed URL (GET_PRESIGNED_URL) — qualquer pessoa pode usar, sem login
→ NÃO File URL (requer login Snowflake)
→ NÃO Scoped URL (apenas sessão atual)

**"Antes de carregar 50 milhões de linhas, a equipe quer visualizar quaisquer erros primeiro..."**
→ VALIDATION_MODE = RETURN_ERRORS (verifica sem carregar de fato)
→ NÃO ON_ERROR (isso é o que acontece DURANTE o carregamento real)

**"Após carregar, o analista quer saber de qual arquivo fonte cada linha veio..."**
→ METADATA$FILENAME na cláusula SELECT do COPY INTO
→ Deve ser feito DURANTE o carregamento, não depois

**"Uma empresa de e-commerce transmite eventos do Kafka para o Snowflake..."**
→ Kafka Connector (executa no ambiente Kafka do CLIENTE, não no Snowflake)
→ Pode usar modo Snowpipe Streaming para menor latência

**"Um engenheiro de dados acidentalmente carregou os mesmos arquivos duas vezes..."**
→ COPY INTO rastreia arquivos carregados por 64 dias (previne duplicatas automaticamente)
→ A menos que FORCE = TRUE tenha sido usado (isso sobrescreve a verificação de duplicatas)

**"Uma equipe quer limpar arquivos fonte do S3 após carregamento bem-sucedido..."**
→ PURGE = TRUE no COPY INTO
→ Deleta arquivos fonte apenas após carregamento bem-sucedido

**"Um cliente pergunta: posso fazer upload de arquivos pela interface web Snowsight?"**
→ PUT/GET NÃO funcionam no Snowsight
→ Deve usar SnowSQL CLI ou conectores Snowflake

**"Uma equipe de analytics quer armazenar seus modelos dbt e código UDF com controle de versão..."**
→ Git Integration (CREATE GIT REPOSITORY — conecta GitHub/GitLab ao Snowflake)
→ Este é recurso nativo do Snowflake, separado do dbt em si

**"Um cliente carrega um CSV mas as colunas estão na ordem errada comparada à tabela..."**
→ Use SELECT com reordenação de colunas no COPY INTO: COPY INTO table FROM (SELECT $3, $1, $2 FROM @stage)
→ Ou use MATCH_BY_COLUMN_NAME para combinar por nomes de cabeçalho

**"Um cliente carrega dados e algumas linhas têm mais colunas que a tabela destino..."**
→ ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE (colunas extras ignoradas, faltantes = NULL)
→ Padrão é TRUE (vai dar erro)

**"Uma equipe de dados quer descarregar resultados de consulta para arquivos Parquet no S3..."**
→ COPY INTO @external_stage FROM (SELECT ...) FILE_FORMAT = (TYPE = PARQUET)
→ Compressão padrão de descarregamento = gzip. Suporta CSV, JSON, Parquet para descarregamento.

**"Um cliente quer UM arquivo grande de saída ao descarregar..."**
→ SINGLE = TRUE no COPY INTO
→ Comportamento padrão divide em múltiplos arquivos

**"O Snowpipe de um cliente mostra status STALLED_COMPILATION..."**
→ O SQL na definição do pipe é inválido ou há incompatibilidade de schema
→ Correção: verifique a instrução COPY INTO no pipe, confirme que tabela/stage ainda correspondem

**"Um cliente carrega dados JSON no Snowflake. Qual tipo de coluna deve usar?"**
→ VARIANT (contêiner semi-estruturado)
→ Pode também usar OBJECT ou ARRAY dependendo da estrutura JSON

**"Um cliente quer ver todos os arquivos em um stage e seus metadados..."**
→ Directory Table (ENABLE no stage, depois consulte com SQL)
→ Mostra: nome do arquivo, tamanho, MD5, última modificação

**"Um cliente precisa conectar com segurança seu stage ao S3 sem embutir chaves AWS na definição do stage..."**
→ Storage Integration (CREATE STORAGE INTEGRATION)
→ Defina uma vez, reutilize em múltiplos stages. Sem credenciais expostas.

**"Uma árvore de tasks tem uma root task e 3 child tasks. Onde fica o schedule?"**
→ Apenas a ROOT task tem o schedule
→ Child tasks executam APÓS parent completar (baseado em dependência, sem schedule independente)

**"Um stream foi criado em uma tabela. Ninguém o consultou por 2 semanas. Os dados ainda estão lá?"**
→ SIM, desde que o offset do stream esteja dentro da retenção de Time Travel da tabela
→ Se a retenção expirar e o stream não foi consumido → stream fica STALE (dados perdidos)

---

### MNEMÔNICOS PARA MEMORIZAR

**Tipos de stage = "U-T-N" → "U Turn Now"**
- **U**ser @~ → armário pessoal, auto-criado, não pode alterar
- **T**able @%t → vinculado a uma tabela, auto-criado, não pode alterar
- **N**amed @s → o flexível, CREATE STAGE, recomendado para produção

**Fluxo de carregamento = "P-C-V" → "Put, Copy, Validate"**
- **P**UT → arquivos do laptop para stage
- **C**OPY INTO → stage para tabela
- **V**ALIDATE → verificar o que deu errado depois

**Opções ON_ERROR = "A-C-S" → "Abort, Continue, Skip"**
- **A**BORT_STATEMENT = para tudo (PADRÃO)
- **C**ONTINUE = pula linhas ruins, carrega o resto
- **S**KIP_FILE = pula arquivos inteiros com erros

**Evolução de pipelines = "Antigo vs Novo"**
- Jeito ANTIGO: Streams + Tasks (mais controle, mais código)
- Jeito NOVO: Dynamic Tables (apenas SQL + target lag)
- Ambos são válidos. Dynamic Tables = menos encanamento.

**Três URLs = "F-S-P" → "Forever, Session, Public"**
- **F**ile URL → acesso permanente, apenas usuários Snowflake
- **S**coped URL → apenas sessão, morre quando você sai
- **P**re-signed URL → temporário, qualquer pessoa pode usar (sem conta Snowflake necessária)

**Snowpipe vs Streaming = "Arquivos vs Linhas"**
- Snowpipe = arquivos chegam → carregados em MINUTOS
- Streaming = linhas enviadas via API → carregadas em SEGUNDOS

**File formats = "CAJ-OPX"** (CSV, Avro, JSON, ORC, Parquet, XML)
- NÃO suportados: HTML, Excel, PDF
- Formato padrão de carregamento: CSV
- Compressão padrão de descarregamento: gzip

---

### PRINCIPAIS ARMADILHAS — Domínio 3

1. **"PUT funciona no Snowsight"** → ERRADO. PUT/GET apenas via SnowSQL ou conectores.
2. **"Snowpipe usa um warehouse"** → ERRADO. Serverless (computação gerenciada pelo Snowflake).
3. **"Snowpipe Streaming precisa de arquivos no stage"** → ERRADO. Nível de linha via SDK/API, sem arquivos.
4. **"Tasks começam no estado RUNNING"** → ERRADO. Começam SUSPENDED. Deve ALTER TASK ... RESUME.
5. **"Dynamic Tables requerem edição Enterprise"** → ERRADO. TODAS as edições.
6. **"Padrão do ON_ERROR é CONTINUE"** → ERRADO. Padrão = ABORT_STATEMENT (falha em tudo).
7. **"Kafka connector executa dentro do Snowflake"** → ERRADO. Executa no ambiente do CLIENTE.
8. **"User stage pode ser alterado ou dropado"** → ERRADO. Não pode alterar ou dropar user/table stages.
9. **"Pre-signed URL requer login Snowflake"** → ERRADO. Qualquer pessoa pode usar (esse é o ponto).
10. **"COPY INTO sempre recarrega arquivos"** → ERRADO. Rastreia arquivos carregados por 64 dias. Use FORCE=TRUE para sobrescrever.

---

### ATALHOS DE PADRÃO — "Se você vir ___, a resposta é ___"

| Se a questão menciona... | A resposta quase sempre é... |
|---|---|
| "upload da máquina local" | Comando PUT (via SnowSQL) |
| "download para máquina local" | Comando GET |
| "carregamento em massa do stage" | COPY INTO |
| "carregamento contínuo", "auto-ingest" | Snowpipe |
| "ingestão de linhas em tempo real", "sub-segundo" | Snowpipe Streaming |
| "100-250 MB comprimido" | Tamanho de arquivo recomendado para Snowpipe |
| "rastrear mudanças", "CDC" | Stream |
| "SYSTEM$STREAM_HAS_DATA" | Padrão Stream + Task |
| "target lag", "pipeline declarativo" | Dynamic Table |
| "agendar SQL", "CRON" | Task |
| "nome do arquivo fonte nos dados carregados" | METADATA$FILENAME |
| "verificar erros sem carregar" | VALIDATION_MODE |
| "deletar arquivos fonte após carregamento" | PURGE = TRUE |
| "recarregar arquivos já carregados" | FORCE = TRUE |
| "compartilhar arquivo com não-usuário Snowflake" | Pre-signed URL |
| "acesso a arquivo apenas na sessão" | Scoped URL |
| "acesso persistente a arquivo, usuários SF" | File URL |
| "conexão segura com armazenamento cloud" | Storage Integration |
| "controle de versão no Snowflake" | Git Integration (CREATE GIT REPOSITORY) |
| "catálogo de arquivos no stage" | Directory Table |
| @~ | User stage |
| @%table_name | Table stage |
| @stage_name | Named stage |
| "Kafka para Snowflake" | Kafka Connector (executa no ambiente do cliente) |
| "stream INSERT-only" | External tables |
| "stream Append-only" | Rastreia apenas INSERTs (não updates/deletes) |

---

## DICAS PARA O DIA DO EXAME — Domínio 3 (18% = ~18 questões)

**Antes de estudar este domínio:**
- Flashcard dos 3 tipos de stage (@~, @%t, @s) e o que cada um pode/não pode fazer
- Flashcard Snowpipe vs Snowpipe Streaming (arquivos vs linhas, minutos vs segundos)
- Conheça os parâmetros do COPY INTO: ON_ERROR, VALIDATION_MODE, PURGE, FORCE
- Conheça os 3 tipos de URL (File, Scoped, Pre-signed) — quem pode usar cada

**Durante o exame — questões do Domínio 3:**
- Leia a ÚLTIMA sentença primeiro — depois leia o cenário
- Elimine 2 respostas obviamente erradas imediatamente
- Se dizem "carregamento contínuo" → Snowpipe. Se "nível de linha, sub-segundo" → Snowpipe Streaming.
- Se dizem "target lag" ou "declarativo" → Dynamic Table
- Se dizem "rastrear mudanças" ou "CDC" → Stream
- Se mencionam um STAGE → verifique o símbolo: @~ = user, @% = table, @nome = named
- Se perguntam "quem pode acessar este arquivo?" → File URL (usuários SF), Scoped (sessão), Pre-signed (qualquer pessoa)

---

## UMA LINHA POR TÓPICO — Domínio 3

| Tópico | Resumo em uma linha |
|---|---|
| User stage @~ | Pessoal, auto-criado, não pode alterar/dropar, não pode definir file format. |
| Table stage @%t | Por tabela, auto-criado, não pode alterar/dropar, deve ser dono da tabela. |
| Named stage @s | CREATE STAGE, mais flexível, pode definir file format + criptografia, recomendado. |
| External stages | Apontam para S3/Azure/GCS, precisam de storage integration ou credenciais. |
| Comando PUT | Upload arquivos locais → stage interno. Apenas SnowSQL/conectores. Auto-comprime. |
| Comando GET | Download arquivos do stage → máquina local. Apenas SnowSQL/conectores. |
| File formats | CSV (padrão), JSON, Avro, ORC, Parquet, XML. NÃO: HTML, Excel, PDF. |
| COPY INTO (carregar) | Carregamento em massa stage → tabela. Rastreia arquivos por 64 dias. Padrão ON_ERROR = ABORT. |
| COPY INTO (descarregar) | Exportar tabela → stage. Padrão: compressão gzip, formato CSV. |
| ON_ERROR | ABORT (padrão), CONTINUE (pula linhas ruins), SKIP_FILE (pula arquivos ruins). |
| VALIDATION_MODE | Verificar erros SEM carregar. RETURN_ERRORS ou RETURN_n_ROWS. |
| PURGE = TRUE | Deletar arquivos fonte após carregamento bem-sucedido. |
| FORCE = TRUE | Recarregar arquivos mesmo se já carregados (sobrescreve rastreamento de 64 dias). |
| MATCH_BY_COLUMN_NAME | Combinar colunas fonte com colunas da tabela por nome, não posição. |
| Colunas METADATA$ | FILENAME, FILE_ROW_NUMBER, FILE_CONTENT_KEY, FILE_LAST_MODIFIED, START_SCAN_TIME. |
| Função VALIDATE | Revisar erros de um COPY INTO anterior (após ON_ERROR = CONTINUE). |
| Snowpipe | Contínuo, serverless, auto-ingest por eventos cloud. Latência em minutos. Arquivos 100-250MB. |
| Snowpipe Streaming | Nível de linha via SDK/API, latência sub-segundo, sem arquivos necessários. |
| Kafka Connector | Executa no ambiente do CLIENTE, lê tópicos → escreve em tabelas SF. |
| Streams (CDC) | Rastreia INSERT/UPDATE/DELETE. Tipos Standard, Append-only, Insert-only. |
| Tasks | SQL agendado (CRON/intervalo). Começa SUSPENDED. Árvores de tasks até 1000. |
| Dynamic Tables | SQL + target lag = pipeline auto-atualizável. Substitui Streams+Tasks. TODAS as edições. |
| Storage Integration | Conexão segura com armazenamento cloud sem credenciais embutidas. |
| Git Integration | CREATE GIT REPOSITORY, código com controle de versão no Snowflake. Tópico NOVO. |
| Directory Tables | Catálogo de arquivos para stages. Consulte metadados de arquivo com SQL. |
| File URL | Persistente, apenas usuários Snowflake. BUILD_STAGE_FILE_URL(). |
| Scoped URL | Apenas sessão, usuário atual. BUILD_SCOPED_FILE_URL(). |
| Pre-signed URL | Expiração configurável, qualquer pessoa (sem conta SF). GET_PRESIGNED_URL(). |

---

## FLASHCARDS — Domínio 3

**P:** Quais são os 4 tipos de stage?
**R:** User stage (@~), Table stage (@%table_name), Named internal stage (@my_stage), Named external stage (@my_ext_stage apontando para S3/Azure/GCS).

**P:** Em quais stages você pode usar PUT?
**R:** Apenas stages INTERNOS (user, table, named interno). Para external stages, faça upload de arquivos diretamente para armazenamento cloud.

**P:** COPY INTO vs Snowpipe?
**R:** COPY INTO = carregamento batch em massa, precisa de warehouse. Snowpipe = micro-batch contínuo, serverless (computação Cloud Services), orientado a eventos.

**P:** Como o Snowpipe é disparado?
**R:** Notificações de eventos (SQS para AWS, Event Grid para Azure, Pub/Sub para GCP) ou chamadas REST API. Auto-escala, cobrado por arquivo.

**P:** Qual computação o Snowpipe usa?
**R:** Computação Cloud Services — NÃO um warehouse. Esta é uma armadilha comum do exame.

**P:** Quais file formats o Snowflake suporta?
**R:** CSV, Avro, JSON, ORC, Parquet, XML. Mnemônico: CAJ-OPX.

**P:** O que VALIDATION_MODE faz?
**R:** Verifica/valida dados SEM realmente carregar. Opções: RETURN_ERRORS, RETURN_N_ROWS, RETURN_ALL_ERRORS.

**P:** O que é a função VALIDATE?
**R:** Chamada APÓS um COPY INTO para recuperar erros do último carregamento. Uso: VALIDATE(table, job_id => '_last').

**P:** O que ON_ERROR faz no COPY INTO?
**R:** Controla comportamento de erro: CONTINUE (pula linhas ruins), SKIP_FILE, SKIP_FILE_n (pula se n+ erros), ABORT_STATEMENT (padrão — para no primeiro erro).

**P:** O que é um stream?
**R:** Um objeto de Change Data Capture (CDC) que rastreia INSERT, UPDATE, DELETE em uma tabela. Colunas: METADATA$ACTION, METADATA$ISUPDATE, METADATA$ROW_ID.

**P:** Stream standard vs stream append-only?
**R:** Standard: rastreia inserts, updates, deletes. Append-only: rastreia APENAS inserts. Use append-only para external tables e quando não precisa rastrear update/delete.

**P:** O que é uma task?
**R:** Uma instrução SQL agendada. Pode formar DAGs (grafos acíclicos dirigidos) com predecessor tasks. Suporta agendamento CRON ou intervalo. Precisa de warehouse (ou serverless).

**P:** O que é uma Dynamic Table?
**R:** Pipeline declarativo — você define uma consulta + target lag, e o Snowflake mantém automaticamente atualizado. Substitui tasks+streams para muitos casos de uso. Novo para COF-C03.

**P:** O que é Snowpipe Streaming?
**R:** Streaming de baixa latência via Snowflake Ingest SDK (Java). Linhas são escritas diretamente em tabelas sem arquivos no stage. Mais rápido que Snowpipe regular. Novo para COF-C03.

**P:** O que é uma directory table?
**R:** Uma tabela somente leitura sobre um stage que cataloga arquivos. Mostra nome do arquivo, tamanho, MD5, última modificação. Habilite com DIRECTORY = (ENABLE = TRUE).

**P:** Quais são os 3 tipos de URLs de arquivo?
**R:** File URL (persistente, apenas usuários SF, BUILD_STAGE_FILE_URL), Scoped URL (apenas sessão, usuário atual, BUILD_SCOPED_FILE_URL), Pre-signed URL (expiração configurável, qualquer pessoa, GET_PRESIGNED_URL).

**P:** O que PURGE = TRUE faz no COPY INTO?
**R:** Automaticamente deleta arquivos do stage após serem carregados com sucesso.

**P:** Como o COPY INTO rastreia arquivos carregados?
**R:** Mantém metadados de carregamento por 64 dias. Não recarrega o mesmo arquivo dentro de 64 dias a menos que você use FORCE = TRUE.

**P:** Qual a diferença entre COPY INTO table e COPY INTO location?
**R:** COPY INTO table = carregando dados PARA DENTRO. COPY INTO location = descarregando dados PARA FORA (para um stage ou armazenamento externo).

**P:** O que o comando GET faz?
**R:** Faz download de arquivos DE um stage interno para o sistema de arquivos local. Oposto do PUT.

---

## EXPLIQUE COMO SE EU TIVESSE 5 ANOS — Domínio 3

**Stage**: Um estacionamento onde seus arquivos de dados ficam antes de serem carregados nas tabelas do Snowflake.

**User stage (@~)**: Sua vaga pessoal de estacionamento que só você pode usar.

**Table stage (@%table)**: Um estacionamento vinculado a uma tabela específica — qualquer pessoa com acesso à tabela pode usar.

**Named stage**: Um estacionamento compartilhado que você cria e dá um nome, com regras sobre quem pode estacionar lá.

**PUT**: Fazer upload de arquivos do seu computador para o estacionamento do Snowflake. Só funciona para estacionamentos próprios do Snowflake (stages internos).

**COPY INTO**: O caminhão de mudança que pega dados do estacionamento e coloca na tabela. Você diz qual caminhão (warehouse) usar.

**Snowpipe**: Um robô que vigia o estacionamento e automaticamente move novos arquivos para a tabela assim que chegam. Sem caminhão necessário — ele usa seus próprios bracinhos robóticos.

**Snowpipe Streaming**: Em vez de estacionar arquivos primeiro, você entrega dados diretamente ao robô linha por linha. Ainda mais rápido.

**File format**: Instruções para o caminhão de mudança sobre como os arquivos estão organizados — como "este é um CSV com vírgulas" ou "este é JSON."

**VALIDATION_MODE**: Verificar se os dados parecem certos sem realmente carregar — como inspecionar caixas antes de movê-las para dentro de casa.

**Stream**: Uma câmera de segurança em uma tabela que grava cada mudança (quem foi adicionado, removido ou atualizado).

**Task**: Um despertador que executa um comando SQL em horários agendados. Você pode encadeá-los como dominós.

**Dynamic table**: Uma tabela inteligente que se mantém atualizada automaticamente. Você diz quais dados quer e quão frescos devem estar.

**Directory table**: Uma lista de todos os arquivos em um estacionamento (stage), mostrando nomes, tamanhos e quando chegaram.

**ON_ERROR**: O que o caminhão de mudança faz quando encontra uma caixa quebrada — para tudo? Pula a caixa? Pula o arquivo inteiro?

**PURGE**: Jogar fora os arquivos do estacionamento depois que foram movidos com segurança para a tabela.

**GET**: Pegar arquivos de volta do estacionamento do Snowflake e baixá-los para seu computador.

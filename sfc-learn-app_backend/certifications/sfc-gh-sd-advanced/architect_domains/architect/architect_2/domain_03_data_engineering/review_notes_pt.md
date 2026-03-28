# Domínio 3: Engenharia de Dados

> **Cobertura do Programa ARA-C01:** Carregamento/Descarregamento de Dados, Transformação de Dados, Ferramentas do Ecossistema

---

## 3.1 CARREGAMENTO DE DADOS

**COPY INTO (Carregamento em Massa)**

- Comando principal para carregamento batch/em massa de stages para tabelas
- Suporta: CSV, JSON, Avro, Parquet, ORC, XML
- Opções-chave: `ON_ERROR`, `PURGE`, `FORCE`, `MATCH_BY_COLUMN_NAME`
- `VALIDATION_MODE` — execução simulada para verificar dados sem carregar
- Retorna metadados: linhas carregadas, erros, nomes de arquivos
- Melhor para: cargas batch agendadas, migração inicial de dados, arquivos grandes

**Snowpipe (Carregamento Contínuo)**

- Pipeline serverless, auto-ingest disparado por eventos de nuvem (notificações S3, GCS Pub/Sub, Azure Event Grid)
- Quase tempo real (micro-batch, tipicamente segundos a minutos de latência)
- Usa um objeto PIPE: `CREATE PIPE ... AUTO_INGEST = TRUE AS COPY INTO ...`
- Cobrado por segundo de computação serverless + overhead de notificação de arquivo
- Semântica exactly-once via metadados de carregamento de arquivo (janela de dedup de 14 dias)

**Snowpipe Streaming**

- Opção de menor latência: linhas chegam em segundos, sem arquivos envolvidos
- Usa o Snowflake Ingest SDK (Java) — cliente chama `insertRows()`
- Dados são escritos em uma área de staging, depois automaticamente migrados para armazenamento de tabela
- Nenhum objeto pipe necessário — usa objetos `CHANNEL`
- Melhor para: IoT, clickstream, dados de eventos em tempo real
- Combina com Dynamic Tables para transformação em tempo real

**Detecção e Evolução de Schema**

- **Detecção de schema** (`INFER_SCHEMA`): detecta automaticamente nomes/tipos de colunas de arquivos em stage
  - Funciona com Parquet, Avro, ORC, CSV (com cabeçalhos)
  - `SELECT * FROM TABLE(INFER_SCHEMA(LOCATION => '@stage', FILE_FORMAT => 'fmt'))`
  - Use com `CREATE TABLE ... USING TEMPLATE` para DDL automático
- **Evolução de schema** (`ENABLE_SCHEMA_EVOLUTION = TRUE`): novas colunas nos arquivos fonte são automaticamente adicionadas à tabela
  - Colunas existentes NÃO são modificadas ou removidas
  - Requer que a role do arquivo tenha privilégio EVOLVE SCHEMA

### Por Que Isso Importa
Uma empresa de varejo recebe 500 arquivos CSV diariamente das lojas. Snowpipe faz auto-ingest conforme eles chegam no S3. Evolução de schema lida com novas colunas (ex: "loyalty_tier") sem ALTER TABLE manual.

### Melhores Práticas
- Use Snowpipe para streams contínuos e orientados a eventos; COPY INTO para grandes batches agendados
- Defina `ON_ERROR = CONTINUE` para cargas não críticas (com monitoramento de erros)
- Habilite evolução de schema em tabelas de staging para lidar com mudanças de schema na fonte
- Use `MATCH_BY_COLUMN_NAME` quando colunas da fonte não correspondem à ordem da tabela
- Monitore Snowpipe via `PIPE_USAGE_HISTORY` e `COPY_HISTORY`

**Armadilha do exame:** SE VOCÊ VER "Snowpipe Streaming requer um objeto PIPE" → ERRADO porque Streaming usa CHANNELS, não pipes.

**Armadilha do exame:** SE VOCÊ VER "COPY INTO detecta schema automaticamente" → ERRADO porque você deve usar explicitamente `INFER_SCHEMA` ou `USING TEMPLATE`.

**Armadilha do exame:** SE VOCÊ VER "evolução de schema pode remover colunas" → ERRADO porque ela apenas ADICIONA novas colunas; nunca remove ou modifica existentes.

**Armadilha do exame:** SE VOCÊ VER "Snowpipe carrega dados de forma síncrona" → ERRADO porque Snowpipe é assíncrono (serverless, orientado a eventos).

### Perguntas Frequentes (FAQ)
**P: Qual é a janela de dedup do Snowpipe?**
R: 14 dias. Arquivos carregados nos últimos 14 dias não serão recarregados (baseado em nome de arquivo + metadados).

**P: Posso usar Snowpipe com internal stages?**
R: Sim, mas auto-ingest com notificações de nuvem só funciona com external stages. Para internal stages, você chama a API REST `insertFiles` manualmente.

**P: Quando devo usar Snowpipe Streaming vs Snowpipe regular?**
R: Use Streaming quando precisar de latência sub-segundo e estiver gerando dados programaticamente (não arquivos). Use Snowpipe regular quando dados chegam como arquivos em armazenamento de nuvem.


### Exemplos de Perguntas de Cenário — Data Loading

**Cenário:** A retail chain has 2,000 stores, each uploading daily sales CSV files to S3 at unpredictable times throughout the day. The analytics team needs data available within 5 minutes of upload. Currently, a scheduled COPY INTO job runs hourly, causing up to 60 minutes of latency and occasionally missing late-arriving files. How should the architect redesign the ingestion?
**Resposta:** Replace the scheduled COPY INTO with Snowpipe using auto-ingest. Configure S3 event notifications (SQS) on the bucket to trigger Snowpipe whenever a new file lands. Create a PIPE object with `AUTO_INGEST = TRUE` pointing to the S3 stage with the appropriate file format. Snowpipe processes files within seconds to minutes of arrival — well within the 5-minute SLA. It uses serverless compute (no dedicated warehouse), and the 14-day deduplication window prevents re-loading files. Enable schema evolution on the target table to handle any new columns stores may add over time.

**Cenário:** An IoT platform receives 50,000 sensor events per second from industrial equipment. Events must be queryable within 2 seconds for real-time monitoring dashboards. File-based ingestion cannot meet the latency requirement. What ingestion method should the architect use?
**Resposta:** Use Snowpipe Streaming via the Snowflake Ingest SDK (Java). The application calls `insertRows()` to write events directly to Snowflake without creating intermediate files — achieving sub-second latency. Data lands in a staging area and is automatically migrated to table storage. No PIPE object is needed; the SDK uses CHANNEL objects. Combine Snowpipe Streaming with dynamic tables for real-time transformation — e.g., a dynamic table with a 1-minute target lag that aggregates raw sensor events into equipment health metrics for the monitoring dashboard.

**Cenário:** A data engineering team is onboarding a new data source that adds new columns to its JSON payloads every few weeks. They don't want to manually ALTER TABLE each time. How should the architect configure the pipeline to handle this automatically?
**Resposta:** Enable schema evolution on the target table: `ALTER TABLE ... SET ENABLE_SCHEMA_EVOLUTION = TRUE`. Use `MATCH_BY_COLUMN_NAME = 'CASE_INSENSITIVE'` in the COPY INTO or Snowpipe definition so that columns are matched by name rather than position. When new columns appear in the source files, Snowflake automatically adds them to the table. Existing columns are never modified or removed. The role running the load must have the EVOLVE SCHEMA privilege on the table. Use `INFER_SCHEMA` for the initial table creation to detect the starting schema from a sample file.

---

---

## 3.2 STAGES E FILE FORMATS

**Internal Stages**

- **User stage** (`@~`): um por usuário, não pode ser alterado ou descartado
- **Table stage** (`@%table_name`): um por tabela, vinculado àquela tabela
- **Named internal stage** (`@my_stage`): criado explicitamente, mais flexível
- Dados armazenados em armazenamento gerenciado pelo Snowflake, criptografados em repouso

**External Stages**

- Apontam para armazenamento de nuvem: S3, GCS, Azure Blob/ADLS
- Requerem uma **storage integration** (melhor prática) ou credenciais inline (não recomendado)
- Suportam caminhos de pasta: `@ext_stage/path/to/folder/`

**File Formats**

- Definições de formato reutilizáveis: `CREATE FILE FORMAT`
- Tipos: CSV, JSON, AVRO, PARQUET, ORC, XML
- Opções-chave de CSV: `FIELD_DELIMITER`, `SKIP_HEADER`, `NULL_IF`, `ERROR_ON_COLUMN_COUNT_MISMATCH`
- Opções-chave de JSON: `STRIP_OUTER_ARRAY`, `STRIP_NULL_VALUES`
- Pode ser especificado inline no COPY INTO ou referenciado por nome

**Directory Tables**

- Camada de metadados em um stage: `ALTER STAGE @my_stage SET DIRECTORY = (ENABLE = TRUE)`
- Permite consultar metadados de arquivo (nome, tamanho, MD5, last_modified) via SQL
- Deve ser atualizado: `ALTER STAGE @my_stage REFRESH`
- Auto-refresh disponível para external stages com notificações de nuvem
- Útil para inventário de arquivos, rastreamento de novas chegadas, construção de pipelines de processamento

### Por Que Isso Importa
Um data lake tem 2M de arquivos Parquet no S3. Uma directory table fornece um inventário consultável sem listar objetos via AWS CLI. Combinado com streams, você pode detectar novos arquivos automaticamente.

### Melhores Práticas
- Sempre use storage integrations para external stages (sem credenciais inline)
- Use named internal stages em vez de table/user stages para workloads de produção
- Defina file formats como objetos reutilizáveis, não specs inline
- Habilite directory tables com auto-refresh para pipelines orientados a arquivos

**Armadilha do exame:** SE VOCÊ VER "user stages podem ser compartilhados entre usuários" → ERRADO porque o stage de cada usuário é privado e com escopo para aquele usuário.

**Armadilha do exame:** SE VOCÊ VER "directory tables armazenam os dados reais dos arquivos" → ERRADO porque elas apenas armazenam metadados sobre arquivos.

**Armadilha do exame:** SE VOCÊ VER "table stages suportam todas as funcionalidades de stage" → ERRADO porque table stages não podem ter file formats e têm opções limitadas vs named stages.

### Perguntas Frequentes (FAQ)
**P: Posso fazer GRANT de acesso a um user stage?**
R: Não. User stages são por usuário e não podem ser concedidos a outros.

**P: Directory tables funcionam em internal stages?**
R: Sim, mas auto-refresh só está disponível para external stages. Internal stages requerem `REFRESH` manual.


### Exemplos de Perguntas de Cenário — Stages & File Formats

**Cenário:** A data lake has 2 million Parquet files in S3 across hundreds of folders. The data engineering team needs to track which files have been processed, identify new arrivals, and build processing pipelines based on file metadata (size, last modified date). Currently, they run AWS CLI `ls` commands which take 30+ minutes. How should the architect improve this?
**Resposta:** Create an external stage pointing to the S3 bucket with a storage integration (no inline credentials). Enable a directory table on the stage: `ALTER STAGE @data_lake SET DIRECTORY = (ENABLE = TRUE)`. Configure auto-refresh with S3 event notifications so the directory table updates automatically when new files land. The team can now query file metadata (name, size, MD5, last_modified) via standard SQL in seconds instead of running CLI commands. Combine the directory table with a stream to detect new file arrivals and trigger processing tasks automatically.

**Cenário:** A security audit reveals that several external stages in production were created with inline AWS access keys embedded directly in the stage definition. How should the architect remediate this and prevent recurrence?
**Resposta:** Recreate all external stages using storage integrations instead of inline credentials. A storage integration uses IAM roles (on AWS) or service principals (on Azure) — no raw credentials in SQL. After migrating all stages, set the account-level parameter `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION = TRUE` to prevent anyone from creating stages with inline credentials in the future. Rotate the compromised AWS access keys immediately. Use named internal stages over table/user stages for any internally-staged data in production.

---

---

## 3.3 STREAMS E TASKS

**Streams (Captura de Dados de Mudança)**

- Rastreiam mudanças DML (INSERT, UPDATE, DELETE) em uma tabela fonte
- Três tipos:
  - **Standard:** rastreia todos os três tipos de DML, usa colunas ocultas
  - **Append-only:** rastreia apenas INSERTs (mais barato, mais simples)
  - **Insert-only (em tabelas externas):** rastreia novos arquivos/linhas em tabelas externas
- Colunas de metadados: `METADATA$ACTION`, `METADATA$ISUPDATE`, `METADATA$ROW_ID`
- Stream é "consumido" quando usado em uma transação DML (avança o offset)
- Um stream tem uma **janela de obsolescência** — se não consumido dentro da retenção de Time Travel, fica obsoleto

**Change Tracking**

- Alternativa a streams: `ALTER TABLE ... SET CHANGE_TRACKING = TRUE`
- Consulte mudanças via cláusula `CHANGES`: `SELECT * FROM table CHANGES(INFORMATION => DEFAULT) AT(...)`
- Não tem offset consumível — queries idempotentes
- Útil para consultas de mudanças pontuais sem um objeto stream dedicado

**Tasks**

- Execução SQL agendada (standalone ou em árvores de task/DAGs)
- Agendamento via expressão CRON ou `SCHEDULE = 'N MINUTE'`
- Árvores de tasks: task raiz dispara filhas em ordem de dependência
- Tasks usam computação serverless por padrão (ou um warehouse especificado)
- Devem ser explicitamente retomadas: `ALTER TASK ... RESUME`
- Cláusula `WHEN`: execução condicional (ex: `WHEN SYSTEM$STREAM_HAS_DATA('my_stream')`)

**Árvores de Tasks (DAGs)**

- Task raiz → tasks filhas → tasks netas
- Apenas a task raiz tem agendamento; filhas disparam automaticamente
- Task finalizadora: executa após todas as tasks no grafo completarem (sucesso ou falha)
- Use `ALLOW_OVERLAPPING_EXECUTION` para controlar execuções concorrentes

### Por Que Isso Importa
Uma plataforma de e-commerce usa um stream em `raw_orders` e uma task que executa a cada 5 minutos. A task verifica `SYSTEM$STREAM_HAS_DATA`, e se verdadeiro, faz merge das mudanças em `curated_orders`. CDC sem ferramenta de terceiros.

### Melhores Práticas
- Use `SYSTEM$STREAM_HAS_DATA` na cláusula WHEN da task para evitar execuções vazias
- Defina `SUSPEND_TASK_AFTER_NUM_FAILURES` apropriado para parar erros descontrolados
- Use tasks serverless a menos que precise controlar o tamanho do warehouse
- Prefira dynamic tables em vez de stream+task para pipelines de transformação pura
- Monitore tasks via `TASK_HISTORY` em ACCOUNT_USAGE

**Armadilha do exame:** SE VOCÊ VER "streams funcionam em views" → ERRADO porque streams funcionam em tabelas (e tabelas externas), não views.

**Armadilha do exame:** SE VOCÊ VER "tasks filhas podem ter seu próprio agendamento" → ERRADO porque apenas a task raiz tem agendamento; filhas são disparadas pela conclusão da pai.

**Armadilha do exame:** SE VOCÊ VER "streams nunca ficam obsoletos" → ERRADO porque um stream fica obsoleto se não consumido dentro da retenção de Time Travel da fonte + 14 dias.

**Armadilha do exame:** SE VOCÊ VER "tasks são retomadas por padrão após criação" → ERRADO porque tasks são criadas em estado SUSPENDED e devem ser explicitamente retomadas.

### Perguntas Frequentes (FAQ)
**P: Múltiplos streams podem existir na mesma tabela?**
R: Sim. Cada stream rastreia independentemente com seu próprio offset.

**P: O que acontece se um stream fica obsoleto?**
R: Ele se torna inutilizável. Você deve recriá-lo. O offset é perdido, e pode ser necessário fazer um recarregamento completo.

**P: Tasks podem chamar stored procedures?**
R: Sim. O corpo de uma task pode ser qualquer instrução SQL única, incluindo `CALL my_procedure()`.


### Exemplos de Perguntas de Cenário — Streams & Tasks

**Cenário:** An e-commerce platform needs to merge incremental order updates (inserts, updates, deletes) from a raw orders table into a curated orders table every 5 minutes. The merge logic includes custom conflict resolution (e.g., latest timestamp wins for updates). What pipeline architecture should the architect use?
**Resposta:** Create a standard stream on the raw orders table to capture all DML changes (inserts, updates, deletes). Create a task with a 5-minute schedule and a `WHEN SYSTEM$STREAM_HAS_DATA('orders_stream')` clause to avoid empty runs. The task body executes a MERGE statement that reads from the stream and applies custom conflict resolution logic (e.g., `WHEN MATCHED AND src.updated_at > tgt.updated_at THEN UPDATE`). Use serverless tasks unless the MERGE is complex enough to warrant a dedicated warehouse. Set `SUSPEND_TASK_AFTER_NUM_FAILURES` to stop runaway errors and monitor via `TASK_HISTORY`.

**Cenário:** A data platform has a complex ETL pipeline: raw data must be cleaned, then enriched with reference data, then aggregated into summary tables. Each step depends on the previous one completing successfully. If any step fails, a notification must be sent. How should the architect orchestrate this?
**Resposta:** Build a task tree (DAG). The root task runs on a schedule and performs the cleaning step. A child task handles enrichment (triggered automatically on root success). A grandchild task handles aggregation. Add a finalizer task to the DAG — it runs after all tasks complete (whether they succeed or fail) and sends an email notification with the outcome. Only the root task has a schedule; children trigger on parent completion. Use `ALLOW_OVERLAPPING_EXECUTION = FALSE` on the root to prevent concurrent runs. Alternatively, if the pipeline is pure SQL transformations without custom merge logic, consider chaining dynamic tables instead — they handle scheduling and incremental refresh declaratively.

---

---

## 3.4 TABELAS EXTERNAS E ICEBERG

**External Tables**

- Tabela somente leitura sobre arquivos em armazenamento externo (S3, GCS, Azure)
- Snowflake armazena apenas metadados; dados ficam no seu armazenamento de nuvem
- Suporta auto-refresh de metadados via notificações de nuvem
- Performance de query é mais lenta que tabelas nativas (sem clustering, sem otimização de micro-partition)
- Suporte para particionamento via colunas computadas `PARTITION BY`
- Streams em tabelas externas: insert-only (rastreia novos arquivos)

**Managed Iceberg Tables**

- Snowflake gerencia o ciclo de vida da tabela (caminho de escrita, compactação, snapshots)
- External volume define ONDE dados são armazenados (seu armazenamento de nuvem)
- DML completo: INSERT, UPDATE, DELETE, MERGE
- Integração de catálogo não necessária (Snowflake é o catálogo)
- Outros motores podem ler os metadados/arquivos de dados Iceberg
- Suporta Time Travel, clonagem, replicação

**Unmanaged Iceberg Tables (Catalog-Linked)**

- Catálogo externo (Glue, Polaris/OpenCatalog, Unity, REST) gerencia metadados
- Snowflake lê o catálogo para entender a estrutura da tabela
- Somente leitura do Snowflake (escritas vão pelo motor externo)
- Requer objeto CATALOG INTEGRATION
- Auto-refresh detecta mudanças no catálogo

**Refresh Incremental vs Completo (Contexto Dynamic/Iceberg)**

- **Refresh completo:** recomputa todo o dataset (caro mas simples)
- **Refresh incremental:** processa apenas dados alterados (mais barato, requer rastreamento de mudanças)
- Dynamic tables usam refresh incremental quando possível (dependente do operador)
- Algumas operações forçam refresh completo (ex: funções não determinísticas, joins complexos)

### Por Que Isso Importa
Uma empresa roda tanto Spark quanto Snowflake. Managed Iceberg tables permitem que o Snowflake escreva dados em formato Iceberg no S3. Spark lê os mesmos arquivos diretamente. Uma cópia dos dados, dois motores.

### Melhores Práticas
- Use managed Iceberg para novos requisitos de "formato aberto" com Snowflake como motor principal
- Use unmanaged/catalog-linked para dados de propriedade de outro motor (Spark, Trino)
- Tabelas externas são legadas para acesso somente leitura — prefira Iceberg para novos projetos
- Particione tabelas externas por data/região para pruning de query

**Armadilha do exame:** SE VOCÊ VER "tabelas externas suportam UPDATE/DELETE" → ERRADO porque tabelas externas são somente leitura.

**Armadilha do exame:** SE VOCÊ VER "unmanaged Iceberg tables suportam MERGE" → ERRADO porque escritas devem ir pelo catálogo/motor externo.

**Armadilha do exame:** SE VOCÊ VER "managed Iceberg tables armazenam dados no armazenamento interno do Snowflake" → ERRADO porque elas escrevem em um external volume (seu armazenamento de nuvem) em formato Iceberg.

**Armadilha do exame:** SE VOCÊ VER "dynamic tables sempre usam refresh incremental" → ERRADO porque certas operações forçam refresh completo.

### Perguntas Frequentes (FAQ)
**P: Posso converter uma tabela externa para uma tabela nativa?**
R: Não diretamente. Você faria CTAS da tabela externa para uma nova tabela nativa (ou Iceberg).

**P: Managed Iceberg tables suportam clustering?**
R: Sim. Você pode definir clustering keys em managed Iceberg tables.

**P: Qual é a diferença entre uma tabela externa e uma unmanaged Iceberg table?**
R: Tabelas externas funcionam com arquivos brutos (CSV, Parquet, etc.) com metadados definidos pelo Snowflake. Unmanaged Iceberg tables lêem tabelas formatadas em Iceberg gerenciadas por um catálogo externo com capacidades Iceberg completas (snapshots, evolução de schema).


### Exemplos de Perguntas de Cenário — External & Iceberg Tables

**Cenário:** A company's data science team uses Apache Spark on EMR to train ML models, and the analytics team uses Snowflake for reporting. Both teams need read/write access to the same feature store tables. Currently, data is duplicated in both Parquet files and Snowflake tables, causing consistency issues. How should the architect unify the data layer?
**Resposta:** Migrate the feature store to managed Iceberg tables in Snowflake. Define an external volume pointing to S3 where the Iceberg data and metadata files will be stored. Snowflake manages the table lifecycle — full DML (INSERT, UPDATE, DELETE, MERGE), compaction, and snapshot management. The Spark team reads the same Iceberg metadata and data files from S3 directly using Spark's Iceberg connector. One copy of data, two engines, full consistency. Managed Iceberg tables also support Time Travel and clustering for the Snowflake analytics team.

**Cenário:** A partner organization manages their data catalog in AWS Glue and writes Iceberg tables from their Spark pipelines. Your company needs to query this data from Snowflake without taking ownership of the catalog. How should the architect set this up?
**Resposta:** Create an unmanaged (catalog-linked) Iceberg table in Snowflake. Configure a catalog integration pointing to the partner's AWS Glue catalog. Snowflake reads the Glue-managed Iceberg metadata to understand the table structure and queries the data files directly from S3. This is read-only from Snowflake — all writes continue through the partner's Spark pipelines. Enable auto-refresh on the catalog integration so Snowflake detects when the partner updates the table. Do not use a managed Iceberg table here, as that would transfer catalog ownership to Snowflake and conflict with the partner's Spark writes.

---

---

## 3.5 TRANSFORMAÇÃO DE DADOS

**FLATTEN**

- Converte dados semi-estruturados (JSON, ARRAY, VARIANT) em linhas
- Lateral join por padrão: `SELECT ... FROM table, LATERAL FLATTEN(input => col)`
- Parâmetros-chave: `INPUT`, `PATH`, `OUTER` (manter linhas com arrays vazios), `RECURSIVE`, `MODE`
- Colunas de saída: `SEQ`, `KEY`, `PATH`, `INDEX`, `VALUE`, `THIS`

**UDFs (Funções Definidas pelo Usuário)**

- SQL, JavaScript, Python, Java, Scala
- UDFs escalares: retornam um valor por linha de entrada
- Devem ser determinísticas para uso em materialized views / clustering
- Secure UDFs: escondem o corpo da função dos consumidores

**UDTFs (Funções de Tabela Definidas pelo Usuário)**

- Retornam uma tabela (múltiplas linhas por linha de entrada)
- Devem implementar: `PROCESS()` (lógica por linha) e opcionalmente `END_PARTITION()` (saída final)
- Chamadas com `TABLE()` na cláusula FROM
- Úteis para: parsing, explosão, agregação customizada

**External Functions**

- Chamam endpoints de API externa (ex: AWS Lambda, Azure Functions) a partir do SQL
- Requer: API integration + definição de external function
- Síncrono: Snowflake chama a API por batch e espera
- Use para: inferência de ML, enriquecimento de terceiros, lógica customizada não disponível no Snowflake
- Sendo substituídas por UDFs baseadas em contêiner (SPCS) para novos casos de uso

**Stored Procedures**

- Podem conter fluxo de controle (IF, LOOP, BEGIN/END), múltiplas instruções SQL
- Linguagens: SQL (Snowflake Scripting), JavaScript, Python, Java, Scala
- Podem executar com direitos CALLER ou OWNER
- Use para: tarefas administrativas, ETL complexo, operações multi-etapa
- Diferença-chave de UDFs: procedures podem ter efeitos colaterais (DML), UDFs não

**Dynamic Tables**

- Transformação declarativa: defina o alvo como uma query SQL + target lag
- Snowflake atualiza automaticamente (incremental quando possível)
- Substituem cadeias complexas de stream+task para pipelines de transformação
- Target lag: `DOWNSTREAM` (cascata de DTs upstream) ou intervalo explícito
- Não podem ser usadas como fonte direta para streams

**Secure Functions**

- UDFs/UDTFs com palavra-chave `SECURE`: corpo é escondido dos consumidores
- Necessárias para funções usadas em Secure Data Sharing
- Mesma barreira de otimizador que secure views

### Por Que Isso Importa
Um pipeline achata eventos JSON brutos, enriquece-os via external function (scoring de ML), e coloca resultados em uma dynamic table com target lag de 5 minutos. Zero gerenciamento de task/stream.

### Melhores Práticas
- Prefira dynamic tables em vez de stream+task para pipelines de transformação pura
- Use SQL UDFs para cálculos simples; Python UDFs para lógica complexa
- Minimize chamadas de external function (overhead de rede por batch)
- Use stored procedures para workflows administrativos, não transformação de dados
- Defina target lag de dynamic table baseado no SLA de negócio, não o mais baixo possível

**Armadilha do exame:** SE VOCÊ VER "UDFs podem executar instruções DML" → ERRADO porque UDFs são somente leitura; apenas stored procedures podem executar DML.

**Armadilha do exame:** SE VOCÊ VER "dynamic tables podem ser fontes para streams" → ERRADO porque você não pode criar streams em dynamic tables.

**Armadilha do exame:** SE VOCÊ VER "external functions executam dentro da computação do Snowflake" → ERRADO porque elas chamam um endpoint de API externo fora do Snowflake.

**Armadilha do exame:** SE VOCÊ VER "FLATTEN só funciona com JSON" → ERRADO porque FLATTEN funciona com qualquer tipo semi-estruturado: VARIANT, ARRAY, OBJECT.

### Perguntas Frequentes (FAQ)
**P: Posso usar Python UDFs em materialized views?**
R: Não. MVs só suportam expressões SQL (sem UDFs, sem external functions).

**P: Qual é a diferença entre target lag DOWNSTREAM e um intervalo específico?**
R: DOWNSTREAM significa "atualizar sempre que minha dynamic table upstream atualizar." Um intervalo específico (ex: 5 MINUTES) significa "garantir que os dados não sejam mais antigos que 5 minutos."

**P: Dynamic tables podem referenciar outras dynamic tables?**
R: Sim. Isso cria um pipeline de dynamic tables (DAG), onde atualizações upstream cascateiam downstream.


### Exemplos de Perguntas de Cenário — Data Transformation

**Cenário:** A data platform ingests raw JSON events with deeply nested arrays (e.g., an order contains an array of items, each item contains an array of discounts). The analytics team needs a flat, relational table with one row per discount. Some orders have no discounts and must still appear in the output. How should the architect design the transformation?
**Resposta:** Use nested LATERAL FLATTEN to expand the multi-level arrays. First FLATTEN the items array, then FLATTEN the discounts array within each item. Use `OUTER => TRUE` on the discounts FLATTEN to preserve orders/items that have empty discount arrays (they appear as NULL discount rows instead of being dropped). The query pattern: `SELECT ... FROM orders, LATERAL FLATTEN(INPUT => items, OUTER => TRUE) AS i, LATERAL FLATTEN(INPUT => i.VALUE:discounts, OUTER => TRUE) AS d`. Materialize this as a dynamic table with an appropriate target lag so the flat table stays current as new events arrive.

**Cenário:** A company has a complex transformation pipeline: raw → cleaned → enriched → aggregated. Currently this is managed with 4 stream+task pairs, and the team spends significant time debugging task failures, managing stream staleness, and handling scheduling edge cases. How should the architect simplify this?
**Resposta:** Replace the stream+task chain with a pipeline of dynamic tables. Define each layer as a dynamic table with a SQL query referencing the previous layer: `raw_dt → cleaned_dt → enriched_dt → aggregated_dt`. Set target lag based on business SLAs — the final aggregated table might use `TARGET_LAG = '5 MINUTES'` while intermediate tables use `TARGET_LAG = DOWNSTREAM` (refresh when downstream needs data). Snowflake handles scheduling, incremental refresh, and error management declaratively. This eliminates manual stream offset management, task scheduling, and staleness risks. Note: dynamic tables work best for pure SQL transformations; if you need custom merge logic or procedural control flow, stream+task remains appropriate.

**Cenário:** The data engineering team needs a stored procedure that loops through all databases in the account, creates a governance tag on each, and grants APPLY TAG privileges to a specific role. A junior engineer asks why they can't use a UDF for this. What should the architect explain?
**Resposta:** UDFs cannot execute DML or DDL statements — they are read-only functions usable in SELECT. This task requires DDL (`CREATE TAG`) and DCL (`GRANT`) operations, which only stored procedures can perform. Create a stored procedure using Snowflake Scripting (SQL) with a RESULTSET cursor to iterate over `SHOW DATABASES`, then execute `CREATE TAG IF NOT EXISTS` and `GRANT APPLY TAG` for each database. The procedure should run with CALLER rights so it executes under the invoking role's permissions, ensuring proper authorization checks.

---

---

## 3.6 FERRAMENTAS DO ECOSSISTEMA

**Kafka Connector**

- Transmite dados de tópicos Kafka para tabelas Snowflake
- Duas versões: **Baseada em Snowpipe** (arquivos para stage, depois COPY) e **Snowpipe Streaming** (inserção direta de linhas, menor latência)
- Suporta semântica exactly-once
- Lida com evolução de schema (novos campos em JSON)
- Gerenciado pelo Snowflake ou auto-hospedado

**Spark Connector**

- Bidirecional: ler de e escrever para Snowflake a partir do Spark
- Empurra queries para o Snowflake quando possível (predicate pushdown)
- Suporta DataFrame API e SQL
- Configuração-chave: `sfURL`, `sfUser`, `sfPassword`, `sfDatabase`, `sfSchema`, `sfWarehouse`

**Python Connector**

- Biblioteca Python nativa (`snowflake-connector-python`)
- Suporta `write_pandas()` para uploads em massa de DataFrame
- Integra com SQLAlchemy
- Suporte a query assíncrona para queries de longa duração
- `snowflake-snowpark-python` — DataFrame API que executa na computação do Snowflake

**JDBC / ODBC**

- Conectividade padrão de banco de dados para Java (JDBC) e outras linguagens (ODBC)
- Snowflake fornece seus próprios drivers JDBC e ODBC
- Suportam todas as operações SQL padrão
- Usados pela maioria das ferramentas de BI (Tableau, Power BI, Looker)

**SQL API (REST)**

- Endpoint HTTP REST para executar SQL
- Submeter instruções, verificar status, recuperar resultados via chamadas REST
- Usa OAuth ou tokens de par de chaves para autenticação
- Execução assíncrona: submeter → consultar status → buscar resultados
- Útil para arquiteturas serverless, microsserviços

**Snowpark**

- Framework de desenvolvimento para Python, Java, Scala
- DataFrame API que executa na computação do Snowflake (sem movimentação de dados)
- Suporta UDFs, UDTFs e stored procedures
- Ideal para pipelines de ML, transformações complexas
- Avaliação lazy: operações constroem um plano, executam no `.collect()` ou ação

### Por Que Isso Importa
Uma plataforma de dados usa Kafka connector para ingestão em tempo real, Snowpark para engenharia de features de ML, e JDBC para ferramentas de BI. O arquiteto deve saber qual conector se encaixa em cada caso de uso.

### Melhores Práticas
- Use Kafka connector com Snowpipe Streaming para menor latência
- Use Snowpark em vez de extrair dados para Python/Spark quando possível (computação fica no Snowflake)
- Use SQL API para integrações leves e apps serverless
- Sempre use os drivers mais recentes fornecidos pelo Snowflake (atualizados frequentemente)
- Use autenticação por par de chaves para todas as conexões programáticas/de serviço

**Armadilha do exame:** SE VOCÊ VER "o Spark connector sempre move todos os dados para o Spark" → ERRADO porque ele suporta predicate pushdown, empurrando filtros para o Snowflake.

**Armadilha do exame:** SE VOCÊ VER "SQL API é apenas síncrona" → ERRADO porque ela suporta execução assíncrona (submeter → consultar → buscar).

**Armadilha do exame:** SE VOCÊ VER "Snowpark requer que dados sejam extraídos do Snowflake" → ERRADO porque Snowpark executa na computação do Snowflake; dados ficam no Snowflake.

**Armadilha do exame:** SE VOCÊ VER "o Kafka connector só suporta JSON" → ERRADO porque ele suporta JSON, Avro e Protobuf (com schema registry).

### Perguntas Frequentes (FAQ)
**P: Quando devo usar o Spark connector vs Snowpark?**
R: Use Spark connector quando você já tem infraestrutura Spark e precisa integrar Snowflake em pipelines existentes. Use Snowpark quando quiser executar toda a computação no Snowflake sem um cluster Spark.

**P: A SQL API pode lidar com grandes conjuntos de resultados?**
R: Sim, via paginação de conjunto de resultados. Resultados grandes são retornados em partições que você busca incrementalmente.

**P: O Kafka connector suporta evolução de schema?**
R: Sim. Novos campos em payloads JSON são carregados na coluna VARIANT. Se você usar evolução de schema na tabela de destino, colunas são auto-adicionadas.


### Exemplos de Perguntas de Cenário — Ecosystem Tools

**Cenário:** A company has an existing Spark-based ML pipeline on Databricks that processes 500 GB of features daily. They're migrating analytics to Snowflake but don't want to rewrite the Spark pipeline. The Spark pipeline needs to read from and write to Snowflake tables. How should the architect integrate the two systems?
**Resposta:** Use the Snowflake Spark connector. Configure it with the Snowflake connection parameters (`sfURL`, `sfUser`, `sfWarehouse`, etc.) and use key-pair authentication for the service account. The Spark connector supports bidirectional data movement and pushes predicates down to Snowflake when reading (minimizing data transfer). For the longer-term, evaluate migrating the ML pipeline to Snowpark — which runs the DataFrame API directly on Snowflake compute without moving data out. But for immediate integration without rewriting, the Spark connector is the correct choice.

**Cenário:** A microservices architecture on AWS Lambda needs to execute Snowflake queries. The Lambda functions are stateless, short-lived, and cannot maintain persistent database connections. What connectivity approach should the architect recommend?
**Resposta:** Use the Snowflake SQL API (REST). Lambda functions submit SQL statements via HTTP POST, then poll for status and fetch results asynchronously. The SQL API supports OAuth or key-pair tokens for authentication — no persistent database connections needed. This fits the stateless, ephemeral nature of Lambda. For larger result sets, the API returns paginated results that Lambda can fetch incrementally. Avoid JDBC/ODBC in Lambda since connection pooling is impractical in short-lived serverless functions.

**Cenário:** A data science team currently extracts 100 GB of data from Snowflake to their local Python environment using the Python connector and pandas for feature engineering. The extraction takes 45 minutes and overwhelms local memory. How should the architect improve this workflow?
**Resposta:** Migrate the feature engineering logic to Snowpark. Snowpark provides a pandas-like DataFrame API that executes directly on Snowflake's compute — no data extraction needed. The data stays in Snowflake, operations are lazily evaluated and pushed down to the warehouse, and results are only materialized on `.collect()` or when writing to a table. This eliminates the 45-minute extraction, local memory constraints, and data movement costs. Snowpark supports Python UDFs and stored procedures for complex ML logic that can't be expressed in SQL.

---

---

## PARES CONFUSOS — Engenharia de Dados

| Perguntam sobre... | A resposta é... | NÃO... |
|---|---|---|
| **Snowpipe** vs **COPY INTO** | **Snowpipe** = serverless, orientado a eventos, contínuo (arquivos disparam carga) | **COPY INTO** = comando batch manual/agendado, você executa explicitamente |
| **Snowpipe** vs **Snowpipe Streaming** | **Snowpipe** = baseado em arquivo (notificações de nuvem → micro-batch) | **Streaming** = baseado em linha (Ingest SDK, sem arquivos, latência sub-segundo) |
| **Objeto PIPE** vs **objeto CHANNEL** | **PIPE** = usado pelo Snowpipe regular (`CREATE PIPE`) | **CHANNEL** = usado pelo Snowpipe Streaming (Ingest SDK, sem PIPE necessário) |
| **Stream** vs **Task** | **Stream** = rastreador de CDC (registra mudanças em uma tabela) | **Task** = executor SQL agendado (cron/intervalo). São *parceiros*, não substitutos |
| **Stream standard** vs **stream append-only** | **Standard** = rastreia INSERT + UPDATE + DELETE | **Append-only** = rastreia apenas INSERTs (mais barato, mais simples) |
| **Tabela externa** vs **Iceberg table** | **External** = arquivos brutos (CSV, Parquet), somente leitura, metadados Snowflake | **Iceberg** = formato Iceberg, managed = DML completo, unmanaged = catalog-linked |
| **Detecção de schema** vs **evolução de schema** | **Detecção** (`INFER_SCHEMA`) = lê arquivo para descobrir colunas *uma vez* | **Evolução** = auto-adiciona novas colunas à tabela *continuamente* conforme a fonte muda |
| **UDF** vs **UDTF** | **UDF** = um valor por linha (escalar) | **UDTF** = múltiplas linhas por entrada (função de tabela, usa PROCESS + END_PARTITION) |
| **UDF** vs **stored procedure** | **UDF** = somente leitura, sem efeitos colaterais, utilizável em SELECT | **Procedure** = pode fazer DML, fluxo de controle, efeitos colaterais, chamada via CALL |
| **External function** vs **UDF** | **External function** = chama uma API *fora* do Snowflake (Lambda, Azure Func) | **UDF** = executa *dentro* da computação do Snowflake |
| **Dynamic table** vs **stream + task** | **Dynamic table** = declarativa (defina SQL + target lag, Snowflake gerencia refresh) | **Stream + task** = imperativa (você gerencia CDC + agendamento + tratamento de erros) |
| **Directory table** vs **tabela externa** | **Directory table** = metadados sobre *arquivos* em um stage (nome, tamanho, data) | **Tabela externa** = *dados dentro* de arquivos consultáveis em armazenamento externo |
| **User stage** vs **table stage** vs **named stage** | **User** (`@~`) = por usuário, privado, não compartilhável | **Table** (`@%t`) = por tabela, opções limitadas | **Named** (`@s`) = explícito, mais flexível |
| **Target lag DOWNSTREAM** vs **intervalo explícito** | **DOWNSTREAM** = atualizar quando DT upstream atualizar | **Explícito** (ex: 5 MIN) = dados não mais antigos que N minutos |
| **VALIDATION_MODE** vs **ON_ERROR** | **VALIDATION_MODE** = execução simulada, nenhum dado carregado | **ON_ERROR** = controla comportamento *durante* carga real (CONTINUE, ABORT, SKIP_FILE) |

---

## ÁRVORES DE DECISÃO DE CENÁRIOS — Engenharia de Dados

**Cenário 1: "500 arquivos CSV chegam no S3 diariamente de sistemas POS de lojas..."**
- **CORRETO:** **Snowpipe** com auto-ingest (notificação de evento S3 dispara carga)
- ARMADILHA: *"COPY INTO agendado a cada hora"* — **ERRADO**, perde arquivos entre execuções, maior latência, mais custo de warehouse

**Cenário 2: "Sensores IoT enviam 10K eventos/segundo, precisam de latência sub-segundo..."**
- **CORRETO:** **Snowpipe Streaming** (Ingest SDK, nível de linha, sem arquivos)
- ARMADILHA: *"Snowpipe regular"* — **ERRADO**, Snowpipe é baseado em arquivo com latência de segundos a minutos; Streaming é sub-segundo

**Cenário 3: "Fonte adiciona novas colunas frequentemente, tabela deve adaptar automaticamente..."**
- **CORRETO:** **Evolução de schema** (`ENABLE_SCHEMA_EVOLUTION = TRUE`) + `MATCH_BY_COLUMN_NAME`
- ARMADILHA: *"INFER_SCHEMA antes de cada carga"* — **ERRADO**, INFER_SCHEMA é detecção única, não evolução contínua

**Cenário 4: "Precisa fazer merge de mudanças incrementais de raw para curated a cada 5 minutos..."**
- **CORRETO:** **Stream na tabela raw** + **Task** com `SYSTEM$STREAM_HAS_DATA` + instrução MERGE
- ARMADILHA: *"Dynamic table"* — possível mas dynamic tables não suportam lógica de MERGE com resolução de conflito customizada; stream+task dá controle total

**Cenário 5: "Construir um pipeline de transformação: raw → limpo → agregado, puramente SQL..."**
- **CORRETO:** **Dynamic tables** encadeadas (DT raw → DT limpa → DT agg com target lag)
- ARMADILHA: *"Três pares de stream+task"* — **ERRADO**, excessivamente complexo; dynamic tables lidam com isso declarativamente

**Cenário 6: "Chamar uma API externa de scoring ML de dentro de uma query SQL..."**
- **CORRETO:** **External function** (API integration + definição de função)
- ARMADILHA: *"Python UDF"* — **ERRADO**, Python UDF executa dentro do Snowflake; não pode chamar APIs externas sem uma external access integration

**Cenário 7: "Precisa achatar arrays JSON aninhados em linhas para analytics..."**
- **CORRETO:** **LATERAL FLATTEN** com `INPUT => column`, opcionalmente `OUTER => TRUE` para arrays vazios
- ARMADILHA: *"PARSE_JSON + extração manual"* — **ERRADO**, FLATTEN é feito para esse propósito e lida com arrays aninhados nativamente

**Cenário 8: "Tarefa admin: iterar por bancos de dados, criar tags, executar grants..."**
- **CORRETO:** **Stored procedure** (Snowflake Scripting com IF/LOOP/BEGIN-END)
- ARMADILHA: *"UDF"* — **ERRADO**, UDFs não podem executar DML (CREATE, GRANT, ALTER)

**Cenário 9: "Precisa rastrear quais arquivos existem em um stage e quando chegaram..."**
- **CORRETO:** **Directory table** no stage (`ENABLE = TRUE`, auto-refresh para externo)
- ARMADILHA: *"Tabela externa"* — **ERRADO**, tabelas externas consultam *conteúdo* de arquivos, não *metadados* de arquivos

**Cenário 10: "Tópicos Kafka precisam chegar no Snowflake com a menor latência possível..."**
- **CORRETO:** **Kafka connector com modo Snowpipe Streaming** (inserção direta de linhas)
- ARMADILHA: *"Kafka connector com modo Snowpipe"* — não errado, mas maior latência (baseado em arquivo); modo Streaming é menor latência

**Cenário 11: "Validação de dados antes de carregar — verificar linhas ruins sem realmente carregar..."**
- **CORRETO:** `COPY INTO ... VALIDATION_MODE = 'RETURN_ERRORS'` (execução simulada)
- ARMADILHA: *"Carregar com ON_ERROR = CONTINUE e depois verificar erros"* — **ERRADO**, isso realmente carrega dados; VALIDATION_MODE não carrega nada

**Cenário 12: "Engenharia de features ML em Python em dados já no Snowflake..."**
- **CORRETO:** **Snowpark** (DataFrame API executa na computação do Snowflake, sem movimentação de dados)
- ARMADILHA: *"Python connector + pandas"* — **ERRADO**, isso puxa dados para fora do Snowflake para a máquina local; Snowpark mantém computação no Snowflake

---

## FLASHCARDS -- Domínio 3

**Q1:** Qual é a janela de deduplicação do Snowpipe?
**A1:** 14 dias. Arquivos carregados nos últimos 14 dias não são recarregados.

**Q2:** Snowpipe Streaming usa objetos PIPE ou CHANNEL?
**A2:** CHANNEL. Nenhum objeto PIPE é necessário.

**Q3:** O que `ENABLE_SCHEMA_EVOLUTION = TRUE` faz?
**A3:** Adiciona automaticamente novas colunas à tabela quando arquivos fonte contêm colunas que não existem na tabela. Não remove ou modifica colunas existentes.

**Q4:** O que acontece quando um stream fica obsoleto?
**A4:** Ele se torna inutilizável — você deve recriá-lo e potencialmente fazer um recarregamento completo.

**Q5:** Tabelas externas podem ser atualizadas (UPDATE/DELETE)?
**A5:** Não. Tabelas externas são somente leitura.

**Q6:** Qual é a diferença entre managed e unmanaged Iceberg tables?
**A6:** Managed: Snowflake controla metadados + DML completo. Unmanaged: catálogo externo (Glue, Polaris) controla metadados, somente leitura do Snowflake.

**Q7:** UDFs podem executar instruções DML?
**A7:** Não. UDFs são somente leitura. Use stored procedures para DML.

**Q8:** O que uma directory table armazena?
**A8:** Metadados sobre arquivos em um stage (nome, tamanho, MD5, last_modified) — não os dados reais dos arquivos.

**Q9:** O que é target lag DOWNSTREAM em dynamic tables?
**A9:** Significa "atualizar sempre que minha dynamic table upstream atualizar" (cascata).

**Q10:** O Spark connector sempre puxa todos os dados para o Spark?
**A10:** Não. Ele suporta predicate pushdown, empurrando filtros para o Snowflake.

**Q11:** Apenas a task _____ tem agendamento em uma árvore de tasks.
**A11:** **Raiz**. Tasks filhas são disparadas pela conclusão da task pai.

**Q12:** Qual conector provê menor latência para dados do Kafka?
**A12:** Kafka connector com modo **Snowpipe Streaming** (inserção direta de linhas, sem arquivos).

**Q13:** Streams podem ser criados em dynamic tables?
**A13:** Não. Dynamic tables não podem ser fontes para streams.

**Q14:** O que VALIDATION_MODE faz no COPY INTO?
**A14:** Executa uma simulação — verifica dados sem realmente carregar nada na tabela.

**Q15:** Snowpark executa computação onde?
**A15:** Na computação do **Snowflake** — dados ficam no Snowflake, sem movimentação para fora.

---

## EXPLIQUE COMO SE EU TIVESSE 5 ANOS -- Domínio 3

**1. COPY INTO vs Snowpipe**
COPY INTO é como encher um balde de água no poço — você vai, enche e volta. Snowpipe é como ter um cano que enche automaticamente quando detecta que precisa de água.

**2. Snowpipe Streaming**
É ainda mais rápido que o cano! É como um bebedouro — cada gota (linha de dados) chega no momento que você precisa, sem esperar pelo balde.

**3. Streams**
Um caderno mágico que anota tudo que muda na sua caixa de brinquedos. "Teddy foi adicionado!" "Carrinho foi removido!" Quando você lê o caderno, ele limpa as anotações e começa de novo.

**4. Tasks**
Um despertador que diz "a cada 5 minutos, verifique se tem algo novo no caderno mágico (stream) e organize a estante." Funciona sozinho, sem você precisar lembrar.

**5. Dynamic Tables**
Você diz "eu quero que esta prateleira sempre tenha os brinquedos ordenados por tamanho." O Snowflake automaticamente reorganiza quando você adiciona ou remove brinquedos. Você só descreveu O QUE quer, não COMO fazer.

**6. Stages**
Caixas de correio para seus dados. User stage é SUA caixa pessoal. Table stage é a caixa da mesa específica. Named stage é uma caixa que você pode nomear e compartilhar.

**7. External Tables**
Uma janela que olha para a garagem do vizinho. Você pode VER o que tem lá, mas não pode MOVER nada. Os dados ficam no lugar deles, você só observa.

**8. Iceberg Tables**
Brinquedos que funcionam com qualquer marca. Seu LEGO (Snowflake) e o LEGO do amigo (Spark) podem construir no mesmo tabuleiro. Managed = você controla. Unmanaged = o amigo controla.

**9. FLATTEN**
Você tem uma caixa com caixinhas dentro, que têm brinquedos. FLATTEN abre todas as caixinhas e coloca todos os brinquedos em uma fila organizada.

**10. External Functions**
Quando você precisa de ajuda de fora. É como ligar para a pizzaria (API externa) no meio do jantar — você espera a pizza chegar e continua comendo.

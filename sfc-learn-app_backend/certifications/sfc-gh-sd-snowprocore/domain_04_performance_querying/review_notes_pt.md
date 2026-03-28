# DOMÍNIO 4: OTIMIZAÇÃO DE PERFORMANCE, CONSULTAS E TRANSFORMAÇÃO
## 21% do exame = ~21 questões

---

## 4.1 CACHING (MUITO TESTADO)

O Snowflake possui TRÊS camadas de cache. Cada uma funciona de forma diferente.

### 1. Query Result Cache
- Armazena o RESULTADO de consultas executadas anteriormente
- Duração: 24 horas (reinicia se a mesma consulta executar novamente, máximo de 31 dias de renovação)
- Escopo: COMPARTILHADO entre todos os usuários na conta
- Localização: Camada de Cloud Services
- Custo: GRATUITO (nenhum warehouse necessário para retornar resultado em cache)
- Condições para cache hit:
  - Texto SQL exatamente igual
  - Mesmo role
  - Dados subjacentes NÃO mudaram
  - Mesmas configurações de sessão
- Usuário diferente, mesmo role → AINDA usa o cache
- Pode desabilitar: ALTER SESSION SET USE_CACHED_RESULT = FALSE

**Armadilha do exame**: "Usuário diferente executa mesma consulta?" → SIM, usa Result Cache (mesmo role + dados inalterados). SE VOCÊ VIR "cache por usuário" ou "cada usuário tem seu próprio cache" → ARMADILHA! Result cache é COMPARTILHADO entre usuários.
**Armadilha do exame**: "Duração do result cache?" → 24 horas (renovável até 31 dias). SE VOCÊ VIR "indefinido" ou "permanente" → ARMADILHA! Máximo é 31 dias, reinicia após 24h sem reutilização.
**Armadilha do exame**: "Result cache armazenado onde?" → Camada de Cloud Services. SE VOCÊ VIR "warehouse" ou "SSD" ou "disco local" → ARMADILHA! Result cache fica em Cloud Services, não em nenhum warehouse.
**Armadilha do exame**: "Custo do result cache hit?" → Zero (sem créditos de warehouse). SE VOCÊ VIR "warehouse necessário" ou "consome créditos" com result cache → ARMADILHA! Result cache é GRATUITO, servido por Cloud Services.

### 2. Warehouse Cache (Local Disk / SSD Cache)
- Faz cache de dados brutos da tabela no SSD local do warehouse
- Acelera consultas subsequentes nos mesmos dados
- Duração: enquanto o warehouse estiver RODANDO
- **PERDIDO quando o warehouse é suspenso**
- Cada warehouse tem seu próprio cache (não compartilhado)

**Armadilha do exame**: "Warehouse suspende → cache?" → Local disk cache é PERDIDO. SE VOCÊ VIR "cache persiste" ou "sobrevive à suspensão" → ARMADILHA! SSD cache é apagado no momento da suspensão.
**Armadilha do exame**: "Qual cache é perdido ao suspender?" → Warehouse cache / Local Disk (SSD) Cache. SE VOCÊ VIR "result cache" como resposta → ARMADILHA! Result cache está em Cloud Services e nunca é perdido ao suspender.

### 3. Metadata Cache
- Armazena metadados da tabela (contagem de linhas, min/max, tamanho em bytes)
- Usado para: COUNT(*), MIN, MAX na tabela inteira (sem filtro)
- Camada de Cloud Services gerencia isso
- Nenhum warehouse necessário para consultas puramente de metadados
- Sempre disponível, não pode ser desabilitado

### Fluxo de Decisão do Cache:
```
Query arrives →
  1. Check Result Cache (exact match?) → YES → return instantly (free)
  2. Check Metadata Cache (metadata-only query?) → YES → return from metadata (free)
  3. Run on Warehouse → uses Warehouse Cache for data reads
```

### Por Que Isso Importa + Casos de Uso

**Por que os caches importam tanto?** Porque o Snowflake cobra por segundo de computação. Se um cache pode responder sua consulta GRATUITAMENTE, isso é dinheiro real economizado — especialmente em escala com centenas de usuários.

**Cenário real — "Nosso dashboard custa $500/dia em créditos de warehouse"**
As mesmas 10 consultas do dashboard executam a cada 5 minutos para 50 usuários. Mas os dados subjacentes mudam apenas uma vez por hora. Solução: Result Cache lida com 95% dessas consultas GRATUITAMENTE (sem inicialização de warehouse). Apenas a primeira execução após mudança de dados custa créditos.

**Cenário real — "Suspendemos o warehouse durante a noite para economizar, mas as consultas da manhã estão lentas"**
O SSD cache do warehouse foi apagado ao suspender. As primeiras consultas do dia precisam reler do armazenamento remoto. Esta é a penalidade de "cold start". Trade-off: economizar créditos à noite vs. consultas iniciais mais lentas. Para dashboards críticos, considere um timeout de auto-suspend mais longo.

**Cenário real — "Nossa consulta escaneia 500GB mas retorna apenas 100 linhas"**
Problema clássico de pruning. A tabela tem bilhões de linhas mas a cláusula WHERE não consegue pular partições eficientemente. Correção: adicione uma clustering key na coluna filtrada. Após o clustering, a mesma consulta escaneia 2GB em vez de 500GB.

**Cenário real — "A consulta gigante de um analista está bloqueando todos os outros"**
50 usuários estão na fila atrás de um relatório massivo. Scale OUT (multi-cluster) para que a consulta grande tenha seu próprio cluster e todos os outros tenham os deles. Também defina STATEMENT_TIMEOUT para encerrar consultas que executam por tempo demais.

---

### Melhores Práticas — Performance
- Não desabilite o result cache (USE_CACHED_RESULT = TRUE é o padrão — mantenha)
- Evite SELECT * — consulte apenas as colunas necessárias (pruning columnar)
- Use clustering keys APENAS em tabelas multi-TB com padrões de filtro conhecidos
- Verifique o Query Profile para TableScan: se partições escaneadas ≈ total, adicione clustering key
- Use EXPLAIN USING TABULAR para visualizar o plano de consulta sem executá-la
- Defina STATEMENT_TIMEOUT no nível do warehouse para encerrar consultas descontroladas


### Exemplos de Perguntas de Cenário — Caching

**Cenário:** A retail company runs an executive dashboard that refreshes every 2 minutes. The same 5 SQL queries are executed by 30 different analysts throughout the day. The underlying sales data is loaded via a nightly ETL job (once every 24 hours). The team notices their warehouse is running all day and costing significant credits. How can they reduce costs without changing the dashboard?
**Resposta:** Since the underlying data only changes once per day (nightly ETL), the **Result Cache** will serve all repeated queries for free after the first execution — as long as the SQL text is identical, the role is the same, and the data hasn't changed. The warehouse only needs to run for the first execution after each nightly load. The team should ensure USE_CACHED_RESULT = TRUE (the default) and that the dashboard uses parameterized queries with consistent SQL text. They can also set a short auto-suspend timeout (1-2 minutes) so the warehouse stops between the rare cache misses. This could eliminate 95%+ of warehouse credit consumption.

**Cenário:** A data engineering team suspends their XL warehouse every night at 8 PM to save credits. Every morning at 7 AM, the first batch of queries takes 3-4x longer than normal. By 8 AM, query performance is back to normal. What is causing this, and what are the trade-offs of fixing it?
**Resposta:** When the warehouse is suspended, the **Warehouse Cache (SSD/Local Disk Cache)** is completely wiped. The first morning queries must re-read all data from remote storage (cold start), which is much slower. By 8 AM, the SSD cache is warm again from repeated reads. The trade-off: keeping the warehouse running overnight preserves the cache but costs credits for idle time. Options: (1) accept the cold start penalty and save overnight credits, (2) increase auto-suspend to a longer timeout so it only suspends after extended inactivity, or (3) schedule a lightweight "warm-up" query to run just before the 7 AM workload begins.

**Cenário:** An analyst runs `SELECT COUNT(*) FROM sales_fact;` on a 500 billion-row table. The query returns instantly in under 1 second without a warehouse running. Another analyst runs `SELECT COUNT(*) FROM sales_fact WHERE region = 'EMEA';` and it takes 45 seconds with a warehouse. Why the dramatic difference?
**Resposta:** The first query (`COUNT(*)` with no filter) is answered by the **Metadata Cache**, which stores pre-computed statistics like row counts, min/max values, and byte sizes. This is served by the Cloud Services layer for free — no warehouse needed. The second query includes a WHERE clause, so Snowflake cannot use metadata alone; it must actually scan (and prune) micro-partitions on a running warehouse. The metadata cache only works for full-table aggregate operations without filters.

**Cenário:** User A (role: ANALYST_ROLE) runs a complex 20-table join query that takes 8 minutes. User B (role: ANALYST_ROLE) runs the exact same query 10 minutes later. User C (role: FINANCE_ROLE) runs the same query 5 minutes after User B. Which users benefit from the result cache?
**Resposta:** **User B** gets a result cache hit — same SQL text, same role (ANALYST_ROLE), and data unchanged within 24 hours. The query returns instantly with zero warehouse cost. **User C** does NOT get a result cache hit, even though the SQL is identical, because User C is using a different role (FINANCE_ROLE). The result cache requires the same role, same SQL text, and unchanged underlying data. User C's query will execute fully on the warehouse.

---

---

## 4.2 QUERY PROFILE & QUERY INSIGHTS (MUITO TESTADO)

### Query Profile:
- Plano de execução visual no Snowsight
- Mostra: operadores, fluxo de dados, estatísticas
- Use para identificar gargalos de performance

### Métricas-chave no Query Profile:

**Bytes Spilled to Local Storage (Local Disk Spilling)**:
- A consulta precisou de mais memória do que a disponível
- Dados transbordaram para o SSD local
- Correção: AUMENTE o tamanho do warehouse (scale UP)

**Bytes Spilled to Remote Storage (Remote Disk Spilling)**:
- Ainda pior — transbordou além do SSD local para armazenamento remoto
- Muito mais lento
- Correção: AUMENTE o tamanho do warehouse significativamente

**Pruning Ineficiente**:
- Muitas partições escaneadas vs partições necessárias
- Proporção scan-para-filtro é alta
- Correção: adicione clustering key, revise cláusulas WHERE
- Causa comum: usar funções em colunas de filtro (ex: WHERE UPPER(col) = 'X')

**Exploding Joins**:
- Join produz muito mais linhas do que a entrada
- Geralmente produto Cartesiano ou condição de join ausente
- Correção: revise condições de join, adicione predicados adequados

**Queuing**:
- Consultas esperando por recursos do warehouse
- Correção: scale OUT (adicionar clusters via multi-cluster warehouse)
- Não: scale UP (tamanho maior não ajuda com queuing)

### Regras-chave:
- Spilling (local ou remoto) → Scale UP (warehouse maior)
- Queuing / concorrência → Scale OUT (mais clusters)
- Problemas de pruning → Melhor clustering, corrigir cláusulas WHERE

**Armadilha do exame**: "Correção para Local Disk Spilling?" → Aumentar tamanho do warehouse (scale UP). SE VOCÊ VIR "adicionar clusters" ou "scale out" para spilling → ARMADILHA! Spilling = problema de memória = scale UP, não OUT.
**Armadilha do exame**: "Correção para Remote Disk Spilling?" → Aumentar tamanho do warehouse ainda mais. SE VOCÊ VIR "scale out" ou "multi-cluster" para remote spilling → ARMADILHA! Remote spill é um problema de memória pior = scale UP significativamente.
**Armadilha do exame**: "Queuing alto?" → Adicionar clusters (scale OUT). SE VOCÊ VIR "warehouse maior" ou "scale up" para queuing → ARMADILHA! Queuing = problema de concorrência = scale OUT com mais clusters.
**Armadilha do exame**: "Privilégio MONITOR necessário para?" → Ver Query Profiles de outros usuários. SE VOCÊ VIR "OPERATE" ou "USAGE" como privilégio → ARMADILHA! Apenas MONITOR concede acesso aos Query Profiles de outros usuários.

### Query History:
- ACCOUNT_USAGE.QUERY_HISTORY → 365 dias, até 3h de latência
- INFORMATION_SCHEMA.QUERY_HISTORY() → 7 dias, tempo real
- Mostra: texto da consulta, duração, warehouse, bytes escaneados, linhas retornadas

### Query Attribution:
- Rastreie consumo de recursos por consulta
- Entenda quais consultas usam mais créditos/recursos


### Exemplos de Perguntas de Cenário — Query Profile & Query Insights

**Cenário:** A financial services company has a nightly reconciliation query that normally takes 15 minutes. Last night it took 2.5 hours. The DBA opens the Query Profile and sees "Bytes Spilled to Local Storage: 85 GB" and "Bytes Spilled to Remote Storage: 210 GB." The warehouse is a Medium. What happened, and what is the correct fix?
**Resposta:** The query ran out of memory on the Medium warehouse and **spilled** data first to local SSD (85 GB), then to much slower remote storage (210 GB). Remote spilling is extremely expensive in terms of performance. The fix is to **scale UP** — increase the warehouse size to Large or XL to provide more memory so the query can process in-memory without spilling. Scaling OUT (adding clusters) would NOT help here because spilling is a memory problem for a single query, not a concurrency problem. The DBA should also check if the query changed (new joins, more data) to understand why it suddenly needs more memory.

**Cenário:** A BI team reports that their morning dashboard queries are slow. The Query Profile shows that a query on the `orders` table scans 12,000 out of 12,500 total micro-partitions, but only returns 500 rows where `order_date = '2025-12-01'`. What is the issue, and how should it be fixed?
**Resposta:** This is a **pruning problem**. The query is scanning nearly all micro-partitions (12,000/12,500 = 96%) but only needs a tiny fraction of the data. The `order_date` column is not well-clustered, so Snowflake cannot skip irrelevant partitions. The fix: add a **clustering key** on `order_date` with `ALTER TABLE orders CLUSTER BY (order_date)`. After automatic clustering reorganizes the data, the same query might scan only 50-100 partitions instead of 12,000. Also check that the WHERE clause doesn't wrap the column in a function (e.g., `WHERE DATE_TRUNC('day', order_date)`) — functions on filter columns prevent pruning.

**Cenário:** A SaaS company has 150 concurrent users running reports on a single Large multi-cluster warehouse (max 3 clusters, Standard scaling). Users complain that queries are "stuck" and taking much longer than usual. The Query Profile shows minimal spilling but significant time in the "Initialization" phase. What is the problem?
**Resposta:** The queries are **queuing** — waiting for available compute resources. With 150 concurrent users, even 3 clusters may not be enough. The "Initialization" wait time indicates queries sitting in the queue before execution begins. The fix is to **scale OUT** — either increase the maximum cluster count beyond 3, or create separate warehouses for different user groups (e.g., finance vs. operations). Scaling UP (bigger warehouse) would NOT help because the problem is concurrency (too many queries), not memory. They should also check STATEMENT_QUEUED_TIMEOUT_IN_SECONDS to auto-cancel queries that wait too long.

**Cenário:** A developer writes a query joining `customers` (10M rows) with `addresses` (50M rows) but accidentally omits the join condition, writing `FROM customers, addresses` instead of using a proper ON clause. The Query Profile shows the output has 500 trillion rows. What happened?
**Resposta:** This is an **exploding join** (Cartesian product). Without a join condition, every row in `customers` is matched with every row in `addresses`: 10M x 50M = 500 trillion rows. The Query Profile would show the join operator producing massively more rows than the input. The fix: add the proper join predicate (`ON customers.customer_id = addresses.customer_id`). Always check join conditions when the Query Profile shows output rows >> input rows. This is a common exam scenario — if a join produces way more rows than expected, the answer is almost always a missing or incorrect join condition.

---

---

## 4.3 SERVIÇOS DE OTIMIZAÇÃO DE PERFORMANCE

### Query Acceleration Service (QAS) — Enterprise+
- Transfere porções de consultas de scan grandes para computação serverless
- Melhor para: consultas que escaneiam muitos dados (scans de tabelas grandes)
- Serverless (computação gerenciada pelo Snowflake, cobrado por uso)
- Você habilita no warehouse: ALTER WAREHOUSE SET ENABLE_QUERY_ACCELERATION = TRUE
- Pode definir fator de escala (1-100) para controlar computação serverless máxima
- NÃO ajuda com: consultas pequenas, consultas já rápidas

**Como funciona**: A consulta tem uma grande porção de scan → QAS distribui partes do scan para computação serverless extra → resultados são mesclados de volta → execução mais rápida

### Search Optimization Service (SOS) — Enterprise+
- Estrutura de dados persistente (como um índice secundário)
- Melhor para: consultas de point lookup em colunas de alta cardinalidade
- Exemplo: buscar um ID de transação específico em bilhões de linhas
- Manutenção em background (serverless, custa créditos)
- Snowflake mantém automaticamente os search access paths
- Reduz necessidade de clustering manual em colunas de lookup

**Armadilha do exame**: "Lookup de ID específico em bilhões de linhas?" → Search Optimization Service. SE VOCÊ VIR "Query Acceleration" para point lookups → ARMADILHA! QAS é para scans grandes. SOS é para lookups de ID/valor específico.
**Armadilha do exame**: "SOS é como um..." → Índice secundário / access paths. SE VOCÊ VIR "materialized view" ou "resultado em cache" → ARMADILHA! SOS constrói search access paths (como um índice), não resultados pré-computados.
**Armadilha do exame**: "QAS transfere para..." → Recursos de computação serverless compartilhados. SE VOCÊ VIR "warehouse dedicado" ou "computação gerenciada pelo usuário" → ARMADILHA! QAS usa computação serverless gerenciada pelo Snowflake, não seu warehouse.
**Armadilha do exame**: "Ambos QAS e SOS são..." → Edição Enterprise+. SE VOCÊ VIR "edição Standard" ou "todas as edições" → ARMADILHA! QAS, SOS e Materialized Views todos requerem Enterprise+ no mínimo.

### Clustering Keys
- Defina quais colunas usar para clustering
- ALTER TABLE ... CLUSTER BY (col1, col2)
- Automatic Clustering: serviço em background mantém o clustering
- Serverless (custa créditos para manutenção)
- Melhor para: tabelas muito grandes onde consultas filtram em colunas específicas
- Co-localiza dados similares em micro-partitions → melhor pruning

**Armadilha do exame**: "Adicionar clustering key em tabela existente?" → ALTER TABLE ... CLUSTER BY. SE VOCÊ VIR "CREATE TABLE" ou "recriar tabela" → ARMADILHA! Você adiciona clustering em tabelas existentes com ALTER TABLE, sem necessidade de rebuild.
**Armadilha do exame**: "Custo do automatic clustering?" → Créditos serverless (manutenção em background). SE VOCÊ VIR "gratuito" ou "sem custo" → ARMADILHA! Definir a key é gratuito, mas a manutenção automática consome créditos serverless.

### Materialized Views — Enterprise+
- Resultados de consulta pré-computados armazenados fisicamente
- Atualizados automaticamente quando dados subjacentes mudam (serviço em background, custa créditos)
- Melhor para: consultas caras em dados que mudam raramente
- Limitações: apenas tabela única, recursos SQL limitados
- Pode usar Search Optimization em materialized views


### Exemplos de Perguntas de Cenário — Performance Optimization Services

**Cenário:** A logistics company has a 2 TB `shipments` table with 8 billion rows. Their operations team frequently searches for individual shipment tracking numbers (e.g., `WHERE tracking_id = 'TRK-2025-8847291'`). These lookup queries take 30-60 seconds each. The team is considering enabling Query Acceleration Service. Is this the right choice?
**Resposta:** No — **Search Optimization Service (SOS)** is the correct choice, not QAS. This is a **point lookup** scenario: searching for a specific value in a high-cardinality column across billions of rows. SOS builds persistent search access paths (like a secondary index) optimized for equality predicates, IN lists, and LIKE patterns. QAS is designed for large table scans, not targeted lookups. Enable SOS with `ALTER TABLE shipments ADD SEARCH OPTIMIZATION ON EQUALITY(tracking_id)`. After the background service builds the access paths, these lookups should drop from 30-60 seconds to under 1 second. SOS requires Enterprise+ edition.

**Cenário:** A media company runs ad-hoc analytics queries against a 5 TB `user_events` table. Most queries are fast, but occasionally an analyst runs a query that scans the entire table and takes 20+ minutes, blocking other work. The team wants to speed up these outlier queries without permanently upsizing the warehouse. What service should they use?
**Resposta:** **Query Acceleration Service (QAS)** is ideal here. QAS offloads the scan-heavy portions of eligible queries to Snowflake-managed serverless compute, letting the outlier query finish faster without affecting other queries on the warehouse. Enable it with `ALTER WAREHOUSE analytics_wh SET ENABLE_QUERY_ACCELERATION = TRUE` and set a scale factor (e.g., 8) to control the maximum serverless compute allowed. QAS is billed per-use (serverless credits) so it only costs money when those outlier queries actually trigger it. This avoids the cost of permanently running a larger warehouse just for occasional heavy queries. Enterprise+ required.

**Cenário:** A healthcare analytics team runs the same expensive aggregation — total patient visits by department, region, and month — dozens of times per day. The underlying `patient_visits` table (800 GB) is only updated once daily via a batch load. Each execution takes 4 minutes on a Large warehouse. What optimization would provide the best performance improvement?
**Resposta:** A **Materialized View** is the best fit. Since the query is expensive (4 min), repeated frequently, and the underlying data changes infrequently (once daily), a materialized view will pre-compute and physically store the aggregation results. Subsequent reads of the MV will be nearly instant since Snowflake reads the pre-computed result rather than re-scanning 800 GB. Snowflake automatically refreshes the MV when the base table changes (after the daily load). The trade-off: MVs consume storage and serverless credits for auto-refresh maintenance. Limitations to remember: MVs can only reference a single base table and support limited SQL features (no joins, no UDFs). Enterprise+ required.

**Cenário:** A fintech company has a 10 TB `transactions` table. Queries always filter by `transaction_date` and the table grows by 500 million rows per day. Query performance has degraded over time — the Query Profile shows poor pruning (scanning 80% of partitions). They've already tried increasing warehouse size with no improvement. What should they do?
**Resposta:** Add a **clustering key** on `transaction_date` with `ALTER TABLE transactions CLUSTER BY (transaction_date)`. As the table grows, new data is appended in ingestion order, which may not align with `transaction_date`. This causes date ranges to be scattered across many micro-partitions, resulting in poor pruning. A clustering key tells Snowflake's Automatic Clustering service to reorganize micro-partitions so rows with similar `transaction_date` values are co-located. After reclustering, queries filtering by date will skip most partitions. Note: clustering keys work on ALL editions, but the Automatic Clustering background maintenance consumes serverless credits. Scaling UP the warehouse wouldn't help here — the problem is I/O (reading too many partitions), not memory.

---

---

## 4.4 MELHORES PRÁTICAS DE GERENCIAMENTO DE WORKLOAD

### Agrupe workloads similares:
- Warehouses separados para: carregamento ETL, relatórios BI, consultas ad-hoc, data science
- Previne que um workload prive outro de recursos

### Dimensione warehouses corretamente:
- Comece pequeno, scale up se necessário
- Consultas complexas → warehouse maior
- Consultas simples → warehouse pequeno
- Carregamento → depende do número de arquivos (não apenas volume de dados)

### Use auto-suspend:
- Economize créditos quando o warehouse estiver ocioso
- Timeout curto para workloads interativos (1-5 minutos)
- Timeout mais longo para ferramentas BI com consultas frequentes

### Parâmetros de timeout:
- STATEMENT_TIMEOUT_IN_SECONDS → encerra consultas que executam por tempo demais
- STATEMENT_QUEUED_TIMEOUT_IN_SECONDS → encerra consultas esperando tempo demais na fila

**Armadilha do exame**: "Política de scaling Economy vs Standard?" → Economy espera ~6 min antes de adicionar clusters (economiza créditos). Standard adiciona imediatamente. SE VOCÊ VIR "Economy adiciona clusters mais rápido" ou "imediatamente" com Economy → ARMADILHA! Economy ESPERA ~6 min. Standard é o rápido.
**Armadilha do exame**: "Auto-suspend definido como 0?" → Warehouse NUNCA auto-suspende. SE VOCÊ VIR "suspensão imediata" ou "desligamento instantâneo" para 0 → ARMADILHA! 0 = desabilitado = warehouse roda para sempre até ser suspenso manualmente.
**Armadilha do exame**: "STATEMENT_TIMEOUT vs STATEMENT_QUEUED_TIMEOUT?" → TIMEOUT encerra consultas em execução. QUEUED_TIMEOUT encerra consultas ainda esperando na fila. SE VOCÊ VIR estes trocados → ARMADILHA! TIMEOUT = executando. QUEUED_TIMEOUT = esperando.


### Exemplos de Perguntas de Cenário — Workload Management Best Practices

**Cenário:** A company has a single XL warehouse shared by the ETL team (heavy nightly loads), the BI team (daytime dashboards), and the data science team (ad-hoc ML queries). The BI team complains that their dashboards are slow every morning while the ETL job is still finishing. What is the recommended architectural change?
**Resposta:** Create **separate warehouses** for each workload type: one for ETL loading, one for BI reporting, and one for data science ad-hoc queries. This is Snowflake's core best practice for workload isolation — it prevents one workload from starving another. The ETL warehouse can be sized larger (XL) for heavy transforms, the BI warehouse can be a Medium multi-cluster warehouse for high concurrency, and the data science warehouse can be a Large with aggressive auto-suspend since usage is sporadic. Each team gets dedicated resources and predictable performance.

**Cenário:** An e-commerce company uses an Enterprise edition warehouse with Economy scaling policy (min 1, max 5 clusters). During Black Friday, users report that queries are queuing for several minutes before executing, even though the system is allowed up to 5 clusters. Support confirms only 2 clusters are running. What is happening?
**Resposta:** The **Economy scaling policy** waits approximately 6 minutes of sustained queuing before adding a new cluster — it prioritizes cost savings over immediate performance. During a traffic spike like Black Friday, this 6-minute delay per cluster means it takes a long time to scale from 1 to 5 clusters. The fix: switch to **Standard scaling policy**, which adds clusters immediately when queries begin queuing. Standard is the right choice for performance-sensitive, user-facing workloads. Economy is better suited for cost-sensitive batch workloads where a few minutes of queuing is acceptable.

**Cenário:** A team has a warehouse that processes bursts of queries every 30 minutes (triggered by a scheduler) but sits completely idle in between. The auto-suspend is set to 10 minutes. They notice they're paying for 20 minutes of idle time per hour. What should they change?
**Resposta:** Reduce the **auto-suspend timeout** to 1-2 minutes (e.g., `ALTER WAREHOUSE SET AUTO_SUSPEND = 60`). Since the workload is bursty with 30-minute gaps, a 10-minute timeout means the warehouse runs idle for 10 minutes after each burst before suspending — wasting credits. With a 1-minute timeout, it suspends almost immediately after the burst completes. Auto-resume (enabled by default) will automatically restart the warehouse when the next scheduled burst arrives. The trade-off: the first query of each burst will have a small cold-start delay (a few seconds for warehouse provisioning), but the credit savings from 28+ minutes of avoided idle time per hour far outweigh this.

**Cenário:** A data platform team discovers that a single analyst's query has been running for 14 hours, consuming an XL warehouse the entire time. It appears to be an accidental Cartesian join. How can they prevent this from happening again?
**Resposta:** Set **STATEMENT_TIMEOUT_IN_SECONDS** at the warehouse level to automatically kill queries that exceed a reasonable duration. For example, `ALTER WAREHOUSE SET STATEMENT_TIMEOUT_IN_SECONDS = 3600` would kill any query running longer than 1 hour. They should also set **STATEMENT_QUEUED_TIMEOUT_IN_SECONDS** to prevent queries from waiting indefinitely in queue. These parameters can be set at the account, warehouse, or session level. For the immediate issue, the admin can manually cancel the running query. Important distinction: STATEMENT_TIMEOUT kills *running* queries, while STATEMENT_QUEUED_TIMEOUT kills queries *waiting in the queue* — don't confuse them on the exam.

---

---

## 4.5 TIPOS DE DADOS E TRANSFORMAÇÃO

### Dados Estruturados:
- Tipos SQL padrão: VARCHAR, NUMBER, DATE, TIMESTAMP, BOOLEAN, etc.
- Operações padrão de tabela

### Dados Semi-Estruturados:
- Armazenados em colunas VARIANT, OBJECT, ARRAY
- Navegue com notação de ponto: col:key.subkey
- Converta com notação ::type: col:name::string
- Funções-chave:
  - PARSE_JSON() → string para VARIANT
  - FLATTEN() → expandir arrays/objetos em linhas
  - LATERAL FLATTEN → juntar saída achatada com outras colunas
  - OBJECT_KEYS() → obter todas as chaves
  - ARRAY_SIZE() → contar elementos do array
  - TYPEOF() → verificar tipo do VARIANT
  - GET_PATH() / GET() → extrair valores

### Dados Não-Estruturados:
- Imagens, PDFs, áudio, vídeo
- Armazenados em stages internos/externos
- Tipo de dados FILE para referências
- Processe com UDFs, external functions ou Cortex AI

**Armadilha do exame**: "FLATTEN vs PARSE_JSON?" → PARSE_JSON converte uma string PARA VARIANT. FLATTEN expande VARIANT EM linhas. SE VOCÊ VIR estes trocados ou tratados como iguais → ARMADILHA! PARSE_JSON = string→VARIANT. FLATTEN = VARIANT→linhas. Direções opostas.
**Armadilha do exame**: "Notação de ponto col:key funciona em VARCHAR?" → ERRADO. SE VOCÊ VIR "col:key" em uma coluna VARCHAR → ARMADILHA! Notação de ponto só funciona em VARIANT/OBJECT. Deve usar PARSE_JSON primeiro se for uma string.
**Armadilha do exame**: "ARRAY e OBJECT são o mesmo que VARIANT?" → ERRADO. SE VOCÊ VIR "intercambiáveis" ou "idênticos" → ARMADILHA! VARIANT é o contêiner genérico. ARRAY = lista ordenada, OBJECT = pares chave-valor. Três tipos distintos.


### Exemplos de Perguntas de Cenário — Data Types & Transformation

**Cenário:** A company ingests IoT sensor data as JSON into a `sensor_readings` table with a VARIANT column called `payload`. A typical record looks like: `{"device_id": "D-4421", "readings": [{"temp": 72.5, "humidity": 45}, {"temp": 73.1, "humidity": 44}], "timestamp": "2025-06-15T10:30:00Z"}`. An analyst needs to produce one row per individual reading with the device ID and timestamp. How should they write this query?
**Resposta:** Use **LATERAL FLATTEN** to expand the nested `readings` array into individual rows, combined with dot notation and casting to extract the scalar values:
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

**Cenário:** A developer stores API response data as a VARCHAR column containing JSON strings (not VARIANT). They try to query it with `SELECT api_response:status_code FROM api_logs` and get an error. What is wrong, and how should they fix it?
**Resposta:** Dot notation (`col:key`) only works on **VARIANT, OBJECT, or ARRAY** columns — not on VARCHAR. Even though the VARCHAR contains valid JSON text, Snowflake treats it as a plain string. The fix: use **PARSE_JSON()** to convert the string to VARIANT first: `SELECT PARSE_JSON(api_response):status_code::NUMBER FROM api_logs`. Alternatively, the better long-term fix is to change the column type to VARIANT during ingestion. Remember: PARSE_JSON converts string→VARIANT (parsing direction), while FLATTEN converts VARIANT→rows (expanding direction). These are opposite operations and a common exam confusion point.

**Cenário:** A data engineer is migrating a legacy system that stores customer preferences as deeply nested JSON. Some customers have preferences nested 5+ levels deep (e.g., `payload:settings:notifications:email:frequency:value`). They ask whether Snowflake's VARIANT column can handle this depth, and whether there are performance considerations for deeply nested semi-structured data.
**Resposta:** Snowflake's VARIANT type can handle arbitrary nesting depth — there is no hard limit on JSON nesting levels. However, there are performance considerations. Snowflake automatically extracts and optimizes commonly accessed top-level keys in VARIANT columns into a columnar format for better pruning and performance. Deeply nested paths may not benefit from this automatic optimization. For frequently queried deep paths, consider: (1) using FLATTEN to normalize deeply nested structures into separate rows/columns at ingestion time, (2) creating a view that extracts commonly used paths with `GET_PATH()` or dot notation, or (3) materializing frequently accessed nested values into dedicated typed columns for better query performance and pruning.

---

---

## 4.6 TÉCNICAS DE CONSULTA SQL

### Funções de Agregação:
- COUNT, SUM, AVG, MIN, MAX, LISTAGG
- GROUP BY, HAVING
- GROUPING SETS, ROLLUP, CUBE (para subtotais)

### Window Functions:
- Realizam cálculos através de linhas relacionadas
- Sintaxe: function() OVER (PARTITION BY col ORDER BY col)
- Comuns: ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, SUM, AVG
- ROWS BETWEEN / RANGE BETWEEN para especificação de frame
- Totais acumulados, médias móveis, ranking

### Common Table Expressions (CTEs):
- Cláusula WITH para subconsultas legíveis e reutilizáveis
- Melhoram a legibilidade de consultas complexas
- Podem referenciar CTEs anteriores no mesmo bloco WITH

### LATERAL:
- Usado com FLATTEN para juntar resultados achatados com a linha de origem
- SELECT t.id, f.value FROM table t, LATERAL FLATTEN(input => t.array_col) f

### Dicas de Otimização de Consulta:
- Filtre cedo (cláusulas WHERE fazem pushdown)
- Evite SELECT * (escaneia colunas desnecessárias)
- Use clustering keys para filtros em tabelas grandes
- Evite funções em colunas filtradas (impede pruning)
- Use LIMIT para consultas exploratórias
- Evite joins Cartesianos (sempre tenha condições de join)

**Armadilha do exame**: "QUALIFY vs HAVING vs WHERE?" → WHERE = antes do agrupamento. HAVING = após GROUP BY. QUALIFY = após window functions. SE VOCÊ VIR "intercambiáveis" ou qualquer um destes trocados → ARMADILHA! Cada um filtra em um estágio diferente da execução da consulta.
**Armadilha do exame**: "RANK vs DENSE_RANK vs ROW_NUMBER?" → ROW_NUMBER = sempre único (1,2,3). RANK = lacunas em empates (1,1,3). DENSE_RANK = sem lacunas (1,1,2). SE VOCÊ VIR "RANK e DENSE_RANK são iguais" → ARMADILHA! RANK pula números após empates, DENSE_RANK não.
**Armadilha do exame**: "PIVOT vs UNPIVOT?" → PIVOT = linhas→colunas (alto→largo). UNPIVOT = colunas→linhas (largo→alto). SE VOCÊ VIR estes invertidos → ARMADILHA! PIVOT torna mais largo, UNPIVOT torna mais alto. Exatos opostos.


### Exemplos de Perguntas de Cenário — SQL Query Techniques

**Cenário:** A sales manager needs a report showing each salesperson's monthly revenue alongside a running total for the year. The output should keep every individual monthly row visible (not collapsed). A junior analyst suggests using `GROUP BY salesperson, month` with `SUM(revenue)`. Why is this approach incomplete, and what is the correct technique?
**Resposta:** GROUP BY with SUM would give the monthly total per salesperson, but it cannot produce a **running total** across months while keeping each row visible. The correct approach is a **window function**:
```sql
SELECT salesperson, month, revenue,
  SUM(revenue) OVER (PARTITION BY salesperson ORDER BY month
    ROWS UNBOUNDED PRECEDING) AS ytd_revenue
FROM monthly_sales;
```
The window function calculates the running sum across all preceding months within each salesperson's partition, without collapsing rows. GROUP BY collapses rows; window functions preserve them. This is a key exam distinction — if the question says "keep all rows" or "running total," think window functions, not GROUP BY.

**Cenário:** A data team has a `user_logins` table with duplicate entries (same user can log in multiple times per day). They need to keep only the most recent login per user per day. An analyst writes a subquery with GROUP BY and MAX(login_time), then joins back to get the full row. A senior engineer suggests a simpler approach. What is it?
**Resposta:** Use **QUALIFY** with **ROW_NUMBER()** — this is the idiomatic Snowflake approach for deduplication:
```sql
SELECT *
FROM user_logins
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY user_id, DATE(login_time)
  ORDER BY login_time DESC
) = 1;
```
QUALIFY filters the results of window functions directly, eliminating the need for a subquery or CTE wrapper. It executes after window functions are computed (just like HAVING executes after GROUP BY). The execution order is: WHERE → GROUP BY/HAVING → Window Functions → QUALIFY. Remember: QUALIFY is Snowflake-specific (not ANSI SQL standard) — this is a common exam point.

**Cenário:** A finance team has a `quarterly_results` table with columns: `company`, `Q1_revenue`, `Q2_revenue`, `Q3_revenue`, `Q4_revenue`. They need to transform this into a normalized format with columns: `company`, `quarter`, `revenue` — one row per company per quarter. What SQL technique should they use?
**Resposta:** Use **UNPIVOT** to convert columns into rows (wide→tall):
```sql
SELECT company, quarter, revenue
FROM quarterly_results
  UNPIVOT(revenue FOR quarter IN (Q1_revenue, Q2_revenue, Q3_revenue, Q4_revenue));
```
UNPIVOT takes the four separate quarter columns and rotates them into rows, creating a `quarter` column (with the original column names as values) and a `revenue` column (with the corresponding values). The opposite operation — PIVOT — would convert rows back into columns (tall→wide) and requires an aggregate function. On the exam, remember: PIVOT = rows→columns (makes wider), UNPIVOT = columns→rows (makes taller).

**Cenário:** A product team needs a report showing total sales by region and product category, but they also need subtotal rows for each region and a grand total row at the bottom. Writing multiple UNION ALL queries for each subtotal level seems cumbersome. What is the efficient approach?
**Resposta:** Use **ROLLUP** within GROUP BY to automatically generate hierarchical subtotals:
```sql
SELECT region, product_category, SUM(sales) AS total_sales
FROM sales_data
GROUP BY ROLLUP(region, product_category);
```
ROLLUP produces subtotals in a left-to-right hierarchy: (region, product_category), (region, NULL) for region subtotals, and (NULL, NULL) for the grand total. If they needed ALL possible combinations of subtotals (not just hierarchical), they'd use **CUBE** instead. If they only needed specific custom grouping combinations, they'd use **GROUPING SETS**. The exam tests the distinction: ROLLUP = hierarchical, CUBE = all combos, GROUPING SETS = you pick exactly which.

---

---

## 4.7 STORED PROCEDURES vs UDFs

### Stored Procedures:
- Executam lógica procedural
- Podem incluir DDL/DML (CREATE, INSERT, etc.)
- Chamados com CALL procedure_name()
- Linguagens: SQL (Snowflake Scripting), JavaScript, Python, Java, Scala
- Podem retornar um único valor

### UDFs (User-Defined Functions):
- Retornam valores para uso em expressões SQL
- Podem ser usados em SELECT, WHERE, etc.
- Linguagens: SQL, JavaScript, Python, Java
- Podem ser escalares (um valor) ou tabulares (UDTF - retorna tabela)
- Não podem executar DDL/DML

### External Functions:
- Chamam APIs externas (AWS Lambda, Azure Functions)
- Requerem API Integration
- Dados saem do Snowflake → processados externamente → retornam

**Armadilha do exame**: "Executar DDL dentro de uma função?" → Use Stored Procedure (não UDF). SE VOCÊ VIR "UDF" com CREATE/INSERT/DDL → ARMADILHA! UDFs não podem executar DDL/DML. Apenas Stored Procedures podem.
**Armadilha do exame**: "Usar em instrução SELECT?" → UDF (não Stored Procedure). SE VOCÊ VIR "CALL" dentro de SELECT ou Stored Procedure em SELECT → ARMADILHA! Procedures usam CALL, apenas UDFs funcionam dentro de SELECT/WHERE.
**Armadilha do exame**: "NÃO é uma linguagem suportada para stored procedures?" → C++ (não suportado). SE VOCÊ VIR "C++" como linguagem válida → ARMADILHA! Suportados: SQL, JavaScript, Python, Java, Scala. Sem C++.


### Exemplos de Perguntas de Cenário — Stored Procedures vs UDFs

**Cenário:** A data engineering team needs to automate an end-of-month process that: (1) creates a new archive table with the current month's name, (2) inserts all transactions from the current month into that archive table, (3) deletes the archived transactions from the main table, and (4) returns a count of rows archived. Should they use a stored procedure or a UDF?
**Resposta:** This requires a **Stored Procedure**. The process involves DDL (CREATE TABLE), DML (INSERT, DELETE), and procedural logic — none of which are allowed in a UDF. The procedure would be called with `CALL archive_monthly_transactions()`. UDFs are restricted to returning values and cannot execute DDL or DML statements. This is one of the most common exam distinctions: if the task involves CREATE, INSERT, UPDATE, DELETE, MERGE, or any schema changes, the answer is always Stored Procedure.

**Cenário:** A marketing team needs a reusable function that takes a customer's purchase history (total spend and number of orders) and returns a loyalty tier label ('Platinum', 'Gold', 'Silver', 'Bronze'). They want to use it directly in SELECT statements like: `SELECT customer_name, calculate_loyalty_tier(total_spend, order_count) FROM customers`. Should this be a procedure or a UDF?
**Resposta:** This must be a **scalar UDF** (User-Defined Function). The requirement to use it inside a SELECT statement is the key indicator — only UDFs can be embedded in SQL expressions (SELECT, WHERE, HAVING, etc.). Stored procedures are invoked with CALL and cannot be used inside queries. The UDF would accept two numeric inputs and return a VARCHAR tier label. It could be written in SQL, Python, Java, or JavaScript. Example: `CREATE FUNCTION calculate_loyalty_tier(spend FLOAT, orders INT) RETURNS VARCHAR AS $$ ... $$`.

**Cenário:** A company needs to call an external fraud detection API (hosted on AWS Lambda) from within Snowflake during query execution. For each transaction row, they want to send the transaction details to the API and get back a fraud risk score. What type of function should they create, and what additional Snowflake object is required?
**Resposta:** They need an **External Function** backed by an **API Integration**. External functions allow Snowflake to call external REST APIs (like AWS Lambda or Azure Functions) during query execution. The setup requires: (1) an API Integration object that defines the trusted external endpoint and authentication, (2) the external function definition that maps Snowflake input/output to the API request/response. Once created, the external function works like a UDF in SELECT statements: `SELECT transaction_id, fraud_check(amount, merchant, location) AS risk_score FROM transactions`. Key consideration: data leaves Snowflake to the external service, so security and latency must be evaluated. External functions are slower than native UDFs because of the network round-trip.

**Cenário:** A developer needs to write a function that takes a department ID and returns a table of all employees in that department with their calculated bonus amounts. The output needs to be used in a FROM clause: `SELECT * FROM TABLE(get_department_bonuses(101))`. What type of object should they create?
**Resposta:** They need a **User-Defined Table Function (UDTF)** — a UDF that `RETURNS TABLE(...)`. UDTFs return multiple rows (unlike scalar UDFs which return a single value) and are invoked with the `TABLE()` wrapper in the FROM clause. This is NOT a stored procedure — procedures use CALL and return a single value, not a result set usable in FROM. The UDTF can be written in SQL, Python, Java, or JavaScript. Example skeleton: `CREATE FUNCTION get_department_bonuses(dept_id INT) RETURNS TABLE(emp_name VARCHAR, bonus FLOAT) AS $$ ... $$`. On the exam, if you see TABLE() in FROM, think UDTF. If you see CALL, think stored procedure.

---

---

## REVISÃO RÁPIDA — Domínio 4

1. Três caches: Result (24h, compartilhado, gratuito), Warehouse (SSD, perdido ao suspender), Metadata (sempre ativo)
2. Result cache compartilhado entre usuários (mesmo role + mesmo SQL + dados inalterados)
3. Suspensão do warehouse = cache local PERDIDO
4. Spilling (local ou remoto) = scale UP (warehouse maior)
5. Queuing = scale OUT (mais clusters)
6. Funções em colunas WHERE = impede pruning
7. Query Acceleration Service = serverless, scans grandes, Enterprise+
8. Search Optimization = point lookups, como índice secundário, Enterprise+
9. Clustering keys = co-localizar dados, melhor pruning, manutenção automática
10. Materialized views = pré-computadas, atualizadas automaticamente, Enterprise+
11. STATEMENT_TIMEOUT_IN_SECONDS = encerrar consultas de longa execução
12. VARIANT = contêiner semi-estruturado
13. FLATTEN + LATERAL = expandir dados aninhados em linhas
14. Window functions = cálculos através de partições (ROW_NUMBER, RANK, etc.)
15. Stored Procedures = procedural + DDL/DML. UDFs = retornam valores em SQL.
16. C++ NÃO é suportado para stored procedures ou UDFs
17. Privilégio MONITOR = ver query profiles de outros usuários
18. Query Profile mostra: operadores, spilling, eficiência de pruning, explosões de join
19. Warehouses separados por tipo de workload
20. Auto-suspend economiza créditos quando ocioso

**Armadilha do exame**: "Clustering keys requerem edição Enterprise?" → ERRADO. Clustering keys funcionam em TODAS as edições. SE VOCÊ VIR "Enterprise necessário" para clustering keys → ARMADILHA! Apenas a manutenção de Automatic Clustering é cobrada como serverless. A key em si funciona em qualquer edição.
**Armadilha do exame**: "QUALIFY é uma cláusula exclusiva do Snowflake?" → Correto. SE VOCÊ VIR "padrão ANSI SQL" com QUALIFY → ARMADILHA! QUALIFY é específico do Snowflake, não é ANSI SQL padrão. Filtra resultados de window functions diretamente.

---

## PARES CONFUSOS — Domínio 4

| Eles perguntam sobre... | A resposta é... | NÃO... |
|---|---|---|
| Cache perdido ao suspender | Warehouse cache (SSD) | Result cache |
| Cache compartilhado entre usuários | Result cache | Warehouse cache |
| Cache sem custo | Result cache | Warehouse cache |
| Duração do result cache | 24 horas (máx 31 dias de renovação) | Indefinido |
| Correção para spilling | Scale UP (warehouse maior) | Scale OUT (mais clusters) |
| Correção para queuing | Scale OUT (mais clusters) | Scale UP (warehouse maior) |
| Point lookups em bilhões de linhas | Search Optimization | Query Acceleration |
| Scans de tabelas grandes | Query Acceleration | Search Optimization |
| Resultados pré-computados | Materialized View | Standard View |
| Impedir pruning | Funções em colunas de filtro | Cláusulas WHERE simples |
| Custo de manutenção em background | Créditos serverless | Gratuito |
| DDL dentro de lógica SQL | Stored Procedure | UDF |
| Usar em SELECT/WHERE | UDF | Stored Procedure |
| Encerrar consulta longa | STATEMENT_TIMEOUT_IN_SECONDS | Resource Monitor |
| Encerrar consulta na fila | STATEMENT_QUEUED_TIMEOUT_IN_SECONDS | Auto-suspend |
| Achatar array aninhado | LATERAL FLATTEN | PARSE_JSON |
| Navegar JSON | Notação de ponto (col:key) | Indexação de array |

**Armadilha do exame**: "Materialized view vs result cache?" → MV é uma tabela física pré-computada (atualizada automaticamente, custa créditos). Result cache é uma resposta de consulta armazenada (24h, gratuito). SE VOCÊ VIR estes tratados como equivalentes → ARMADILHA! MV = objeto físico persistente. Result cache = resposta temporária em cache. Mecanismos totalmente diferentes.
**Armadilha do exame**: "LATERAL FLATTEN vs apenas FLATTEN?" → LATERAL é necessário para correlacionar a saída achatada de volta à linha de origem. SE VOCÊ VIR FLATTEN sem LATERAL em uma consulta com join → ARMADILHA! Sem LATERAL você perde o contexto de join com a linha pai.

---

## RESUMO AMIGÁVEL — Domínio 4

### ÁRVORES DE DECISÃO POR CENÁRIO
Quando você ler uma questão, encontre o padrão:

**"O relatório de fim de mês de um banco está transbordando para disco local..."**
→ Scale UP (warehouse maior = mais memória)
→ NÃO scale OUT (mais clusters não ajudam uma consulta lenta)

**"O relatório de fim de mês de um banco está transbordando para disco REMOTO..."**
→ Scale UP ainda MAIS (remote spill = realmente precisa de mais memória)
→ Mesma correção, apenas mais urgente

**"Um site de e-commerce tem 200 analistas todos consultando ao mesmo tempo e as consultas estão na fila..."**
→ Scale OUT (multi-cluster warehouse, Enterprise+)
→ NÃO scale UP (warehouse maior não reduz a fila)

**"Uma empresa de saúde executa a mesma consulta de busca de paciente milhares de vezes por dia..."**
→ Result Cache lida com isso (24h, gratuito, sem warehouse necessário)
→ Mesmo SQL + mesmo role + dados inalterados = cache hit

**"Um analista diferente executa exatamente a mesma consulta que outro analista..."**
→ AINDA usa Result Cache (compartilhado entre usuários SE mesmo role)
→ Usuário diferente não importa — mesmo role + mesmo SQL = cache hit

**"Um admin suspende um warehouse para economizar custos. O que acontece com os dados em cache?"**
→ Warehouse (SSD) cache é PERDIDO
→ Result cache está bem (está em Cloud Services, não no warehouse)

**"Uma empresa de telecom busca um número de telefone específico em 5 bilhões de registros de chamadas..."**
→ Search Optimization Service (point lookup, alta cardinalidade, Enterprise+)
→ NÃO Query Acceleration (isso é para SCANS grandes)

**"O dashboard de uma empresa de varejo escaneia toda a tabela de vendas toda manhã..."**
→ Query Acceleration Service (transfere porções de scan grande, Enterprise+)
→ NÃO Search Optimization (isso é para lookups de ID específico)

**"A cláusula WHERE de uma consulta usa UPPER(email) = 'TEST@MAIL.COM'..."**
→ RUIM — função na coluna impede pruning
→ Correção: armazene uma coluna pré-computada ou reescreva o filtro

**"Um join produz 100x mais linhas do que as tabelas de entrada..."**
→ Exploding join / produto Cartesiano
→ Correção: verifique condições de join, adicione predicados adequados

**"Um time de data science executa consultas ML caras em dados que raramente mudam..."**
→ Materialized View (pré-computada, atualizada automaticamente, Enterprise+)
→ Melhor quando: consulta cara + mudanças infrequentes de dados

**"Um cliente quer executar lógica procedural com CREATE TABLE dentro..."**
→ Stored Procedure (pode executar DDL/DML)
→ NÃO UDF (UDFs não podem executar DDL/DML)

**"Um cliente quer uma função reutilizável dentro de cláusulas SELECT e WHERE..."**
→ UDF (retorna valores utilizáveis em expressões SQL)
→ NÃO Stored Procedure (chamada com CALL, não em SELECT)

**"Um cliente quer chamar uma função AWS Lambda externa do Snowflake..."**
→ External Function + API Integration
→ Dados saem do Snowflake, processados externamente, retornam

**"A tabela de um cliente tem 10 bilhões de linhas. Consultas sempre filtram por data mas está lento..."**
→ Adicione clustering key na coluna de data (ALTER TABLE ... CLUSTER BY (date_col))
→ Auto-clustering mantém (créditos serverless)
→ Co-localiza datas similares nas mesmas micro-partitions → melhor pruning

**"Um cliente redimensionou um warehouse de Small para Large enquanto uma consulta estava rodando. A consulta em execução se beneficia?"**
→ NÃO. Consultas em execução usam o tamanho ANTIGO.
→ Apenas NOVAS consultas após o redimensionamento usam o warehouse Large.

**"O Query Profile de um cliente mostra alto 'Bytes Scanned' mas baixo 'Rows Returned'..."**
→ Pruning ruim — escaneando muito mais dados do que necessário
→ Correção: adicione/melhore clustering key, verifique cláusulas WHERE

**"Um cliente precisa de totais acumulados em dados de vendas mensais..."**
→ Window function: SUM(sales) OVER (ORDER BY month ROWS UNBOUNDED PRECEDING)
→ NÃO GROUP BY (isso colapsa linhas, window functions mantêm todas as linhas)

**"Um cliente precisa ranquear funcionários por salário dentro de cada departamento..."**
→ RANK() ou DENSE_RANK() OVER (PARTITION BY dept ORDER BY salary DESC)
→ RANK = lacunas no ranking (empates pulam), DENSE_RANK = sem lacunas

**"Um cliente tem arrays JSON aninhados em uma coluna VARIANT e precisa de cada elemento do array como uma linha separada..."**
→ LATERAL FLATTEN(input => col:array_key)
→ Cada elemento se torna sua própria linha, juntado de volta à origem

**"Um cliente pergunta: qual a diferença entre GROUPING SETS, ROLLUP e CUBE?"**
→ GROUPING SETS = combinações específicas que você escolhe
→ ROLLUP = subtotais hierárquicos (ano → mês → dia)
→ CUBE = TODAS as combinações possíveis de subtotais

**"Um warehouse ETL e um warehouse de relatórios BI estão competindo por recursos..."**
→ Use warehouses SEPARADOS para cada workload (melhor prática)
→ ETL = warehouse dedicado, BI = warehouse dedicado
→ Previne que um workload prive o outro de recursos

**"Um cliente quer encerrar automaticamente consultas que executam por mais de 30 minutos..."**
→ STATEMENT_TIMEOUT_IN_SECONDS = 1800
→ Defina no nível do warehouse, sessão ou conta

**"O warehouse de um cliente fica ocioso a maior parte do dia mas recebe rajadas de consultas a cada hora..."**
→ Timeout curto de auto-suspend (1-2 minutos) para economizar créditos durante ociosidade
→ Auto-resume lida com as rajadas automaticamente

**"Um cliente quer uma UDTF (table function) que retorna múltiplas linhas..."**
→ User-Defined Table Function (RETURNS TABLE)
→ Linguagens: SQL, JavaScript, Python, Java
→ Usada com TABLE() na cláusula FROM

---

### MNEMÔNICOS PARA MEMORIZAR

**Três caches = "R-W-M" → "Result, Warehouse, Metadata"**
- **R**esult Cache → 24h, GRATUITO, compartilhado, camada Cloud Services
- **W**arehouse Cache → SSD, PERDIDO ao suspender, por warehouse
- **M**etadata Cache → sempre ativo, COUNT(*)/MIN/MAX, gratuito

**Fluxo do cache = "R depois M depois W"**
- Consulta chega → verifica Result cache primeiro → depois Metadata → depois executa no Warehouse

**Spilling vs Queuing = "UP para Potência, OUT para Pessoas"**
- Spilling (local ou remoto) → scale UP (warehouse maior = mais memória)
- Queuing (muitas consultas) → scale OUT (mais clusters = mais espaço)

**Serviços de performance = "QAS-SOS-CK-MV"**
- **Q**AS = Query Acceleration Service (scans grandes, serverless, Enterprise+)
- **S**OS = Search Optimization Service (point lookups, como um índice, Enterprise+)
- **C**K = Clustering Keys (co-localizar dados, melhor pruning, TODAS as edições)
- **M**V = Materialized Views (resultados pré-computados, Enterprise+)

**Procedures vs UDFs = "Procedures FAZEM, Functions RETORNAM"**
- Stored Procedures → FAZEM coisas (DDL, DML, lógica procedural) → CALL
- UDFs → RETORNAM valores → usados em SELECT/WHERE

**Navegação semi-estruturada = "Ponto-Cast-Flat"**
- **Ponto** (notação) → col:key.subkey (navegar)
- **Cast** → ::string, ::number (converter tipos)
- **Flat**ten → LATERAL FLATTEN (expandir arrays em linhas)

---

### PRINCIPAIS ARMADILHAS — Domínio 4

1. **"Result cache requer um warehouse rodando"** → ERRADO. Result cache é GRATUITO, sem warehouse necessário.
2. **"Result cache é por usuário"** → ERRADO. Compartilhado entre usuários (mesmo role + mesmo SQL + dados inalterados).
3. **"Warehouse cache sobrevive à suspensão"** → ERRADO. SSD cache PERDIDO ao suspender.
4. **"Spilling → adicionar mais clusters"** → ERRADO. Spilling → warehouse maior (scale UP).
5. **"Queuing → warehouse maior"** → ERRADO. Queuing → mais clusters (scale OUT).
6. **"Search Optimization = scans de tabelas grandes"** → ERRADO. SOS = point lookups. QAS = scans grandes.
7. **"Clustering keys requerem Enterprise"** → ERRADO. TODAS as edições. (Manutenção de auto-clustering é serverless.)
8. **"UDFs podem executar CREATE TABLE"** → ERRADO. Apenas Stored Procedures podem executar DDL/DML.
9. **"C++ é suportado para UDFs"** → ERRADO. Suportados: SQL, JavaScript, Python, Java, Scala.
10. **"Materialized views podem fazer join de múltiplas tabelas"** → ERRADO. Apenas tabela única.

---

### ATALHOS DE PADRÃO — "Se você vir ___, a resposta é ___"

| Se a questão menciona... | A resposta quase sempre é... |
|---|---|
| "transbordamento para disco local" | Scale UP (warehouse maior) |
| "transbordamento para disco remoto" | Scale UP MAIS (warehouse muito maior) |
| "consultas na fila" | Scale OUT (multi-cluster) |
| "mesma consulta, usuário diferente, mesmo role" | Result Cache (ainda funciona) |
| "warehouse suspenso, e o cache" | SSD/warehouse cache = PERDIDO |
| "COUNT(*) sem WHERE, instantâneo" | Metadata Cache |
| "buscar um ID em bilhões de linhas" | Search Optimization Service |
| "scan grande transferido" | Query Acceleration Service |
| "pré-computado, atualizado automaticamente" | Materialized View |
| "co-localizar dados, melhor pruning" | Clustering Keys |
| "função no WHERE impede..." | Pruning (reescreva o filtro) |
| "linhas demais do join" | Exploding join / condição de join ausente |
| "CALL procedure_name()" | Stored Procedure |
| "usado em SELECT/WHERE" | UDF |
| "DDL dentro de lógica de código" | Stored Procedure (não UDF) |
| "coluna VARIANT" | Dados semi-estruturados |
| "FLATTEN + LATERAL" | Expandir arrays/objetos aninhados |
| "col:key::string" | Navegação semi-estruturada + casting |
| "STATEMENT_TIMEOUT_IN_SECONDS" | Encerrar consultas de longa execução |
| "STATEMENT_QUEUED_TIMEOUT_IN_SECONDS" | Encerrar consultas esperando demais |
| "warehouses separados por workload" | Melhor prática para isolamento de workload |
| "Política de scaling Economy" | Economiza créditos, espera 6 min antes de adicionar cluster |
| "Política de scaling Standard" | Performance primeiro, adiciona cluster imediatamente |

**Armadilha do exame**: "Redimensionar warehouse enquanto consulta roda — a consulta em execução se beneficia?" → NÃO. Apenas NOVAS consultas usam o novo tamanho. Consultas em execução mantêm o tamanho antigo.
**Armadilha do exame**: "GROUPING SETS vs ROLLUP vs CUBE?" → GROUPING SETS = você escolhe combinações exatas. ROLLUP = hierárquico da esquerda para direita. CUBE = toda combinação possível. ERRADO: "Todos produzem a mesma saída."
**Armadilha do exame**: "Padrão caller's rights vs owner's rights?" → Padrão é OWNER's rights. ERRADO: "Padrão é caller's rights."

---

## DICAS PARA O DIA DO EXAME — Domínio 4 (21% = ~21 questões)

**Antes de estudar este domínio:**
- Flashcard dos 3 caches (Result, Warehouse, Metadata) — qual é compartilhado, qual é perdido, qual é gratuito
- Flashcard "spilling = UP, queuing = OUT" — isso aparece repetidamente
- Saiba QAS vs SOS: QAS = scans grandes, SOS = point lookups. Ambos Enterprise+.
- Saiba Stored Procedures vs UDFs: Procedures FAZEM (DDL/DML), Functions RETORNAM (em SELECT)

**Durante o exame — questões do Domínio 4:**
- Leia a ÚLTIMA sentença primeiro — depois leia o cenário
- Elimine 2 respostas obviamente erradas imediatamente
- Se descrevem uma consulta LENTA → verifique: está transbordando (scale UP) ou na fila (scale OUT)?
- Se mencionam CACHE → pergunte: qual? Result (24h, gratuito), Warehouse (SSD, perdido ao suspender), Metadata (sempre ativo)
- Se perguntam sobre SERVIÇO DE OTIMIZAÇÃO → scan grande = QAS, lookup específico = SOS
- Se mostram JSON/VARIANT → pense notação de ponto, ::cast, LATERAL FLATTEN
- Se perguntam "pode executar DDL?" → apenas Stored Procedures, nunca UDFs

**Armadilha do exame**: "Query History 365 dias do INFORMATION_SCHEMA?" → ERRADO. INFORMATION_SCHEMA = 7 dias (tempo real). ACCOUNT_USAGE = 365 dias (até 3h de latência). Não troque-os.
**Armadilha do exame**: "Materialized views podem referenciar múltiplas tabelas?" → ERRADO. MVs são apenas tabela única. Se a questão descreve um join multi-tabela, MV não é a resposta.

---

## UMA LINHA POR TÓPICO — Domínio 4

| Tópico | Resumo em uma linha |
|---|---|
| Result Cache | 24h (máx 31 dias), compartilhado entre usuários (mesmo role+SQL+dados), Cloud Services, GRATUITO. |
| Warehouse Cache | SSD nos nós do warehouse, PERDIDO ao suspender, por warehouse, não compartilhado. |
| Metadata Cache | Sempre ativo, COUNT(*)/MIN/MAX tabela inteira, Cloud Services, sem warehouse necessário. |
| Query Profile | Plano de execução visual no Snowsight: operadores, spilling, pruning, problemas de join. |
| Local Disk Spilling | Consulta precisa de mais memória → transborda para SSD local → scale UP warehouse. |
| Remote Disk Spilling | Pior que local → transborda para armazenamento remoto → scale UP significativamente. |
| Queuing | Muitas consultas concorrentes → esperando na fila → scale OUT (multi-cluster). |
| Pruning | Snowflake pula micro-partitions irrelevantes. Funções em colunas WHERE impedem. |
| QAS | Query Acceleration Service: transfere scans grandes para computação serverless. Enterprise+. |
| SOS | Search Optimization Service: access paths persistentes para point lookups. Enterprise+. |
| Clustering Keys | ALTER TABLE CLUSTER BY (cols). Manutenção automática. Melhor pruning. TODAS as edições. |
| Materialized Views | Resultados pré-computados, atualizados automaticamente, apenas tabela única. Enterprise+. |
| Isolamento de workload | Warehouses separados por tipo de workload (ETL, BI, ad-hoc, data science). |
| Auto-suspend | Economiza créditos quando ocioso. Timeout curto (1-5 min) para workloads interativos. |
| STATEMENT_TIMEOUT | Encerra consultas de longa execução. Defina no nível warehouse/sessão/conta. |
| Dados semi-estruturados | Colunas VARIANT/OBJECT/ARRAY. Notação de ponto, ::cast, FLATTEN. |
| LATERAL FLATTEN | Expande arrays/objetos aninhados em linhas. Junta de volta à origem. |
| Window functions | ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, SUM OVER. Mantêm todas as linhas. |
| GROUPING SETS/ROLLUP/CUBE | Subtotais: SETS = combinações personalizadas, ROLLUP = hierarquia, CUBE = todas as combinações. |
| CTEs | Cláusula WITH para subconsultas legíveis. Podem referenciar CTEs anteriores. |
| Stored Procedures | Lógica procedural + DDL/DML. CALL para executar. SQL/JS/Python/Java/Scala. |
| UDFs | Retornam valores em expressões SQL (SELECT/WHERE). Não podem executar DDL/DML. |
| UDTFs | Table functions (RETURNS TABLE). Retornam múltiplas linhas. Usadas com TABLE(). |
| External Functions | Chamam APIs externas (Lambda, Azure Functions). Requerem API Integration. |
| Políticas de scaling | Standard = adiciona cluster imediatamente. Economy = espera 6 min, economiza créditos. |

**Armadilha do exame**: "Search Optimization funciona em qualquer edição?" → ERRADO. SOS requer edição Enterprise+. O mesmo para QAS e Materialized Views.
**Armadilha do exame**: "UDTFs são chamadas com CALL?" → ERRADO. UDTFs são usadas com TABLE() na cláusula FROM. CALL é apenas para stored procedures.

---

## FLASHCARDS — Domínio 4

**P:** Qual é a ordem de verificação do cache?
**R:** 1) Result cache (gratuito, 24h, Cloud Services) → 2) Local disk cache (SSD do warehouse) → 3) Remote disk cache (camada de Storage).

**P:** Quando o result cache é invalidado?
**R:** Quando os dados subjacentes mudam, quando a consulta usa funções não-determinísticas (CURRENT_TIMESTAMP, RANDOM), ou após 24 horas.

**P:** O result cache requer um warehouse rodando?
**R:** Não. Result cache é servido por Cloud Services — sem créditos de warehouse consumidos.

**P:** O que é spilling?
**R:** Quando uma consulta precisa de mais memória do que o warehouse tem, transborda para disco local (SSD), depois para armazenamento remoto. Correção: scale UP (warehouse maior).

**P:** O que é queuing?
**R:** Quando todos os clusters em um warehouse estão ocupados, novas consultas esperam em uma fila. Correção: scale OUT (adicionar mais clusters via multi-cluster warehouse).

**P:** Economy vs Standard scaling policy?
**R:** Standard: inicia novos clusters imediatamente quando consultas entram na fila. Economy: espera ~6 minutos antes de adicionar clusters — economiza créditos mas maior latência.

**P:** O que é o Query Profile?
**R:** Plano de execução visual no Snowsight. Mostra operadores, fluxo de dados, estatísticas de pruning, spilling e gargalos. Use para diagnosticar consultas lentas.

**P:** O que "TableScan" mostra no Query Profile?
**R:** Partições escaneadas vs total de partições. Se escaneadas está próximo do total, pruning está ruim — considere uma clustering key.

**P:** O que é Search Optimization Service?
**R:** Serviço em background que constrói search access paths para point lookups (igualdade, IN, LIKE). Enterprise+. Melhor para consultas seletivas em tabelas grandes.

**P:** O que são Materialized Views?
**R:** Resultados de consulta pré-computados armazenados fisicamente. Atualizados automaticamente pelo Snowflake. Apenas Enterprise+. Bom para agregações caras repetidas.

**P:** O que é Query Acceleration Service (QAS)?
**R:** Transfere partes de consultas elegíveis (scans grandes) para computação compartilhada. Enterprise+. Bom para workloads ad-hoc/imprevisíveis com consultas outlier.

**P:** O que é Automatic Clustering?
**R:** Serviço em background que reorganiza micro-partitions baseado na clustering key. Enterprise+. Executa quando dados mudam, cobrado como computação serverless.

**P:** O que o FLATTEN faz?
**R:** Converte VARIANT/ARRAY/OBJECT em linhas (uma linha por elemento). Geralmente usado com LATERAL: `SELECT * FROM table, LATERAL FLATTEN(input => col)`.

**P:** O que é a cláusula QUALIFY?
**R:** Filtra resultados de window functions — como WHERE mas para window functions. Exemplo: `QUALIFY ROW_NUMBER() OVER (...) = 1`.

**P:** Stored Procedure vs UDF — diferenças-chave?
**R:** Procedure: chamado com CALL, pode executar DDL/DML, não retorna em SELECT. UDF: retorna um valor, usado em SELECT, não pode fazer DDL. Ambos suportam SQL/Python/Java/Scala/JavaScript.

**P:** O que é caller's rights vs owner's rights?
**R:** Caller's rights: procedure executa com as permissões de quem o chama. Owner's rights: executa com permissões do dono do procedure. Padrão é owner's rights.

**P:** O que o PIVOT faz?
**R:** Rotaciona linhas em colunas. Transforma valores únicos em uma coluna em colunas separadas. Oposto do UNPIVOT.

**P:** Quais window functions são comumente testadas?
**R:** ROW_NUMBER (rank único), RANK (lacunas em empates), DENSE_RANK (sem lacunas), LAG/LEAD (linha anterior/próxima), SUM/AVG OVER (agregados acumulados).

**Armadilha do exame**: "Funções não-determinísticas (CURRENT_TIMESTAMP, RANDOM) usam result cache?" → ERRADO. Funções não-determinísticas INVALIDAM o result cache. A consulta re-executa toda vez.
**Armadilha do exame**: "Automatic Clustering é gratuito?" → ERRADO. É um serviço serverless em background que custa créditos. Apenas definir a clustering key (ALTER TABLE CLUSTER BY) é gratuito.
**Armadilha do exame**: "PIVOT requer uma função de agregação?" → Correto. A sintaxe do PIVOT precisa de um agregado (SUM, COUNT, etc.). ERRADO: "PIVOT apenas reorganiza linhas sem agregação."

---

## EXPLIQUE COMO SE EU TIVESSE 5 ANOS — Domínio 4

**Result cache**: Quando você faz a mesma pergunta duas vezes, o Snowflake lembra a resposta por 24 horas e devolve instantaneamente de graça.

**Local disk cache**: O warehouse mantém dados usados recentemente no seu drive SSD rápido — como manter um livro na sua mesa em vez de ir até a biblioteca.

**Spilling**: Seu warehouse ficou sem espaço na mesa e teve que colocar papéis no chão (disco local), depois no corredor (armazenamento remoto). Pegue uma mesa maior = scale UP.

**Queuing**: Há uma fila de pessoas esperando para usar o warehouse. Consiga mais warehouses = scale OUT.

**Query Profile**: Um raio-X da sua consulta mostrando exatamente o que aconteceu — onde gastou tempo, quais dados leu e onde ficou presa.

**Pruning**: Snowflake pulando dados que não precisa. Bom pruning = consulta rápida. Verifique olhando "partitions scanned" no Query Profile.

**Clustering key**: Organizar sua estante por assunto para encontrar livros mais rápido. Só vale a pena para estantes enormes (tabelas multi-TB).

**Search Optimization**: Um índice especial que ajuda a encontrar agulhas específicas em um palheiro enorme. Para lookups como "encontre a linha onde ID = 12345."

**Materialized view**: Uma cola que o Snowflake pré-calcula e mantém atualizada. Mais rápido para ler, mas custa dinheiro para manter.

**Query Acceleration**: Quando uma consulta está fazendo muito mais trabalho que as outras, o Snowflake empresta computadores extras para ajudar apenas aquela consulta a terminar mais rápido.

**FLATTEN**: Abrir uma caixa que contém uma lista e espalhar cada item em sua própria linha na mesa.

**QUALIFY**: Um filtro para window functions. Como dizer "me dê apenas o primeiro resultado" depois de numerar todas as linhas.

**Window function**: Fazer matemática através de linhas sem colapsá-las. Como calcular um total acumulado onde cada linha mostra a soma até agora.

**Stored procedure**: Uma receita com instruções passo a passo que você pode executar a qualquer momento dizendo seu nome. Pode fazer qualquer coisa.

**UDF**: Uma mini calculadora — você dá uma entrada, ela devolve uma saída. Usada dentro de consultas.

**PIVOT**: Transformar dados altos em dados largos — como converter uma lista de meses em colunas separadas para cada mês.

**Economy scaling**: Ser paciente e econômico — esperar um pouco antes de contratar trabalhadores extras. Standard scaling: contratar trabalhadores extras imediatamente quando há fila.

**Armadilha do exame**: "Window functions colapsam linhas como GROUP BY?" → ERRADO. Window functions MANTÊM todas as linhas. GROUP BY as colapsa. Essa é a diferença-chave.
**Armadilha do exame**: "Spilling significa que a consulta está na fila?" → ERRADO. Spilling = MEMÓRIA insuficiente (scale UP). Queuing = CONCORRÊNCIA insuficiente (scale OUT). Problemas completamente diferentes.

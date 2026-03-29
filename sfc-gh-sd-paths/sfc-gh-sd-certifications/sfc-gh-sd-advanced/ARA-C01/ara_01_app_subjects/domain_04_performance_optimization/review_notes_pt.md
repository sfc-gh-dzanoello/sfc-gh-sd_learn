# Domínio 4: Performance — Ferramentas, Melhores Práticas e Resolução de Problemas

> **Peso no ARA-C01:** ~20-25% do exame. Este é um domínio de ALTA PRIORIDADE.
> Foco em: Interpretação do Query Profile, dimensionamento de warehouse, camadas de cache, clustering e serviços de performance.

---

## 4.1 QUERY PROFILE

O Query Profile é a sua **ferramenta de diagnóstico mais importante** no Snowflake.

### Conceitos-Chave

- Acesso via: **Aba History → query → Query Profile** (ou `GET_QUERY_OPERATOR_STATS()`)
- Mostra um **DAG (grafo acíclico direcionado)** de operadores — os dados fluem de baixo para cima
- Cada nó de operador mostra: **% do tempo total**, linhas processadas, bytes escaneados

**Operadores críticos que você precisa conhecer:**

| Operador | O Que Faz | Sinal de Alerta |
|----------|-----------|-----------------|
| TableScan | Lê micro-partitions | Partições escaneadas altas vs. total = pruning ruim |
| Filter | Aplica cláusulas WHERE | Deve aparecer APÓS pruning, não no lugar dele |
| Aggregate | GROUP BY / DISTINCT | Memória alta = possível spilling |
| SortWithLimit | ORDER BY + LIMIT | Caro em datasets grandes |
| JoinFilter | Hash join / merge join | Explosão de linhas = condição de join ruim |
| ExternalScan | Tabelas externas / stages | Sempre mais lento que tabelas nativas |
| WindowFunction | Cláusulas OVER() | Intensivo em memória, atenção ao spilling |
| Flatten | Expansão de VARIANT/array | Risco de explosão de linhas |

**Indicadores de spilling:**

- **Bytes spilled to local storage** — SSD do warehouse usado (problema moderado)
- **Bytes spilled to remote storage** — S3/Azure Blob/GCS usado (problema GRAVE)
- Solução: usar um **warehouse maior** (mais memória/SSD) ou otimizar a query

**Estatísticas de pruning (no TableScan):**

- **Partitions scanned** vs. **Partitions total** — o objetivo é scanned << total
- Se scanned ≈ total → clustering key está ausente ou o filtro não corresponde ao clustering

### Por Que Isso Importa

Você tem uma query de relatório levando 45 minutos. O Query Profile mostra um JoinFilter com 50B linhas de saída a partir de duas tabelas de 10M linhas. A condição de join está faltando uma coluna-chave — join cartesiano. Sem o Query Profile, você apenas aumentaria o warehouse e desperdiçaria créditos.

### Melhores Práticas

- Verifique o painel **"Most Expensive Nodes"** primeiro — os 1-2 nós do topo geralmente são o gargalo
- Olhe em **Statistics → Spilling** antes de aumentar warehouses
- Use `SYSTEM$EXPLAIN_PLAN()` para verificações rápidas sem executar a query
- Compare estatísticas de pruning antes/depois de adicionar clustering keys

**Armadilhas do exame:**

- Armadilha do exame: SE VOCÊ VER "Query está lenta, aumente o tamanho do warehouse" → ERRADO porque você deve diagnosticar com o Query Profile primeiro; o problema pode ser um join ruim ou filtro ausente, não falta de computação
- Armadilha do exame: SE VOCÊ VER "Spilling para disco local é um problema crítico" → ERRADO porque spilling local é uma preocupação moderada; spilling para **remote storage** é o grave
- Armadilha do exame: SE VOCÊ VER "Query Profile mostra o plano de execução antes de executar" → ERRADO porque o Query Profile mostra estatísticas de **execução real**; use `EXPLAIN_PLAN` para planos pré-execução

### Perguntas Frequentes (FAQ)

**P: Posso ver o Query Profile de queries executadas por outros usuários?**
R: Sim, se você tiver ACCOUNTADMIN ou privilégio MONITOR no warehouse. Caso contrário, você só vê suas próprias queries.

**P: Por quanto tempo os Query Profiles são retidos?**
R: 14 dias na interface web. Use ACCOUNT_USAGE.QUERY_HISTORY para até 365 dias (mas sem o DAG visual).


### Exemplos de Perguntas de Cenário — Query Profile

**Cenário:** A nightly reporting job that used to complete in 10 minutes now takes 3 hours. The data engineering team's first instinct is to upsize the warehouse from Large to 2XL. Before approving the cost increase, what should the architect require?
**Resposta:** Require a Query Profile analysis before any warehouse resizing. Open the Query Profile for the slow query and check: (1) the "Most Expensive Nodes" panel to identify the bottleneck operator, (2) spilling statistics — if the query spills to remote storage, upsizing may help; if there's no spilling, more compute won't help, (3) TableScan pruning stats — if partitions scanned is close to partitions total, the issue is poor pruning (fix with clustering keys, not bigger warehouse), (4) JoinFilter — check for row explosion from bad join conditions. The root cause is often a missing filter, a cartesian join, or degraded clustering — none of which are fixed by upsizing.

**Cenário:** An analyst reports that a join between two 10-million-row tables produces a Query Profile showing a JoinFilter operator with 50 billion output rows. The warehouse eventually runs out of memory and the query fails. What is the likely root cause and how should the architect fix it?
**Resposta:** The 50 billion rows from a join of two 10M-row tables indicates a cartesian or near-cartesian join — the join condition is either missing a key column or using a non-selective predicate. Check the Query Profile's JoinFilter node for the join condition. The fix is correcting the SQL join logic (adding the missing key column), not upsizing the warehouse. Even a 6XL warehouse cannot efficiently process 50 billion rows from what should be a 10M-row result. Use `SYSTEM$EXPLAIN_PLAN()` to verify the corrected query plan before running it.

---

---

## 4.2 WAREHOUSES

Warehouses são seus **motores de computação**. Dimensioná-los corretamente é a principal alavanca de custo.

### Conceitos-Chave

**Tamanhos de warehouse (dimensionamento por camiseta):**

| Tamanho | Nós | Créditos/hr | Caso de Uso |
|---------|-----|-------------|-------------|
| X-Small | 1 | 1 | Dev, queries simples |
| Small | 2 | 2 | Analytics leve |
| Medium | 4 | 4 | Workloads moderados |
| Large | 8 | 8 | Joins complexos, transformações |
| X-Large | 16 | 16 | ETL pesado |
| 2XL–6XL | 32–128 | 32–128 | Workloads massivos |

**Regra de dobra:** Cada tamanho acima = **2x nós, 2x créditos, 2x memória/SSD**. NÃO garante 2x de velocidade.

**Warehouses Otimizados para Snowpark:**

- 16x mais memória por nó que o padrão
- Finalidade: treinamento de ML, UDFs grandes, Snowpark DataFrames, Java/Python UDTFs
- Custo: ~1.5x mais créditos por hora que o padrão do mesmo tamanho

**Warehouses multi-cluster (Enterprise+):**

- Configurações de **Min clusters** e **Max clusters**
- **Políticas de escalonamento:**
  - **Standard (padrão):** Inicia novo cluster quando uma query entra em fila. Scale-down conservador.
  - **Economy:** Espera até haver carga suficiente para manter o novo cluster ocupado por 6 minutos. Economiza créditos mas aumenta enfileiramento.

**Auto-suspend / Auto-resume:**

- Auto-suspend: definido em **segundos** (mínimo 60s, ou 0 para imediato)
- Auto-resume: `TRUE` por padrão — warehouse inicia quando uma query chega
- Warehouses suspensos consomem **zero créditos**
- Cada resume incorre em tempo de provisionamento (~1-2 segundos tipicamente)

### Por Que Isso Importa

Sua equipe de engenharia de dados executa ETL às 2 da manhã em um warehouse 2XL que auto-suspende após 10 minutos. Mas 50 queries pequenas chegam a cada poucos minutos durante o dia, cada uma resumindo o warehouse. Você está pagando créditos de 2XL para workloads de X-Small. Solução: warehouses separados por tipo de workload.

### Melhores Práticas

- **Separe warehouses por workload** (ETL vs. BI vs. ciência de dados)
- Comece pequeno, escale apenas após verificar o Query Profile
- Auto-suspend: **60 segundos** para ETL, **300-600 segundos** para BI (evita resume constante)
- Use política de escalonamento **Economy** para workloads sensíveis a custo e tolerantes a latência
- Use política de escalonamento **Standard** para workloads voltados ao usuário e sensíveis a latência

**Armadilhas do exame:**

- Armadilha do exame: SE VOCÊ VER "Warehouse maior sempre significa queries mais rápidas" → ERRADO porque a velocidade da query depende do gargalo; um plano de query ruim não melhora com mais computação
- Armadilha do exame: SE VOCÊ VER "Warehouses multi-cluster executam uma única query em múltiplos clusters" → ERRADO porque cada cluster executa queries separadas; multi-cluster é para **concorrência**, não paralelismo de query única
- Armadilha do exame: SE VOCÊ VER "Warehouses otimizados para Snowpark são sempre melhores" → ERRADO porque custam mais e só ajudam workloads intensivos em memória (ML, UDFs grandes); padrão é suficiente para SQL
- Armadilha do exame: SE VOCÊ VER "Auto-suspend 0 significa nunca suspender" → ERRADO porque `AUTO_SUSPEND = 0` significa suspender imediatamente quando ocioso; `NULL` desabilita auto-suspend

### Perguntas Frequentes (FAQ)

**P: O tamanho do warehouse afeta o tempo de compilação?**
R: Não. A compilação acontece na camada de cloud services, não no warehouse.

**P: Posso redimensionar um warehouse enquanto queries estão executando?**
R: Sim. Queries em execução usam o tamanho antigo; novas queries usam o novo tamanho.


### Exemplos de Perguntas de Cenário — Warehouses

**Cenário:** A company uses a single 2XL warehouse for all workloads: ETL at 2 AM, BI dashboards during business hours, and ad-hoc data science queries throughout the day. BI users complain about slow dashboards during ETL runs, and costs are high because the 2XL runs 24/7. How should the architect redesign the warehouse strategy?
**Resposta:** Separate warehouses by workload type. Create a dedicated ETL warehouse (Large or XL, auto-suspend 60 seconds) that runs only during the 2 AM batch window. Create a BI warehouse (Medium, multi-cluster with Standard scaling policy, auto-suspend 300-600 seconds) for dashboard queries — the multi-cluster handles concurrency spikes during business hours, and the longer auto-suspend avoids constant resume overhead and preserves SSD cache. Create a data science warehouse (Snowpark-optimized if running ML/UDFs, standard otherwise, auto-suspend 120 seconds). This eliminates contention between workloads and right-sizes each warehouse independently.

**Cenário:** A data science team runs ML training jobs using Snowpark Python UDFs that process large in-memory datasets. Jobs frequently fail with out-of-memory errors on a standard XL warehouse. What should the architect recommend?
**Resposta:** Switch to a Snowpark-optimized warehouse. Snowpark-optimized warehouses provide 16x more memory per node compared to standard warehouses — specifically designed for memory-intensive workloads like ML training, large UDFs, and Snowpark DataFrames. The cost is approximately 1.5x more credits per hour than a standard warehouse of the same size, but the increased memory eliminates OOM failures and reduces spilling. Do not simply upsize to a standard 4XL — that adds compute nodes but doesn't provide the same memory density per node as a Snowpark-optimized warehouse.

---

---

## 4.3 CACHING

O Snowflake tem **três camadas de cache**. Entendê-las é crítico para o exame e para a vida real.

### Conceitos-Chave

**1. Result Cache (Camada de Cloud Services)**

- Armazena **resultados exatos de queries** por 24 horas
- Reutilizado quando: mesmo texto da query + mesmos dados (sem alterações subjacentes) + mesma role
- **Gratuito** — nenhum warehouse necessário
- Persiste mesmo se o warehouse estiver suspenso
- Invalidado quando dados subjacentes mudam (DML) ou 24 horas passam
- Pode ser desabilitado: `ALTER SESSION SET USE_CACHED_RESULT = FALSE;`

**2. Metadata Cache (Camada de Cloud Services)**

- Armazena min/max/count/null_count por micro-partition por coluna
- Alimenta: `SELECT COUNT(*)`, `MIN()`, `MAX()` em tabelas completas — **instantâneo, sem warehouse**
- Sempre ativo, não pode ser desabilitado

**3. Local Disk Cache (SSD do Warehouse)**

- Armazena em cache **dados brutos de micro-partition** no SSD do warehouse
- Perdido quando o warehouse suspende (SSD limpo)
- Compartilhado entre queries no mesmo warehouse
- Ajuda escaneamentos repetidos dos mesmos dados dentro de uma sessão
- Razão pela qual auto-suspend mais longo pode às vezes economizar dinheiro (evita re-buscar dados)

### Por Que Isso Importa

Um dashboard atualiza a cada 5 minutos com as mesmas 10 queries. Se os dados subjacentes não mudaram, todas as 10 usam o result cache — zero créditos de warehouse. Mas se alguém insere uma linha, todos os 10 caches são invalidados e o warehouse inicia. Entender isso molda seu agendamento de ELT.

### Melhores Práticas

- Agende cargas de dados em intervalos previsíveis para que o result cache permaneça válido entre as cargas
- Não desabilite o result cache a menos que esteja debugando
- Balance o timeout de auto-suspend: muito curto = perde cache SSD; muito longo = desperdiça créditos
- Use warehouses dedicados por workload para maximizar hits do cache SSD
- Metadata cache significa que `SELECT COUNT(*) FROM big_table` é sempre instantâneo — não precisa fazer cache disso manualmente

**Armadilhas do exame:**

- Armadilha do exame: SE VOCÊ VER "Result cache funciona entre roles diferentes" → ERRADO porque o result cache é **específico por role**; mesma query com roles diferentes = cache miss
- Armadilha do exame: SE VOCÊ VER "Suspender um warehouse limpa o result cache" → ERRADO porque o result cache fica na **camada de cloud services**, não no warehouse; o cache SSD/disco local é o que é limpo
- Armadilha do exame: SE VOCÊ VER "Result cache dura 24 horas não importa o quê" → ERRADO porque qualquer DML nas tabelas subjacentes **invalida** o cache imediatamente

### Perguntas Frequentes (FAQ)

**P: O result cache conta para a cobrança de cloud services?**
R: Não. A recuperação do result cache é gratuita. A cobrança de cloud services só entra se cloud services exceder 10% do total de computação.

**P: Se dois usuários executam a mesma query com a mesma role, o usuário B se beneficia do result cache do usuário A?**
R: Sim — o result cache é compartilhado entre usuários se o texto da query, role e dados forem idênticos.


### Exemplos de Perguntas de Cenário — Caching

**Cenário:** A BI dashboard refreshes 20 queries every 5 minutes. The underlying data is only updated once per hour via a scheduled ETL job. The architect notices the BI warehouse is consuming significant credits despite the data being mostly static. How should caching be optimized?
**Resposta:** Between ETL runs (55 minutes out of every hour), all 20 queries should hit the result cache since the underlying data hasn't changed and the queries use the same role. The result cache is free — no warehouse credits consumed. Verify that: (1) result cache is not disabled (`USE_CACHED_RESULT = TRUE`), (2) all dashboard queries use the same role (result cache is role-specific), (3) the ETL job doesn't do unnecessary DML that would invalidate the cache prematurely. If the dashboard auto-refreshes with slightly different query text each time (e.g., dynamic timestamps), standardize the query text to maximize cache hits. This should reduce warehouse usage by ~90%.

**Cenário:** An analytics team sets warehouse auto-suspend to 10 seconds to save credits. However, they notice that recurring queries throughout the day are slower than expected, and the warehouse is constantly resuming and suspending. What is happening and how should the architect fix it?
**Resposta:** The 10-second auto-suspend is clearing the local disk cache (warehouse SSD) too frequently. When the warehouse suspends, all cached micro-partition data on the SSD is lost. When it resumes, queries must re-fetch data from remote storage, making them slower. Increase the auto-suspend to 300-600 seconds for BI workloads — this keeps the SSD cache warm between queries, reducing remote storage reads. The slightly higher idle cost (a few minutes of credits) is offset by faster queries and fewer resume cycles. For ETL warehouses that run in discrete bursts, 60 seconds is appropriate since there's no cache to preserve between jobs.

---

---

## 4.4 CLUSTERING E PRUNING

Pruning de micro-partition é como o Snowflake evita full table scans. Clustering controla como os dados são organizados.

### Conceitos-Chave

**Micro-partitions:**

- O Snowflake armazena dados em micro-partitions comprimidas de 50-500 MB (imutáveis, colunares)
- Cada partição tem **metadados**: valores min/max por coluna
- Queries usam esses metadados para **pular** partições irrelevantes = pruning

**Clustering natural:**

- Os dados são clusterizados pela **ordem de ingestão** por padrão
- Funciona muito bem se você sempre filtra por uma coluna timestamp e carrega dados cronologicamente
- Degrada com inserts aleatórios, updates ou merges ao longo do tempo

**Clustering keys:**

- Definidas com `ALTER TABLE ... CLUSTER BY (col1, col2)`
- Melhor para: tabelas grandes (multi-TB), colunas frequentemente filtradas, cardinalidade baixa a média
- O serviço de **Automatic Clustering** do Snowflake reorganiza dados em background (serverless, consome créditos)
- Verificar qualidade do clustering: `SYSTEM$CLUSTERING_INFORMATION('table', '(col)')`
  - `average_depth` — menor é melhor (1.0 = perfeito)
  - `average_overlap` — menor é melhor (0.0 = sem sobreposição)

**Diretrizes de seleção de chaves:**

- Escolha colunas usadas em WHERE, JOIN, ORDER BY
- Máximo de 3-4 colunas em uma clustering key
- Coloque **colunas de baixa cardinalidade primeiro** (ex: `region` antes de `order_id`)
- Expressões permitidas: `CLUSTER BY (TO_DATE(created_at), region)`

### Por Que Isso Importa

Uma tabela fato de 500 TB com `WHERE event_date = '2025-01-15'` escaneia 500 TB sem clustering. Com `CLUSTER BY (event_date)`, escaneia talvez 100 MB. Essa é a diferença entre uma query de 30 minutos e uma query de 2 segundos.

### Melhores Práticas

- Só clusterize tabelas > 1 TB (ou com pruning ruim visível no Query Profile)
- Monitore créditos de auto-clustering em ACCOUNT_USAGE.AUTOMATIC_CLUSTERING_HISTORY
- Não clusterize por colunas de alta cardinalidade sozinhas (ex: UUID) — ineficaz
- Combine com colunas baseadas em tempo para tabelas de eventos/log: `CLUSTER BY (TO_DATE(ts), category)`
- Reavalie clustering keys trimestralmente conforme padrões de query evoluem

**Armadilhas do exame:**

- Armadilha do exame: SE VOCÊ VER "Clustering keys ordenam os dados como um índice tradicional" → ERRADO porque o Snowflake não tem índices; clustering keys guiam a **organização de micro-partitions** para melhor pruning
- Armadilha do exame: SE VOCÊ VER "Você deve clusterizar toda tabela" → ERRADO porque tabelas pequenas não se beneficiam; clustering tem custo de manutenção contínuo (créditos de auto-clustering)
- Armadilha do exame: SE VOCÊ VER "Clustering keys são gratuitas para manter" → ERRADO porque Automatic Clustering é uma **funcionalidade serverless que consome créditos**
- Armadilha do exame: SE VOCÊ VER "Coluna de alta cardinalidade é a melhor clustering key" → ERRADO porque baixa a média cardinalidade proporciona melhor pruning de partições; alta cardinalidade significa muitos valores distintos por partição

### Perguntas Frequentes (FAQ)

**P: Posso ter múltiplas clustering keys em uma tabela?**
R: Não. Uma clustering key por tabela, mas pode ser uma **chave composta** com múltiplas colunas.

**P: Clustering afeta a performance de DML?**
R: Não diretamente. Mas o Automatic Clustering roda em background e consome créditos serverless quando dados mudam.


### Exemplos de Perguntas de Cenário — Clustering & Pruning

**Cenário:** A 200 TB event log table is queried primarily by `event_date` and `region`. Queries filtering by `event_date` alone are fast, but queries filtering by both `event_date` and `region` still scan 60% of partitions. The table currently has `CLUSTER BY (event_date)`. How should the architect improve pruning?
**Resposta:** Change the clustering key to a compound key: `ALTER TABLE events CLUSTER BY (TO_DATE(event_ts), region)`. Put the lower-cardinality column (`region`, perhaps 10-20 values) first for maximum pruning efficiency, followed by the date expression. This organizes micro-partitions so that data for a specific region and date is co-located, allowing queries with both filters to prune much more aggressively. After changing the key, monitor `SYSTEM$CLUSTERING_INFORMATION('events', '(TO_DATE(event_ts), region)')` — `average_depth` should decrease toward 1.0 and `average_overlap` toward 0.0 over time as Automatic Clustering reorganizes data. Monitor auto-clustering credits in `AUTOMATIC_CLUSTERING_HISTORY`.

**Cenário:** A product manager asks the architect to add clustering keys to all 500 tables in the analytics database to "make everything faster." What should the architect's response be?
**Resposta:** Clustering should only be applied to large tables (typically >1 TB) with demonstrably poor pruning visible in Query Profile. Small tables fit in a few micro-partitions and don't benefit from clustering — Snowflake already scans all partitions quickly. Clustering also has ongoing maintenance costs: Automatic Clustering is a serverless feature that consumes credits whenever data changes. For the 500 tables, the architect should analyze Query Profile pruning statistics and `SYSTEM$CLUSTERING_INFORMATION` for the top 10-20 most-queried large tables first, then only apply clustering where partitions scanned is significantly higher than necessary. Re-evaluate clustering keys quarterly as query patterns evolve.

---

---

## 4.5 SERVIÇOS DE PERFORMANCE

Três serviços serverless que aceleram padrões de query específicos.

### Conceitos-Chave

**1. Query Acceleration Service (QAS)**

- Transfere **porções** de uma query para computação serverless compartilhada
- Melhor para: queries com grandes escaneamentos + filtros seletivos (analytics ad-hoc)
- Habilitado por warehouse: `ALTER WAREHOUSE SET ENABLE_QUERY_ACCELERATION = TRUE;`
- `QUERY_ACCELERATION_MAX_SCALE_FACTOR` — limita computação serverless (0 = ilimitado, padrão 8)
- Verificar elegibilidade: `SYSTEM$ESTIMATE_QUERY_ACCELERATION('query_id')`
- **Não ajuda para:** queries limitadas por operações single-threaded, escaneamentos pequenos ou gargalos de CPU

**2. Search Optimization Service (SOS)**

- Constrói um **caminho de acesso de busca persistente, mantido pelo servidor**
- Melhor para: **buscas pontuais seletivas** em tabelas grandes (WHERE id = X, CONTAINS, GEO)
- Suporta: predicados de igualdade, IN, SUBSTRING, funções GEOGRAPHY/GEOMETRY, campos VARIANT
- Habilitado por tabela ou por coluna: `ALTER TABLE t ADD SEARCH OPTIMIZATION ON EQUALITY(col)`
- Custos: créditos serverless para construção + armazenamento para estruturas de busca
- **Não ajuda para:** range scans, analytics de tabela completa, tabelas pequenas

**3. Materialized Views (MVs)**

- Resultados de query pré-computados, automaticamente mantidos, armazenados como micro-partitions
- Melhor para: subqueries repetidas, pré-agregações, subconjuntos comumente unidos por join
- O Snowflake **atualiza automaticamente** MVs quando a tabela base muda (créditos serverless)
- O otimizador de queries pode **reescrever automaticamente** queries para usar MVs mesmo que não sejam referenciadas diretamente
- Limitações: apenas tabela base única, sem joins, sem UDFs, sem HAVING, funções de janela limitadas
- Requer Enterprise Edition

### Por Que Isso Importa

Uma plataforma de analytics tem 200 usuários executando queries ad-hoc em uma tabela de 100 TB. Algumas queries escaneiam 80 TB, algumas escaneiam 100 MB. QAS ajuda as queries de grande escaneamento a compartilhar computação serverless. SOS ajuda as queries de busca pontual a pular direto para as partições corretas. MVs pré-computam as 10 principais agregações do dashboard.

### Melhores Práticas

- QAS: habilite em warehouses servindo padrões de query **imprevisíveis, ad-hoc**
- SOS: use para padrões de busca de **alta seletividade conhecidos** (buscas por ID, filtros de pesquisa)
- MVs: use para agregações ou views filtradas **estáveis e repetidas**
- Monitore todos os três em ACCOUNT_USAGE: histórico de QAS, histórico de SOS, histórico de refresh de MV
- Não habilite os três cegamente — cada um tem custos serverless contínuos

**Armadilhas do exame:**

- Armadilha do exame: SE VOCÊ VER "QAS substitui o warehouse inteiramente" → ERRADO porque QAS **complementa** o warehouse; o warehouse ainda executa a query, QAS transfere porções intensivas em escaneamento
- Armadilha do exame: SE VOCÊ VER "Search Optimization é como um índice B-tree tradicional" → ERRADO porque é um **caminho de acesso de busca** mantido por serverless; não é um índice gerenciado pelo usuário
- Armadilha do exame: SE VOCÊ VER "Materialized views podem unir múltiplas tabelas" → ERRADO porque MVs no Snowflake suportam **apenas tabela base única** — sem joins
- Armadilha do exame: SE VOCÊ VER "Materialized views devem ser referenciadas na query para serem usadas" → ERRADO porque o otimizador pode **reescrever automaticamente** queries para usar MVs de forma transparente

### Perguntas Frequentes (FAQ)

**P: QAS e Search Optimization podem ser usados juntos?**
R: Sim. Eles resolvem problemas diferentes — QAS para grandes escaneamentos, SOS para buscas pontuais.

**P: Materialized views consomem armazenamento?**
R: Sim. Elas são armazenadas como micro-partitions e contribuem para sua conta de armazenamento.


### Exemplos de Perguntas de Cenário — Performance Services

**Cenário:** An analytics platform serves 200 analysts running ad-hoc queries on a 100 TB sales fact table. Some queries scan 80 TB (broad date ranges), while others look up individual orders by `order_id`. The warehouse is frequently overloaded. Which performance services should the architect enable?
**Resposta:** Enable Query Acceleration Service (QAS) on the warehouse to help large-scan ad-hoc queries offload scan-intensive portions to shared serverless compute. For the point-lookup queries by `order_id`, add Search Optimization Service (SOS) on the `order_id` column: `ALTER TABLE sales ADD SEARCH OPTIMIZATION ON EQUALITY(order_id)`. SOS builds a persistent search access path for selective point lookups, skipping directly to the relevant partitions. For the most common dashboard aggregations that are queried repeatedly, create materialized views (MVs) on single-table aggregations — the optimizer auto-rewrites queries to use them. Each service addresses a different query pattern: QAS for large scans, SOS for point lookups, MVs for repeated aggregations. Monitor serverless costs for all three via ACCOUNT_USAGE.

**Cenário:** A BI team's top-10 dashboard shows pre-aggregated metrics (total sales by region, average order value by category) from a single large fact table. These queries run every 5 minutes and always return the same aggregation patterns. The architect wants to pre-compute these results. Should they use a materialized view or a dynamic table?
**Resposta:** Use a materialized view (MV). MVs are purpose-built for single-table aggregations with no joins — exactly this use case. Snowflake auto-refreshes the MV when the base table changes (serverless credits) and the optimizer can auto-rewrite queries to use the MV even if the query doesn't reference it directly. A dynamic table would also work but is heavier — dynamic tables are better suited for multi-table transformations with joins, which MVs don't support. For simple single-table aggregations, MVs are more efficient and integrate transparently with the optimizer. Enterprise edition is required.

---

---

## 4.6 RESOLUÇÃO DE PROBLEMAS

Saiba onde olhar e quais ferramentas usar.

### Conceitos-Chave

**INFORMATION_SCHEMA vs. ACCOUNT_USAGE:**

| Característica | INFORMATION_SCHEMA | ACCOUNT_USAGE |
|----------------|-------------------|---------------|
| Latência | Tempo real | 15 min – 3 hr de atraso |
| Retenção | 7 dias–6 meses (varia) | **365 dias** |
| Escopo | Banco de dados atual | Conta inteira |
| Objetos deletados | Não incluídos | **Incluídos** |
| Acesso | Qualquer role com acesso ao DB | ACCOUNTADMIN (ou concedido) |

**Views-chave de ACCOUNT_USAGE para performance:**

- `QUERY_HISTORY` — todas as queries, tempo de execução, bytes escaneados, warehouse, erros
- `WAREHOUSE_METERING_HISTORY` — consumo de créditos por warehouse
- `AUTOMATIC_CLUSTERING_HISTORY` — uso de créditos de auto-clustering
- `SEARCH_OPTIMIZATION_HISTORY` — uso de créditos do SOS
- `MATERIALIZED_VIEW_REFRESH_HISTORY` — uso de créditos de refresh de MV
- `QUERY_ACCELERATION_HISTORY` — uso de créditos do QAS
- `STORAGE_USAGE` — tendências de armazenamento ao longo do tempo
- `LOGIN_HISTORY` — problemas de autenticação

**Resource Monitors:**

- Rastreiam **consumo de créditos** no nível de conta ou warehouse
- Ações nos limites: **Notificar, Notificar e Suspender, Notificar e Suspender Imediatamente**
- Configurado com: `CREATE RESOURCE MONITOR` + atribuir ao warehouse ou conta
- Apenas ACCOUNTADMIN pode criar monitores no nível de conta
- Pode definir **hora de início, frequência (diária/semanal/mensal), cota de créditos**

**Alerts e Event Tables:**

- **Alerts** (`CREATE ALERT`): verificações de condição SQL agendadas → disparam ação (email, task, etc.)
- **Event Table**: armazém centralizado para **logs, traces, métricas** de UDFs, procedures, Streamlit
- Uma event table por conta: `ALTER ACCOUNT SET EVENT_TABLE = db.schema.events`
- Consulte dados de eventos com SQL padrão: `SELECT * FROM db.schema.events WHERE ...`

**Logging e Tracing:**

- Definir nível de log: `ALTER SESSION SET LOG_LEVEL = 'INFO';` (OFF, TRACE, DEBUG, INFO, WARN, ERROR, FATAL)
- Definir nível de trace: `ALTER SESSION SET TRACE_LEVEL = 'ON_EVENT';` (OFF, ALWAYS, ON_EVENT)
- Logs vão para a **event table** — consultável via SQL
- Disponível em UDFs (Python, Java, Scala, JavaScript), stored procedures, apps Streamlit

### Por Que Isso Importa

Dashboard de produção está lento. Você verifica ACCOUNT_USAGE.QUERY_HISTORY e encontra 500 queries enfileiradas em um único warehouse. Resource monitors mostram que você está queimando 2x os créditos esperados. Alerts que você configurou capturaram o pico e enviaram email para a equipe. Sem essas ferramentas, você não saberia até os usuários reclamarem.

### Melhores Práticas

- Use ACCOUNT_USAGE para análise histórica (retenção de 365 dias)
- Use INFORMATION_SCHEMA para debugging em tempo real (sessão/banco de dados atual)
- Configure resource monitors em **todo warehouse de produção** — inegociável
- Crie alerts para: queries de longa duração, spilling, profundidade de fila do warehouse, falhas de login
- Habilite logging (nível INFO no mínimo) para todos os UDFs e procedures de produção
- Revise WAREHOUSE_METERING_HISTORY semanalmente para capturar anomalias de custo cedo

**Armadilhas do exame:**

- Armadilha do exame: SE VOCÊ VER "INFORMATION_SCHEMA tem retenção de 365 dias" → ERRADO porque isso é **ACCOUNT_USAGE**; INFORMATION_SCHEMA varia (7 dias a 6 meses por view)
- Armadilha do exame: SE VOCÊ VER "Resource monitors podem limitar custos de armazenamento" → ERRADO porque resource monitors só rastreiam **créditos de computação**, não armazenamento
- Armadilha do exame: SE VOCÊ VER "Dados de ACCOUNT_USAGE são em tempo real" → ERRADO porque ACCOUNT_USAGE tem **15 minutos a 3 horas de latência**
- Armadilha do exame: SE VOCÊ VER "Qualquer role pode criar resource monitors no nível de conta" → ERRADO porque apenas **ACCOUNTADMIN** pode criar resource monitors no nível de conta

### Perguntas Frequentes (FAQ)

**P: Posso conceder acesso ao ACCOUNT_USAGE para roles que não são ACCOUNTADMIN?**
R: Sim. Conceda `IMPORTED PRIVILEGES` no banco de dados SNOWFLAKE para qualquer role.

**P: Resource monitors impedem queries de iniciar?**
R: Com "Suspend Immediately", sim — queries em execução são encerradas e novas são bloqueadas. Com "Suspend", queries em execução terminam mas novas não iniciam.

**P: Qual é a diferença entre um Alert e uma Task?**
R: Uma Task executa em um agendamento incondicionalmente. Um Alert executa em um agendamento mas **só dispara sua ação se uma condição SQL for verdadeira**.


### Exemplos de Perguntas de Cenário — Troubleshooting

**Cenário:** A production data platform has no cost controls in place. Last month, a developer accidentally left a 4XL warehouse running over a weekend, consuming $15,000 in credits. The CFO demands guardrails. What monitoring and control mechanisms should the architect implement?
**Resposta:** Create resource monitors on every production warehouse with tiered thresholds: Notify at 75% of the daily/weekly quota, Notify & Suspend at 100%. For the account level, create an account-level resource monitor (ACCOUNTADMIN only) as an overall safety net. Set up alerts (`CREATE ALERT`) to check for long-running queries (e.g., queries exceeding 30 minutes) and warehouse queue depth, triggering email notifications. Review `ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY` weekly to catch anomalies early. Resource monitors track compute credits only (not storage), so pair them with `STORAGE_USAGE` monitoring for complete cost visibility. Set appropriate auto-suspend timeouts on all warehouses (60s for ETL, 300-600s for BI).

**Cenário:** A Python UDF in production is intermittently failing with cryptic errors. The data engineering team has no visibility into what happens inside the UDF. How should the architect enable observability for UDFs and stored procedures?
**Resposta:** Set up an event table for the account: `ALTER ACCOUNT SET EVENT_TABLE = db.schema.events`. Set the log level to at least INFO: `ALTER SESSION SET LOG_LEVEL = 'INFO'`. Inside the Python UDF, add structured logging using Python's `logging` module — these logs automatically flow to the event table. Set `TRACE_LEVEL = 'ON_EVENT'` for tracing. The event table is queryable via standard SQL: `SELECT * FROM db.schema.events WHERE RESOURCE_ATTRIBUTES['snow.executable.name'] = 'MY_UDF'`. This provides full observability — logs, traces, and metrics — for all UDFs, stored procedures, and Streamlit apps. Enable INFO-level logging as a minimum for all production code.

**Cenário:** An architect needs to investigate a performance issue from 3 months ago. INFORMATION_SCHEMA shows no data for that period. Where should they look?
**Resposta:** Use `SNOWFLAKE.ACCOUNT_USAGE` views, which have 365-day retention. `INFORMATION_SCHEMA` retention varies by view (7 days to 6 months) and is scoped to the current database only. `ACCOUNT_USAGE.QUERY_HISTORY` provides all query details (execution time, bytes scanned, warehouse, errors) for up to 365 days across the entire account. Note that ACCOUNT_USAGE has 15 minutes to 3 hours of latency (not real-time), and access requires ACCOUNTADMIN or the `IMPORTED PRIVILEGES` grant on the SNOWFLAKE database. For real-time debugging of current issues, use INFORMATION_SCHEMA; for historical analysis, always use ACCOUNT_USAGE.

---

---

## FLASHCARDS — Domínio 4

**Q1: Quais são as três camadas de cache no Snowflake?**
A1: Result cache (cloud services, 24h, gratuito), Metadata cache (cloud services, sempre ativo), Local disk cache (SSD do warehouse, perdido ao suspender).

**Q2: Uma query faz spill para remote storage. Qual é a solução?**
A2: Use um **warehouse maior** (mais memória/SSD). Também verifique se a query pode ser otimizada para reduzir o volume de dados.

**Q3: Qual política de escalonamento você deve usar para um warehouse de BI voltado ao usuário?**
A3: **Standard** — escala rapidamente quando queries enfileiram. Economy é para workloads sensíveis a custo e tolerantes a latência.

**Q4: Como você verifica se uma tabela se beneficiaria de clustering?**
A4: `SYSTEM$CLUSTERING_INFORMATION('table', '(columns)')` — verifique `average_depth` e `average_overlap`. Valores altos = clustering ruim.

**Q5: Qual é o período máximo de retenção para views de ACCOUNT_USAGE?**
A5: **365 dias**.

**Q6: Materialized views podem unir múltiplas tabelas base?**
A6: **Não.** MVs do Snowflake suportam apenas tabela base única.

**Q7: O que o Query Acceleration Service (QAS) faz?**
A7: Transfere porções intensivas em escaneamento de queries elegíveis para computação serverless, complementando o warehouse.

**Q8: O result cache é invalidado quando ____?**
A8: Dados subjacentes mudam (DML), 24 horas passam, ou o usuário muda de role.

**Q9: Qual é a configuração mínima de auto-suspend?**
A9: **60 segundos** (ou 0 para suspensão imediata).

**Q10: Warehouses otimizados para Snowpark têm ___x mais memória.**
A10: **16x** mais memória por nó comparado a warehouses padrão.

**Q11: INFORMATION_SCHEMA mostra dados para qual escopo?**
A11: Apenas o **banco de dados atual**. Para dados de toda a conta, use ACCOUNT_USAGE.

**Q12: Como funciona o Search Optimization Service?**
A12: Constrói um caminho de acesso de busca persistente (mantido por serverless) para buscas pontuais seletivas, predicados de igualdade e funções geográficas.

**Q13: Resource monitors rastreiam o quê?**
A13: Apenas **créditos de computação**. Eles NÃO rastreiam custos de armazenamento.

**Q14: Para onde vão os logs de UDF/procedure?**
A14: A **event table** — uma única tabela no nível de conta definida via `ALTER ACCOUNT SET EVENT_TABLE`.

**Q15: Quais colunas devem vir primeiro em uma clustering key?**
A15: **Colunas de baixa cardinalidade primeiro** (ex: region, status) para máxima eficiência de pruning.

---

## EXPLIQUE COMO SE EU TIVESSE 5 ANOS — Domínio 4

**ELI5 #1: Query Profile**
Imagine que você está construindo um castelo de LEGO e alguém tira uma foto em cada etapa. O Query Profile são essas fotos — ele mostra exatamente qual etapa demorou mais e onde as coisas travaram.

**ELI5 #2: Dimensionamento de Warehouse**
Um warehouse é como contratar trabalhadores. X-Small = 1 trabalhador, Small = 2, Medium = 4. Mais trabalhadores custam mais dinheiro. Mas se o trabalho precisa de uma ferramenta especial (SQL melhor), contratar mais trabalhadores não vai ajudar.

**ELI5 #3: Result Cache**
Você pergunta para sua mãe "O que tem pra janta?" Ela diz "Macarrão." Você pergunta de novo 5 minutos depois — ela lembra e diz "Macarrão" instantaneamente sem verificar a cozinha. Isso é o result cache. Mas se ela começa a cozinhar outra coisa, a resposta muda.

**ELI5 #4: Pruning de Micro-partition**
Você tem 1.000 caixas de brinquedos etiquetadas. Cada etiqueta diz o que tem dentro (ex: "carros de 2020"). Quando você quer "carros de 2020", você só abre as caixas etiquetadas "2020" em vez de todas as 1.000.

**ELI5 #5: Clustering Keys**
Você organiza sua estante de livros por cor primeiro, depois por tamanho. Agora quando alguém pede "todos os livros azuis", você vai direto para a seção azul em vez de verificar cada prateleira.

**ELI5 #6: Spilling**
Sua mesa é pequena demais para seu quebra-cabeça. Você derrama peças no chão (disco local) — mais lento mas ok. Se o chão lota, você move peças para a garagem (remote storage) — muito mais lento. Mesa maior = warehouse maior.

**ELI5 #7: Warehouses Multi-cluster**
Uma sorveteria com filas longas. Multi-cluster = abrir mais lojas quando a fila fica muito longa. Política Standard: abrir uma nova loja assim que alguém espera. Política Economy: só abrir se a fila estiver realmente, realmente longa.

**ELI5 #8: Search Optimization**
Sua professora fez um índice no final do livro didático. Em vez de ler cada página para encontrar "dinossauros", você olha no índice, encontra "página 42", e vai direto lá.

**ELI5 #9: Resource Monitors**
Seus pais te dão R$20 para jogos de fliperama. Um resource monitor é como um rastreador: em R$15 ele te avisa, em R$20 ele tira o dinheiro para que você não gaste demais.

**ELI5 #10: Materialized Views**
Toda manhã sua professora escreve "Cardápio do Almoço de Hoje" no quadro. Em vez de todo mundo ir à cantina para verificar, eles só olham o quadro. Quando o cardápio muda, a professora atualiza o quadro automaticamente.

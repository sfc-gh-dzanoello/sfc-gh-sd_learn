# DOMÍNIO 1: RECURSOS E ARQUITETURA DO SNOWFLAKE AI DATA CLOUD
## 31% do exame = ~31 questões. Este é o MAIOR domínio.

---

## 1.1 AS TRÊS CAMADAS

Snowflake = híbrido de shared-disk + shared-nothing.
Três camadas independentes que escalam independentemente:

```
┌─────────────────────────────────┐
│      CAMADA DE CLOUD SERVICES   │  ← "O Cérebro"
│  Auth, Segurança, Metadados,    │
│  Otimizador de Consultas,       │
│  Transações. Funciona 24/7.     │
│  Cobrado apenas se >10% dos     │
│  créditos diários de warehouse  │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│        CAMADA DE COMPUTE        │  ← "O Músculo"
│  Virtual Warehouses (VW)        │
│  Clusters independentes, sem    │
│  compartilhamento entre WHs     │
│  Cobrado por segundo (mín 60s)  │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│  CAMADA DE ARMAZENAMENTO (DB)   │  ← "A Memória"
│  Armazenamento centralizado     │
│  Micro-partições colunares      │
│  Comprimidas, criptografadas,   │
│  imutáveis. Cobrado por TB/mês  │
└─────────────────────────────────┘
```

### A Camada de Cloud Services cuida de:
- Autenticação + controle de acesso (RBAC + DAC)
- Análise + otimização de consultas
- Gerenciamento de metadados
- Gerenciamento de transações (conformidade ACID)
- Gerenciamento de infraestrutura
- Segurança + criptografia

**Armadilha do exame**: "Qual camada cuida da otimização de consultas?" → Cloud Services. SE VOCÊ VER "Camada de Compute otimiza" → ERRADO, Compute apenas executa consultas.
**Armadilha do exame**: "Qual camada cuida de ACID/transações?" → Cloud Services. SE VOCÊ VER "Camada de Storage" ou "Camada de Compute" com "transações" → ERRADO, apenas Cloud Services gerencia transações.
**Armadilha do exame**: "Qual camada garante que o Usuário A não veja mudanças não commitadas do Usuário B?" → Cloud Services (Gerenciamento de Transações). SE VOCÊ VER "isolamento" + "Compute" → ERRADO, isolamento de transações = Cloud Services.

### Cobrança de Cloud Services:
- Só é cobrada se o uso de Cloud Services > 10% do uso diário total de créditos de warehouse
- A maioria das contas nunca atinge esse limite

Armadilha do exame: "Cloud Services é sempre cobrada separadamente" → ERRADO. SE VOCÊ VER "sempre" + "cobrada" com Cloud Services → ERRADO, só é cobrada se exceder 10% dos créditos diários de warehouse.
Armadilha do exame: "O limite de 10% é mensal" → ERRADO. SE VOCÊ VER "mensal" com o limite de 10% → ERRADO, é calculado DIARIAMENTE, não mensalmente.

### Camada de Compute:
- Virtual warehouses = clusters MPP independentes
- Um warehouse NÃO afeta outro
- Carga + consulta podem acontecer simultaneamente na mesma tabela (warehouses diferentes)
- O cache do warehouse fica aqui (perdido quando o warehouse é suspenso)

Armadilha do exame: "Cache do warehouse persiste após suspensão" → ERRADO. SE VOCÊ VER "persiste" ou "mantido" com "suspender" → ERRADO, cache SSD é PERDIDO ao suspender. Apenas o cache de resultados (Cloud Services) sobrevive.
Armadilha do exame: "Dois warehouses compartilham recursos de compute" → ERRADO. SE VOCÊ VER "compartilham" ou "recursos compartilhados" entre warehouses → ERRADO, cada warehouse é totalmente independente.

### Camada de Armazenamento:
- Dados armazenados no blob storage do provedor de nuvem (S3, Azure Blob, GCS)
- Formato colunar, comprimido, criptografado
- O cliente não pode acessar diretamente os arquivos subjacentes
- Cobrado mensalmente por TB (comprimido)

Armadilha do exame: "Clientes podem acessar diretamente os arquivos de armazenamento subjacentes" → ERRADO. SE VOCÊ VER "acesso direto" ou "navegar objetos S3" → ERRADO, Snowflake gerencia todos os arquivos — sem acesso direto.
Armadilha do exame: "Armazenamento é cobrado por TB descomprimido" → ERRADO. SE VOCÊ VER "descomprimido" com cobrança de armazenamento → ERRADO, cobrado por TB COMPRIMIDO.


### Exemplos de Perguntas de Cenário — Three Layers

**Cenário:** A data engineer notices that query compilation takes unusually long, but once running, queries complete quickly. Which layer is the bottleneck, and what might cause this?
**Resposta:** Cloud Services layer — it handles query parsing, optimization, and compilation. Possible causes: very complex SQL with many joins/subqueries, or high metadata overhead. This is NOT a Compute issue since execution is fast.

**Cenário:** Two teams share the same Snowflake account. Team A runs heavy ETL jobs while Team B runs real-time dashboards. Team B complains about slow performance. The admin confirms they use separate warehouses. Is it possible that Team A's workload affects Team B?
**Resposta:** No. Virtual warehouses are completely independent in the Compute layer. Each warehouse has its own dedicated resources. If Team B is slow, the issue is with their own warehouse size, not Team A's workload. Check if Team B's warehouse needs scaling up.

**Cenário:** An auditor asks: "Where does Snowflake physically store our data, and can we access the raw files for compliance?" What is the correct answer?
**Resposta:** Data is stored in the cloud provider's blob storage (S3/Azure Blob/GCS) in the Storage layer, in compressed, encrypted, columnar micro-partitions. You CANNOT directly access the raw files — Snowflake manages all storage. For compliance, use ACCOUNT_USAGE views, Access History, and Time Travel instead.

**Cenário:** Your Cloud Services costs suddenly spike to 15% of your daily warehouse credits. What happened and what do you pay?
**Resposta:** You only pay for the amount exceeding 10%. If Cloud Services = 15% and warehouse credits = 100, you pay for 5 credits of Cloud Services (15 - 10 = 5). Common causes: excessive SHOW/DESCRIBE commands, heavy metadata operations, or complex query compilation on many small queries.

---

---

## 1.2 FUNDAMENTOS DA CONTA SNOWFLAKE

### Uma conta = um provedor de nuvem + uma região
- Uma conta NÃO pode abranger múltiplos provedores de nuvem
- Para usar AWS + Azure = precisam de contas separadas
- Use Organizations para vincular contas entre provedores/regiões
- Replicação pode sincronizar dados entre contas

### Identificadores de Conta (dois formatos):
1. **Organização + Nome da conta**: `minhaorg-minhaconta` (preferido)
2. **Account locator**: formato legado, específico por região (ex: `xy12345.us-east-1`)

Armadilha do exame: "Account locator é o formato preferido" → ERRADO. SE VOCÊ VER "locator" como "preferido" ou "recomendado" → ERRADO, `minhaorg-minhaconta` é preferido. Locator é legado.
Armadilha do exame: "Uma conta pode abranger AWS e Azure" → ERRADO. SE VOCÊ VER "abranger" ou "múltiplos provedores" em uma conta → ERRADO, uma conta = um provedor de nuvem + uma região.
Armadilha do exame: "Replicação move a conta para outra região" → ERRADO. SE VOCÊ VER "move" com replicação → ERRADO, replicação sincroniza DADOS entre contas. A conta fica no lugar.


### Exemplos de Perguntas de Cenário — Account Basics

**Cenário:** A multinational company wants to use Snowflake on AWS in us-east-1 for their US team and Azure West Europe for their EU team. How many Snowflake accounts do they need?
**Resposta:** At least 2 accounts — one per cloud provider/region combination. They should use Snowflake Organizations to manage both accounts and database replication to sync shared data between them.

**Cenário:** A developer shares their account identifier as `xy12345.us-east-1`. A colleague in another region tries to connect using that identifier but it doesn't resolve. Why?
**Resposta:** Account locators are region-specific and legacy format. The preferred approach is using the organization-based format `myorg-myaccount` which works globally. The locator `xy12345.us-east-1` only works for that specific region.

**Cenário:** Management wants disaster recovery across AWS regions. Can they replicate their Snowflake account from us-east-1 to us-west-2?
**Resposta:** Yes, but it requires a second Snowflake account in us-west-2. Database replication syncs data objects, while account replication (Business Critical+) syncs users, roles, warehouses, and policies. Both accounts are linked via Organizations.

---

---

## 1.3 EDIÇÕES (MUITO IMPORTANTE NO EXAME)

### Standard Edition — TUDO isso está incluído:
- Virtual warehouses (cluster único apenas)
- Time Travel de 1 dia
- Fail-safe de 7 dias (apenas tabelas permanentes)
- Criptografia automática (AES-256)
- Políticas de rede, MFA, SSO, OAuth
- RBAC + DAC
- UDFs (Java, JavaScript, Python, SQL)
- Stored procedures (Java, JavaScript, Python, Scala, SQL)
- Snowpark
- Tabelas dinâmicas
- Tabelas externas
- Tabelas híbridas
- Clustering (automático)
- Compartilhamento de dados
- Monitores de recursos
- Suporte SQL padrão
- Dados semi-estruturados (JSON, Avro, ORC, Parquet, XML)
- Suporte a dados não estruturados
- Data Quality / Data Metric Functions

### Enterprise Edition = Standard + estas adições:
- Warehouses multi-cluster (escalar HORIZONTALMENTE)
- Time Travel estendido (até 90 dias)
- Segurança a nível de coluna (políticas de mascaramento)
- Segurança a nível de linha (políticas de acesso a linhas)
- Políticas de agregação
- Políticas de projeção
- Classificação de dados
- Histórico de Acesso (view ACCOUNT_USAGE)
- Rekeying periódico de dados criptografados
- Serviço de Otimização de Busca
- Serviço de Aceleração de Consultas
- Vistas materializadas
- Geração de dados sintéticos

### Business Critical = Enterprise + estas adições:
- Tri-Secret Secure (chaves gerenciadas pelo cliente)
- Conectividade privada (AWS PrivateLink, Azure Private Link, GCP Private Service Connect)
- Conformidade PHI/HIPAA/HITRUST
- Suporte PCI DSS
- Suporte FedRAMP/ITAR
- Failover/failback de conta (recuperação de desastres)

### VPS (Virtual Private Snowflake) = Business Critical +:
- Ambiente completamente isolado
- Armazenamento de metadados dedicado
- Pool de compute dedicado
- Sem recursos compartilhados com outras contas Snowflake

### TABELA DE REFERÊNCIA DE EDIÇÕES — O que vai onde:

| Recurso | Edição |
|---|---|
| Clustering | TODAS (automático) |
| Tabelas dinâmicas | TODAS |
| Snowpark | TODAS |
| UDFs + Stored Procs | TODAS |
| Políticas de rede | TODAS |
| MFA, SSO, OAuth | TODAS |
| Time Travel 1 dia | TODAS |
| Fail-safe (7 dias) | TODAS (tabelas permanentes) |
| Monitores de recursos | TODAS |
| Data Quality / DMFs | TODAS |
| Warehouses multi-cluster | Enterprise+ |
| Time Travel estendido (90 dias) | Enterprise+ |
| Segurança a nível de coluna (mascaramento) | Enterprise+ |
| Políticas de acesso a linhas | Enterprise+ |
| Otimização de Busca | Enterprise+ |
| Aceleração de Consultas | Enterprise+ |
| Vistas materializadas | Enterprise+ |
| Classificação de dados | Enterprise+ |
| Histórico de Acesso | Enterprise+ |
| Rekeying periódico | Enterprise+ |
| Tri-Secret Secure | Business Critical+ |
| Conectividade privada (PrivateLink) | Business Critical+ |
| Suporte PHI/HIPAA | Business Critical+ |
| Armazenamento de metadados dedicado | Apenas VPS |

Armadilha do exame: "Políticas de mascaramento estão disponíveis em Standard" → ERRADO. SE VOCÊ VER "Standard" + "mascaramento" ou "segurança a nível de coluna" → ERRADO, mascaramento requer Enterprise+.
Armadilha do exame: "Warehouses multi-cluster funcionam em Standard" → ERRADO. SE VOCÊ VER "Standard" + "multi-cluster" → ERRADO, multi-cluster requer Enterprise+. Standard = cluster único apenas.
Armadilha do exame: "Tri-Secret Secure é Enterprise" → ERRADO. SE VOCÊ VER "Enterprise" com "Tri-Secret" → ERRADO, Tri-Secret = Business Critical+. Não confunda com rekeying periódico (Enterprise+).


### Exemplos de Perguntas de Cenário — Editions

**Cenário:** A healthcare company needs to store PHI (Protected Health Information) in Snowflake and must comply with HIPAA. They're currently on Enterprise edition. Is this sufficient?
**Resposta:** No. HIPAA/PHI compliance requires Business Critical edition or higher. Enterprise provides masking policies and row access policies for data protection, but the compliance certifications (HIPAA, HITRUST, PCI DSS) are only available starting at Business Critical.

**Cenário:** A startup wants to use dynamic masking policies to hide PII from junior analysts. They have Standard edition. Will this work?
**Resposta:** No. Masking policies (column-level security) require Enterprise edition or higher. The startup needs to upgrade to Enterprise. Standard includes network policies, MFA, SSO, and RBAC, but NOT dynamic data masking.

**Cenário:** A company's data team wants to use multi-cluster warehouses to handle 200 concurrent dashboard users during peak hours. They have Standard edition. What do they need?
**Resposta:** Upgrade to Enterprise edition. Multi-cluster warehouses (horizontal scaling) require Enterprise+. On Standard, they're limited to a single cluster per warehouse, which means queries will queue during high concurrency.

**Cenário:** Your security team demands that encryption keys be managed by your organization (customer-managed keys) so you can revoke access at any time. Which edition and feature do you need?
**Resposta:** Business Critical edition with Tri-Secret Secure. This creates a composite master key using both a Snowflake-managed key and a customer-managed key (via AWS KMS, Azure Key Vault, or GCP Cloud KMS). If you revoke your key, data becomes inaccessible.

---

---

## 1.4 VIRTUAL WAREHOUSES (MUITO IMPORTANTE NO EXAME)

### O que são:
- Clusters de compute MPP independentes
- Necessários para consultas E DML (INSERT, UPDATE, DELETE, COPY INTO)
- NÃO necessários para operações de metadados (SHOW, DESCRIBE, algumas consultas COUNT)

### Tamanhos (Gen1):
XS=1 crédito/hr → S=2 → M=4 → L=8 → XL=16 → 2XL=32 → 3XL=64 → 4XL=128 → 5XL=256 → 6XL=512

**Padrão**: cada tamanho ACIMA = dobro dos créditos = dobro do compute

Armadilha do exame: "Um warehouse Medium é 3x um XS" → ERRADO. SE VOCÊ VER "3x" ou qualquer multiplicador que não é potência de 2 → ERRADO, cada tamanho DOBRA (1→2→4→8→16). M = 4x XS.
Armadilha do exame: "SHOW e DESCRIBE requerem warehouse em execução" → ERRADO. SE VOCÊ VER "warehouse necessário" para SHOW/DESCRIBE → ERRADO, operações de metadados não precisam de warehouse.

### Warehouses Gen2 (NOVO para COF-C03):
- Geração mais nova de warehouses padrão
- Ainda não é padrão, não disponível em todas as regiões
- Mesmos nomes de tamanho mas consumo de créditos diferente
- Melhor desempenho por crédito para muitas cargas de trabalho

### Warehouses Otimizados para Snowpark:
- Projetados para cargas de trabalho Snowpark (Python, Java, Scala)
- Mais memória por nó
- Use para: treinamento ML, UDFs grandes, operações Snowpark intensivas em dados
- Custo de crédito maior que warehouses padrão

Armadilha do exame: "Warehouses Otimizados para Snowpark são mais baratos" → ERRADO. SE VOCÊ VER "mais barato" ou "menor custo" com Snowpark-Optimized → ERRADO, custam MAIS créditos pela memória extra.
Armadilha do exame: "Todo código Snowpark precisa de warehouses Snowpark-Optimized" → ERRADO. SE VOCÊ VER "requer" ou "precisa" Snowpark-Optimized → ERRADO, warehouses padrão executam Snowpark normalmente. Optimized = apenas para ML pesado.

### Warehouse Padrão para Notebooks:
- SYSTEM$STREAMLIT_NOTEBOOK_WH (provisionado automaticamente)
- Multi-cluster XS, máximo 10 clusters, timeout de 60 segundos
- ACCOUNTADMIN é o proprietário
- Melhor prática: use apenas para cargas Python de notebook, use warehouse separado para consultas SQL de notebooks

### Cobrança:
- Cobrança por segundo
- Mínimo de 60 segundos cada vez que o warehouse inicia
- Créditos consumidos apenas enquanto está em execução
- Warehouse suspenso = zero créditos

Armadilha do exame: "Cobrança é por minuto" → ERRADO. SE VOCÊ VER "por minuto" → ERRADO, é por SEGUNDO com mínimo de 60 segundos.
Armadilha do exame: "Um warehouse suspenso ainda custa créditos" → ERRADO. SE VOCÊ VER "suspenso" + "créditos" ou "custos" → ERRADO, suspenso = zero créditos. Apenas em execução = cobrado.

### Auto-Suspend + Auto-Resume:
- Auto-suspend: warehouse suspende após X segundos de inatividade (padrão varia)
- Auto-resume: warehouse inicia automaticamente quando uma consulta chega (habilitado por padrão)
- Ambos se aplicam ao warehouse INTEIRO, não a clusters individuais

Armadilha do exame: "Auto-suspend se aplica por cluster em multi-cluster" → ERRADO. SE VOCÊ VER "por cluster" com auto-suspend → ERRADO, auto-suspend se aplica ao warehouse INTEIRO.
Armadilha do exame: "Auto-resume é desabilitado por padrão" → ERRADO. SE VOCÊ VER "desabilitado" + "auto-resume" → ERRADO, auto-resume é HABILITADO por padrão.

### Escalar VERTICALMENTE vs Escalar HORIZONTALMENTE:

| | Escalar VERTICALMENTE | Escalar HORIZONTALMENTE |
|---|---|---|
| O quê | Warehouse de tamanho maior | Mais clusters (multi-cluster) |
| Quando | Consultas complexas, spilling | Alta concorrência, muitos usuários |
| Como | ALTER WAREHOUSE SET SIZE | Definir MAX_CLUSTER_COUNT > 1 |
| Edição | TODAS | Enterprise+ |
| Resolve | Consultas únicas lentas, spilling | Tempos de espera em fila |

### Warehouses Multi-cluster (Enterprise+):
- Clusters mínimos = 1 a 10
- Clusters máximos = 1 a 10
- Se MIN = MAX → **Modo Maximizado** (sempre essa quantidade de clusters)
- Se MIN < MAX → **Modo Auto-scale**

### Políticas de Escalonamento (para auto-scale):
- **Standard**: inicia novo cluster imediatamente quando uma consulta entra em fila. Desliga após 2-3 minutos ociosos. Favorece desempenho.
- **Economy**: inicia novo cluster apenas se estimado que ficará ocupado por 6+ minutos. Favorece economia de custos.

**Armadilha do exame**: "Economy prioriza..." → Economia de créditos / throughput. SE VOCÊ VER "Economy" + "desempenho" ou "rápido" → ERRADO, Economy favorece economia de custos, não velocidade.
**Armadilha do exame**: "Standard prioriza..." → Desempenho / resposta rápida. SE VOCÊ VER "Standard" + "economia de custos" → ERRADO, Standard favorece desempenho, inicia clusters imediatamente.

### Por que isso importa + Casos de uso

**Por que warehouses separados?** Porque a consulta pesada de uma equipe não deveria atrasar outra equipe. Warehouses são INDEPENDENTES — não compartilham recursos.

**Cenário real — "Nosso dashboard BI fica lento durante cargas ETL"**
Uma empresa executa COPY INTO (carga) e consultas Tableau no MESMO warehouse. Durante a carga, usuários do dashboard esperam na fila. Solução: warehouses separados — um para carga (auto-suspend após 1 min), um para BI (sempre ativo durante horário comercial).

**Cenário real — "Nosso relatório mensal leva 3 horas no XS"**
A consulta é complexa e derrama para disco remoto. Solução: escalar VERTICALMENTE para Large ou XL para essa consulta específica. O relatório executa em 15 minutos. Depois reduz de volta. Cobrança por segundo significa que você paga apenas por esses 15 minutos.

**Cenário real — "50 analistas consultando às 9h"**
Consultas entram em fila porque há apenas 1 cluster. Solução: warehouse multi-cluster (Enterprise+) com política de escalonamento Standard. Novos clusters iniciam imediatamente quando consultas entram em fila. Às 11h quando o tráfego cai, clusters desligam automaticamente.

**A armadilha de escalonamento que o exame adora:**
- "Derramamento para disco" → Escalar VERTICALMENTE (warehouse maior, mais memória)
- "Consultas em fila" → Escalar HORIZONTALMENTE (mais clusters, multi-cluster)
- NUNCA o contrário. O exame VAI tentar te enganar.

---

### Melhores Práticas para Warehouses:
- Warehouses separados para cargas de trabalho diferentes (carga vs consulta vs BI)
- Warehouses separados para equipes diferentes
- Usar auto-suspend (economizar créditos)
- Escalar VERTICALMENTE para consultas complexas com spilling
- Escalar HORIZONTALMENTE para problemas de concorrência
- Começar pequeno, redimensionar conforme necessário

Armadilha do exame: "Um warehouse grande para todas as cargas é melhor prática" → ERRADO. SE VOCÊ VER "warehouse único" ou "um warehouse para tudo" → ERRADO, melhor prática = warehouses SEPARADOS por carga de trabalho.
Armadilha do exame: "Redimensionar um warehouse afeta consultas em execução" → ERRADO. SE VOCÊ VER "consultas em execução" + "redimensionar" + "afetadas" → ERRADO, consultas em execução usam o tamanho ANTIGO. Apenas NOVAS consultas usam o novo tamanho.


### Exemplos de Perguntas de Cenário — Virtual Warehouses

**Cenário:** A Query Profile shows significant "Bytes spilled to remote storage" for a complex join query running on an XS warehouse. What should you do?
**Resposta:** Scale UP vertically — increase the warehouse size to Medium or Large. Spilling to remote storage means the warehouse doesn't have enough local SSD memory, so data overflows to slower remote storage. A bigger warehouse = more memory = less spilling = faster query. Do NOT add more clusters (horizontal scaling) — that only helps with concurrency, not individual query performance.

**Cenário:** At 9 AM every Monday, 80 analysts run their weekly reports simultaneously. The warehouse queue shows 60+ queries waiting. The warehouse is XL. What should you do?
**Resposta:** Enable multi-cluster warehouse (requires Enterprise+) with auto-scale mode. Set MIN_CLUSTER_COUNT=1, MAX_CLUSTER_COUNT=5, scaling policy=Standard. This starts new clusters immediately when queries queue. The XL size is fine for individual queries — the problem is concurrency, not query complexity.

**Cenário:** A warehouse was suspended for 4 hours. A user runs the same query they ran yesterday. The query takes much longer than yesterday. Why?
**Resposta:** The warehouse's local SSD cache (warm cache) was cleared when the warehouse was suspended. Yesterday's query benefited from cached data. Today the query must re-read data from remote storage. Note: the result cache (in Cloud Services) may still have yesterday's result IF the underlying data hasn't changed — but if data changed, a full re-scan is needed.

**Cenário:** You have a multi-cluster warehouse with MIN=1, MAX=4 and Economy scaling policy. During a burst of 30 concurrent queries, users complain about wait times. What's happening?
**Resposta:** Economy policy only starts a new cluster if the system estimates it will be busy for 6+ minutes. Short bursts may not trigger new clusters. Switch to Standard scaling policy, which starts new clusters immediately when queries queue. Standard favors performance; Economy favors cost savings.

**Cenário:** An admin creates a Snowpark-Optimized warehouse for a team that writes simple SELECT queries on small tables. Is this the right choice?
**Resposta:** No. Snowpark-Optimized warehouses cost more credits because they have extra memory per node. They're designed for memory-intensive workloads like ML training, large UDFs, and heavy Snowpark DataFrame operations. For simple SELECT queries, a standard warehouse is more cost-effective.

---

---

## 1.5 MICRO-PARTIÇÕES E CLUSTERING DE DADOS

### Micro-partições:
- Snowflake automaticamente divide TODOS os dados de tabela em micro-partições
- Tamanho: 50-500 MB descomprimido (menor quando comprimido)
- Armazenamento colunar dentro de cada partição
- Imutáveis (não podem ser alteradas, apenas substituídas)
- Usuários NÃO definem nem gerenciam manualmente

### Que metadados são armazenados por micro-partição:
- Valores mínimo e máximo para cada coluna
- Número de valores distintos
- Número de valores nulos
- Propriedades adicionais de otimização

**Armadilha do exame**: "Que metadados são armazenados?" → Valores mín/máx, contagem de distintos, contagem de nulos. SE VOCÊ VER "histórico de consultas" ou "nomes de usuários" como metadados → ERRADO, apenas metadados estatísticos são armazenados.

### Pruning de Consultas:
- Snowflake usa metadados de micro-partição para pular partições irrelevantes
- Só escaneia partições onde os dados PODEM corresponder ao filtro
- Também pruna a nível de COLUNA dentro das partições (colunar = só escaneia colunas necessárias)

**Armadilha do exame**: "O que impede pruning efetivo?" → Usar funções em colunas filtradas. SE VOCÊ VER "WHERE UPPER(col)" ou "WHERE CAST(col...)" → armadilha! Funções nas colunas anulam o pruning.

### Clustering de Dados:
- Dados são naturalmente agrupados pela ordem de inserção
- Profundidade de clustering = quantas partições se sobrepõem para uma coluna
- Menor profundidade = melhor clustering = consultas mais rápidas
- Disponível em TODAS as edições (clustering automático)
- Chaves de Clustering = você define por quais colunas agrupar
- Clustering Automático = serviço em segundo plano mantém o clustering (serverless, custa créditos)

### Profundidade de Clustering:
- SYSTEM$CLUSTERING_DEPTH(tabela, colunas) → verificar profundidade
- SYSTEM$CLUSTERING_INFORMATION(tabela, colunas) → informações detalhadas de clustering
- Profundidade de 1 = perfeitamente agrupado (sem sobreposição)

Armadilha do exame: "Maior profundidade de clustering = melhor" → ERRADO. SE VOCÊ VER "maior" + "melhor" com profundidade de clustering → ERRADO, MENOR profundidade = melhor. Profundidade 1 = perfeito.

### Quando usar chaves de clustering:
- Tabelas muito grandes (multi-terabyte)
- Consultas frequentemente filtram por colunas específicas
- Profundidade de clustering é alta (muita sobreposição)
- NÃO para tabelas pequenas (desperdício de créditos)

Armadilha do exame: "Todas as tabelas se beneficiam de chaves de clustering" → ERRADO. SE VOCÊ VER "todas as tabelas" + "chaves de clustering" → ERRADO, apenas tabelas muito grandes (multi-TB) se beneficiam. Tabelas pequenas = desperdício de créditos.
Armadilha do exame: "Clustering Automático requer Enterprise" → ERRADO. SE VOCÊ VER "Enterprise" + "clustering" → ERRADO, clustering = TODAS as edições. Não confunda com warehouses multi-cluster (Enterprise+).


### Exemplos de Perguntas de Cenário — Micro-partitions & Clustering

**Cenário:** A 10TB orders table is frequently queried with `WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31'`. The query scans 95% of all micro-partitions despite the date filter. What's the problem and the fix?
**Resposta:** The data has poor natural clustering on `order_date` — micro-partitions have overlapping date ranges so Snowflake can't effectively prune. Fix: define a clustering key on `order_date` with `ALTER TABLE orders CLUSTER BY (order_date)`. Automatic Clustering will reorganize data in the background. Verify improvement with `SYSTEM$CLUSTERING_DEPTH('orders', '(order_date)')` — the depth should decrease over time.

**Cenário:** A developer writes `WHERE UPPER(customer_name) = 'JOHN'` on a table with a clustering key on `customer_name`. The query is still slow. Why?
**Resposta:** Wrapping a column in a function (like UPPER()) prevents micro-partition pruning. Snowflake stores min/max metadata for the raw column values, not for function results. Rewrite as `WHERE customer_name = 'John'` (if data is consistent) or use a case-insensitive collation. This is a common exam trap.

**Cenário:** A team adds clustering keys to every table in their schema, including a 50MB lookup table. Is this appropriate?
**Resposta:** No. Clustering keys are only beneficial for very large tables (multi-TB). A 50MB table fits into a single micro-partition — there's nothing to prune. Adding clustering keys wastes credits on Automatic Clustering maintenance with zero query benefit.

**Cenário:** You run `SYSTEM$CLUSTERING_DEPTH('sales', '(region)')` and get a depth of 15. What does this tell you?
**Resposta:** The clustering depth of 15 means there are many micro-partitions with overlapping `region` values — poor clustering. Ideally you want depth close to 1 (no overlap). If `region` is a frequent filter column, this table would benefit from a clustering key on `region`. After setting the key, Automatic Clustering will reduce depth over time.

---

---

## 1.6 TIPOS DE TABELA (MUITO TESTADO)

### Tabelas Permanentes (padrão):
- Time Travel completo (1 dia Standard, até 90 dias Enterprise+)
- Fail-safe de 7 dias após Time Travel expirar
- Maior custo de armazenamento (dados + Time Travel + Fail-safe)

### Tabelas Transientes:
- Time Travel: 0 ou 1 dia apenas (mesmo em Enterprise+, máximo 1 dia)
- SEM Fail-safe
- Persistem entre sessões
- Visíveis para outros usuários/roles com acesso
- Menor custo de armazenamento que permanentes
- Boas para: dados de staging, tabelas intermediárias de ETL

### Tabelas Temporárias:
- Time Travel: 0 ou 1 dia
- SEM Fail-safe
- Escopo de sessão (eliminadas quando a sessão termina)
- Visíveis apenas para a sessão que as criou
- Sessões diferentes podem ter tabelas temp com o mesmo nome
- Se a sessão desconecta (falha de rede) → tabela é eliminada imediatamente

**Armadilha do exame**: "Tabela temporária + falha de rede?" → Tabela eliminada imediatamente. SE VOCÊ VER "persiste" ou "recuperável" após desconexão → ERRADO, tabela temp = perdida instantaneamente.
**Armadilha do exame**: "Transiente vs Temporária?" → Transiente persiste entre sessões, Temporária é apenas da sessão. SE VOCÊ VER "transiente" + "escopo de sessão" → ERRADO, isso é temporária.
**Armadilha do exame**: "Você pode converter Transiente para Permanente?" → NÃO (deve recriar). SE VOCÊ VER "ALTER" + "converter" entre tipos de tabela → ERRADO, deve CREATE nova + copiar dados.

### Tabelas Externas:
- Somente leitura
- Dados ficam em stage externo (S3, Azure Blob, GCS)
- Metadados gerenciados pelo Snowflake
- Podem ser usadas com Directory Tables
- Sem Time Travel, sem Fail-safe
- Úteis para data lakes

Armadilha do exame: "Tabelas externas suportam INSERT/UPDATE" → ERRADO. SE VOCÊ VER "INSERT", "UPDATE", ou "DML" com tabelas externas → ERRADO, tabelas externas são SOMENTE LEITURA.

### Tabelas Dinâmicas (NOVO para COF-C03):
- Definidas por uma consulta SQL (instrução SELECT)
- Snowflake automaticamente mantém os resultados atualizados
- Você define um "target lag" (meta de frescura)
- Pode ser refresh incremental ou completo
- Disponíveis em TODAS as edições
- Substituem pipelines complexos de Streams + Tasks para muitos casos
- Pense como: "Quero que esta tabela sempre reflita o resultado desta consulta"

### Tabelas Apache Iceberg (NOVO para COF-C03):
- Formato de tabela aberto
- Dados armazenados NO SEU armazenamento externo (S3, Azure, GCS)
- Metadados em formato Iceberg (não proprietário do Snowflake)
- Você gerencia o armazenamento
- Podem ser lidas por outros motores (Spark, Flink, etc.)
- Combina desempenho de consulta do Snowflake com formato aberto
- Use para data lakes / lakehouses

### Tabelas Híbridas:
- Otimizadas para cargas de trabalho transacionais de baixa latência
- Armazenamento baseado em LINHAS (não colunar)
- Suportam bloqueio de linha, restrições de integridade referencial e unicidade
- Use para Unistore (transacional + analítico juntos)
- Disponíveis em TODAS as edições

### Resumo dos Tipos de Tabela:

| Tipo | Time Travel | Fail-safe | Escopo | Persiste |
|---|---|---|---|---|
| Permanente | 1 dia (90 Enterprise+) | 7 dias | Conta | Sim |
| Transiente | 0-1 dia máx | NENHUM | Conta | Sim |
| Temporária | 0-1 dia máx | NENHUM | Apenas sessão | Não |
| Externa | NENHUM | NENHUM | Conta | Sim (somente leitura) |
| Dinâmica | Depende do tipo subjacente | Depende | Conta | Sim |
| Iceberg | Limitado | NENHUM | Conta | Sim |
| Híbrida | Limitado | Limitado | Conta | Sim |

---

### Melhores Práticas — Quando Usar Cada Tipo de Tabela
- **Permanente**: Dados de produção, dados de conformidade/auditoria, qualquer coisa que precise de recuperação de desastres
- **Transiente**: Tabelas de staging/ETL, agregações derivadas que podem ser recriadas. Economiza ~25-30% de armazenamento vs permanente (sem Fail-safe)
- **Temporária**: Trabalho apenas de sessão — consultas exploratórias, cálculos intermediários. Auto-eliminada quando a sessão termina (NÃO ao desconectar — sessões persistem durante quedas de rede)
- **Externa**: Consultas de data lake onde dados ficam em S3/Azure/GCS. Somente leitura
- **Dinâmica**: Substitui pipelines de Streams+Tasks. Defina target lag
- **Iceberg**: Formato aberto, SEU armazenamento. Use quando múltiplos motores precisam ler os mesmos dados
- **Híbrida**: Cargas transacionais de baixa latência (OLTP). NÃO para analytics
- NUNCA use tabelas permanentes para staging — desperdício (Fail-safe custa dinheiro para dados que você pode recriar)


### Exemplos de Perguntas de Cenário — Table Types

**Cenário:** Your ETL pipeline creates a staging table every morning, loads CSV files from S3, transforms data, and inserts into production tables. The staging data is deleted after each run. Currently using permanent tables for staging, and storage costs are high. What table type should you use for staging?
**Resposta:** Transient tables. Staging data can be recreated (just re-run the pipeline), so there's no need for Fail-safe. Switching from permanent to transient saves ~25-30% on storage costs. Do NOT use temporary — you want the table to persist across sessions in case the pipeline spans multiple sessions.

**Cenário:** A data analyst creates a temporary table during an interactive session to hold intermediate results of a complex analysis. Their VPN drops and the session disconnects. What happens to the data?
**Resposta:** The temporary table is immediately dropped — all data is lost. Temporary tables are session-scoped and cannot survive disconnection. If the work is important and takes time, use a transient table instead (persists across sessions, still no Fail-safe cost).

**Cenário:** Your company wants both Snowflake and Apache Spark to read the same dataset stored in S3. They don't want to maintain two copies. Which table type should they use?
**Resposta:** Apache Iceberg tables. Iceberg is an open table format stored in the customer's own storage (S3/Azure/GCS). Both Snowflake and Spark can read/write Iceberg format natively. The data stays in one place with one format — no duplication.

**Cenário:** A team wants a summary table that always reflects the latest aggregated sales data with no more than 1 hour delay. They currently use a complex Streams + Tasks pipeline that occasionally fails. What's a simpler approach?
**Resposta:** Create a Dynamic Table with `TARGET_LAG = '1 hour'`. Define the table as a SELECT query with the aggregation logic. Snowflake automatically refreshes it (incrementally when possible). No Streams, no Tasks, no pipeline code to maintain.

**Cenário:** An admin tries to run `ALTER TABLE staging_transient SET DATA_RETENTION_TIME_IN_DAYS = 45` on a transient table (Enterprise edition). Will this work?
**Resposta:** No. Transient tables have a maximum Time Travel retention of 1 day, even on Enterprise edition (which allows up to 90 days for permanent tables). The ALTER will fail. If you need 45-day Time Travel, you must use a permanent table.

---

---

## 1.7 TIPOS DE VIEW

### View Padrão:
- Consulta SQL armazenada (sem dados armazenados)
- Re-executa a consulta toda vez que é acessada
- Pode ver a definição SQL subjacente

### View Materializada (Enterprise+):
- Armazena resultados de consulta fisicamente
- Auto-atualizada por serviço em segundo plano (custa créditos)
- Leituras mais rápidas (pré-computada)
- Não pode usar todos os recursos SQL (limitada a tabela única)
- Melhor para: consultas caras em dados que não mudam frequentemente

### View Segura:
- Oculta a definição da view de não-proprietários
- Otimizador de consultas pode ser limitado (não pode ver definição para otimizar)
- Use para: compartilhamento de dados (requerida para shares), proteger lógica de negócios
- Pode ser segura padrão ou materializada segura

**Armadilha do exame**: "Qual tipo de view é requerido para compartilhamento de dados?" → View Segura. SE VOCÊ VER "view padrão" ou "view materializada" como requerida para compartilhamento → ERRADO, apenas views SEGURAS funcionam em shares.


### Exemplos de Perguntas de Cenário — View Types

**Cenário:** A company wants to share a curated dataset with an external Snowflake account via Secure Data Sharing. They have a standard view that joins 3 tables and applies business logic. Can they share this view directly?
**Resposta:** No. Data sharing requires SECURE views. The admin must recreate the view as `CREATE SECURE VIEW ...`. Secure views hide the view definition from consumers, which is required for shares. Standard views expose their SQL definition, which is not allowed in sharing.

**Cenário:** A BI team runs the same expensive aggregation query every 15 minutes on a 2TB table that only changes once per day. The query takes 3 minutes each time. What view type would help?
**Resposta:** A Materialized View (Enterprise+). It pre-computes and stores the results physically. Since the underlying data changes only once per day, the materialized view auto-refreshes once (cheap). The 15-minute queries become instant reads. The tradeoff: materialized views cost credits for background maintenance, and they're limited to single-table queries.

**Cenário:** A developer creates a secure view and notices that queries against it are slower than the same query run directly on the base table. Why?
**Resposta:** Secure views limit the query optimizer's ability to optimize because the view definition is hidden. The optimizer can't push predicates through the view boundary as aggressively. This is the security-performance tradeoff of secure views. Only use secure views when security requires it (sharing, protecting business logic).

---

---

## 1.8 HIERARQUIA DE OBJETOS

```
Organização
  └── Conta(s)
        └── Banco(s) de Dados
              └── Schema(s)
                    ├── Tabelas
                    ├── Views
                    ├── Stages
                    ├── Formatos de Arquivo
                    ├── Sequências
                    ├── Pipes
                    ├── Streams
                    ├── Tasks
                    ├── UDFs
                    ├── Stored Procedures
                    ├── Modelos ML
                    └── Aplicações (Native Apps)
```

### Nome Totalmente Qualificado: `banco_de_dados.schema.objeto`
### Namespace: banco_de_dados.schema

### Hierarquia de Parâmetros (precedência):
- Conta → definido por ACCOUNTADMIN
- Usuário → sobrescreve conta para aquele usuário
- Sessão → sobrescreve usuário para aquela sessão
- Objeto → depende do parâmetro

**Chave**: Configurações mais específicas sobrescrevem as menos específicas.

Armadilha do exame: "Nível de conta sobrescreve nível de sessão" → ERRADO. SE VOCÊ VER "conta sobrescreve sessão" → ERRADO, sessão sobrescreve conta. Mais específico vence (Objeto > Sessão > Usuário > Conta).


### Exemplos de Perguntas de Cenário — Object Hierarchy

**Cenário:** A new analyst runs `SELECT * FROM customers` and gets "Object does not exist" even though the table exists. Other team members can query it fine. What's likely wrong?
**Resposta:** The analyst's session context is set to a different database or schema. They need to either use the fully qualified name `database.schema.customers` or set the correct context with `USE DATABASE mydb; USE SCHEMA myschema;`. Check with `SELECT CURRENT_DATABASE(), CURRENT_SCHEMA()`.

**Cenário:** An admin sets `STATEMENT_TIMEOUT_IN_SECONDS = 3600` at the account level. A specific user needs longer timeouts for their ETL jobs. Can this be overridden?
**Resposta:** Yes. Set the parameter at the user level: `ALTER USER etl_user SET STATEMENT_TIMEOUT_IN_SECONDS = 7200`. More specific settings override less specific ones: Object > Session > User > Account. The ETL user gets 7200s while all other users keep 3600s.

**Cenário:** A developer asks: "Are stages account-level objects like warehouses?" How do you answer?
**Resposta:** No. Stages are schema-level objects — they live inside `database.schema`. Warehouses and roles are account-level objects (they exist outside any database). This distinction matters for RBAC — granting access to a stage requires schema-level privileges.

---

---

## 1.9 INTERFACES E FERRAMENTAS

### Snowsight:
- UI baseada em web
- Escrever + executar SQL
- Dashboards + visualizações
- Gerenciar warehouses, bancos de dados, usuários

### Snowflake CLI (snow):
- Ferramenta de linha de comando
- Gerenciar objetos Snowflake do terminal
- Executar SQL
- Deploy de aplicações Snowpark, apps Streamlit, Native Apps

### SnowSQL:
- Cliente de linha de comando
- Executar SQL
- PUT/GET arquivos (única forma de upload/download do local)

### Integração Git (NOVO para COF-C03):
- Conectar repositórios Git ao Snowflake
- Armazenar UDFs, procedures, apps Streamlit no Git
- Controle de versão para código Snowflake
- Objeto CREATE GIT REPOSITORY

Armadilha do exame: "Snowsight suporta comandos PUT/GET" → ERRADO. SE VOCÊ VER "Snowsight" + "PUT" ou "GET" → ERRADO, apenas SnowSQL (CLI) e conectores suportam PUT/GET.


### Exemplos de Perguntas de Cenário — Interfaces & Tools

**Cenário:** A developer needs to upload a 2GB CSV file from their local laptop to a Snowflake internal stage. They try using Snowsight but can't find an upload option for files this large. What tool should they use?
**Resposta:** Use SnowSQL (the CLI client) with the PUT command: `PUT file:///path/to/file.csv @my_stage`. Snowsight has a file upload limit and doesn't support the PUT/GET commands. For programmatic uploads, you can also use Snowflake connectors (Python, JDBC, etc.).

**Cenário:** A team wants to version-control their Snowflake UDFs and stored procedures in GitHub, and deploy changes automatically. How can they integrate Git with Snowflake?
**Resposta:** Use Git Integration (NEW in COF-C03): `CREATE GIT REPOSITORY` to connect your GitHub repo to Snowflake. The code stays in Git (not stored in Snowflake storage). You can then reference Git-stored files when creating UDFs, procedures, or Streamlit apps. For CI/CD, use the Snowflake CLI (`snow`) to deploy from Git.

**Cenário:** An admin wants to explore query performance issues using the VS Code extension for Snowflake. Can they view Query Profiles from VS Code?
**Resposta:** The VS Code extension lets you connect to Snowflake, run SQL, and browse objects. For detailed Query Profile analysis (execution plan, operator statistics, spilling details), use Snowsight — it provides the visual Query Profile with the full performance breakdown.

---

---

## 1.10 AI/ML E DESENVOLVIMENTO DE APPS (NOVO para COF-C03)

### Snowflake Notebooks:
- Ambiente de codificação interativo dentro do Snowflake
- Suporta células Python + SQL
- Use para exploração de dados, ML, análise

### Streamlit no Snowflake:
- Construa apps de dados diretamente no Snowflake
- Baseado em Python (framework Streamlit)
- Dados ficam no Snowflake (sem movimentação de dados)
- Governado pela segurança do Snowflake (RBAC)

### Snowpark:
- Escreva código em Python, Java, Scala
- API DataFrame que traduz para SQL
- Código executa DENTRO do warehouse (não no seu laptop)
- "Avaliação preguiçosa" = nada executa até você chamar uma ação (collect, show, write)
- Disponível em TODAS as edições

**Armadilha do exame**: "Onde o código Snowpark executa?" → Dentro do Virtual Warehouse. SE VOCÊ VER "lado do cliente", "máquina local", ou "Cloud Services" → ERRADO, Snowpark executa DENTRO do warehouse.
**Armadilha do exame**: "O que é avaliação preguiçosa?" → A consulta só executa quando uma ação é chamada. SE VOCÊ VER "execução imediata" ou "executa na definição" → ERRADO, nada executa até .collect()/.show().

### Snowflake Cortex (Funções AI):
- AI_COMPLETE → geração de texto (inferência LLM)
- AI_SENTIMENT → análise de sentimento
- AI_SUMMARIZE → resumo de texto
- AI_TRANSLATE → tradução de idiomas
- AI_EXTRACT → extração de entidades
- AI_CLASSIFY → classificação de texto
- AI_EMBED → gerar embeddings
- Executa dentro do Snowflake, dados ficam no Snowflake

### Cortex Search:
- Busca semântica sobre dados de texto

### Cortex Analyst:
- Linguagem natural para SQL
- Faça perguntas sobre seus dados em português simples
- Usa views semânticas / modelos semânticos

### Snowflake ML:
- Funções ML: previsão, detecção de anomalias, classificação embutidos
- Model Registry: armazenar e versionar modelos ML
- Feature Store: gerenciar features de ML

Armadilha do exame: "Cortex Analyst faz busca semântica" → ERRADO. Analyst = linguagem natural para SQL. Search = busca semântica. São diferentes.


### Exemplos de Perguntas de Cenário — AI/ML and App Development

**Cenário:** A data scientist wants to build a quick dashboard to let business users explore sales data interactively. They want the app to run inside Snowflake without moving data to an external server. What should they use?
**Resposta:** Use Streamlit in Snowflake. It allows you to build interactive Python-based data apps directly inside Snowflake. Data never leaves Snowflake, and the app is governed by Snowflake RBAC. No external hosting needed.

**Cenário:** A team has a Python ML pipeline that processes large DataFrames. They currently run it on a local server, but want to run it inside Snowflake for better scalability. What technology should they use, and where does the code execute?
**Resposta:** Use Snowpark with a Snowpark-optimized warehouse. The Snowpark DataFrame API translates Python operations to SQL. Code executes INSIDE the virtual warehouse (not on the client machine). For memory-intensive ML workloads, use Snowpark-optimized warehouses which provide more memory per node.

**Cenário:** A company wants to add sentiment analysis to their customer feedback table without exporting data to an external ML platform. Which Cortex function should they use?
**Resposta:** Use `AI_SENTIMENT()` — e.g., `SELECT AI_SENTIMENT(feedback_text) FROM customer_feedback`. This runs inside Snowflake, no data export needed. Do NOT confuse with AI_COMPLETE (which is for text generation/LLM inference) or AI_CLASSIFY (which is for text classification into categories).

**Cenário:** A business analyst wants to ask questions about their data in plain English and get SQL results back. They heard about Cortex Search and Cortex Analyst but aren't sure which to use. What's the difference?
**Resposta:** Cortex Analyst converts natural language to SQL queries — it's for asking questions about structured data (e.g., "What were total sales last quarter?"). Cortex Search performs semantic search over text data — it's for finding relevant documents or text passages. The analyst wants Cortex Analyst (natural language → SQL), not Cortex Search.

**Cenário:** A developer is using Snowflake Notebooks and notices the notebook runs on a warehouse called SYSTEM$STREAMLIT_NOTEBOOK_WH. Can they change this?
**Resposta:** Snowflake Notebooks run on dedicated notebook warehouses. While they use SYSTEM$STREAMLIT_NOTEBOOK_WH by default, you can configure the warehouse. Notebooks support both Python and SQL cells, and have access to Snowpark and ML libraries for data exploration and analysis.

---

---

## 1.11 CLONAGEM (Clone Zero-Copy)

- CREATE ... CLONE cria uma cópia apenas de metadados
- Sem armazenamento adicional até dados serem modificados
- Funciona em: bancos de dados, schemas, tabelas
- Clone herda dados no ponto no tempo da clonagem
- Clone NÃO herda histórico de Time Travel do original
- Mudanças no clone NÃO afetam o original (e vice-versa)


### Exemplos de Perguntas de Cenário — Cloning

**Cenário:** A team needs to create a copy of a production database for testing. They're concerned about storage costs since the database is 5TB. How much additional storage will the clone use initially?
**Resposta:** Zero additional storage initially. `CREATE DATABASE test_db CLONE prod_db` creates a zero-copy clone — it's metadata-only. Both the original and clone point to the same micro-partitions. You only pay for additional storage when data in the clone is modified (and only for the changed micro-partitions, not the entire table).

**Cenário:** After cloning a table, a developer checks Time Travel on the clone and expects to see the original table's history. They can't find it. Why?
**Resposta:** Clones do NOT inherit Time Travel history from the original. The clone starts with only the data as it existed at the point of cloning. Time Travel on the clone begins fresh from the moment of creation. This is a common exam trap — "inherits Time Travel" is always wrong for clones.

**Cenário:** A developer clones a schema containing 10 tables. They then INSERT new rows into 3 of the cloned tables. How much additional storage is used?
**Resposta:** Only the new/modified micro-partitions in those 3 tables consume additional storage. The other 7 unchanged tables still share micro-partitions with the original (zero extra storage). Even for the 3 modified tables, only the affected micro-partitions are new — unchanged partitions are still shared.

**Cenário:** Can you clone a view in Snowflake?
**Resposta:** You cannot directly clone individual views. However, when you clone a database or schema, the views within it are included in the clone. The cloned views will reference the cloned tables (within the cloned schema/database), not the original tables. Cloning works on: databases, schemas, and tables.

---

---

## 1.12 DADOS SEMI-ESTRUTURADOS

### Formatos suportados: JSON, Avro, ORC, Parquet, XML

### Tipo de dado VARIANT:
- Armazena dados semi-estruturados
- Pode conter qualquer tipo (objeto, array, escalar)
- Tamanho máximo: 16 MB por valor (comprimido)

### Funções Chave:
- **PARSE_JSON()** → converter string JSON para VARIANT
- **FLATTEN()** → expandir arrays/objetos em linhas
- **OBJECT_KEYS()** → obter todas as chaves de um objeto JSON
- **TYPEOF()** → obter o tipo de dado de um valor VARIANT
- **::tipo** notação → converter VARIANT para tipo específico (ex: col:nome::string)
- **Notação de ponto**: `coluna:chave.subchave` para navegar JSON

### Sub-columnarização:
- A camada de Cloud Services automaticamente analisa colunas VARIANT
- Extrai caminhos frequentemente acessados para armazenamento colunar otimizado
- Acontece automaticamente, sem ação do usuário necessária

**Armadilha do exame**: "Qual serviço sub-columnariza VARIANT?" → Camada de Cloud Services. SE VOCÊ VER "Compute" ou "Storage" fazendo sub-columnarização → ERRADO, Cloud Services analisa e otimiza colunas VARIANT.


### Exemplos de Perguntas de Cenário — Semi-structured Data

**Cenário:** A company receives JSON data from an API where each record contains a nested array of order items. They need to create one row per order item for analysis. Which function should they use?
**Resposta:** Use `FLATTEN()` to expand the nested array into individual rows. Example: `SELECT o.value:product_name::string AS product, o.value:quantity::number AS qty FROM orders, LATERAL FLATTEN(input => order_data:items) o`. FLATTEN explodes arrays/objects into rows — it's the opposite of aggregation.

**Cenário:** A data engineer loads JSON data into a VARIANT column. Queries on this column are slow. They haven't done anything special — does Snowflake optimize VARIANT data automatically?
**Resposta:** Yes. The Cloud Services layer automatically performs sub-columnarization on VARIANT columns. It analyzes access patterns and extracts frequently-queried paths into optimized internal columnar storage. This happens automatically with no user action required. The key exam point: sub-columnarization is done by Cloud Services (not Compute, not Storage).

**Cenário:** A developer needs to access a deeply nested JSON field: `{"customer": {"address": {"city": "NYC"}}}`. The data is stored in a VARIANT column called `data`. How do they extract the city?
**Resposta:** Use dot notation with casting: `SELECT data:customer.address.city::string AS city FROM my_table`. The colon (`:`) accesses the first level, dots (`.`) navigate deeper levels, and `::string` casts the VARIANT value to a string type. You can also use bracket notation: `data['customer']['address']['city']::string`.

**Cenário:** A team needs to load Parquet files into Snowflake. Should they convert Parquet to CSV first, or can Snowflake handle Parquet natively?
**Resposta:** Snowflake handles Parquet natively — no conversion needed. Snowflake supports JSON, Avro, ORC, Parquet, and XML as semi-structured formats. You can load Parquet directly using COPY INTO with `TYPE = PARQUET` in the file format. Snowflake can also auto-detect the schema from Parquet files using `INFER_SCHEMA()`.

---

---

## REPASO RÁPIDO (padrões mais testados)

1. Três camadas: Cloud Services (cérebro), Compute (músculo), Storage (memória)
2. Cloud Services cuida de: auth, otimizador, transações, metadados
3. Warehouses cobrados por segundo, mínimo 60s
4. Cada tamanho acima = 2x créditos
5. Escalar VERTICALMENTE = tamanho maior (consultas complexas). Escalar HORIZONTALMENTE = mais clusters (concorrência)
6. Multi-cluster = apenas Enterprise+
7. Escalonamento Standard = inicia clusters rápido. Economy = economiza créditos.
8. Micro-partições: 50-500 MB, colunares, imutáveis, automáticas
9. Pruning usa metadados mín/máx. Funções em colunas impedem pruning.
10. Tabela temporária = apenas sessão, eliminada quando a sessão termina (NÃO ao desconectar)
11. Transiente = sem Fail-safe, persiste entre sessões
12. Permanente = Time Travel + Fail-safe
13. Não é possível converter entre tipos de tabela (deve recriar)
14. Clone = zero-copy, sem custo de armazenamento até modificação
15. VARIANT = container semi-estruturado
16. PARSE_JSON + FLATTEN = funções mais testadas
17. Snowpark = avaliação preguiçosa, executa DENTRO do warehouse
18. Tabelas dinâmicas = refresh automático, target lag
19. Iceberg = formato aberto, SEU armazenamento, interoperável
20. Todas as edições têm: clustering, Snowpark, UDFs, tabelas dinâmicas, políticas de rede
21. Enterprise+: multi-cluster, mascaramento, acesso a linhas, otim. busca, acel. consultas, TT 90 dias
22. Business Critical+: Tri-Secret, PrivateLink, HIPAA
23. VPS: tudo dedicado, totalmente isolado

---

## PARES CONFUSOS — Arquitetura

| Perguntam sobre... | A resposta é... | NÃO é... |
|---|---|---|
| Otimização de consultas | Camada Cloud Services | Camada Compute |
| Conformidade ACID | Camada Cloud Services | Camada Storage |
| Onde dados vivem fisicamente | Camada Storage | Cloud Services |
| Onde consultas executam | Camada Compute | Cloud Services |
| Cobrança de créditos | Por segundo, mín 60s | Por minuto |
| Tamanho de micro-partição | 50-500 MB descomprimido | 50-500 MB comprimido |
| Micro-partições gerenciadas por | Snowflake (automático) | Usuários (manual) |
| Clustering disponível em | TODAS as edições | Enterprise+ |
| Multi-cluster disponível em | Enterprise+ | TODAS as edições |
| Sessão de tabela temp termina | Tabela é ELIMINADA | Tabela persiste |
| Fail-safe de tabela transiente | NENHUM | 7 dias |
| Snowpark executa código | Dentro do warehouse | Na sua máquina local |
| Frescura de tabela dinâmica | Target lag (você define) | Sempre tempo real |
| Conta abrange provedores | NÃO (um provedor por conta) | Sim |

---

## RESUMO AMIGÁVEL — Domínio 1

### MNEMÔNICOS PARA FIXAR

**Camadas = C-M-M** (Cérebro, Músculo, Memória)
- Cérebro = Cloud Services (pensa, otimiza, protege)
- Músculo = Compute (faz o trabalho pesado)
- Memória = Storage (lembra os dados)

**Tamanhos de warehouse dobram = "Dobra Sempre"**
- XS=1, S=2, M=4, L=8, XL=16... cada passo ACIMA = 2x créditos

**Tipos de tabela = "PeTT-y EDI"** (Permanente, Transiente, Temporária, Externa, Dinâmica, Iceberg)
- **Pe**rmanente = proteção total (TT + Fail-safe)
- **T**ransiente = sem rede de segurança (sem Fail-safe)
- **T**emporária = sem rede de segurança E apenas sessão

**Regra de edição = "Segurança SOBE, Recursos SOBEM"**
- Standard = básico (funciona bem para maioria)
- Enterprise = controle quem vê o quê (mascaramento, acesso a linhas) + desempenho
- BC = criptografia + privacidade (Tri-Secret, PrivateLink, HIPAA)
- VPS = isolamento total

**Truque de memória para escalonamento = "VERTICAL para Potência, HORIZONTAL para Pessoas"**
- VERTICAL = mais potência para uma consulta grande
- HORIZONTAL = mais espaço para muitas pessoas consultando

---

### TRAMPAS PRINCIPAIS — Domínio 1

1. **"Clustering requer Enterprise"** → ERRADO. TODAS as edições.
2. **"Snowpark requer Enterprise"** → ERRADO. TODAS as edições.
3. **"Micro-partições são 50-500 MB comprimidas"** → ERRADO. É tamanho DESCOMPRIMIDO.
4. **"Usuários definem micro-partições"** → ERRADO. Automático, sempre.
5. **"Suspensão do warehouse mantém o cache"** → ERRADO. Cache SSD é PERDIDO ao suspender.
6. **"Tabelas temporárias não têm Time Travel"** → ERRADO. Até 1 dia.
7. **"Você pode ALTER uma tabela transiente para permanente"** → ERRADO. Deve recriar.
8. **"Snowpark executa na sua máquina local"** → ERRADO. Executa dentro do warehouse.
9. **"Tabelas dinâmicas precisam de refresh manual"** → ERRADO. Automático baseado no target lag.
10. **"Uma conta Snowflake abrange AWS + Azure"** → ERRADO. Uma conta = um provedor de nuvem.

---

### ATALHOS DE PADRÃO — "Se você ver ___, a resposta é ___"

| Se a questão menciona... | A resposta quase sempre é... |
|---|---|
| "otimização de consultas", "parsing de consultas" | Camada Cloud Services |
| "gerenciamento de transações", "ACID" | Camada Cloud Services |
| "derramamento para disco local/remoto" | Aumentar TAMANHO do warehouse |
| "consultas em fila", "concorrência" | Multi-cluster / escalar HORIZONTALMENTE |
| "política de escalonamento Economy" | Economiza créditos, espera 6 min |
| "política de escalonamento Standard" | Desempenho, inicia imediatamente |
| "MIN = MAX clusters" | Modo Maximizado |
| "sem Fail-safe mas persiste" | Tabela transiente |
| "sessão termina = perdido" | Tabela temporária |
| "formato aberto, armazenamento externo" | Tabela Iceberg |
| "target lag", "pipeline de refresh automático" | Tabela dinâmica |
| "avaliação preguiçosa" | Snowpark |
| "API DataFrame" | Snowpark |
| "AI_COMPLETE, AI_SENTIMENT" | Funções Cortex AI |
| "linguagem natural para SQL" | Cortex Analyst |
| "busca semântica" | Cortex Search |
| "Python + SQL interativo" | Snowflake Notebooks |
| "app de dados dentro do Snowflake" | Streamlit no Snowflake |
| "controle de versão no Snowflake" | Integração Git (CREATE GIT REPOSITORY) |

---

## DICAS PARA O DIA DO EXAME — Domínio 1 (31% = ~31 questões)

**Antes de estudar este domínio:**
- Faça 10-15 flashcards APENAS para os conceitos que você confunde (camadas, tipos de tabela, edições)
- Teste "Explique para uma criança de 5 anos": se não consegue explicar Cloud Services vs Compute em uma frase, estude mais

**Durante o exame — Questões do Domínio 1:**
- Leia a ÚLTIMA frase primeiro (a pergunta real) — depois leia o cenário
- Elimine 2 respostas obviamente erradas imediatamente
- Se mencionam uma CAMADA → pergunte-se: pensar/decidir = Cloud Services, fazer trabalho = Compute, armazenar = Storage
- Se mencionam ESCALONAMENTO → "VERTICAL para Potência, HORIZONTAL para Pessoas"
- Se mencionam um TIPO DE TABELA → verifique: persiste? tem Fail-safe?
- Se mencionam uma EDIÇÃO → pense "Segurança SOBE, Recursos SOBEM"

---

## UMA LINHA POR TÓPICO — Domínio 1

| Tópico | Resumo em uma linha |
|---|---|
| Arquitetura 3 camadas | Cloud Services (cérebro), Compute (músculo), Storage (memória) — totalmente independentes |
| Cloud Services | Pensa: otimização de consultas, segurança, metadados, gerenciamento de transações |
| Compute | Faz: executa consultas em warehouses, cada warehouse = cluster independente de nós |
| Storage | Lembra: todos os dados em micro-partições, colunar, comprimido, imutável |
| Edições | Standard→Enterprise (mascaramento, multi-cluster)→BC (Tri-Secret, PrivateLink)→VPS (isolamento total) |
| Virtual Warehouses | Tamanho camiseta (XS=1 crédito/hr, dobra a cada tamanho), auto-suspend, auto-resume |
| Multi-cluster | Escalar HORIZONTALMENTE para concorrência, Enterprise+, política Standard ou Economy |
| Micro-partições | 50-500MB descomprimido, colunar, imutável, automático — você nunca gerencia |
| Tabelas permanentes | Proteção total: Time Travel (1-90 dias) + Fail-safe (7 dias) |
| Tabelas transientes | Sem Fail-safe, máx 1 dia TT, persiste entre sessões |
| Tabelas temporárias | Sem Fail-safe, máx 1 dia TT, perdida quando sessão termina |
| Tabelas externas | Somente leitura, dados no armazenamento de nuvem do cliente, metadados no Snowflake |
| Tabelas dinâmicas | Pipeline declarativo: SQL + target lag = resultados auto-atualizados |
| Tabelas Iceberg | Formato Apache Iceberg aberto, dados no armazenamento do cliente, interoperável |
| Tabelas híbridas | Baixa latência chave-valor + ACID, para cargas operacionais |
| Views | Padrão (expõe SQL), Segura (oculta SQL, requerida para sharing), Materializada (pré-computada, Enterprise+) |
| Snowpark | API DataFrame (Python/Java/Scala), avaliação preguiçosa, executa dentro do warehouse |
| Cortex AI | AI_COMPLETE, AI_SENTIMENT, AI_EXTRACT — funções LLM embutidas |
| Clonagem | Zero-copy, instantâneo, independente após criação, sem histórico TT da fonte |

---

## FLASHCARDS — Domínio 1

**P:** Quais são as 3 camadas do Snowflake e o que cada uma faz?
**R:** Cloud Services (cérebro — auth, otimizador, metadados, transações), Compute (músculo — virtual warehouses executam consultas), Storage (memória — armazenamento centralizado na nuvem, micro-partições colunares). Todas escalam independentemente.

**P:** Qual camada cuida da otimização de consultas?
**R:** Camada Cloud Services — NÃO Compute. Armadilha comum do exame.

**P:** Uma conta Snowflake pode abranger múltiplos provedores de nuvem?
**R:** Não. Uma conta = um provedor de nuvem + uma região. Use Organizations para vincular contas entre provedores/regiões.

**P:** O que a Enterprise Edition adiciona sobre Standard?
**R:** Warehouses multi-cluster, Time Travel até 90 dias, segurança a nível de coluna, políticas de acesso a linhas, vistas materializadas, otimização de busca, aceleração de consultas, mascaramento dinâmico, rekeying periódico.

**P:** Qual é o modelo de cobrança de warehouses?
**R:** Cobrança por segundo com mínimo de 60 segundos. Créditos dependem do tamanho (XS=1, S=2, M=4, L=8... cada tamanho dobra).

**P:** Escalar VERTICALMENTE vs HORIZONTALMENTE — quando usar cada?
**R:** VERTICALMENTE (warehouse maior) = consultas complexas, spilling. HORIZONTALMENTE (multi-cluster) = mais usuários concorrentes, fila.

**P:** O que são micro-partições?
**R:** Colunares, comprimidas, imutáveis, 50-500MB. Criadas automaticamente — você NÃO pode controlar seu tamanho ou número.

**P:** Transiente vs Temporária — qual é a diferença?
**R:** Ambas: 0-1 dia Time Travel, SEM Fail-safe. Transiente persiste entre sessões. Temporária existe apenas na sessão atual e é invisível para outras sessões.

**P:** O que é uma Tabela Dinâmica?
**R:** Uma tabela que automaticamente se atualiza baseada em uma consulta e um target lag. Pipeline declarativo — sem tasks/streams necessários.

**P:** O que é Snowpark?
**R:** Framework para escrever pipelines em Python, Java ou Scala usando API DataFrame. Executa na CAMADA DE COMPUTE (não Cloud Services).

**P:** O que o tipo VARIANT faz?
**R:** Armazena dados semi-estruturados (JSON, Avro, Parquet, XML). Máximo 16MB por valor. Acesse campos aninhados com notação `:` e `[]`.

**P:** O que FLATTEN faz?
**R:** Converte VARIANT/ARRAY/OBJECT em linhas. Geralmente pareado com LATERAL na cláusula FROM.

---

## EXPLIQUE COMO SE EU TIVESSE 5 ANOS — Domínio 1

**Camada Cloud Services**: O chefe que lê sua pergunta, descobre o melhor plano e diz aos trabalhadores o que fazer.

**Camada Compute**: Os trabalhadores (virtual warehouses) que realmente fazem os cálculos e o trabalho pesado.

**Camada Storage**: O gigante arquivo onde todos os seus dados são guardados em pequenas pastas organizadas (micro-partições).

**Micro-partições**: Snowflake automaticamente corta seus dados em pequenas caixas organizadas (50-500MB cada) para encontrar coisas mais rápido.

**Pruning**: Quando você pede dados, Snowflake verifica o rótulo de cada caixa (valores mín/máx) e pula caixas que definitivamente não têm o que você precisa.

**Virtual Warehouse**: Um grupo de computadores que faz seu trabalho. Você pode ter vários warehouses, e eles não atrapalham um ao outro.

**Edições**: Como planos de celular — Standard é básico, Enterprise adiciona recursos (multi-cluster, 90 dias Time Travel), Business Critical adiciona segurança (HIPAA, criptografia), VPS é seu Snowflake privado.

**Tabela transiente**: Uma tabela que fica por aí mas não guarda backups de longo prazo. Como escrever num quadro branco que ninguém fotografa.

**Tabela temporária**: Uma tabela que desaparece quando você fecha sua sessão. Como um castelo de areia — some quando você sai da praia.

**Tabela dinâmica**: Uma tabela que se atualiza automaticamente baseada em uma receita (consulta SQL) que você escreveu. Como uma planilha que se preenche sozinha.

**Snowpark**: Escrever código em Python/Java/Scala que executa dentro dos trabalhadores do Snowflake, em vez de escrever SQL.

**VARIANT**: Uma caixa especial que pode guardar dados bagunçados (JSON, objetos aninhados). Snowflake entende o que tem dentro.

**Clone zero-copy**: Fazer uma cópia de uma tabela instantaneamente compartilhando as mesmas caixas — nenhum dado realmente se move até alguém mudar algo.

# Domínio 2: Arquitetura de Dados

> **Cobertura do Programa ARA-C01:** Modelagem de Dados, Hierarquia de Objetos, Recuperação de Dados

---

## 2.1 MODELAGEM DE DADOS

**Data Vault**

- Três tipos de entidade principais: **Hubs** (chaves de negócio), **Links** (relacionamentos), **Satellites** (atributos descritivos + histórico)
- Projetado para auditabilidade, flexibilidade e carregamento paralelo
- Hash keys permitem carregamento paralelo, apenas inserção
- Melhor para: data warehouses corporativos com muitos sistemas fonte, esquemas em evolução, requisitos de auditoria
- Desvantagem: queries mais complexas, requer modeladores experientes

**Star Schema**

- **Tabela fato** central (medidas/métricas) cercada por **tabelas dimensão** (contexto descritivo)
- Dimensões desnormalizadas = leituras rápidas, joins simples
- Melhor para: BI/analytics, dashboards, padrões de query conhecidos
- Desvantagem: ETL é mais difícil (precisa manter dims desnormalizadas), menos flexível a mudanças de esquema

**Snowflake Schema**

- Como star schema mas as dimensões são normalizadas (divididas em sub-dimensões)
- Ex: `product_dim` → `category_dim` → `department_dim`
- Melhor para: economizar armazenamento, reduzir redundância em dimensões grandes
- Desvantagem: mais joins = queries mais lentas, mais complexo para analistas

**Quando Usar Cada Um**

| Modelo | Use Quando... |
|---|---|
| Data Vault | Muitas fontes, precisa de trilha de auditoria, esquema muda frequentemente |
| Star | Esquema estável, foco em BI, performance de query é prioridade |
| Snowflake | Dimensões grandes com alta redundância, armazenamento importa |
| Flat/OBT | Analytics simples, fonte única, joins mínimos necessários |

### Por Que Isso Importa
Uma empresa de mídia ingere dados de mais de 20 plataformas de anúncios. Esquemas mudam mensalmente. Data Vault absorve as mudanças nos satellites sem quebrar hubs/links. A camada de BI usa star schemas construídos por cima.

### Melhores Práticas
- Use Data Vault para a camada raw/integração, star schema para a camada de apresentação
- Aproveite a elasticidade de computação do Snowflake — economias de armazenamento do snowflake schema raramente justificam a complexidade das queries
- Documente chaves de negócio e granularidade para cada tabela fato

**Armadilha do exame:** SE VOCÊ VER "star schema é melhor para trilhas de auditoria" → ERRADO porque Data Vault é projetado para auditabilidade.

**Armadilha do exame:** SE VOCÊ VER "snowflake schema é a recomendação padrão para o produto Snowflake" → ERRADO porque a nomenclatura é coincidência. Star schema é mais comum para analytics.

**Armadilha do exame:** SE VOCÊ VER "Data Vault substitui modelagem dimensional" → ERRADO porque Data Vault é para a camada de integração; você ainda constrói star schemas por cima para consumo.

### Perguntas Frequentes (FAQ)
**P: Posso usar star schema diretamente em dados brutos?**
R: Pode, mas é frágil. Mudanças nos sistemas fonte quebram o modelo. Melhor fazer staging/integração primeiro.

**P: O Snowflake impõe algum padrão de modelagem?**
R: Não. O Snowflake é agnóstico a esquema. Você escolhe o modelo que atende suas necessidades.


### Exemplos de Perguntas de Cenário — Data Modeling

**Cenário:** A media conglomerate acquires 5 companies, each with different source systems (SAP, Salesforce, custom APIs, flat files). Schemas change frequently due to ongoing integrations. The CFO needs a unified financial reporting layer for quarterly earnings. What data modeling approach should the architect recommend?
**Resposta:** Use Data Vault for the integration/raw layer. Hubs capture core business entities (customer, account, transaction) via hash keys, Links capture relationships, and Satellites absorb schema changes without breaking existing structures. Each acquired company's data feeds into the same Hub/Link structure with separate Satellites tracking the source history. On top of the Data Vault layer, build star schemas for the presentation/consumption layer — the CFO's reporting team queries denormalized fact and dimension tables optimized for BI dashboards. This two-layer approach absorbs ongoing schema changes in the Data Vault while delivering stable, fast analytics in the star layer.

**Cenário:** A startup with a single Postgres source and 10 analysts wants fast dashboards. They have a small team with no Data Vault experience. The data schema is stable and changes rarely. What modeling approach fits best?
**Resposta:** Star schema directly on the curated/presentation layer. With a single stable source, the complexity of Data Vault is unnecessary overhead. Build fact tables for core business events (orders, sessions, payments) surrounded by denormalized dimension tables (customers, products, dates). Star schema provides the simplest joins for BI tools like Tableau or Looker. Since Snowflake's elastic compute handles joins efficiently, the query performance benefits of denormalized dimensions outweigh the minimal storage savings of a normalized snowflake schema.

---

---

## 2.2 HIERARQUIA DE OBJETOS

**Estrutura de Cima para Baixo**

```
Organization
  └── Account
        └── Database
              └── Schema
                    ├── Tables (permanent, transient, temporary, external, dynamic, Iceberg)
                    ├── Views (standard, secure, materialized)
                    ├── Stages (internal, external)
                    ├── File Formats
                    ├── Sequences
                    ├── Streams
                    ├── Tasks
                    ├── Pipes
                    ├── UDFs / UDTFs
                    ├── Stored Procedures
                    ├── Tags
                    └── Policies (masking, RAP, aggregation, projection)
```

**Pontos-Chave**

- Tudo reside dentro de um namespace `DATABASE.SCHEMA`
- Alguns objetos são no nível de conta: warehouses, users, roles, resource monitors, network policies, integrations, shares
- Stages podem ser no nível de tabela (`@%my_table`), nível de schema (`@my_stage`), ou nível de usuário (`@~`)
- Managed access schemas: apenas o dono do schema (ou MANAGE GRANTS) pode conceder privilégios — impede que donos de objetos concedam acesso independentemente

### Por Que Isso Importa
Uma equipe de plataforma de dados precisa impedir que donos individuais de tabelas concedam SELECT para roles aleatórias. Managed access schemas centralizam o controle de concessões.

### Melhores Práticas
- Use managed access schemas em produção
- Organize schemas por domínio ou camada de dados (raw, curated, presentation)
- Nomeie objetos consistentemente: `<domínio>_<entidade>_<sufixo>` (ex: `sales_orders_fact`)
- Mantenha objetos no nível de conta (warehouses, roles) bem documentados

**Armadilha do exame:** SE VOCÊ VER "warehouses pertencem a um banco de dados" → ERRADO porque warehouses são objetos no nível de conta.

**Armadilha do exame:** SE VOCÊ VER "managed access schemas impedem o dono do schema de conceder" → ERRADO porque o dono do schema PODE ainda conceder em managed access schemas — a restrição é sobre donos de objetos diferentes do dono do schema.

**Armadilha do exame:** SE VOCÊ VER "network policies são objetos no nível de banco de dados" → ERRADO porque são no nível de conta.

### Perguntas Frequentes (FAQ)
**P: Qual é a diferença entre `@~` e `@%table`?**
R: `@~` é o user stage (um por usuário). `@%table` é o table stage (um por tabela). Ambos são internos, mas com escopo diferente.

**P: Posso ter um schema sem um banco de dados?**
R: Não. Schemas sempre residem dentro de um banco de dados.


### Exemplos de Perguntas de Cenário — Object Hierarchy

**Cenário:** A production data platform has 200 tables owned by different teams (marketing, finance, engineering). The security team discovers that individual table owners have been granting SELECT on their tables to unapproved roles, bypassing the central governance model. How should the architect prevent this?
**Resposta:** Convert production schemas to managed access schemas using `ALTER SCHEMA ... ENABLE MANAGED ACCESS`. In a managed access schema, only the schema owner or roles with the MANAGE GRANTS privilege can issue GRANT statements on objects within the schema. Individual table owners lose the ability to grant access independently. This centralizes privilege management without requiring any changes to the object ownership model or existing data pipelines.

**Cenário:** An architect is designing the schema layout for a new analytics platform. They need separate layers for raw ingestion, cleaned/curated data, and presentation-ready datasets. Some objects (warehouses, resource monitors, network policies) need to be shared across all layers. How should this be organized?
**Resposta:** Create a single database (or one per domain) with three schemas: `RAW`, `CURATED`, and `PRESENTATION`. Each schema represents a data layer with its own access controls. Warehouses, resource monitors, network policies, users, and roles are account-level objects — they exist outside the database hierarchy and are shared across all schemas automatically. Use managed access schemas for `CURATED` and `PRESENTATION` to enforce centralized grant control. Name objects consistently with domain prefixes (e.g., `sales_orders_fact`) for discoverability.

---

---

## 2.3 TIPOS DE TABELA E VIEWS

**Tipos de Tabela**

| Tipo | Time Travel | Fail-safe | Persiste Após Sessão | Clonável |
|---|---|---|---|---|
| **Permanent** | 0-90 dias (Enterprise) | 7 dias | Sim | Sim |
| **Transient** | 0-1 dia | Nenhum | Sim | Sim |
| **Temporary** | 0-1 dia | Nenhum | Não (escopo de sessão) | Sim (dentro da sessão) |
| **External** | Não | Não | Sim (apenas metadados) | Não |
| **Dynamic** | 0-90 dias | 7 dias | Sim | Não |

- **Transient:** use para tabelas de staging/ETL onde você não precisa de Fail-safe (economiza custo de armazenamento)
- **Temporary:** use para resultados intermediários com escopo de sessão
- **External:** camada de metadados sobre arquivos em armazenamento externo — somente leitura
- **Dynamic:** atualizada automaticamente com base em uma query e target lag

**Iceberg Tables**

- **Managed (gerenciada pelo Snowflake):** Snowflake gerencia os metadados Iceberg + arquivos de dados
  - Suporte completo a DML (INSERT, UPDATE, DELETE, MERGE)
  - Snowflake cuida da compactação, gerenciamento de snapshots
  - Armazenada em armazenamento gerenciado pelo Snowflake ou external volume do cliente
- **Unmanaged (gerenciada externamente / catalog-linked):** catálogo externo (AWS Glue, Polaris) gerencia metadados
  - Somente leitura a partir do Snowflake (ou escrita limitada dependendo do catálogo)
  - Snowflake lê metadados Iceberg para consultar dados
  - Use para acesso multi-engine (Spark + Snowflake nos mesmos dados)

**Hybrid Tables**

- Projetadas para workloads transacionais (OLTP) dentro do Snowflake
- Suportam buscas rápidas por linha única, índices e integridade referencial (PRIMARY KEY, FOREIGN KEY, UNIQUE aplicadas)
- Armazenadas em formato orientado a linhas para leituras pontuais de baixa latência
- Caso de uso: dados operacionais que também precisam ser unidos com dados analíticos

**Tipos de View**

| Tipo | Materializada? | Segura? | Notas |
|---|---|---|---|
| Standard view | Não | Não | Apenas uma query salva |
| Secure view | Não | Sim | Esconde definição, barreira de otimizador |
| Materialized view | Sim | Não | Pré-computada, mantida automaticamente |
| Secure materialized view | Sim | Sim | Ambos os benefícios |

- **Secure views:** definição da query escondida dos consumidores, otimizador não pode empurrar predicados além da barreira da view
- **Materialized views:** melhor para agregações caras em dados grandes e pouco alterados
- Materialized views têm limitações: sem joins, sem UDFs, sem subqueries na definição

### Por Que Isso Importa
Um marketplace de dados compartilha dados via secure views — consumidores não podem ver a lógica da query subjacente ou contornar segurança no nível de linha.

### Melhores Práticas
- Use tabelas transient para dados de staging (evite custos desnecessários de Fail-safe)
- Use dynamic tables em vez de pipelines complexos de task/stream onde possível
- Use secure views para todos os objetos compartilhados
- Considere Iceberg managed tables quando precisar de interoperabilidade em formato aberto

**Armadilha do exame:** SE VOCÊ VER "tabelas transient têm 7 dias de Fail-safe" → ERRADO porque tabelas transient têm zero Fail-safe.

**Armadilha do exame:** SE VOCÊ VER "tabelas temporary persistem após o término da sessão" → ERRADO porque são descartadas quando a sessão termina.

**Armadilha do exame:** SE VOCÊ VER "materialized views suportam joins" → ERRADO porque definições de MV não podem incluir joins.

**Armadilha do exame:** SE VOCÊ VER "hybrid tables usam armazenamento colunar" → ERRADO porque usam armazenamento orientado a linhas para buscas pontuais rápidas.

**Armadilha do exame:** SE VOCÊ VER "tabelas externas suportam DML" → ERRADO porque tabelas externas são somente leitura.

### Perguntas Frequentes (FAQ)
**P: Posso converter uma tabela permanent para transient?**
R: Não diretamente. Você precisa criar uma nova tabela transient e copiar os dados (ou usar CTAS).

**P: Secure views têm custo de performance?**
R: Sim. A barreira do otimizador impede algumas otimizações, então secure views podem ser mais lentas que standard views.

**P: Quando eu usaria uma managed Iceberg table vs uma tabela Snowflake regular?**
R: Quando você precisa que os dados estejam em formato aberto Iceberg para acesso multi-engine enquanto ainda tem DML completo do Snowflake.


### Exemplos de Perguntas de Cenário — Table Types & Views

**Cenário:** A data platform team runs multi-step ETL pipelines that produce intermediate staging tables. These tables are recreated every run and don't need historical recovery. Storage costs are a concern because the staging data is 50 TB and growing. What table types should the architect use?
**Resposta:** Use transient tables for all staging/intermediate tables. Transient tables have zero Fail-safe storage (saving 7 days worth of historical data storage per table) and a maximum of 1-day Time Travel. Since these tables are recreated every run, the 7-day Fail-safe of permanent tables provides no value but adds significant storage cost at 50 TB scale. For truly session-scoped scratch work within a single ETL step, temporary tables are even lighter (dropped when the session ends).

**Cenário:** A company runs both Snowflake and Apache Spark. The data science team uses Spark for ML training on feature tables, while the analytics team queries the same tables from Snowflake. Currently, data is duplicated — a Snowflake copy and a Parquet copy in S3. How should the architect eliminate the duplication?
**Resposta:** Migrate the feature tables to managed Iceberg tables with an external volume pointing to S3. Snowflake manages the table lifecycle (writes, compaction, snapshots) and produces Iceberg-formatted data files and metadata in S3. Spark reads the same Iceberg metadata and data files directly — no duplication. Snowflake retains full DML (INSERT, UPDATE, DELETE, MERGE) support, Time Travel, and clustering. The data science team accesses the same data from Spark without any data movement or copy.

**Cenário:** A data marketplace needs to share pre-aggregated sales metrics with external consumers. The underlying query logic is proprietary. Consumers should not see the SQL definition or be able to bypass row-level security through optimizer tricks. What view type should the architect use?
**Resposta:** Use secure views (or secure materialized views for expensive aggregations). Secure views hide the view definition from consumers and impose an optimizer fence that prevents predicate pushdown past the view boundary — this stops consumers from inferring hidden data through clever filtering. For the data marketplace use case, all shared objects should use secure views as a baseline. Note that secure views have a minor performance cost due to the optimizer fence, but this is an acceptable trade-off for data protection in a sharing context.

---

---

## 2.4 RECUPERAÇÃO DE DADOS

**Time Travel**

- Consulte ou restaure dados como existiam em qualquer ponto dentro do período de retenção
- Métodos: `AT` / `BEFORE` com `TIMESTAMP`, `OFFSET`, ou `STATEMENT` (query ID)
- Retenção: 0-1 dia (Standard), 0-90 dias (Enterprise+)
- Funciona em tabelas, schemas e bancos de dados
- Custa armazenamento para dados alterados/deletados

**Fail-safe**

- Período de 7 dias APÓS o Time Travel expirar
- NÃO acessível pelo usuário — apenas o Suporte Snowflake pode recuperar dados
- Apenas para tabelas permanent (não transient, temporary ou external)
- Existe como último recurso para cenários catastróficos

**UNDROP**

- Restaura o objeto mais recentemente descartado: `UNDROP TABLE`, `UNDROP SCHEMA`, `UNDROP DATABASE`
- Usa dados de Time Travel internamente
- Se você descarta e recria um objeto com mesmo nome, o antigo ainda pode ser restaurado (usa versionamento interno)

**Zero-Copy Cloning para Backup**

- `CREATE TABLE backup_table CLONE source_table`
- Sem armazenamento adicional até os dados divergirem
- Clones herdam configurações de Time Travel da origem
- Suporta clonagem de bancos de dados e schemas (clone recursivo de todos os filhos)
- Clones são independentes — mudanças no clone não afetam a origem

**Replicação para DR**

- Replicação de banco de dados: cópia assíncrona do banco de dados para outra conta/região
- Replicação de conta: replica usuários, roles, warehouses, policies
- Failover groups: conjunto de objetos replicados que podem fazer failover juntos
- RPO depende da frequência de replicação; RTO é o tempo para promover o secundário

### Por Que Isso Importa
Um analista acidentalmente executa `DELETE FROM production_table`. Com Time Travel de 90 dias, a equipe de dados restaura a tabela para 5 minutos antes do delete. Sem fitas de backup, sem downtime.

### Melhores Práticas
- Defina Time Travel de 90 dias em tabelas críticas de produção (Enterprise necessário)
- Use tabelas transient para staging para evitar custos de armazenamento do Fail-safe
- Clone produção para dev/teste em vez de copiar dados
- Configure replicação para bancos de dados de missão crítica em uma região secundária
- Teste seus procedimentos de recuperação regularmente

**Armadilha do exame:** SE VOCÊ VER "Dados do Fail-safe podem ser recuperados por usuários via SQL" → ERRADO porque apenas o Suporte Snowflake pode recuperar dados do Fail-safe.

**Armadilha do exame:** SE VOCÊ VER "Retenção de Time Travel pode ser definida para 90 dias na edição Standard" → ERRADO porque o máximo da edição Standard é 1 dia.

**Armadilha do exame:** SE VOCÊ VER "clonar uma tabela dobra o armazenamento imediatamente" → ERRADO porque clonagem é zero-copy; armazenamento só cresce conforme dados divergem.

**Armadilha do exame:** SE VOCÊ VER "UNDROP funciona em tabelas transient após Fail-safe" → ERRADO porque tabelas transient não têm Fail-safe, e UNDROP só funciona durante o período de Time Travel.

### Perguntas Frequentes (FAQ)
**P: Se eu defino Time Travel para 0, ainda posso fazer UNDROP?**
R: Não. UNDROP depende de dados de Time Travel. Com retenção 0, os dados são perdidos imediatamente.

**P: A clonagem copia grants?**
R: Ao clonar bancos de dados/schemas, grants em objetos filhos são copiados. Clones no nível de tabela não copiam grants por padrão (a menos que você use `COPY GRANTS`).

**P: Posso replicar para um provedor de nuvem diferente?**
R: Sim. Replicação cross-cloud é suportada (ex: AWS para Azure), mas ambas as contas devem estar na mesma Organization.


### Exemplos de Perguntas de Cenário — Data Recovery

**Cenário:** A junior engineer accidentally runs `TRUNCATE TABLE customers` on the production database containing 500M rows. The team discovers the mistake 3 hours later. The account is on Enterprise edition with the default 1-day Time Travel retention. How should the architect recover the data?
**Resposta:** Use Time Travel to restore the data. Since only 3 hours have passed and the table has at least 1-day Time Travel, the data is fully recoverable. Option 1: `CREATE TABLE customers_restored CLONE customers BEFORE(STATEMENT => '<truncate_query_id>')` to create a point-in-time clone, then swap the tables. Option 2: `INSERT INTO customers SELECT * FROM customers BEFORE(OFFSET => -10800)` to repopulate from the 3-hour-ago snapshot. Going forward, the architect should set `DATA_RETENTION_TIME_IN_DAYS = 90` on all critical production tables (Enterprise edition supports up to 90 days) and set `MIN_DATA_RETENTION_TIME_IN_DAYS` at the account level to prevent anyone from reducing it.

**Cenário:** A data platform team needs to provide fresh copies of the 200 TB production database to 5 development teams daily for testing. Full data copies would cost 1 PB of storage. How should the architect handle this efficiently?
**Resposta:** Use zero-copy cloning: `CREATE DATABASE dev_team_1 CLONE production`. Each clone initially shares all underlying micro-partitions with production — zero additional storage. Storage only grows as dev teams make changes to their cloned data. Each morning, drop the previous day's clones and create fresh ones. Clones inherit Time Travel settings from the source and are fully independent — dev team changes never affect production. This provides 5 teams with full production data at near-zero storage cost.

---

---

## 2.5 REPLICAÇÃO E FAILOVER

**Replicação de Banco de Dados**

- Replica um banco de dados da conta primária para uma ou mais contas secundárias
- Secundário é somente leitura até ser promovido (ou até failover)
- Replicação é assíncrona — atualidade dos dados depende do agendamento de refresh
- Replicação inicial copia todos os dados; subsequentes são incrementais (apenas mudanças)

**Replicação de Conta**

- Replica objetos no nível de conta: usuários, roles, grants, warehouses, network policies, parâmetros
- Essencial para DR verdadeiro — replicação de banco de dados sozinha não cobre controle de acesso
- Combinada com replicação de banco de dados em failover groups

**Failover Groups**

- Coleção nomeada de objetos que podem fazer failover como uma unidade
- Tipos de objetos: databases, shares, users, roles, warehouses, integrations, network policies
- Promoção `PRIMARY` → `SECONDARY` via `ALTER FAILOVER GROUP ... PRIMARY`
- Apenas um primário por vez por failover group

**Cross-Region / Cross-Cloud**

- Replicação funciona entre regiões E entre provedores de nuvem
- Ambas as contas devem estar na mesma Snowflake Organization
- Considere regulamentações de residência de dados ao replicar entre regiões
- Custos de replicação: transferência de dados + computação para refresh

**Client Redirect**

- URLs de conexão que redirecionam automaticamente para o primário ativo
- Minimiza mudanças no lado do cliente durante failover
- Usa objetos `CONNECTION`: `CREATE CONNECTION`, `ALTER CONNECTION ... PRIMARY`

### Por Que Isso Importa
Uma empresa global de fintech roda primário em AWS US-East, secundário em AWS EU-West. Se US-East cai, eles promovem EU-West em minutos. Client redirect significa que apps não precisam de mudanças de configuração.

### Melhores Práticas
- Use failover groups (não replicação standalone de banco de dados) para DR de produção
- Inclua objetos de conta no seu failover group para recuperação completa
- Configure client redirect para minimizar RTO de failover
- Monitore lag de replicação via `REPLICATION_GROUP_REFRESH_HISTORY`
- Teste failover trimestralmente com exercícios reais de promoção/failback

**Armadilha do exame:** SE VOCÊ VER "bancos de dados secundários são leitura-escrita" → ERRADO porque bancos de dados secundários são somente leitura até serem promovidos a primário.

**Armadilha do exame:** SE VOCÊ VER "replicação requer o mesmo provedor de nuvem" → ERRADO porque replicação cross-cloud é suportada.

**Armadilha do exame:** SE VOCÊ VER "failover é automático" → ERRADO porque failover deve ser iniciado manualmente (Snowflake não faz auto-failover).

**Armadilha do exame:** SE VOCÊ VER "client redirect funciona sem objetos Connection" → ERRADO porque você deve criar e configurar objetos Connection para client redirect.

### Perguntas Frequentes (FAQ)
**P: Qual é a diferença entre replicação de banco de dados e failover groups?**
R: Replicação de banco de dados cobre um banco de dados. Failover groups agrupam múltiplos bancos de dados + objetos de conta para failover coordenado.

**P: Há perda de dados durante failover?**
R: Potencialmente, sim. RPO = tempo desde o último refresh de replicação bem-sucedido. Qualquer dado escrito após o último refresh não está no secundário.

**P: Posso ter múltiplos failover groups?**
R: Sim. Você pode ter múltiplos failover groups, cada um contendo conjuntos diferentes de objetos. Cada objeto só pode pertencer a um failover group.


### Exemplos de Perguntas de Cenário — Replication & Failover

**Cenário:** A global fintech company runs its primary Snowflake account in AWS US-East-1. Regulators require that the platform can recover from a full regional outage within 5 minutes (RTO) with no more than 15 minutes of data loss (RPO). Applications connect via JDBC using a single connection URL. How should the architect design the DR architecture?
**Resposta:** Set up a failover group containing all critical databases plus account-level objects (users, roles, grants, warehouses, network policies, integrations). Replicate to a secondary account in AWS EU-West-1 (or another region) within the same Organization. Schedule replication refreshes every 10-15 minutes to meet the 15-minute RPO. Configure client redirect using a Connection object — applications connect to the Connection URL, which automatically routes to the active primary. During failover, promote the secondary via `ALTER FAILOVER GROUP ... PRIMARY` and update the Connection object. Apps automatically redirect to the new primary without configuration changes, meeting the 5-minute RTO. Test failover quarterly with real promote/failback drills.

**Cenário:** A company replicates its core database to a secondary account for DR, but during a failover drill, they discover that users cannot log in to the secondary account because roles, grants, and network policies were not replicated. What did the architect miss?
**Resposta:** The architect used database replication alone instead of a failover group with account replication. Database replication only copies the database and its contents — it does not replicate account-level objects like users, roles, grants, warehouses, network policies, or integrations. The correct approach is to create a failover group that includes both the databases AND account-level objects. This ensures that when the secondary is promoted, all access controls, role hierarchies, and network policies are already in place. Always include account objects in failover groups for complete DR.

**Cenário:** An organization operates on AWS for its primary workloads but wants a secondary DR site on Azure for cloud-provider redundancy. Is this possible with Snowflake replication?
**Resposta:** Yes. Snowflake supports cross-cloud replication — you can replicate from an AWS account to an Azure account (or GCP) as long as both accounts are in the same Snowflake Organization. The failover group mechanism works identically across cloud providers. However, the architect should account for cross-cloud data transfer costs, potential latency differences, and data residency regulations that may restrict which regions data can be replicated to. Monitor replication lag via `REPLICATION_GROUP_REFRESH_HISTORY` to ensure RPO targets are met despite cross-cloud overhead.

---

---

## PARES CONFUSOS — Arquitetura de Dados

| Perguntam sobre... | A resposta é... | NÃO... |
|---|---|---|
| **Star schema** vs **snowflake schema** | **Star** = dims desnormalizadas, menos joins, queries rápidas | **Snowflake schema** = dims normalizadas, mais joins, economiza armazenamento mas mais lento |
| **Data Vault** vs **modelagem dimensional** | **Data Vault** = camada de integração/raw (Hubs, Links, Satellites) | **Dimensional** = camada de apresentação/BI (fatos + dims). São *complementares*, não concorrentes |
| **Hub** vs **Link** vs **Satellite** | **Hub** = chave de negócio, **Link** = relacionamento, **Satellite** = histórico descritivo | Não confunda Hub (ID da entidade) com Satellite (atributos) |
| **Managed Iceberg** vs **unmanaged Iceberg** | **Managed** = Snowflake controla metadados + DML completo | **Unmanaged** = catálogo externo (Glue, Polaris) controla metadados, somente leitura do Snowflake |
| **Time Travel** vs **Fail-safe** | **Time Travel** = acessível pelo usuário, 0-90 dias, consulta/restauração via SQL | **Fail-safe** = apenas Suporte Snowflake, 7 dias APÓS Time Travel expirar |
| **Clone** vs **réplica** | **Clone** = snapshot zero-copy *dentro* da mesma conta, objeto independente | **Réplica** = cópia assíncrona para *outra* conta/região para DR |
| **Tabela permanent** vs **transient** | **Permanent** = Time Travel completo + Fail-safe de 7 dias | **Transient** = máximo 1 dia de Time Travel, **zero** Fail-safe |
| **Tabela temporary** vs **transient** | **Temporary** = escopo de sessão, desaparece quando a sessão termina | **Transient** = persiste entre sessões, apenas sem Fail-safe |
| **Secure view** vs **standard view** | **Secure** = esconde definição + barreira de otimizador (mais lenta) | **Standard** = definição visível, otimizador completo (mais rápida) |
| **Materialized view** vs **dynamic table** | **MV** = mantida automaticamente, sem joins/UDFs permitidos | **Dynamic table** = mais flexível (joins OK), baseada em target lag, substitui stream+task |
| **Hybrid table** vs **tabela regular** | **Hybrid** = orientada a linhas, PK/FK/UNIQUE aplicadas, buscas pontuais rápidas (OLTP) | **Regular** = colunar, sem constraints aplicadas (OLAP) |
| **Replicação de banco de dados** vs **failover group** | **Replicação de DB** = um banco de dados copiado para secundário | **Failover group** = conjunto de DBs + objetos de conta que fazem failover juntos |
| **UNDROP** vs **Time Travel AT** | **UNDROP** = restaura um objeto *descartado* | **AT/BEFORE** = consulta/restaura dados em um *ponto no tempo* (objeto ainda existe) |
| **Client redirect** vs **DNS failover** | **Client redirect** = **objeto Connection** do Snowflake, rota automática para primário ativo | NÃO é DNS genérico — requer configuração explícita do Snowflake |

---

## ÁRVORES DE DECISÃO DE CENÁRIOS — Arquitetura de Dados

**Cenário 1: "Mais de 20 sistemas fonte, esquemas mudam mensalmente, precisa de trilha de auditoria completa..."**
- **CORRETO:** **Data Vault** para a camada de integração (absorve mudanças nos Satellites)
- ARMADILHA: *"Star schema em dados brutos"* — **ERRADO**, star schema é frágil com mudanças frequentes de esquema

**Cenário 2: "Equipe de BI precisa de dashboards rápidos em dados estáveis e bem compreendidos..."**
- **CORRETO:** **Star schema** para a camada de apresentação/consumo
- ARMADILHA: *"Data Vault diretamente para BI"* — **ERRADO**, queries de Data Vault são complexas; construa star schemas por cima

**Cenário 3: "Precisa de dados em formato aberto para Spark e Snowflake lerem/escreverem..."**
- **CORRETO:** **Managed Iceberg table** com external volume (Snowflake escreve formato Iceberg, Spark lê os mesmos arquivos)
- ARMADILHA: *"Tabela externa"* — **ERRADO**, tabelas externas são somente leitura e não produzem formato Iceberg

**Cenário 4: "Tabelas de staging guardam dados temporários de ETL — minimizar custos de armazenamento..."**
- **CORRETO:** **Tabelas transient** (sem Fail-safe = menor custo de armazenamento)
- ARMADILHA: *"Tabelas temporary"* — **ERRADO**, tabelas temporary têm escopo de sessão e desaparecem quando a sessão termina; não adequadas para ETL multi-sessão

**Cenário 5: "Analista acidentalmente deletou 1M de linhas da produção 2 horas atrás..."**
- **CORRETO:** **Time Travel** — `INSERT INTO prod SELECT * FROM prod AT(OFFSET => -7200)` ou `CREATE TABLE restore CLONE prod AT(...)`
- ARMADILHA: *"Contactar Suporte Snowflake para Fail-safe"* — **ERRADO**, Fail-safe é apenas após Time Travel expirar; 2 horas atrás está dentro do Time Travel

**Cenário 6: "Precisa de DR em uma região de nuvem diferente com < 5 min de RTO para conexões de app..."**
- **CORRETO:** **Failover group** (DB + objetos de conta) + **client redirect** (objeto Connection)
- ARMADILHA: *"Replicação de banco de dados sozinha"* — **ERRADO**, replicação de DB não cobre roles/usuários/policies, e sem redirecionamento automático sem objetos Connection

**Cenário 7: "Impedir que donos individuais de tabelas em produção concedam acesso às suas tabelas..."**
- **CORRETO:** **Managed access schema** — centraliza controle de concessões no dono do schema
- ARMADILHA: *"Apenas usar RBAC cuidadosamente"* — **ERRADO**, sem managed access, qualquer dono de objeto pode conceder privilégios

**Cenário 8: "Dados compartilhados com consumidores externos — deve esconder definição da query..."**
- **CORRETO:** **Secure views** (esconde definição, previne bypass de predicate pushdown)
- ARMADILHA: *"Standard views com row access policies"* — **ERRADO**, standard views expõem a definição SQL para consumidores

**Cenário 9: "Precisa de uma tabela resumo pré-computada que atualiza automaticamente, agregação simples, sem joins..."**
- **CORRETO:** **Materialized view** (mantida automaticamente, ótima para agregações simples)
- ARMADILHA: *"Dynamic table"* — não é errado em si, mas MV é mais simples e mais eficiente para agregações de tabela única sem joins

**Cenário 10: "Aplicação precisa de buscas rápidas por linha única por primary key + joins com tabelas de analytics..."**
- **CORRETO:** **Hybrid table** (orientada a linhas, PK aplicada, leituras pontuais rápidas)
- ARMADILHA: *"Tabela Snowflake regular com clustering na PK"* — **ERRADO**, armazenamento colunar não é otimizado para buscas por linha única

**Cenário 11: "Cluster Spark possui o catálogo Iceberg (AWS Glue), Snowflake precisa ler..."**
- **CORRETO:** **Unmanaged (catalog-linked) Iceberg table** com integração de catálogo Glue
- ARMADILHA: *"Managed Iceberg table"* — **ERRADO**, managed significa que Snowflake assume a propriedade do catálogo, conflitando com Spark

**Cenário 12: "Clonar produção para dev para testes sem dobrar armazenamento..."**
- **CORRETO:** **Zero-copy clone** (`CREATE DATABASE dev CLONE prod`)
- ARMADILHA: *"CTAS de todas as tabelas para novo banco de dados"* — **ERRADO**, CTAS copia todos os dados imediatamente, dobrando armazenamento

---

## FLASHCARDS -- Domínio 2

**Q1:** Quais são os três tipos de entidade principais no Data Vault?
**A1:** Hubs (chaves de negócio), Links (relacionamentos), Satellites (atributos descritivos + histórico).

**Q2:** Qual é a retenção máxima de Time Travel na edição Enterprise?
**A2:** 90 dias.

**Q3:** Tabelas transient têm Fail-safe?
**A3:** Não. Zero Fail-safe.

**Q4:** Materialized views podem incluir joins?
**A4:** Não. MVs não podem incluir joins, UDFs ou subqueries.

**Q5:** O que é zero-copy cloning?
**A5:** Criar uma cópia de um objeto que compartilha o armazenamento subjacente até os dados divergirem. Sem armazenamento adicional no momento da clonagem.

**Q6:** Qual é a diferença entre managed e unmanaged Iceberg tables?
**A6:** Managed: Snowflake controla metadados + dados, DML completo. Unmanaged: catálogo externo gerencia metadados, limitado/somente leitura do Snowflake.

**Q7:** Quais objetos um failover group pode conter?
**A7:** Databases, shares, users, roles, warehouses, integrations, network policies e outros objetos de conta.

**Q8:** Como funciona UNDROP se você descarta e recria uma tabela com o mesmo nome?
**A8:** UNDROP usa versionamento interno — restaura a versão descartada mais recentemente, não a atual.

**Q9:** O que torna hybrid tables diferentes de tabelas regulares?
**A9:** Armazenamento orientado a linhas, constraints aplicadas (PK, FK, UNIQUE), buscas pontuais rápidas — projetadas para OLTP.

**Q10:** Replicação é síncrona ou assíncrona?
**A10:** Assíncrona. A atualidade dos dados depende da frequência de refresh.

**Q11:** O que é um managed access schema?
**A11:** Um schema onde apenas o dono do schema (ou detentor de MANAGE GRANTS) pode conceder privilégios em objetos — donos individuais de objetos não podem.

**Q12:** Qual é o overhead de armazenamento do Fail-safe?
**A12:** Até 7 dias de dados históricos além do Time Travel, apenas para tabelas permanent.

**Q13:** Você pode replicar entre provedores de nuvem?
**A13:** Sim, desde que ambas as contas estejam na mesma Organization.

**Q14:** O que uma secure view esconde?
**A14:** Sua definição de query e previne que o otimizador empurre predicados além da barreira da view.

**Q15:** O que é client redirect?
**A15:** Um objeto Connection que roteia automaticamente clientes para a conta primária ativa durante failover.

---

## EXPLIQUE COMO SE EU TIVESSE 5 ANOS -- Domínio 2

**1. Data Vault**
Imagine que você tem uma caixa para o nome de cada amigo (Hub), um barbante conectando amigos que brincaram juntos (Link), e post-its descrevendo o que aconteceu em cada brincadeira (Satellite). Você nunca joga nada fora — só adiciona mais post-its!

**2. Star Schema**
Sua coleção de brinquedos: o grande baú de brinquedos no meio tem todas as suas sessões de brincadeira (tabela fato). Em volta estão prateleiras etiquetadas "brinquedos", "amigos", "dias da semana" (tabelas dimensão). Fácil de encontrar "com qual brinquedo eu brinquei na terça?"

**3. Time Travel**
Seu botão mágico de desfazer. Derramou tinta no seu desenho? Pressione desfazer e volte para antes do derramamento. Funciona por até 90 dias!

**4. Fail-safe**
Mesmo depois que seu botão de desfazer para de funcionar, seus pais guardaram uma cópia secreta dos seus desenhos em uma gaveta trancada. Você não pode abrir sozinho, mas eles podem ajudar se algo realmente ruim acontecer.

**5. Zero-Copy Cloning**
Como tirar uma foto do seu castelo de LEGO. A foto não usa peças de LEGO extras. Mas se você mudar o castelo original, apenas as partes alteradas precisam de peças extras.

**6. Tabelas Transient vs Permanent**
Tabelas permanent são como seu brinquedo favorito guardado para sempre com seguro (Fail-safe). Tabelas transient são como castelos de areia — eles existem, mas sem seguro se a maré chegar.

**7. Managed Iceberg Tables**
Você constrói com LEGO, mas usa o sistema de conector universal de LEGO para que seu amigo com uma marca diferente de LEGO também possa conectar ao seu castelo. Snowflake gerencia a construção, mas qualquer um pode ler as instruções.

**8. Secure Views**
Uma janela mágica onde você pode ver o jardim mas não pode ver como a janela foi construída. Pessoas diferentes olhando pela mesma janela podem ver flores diferentes (filtradas!).

**9. Replicação**
Como ter um backup do seu save de jogo favorito em um pendrive na casa da vovó. Se seu computador quebrar, a vovó tem o save. Não está totalmente atualizado, mas quase.

**10. Client Redirect**
Como uma caixa de correio que te segue. Se você muda de casa, a caixa de correio automaticamente vai para sua nova casa, e as cartas de todo mundo ainda chegam sem eles saberem que você mudou.

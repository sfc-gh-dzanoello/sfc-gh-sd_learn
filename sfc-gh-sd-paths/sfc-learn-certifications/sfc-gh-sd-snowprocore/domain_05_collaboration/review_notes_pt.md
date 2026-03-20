# DOMÍNIO 5: COLABORAÇÃO DE DADOS
## 10% do exame = ~10 questões. Menor domínio, mas pontos fáceis.

---

## 5.1 REPLICAÇÃO DE DADOS E FAILOVER

### Replicação de Banco de Dados:
- Copiar um banco de dados de uma conta para outra
- Banco de dados primário (leitura-escrita) → Banco(s) de dados secundário(s) (somente leitura)
- Pode replicar entre regiões e provedores de nuvem
- Banco de dados secundário faz refresh para sincronizar mudanças do primário
- Necessário para: compartilhamento de dados cross-region

### Replicação de Conta:
- Replicar objetos no nível de conta (usuários, roles, warehouses, bancos de dados)
- Para recuperação de desastres

### Failover (Business Critical+):
- Promover um banco de dados/conta secundário para primário
- Quando a região/conta primária está indisponível
- Continuidade de negócios e recuperação de desastres
- Failback: voltar ao primário original após recuperação

**Armadilha do exame**: "Compartilhar dados cross-region?" → Precisa de replicação PRIMEIRO, depois compartilhar. SE VOCÊ VER "compartilhamento direto" + "cross-region" ou "nuvem diferente" → ERRADO porque compartilhamento direto = mesma região + mesma nuvem apenas.
**Armadilha do exame**: "Edição para failover?" → Business Critical+. SE VOCÊ VER "Standard" ou "Enterprise" + "failover" → ERRADO porque failover requer Business Critical ou superior.
**Armadilha do exame**: "Banco de dados secundário é..." → Somente leitura até ser promovido. SE VOCÊ VER "leitura-escrita" + "banco de dados secundário" → ERRADO porque secundário = somente leitura. Apenas primário é leitura-escrita.


### Exemplos de Perguntas de Cenário — Data Replication & Failover

**Cenário:** A multinational retail company has its primary Snowflake account in AWS US-East-1. They need to share sales data with their analytics team in AWS EU-Frankfurt. The team tries to create a direct share but gets an error. What is the correct approach?
**Resposta:** Direct shares only work within the same cloud provider AND the same region. The company must first replicate the database to an account in AWS EU-Frankfurt using database replication (CREATE DATABASE ... AS REPLICA OF ...), then create a share from the replicated database in that region. Replication works across regions and cloud providers on any Snowflake edition.

**Cenário:** A financial services firm on Snowflake Business Critical edition has accounts in two regions for disaster recovery. Their primary region experiences an outage. The DR team needs to restore operations. What Snowflake feature should they use, and what edition is required?
**Resposta:** They should use Failover to promote their secondary account/database to primary. Failover is available only on Business Critical edition and above — their BC edition qualifies. Once the original region recovers, they can failback (switch back to the original primary). Standard and Enterprise editions support replication but NOT failover.

**Cenário:** A healthcare company replicates their patient analytics database to a secondary account for disaster recovery. A junior analyst connects to the secondary database and tries to INSERT new records. What happens?
**Resposta:** The INSERT will fail. Secondary databases are read-only — they can only be used for querying until they are promoted to primary via failover. Only the primary database supports read-write operations. The analyst must connect to the primary account to insert data.

---

---

## 5.2 SECURE DATA SHARING (MUITO COBRADO)

### Como funciona:
- Provider COMPARTILHA dados com Consumer
- NENHUM dado é copiado ou movido
- Consumer acessa dados do Provider em tempo real
- Mudanças feitas pelo Provider são visíveis ao Consumer IMEDIATAMENTE
- Zero movimentação de dados = zero custo de armazenamento para compartilhamento

### O que pode ser compartilhado:
- Tabelas
- Secure views (obrigatório para compartilhar views)
- Secure UDFs
- Secure materialized views

### O que NÃO pode ser compartilhado diretamente:
- Views regulares (não seguras)
- Stages
- Pipes
- Tasks

### Objeto Share:
- Criado por ACCOUNTADMIN (apenas ACCOUNTADMIN pode criar shares)
- GRANT de privilégios em objetos TO SHARE
- Consumer cria um banco de dados FROM SHARE

### Provider vs Consumer:
| | Provider | Consumer |
|---|---|---|
| Cria share | Sim | Não |
| É dono dos dados | Sim | Não |
| Paga por armazenamento | Sim | Não |
| Paga por computação | Não (consumer consulta) | Sim (warehouse próprio) |
| Pode modificar dados compartilhados | Sim | Não (somente leitura) |

### Regra-chave: Consumer usa seu PRÓPRIO warehouse para consultar dados compartilhados. Provider não paga nada pelas queries do consumer.

### Por Que Isso Importa + Casos de Uso

**Cenário real — "Nosso parceiro não tem conta Snowflake"**
Crie uma Reader Account para ele. VOCÊ (provider) paga por TUDO — armazenamento + computação. A reader account é somente leitura e limitada. Use isto apenas quando o parceiro não tem conta Snowflake.

**Cenário real — "Compartilhamos uma view mas o consumer vê nossa lógica SQL"**
Views regulares expõem a definição SQL. Solução: use views SECURE para TODOS os objetos compartilhados. Secure views escondem a definição SQL dos consumidores. Isto é OBRIGATÓRIO para shares.

**Cenário real — "Precisamos compartilhar dados com nosso escritório em Tóquio mas nossa conta é em US-West"**
Compartilhamento direto cross-region NÃO é possível. Solução: replique seu banco de dados para a região de Tóquio primeiro (CREATE DATABASE ... AS REPLICA OF ...), depois crie um share naquela região.

---

### Melhores Práticas — Compartilhamento de Dados
- Sempre use views SECURE para compartilhamento (obrigatório, esconde SQL)
- Apenas ACCOUNTADMIN pode criar shares
- Para compartilhamento cross-region: replique o banco de dados primeiro, depois crie o share
- Reader accounts: use APENAS quando o consumer não tem conta Snowflake (você paga tudo)
- Monitore uso de dados compartilhados com views ACCOUNT_USAGE

**Armadilha do exame**: "Quem paga pela computação em dados compartilhados?" → Consumer (usa warehouse próprio). SE VOCÊ VER "provider paga computação" ou "warehouse do provider" para queries compartilhadas → ERRADO porque consumer sempre usa seu PRÓPRIO warehouse.
**Armadilha do exame**: "Provider atualiza dados, quando consumer vê?" → Imediatamente. SE VOCÊ VER "atraso", "refresh necessário" ou "sincronização necessária" para visibilidade de dados compartilhados → ERRADO porque dados compartilhados = mesmos dados subjacentes, mudanças visíveis instantaneamente.
**Armadilha do exame**: "Quem cria objeto Share?" → Apenas ACCOUNTADMIN. SE VOCÊ VER "SYSADMIN", "SECURITYADMIN" ou "USERADMIN" + "criar share" → ERRADO porque APENAS ACCOUNTADMIN pode criar objetos Share.
**Armadilha do exame**: "Pode compartilhar uma view regular?" → NÃO, deve ser Secure View. SE VOCÊ VER "view regular" + "share" ou "view não segura" + "compartilhamento de dados" → ERRADO porque APENAS secure views/UDFs/MVs podem ser compartilhadas.


### Exemplos de Perguntas de Cenário — Secure Data Sharing

**Cenário:** A logistics company (Provider) shares real-time shipment tracking data with a retail partner (Consumer). The retail partner's CFO asks: "How much are we being charged for storing the shared data?" What is the correct answer?
**Resposta:** The Consumer pays zero for storage of shared data. The Provider owns and stores the data — storage costs are entirely the Provider's responsibility. The Consumer only pays for compute when they query the shared data using their own warehouse. Shared data involves zero data movement and zero storage duplication.

**Cenário:** A data engineering team creates a share containing a view that joins three internal tables. After the consumer creates a database from the share, they can see the SQL definition of the view and reverse-engineer the Provider's data model. How should this be fixed?
**Resposta:** The view must be changed to a SECURE view (ALTER VIEW ... SET SECURE). Only secure views, secure UDFs, and secure materialized views can be shared. Secure views hide the SQL definition from consumers, preventing them from seeing the underlying logic or table structure. Regular (non-secure) views should never be used in shares.

**Cenário:** A Provider updates pricing data in a shared table at 2:00 PM. The Consumer runs a query at 2:01 PM. Will the Consumer see the updated prices, or is there a synchronization delay?
**Resposta:** The Consumer will see the updated prices immediately. Secure Data Sharing provides real-time access to the Provider's underlying data — there is no copy, no sync process, and no delay. Changes made by the Provider are visible to the Consumer instantly because both are reading the same underlying micro-partitions.

**Cenário:** A SYSADMIN at a healthcare company tries to create a SHARE object to distribute anonymized patient statistics to research partners. The command fails. Why?
**Resposta:** Only ACCOUNTADMIN can create SHARE objects in Snowflake. SYSADMIN, SECURITYADMIN, and other roles do not have the CREATE SHARE privilege. The SYSADMIN must ask the ACCOUNTADMIN to create the share, or the ACCOUNTADMIN role must be used directly.

---

---

## 5.3 READER ACCOUNTS

### O que são:
- Criadas PELO Provider PARA consumidores que NÃO têm conta Snowflake
- Conta gerenciada — Provider controla tudo

### Fatos-chave:
- Provider as cria (CREATE MANAGED ACCOUNT)
- **Provider paga por tudo** (armazenamento + computação)
- Usuários da reader account só podem consultar dados compartilhados (somente leitura)
- Não podem criar seus próprios bancos de dados/tabelas (funcionalidade limitada)
- Sem limite rígido no número de Reader Accounts por Provider

**Armadilha do exame**: "Consumer não tem conta Snowflake?" → Criar Reader Account. SE VOCÊ VER "sem conta Snowflake" + "compartilhamento direto" ou "Marketplace" → ERRADO porque sem conta SF, apenas Reader Account funciona.
**Armadilha do exame**: "Quem paga pela computação da Reader Account?" → O PROVIDER. SE VOCÊ VER "consumer paga" + "reader account" → ERRADO porque Reader Account = Provider paga TUDO (armazenamento + computação).
**Armadilha do exame**: "Quantas Reader Accounts você pode criar?" → Sem limite rígido. SE VOCÊ VER um número específico como "5", "10", "25" como limite máximo → ERRADO porque não há limite rígido de Reader Accounts por Provider.


### Exemplos de Perguntas de Cenário — Reader Accounts

**Cenário:** A weather data Provider wants to share forecast data with a small agricultural cooperative that does not have a Snowflake account and has no budget for one. The Provider's finance team asks who will pay for the cooperative's query compute costs. What is the answer?
**Resposta:** The Provider pays for everything — both storage and compute — when using a Reader Account. Since the cooperative has no Snowflake account, a Reader Account (CREATE MANAGED ACCOUNT) is the only option. The Provider should budget for the cooperative's compute costs, as queries run on warehouses provisioned within the Reader Account but billed to the Provider.

**Cenário:** A consulting firm creates a Reader Account for a client to access shared benchmark data. The client's analyst wants to create their own tables within the Reader Account to store custom calculations. Can they do this?
**Resposta:** No. Reader Accounts are limited to read-only access on shared data. Users in a Reader Account cannot create their own databases, tables, or other objects. If the client needs to store custom calculations, they must get their own full Snowflake account. Reader Accounts are intentionally restricted — they exist solely to query data shared by the Provider.

**Cenário:** A SaaS company shares usage analytics with 30 different enterprise clients, each without Snowflake accounts. Their architect asks if there is a limit to how many Reader Accounts they can create. What should they be told?
**Resposta:** There is no hard limit on the number of Reader Accounts a Provider can create. The SaaS company can create Reader Accounts for all 30 clients. However, they should be aware that they (the Provider) will pay all compute and storage costs for every Reader Account, so cost monitoring is important at scale.

---

---

## 5.4 COMPARTILHAMENTO DE DADOS E RECOMPARTILHAMENTO

### Compartilhamento Direto:
- Provider → Consumer (um-para-um ou um-para-muitos)
- Ambos devem estar no mesmo provedor de nuvem + região (a menos que use replicação)
- Para cross-region: replique o banco de dados primeiro, depois compartilhe

### Recompartilhamento:
- Consumer pode recompartilhar dados que recebeu (se Provider permitir)
- Cadeia de compartilhamento

**Armadilha do exame**: "Compartilhamento direto funciona entre regiões?" → NÃO. Mesma região + nuvem apenas. Cross-region requer replicação PRIMEIRO. SE VOCÊ VER "compartilhamento direto" + "região diferente" ou "cross-cloud" → ERRADO porque compartilhamento direto = mesma região E mesmo provedor de nuvem apenas.
**Armadilha do exame**: "Qualquer consumer pode recompartilhar dados?" → Apenas se o Provider permitir explicitamente. Não é automático. SE VOCÊ VER "consumer recompartilha" + "por padrão" ou "automaticamente" → ERRADO porque recompartilhamento requer permissão explícita do Provider.
**Armadilha do exame**: "Compartilhamento direto = dados são copiados para o consumer?" → ERRADO. Zero cópia. Consumer lê dados do Provider no local. SE VOCÊ VER "dados copiados", "dados movidos" ou "dados transferidos" + "compartilhamento" → ERRADO porque compartilhamento = zero cópia, zero movimentação.


### Exemplos de Perguntas de Cenário — Data Sharing & Resharing

**Cenário:** A pharmaceutical company in AWS US-East-1 wants to share clinical trial results directly with a research hospital in Azure West Europe. They attempt to create a direct share. Will this work?
**Resposta:** No. Direct shares require both parties to be on the same cloud provider AND the same region. AWS US-East-1 and Azure West Europe differ in both cloud provider and region. The pharmaceutical company must first replicate the database to an account in Azure West Europe, then create a share from that replicated database.

**Cenário:** Company A shares market research data with Company B via Secure Data Sharing. Company B wants to reshare this data with Company C (a mutual business partner). Can Company B do this without any special permissions?
**Resposta:** No. Resharing is not automatic. Company B can only reshare the data if Company A (the original Provider) explicitly grants permission to reshare. Without that permission, Company B cannot create a share of data they received from Company A. This prevents unauthorized distribution of proprietary data.

**Cenário:** A data Provider shares inventory data with 15 different retail partners, all within the same AWS US-West-2 region. One partner asks if the Provider had to create 15 separate copies of the data to serve all partners. What is the reality?
**Resposta:** Zero copies were created. A single share can serve multiple consumers (one-to-many). All 15 retail partners read from the same underlying data in the Provider's storage. There is no data duplication, no data movement, and no additional storage cost for the Provider regardless of how many consumers access the share. Each consumer uses their own warehouse for compute.

---

---

## 5.5 SNOWFLAKE MARKETPLACE

### O que é:
- Plataforma de descoberta e acesso para produtos de dados
- Provedores de dados terceiros listam seus dados
- Consumidores navegam, solicitam acesso e usam dados
- Algumas listagens são gratuitas, outras são pagas

### Tipos de Listagens:

**Listagens Públicas**:
- Visíveis para todas as contas Snowflake
- Qualquer um pode solicitar acesso
- Listadas no Marketplace

**Listagens Privadas**:
- Visíveis apenas para contas específicas convidadas
- Compartilhamento direto entre partes conhecidas
- Não são publicamente descobríveis

### Data Exchange (conceito mais antigo):
- Hub privado para grupo controlado de participantes
- Provider controla quem pode participar
- Membros podem compartilhar dados dentro do exchange

**Armadilha do exame**: "Marketplace vs Data Exchange?" → Marketplace = listagens públicas/privadas para ampla descoberta. Data Exchange = hub privado apenas por convite. SE VOCÊ VER "Data Exchange" + "público" ou "qualquer um pode participar" → ERRADO porque Data Exchange = privado, apenas por convite.
**Armadilha do exame**: "Listagem Privada vs Data Exchange?" → Listagem Privada = no Marketplace mas visível apenas para contas convidadas. Data Exchange = hub privado totalmente separado. SE VOCÊ VER "Listagem Privada" confundida com "Data Exchange" → ERRADO porque Listagem Privada fica NO Marketplace; Data Exchange é um hub separado.
**Armadilha do exame**: "Listagem gratuita no Marketplace = sem custo algum?" → Sem custo de armazenamento para o consumer (Provider armazena), mas consumer ainda paga computação para consultar. SE VOCÊ VER "listagem gratuita" + "sem custo" ou "completamente grátis" → ERRADO porque "gratuita" significa apenas sem taxa de dados — consumer ainda paga computação.


### Exemplos de Perguntas de Cenário — Snowflake Marketplace

**Cenário:** A global weather data company wants to make their historical climate dataset available to any Snowflake customer worldwide for discovery and purchase. Should they use a Public Listing, a Private Listing, or a Data Exchange?
**Resposta:** A Public Listing on the Snowflake Marketplace. Public listings are visible to all Snowflake accounts and allow anyone to discover, request access, and use the data. This is the right choice for broad distribution to unknown potential customers. A Private Listing would limit visibility to invited accounts only, and a Data Exchange is a separate private hub — neither fits the goal of broad public discovery.

**Cenário:** A financial services consortium of five banks wants to share proprietary risk models only among themselves — no outside access. They need a controlled environment where only approved members can participate. What should they use?
**Resposta:** A Data Exchange. Data Exchanges are private, invite-only hubs where the provider controls exactly who can join. This is ideal for a closed consortium where membership is restricted. A Marketplace public listing would expose the data to all Snowflake users, and a private listing still lives on the public Marketplace (just with restricted visibility). A Data Exchange is a completely separate, controlled environment.

**Cenário:** A consumer finds a "free" weather dataset on the Snowflake Marketplace and tells their manager it will cost the company nothing. Is this accurate?
**Resposta:** Not entirely. "Free" on the Marketplace means there is no data licensing fee and no storage cost to the consumer (the Provider stores the data). However, the consumer still pays for compute — they must use their own warehouse to query the data. So while the data itself is free, querying it incurs standard Snowflake compute charges.

---

---

## 5.6 NATIVE APPS

### O que são:
- Aplicações completas construídas sobre dados Snowflake
- Provider constrói o app, Consumer instala
- App roda na conta do Consumer
- Dados ficam na conta do Consumer (privacidade)
- Pode incluir: UI (Streamlit), stored procedures, UDFs, views

### Native App Framework:
- Provider cria um Application Package
- Package inclui: script de setup, conteúdo de dados, UI Streamlit, código
- Consumer instala e executa o app
- Provider pode atualizar o app (versionamento)

**Armadilha do exame**: "Native App roda na conta do Provider?" → ERRADO. Roda na conta do Consumer. Dados permanecem privados para o consumer. SE VOCÊ VER "conta do provider" + "Native App roda" → ERRADO porque Native Apps SEMPRE rodam na conta do Consumer.
**Armadilha do exame**: "Native App vs Secure Data Sharing?" → Sharing = acesso somente leitura a dados. Native App = aplicação completa com UI + lógica + código. SE VOCÊ VER "compartilhamento" quando a questão descreve UI, stored procedures ou lógica de aplicação → ERRADO porque isso é Native App, não compartilhamento simples.
**Armadilha do exame**: "Quem paga computação do Native App?" → Consumer (roda na conta dele com sua computação). SE VOCÊ VER "provider paga computação" + "Native App" → ERRADO porque app roda na conta do Consumer, então Consumer paga toda a computação.


### Exemplos de Perguntas de Cenário — Native Apps

**Cenário:** An analytics vendor builds a churn-prediction application with a Streamlit dashboard, stored procedures, and UDFs. They want to distribute it to customers so each customer can run it on their own data without exposing that data to the vendor. What Snowflake feature should they use?
**Resposta:** A Native App. The vendor creates an Application Package containing the Streamlit UI, stored procedures, and UDFs. Each customer installs the app in their own Snowflake account. The app runs inside the customer's account on the customer's data — the vendor never sees the customer's raw data. This preserves data privacy while distributing full application functionality.

**Cenário:** A consumer installs a Native App from a Provider. The consumer's finance team wants to know: does the Provider charge us for the compute used to run this app? Where does the app actually execute?
**Resposta:** The Native App runs entirely in the Consumer's account, using the Consumer's compute resources (warehouses). The Consumer pays for all compute. The Provider does not pay for the Consumer's execution costs. The Provider may charge a licensing or subscription fee for the app itself (separate from Snowflake compute costs), but Snowflake compute is always the Consumer's responsibility since the app runs in their environment.

**Cenário:** A data Provider currently shares read-only tables with consumers via Secure Data Sharing. A consumer asks for interactive dashboards and custom scoring logic on the shared data. Can this be done with Secure Data Sharing alone?
**Resposta:** No. Secure Data Sharing provides read-only data access — it cannot deliver UI, stored procedures, or application logic. The Provider should build a Native App using the Native App Framework. The Application Package can include a Streamlit UI for dashboards, stored procedures for scoring logic, and UDFs for calculations. The consumer installs it and gets the full interactive experience in their own account.

---

---

## 5.7 CLONAGEM (Zero-Copy)

### Como funciona:
- CREATE TABLE/DATABASE/SCHEMA ... CLONE source
- Operação apenas de metadados (instantânea)
- Sem armazenamento adicional até dados serem modificados
- Clone é independente — mudanças não afetam o original

### O que pode ser clonado:
- Databases
- Schemas
- Tables (permanent, transient, temporary)
- Streams
- Tasks
- Stages (apenas named stages, não user/table stages)
- File formats
- Sequences

### O que NÃO pode ser clonado:
- Tabelas externas
- Stages internos (user/table)

### Comportamento do clone com privilégios:
- Ao clonar um database/schema: objetos filhos herdam os MESMOS privilégios da origem
- Ao clonar uma única tabela: privilégios NÃO são copiados

### Clone + Time Travel:
- Clone captura dados no ponto ATUAL no tempo (ou tempo especificado)
- Clone NÃO inclui histórico de Time Travel do original
- Pode clonar usando Time Travel: CREATE TABLE clone CLONE source AT(TIMESTAMP => '...')

**Armadilha do exame**: "Custo de armazenamento do novo clone?" → Zero até modificações. SE VOCÊ VER "dobra armazenamento", "custo de cópia completa" ou "mesmo armazenamento que original" + "clone" → ERRADO porque clone = zero-copy, sem armazenamento extra até dados serem modificados.
**Armadilha do exame**: "Clone inclui histórico de Time Travel?" → NÃO. SE VOCÊ VER "histórico de Time Travel" + "clone herda" ou "clone inclui" → ERRADO porque clone começa do zero SEM histórico de Time Travel da origem.
**Armadilha do exame**: "Clonar em um ponto passado?" → Sim, usando cláusula AT/BEFORE. SE VOCÊ VER "não pode clonar dados históricos" ou "clone só funciona no estado atual" → ERRADO porque você PODE clonar em um ponto passado via CLONE source AT(TIMESTAMP => '...').
**Armadilha do exame**: "Clone de database inclui privilégios?" → SIM (objetos filhos mantêm privilégios). SE VOCÊ VER "sem privilégios" + "clone de database" ou "clone de schema" → ERRADO porque clones de DB/schema MANTÊM privilégios filhos. Apenas clones de TABELA individual perdem privilégios.


### Exemplos de Perguntas de Cenário — Cloning

**Cenário:** A DevOps team needs to create an exact copy of their 2TB production database for QA testing. They are concerned about doubling their storage costs and the time it will take to copy all the data. How should they proceed?
**Resposta:** Use zero-copy cloning: CREATE DATABASE qa_db CLONE production_db. This is a metadata-only operation that completes in seconds regardless of database size. The clone initially points to the same underlying micro-partitions, so there is zero additional storage cost at creation. Storage costs only increase as the QA team modifies data in the clone — and only for the changed micro-partitions, not the entire database.

**Cenário:** A DBA clones an entire production database for a development team. The dev team asks whether the table-level grants (SELECT, INSERT) that exist in production will also exist in the cloned database. What is the answer?
**Resposta:** Yes. When cloning a database or schema, child objects inherit the same privileges from the source. So all table-level grants (SELECT, INSERT, etc.) in the production database will be present in the cloned database. This is different from cloning a single table directly — in that case, privileges are NOT copied.

**Cenário:** A data engineer clones a table and then discovers they need the data as it existed two days ago, not at the current point in time. They also wonder if the clone contains the original table's Time Travel history. What should they know?
**Resposta:** Clones do NOT include the Time Travel history of the source table — the clone starts fresh with its own Time Travel timeline from the moment of creation. However, the engineer can create a new clone at a past point in time using: CREATE TABLE my_clone CLONE source_table AT(TIMESTAMP => '2024-01-15 10:00:00'). This combines cloning with Time Travel to capture the table's state at the specified timestamp.

**Cenário:** A team tries to clone an external table and a table stage as part of their development environment setup. Both operations fail. Why?
**Resposta:** External tables and internal stages (user stages and table stages) cannot be cloned. These are among the few object types excluded from cloning. Named stages CAN be cloned, but user/table stages cannot. For external tables, the team would need to recreate the external table definition manually in the target environment.

---

---

## 5.8 TIME TRAVEL (MUITO COBRADO)

### O que é:
- Acessar dados históricos (antes de mudanças)
- Consultar dados como eram em um ponto passado no tempo
- Recuperar objetos descartados

### Períodos de retenção:
| Edição | Tabelas Permanent | Transient/Temporary |
|---|---|---|
| Standard | 0-1 dia | 0-1 dia |
| Enterprise+ | 0-90 dias | 0-1 dia |

### Parâmetro: DATA_RETENTION_TIME_IN_DAYS
- Definido no nível de conta, banco de dados, schema ou tabela
- Definir como 0 = desabilita Time Travel para aquele objeto

### Queries de Time Travel:
- `AT(TIMESTAMP => 'timestamp')` → dados no momento exato
- `AT(OFFSET => -60*5)` → dados de 5 minutos atrás (segundos)
- `AT(STATEMENT => 'query_id')` → dados antes de uma query específica
- `BEFORE(STATEMENT => 'query_id')` → dados antes da query ser executada

### Recuperar objetos descartados:
- UNDROP TABLE table_name
- UNDROP SCHEMA schema_name
- UNDROP DATABASE database_name
- Deve estar dentro do período de retenção de Time Travel

### Melhores Práticas — Proteção de Dados
- Defina DATA_RETENTION_TIME_IN_DAYS = 90 para tabelas críticas de produção (Enterprise+)
- Defina DATA_RETENTION_TIME_IN_DAYS = 0 para dados de staging/temporários (economize armazenamento)
- Use UNDROP imediatamente após descartes acidentais — é a recuperação mais rápida
- Clone antes de operações arriscadas: CREATE TABLE backup CLONE production
- Fail-safe é apenas via suporte Snowflake — planeje recuperação em torno do Time Travel, não do Fail-safe

**Armadilha do exame**: "Consultar dados de 5 minutos atrás?" → AT(OFFSET => -60*5). SE VOCÊ VER "TIMESTAMP" quando a questão diz "X minutos atrás" → armadilha! Offset usa SEGUNDOS negativos, não um timestamp.
**Armadilha do exame**: "UNDROP TABLE funciona dentro de..." → Período de retenção de Time Travel. SE VOCÊ VER "Fail-safe" + "UNDROP" → ERRADO porque UNDROP só funciona durante Time Travel. Fail-safe requer suporte Snowflake — você não pode fazer UNDROP do Fail-safe.
**Armadilha do exame**: "Definir retenção para 0?" → Desabilita Time Travel. SE VOCÊ VER "DATA_RETENTION_TIME_IN_DAYS = 0" + "ainda tem Time Travel" ou "ainda pode fazer UNDROP" → ERRADO porque 0 = completamente desabilitado, sem acesso histórico algum.
**Armadilha do exame**: "Time Travel máximo de tabela transient?" → 1 dia (mesmo na Enterprise). SE VOCÊ VER "90 dias" + "transient" ou "temporary" → ERRADO porque tabelas transient/temporary têm máximo de 1 dia independente da edição.


### Exemplos de Perguntas de Cenário — Time Travel

**Cenário:** An analyst on an Enterprise edition account accidentally runs a DELETE statement that removes all records from a critical sales table. They realize the mistake 30 minutes later. The table has DATA_RETENTION_TIME_IN_DAYS set to 90. How can they recover the data?
**Resposta:** Since only 30 minutes have passed and the table has 90-day Time Travel retention on Enterprise edition, they have multiple recovery options: (1) Query the data before the delete using SELECT * FROM sales_table BEFORE(STATEMENT => 'delete_query_id'), (2) Use UNDROP if the table was dropped, or (3) Create a clone at the point before the delete: CREATE TABLE sales_recovered CLONE sales_table BEFORE(STATEMENT => 'delete_query_id'). The BEFORE clause captures data just before the DELETE executed.

**Cenário:** A company on Enterprise edition creates a transient staging table for ETL processing. The data architect sets DATA_RETENTION_TIME_IN_DAYS = 90 on this table. Will this work?
**Resposta:** No. Transient tables have a maximum Time Travel retention of 1 day, regardless of the Snowflake edition. Even though Enterprise edition supports up to 90 days for permanent tables, transient and temporary tables are capped at 1 day. The ALTER TABLE command will either fail or be silently capped to 1 day. If 90-day Time Travel is needed, the table must be created as a permanent table.

**Cenário:** A database administrator sets DATA_RETENTION_TIME_IN_DAYS = 0 on a test database to save storage. Later, a developer accidentally drops a table in that database and tries to run UNDROP TABLE. What happens?
**Resposta:** The UNDROP will fail. Setting DATA_RETENTION_TIME_IN_DAYS = 0 completely disables Time Travel for the object. With Time Travel disabled, there is no historical data retained — no AT/BEFORE queries, no UNDROP capability. The table may still be recoverable via Fail-safe (if it was a permanent table), but only by contacting Snowflake support. To prevent this, critical tables should always have a non-zero retention period.

**Cenário:** A data engineer needs to see what a table looked like exactly 10 minutes before a specific UPDATE query ran (query ID: '01a2b3c4-...'). Should they use AT or BEFORE?
**Resposta:** They should use BEFORE(STATEMENT => '01a2b3c4-...'). The BEFORE clause returns data as it existed immediately before the specified statement executed. The AT clause would return data at the moment the statement ran, which would include the effects of the UPDATE. If they need data 10 minutes before the query (not just immediately before), they should use AT(OFFSET => -600) where -600 is 10 minutes in negative seconds, or AT(TIMESTAMP => 'specific_timestamp') with the exact time 10 minutes prior.

---

---

## 5.9 FAIL-SAFE

### O que é:
- Período de 7 dias APÓS Time Travel expirar
- Recuperação de desastres gerenciada pelo Snowflake
- VOCÊ não pode acessar dados do Fail-safe diretamente
- Apenas suporte Snowflake pode recuperar dados do Fail-safe

### Quais tabelas têm Fail-safe:
- Tabelas permanent → SIM (7 dias)
- Tabelas transient → NÃO
- Tabelas temporary → NÃO

### Fail-safe NÃO é:
- Um backup que você controla
- Algo que você pode consultar
- Disponível para tabelas transient/temporary

### Linha do tempo de custo de armazenamento:
```
Dados Ativos → Dados Time Travel → Dados Fail-safe → Purgados
(atual)        (1-90 dias)          (7 dias)           (perdidos para sempre)
```

**Armadilha do exame**: "Fail-safe para tabelas transient?" → SEM Fail-safe. SE VOCÊ VER "Fail-safe" + "transient" ou "temporary" → ERRADO porque APENAS tabelas permanent têm Fail-safe. Transient e temporary = zero Fail-safe.
**Armadilha do exame**: "Pode consultar dados do Fail-safe?" → NÃO (apenas suporte Snowflake). SE VOCÊ VER "SELECT", "consultar" ou "acessar diretamente" + "Fail-safe" → ERRADO porque você NÃO PODE consultar dados do Fail-safe. Apenas suporte Snowflake pode recuperá-los.
**Armadilha do exame**: "Duração do Fail-safe?" → 7 dias (sempre, todas as edições). SE VOCÊ VER "90 dias", "varia por edição" ou "configurável" + "Fail-safe" → ERRADO porque Fail-safe é SEMPRE exatamente 7 dias, não configurável.
**Armadilha do exame**: "Dados descartados há 10 dias, Time Travel de 1 dia?" → No Fail-safe (contate Snowflake), ou se passar de 8 dias no total → permanentemente perdido. SE VOCÊ VER "UNDROP" + "após retenção de Time Travel" → ERRADO porque UNDROP só funciona dentro do Time Travel. Depois disso, apenas suporte Snowflake via Fail-safe.


### Exemplos de Perguntas de Cenário — Fail-Safe

**Cenário:** A company uses transient tables for all their staging data to save on storage costs. After a critical ETL failure corrupts staging data 3 days ago (past the 1-day Time Travel window), the team asks if Fail-safe can recover the data. What is the answer?
**Resposta:** No. Transient tables do NOT have Fail-safe protection — only permanent tables do. With a 1-day Time Travel window already expired, the data is permanently lost. There is no recovery path — not through UNDROP, not through Time Travel queries, and not through Fail-safe. For critical staging data that may need recovery beyond 1 day, the team should use permanent tables instead of transient tables.

**Cenário:** A DBA accidentally drops a permanent production table. Time Travel retention was set to 1 day, and the mistake is discovered 5 days later. The DBA tries UNDROP TABLE but it fails. Is the data gone forever?
**Resposta:** Not necessarily. UNDROP only works within the Time Travel retention period (1 day in this case), so it correctly failed. However, since the table is a permanent table, it has 7 days of Fail-safe protection that begins after Time Travel expires. Day 5 falls within the Fail-safe window (Time Travel day 1 + Fail-safe days 2-8). The DBA must contact Snowflake support to request data recovery from Fail-safe. Note: recovery is not guaranteed and is a best-effort process performed by Snowflake.

**Cenário:** A finance team asks their architect to explain the total storage cost timeline for a permanent table on Enterprise edition with 90-day Time Travel. How long is data retained in total before permanent deletion?
**Resposta:** The total data retention timeline is: Active data (current) → Time Travel (up to 90 days after modification/deletion) → Fail-safe (7 additional days after Time Travel expires) → permanently purged. So the maximum total retention before permanent deletion is 90 + 7 = 97 days. During Time Travel, users can query historical data and use UNDROP. During Fail-safe, only Snowflake support can recover data. After both periods expire, data is gone forever.

**Cenário:** A manager asks: "Can we write a script that queries our Fail-safe data periodically as an extra backup check?" Is this possible?
**Resposta:** No. Fail-safe data cannot be accessed, queried, or interacted with by users in any way. There is no SQL command, API, or interface to read Fail-safe data. It is entirely managed by Snowflake internally and can only be recovered by contacting Snowflake support in a disaster recovery scenario. For proactive backup strategies, rely on Time Travel (which you CAN query) and cloning.

---

---

## 5.10 DATA CLEAN ROOMS

### O que são:
- Ambiente seguro para análise de dados multi-parte
- Cada parte mantém seus dados privados
- Executam queries/análises aprovadas sem expor dados brutos
- Caso de uso: sobreposição de publicidade, correspondência de clientes

**Armadilha do exame**: "Data Clean Room = dados são compartilhados entre partes?" → ERRADO. Dados brutos permanecem privados. Apenas resultados agregados aprovados são visíveis. SE VOCÊ VER "dados brutos compartilhados", "partes veem dados uma da outra" ou "dados trocados" + "Clean Room" → ERRADO porque dados brutos NUNCA saem de cada parte.
**Armadilha do exame**: "Data Clean Room vs Secure Data Sharing?" → Sharing = uma parte dá acesso a dados. Clean Room = análise multi-parte onde NENHUMA parte vê os dados brutos da outra. SE VOCÊ VER "Data Sharing" quando o cenário descreve análise privada multi-parte → ERRADO porque isso é Clean Room, não compartilhamento regular.


### Exemplos de Perguntas de Cenário — Data Clean Rooms

**Cenário:** Two competing retail brands want to measure how many customers they share in common to evaluate a joint loyalty program. Neither brand is willing to reveal their full customer list to the other. What Snowflake feature should they use?
**Resposta:** A Data Clean Room. Each brand keeps their customer data private within their own Snowflake account. The Clean Room allows them to run approved aggregate queries — such as counting overlapping customers — without either party seeing the other's raw customer records. Only the agreed-upon aggregate results (e.g., "12,450 customers overlap") are visible, not the underlying individual records.

**Cenário:** An advertising agency wants to match their campaign audience data against a media company's viewer data to measure ad effectiveness. The media company's legal team insists that no raw viewer data can leave their environment. Can this be done with regular Secure Data Sharing?
**Resposta:** No. Secure Data Sharing would give the advertising agency direct read access to the media company's data, which violates their legal requirement. A Data Clean Room is the correct solution. In a Clean Room, both parties contribute their data but neither sees the other's raw records. Only pre-approved analyses (like audience overlap counts or aggregate conversion metrics) produce results — the raw viewer data never leaves the media company's control.

**Cenário:** A pharmaceutical company and a hospital network want to jointly analyze patient outcomes for a drug trial. Regulations require that individual patient records are never exposed to the pharmaceutical company. How does a Data Clean Room help compared to just sharing the data?
**Resposta:** In regular Secure Data Sharing, the pharmaceutical company would gain read access to the hospital's patient data — violating privacy regulations. A Data Clean Room ensures that the hospital's raw patient records are never visible to the pharmaceutical company. Both parties load their respective data, and only approved aggregate analyses (e.g., average recovery time, outcome distributions by age group) are computed and shared. Individual patient-level data remains private to each party throughout the process.

---

---

## REVISÃO RÁPIDA — Domínio 5

1. Compartilhamento de dados = nenhum dado copiado, acesso em tempo real, zero custo de movimentação
2. Provider paga armazenamento. Consumer paga computação (warehouse próprio).
3. Apenas ACCOUNTADMIN cria Shares
4. Apenas Secure Views podem ser compartilhadas (não views regulares)
5. Reader Account = para consumers sem Snowflake. Provider paga tudo.
6. Compartilhamento cross-region requer replicação primeiro
7. Failover = apenas Business Critical+
8. Marketplace: listagens públicas (qualquer um) vs listagens privadas (apenas convidados)
9. Native Apps = aplicações completas, rodam na conta do consumer
10. Clone = zero-copy, instantâneo, sem custo de armazenamento até modificação
11. Clone NÃO inclui histórico de Time Travel
12. Time Travel: 1 dia Standard, até 90 dias Enterprise+ (tabelas permanent)
13. Tabelas Transient/Temporary: máximo 1 dia de Time Travel independente da edição
14. UNDROP = recuperar dentro do período de Time Travel
15. Fail-safe: 7 dias, apenas tabelas permanent, gerenciado pelo Snowflake (não pode acessar diretamente)
16. DATA_RETENTION_TIME_IN_DAYS = 0 desabilita Time Travel
17. Consumer vê atualizações do Provider imediatamente
18. Sem limite de Reader Accounts por Provider

---

## PARES CONFUSOS — Domínio 5

| Perguntam sobre... | A resposta é... | NÃO... |
|---|---|---|
| Quem paga queries de dados compartilhados | Consumer (warehouse próprio) | Provider |
| Quem paga pela Reader Account | Provider (tudo) | Consumer |
| Compartilhar uma view | Deve ser Secure View | View regular funciona |
| Quem cria Share | ACCOUNTADMIN | SYSADMIN |
| Compartilhamento cross-region precisa | Replicação primeiro | Compartilhamento direto |
| Fail-safe para transient | NENHUM | 7 dias |
| Acesso ao Fail-safe | Apenas suporte Snowflake | Consulta direta |
| Time Travel máximo (transient) | 1 dia | 90 dias |
| Time Travel máximo (permanent, Enterprise) | 90 dias | 1 dia |
| Custo de armazenamento do clone | Zero até modificado | Custo de cópia completa |
| Histórico de Time Travel do clone | NÃO incluído | Incluído |
| Listagem pública Marketplace | Qualquer um pode ver | Apenas convidados |
| Listagem privada Marketplace | Apenas contas convidadas | Público |
| Edição para failover | Business Critical+ | Enterprise |
| UNDROP funciona durante | Período de Time Travel | Fail-safe |
| Banco de dados secundário | Somente leitura | Leitura-escrita |

---

## RESUMO AMIGÁVEL — Domínio 5

### ÁRVORES DE DECISÃO DE CENÁRIOS
Quando ler uma questão, encontre o padrão:

**"Uma empresa farmacêutica quer compartilhar resultados de ensaios clínicos com um hospital parceiro que também usa Snowflake..."**
→ Compartilhamento Direto (Provider cria SHARE, Consumer cria database FROM SHARE)
→ Nenhum dado copiado, acesso em tempo real, zero custo de armazenamento para compartilhamento

**"Uma startup quer compartilhar dados com um pequeno fornecedor que NÃO tem conta Snowflake..."**
→ Reader Account (Provider cria, Provider paga TUDO)
→ Consumer recebe acesso limitado somente leitura

**"Quem paga quando um consumer consulta dados compartilhados?"**
→ CONSUMER paga (usa warehouse próprio)
→ Provider não paga NADA pelas queries do consumer

**"Quem paga quando um usuário de Reader Account consulta dados compartilhados?"**
→ PROVIDER paga (Reader Account = Provider paga tudo — computação + armazenamento)

**"Uma empresa global em AWS US-West precisa compartilhar dados com sua equipe em Azure Europe..."**
→ Passo 1: Replicar o banco de dados para a outra região/nuvem PRIMEIRO
→ Passo 2: Depois criar um Share naquela região
→ Não pode compartilhar diretamente entre regiões sem replicação

**"A região primária de uma empresa cai. Como eles continuam operando?"**
→ Failover: promover banco de dados/conta secundário para primário (Business Critical+)
→ NÃO apenas replicação (replicação copia dados, failover troca o ativo)

**"O provider atualiza uma tabela compartilhada. Quando o consumer vê a mudança?"**
→ IMEDIATAMENTE (sem atraso, sem refresh necessário — são os mesmos dados)

**"Um cliente quer compartilhar uma view com outra conta..."**
→ Deve ser uma SECURE VIEW (views regulares NÃO podem ser compartilhadas)
→ Também funciona: Secure UDFs, Secure Materialized Views

**"Um provedor de dados quer listar seus dados meteorológicos para qualquer cliente Snowflake descobrir..."**
→ Listagem Pública no Marketplace (visível para todas as contas Snowflake)

**"Dois bancos concorrentes querem encontrar sobreposição de clientes sem revelar suas listas completas..."**
→ Data Clean Room (análise multi-parte, dados brutos permanecem privados)

**"Um fornecedor de software quer distribuir um app de analytics que roda dentro da conta Snowflake do cliente..."**
→ Native App (Provider constrói Application Package, Consumer instala)
→ App roda na conta do Consumer, dados permanecem privados

**"Uma equipe precisa criar uma cópia de produção para testes, sem dobrar custos de armazenamento..."**
→ Clone (CREATE ... CLONE — zero-copy, instantâneo, sem armazenamento extra até mudanças)

**"Um clone inclui o histórico de Time Travel da tabela original?"**
→ NÃO. Clone começa do zero. Sem snapshots históricos da origem.

**"Um desenvolvedor acidentalmente descartou uma tabela 2 horas atrás..."**
→ UNDROP TABLE (dentro do período de retenção de Time Travel)
→ Se passou do Time Travel → pode estar no Fail-safe (contate suporte Snowflake)

**"Pode consultar dados do Fail-safe diretamente?"**
→ NÃO. Apenas suporte Snowflake pode recuperar dados do Fail-safe. Você não pode acessar sozinho.

**"Uma tabela transient foi descartada. Fail-safe pode recuperá-la?"**
→ NÃO. Tabelas Transient e Temporary NÃO têm Fail-safe.

**"Uma conta Enterprise quer Time Travel de 90 dias em uma tabela transient..."**
→ IMPOSSÍVEL. Tabelas Transient/Temporary têm máximo de 1 dia independente da edição.

**"Um consumer recebe um share e quer modificar os dados recebidos..."**
→ NÃO PODE modificar dados compartilhados diretamente (somente leitura)
→ Deve CREATE TABLE ... AS SELECT da view/tabela compartilhada para obter uma cópia local que ele possui

**"Um cliente clona um banco de dados inteiro. As tabelas filhas mantêm seus privilégios?"**
→ SIM. Ao clonar um DATABASE ou SCHEMA, objetos filhos herdam privilégios da origem.
→ Mas clonar uma TABELA INDIVIDUAL → privilégios NÃO são copiados.

**"Um cliente quer clonar uma tabela como era 3 dias atrás..."**
→ CREATE TABLE clone_name CLONE source AT(TIMESTAMP => '2024-01-01 12:00:00')
→ Combina Clone + Time Travel em um comando

**"Um cliente quer saber o custo total de armazenamento de uma tabela incluindo Time Travel e Fail-safe..."**
→ TABLE_STORAGE_METRICS (ACCOUNT_USAGE)
→ Mostra: active bytes + time travel bytes + fail-safe bytes

**"Um provider quer compartilhar dados com 50 contas Snowflake diferentes..."**
→ Um Share pode ter múltiplos consumers (um-para-muitos)
→ Ou use listagem no Marketplace para distribuição mais ampla

**"Um consumer recompartilha dados que recebeu de um provider para um terceiro..."**
→ Recompartilhamento é possível SE o provider permitir
→ Cria uma cadeia de compartilhamento

**"Um cliente pergunta: quais objetos NÃO podem ser clonados?"**
→ Tabelas externas e stages internos (user/table) NÃO podem ser clonados
→ Named stages PODEM ser clonados

**"O banco de dados secundário de um cliente não foi atualizado em 48 horas. Os dados estão atuais?"**
→ NÃO. Bancos de dados secundários devem ser explicitamente atualizados para sincronizar.
→ Eles não fazem auto-refresh (diferente de Dynamic Tables)

**"Um provider constrói um Native App que inclui uma UI Streamlit e stored procedures..."**
→ Tudo empacotado em um Application Package
→ Consumer instala → app roda na conta do Consumer
→ Provider pode enviar atualizações (versionamento)

**"Um cliente quer consultar dados exatamente como eram antes de uma instrução DELETE específica ser executada..."**
→ BEFORE(STATEMENT => 'query_id')
→ NÃO AT (AT dá dados no momento, BEFORE dá dados logo antes da instrução)

**"Um cliente define DATA_RETENTION_TIME_IN_DAYS = 0 em uma tabela. O que acontece?"**
→ Time Travel é DESABILITADO para aquela tabela
→ Sem UNDROP, sem queries AT/BEFORE, sem acesso histórico
→ Fail-safe ainda se aplica (se tabela permanent)

---

### MNEMÔNICOS PARA FIXAR

**Cobrança de compartilhamento = "Provider Armazena, Consumer Computa"**
- Provider paga pelo armazenamento (ele é dono dos dados)
- Consumer paga pela computação (executa queries com seu warehouse)
- EXCEÇÃO: Reader Account → Provider paga AMBOS

**Criação de Share = "Só o Chefe"**
- Apenas ACCOUNTADMIN pode criar objetos Share
- NÃO SYSADMIN, NÃO SECURITYADMIN

**O que pode ser compartilhado = "Apenas Secure"** → tabelas + secure views/UDFs/MVs
- Views regulares → NÃO
- Stages, Pipes, Tasks → NÃO

**Retenção de Time Travel = regra "1-90-1"**
- Edição Standard: máximo 1 dia (todos os tipos de tabela)
- Enterprise+: até 90 dias (apenas tabelas permanent)
- Transient/Temporary: máximo 1 dia (QUALQUER edição)

**Ciclo de vida dos dados = "A-T-F-P" → "Ativo, Travel, Failsafe, Purgado"**
- **A**tivo → atual
- **T**ime Travel → 1-90 dias (você pode consultar/UNDROP)
- **F**ail-safe → 7 dias (apenas suporte Snowflake, apenas tabelas permanent)
- **P**urgado → permanentemente deletado

**Clone = "Copie o Ponteiro, Não os Dados"**
- Instantâneo, zero custo de armazenamento
- Independente após criação
- Sem histórico de Time Travel da origem

**Edição para failover = "BC+" (Business Critical e acima)**
- Replicação = qualquer edição
- Failover = apenas BC+

**Marketplace = "Público vs Privado"**
- Listagem pública → todo mundo vê
- Listagem privada → apenas por convite

---

### ARMADILHAS PRINCIPAIS — Domínio 5

1. **"Consumer paga pelo armazenamento de dados compartilhados"** → ERRADO. Provider paga armazenamento. Consumer paga computação.
2. **"Reader Account: consumer paga"** → ERRADO. Provider paga TUDO para Reader Accounts.
3. **"SYSADMIN pode criar Shares"** → ERRADO. Apenas ACCOUNTADMIN.
4. **"Views regulares podem ser compartilhadas"** → ERRADO. Devem ser Secure Views.
5. **"Compartilhamento direto funciona cross-region"** → ERRADO. Precisa replicação primeiro.
6. **"Atualizações do Provider são atrasadas para consumers"** → ERRADO. Visibilidade imediata.
7. **"Clone dobra armazenamento"** → ERRADO. Zero custo até dados serem modificados.
8. **"Clone inclui histórico de Time Travel"** → ERRADO. Clone começa do zero.
9. **"Tabelas transient têm Fail-safe"** → ERRADO. Sem Fail-safe (apenas tabelas permanent).
10. **"Você pode consultar dados do Fail-safe"** → ERRADO. Apenas suporte Snowflake.
11. **"Tabela transient + Enterprise = Time Travel de 90 dias"** → ERRADO. Máximo 1 dia independente.
12. **"Failover funciona na edição Standard"** → ERRADO. Apenas Business Critical+.

---

### ATALHOS DE PADRÃO — "Se você vir ___, a resposta é ___"

| Se a questão menciona... | A resposta quase sempre é... |
|---|---|
| "compartilhar dados, sem cópia" | Secure Data Sharing |
| "consumer não tem conta SF" | Reader Account |
| "quem paga computação de dados compartilhados" | Consumer (warehouse próprio) |
| "quem paga pela Reader Account" | Provider (tudo) |
| "quem cria objeto Share" | Apenas ACCOUNTADMIN |
| "compartilhar uma view" | Deve ser Secure View |
| "compartilhamento cross-region" | Replicar primeiro, depois compartilhar |
| "região primária está fora" | Failover (BC+) |
| "banco de dados secundário é..." | Somente leitura (até promovido) |
| "provider atualiza, consumer vê quando" | Imediatamente |
| "zero-copy, cópia instantânea" | CLONE |
| "custo de armazenamento do clone" | Zero até modificado |
| "histórico de Time Travel do clone" | NÃO incluído |
| "recuperar tabela descartada" | UNDROP (dentro do período de Time Travel) |
| "recuperar após Time Travel expirar" | Fail-safe (suporte Snowflake, apenas permanent) |
| "7 dias após Time Travel" | Período de Fail-safe |
| "DATA_RETENTION_TIME_IN_DAYS = 0" | Desabilita Time Travel |
| "Time Travel máximo tabela transient" | 1 dia (qualquer edição) |
| "Time Travel máximo permanent, Enterprise" | 90 dias |
| "produtos de dados marketplace" | Snowflake Marketplace |
| "listagem pública" | Qualquer um pode descobrir |
| "listagem privada" | Apenas contas convidadas |
| "app roda na conta do consumer" | Native App |
| "análise multi-parte, dados privados" | Data Clean Room |
| "Application Package" | Native App Framework |

---

## DICAS PARA O DIA DO EXAME — Domínio 5 (10% = ~10 questões)

**Antes de estudar este domínio:**
- Menor domínio mas PONTOS FÁCEIS — não pule
- Flashcard: quem paga o quê no compartilhamento (Provider armazena, Consumer computa, Reader = Provider paga tudo)
- Flashcard: regras de retenção de Time Travel (1-90-1: Standard=1 dia, Enterprise+=90 dias permanent, Transient=1 dia sempre)
- Conheça comportamento do Clone: zero-copy, sem histórico TT, privilégios diferem (clone de database = sim, clone de tabela = não)

**Durante o exame — questões do Domínio 5:**
- Leia a ÚLTIMA sentença primeiro — depois leia o cenário
- Elimine 2 respostas obviamente erradas imediatamente
- Se perguntam QUEM PAGA → Provider armazena, Consumer computa. EXCEÇÃO: Reader Account = Provider paga tudo.
- Se perguntam sobre COMPARTILHAR UMA VIEW → deve ser Secure View (views regulares não podem ser compartilhadas)
- Se perguntam sobre CROSS-REGION → replicação primeiro, depois compartilhar
- Se perguntam sobre RECUPERAÇÃO → Janela Time Travel = UNDROP. Após TT = Fail-safe (apenas suporte SF). Após ambos = perdido.
- Se mencionam CLONE → zero armazenamento, instantâneo, independente, SEM histórico de Time Travel da origem

---

## UMA LINHA POR TÓPICO — Domínio 5

| Tópico | Resumo em uma linha |
|---|---|
| Replicação de Database | Primário (leitura-escrita) → Secundário (somente leitura). Cross-region/cloud. Qualquer edição. |
| Replicação de Conta | Replicar usuários, roles, warehouses para recuperação de desastres. |
| Failover | Promover secundário para primário quando primário está fora. Apenas BC+. |
| Secure Data Sharing | Sem cópia, tempo real, zero custo de movimentação. Provider → Consumer. |
| Objeto Share | Criado apenas por ACCOUNTADMIN. GRANT de objetos TO SHARE. |
| Cobrança do Provider | Paga por armazenamento. NÃO paga pelas queries do consumer. |
| Cobrança do Consumer | Paga por computação (usa warehouse próprio). NÃO paga por armazenamento. |
| Reader Accounts | Para consumers sem conta SF. Provider paga TUDO. Somente leitura limitada. |
| Objetos compartilháveis | Tabelas, Secure Views, Secure UDFs, Secure MVs. NÃO: views regulares, stages, pipes. |
| Compartilhamento cross-region | Replicar banco de dados primeiro → depois criar Share naquela região. |
| Marketplace | Listagens públicas (qualquer um) vs listagens privadas (apenas convidados). |
| Data Exchange | Hub privado para grupo controlado. Provider decide quem participa. |
| Native Apps | Application Package → Consumer instala → roda na conta do Consumer. UI Streamlit + código. |
| Data Clean Rooms | Análise multi-parte, dados brutos de cada parte permanecem privados. |
| Clonagem | Zero-copy, instantâneo, independente. Sem histórico TT. Clone de DB/schema mantém privilégios. |
| Time Travel | AT(TIMESTAMP/OFFSET/STATEMENT), BEFORE(STATEMENT). 1-90 dias dependendo de edição+tipo de tabela. |
| UNDROP | Recuperar tabela/schema/database descartado dentro da retenção de Time Travel. |
| Fail-safe | 7 dias após TT expirar. Apenas tabelas permanent. Apenas suporte Snowflake. |
| DATA_RETENTION_TIME_IN_DAYS | Definido no nível de conta/database/schema/tabela. 0 = desabilita TT. |
| AT vs BEFORE | AT = dados naquele momento. BEFORE = dados logo antes de uma instrução ser executada. |
| Clone + Time Travel | Pode clonar em ponto passado: CLONE source AT(TIMESTAMP => '...'). |
| Privilégios do clone | Clone de database/schema = privilégios filhos mantidos. Clone de tabela individual = SEM privilégios. |
| Recompartilhamento | Consumer pode recompartilhar se Provider permitir. Cria cadeia de compartilhamento. |

---

## FLASHCARDS — Domínio 5

**P:** O que é Secure Data Sharing?
**R:** Compartilhamento de dados ao vivo entre contas Snowflake com zero cópia e zero movimentação de dados. Provider cria um objeto SHARE, consumer cria um banco de dados FROM SHARE. Dados ficam no armazenamento do provider.

**P:** Quem paga o quê no compartilhamento de dados?
**R:** Provider paga por armazenamento. Consumer paga por computação (warehouse próprio). Sem custos de transferência de dados dentro da mesma região.

**P:** Quem pode criar um objeto SHARE?
**R:** Apenas ACCOUNTADMIN pode criar shares e conceder objetos a eles.

**P:** Quais objetos PODEM ser compartilhados?
**R:** Tabelas, secure views, secure materialized views, secure UDFs. Devem ser variantes SECURE para views/UDFs.

**P:** Quais objetos NÃO PODEM ser compartilhados?
**R:** Views regulares (não seguras), stages, pipes, tasks, streams, sequences, file formats.

**P:** O que é uma Reader Account?
**R:** Uma conta Snowflake criada PELO provider PARA consumers que não têm sua própria conta Snowflake. Provider paga por TUDO (armazenamento + computação). Reader accounts são somente leitura e limitadas.

**P:** Como funciona compartilhamento cross-region?
**R:** Você deve primeiro replicar o banco de dados para a região de destino, depois criar um share naquela região. Compartilhamento direto cross-region não é possível sem replicação.

**P:** Qual é a diferença entre Marketplace e Data Exchange?
**R:** Marketplace: listagens públicas ou privadas visíveis para todos os clientes Snowflake. Data Exchange: hub privado onde o provider controla exatamente quem pode participar e acessar dados.

**P:** O que é um Native App?
**R:** Uma aplicação instalável construída com um Application Package. Consumer instala na sua própria conta. Pode incluir UI Streamlit, stored procedures e lógica. Código roda na conta do consumer.

**P:** O que é um Data Clean Room?
**R:** Um ambiente seguro para análise de dados multi-parte onde os dados brutos de cada parte permanecem privados. Apenas resultados agregados acordados são compartilhados.

**P:** O que significa zero-copy cloning?
**R:** CLONE cria uma cópia instantânea e independente que inicialmente aponta para as mesmas micro-partitions. Nenhum dado é fisicamente copiado até um lado modificar dados. É gratuito na criação.

**P:** Um clone herda histórico de Time Travel?
**R:** Não. Um clone começa do zero — não tem histórico de Time Travel da origem. TT começa a partir do momento da clonagem.

**P:** Quais privilégios um clone recebe?
**R:** Clone de database/schema: privilégios de objetos filhos são copiados. Clone de tabela individual: NENHUM privilégio é copiado.

**P:** O que é Time Travel?
**R:** Capacidade de consultar dados históricos usando cláusulas AT ou BEFORE. Período de retenção: 0-1 dia (Standard), 0-90 dias (Enterprise+). Definido via DATA_RETENTION_TIME_IN_DAYS.

**P:** AT vs BEFORE — qual é a diferença?
**R:** AT(TIMESTAMP => X) = dados como existiam naquele momento exato. BEFORE(STATEMENT => 'query_id') = dados logo antes daquela instrução ser executada.

**P:** O que é UNDROP?
**R:** Recupera uma tabela, schema ou banco de dados descartado — mas apenas dentro do período de retenção de Time Travel. Depois disso, o objeto vai para Fail-safe.

**P:** O que é Fail-safe?
**R:** 7 dias adicionais de proteção de dados APÓS Time Travel expirar. Apenas para tabelas permanent. Apenas suporte Snowflake pode recuperar dados — você não pode acessar sozinho.

**P:** Quais tipos de tabela têm Fail-safe?
**R:** Apenas tabelas permanent. Tabelas transient e temporary têm ZERO Fail-safe.

**P:** Pode clonar para um ponto passado no tempo?
**R:** Sim. `CREATE TABLE clone_t CLONE source AT(TIMESTAMP => '2024-01-01')` cria um clone da origem como era naquele timestamp.

**P:** O que é Replicação de Banco de Dados?
**R:** Copiar um banco de dados para outra conta Snowflake (mesma ou diferente região/nuvem). Usado para recuperação de desastres (failover) e compartilhamento de dados cross-region. Primário → secundário → pode promover secundário.

---

## EXPLIQUE COMO SE EU TIVESSE 5 ANOS — Domínio 5

**Secure Data Sharing**: Você deixa seu amigo olhar seu brinquedo pela janela — ele pode ver e brincar com ele, mas você nunca entrega. Sem cópia, sem envio.

**Reader Account**: Seu amigo não tem conta Snowflake, então você cria uma mini-conta para ele e paga as contas dele também. Ele só pode olhar, não construir.

**Objeto SHARE**: Uma caixa especial onde você coloca as coisas que quer compartilhar. Só o chefe (ACCOUNTADMIN) pode fazer a caixa.

**Secure view**: Uma janela que mostra apenas certos brinquedos da sua coleção — esconde os que você não quer que outros vejam. Deve ser "segura" para compartilhar.

**Marketplace**: Uma loja onde qualquer um pode navegar por listagens de dados. Alguns são grátis, outros custam dinheiro. Como uma loja de apps para dados.

**Data Exchange**: Um clube privado — apenas pessoas que você convida podem ver e usar os dados. Não é aberto ao público.

**Native App**: Um app completo que você constrói e dá para alguém instalar NA CASA DELE. Roda na eletricidade (computação) dele, não na sua.

**Data Clean Room**: Duas crianças querem comparar coleções de brinquedos sem mostrar tudo uma para a outra. Usam uma sala mágica que só diz "vocês dois têm 5 brinquedos iguais" sem revelar quais.

**Zero-copy clone**: Fazer uma fotocópia que é na verdade mágica — parece real, não pesa nada e não custa nada. Só começa a custar quando alguém desenha na sua cópia.

**Time Travel**: Uma máquina do tempo para seus dados. Volte e veja como sua tabela era ontem, ou logo antes de alguém acidentalmente deletar tudo.

**UNDROP**: Um botão de "desfazer exclusão". Descartou uma tabela? Diga UNDROP e ela volta — mas apenas se você ainda estiver dentro da janela de Time Travel.

**Fail-safe**: Depois que sua máquina do tempo expira, Snowflake mantém um backup secreto por mais 7 dias em um cofre que só eles podem abrir. Apenas para uso de emergência.

**AT vs BEFORE**: AT = "me mostra a foto tirada às 15h." BEFORE = "me mostra a foto tirada logo antes do acidente acontecer."

**Replicação de Banco de Dados**: Fazer uma cópia de backup ao vivo do seu banco de dados inteiro em outra cidade. Se a primeira cidade tiver um desastre, você muda para a cópia.

**Recompartilhamento**: Seu amigo compartilha seus brinquedos com o amigo DELE. Só permitido se você disser que está OK. Cria uma cadeia de compartilhamento.

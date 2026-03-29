# Domínio 1: Estratégia de Conta e Segurança

> **Cobertura do Programa ARA-C01:** Estratégia de Conta/DB, Segurança/Privacidade/Conformidade, Princípios de Segurança

---

## 1.1 ESTRATÉGIA DE CONTA

**Arquitetura de Conta Única vs Multi-Conta**

- **Conta única:** mais simples, todos os ambientes (dev/staging/prod) compartilham uma conta
  - Mais barato, menos overhead
  - Risco: raio de explosão é a conta inteira (um GRANT ruim afeta tudo)
- **Multi-conta:** contas separadas por ambiente, unidade de negócio ou região
  - Isolamento mais forte, políticas de segurança independentes, cobrança separada
  - Necessário para conformidade estrita (ex: dados PCI em sua própria conta)
- **Snowflake Organizations:** contêiner pai que agrupa múltiplas contas
  - Habilita replicação cross-account, failover groups e cobrança centralizada
  - Role ORGADMIN gerencia contas dentro da org
  - Criação de conta via `CREATE ACCOUNT` (apenas ORGADMIN)

**Padrões de Segmentação**

- **Por ambiente:** contas dev / staging / prod
- **Por região:** contas em diferentes regiões de nuvem para residência de dados
- **Por unidade de negócio:** finanças, marketing, engenharia cada uma com a sua
- **Por conformidade:** conta com escopo PCI, conta com escopo HIPAA

### Por Que Isso Importa
Uma empresa de saúde precisa de dados HIPAA isolados de analytics de marketing. Multi-conta com replicação no nível de org permite compartilhar dados não-PHI entre contas enquanto mantém PHI protegido.

### Melhores Práticas
- Use Organizations para gerenciar centralmente contas e cobrança
- Replique objetos de segurança (network policies, RBAC) via replicação de conta
- Mantenha contas de produção em edição Business Critical ou superior para conformidade

**Armadilha do exame:** SE VOCÊ VER "use uma conta única com bancos de dados separados para isolamento PCI" → ERRADO porque PCI requer isolamento no nível de conta, não apenas no nível de banco de dados.

**Armadilha do exame:** SE VOCÊ VER "ACCOUNTADMIN pode criar novas contas" → ERRADO porque apenas ORGADMIN pode criar contas dentro de uma Organization.

**Armadilha do exame:** SE VOCÊ VER "Organizations requerem edição Enterprise" → ERRADO porque Organizations estão disponíveis em todas as edições.

### Perguntas Frequentes (FAQ)
**P: Posso compartilhar dados entre contas sem Organizations?**
R: Sim, via Secure Data Sharing (listings), mas Organizations adicionam replicação, failover e gerenciamento centralizado.

**P: Cada conta em uma org recebe cobrança separada?**
R: Por padrão a cobrança é consolidada no nível da org, mas você pode visualizar uso por conta.

### Exemplos de Perguntas de Cenário — Estratégia de Conta

**Cenário:** Uma seguradora global opera na UE, EUA e APAC. As regulamentações da UE exigem que os dados de clientes da UE nunca saiam do solo europeu. A equipe dos EUA precisa de acesso a métricas agregadas (não-PII) de todas as regiões para dashboards globais. Como o arquiteto deve projetar a topologia de contas Snowflake?
**Resposta:** Implante contas Snowflake separadas por região (UE, EUA, APAC) dentro de uma única Snowflake Organization. Cada conta regional armazena seus próprios dados de clientes em uma região de nuvem que satisfaça os requisitos de residência de dados. Use replicação de banco de dados para replicar datasets agregados não-PII das contas UE e APAC para a conta dos EUA para dashboards globais. ORGADMIN gerencia a criação de contas e cobrança centralizada. Isso garante que os dados da UE nunca saiam da conta da UE enquanto habilita analytics cross-region em agregações seguras.

**Cenário:** Uma fintech startup está crescendo de 10 para 500 funcionários e atualmente usa uma única conta Snowflake para dev, staging e produção. Um estagiário acidentalmente executou `GRANT ALL ON DATABASE prod_db TO ROLE PUBLIC` em produção. Qual mudança arquitetural previne essa classe de incidente?
**Resposta:** Migre para uma arquitetura multi-conta com contas separadas para dev, staging e produção dentro de uma Snowflake Organization. Isso fornece isolamento de raio de explosão no nível de conta — um GRANT mal configurado em dev não pode afetar produção. Adicionalmente, use managed access schemas na conta de produção para que apenas o dono do schema (ou detentor de MANAGE GRANTS) possa emitir grants, prevenindo escalação de privilégios por donos individuais de objetos. Replique objetos de segurança entre contas usando replicação de conta para RBAC consistente.

---

## 1.2 HIERARQUIA DE PARÂMETROS

**Três Níveis (de cima para baixo):**

1. **Account** — definido por ACCOUNTADMIN, aplica-se globalmente
2. **Object** — definido em warehouse, banco de dados, schema, tabela, usuário
3. **Session** — definido pelo usuário para sua sessão atual (`ALTER SESSION`)

**Regra de Precedência:** O mais específico vence. Session > Object > Account.

**Parâmetros-Chave que Você Precisa Conhecer:**

| Parâmetro | Nível Típico | Notas |
|---|---|---|
| `STATEMENT_TIMEOUT_IN_SECONDS` | Account / Session | Encerra queries longas |
| `DATA_RETENTION_TIME_IN_DAYS` | Account / Object | Janela de Time Travel (0-90) |
| `MIN_DATA_RETENTION_TIME_IN_DAYS` | Apenas Account | Piso que objetos não podem ficar abaixo |
| `NETWORK_POLICY` | Account / User | Nível de usuário sobrescreve nível de conta |
| `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` | Account | Endurecimento de segurança |

### Por Que Isso Importa
Um DBA define timeout no nível de conta para 1 hora. Um cientista de dados define timeout de sessão para 4 horas para um job grande de ML. O nível de sessão vence para esse usuário.

### Melhores Práticas
- Defina `MIN_DATA_RETENTION_TIME_IN_DAYS` no nível de conta para impedir que usuários definam Time Travel para 0
- Use `STATEMENT_TIMEOUT_IN_SECONDS` em warehouses para prevenir queries descontroladas
- Documente quais parâmetros são definidos em qual nível

**Armadilha do exame:** SE VOCÊ VER "parâmetro de conta sempre sobrescreve parâmetro de sessão" → ERRADO porque sessão é mais específico e vence.

**Armadilha do exame:** SE VOCÊ VER "MIN_DATA_RETENTION_TIME_IN_DAYS pode ser definido em um schema" → ERRADO porque é apenas no nível de conta.

**Armadilha do exame:** SE VOCÊ VER "uma network policy no nível de usuário é aditiva à de nível de conta" → ERRADO porque a network policy no nível de usuário **substitui** a política no nível de conta para aquele usuário.

### Perguntas Frequentes (FAQ)
**P: Se eu definir DATA_RETENTION_TIME_IN_DAYS = 1 em uma tabela mas o MIN da conta é 7, qual vence?**
R: O MIN vence — a tabela recebe 7 dias. MIN define um piso.

**P: Um não-ACCOUNTADMIN pode definir parâmetros de conta?**
R: Não. Apenas ACCOUNTADMIN (ou roles com o privilégio concedido) pode definir parâmetros no nível de conta.


### Exemplos de Perguntas de Cenário — Parameter Hierarchy

**Cenário:** A data engineering team runs large Spark-based ETL jobs that can take up to 6 hours. The account-level `STATEMENT_TIMEOUT_IN_SECONDS` is set to 3600 (1 hour) to protect against runaway queries. The ETL jobs keep getting killed. The team asks the architect to raise the account timeout to 24 hours. What is the correct approach?
**Resposta:** Do not raise the account-level timeout — that would expose all users to potential 24-hour runaway queries. Instead, set `STATEMENT_TIMEOUT_IN_SECONDS` at the object level on the dedicated ETL warehouse to 21600 (6 hours). Session-level and object-level parameters override the account default for that specific context. This way, BI users on other warehouses still get the 1-hour safety net while ETL has the headroom it needs.

**Cenário:** A compliance officer discovers that a developer set `DATA_RETENTION_TIME_IN_DAYS = 0` on several staging tables, meaning accidental deletes cannot be recovered via Time Travel. How should the architect prevent this from happening again across the entire account?
**Resposta:** Set `MIN_DATA_RETENTION_TIME_IN_DAYS` at the account level (e.g., to 1 or 7 days). This parameter is account-level only and establishes a floor that no individual database, schema, or table can go below. Even if a developer sets `DATA_RETENTION_TIME_IN_DAYS = 0` on a table, the MIN floor overrides it, ensuring Time Travel is always available for at least the minimum period.

---

---

## 1.3 CONTROLE DE ACESSO BASEADO EM ROLES

**Conceitos Fundamentais**

- Snowflake usa **Role-Based Access Control (RBAC)** — privilégios são concedidos a roles, roles são concedidas a usuários
- Roles formam uma hierarquia: privilégios de role filho fluem PARA CIMA para roles pai
- **Roles definidas pelo sistema:** ORGADMIN > ACCOUNTADMIN > SECURITYADMIN > SYSADMIN > USERADMIN > PUBLIC

**Herança de Privilégios**

- Se Role A é concedida a Role B, então Role B herda TODOS os privilégios da Role A
- ACCOUNTADMIN deve herdar de tanto SECURITYADMIN quanto SYSADMIN
- Nunca use ACCOUNTADMIN para trabalho diário

**Database Roles**

- Com escopo para um único banco de dados (portável com o banco de dados durante replicação/clonagem)
- Concedidas a roles no nível de conta ou outras database roles
- Ideal para compartilhamento: consumidores recebem database roles, não account roles

**Padrão de Roles Funcionais vs de Acesso**

- **Roles de acesso:** detêm privilégios de objeto (ex: `ANALYST_READ` tem SELECT em tabelas)
- **Roles funcionais:** representam funções de trabalho, herdam de roles de acesso (ex: `DATA_ANALYST` herda `ANALYST_READ` + `DASHBOARD_WRITE`)
- Este modelo de duas camadas simplifica o gerenciamento em escala

**Secondary Roles**

- `USE SECONDARY ROLES ALL` — usuário obtém união de privilégios de todas as roles concedidas
- Evita troca constante de role
- Role secundária padrão pode ser definida no objeto do usuário

### Por Que Isso Importa
Uma equipe de analytics de 500 pessoas precisa de acesso granular. Roles funcionais (Data Analyst, Data Engineer) herdam de roles de acesso refinadas. Novo contratado? Conceda uma role funcional. Pronto.

### Melhores Práticas
- Nunca conceda privilégios diretamente a usuários — sempre use roles
- SYSADMIN deve possuir todos os bancos de dados/warehouses (ou roles customizadas concedidas a SYSADMIN)
- Use database roles para objetos compartilhados via Secure Sharing
- Separe SECURITYADMIN (gerencia grants) de SYSADMIN (gerencia objetos)

**Armadilha do exame:** SE VOCÊ VER "ACCOUNTADMIN deve ser a role padrão para admins" → ERRADO porque ACCOUNTADMIN é apenas para emergências; trabalho diário deve usar roles inferiores.

**Armadilha do exame:** SE VOCÊ VER "database roles podem ser concedidas diretamente a usuários" → ERRADO porque database roles devem ser concedidas a roles no nível de conta primeiro (ou outras database roles).

**Armadilha do exame:** SE VOCÊ VER "herança de privilégios flui para baixo" → ERRADO porque flui PARA CIMA na hierarquia de roles.

### Perguntas Frequentes (FAQ)
**P: Qual é a diferença entre SECURITYADMIN e USERADMIN?**
R: USERADMIN gerencia usuários e roles. SECURITYADMIN herda USERADMIN e também pode gerenciar grants (GRANT/REVOKE).

**P: Posso usar secondary roles com Secure Sharing?**
R: Não. Shares usam a database role designada do share; secondary roles não se aplicam no contexto de compartilhamento.


### Exemplos de Perguntas de Cenário — Role-Based Access Control

**Cenário:** A 2,000-person enterprise has 15 departments, each with analysts, engineers, and managers. New hires join weekly. Currently, each new hire requires 10+ individual GRANT statements. The security team wants a scalable model. What RBAC pattern should the architect implement?
**Resposta:** Implement the functional-role / access-role pattern. Create fine-grained access roles that hold object-level privileges (e.g., `SALES_READ`, `SALES_WRITE`, `MARKETING_READ`). Then create functional roles representing job functions (e.g., `SALES_ANALYST`, `SALES_ENGINEER`, `MARKETING_MANAGER`) that inherit from the appropriate access roles. When a new hire joins, grant them a single functional role. All access roles should be granted to SYSADMIN for hierarchy completeness. This reduces onboarding to one GRANT per new user and simplifies auditing.

**Cenário:** A data marketplace team shares curated datasets to external consumers via Secure Data Sharing. They need consumers to have SELECT on specific views without exposing account-level role structures. What role type should the architect use?
**Resposta:** Use database roles. Database roles are scoped to a single database and are portable with the database during sharing. Grant SELECT on the secure views to database roles within the shared database, then assign those database roles to the share. Consumers receive the database roles without visibility into the provider's account-level role hierarchy. This also ensures that if the database is replicated or cloned, the database roles travel with it.

**Cenário:** Multiple analysts complain about constantly switching roles to access tables in different databases. Each analyst has 4-5 roles granted. How should the architect solve this without restructuring the entire RBAC model?
**Resposta:** Enable secondary roles by having analysts run `USE SECONDARY ROLES ALL` at session start (or set a default secondary role on the user object). This gives users the union of privileges from all their granted roles simultaneously, eliminating constant `USE ROLE` switching. This is a session-level change and does not affect the underlying RBAC model or security posture.

---

---

## 1.4 SEGURANÇA DE REDE

**Network Policies**

- Listas de IP permitidos/bloqueados aplicadas no nível de conta ou usuário
- Use `ALLOWED_IP_LIST` e `BLOCKED_IP_LIST`
- Política no nível de usuário **substitui** (não complementa) a política no nível de conta

**Network Rules (mais recentes, mais flexíveis)**

- Podem referenciar faixas de IP, endpoints VPC, nomes de host
- Anexadas a network policies para regras modulares e reutilizáveis
- Suportam direções `INGRESS` (entrada) e `EGRESS` (saída)

**AWS PrivateLink / Azure Private Link / GCP Private Service Connect**

- Conectividade privada da sua VPC ao Snowflake — sem internet pública
- Requer edição Business Critical ou superior
- Você recebe uma URL de endpoint privado (ex: `account.privatelink.snowflakecomputing.com`)
- NÃO substitui network policies — use ambos juntos

**External Access Integrations**

- Permitem que UDFs/procedures chamem APIs externas (ex: endpoints REST)
- Requer criar uma External Access Integration + Network Rule (egress)
- Segredos armazenados em objetos secret do Snowflake, não no código

### Por Que Isso Importa
Um banco precisa que todo o tráfego do Snowflake fique em sua rede privada. PrivateLink + network policies + bloqueio de acesso público = zero exposição à internet pública.

### Melhores Práticas
- Sempre defina uma network policy no nível de conta (mesmo que ampla) como rede de segurança
- Use PrivateLink para workloads de produção em indústrias regulamentadas
- Teste network policies em não-produção antes de aplicar no nível de conta
- Use network rules em vez de listas de IP brutas para manutenibilidade

**Armadilha do exame:** SE VOCÊ VER "PrivateLink está disponível na edição Standard" → ERRADO porque requer Business Critical ou superior.

**Armadilha do exame:** SE VOCÊ VER "network policies suportam bloqueio por FQDN/hostname" → ERRADO para network policies sozinhas; você precisa de network rules para controles baseados em hostname.

**Armadilha do exame:** SE VOCÊ VER "PrivateLink elimina a necessidade de network policies" → ERRADO porque servem propósitos diferentes e devem ser usados juntos.

### Perguntas Frequentes (FAQ)
**P: Se eu bloquear todos os IPs públicos, ainda posso usar o Snowsight?**
R: Apenas via URL do Snowsight habilitada para PrivateLink ou se você adicionar os IPs do Snowsight do Snowflake à lista de permitidos.

**P: Posso ter tanto network policies de conta quanto de usuário?**
R: Sim, mas a política no nível de usuário substitui completamente (não mescla com) a política de conta para aquele usuário.


### Exemplos de Perguntas de Cenário — Network Security

**Cenário:** A large bank is migrating to Snowflake and requires zero public internet exposure. Their applications run in AWS VPCs across three regions. Some teams also need Snowsight access from corporate offices with static IPs. How should the architect design the network architecture?
**Resposta:** Enable AWS PrivateLink to establish private connectivity from each VPC to Snowflake — traffic stays on the AWS backbone and never traverses the public internet. Create a network policy at the account level that blocks all public IPs by default. For Snowsight access from corporate offices, add the corporate static IPs to the `ALLOWED_IP_LIST` in the account-level network policy (or use a user-level network policy for specific admin users who need Snowsight). PrivateLink requires Business Critical edition or higher. Use network rules for modular, reusable IP and VPC endpoint definitions.

**Cenário:** A data engineering team needs their Python UDFs to call an external REST API for geocoding. The security team does not allow arbitrary outbound internet access from Snowflake. What is the correct architecture?
**Resposta:** Create a network rule with `MODE = EGRESS` specifying the geocoding API's hostname. Create an external access integration referencing that network rule and a Snowflake secret object containing the API key. Grant the external access integration to the UDF. This allows controlled, auditable outbound access to only the specified endpoint — no blanket internet access. The API credentials are stored in Snowflake's secret management, never in code.

---

---

## 1.5 AUTENTICAÇÃO

**SSO / SAML 2.0**

- Snowflake atua como Service Provider (SP)
- Seu IdP (Okta, Azure AD, etc.) autentica usuários
- Configurado via integração de segurança SAML2
- Suporta SCIM para provisionamento automatizado de usuários/grupos

**OAuth**

- External OAuth: token do seu IdP (Okta, Azure AD, PingFederate)
- Snowflake OAuth: Snowflake emite o token (usado por apps parceiros como Tableau)
- Ambos usam integrações de segurança

**MFA (Autenticação Multi-Fator)**

- MFA Duo integrado, sem custo extra
- Pode ser aplicado via políticas de autenticação (`AUTHENTICATION_POLICY`)
- `CLIENT_TYPES` na política de auth controla quais clientes devem usar MFA

**Autenticação por Par de Chaves**

- RSA 2048-bit mínimo
- Chave pública armazenada no objeto do usuário, chave privada mantida pelo cliente
- Suporta rotação de chaves (duas chaves ativas: `RSA_PUBLIC_KEY` e `RSA_PUBLIC_KEY_2`)
- Necessário para contas de serviço / automação (Snowpipe, conectores)

**Políticas de Autenticação**

- Controlam métodos de auth permitidos por conta ou por usuário
- Podem restringir a `CLIENT_TYPES` específicos (ex: SNOWFLAKE_UI, DRIVERS)
- Podem aplicar MFA para tipos de cliente específicos

**Autenticação Federada**

- Combina SSO + MFA para postura mais forte
- Usuários autenticam via IdP, depois desafio MFA

### Por Que Isso Importa
Uma empresa com 5.000 usuários precisa de SSO via Okta, MFA aplicado para usuários de UI, e par de chaves para pipelines CI/CD. Políticas de autenticação permitem aplicar regras diferentes por caso de uso.

### Melhores Práticas
- Aplique MFA para todos os usuários humanos (no mínimo ACCOUNTADMIN)
- Use autenticação por par de chaves para todas as contas de serviço / automação
- Use SCIM para sincronizar usuários/grupos do seu IdP
- Defina políticas de autenticação para bloquear acesso apenas por senha

**Armadilha do exame:** SE VOCÊ VER "Snowflake OAuth e External OAuth são a mesma coisa" → ERRADO porque Snowflake OAuth é emitido pelo Snowflake; External OAuth vem do seu IdP.

**Armadilha do exame:** SE VOCÊ VER "autenticação por par de chaves requer edição Enterprise" → ERRADO porque está disponível em todas as edições.

**Armadilha do exame:** SE VOCÊ VER "MFA pode ser aplicado via network policy" → ERRADO porque aplicação de MFA usa políticas de autenticação, não network policies.

**Armadilha do exame:** SE VOCÊ VER "SCIM cria roles automaticamente" → ERRADO porque SCIM provisiona usuários e grupos mas NÃO cria roles do Snowflake automaticamente.

### Perguntas Frequentes (FAQ)
**P: Posso usar tanto SSO quanto login por senha?**
R: Sim, a menos que você defina uma política de autenticação que bloqueie auth por senha. Por padrão ambos funcionam.

**P: O que acontece se um usuário perder seu par de chaves?**
R: O admin pode definir uma nova chave pública no objeto do usuário. O segundo slot de chave permite rotação sem downtime.


### Exemplos de Perguntas de Cenário — Authentication

**Cenário:** An enterprise has 5,000 employees using Okta for SSO, plus 200 CI/CD service accounts running nightly ETL pipelines. The CISO mandates MFA for all human users accessing Snowsight but cannot require MFA for automated pipelines (which have no human to approve a push notification). How should the architect configure authentication?
**Resposta:** Configure a SAML 2.0 security integration with Okta for SSO for all human users. Create an authentication policy that enforces MFA with `CLIENT_TYPES` set to `SNOWFLAKE_UI` (Snowsight) — this requires MFA for interactive logins but not for programmatic drivers. For the 200 CI/CD service accounts, use key-pair authentication (RSA 2048-bit minimum) with the public key stored on each service user object. Set a separate authentication policy on service accounts that allows only key-pair auth and blocks password-based access entirely. Use SCIM to auto-provision and deprovision human users from Okta.

**Cenário:** A company rotates credentials quarterly. They have 50 service accounts using key-pair authentication. How can the architect enable zero-downtime key rotation?
**Resposta:** Snowflake supports two concurrent public keys per user object: `RSA_PUBLIC_KEY` and `RSA_PUBLIC_KEY_2`. During rotation, generate a new key pair and set it as `RSA_PUBLIC_KEY_2` on the user object. Update the service account's client configuration to use the new private key. Once confirmed working, remove the old key from `RSA_PUBLIC_KEY`. This overlapping window allows zero-downtime rotation without any service interruption.

---

---

## 1.6 GOVERNANÇA DE DADOS

**Masking Policies (Dynamic Data Masking)**

- Segurança no nível de coluna: retorna valor mascarado com base na role que consulta
- A política é uma função SQL: `CREATE MASKING POLICY ... RETURNS <type> -> CASE WHEN ...`
- Aplicada a colunas via `ALTER TABLE ... ALTER COLUMN ... SET MASKING POLICY`
- Uma masking policy por coluna
- Suporta mascaramento condicional (baseado em role, outra coluna, etc.)

**Row Access Policies (RAP)**

- Segurança no nível de linha: filtra linhas com base no contexto de consulta
- Retorna `TRUE` (linha visível) ou `FALSE` (linha oculta)
- Uma RAP por tabela/view
- Pode referenciar tabelas de mapeamento para filtragem de role-para-região

**Aggregation Policies**

- Impedem queries que retornam resultados abaixo de um tamanho mínimo de grupo
- Protege contra re-identificação em analytics
- Privacidade no nível de entidade (ex: deve agregar pelo menos 5 pacientes)

**Projection Policies**

- Impedem `SELECT column` diretamente — coluna só pode ser usada em WHERE, JOIN, GROUP BY
- Caso de uso: permitir filtrar por SSN mas nunca exibi-lo

**Object Tagging**

- Metadados chave-valor em qualquer objeto (tabela, coluna, warehouse, etc.)
- Linhagem de tags: tags se propagam através de views
- Base para masking policies baseadas em tags (aplicar mascaramento a todas as colunas com tag X)
- Tags de sistema da classificação (ex: `SNOWFLAKE.CORE.SEMANTIC_CATEGORY = EMAIL`)

**Linhagem de Dados (ACCESS_HISTORY)**

- `SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY` — rastreia leituras/escritas no nível de coluna
- Mostra quais colunas foram acessadas, por quem, e como os dados fluíram
- Retenção de 365 dias
- Requer edição Enterprise ou superior

### Por Que Isso Importa
Uma empresa de varejo tageia todas as colunas PII, depois aplica uma única masking policy a cada coluna com a tag PII. Quando uma nova coluna PII é adicionada e tageada, o mascaramento é automático.

### Melhores Práticas
- Use mascaramento baseado em tags para governança escalável
- Combine RAP + masking para defesa em profundidade
- Use aggregation policies para datasets de analytics expostos a públicos amplos
- Execute classificação de dados para auto-detectar dados sensíveis

**Armadilha do exame:** SE VOCÊ VER "você pode aplicar duas masking policies na mesma coluna" → ERRADO porque apenas uma masking policy por coluna é permitida.

**Armadilha do exame:** SE VOCÊ VER "row access policies são aplicadas a colunas" → ERRADO porque RAP é aplicada a tabelas/views, não colunas individuais.

**Armadilha do exame:** SE VOCÊ VER "object tags requerem edição Business Critical" → ERRADO porque tagging está disponível em Enterprise e superior.

**Armadilha do exame:** SE VOCÊ VER "aggregation policies filtram linhas" → ERRADO porque elas bloqueiam queries que produzem grupos abaixo do tamanho mínimo, não filtram linhas individuais.

### Perguntas Frequentes (FAQ)
**P: Masking policies podem referenciar outras tabelas?**
R: Sim. Você pode consultar uma tabela de mapeamento dentro do corpo da masking policy (subquery).

**P: Row access policies funcionam em materialized views?**
R: Não. RAP não é suportada em materialized views.

**P: Qual é a diferença entre projection policy e masking policy?**
R: Masking substitui o valor (ex: `***`). Projection impede que a coluna apareça nos resultados completamente mas permite seu uso em predicados.


### Exemplos de Perguntas de Cenário — Data Governance

**Cenário:** A healthcare analytics platform has 500+ tables, and new columns containing PHI (emails, phone numbers, SSNs) are added regularly as new data sources are onboarded. The governance team cannot manually review every new column. How should the architect automate masking at scale?
**Resposta:** Implement tag-based masking. Run Snowflake's automatic data classification to detect sensitive columns and apply system tags (e.g., `SNOWFLAKE.CORE.SEMANTIC_CATEGORY = 'EMAIL'`). Create masking policies for each sensitivity category (EMAIL, PHONE, SSN) and bind them to the corresponding tags using tag-based masking policy assignments. When new columns are added and classified, the masking policy auto-applies based on the tag — no manual intervention needed. Combine with row access policies for defense-in-depth.

**Cenário:** A pharmaceutical company needs to share a clinical trial dataset with external researchers. Researchers must be able to filter by patient demographics (age, gender, zip code) for cohort selection, but must never see individual patient records — results must aggregate at least 20 patients per group to prevent re-identification. How should the architect configure governance?
**Resposta:** Apply an aggregation policy on the shared dataset with a minimum group size of 20 — any query that produces groups with fewer than 20 patients is blocked. Additionally, apply projection policies on direct patient identifiers (patient_id, SSN) so researchers can use them in WHERE/JOIN/GROUP BY for cohort selection but cannot SELECT them in results. Share the data via secure views with these policies applied. This provides layered privacy: aggregation prevents small-group re-identification, and projection prevents direct identifier exposure.

**Cenário:** An internal audit requires understanding which roles accessed which PII columns over the past year, including data flows through views and downstream tables. What Snowflake feature supports this?
**Resposta:** Query `SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY`, which provides column-level data lineage tracking with 365-day retention. It records which columns were read (`base_objects_accessed`) and written (`objects_modified`), by which role, including data flows through views and transformations. This supports audit requirements without requiring any custom logging infrastructure. Requires Enterprise edition or higher.

---

---

## 1.7 CONFORMIDADE

**Funcionalidades por Edição para Conformidade**

| Requisito | Edição Mínima |
|---|---|
| HIPAA / HITRUST | Business Critical |
| PCI DSS | Business Critical |
| SOC 1/2 | Todas as edições |
| FedRAMP Moderate | Virtual Private Snowflake (VPS) no AWS GovCloud |
| ITAR | VPS no AWS GovCloud |
| Suporte a PHI | Business Critical com BAA |

**Tri-Secret Secure**

- Chave gerenciada pelo cliente (CMK) envolve a chave do Snowflake, que envolve a chave de dados
- Requer edição Business Critical
- Se o cliente revogar a CMK, Snowflake não pode descriptografar dados — controle total do cliente
- Suportado em AWS (KMS), Azure (Key Vault), GCP (Cloud KMS)

**Storage Integrations**

- Acesso seguro e governado ao armazenamento de nuvem externo (S3, GCS, Azure Blob)
- Usa IAM roles / service principals — sem credenciais brutas no SQL
- Necessário para external stages, tabelas externas, acesso a data lake
- Parâmetro `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` força seu uso

### Por Que Isso Importa
Uma empresa de saúde armazenando PHI precisa de Business Critical + BAA + Tri-Secret Secure + PrivateLink. Faltar qualquer um quebra a conformidade HIPAA.

### Melhores Práticas
- Habilite Tri-Secret Secure para dados sobre os quais você precisa de controle total
- Exija storage integrations no nível de conta para prevenir vazamento de credenciais
- Documente sua arquitetura de conformidade para auditores
- Use VPS apenas quando FedRAMP / ITAR for necessário (custo significativo)

**Armadilha do exame:** SE VOCÊ VER "Tri-Secret Secure está disponível na edição Enterprise" → ERRADO porque requer Business Critical.

**Armadilha do exame:** SE VOCÊ VER "conformidade SOC 2 requer Business Critical" → ERRADO porque relatórios SOC 2 estão disponíveis para todas as edições.

**Armadilha do exame:** SE VOCÊ VER "Tri-Secret Secure significa que Snowflake não pode acessar seus dados de forma alguma" → ERRADO porque Snowflake ainda gerencia a chave intermediária; o cliente controla a chave externa.

### Perguntas Frequentes (FAQ)
**P: Qual é a diferença entre Business Critical e VPS?**
R: Business Critical adiciona criptografia, conformidade, PrivateLink. VPS adiciona um deployment Snowflake dedicado e isolado (metadata store separado, computação separada).

**P: Habilitar Tri-Secret Secure afeta a performance?**
R: Insignificantemente. O envolvimento de chaves adiciona overhead mínimo.


### Exemplos de Perguntas de Cenário — Compliance

**Cenário:** A US defense contractor needs to process ITAR-controlled data in Snowflake. They also have non-ITAR commercial workloads that don't require the same isolation. What Snowflake deployment model should the architect recommend?
**Resposta:** Deploy a Virtual Private Snowflake (VPS) instance on AWS GovCloud specifically for the ITAR-controlled workloads. VPS provides a fully dedicated, isolated Snowflake deployment with a separate metadata store and compute infrastructure — the strongest isolation level Snowflake offers. For non-ITAR commercial workloads, use a standard Business Critical account in a commercial region. Both accounts can be managed under the same Snowflake Organization for centralized billing, but data and compute are completely separated. Never mix ITAR data with commercial workloads in the same account.

**Cenário:** A healthcare company stores PHI in Snowflake and must comply with HIPAA. Their CISO requires the ability to immediately revoke Snowflake's access to all data in case of a security incident. What combination of features should the architect implement?
**Resposta:** Deploy on Business Critical edition (minimum for HIPAA/PHI support) and sign a Business Associate Agreement (BAA) with Snowflake. Enable Tri-Secret Secure, which adds a customer-managed key (CMK) via AWS KMS, Azure Key Vault, or GCP Cloud KMS that wraps Snowflake's encryption key. If the CISO needs to revoke access, they revoke the CMK — Snowflake immediately loses the ability to decrypt any data. Complement with PrivateLink for private connectivity, network policies to block all public access, and `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` to prevent credential leakage in stages.

---

---

## PARES CONFUSOS — Conta e Segurança

| Perguntam sobre... | A resposta é... | NÃO... |
|---|---|---|
| Quem **cria usuários/roles**? | **USERADMIN** | NÃO SECURITYADMIN (SECURITYADMIN *herda* USERADMIN mas sua função é grants) |
| Quem **gerencia grants** (GRANT/REVOKE)? | **SECURITYADMIN** | NÃO USERADMIN (USERADMIN apenas cria usuários/roles) |
| Quem **cria contas** em uma org? | **ORGADMIN** | NÃO ACCOUNTADMIN (ACCOUNTADMIN é por conta, não no nível de org) |
| **Roles funcionais** vs **roles de acesso** | **Funcional** = função de negócio (Data Analyst), **Acesso** = privilégios de objeto (READ_SALES) | Não misture — roles funcionais *herdam de* roles de acesso |
| **Database roles** vs **account roles** | **Database roles** = escopo de um DB, portáveis com replicação/clonagem | **Account roles** = escopo de conta, NÃO portáveis com DB |
| **Network policy** vs **network rule** | **Policy** = lista de IP permitidos/bloqueados aplicada a conta/usuário | **Rule** = mais granular (host, porta, endpoint VPC), anexada a policies |
| **Column masking** vs **row access policy** | **Masking** = esconde/substitui *valores* de coluna | **RAP** = esconde *linhas* inteiras — aplicada à tabela, não à coluna |
| **Aggregation policy** vs **projection policy** | **Aggregation** = bloqueia queries abaixo do tamanho mínimo de grupo | **Projection** = impede coluna de aparecer nos resultados do SELECT |
| **External tokenization** vs **dynamic masking** | **External** = serviço terceiro (Protegrity) substitui valor | **Dynamic masking** = nativo do Snowflake, baseado em role no momento da query |
| **PrivateLink** vs **VPN** | **PrivateLink** = conexão direta pelo backbone da nuvem, sem internet | **VPN** = túnel criptografado *pela* internet |
| **Authentication policy** vs **security integration** | **Auth policy** = regras de *como* usuários podem fazer login (MFA, tipos de cliente) | **Security integration** = *configuração* de SSO/OAuth com um IdP externo |
| Network policy de usuário + de conta | Nível de usuário **substitui** nível de conta para aquele usuário | NÃO é aditivo — a política de conta é *ignorada* para aquele usuário |
| **Snowflake OAuth** vs **External OAuth** | **Snowflake OAuth** = Snowflake emite token (apps parceiros) | **External OAuth** = seu IdP emite o token |
| **SCIM** provisiona... | **Usuários e grupos** automaticamente do IdP | NÃO roles — SCIM NÃO cria roles do Snowflake |
| Nível de **MIN_DATA_RETENTION** | **Apenas nível de conta** (define um piso) | NÃO pode ser definido em schema ou tabela |

---

## ÁRVORES DE DECISÃO DE CENÁRIOS — Conta e Segurança

**Cenário 1: "Uma empresa precisa de dados completamente isolados para conformidade PCI..."**
- **CORRETO:** **Contas** Snowflake separadas (dados PCI em sua própria conta, edição Business Critical)
- ARMADILHA: *"Usar bancos de dados diferentes na mesma conta"* — **ERRADO**, mesma conta = metadados compartilhados, ACCOUNTADMIN compartilhado, não é isolamento real

**Cenário 2: "Um analista deve ver SSNs mascarados mas um gerente vê os reais..."**
- **CORRETO:** **Masking policy de dados dinâmicos** com lógica CASE baseada em role
- ARMADILHA: *"Criar duas views separadas"* — **ERRADO**, não escalável, difícil de manter, contorna governança

**Cenário 3: "Bloquear todo acesso à internet pública ao Snowflake..."**
- **CORRETO:** **PrivateLink** + **network policy** bloqueando todos os IPs públicos
- ARMADILHA: *"Apenas usar uma VPN"* — **ERRADO**, VPN ainda atravessa internet pública; PrivateLink fica no backbone da nuvem

**Cenário 4: "Uma conta de serviço precisa conectar ao Snowflake de um pipeline CI/CD..."**
- **CORRETO:** **Autenticação por par de chaves** (RSA 2048-bit)
- ARMADILHA: *"Armazenar usuário/senha em variáveis de ambiente"* — **ERRADO**, senhas são menos seguras e não podem aplicar MFA

**Cenário 5: "Impedir que donos de tabelas concedam SELECT para roles não autorizadas..."**
- **CORRETO:** **Managed access schema** — apenas dono do schema/MANAGE GRANTS pode conceder
- ARMADILHA: *"Usar row access policies"* — **ERRADO**, RAP filtra linhas mas não previne escalação de grants

**Cenário 6: "Permitir filtrar por SSN na cláusula WHERE mas nunca exibir a coluna..."**
- **CORRETO:** **Projection policy** na coluna SSN
- ARMADILHA: *"Masking policy"* — **ERRADO**, masking ainda mostra a coluna (com valor mascarado). Projection esconde completamente do SELECT

**Cenário 7: "Aplicar MFA para usuários Snowsight mas não para contas de serviço JDBC..."**
- **CORRETO:** **Authentication policy** com `CLIENT_TYPES` definido para aplicar MFA apenas para `SNOWFLAKE_UI`
- ARMADILHA: *"Network policy"* — **ERRADO**, network policies controlam acesso por IP, não métodos de autenticação

**Cenário 8: "Garantir que Time Travel nunca seja definido abaixo de 7 dias em qualquer tabela..."**
- **CORRETO:** Definir **`MIN_DATA_RETENTION_TIME_IN_DAYS = 7`** no nível de conta
- ARMADILHA: *"Definir DATA_RETENTION_TIME_IN_DAYS = 7 em cada schema"* — **ERRADO**, objetos individuais podem sobrescrever configurações do schema; apenas MIN no nível de conta define um piso verdadeiro

**Cenário 9: "Queries de analytics devem agregar pelo menos 10 pacientes antes de mostrar resultados..."**
- **CORRETO:** **Aggregation policy** com tamanho mínimo de grupo de 10
- ARMADILHA: *"Row access policy"* — **ERRADO**, RAP filtra linhas por role; não aplica tamanhos mínimos de grupo

**Cenário 10: "Cliente quer controle total para revogar o acesso do Snowflake aos seus dados..."**
- **CORRETO:** **Tri-Secret Secure** (chave gerenciada pelo cliente envolve a chave do Snowflake) no **Business Critical**
- ARMADILHA: *"Apenas usar a criptografia nativa do Snowflake"* — **ERRADO**, criptografia padrão não dá ao cliente um interruptor de desligamento

**Cenário 11: "5.000 usuários precisam de SSO, com grupos auto-sincronizados do Okta..."**
- **CORRETO:** **Integração de segurança SAML 2.0** para SSO + **SCIM** para provisionamento de usuários/grupos
- ARMADILHA: *"Criar usuários manualmente com senhas"* — **ERRADO**, não escala, sem desprovisionamento automático

**Cenário 12: "Nova coluna PII adicionada — deve ser automaticamente mascarada sem intervenção manual..."**
- **CORRETO:** **Mascaramento baseado em tags** — tagear a coluna como PII, masking policy se aplica automaticamente a todas as colunas com aquela tag
- ARMADILHA: *"Aplicar nova masking policy a cada coluna manualmente"* — **ERRADO**, não escala, fácil de perder colunas

---

## FLASHCARDS -- Domínio 1

**Q1:** Qual role pode criar novas contas em uma Snowflake Organization?
**A1:** Apenas ORGADMIN.

**Q2:** Se um parâmetro de sessão e um parâmetro de conta conflitam, qual vence?
**A2:** Parâmetro de sessão (o mais específico vence).

**Q3:** Qual é a edição mínima para PrivateLink?
**A3:** Business Critical.

**Q4:** Quantas masking policies podem ser aplicadas a uma única coluna?
**A4:** Uma.

**Q5:** Qual é a diferença entre uma role funcional e uma role de acesso?
**A5:** Roles de acesso detêm privilégios de objeto; roles funcionais representam funções de trabalho e herdam de roles de acesso.

**Q6:** O que o Tri-Secret Secure fornece?
**A6:** Chave gerenciada pelo cliente envolvendo a chave do Snowflake — cliente pode revogar acesso aos seus dados.

**Q7:** Database roles podem ser concedidas diretamente a usuários?
**A7:** Não. Devem ser concedidas a roles no nível de conta (ou outras database roles dentro do mesmo banco de dados).

**Q8:** O que `MIN_DATA_RETENTION_TIME_IN_DAYS` faz?
**A8:** Define um piso para retenção de Time Travel que objetos individuais não podem ficar abaixo.

**Q9:** Qual método de autenticação contas de serviço devem usar?
**A9:** Autenticação por par de chaves.

**Q10:** Qual é o propósito de uma projection policy?
**A10:** Impede que uma coluna apareça nos resultados do SELECT enquanto permite seu uso em WHERE/JOIN/GROUP BY.

**Q11:** O que SCIM faz no Snowflake?
**A11:** Automatiza provisionamento/desprovisionamento de usuários e grupos de um IdP externo.

**Q12:** Quando uma network policy no nível de usuário é definida, o que acontece com a política no nível de conta para aquele usuário?
**A12:** A política no nível de usuário substitui completamente (não mescla com) a política no nível de conta.

**Q13:** Qual edição é necessária para row access policies?
**A13:** Enterprise ou superior.

**Q14:** Qual é o período de retenção do ACCESS_HISTORY?
**A14:** 365 dias.

**Q15:** Aggregation policies podem ser combinadas com masking policies na mesma tabela?
**A15:** Sim. Servem propósitos diferentes e podem coexistir.

---

## EXPLIQUE COMO SE EU TIVESSE 5 ANOS -- Domínio 1

**1. Estratégia Multi-Conta**
Imagine que você tem caixas de brinquedos diferentes para salas diferentes. A caixa do quarto tem brinquedos de dormir, a caixa da sala de jogos tem brinquedos de bagunça. Você mantém separados para que glitter não vá parar no seu travesseiro. Isso é multi-conta — caixas separadas para coisas separadas.

**2. Hierarquia de Parâmetros**
Seus pais dizem "hora de dormir às 20h" (regra de conta). Mas para O SEU quarto, é "hora de dormir às 20:30" (regra de objeto). E hoje à noite, já que é seu aniversário, é "hora de dormir às 21h" (regra de sessão). A regra mais específica vence!

**3. Herança de Roles**
Você é o "monitor de biscoitos" na escola. Isso significa que pode distribuir biscoitos. Sua professora é a "chefe da sala" e ela tem TODOS os poderes de monitor, incluindo os seus. Poderes fluem PARA CIMA.

**4. Network Policies**
É como uma lista de convidados em uma festa de aniversário. Só crianças na lista podem entrar. Se sua mãe faz uma lista especial só para você, ela substitui a lista principal — não adiciona a ela.

**5. PrivateLink**
Imagine um túnel secreto da sua casa direto para a casa do seu amigo. Você nunca precisa andar na calçada (internet pública). É mais seguro porque ninguém pode te ver indo e voltando.

**6. Masking Policies**
Seu diário tem uma tinta mágica. Quando VOCÊ lê, vê tudo. Quando seu irmão lê, as partes secretas ficam borradas. Mesma página, pessoas diferentes veem coisas diferentes.

**7. Row Access Policies**
Um buffet onde todo mundo vê pratos diferentes. Crianças veem pizza e nuggets. Adultos veem salada e sushi. Mesma mesa, porções diferentes baseadas em quem você é.

**8. Tri-Secret Secure**
Seu cofre precisa de DUAS chaves para abrir. Você tem uma, o Snowflake tem a outra. Se você tira sua chave, ninguém pode abrir o cofre — nem mesmo o Snowflake.

**9. SCIM**
Quando um novo aluno entra na escola, ele automaticamente ganha um crachá, um cubículo e um lugar no refeitório. Quando sai, tudo é retirado automaticamente. Não é preciso papelada manual!

**10. Aggregation Policies**
Uma regra que diz "você não pode contar uma história sobre menos de 5 pessoas." Isso impede que alguém adivinhe sobre quem é a história.

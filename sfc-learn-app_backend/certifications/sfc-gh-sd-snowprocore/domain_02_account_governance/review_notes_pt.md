# DOMÍNIO 2: GERENCIAMENTO DE CONTA E GOVERNANÇA DE DADOS
## 20% do exame = ~20 questões

---

## 2.1 MODELO DE CONTROLE DE ACESSO

O Snowflake usa DOIS modelos juntos:

### RBAC (Role-Based Access Control):
- Privilégios → concedidos a ROLES → roles concedidos a USUÁRIOS
- Este é o modelo primário
- "Quem pode fazer o quê" é determinado pelo ROLE, não pelo usuário

### DAC (Discretionary Access Control):
- O DONO de um objeto pode conceder acesso a ele
- Cada objeto tem exatamente UM role dono
- Dono = o role que criou o objeto (por padrão)
- Dono pode transferir propriedade: GRANT OWNERSHIP

**Armadilha do exame**: "DAC significa..." → O DONO de um objeto decide quem recebe acesso. SE VOCÊ VIR "roles determinam acesso" com DAC → ERRADO! Isso é RBAC. DAC = controle baseado em propriedade.
**Armadilha do exame**: "RBAC significa..." → Privilégios são atribuídos a ROLES, roles a usuários. SE VOCÊ VIR "dono concede acesso" com RBAC → ERRADO! Isso é DAC. RBAC = baseado em role, não baseado em propriedade.

### Como eles funcionam juntos:
- RBAC determina o que um role PODE fazer
- DAC determina quem É DONO do objeto e pode conceder/revogar


### Exemplos de Perguntas de Cenário — Access Control Model

**Cenário:** A data engineer on the ANALYTICS_TEAM role created a staging table. Now the FINANCE_TEAM role needs SELECT access to that table. The finance lead asks: "Who needs to grant us access?"
**Resposta:** Under Snowflake's DAC model, the **owner** of the object controls who gets access. The ANALYTICS_TEAM role owns the table (because it created it), so someone using that role (or a higher role in the hierarchy like SECURITYADMIN with MANAGE GRANTS) must run `GRANT SELECT ON TABLE ... TO ROLE FINANCE_TEAM`. The finance team cannot grant themselves access — only the owner or a role with MANAGE GRANTS can. This is DAC in action: the owner decides.

**Cenário:** A security auditor asks: "Does Snowflake use RBAC or DAC?" A junior DBA responds: "It uses DAC because the object owner controls access." Is the DBA correct?
**Resposta:** Partially correct but incomplete. Snowflake uses **both RBAC and DAC together**. RBAC is the primary model — privileges are granted to roles, and roles are granted to users. DAC complements it because every object has an owner role, and that owner can grant/revoke access. Saying "only DAC" ignores that all access flows through roles (RBAC). The correct answer on the exam is always "both models working together."

**Cenário:** A company wants to transfer ownership of a production database from the DEV_ADMIN role to the PROD_ADMIN role. What command is needed, and what happens to existing grants?
**Resposta:** Use `GRANT OWNERSHIP ON DATABASE prod_db TO ROLE PROD_ADMIN`. After transfer, PROD_ADMIN becomes the new owner and controls access (DAC). By default, existing grants are preserved with the `COPY CURRENT GRANTS` option. Without it, existing grants may be revoked. This is a key DAC concept: ownership transfer changes who controls the object's access grants.

### Schemas de Acesso Gerenciado (Managed Access Schemas)

Em um **schema normal**, qualquer role que POSSUA um objeto dentro do schema pode conceder acesso a esse objeto para outros roles. Esse é o comportamento DAC padrão -- o dono do objeto decide quem recebe acesso.

Em um **schema de acesso gerenciado** (`CREATE SCHEMA ... WITH MANAGED ACCESS`), os donos dos objetos PERDEM a capacidade de conceder acesso. Apenas o **dono do schema** (o role com OWNERSHIP no schema) ou um role com **MANAGE GRANTS** pode controlar quem acessa objetos dentro do schema.

**Por que isso importa:**
- Schema normal = controle de acesso descentralizado (cada dono de objeto distribui suas próprias chaves)
- Acesso gerenciado = controle de acesso centralizado (apenas o gerente do prédio distribui chaves)
- Previne "desvio de permissões" onde engenheiros de dados individuais concedem acesso ad-hoc sem supervisão

**Sintaxe:**
```sql
-- Criar um schema de acesso gerenciado
CREATE SCHEMA finance.secure WITH MANAGED ACCESS;

-- Converter schema existente para acesso gerenciado
ALTER SCHEMA my_schema ENABLE MANAGED ACCESS;

-- Reverter para schema normal
ALTER SCHEMA my_schema DISABLE MANAGED ACCESS;
```

### ELI5: O Prédio de Apartamentos (Managed Access Schemas)

Em um **schema normal**, cada morador do apartamento (dono do objeto) pode dar cópias da sua chave para qualquer pessoa que quiser. O gerente do prédio não tem ideia de quem tem chaves de quê.

Em um **schema de acesso gerenciado**, apenas o gerente do prédio (dono do schema ou role MANAGE GRANTS) pode distribuir chaves. Um morador pode construir móveis dentro do seu apartamento (ele ainda É DONO do objeto), mas NÃO PODE entregar sua chave a um estranho. Se alguém precisar de acesso, deve passar pelo gerente do prédio.

**Gatilho do exame:** "centralizar controle de acesso" / "impedir donos de conceder acesso" / "governança de ambiente de produção" → Managed Access Schema.

**Armadilha do exame**: "Donos de objetos podem conceder acesso em schemas de acesso gerenciado?" → ERRADO! Em acesso gerenciado, apenas o dono do schema ou role MANAGE GRANTS pode conceder acesso. Donos de objetos mantêm OWNERSHIP mas não podem gerenciar grants.
**Armadilha do exame**: "Acesso gerenciado requer edição Enterprise?" → NÃO! Disponível em TODAS as edições.

---

---

## 2.2 ROLES DEFINIDOS PELO SISTEMA (MUITO TESTADO)

### Hierarquia de Roles (de cima para baixo):

```
    ACCOUNTADMIN
    ├── SECURITYADMIN
    │   └── USERADMIN
    └── SYSADMIN
         └── (custom roles devem ficar aqui)
              └── PUBLIC (todos)
```

### Função de cada role:

**ACCOUNTADMIN** (nível mais alto, mais poderoso):
- Encapsula SYSADMIN + SECURITYADMIN
- Unico role que pode: ver faturamento, gerenciar resource monitors, ver ACCOUNT_USAGE
- Pode criar Shares para compartilhamento de dados
- Deve ser atribuido a POUCOS usuarios (2-3 pessoas no maximo)
- Melhor pratica: usar MFA, NAO usar como role padrao
- Este e um **break-glass role** ("quebre o vidro em caso de emergencia") -- mantenha trancado, so para emergencias
- Segue o **Principio do Menor Privilegio (PoLP - Principle of Least Privilege)**: usuarios devem ter apenas o nivel exato de poder necessario para a tarefa, nada mais

### ELI5: O Tanque de Guerra na Padaria (Por que NUNCA Usar ACCOUNTADMIN no Dia a Dia)

ACCOUNTADMIN e o "Modo Deus" da Snowflake. Ele pode ver todos os dados de cartao de credito, alterar as senhas de todo mundo, mudar a rede e -- pior de tudo -- apagar a conta inteira.

Usar ACCOUNTADMIN para trabalho diario (como rodar um SELECT ou criar uma tabelinha) e como usar um tanque de guerra atirador de misseis para ir comprar pao na padaria. Voce vai conseguir comprar o pao? Vai. Mas se voce espirrar e esbarrar num botao, voce explode o quarteireo inteiro.

**A protecao contra o "Oops":** Imagine que e sexta-feira, voce esta cansado e digita sem querer `DROP DATABASE banco_de_producao;`
- Se voce estiver usando a sua role normal (ex: DATA_ENGINEER): a Snowflake te da um tapa na mao -- "Erro: Voce nao tem permissao". Ufa, seu emprego esta salvo!
- Se voce estiver de ACCOUNTADMIN: a Snowflake diz "Seu desejo e uma ordem, mestre!" e DELETA tudo em 1 segundo. Sem perguntar duas vezes.

**Quando e a UNICA hora de usar ACCOUNTADMIN?** Faturamento, resource monitors, integracoes de conta, ou emergencias reais. Para todo o resto: SYSADMIN (construir coisas), SECURITYADMIN (gerenciar acesso), ou custom roles.

**SECURITYADMIN**:
- Gerenciar grants (privilégio MANAGE GRANTS)
- Gerenciar network policies
- Pode conceder/revogar privilégios em QUALQUER objeto
- Melhor para: gerenciar quem pode acessar o quê

**USERADMIN**:
- Criar e gerenciar usuários e roles
- Privilégios CREATE USER, CREATE ROLE
- NÃO obtém automaticamente acesso a dados
- Reporta ao SECURITYADMIN

**SYSADMIN**:
- Criar e gerenciar databases, schemas, warehouses
- Deve possuir todos os custom roles (melhor prática: conceder custom roles AO SYSADMIN)
- O role "construtor"

**PUBLIC**:
- Concedido automaticamente a todo usuário
- Nível mais baixo
- Qualquer privilégio concedido ao PUBLIC fica disponível para todos

**ORGADMIN**:
- Gerenciamento no nível da organização
- Criar e gerenciar contas dentro da organização
- Visualizar uso no nível da organização
- NÃO está no diagrama regular de hierarquia de roles

### Regras-chave:
- Roles superiores HERDAM privilégios dos roles inferiores na hierarquia
- ACCOUNTADMIN herda tudo de SYSADMIN + SECURITYADMIN
- Mas: possuir um role NÃO significa herdar seus privilégios (apenas a hierarquia faz isso)
- Custom roles devem ser concedidos ao SYSADMIN (melhor pratica)

### ELI5: A Empresa Dividida (O Formato Y)

Sua conta Snowflake e uma empresa. Esquece os bullet points -- visualize um **Y**.

**O CEO (ACCOUNTADMIN)** fica no topo do Y. A pessoa mais poderosa do predio. Herda tudo de todos abaixo.

Abaixo do CEO, a empresa se divide em **DOIS departamentos completamente separados**:

**Galho esquerdo -- RH e Seguranca (Pessoas):**
- **SECURITYADMIN** = o Diretor de Seguranca. Trabalho dele: distribuir crachas de acesso (GRANTS). Ele herda do cara abaixo.
- **USERADMIN** = o Recrutador do RH. Trabalho dele: criar Pessoas (USERS) e criar Crachas/Cargos (ROLES). Ele pode criar mas NAO pode distribuir.

**Galho direito -- Engenharia (Maquinas e Dados):**
- **SYSADMIN** = o Mestre de Obras. Ele constroi databases, tabelas, warehouses. Toda a infraestrutura.
- Custom roles ficam abaixo do SYSADMIN (melhor pratica).

**PUBLIC** = o lobby. Todo mundo automaticamente tem acesso. Base da hierarquia.

**ORGADMIN** = o Dono da Franquia. Ele fica FORA do predio -- cria e gerencia outros predios (contas). Ele NAO esta acima do CEO dentro do predio. Sao separados.

**O truque do exame:** "O SYSADMIN tentou resetar a senha de um usuario mas deu erro. Por que?"
Porque o Mestre de Obras (SYSADMIN) tem ZERO poder sobre o RH (USERADMIN). Estao em galhos separados do Y. Um cuida de tijolo e cimento (Dados), o outro cuida de crachas (Pessoas). Sao irmaos que so respondem a um chefe: o CEO (ACCOUNTADMIN).

**Palavras-ancora para lembrar o Y:**
- Lado esquerdo: Seguranca e RH (SECURITY > USER)
- Lado direito: Construcao (SYSADMIN)
- Os dois lados NAO se misturam!

### Por Que Isso Importa + Casos de Uso

**Cenário real — "Um estagiário acidentalmente dropou um database de produção"**
O estagiário tinha ACCOUNTADMIN. Solução: NUNCA dê ACCOUNTADMIN para trabalho diário. Crie custom roles com privilégios mínimos necessários. Conceda-os à hierarquia do SYSADMIN.

**Cenário real — "Precisamos esconder dados de salário dos analistas"**
Analistas precisam consultar a tabela de funcionários mas não devem ver a coluna de salário. Solução: Política de Dynamic Data Masking (Enterprise+). Analistas veem '****', gerentes veem valores reais. UMA política por coluna.

**Cenário real — "ACCOUNT_USAGE não mostra dados de hoje"**
ACCOUNT_USAGE tem latência de 45min-3h. Se você precisa de informações de uso em tempo real, use INFORMATION_SCHEMA (tempo real, mas 7 dias a 6 meses de histórico dependendo da view).

---

### Melhores Práticas — Roles
- NUNCA use ACCOUNTADMIN para trabalho diário — crie custom roles
- Conceda ACCOUNTADMIN a poucas pessoas (2-3 no máximo para emergências)
- Sempre use hierarquia de roles: custom roles concedidos ao SYSADMIN
- Use SECURITYADMIN para gerenciar grants, USERADMIN para criar usuários
- Habilite MFA para TODOS os usuários com ACCOUNTADMIN

**Armadilha do exame**: "Qual role monitora faturamento?" → ACCOUNTADMIN. SE VOCÊ VIR "faturamento" com SYSADMIN → ERRADO! SYSADMIN constrói objetos. Apenas ACCOUNTADMIN vê faturamento/custos.
**Armadilha do exame**: "Qual role gerencia network policies?" → SECURITYADMIN. SE VOCÊ VIR "network policies" com ACCOUNTADMIN → armadilha! SECURITYADMIN é o role designado para segurança.
**Armadilha do exame**: "Qual role cria usuários?" → USERADMIN. SE VOCÊ VIR "cria usuários" com SECURITYADMIN → ERRADO! SECURITYADMIN gerencia GRANTS. USERADMIN cria usuários.
**Armadilha do exame**: "Qual role cria databases/warehouses?" → SYSADMIN. SE VOCÊ VIR "cria databases" com ACCOUNTADMIN → armadilha! SYSADMIN é o construtor. ACCOUNTADMIN é exagero.
**Armadilha do exame**: "Qual role cria contas em uma org?" → ORGADMIN. SE VOCÊ VIR "cria contas" com ACCOUNTADMIN → ERRADO! ACCOUNTADMIN é por conta. ORGADMIN é nível de organização.
**Armadilha do exame**: "Qual role cria Shares?" → ACCOUNTADMIN. SE VOCÊ VIR "cria Shares" com SYSADMIN → ERRADO! Apenas ACCOUNTADMIN pode criar Shares para compartilhamento de dados.


### Exemplos de Perguntas de Cenário — System-Defined Roles

**Cenário:** A new data team lead needs to create a warehouse for their analytics workload. They ask the admin to give them ACCOUNTADMIN. Is this appropriate?
**Resposta:** No. ACCOUNTADMIN is the most powerful role and should be reserved for limited use. The correct approach is to use SYSADMIN to create the warehouse (SYSADMIN is the "builder" role for databases, schemas, and warehouses). Either grant SYSADMIN to the lead, or create a custom role with CREATE WAREHOUSE privilege and grant it to SYSADMIN in the hierarchy.

**Cenário:** An organization wants to set up SSO for all employees. Which system role should configure the network policies and security settings?
**Resposta:** SECURITYADMIN. This role has the MANAGE GRANTS privilege and is the designated role for security-related configuration including network policies, grants, and access control. While ACCOUNTADMIN can also do this (it inherits SECURITYADMIN privileges), best practice is to use the most specific role for the task.

**Cenário:** A company has 15 custom roles but none of them can access databases created by SYSADMIN. What's likely wrong with their role hierarchy?
**Resposta:** The custom roles are not granted to SYSADMIN. Best practice: all custom roles should be granted to SYSADMIN (`GRANT ROLE custom_role TO ROLE SYSADMIN`). This ensures the hierarchy flows properly — SYSADMIN inherits custom role privileges, and ACCOUNTADMIN inherits everything. Without this, custom roles are isolated from the hierarchy.

---

---

## 2.3 TIPOS DE ROLE

### Account Roles:
- Roles regulares com escopo para toda a conta
- Podem acessar qualquer objeto na conta (se concedido)

### Database Roles:
- Escopo para um único database
- Não podem ser ativados diretamente em uma sessão
- Devem ser concedidos a um account role
- Úteis para gerenciar acesso dentro de um database

### Secondary Roles:
- Um usuario pode ativar MULTIPLOS roles em uma sessao
- Role primario = o role definido com `USE ROLE` (e dono dos objetos criados)
- Secondary roles = roles adicionais que somam permissoes na sessao
- Tres opcoes de sintaxe:
  - `USE SECONDARY ROLES ALL` → ativa TODOS os roles concedidos como secundarios
  - `USE SECONDARY ROLES NONE` → desativa todos os secundarios (so o primario ativo)
  - `USE SECONDARY ROLES role1, role2` → ativa roles ESPECIFICOS como secundarios
- Combina permissoes de todos os roles ativos (primario + secundarios)
- **Regra critica: CREATE (DDL) e restrito ao role PRIMARIO apenas**
  - Secondary roles podem fazer: SELECT, INSERT, UPDATE, DELETE, TRUNCATE (DML)
  - Secondary roles NAO podem fazer: CREATE TABLE, CREATE VIEW, CREATE SCHEMA, etc.
  - Motivo: objetos criados precisam de exatamente um DONO, e esse e o role primario
- Propriedade `DEFAULT_SECONDARY_ROLES` do usuario controla o comportamento ao logar:
  - `ALTER USER ... SET DEFAULT_SECONDARY_ROLES = ('ALL')` → ativa todos ao logar
  - `ALTER USER ... SET DEFAULT_SECONDARY_ROLES = ()` → nenhum ao logar
  - Desde BCR-1692 (2024), contas novas podem ter ALL como padrao em vez de NONE
  - IMPORTANTE: DEFAULT_SECONDARY_ROLES so aceita ('ALL') ou () -- voce NAO pode especificar roles individuais no nivel do usuario
- Nivel de Sessao vs Nivel de Usuario (distincao chave do exame):
  - `USE SECONDARY ROLES ...` = nivel de SESSAO, temporario, morre quando voce faz logoff
  - `ALTER USER SET DEFAULT_SECONDARY_ROLES` = propriedade do objeto USUARIO, permanente, aplica automaticamente em todo login
  - Session policies (`ALLOWED_SECONDARY_ROLES`) podem restringir ainda mais quais secondary roles sao permitidos

### ELI5: A Camiseta e a Mochila (Primary vs Secondary Roles)

Pense no seu role primario como a camiseta que voce esta vestindo -- e a que todo mundo ve e tem SEU NOME nela. Quando voce constroi algo (CREATE), o nome da sua camiseta vai como dono.

Seus secondary roles sao ferramentas na sua mochila. Voce pode pegar coisas na mochila para LER (SELECT), MODIFICAR (INSERT, UPDATE, DELETE) -- mas quando voce CONSTROI algo novo (CREATE TABLE), so o nome da camiseta vai como dono.

Voce tem tres escolhas para a mochila:
- Levar TUDO que voce tem (`USE SECONDARY ROLES ALL`)
- Levar NADA (`USE SECONDARY ROLES NONE`)
- Escolher ferramentas especificas (`USE SECONDARY ROLES role_a, role_b`)

**Armadilha do exame**: "Um database role pode ser ativado diretamente em uma sessao?" → NAO. SE VOCE VIR "ativar diretamente" com database role → ERRADO! Deve ser concedido a um ACCOUNT role primeiro.
**Armadilha do exame**: "Escopo de database role vs account role?" → Database role = apenas um database. SE VOCE VIR "conta inteira" com database role → ERRADO! Account role = conta inteira. Database role = database unico.
**Armadilha do exame**: "Operacoes CREATE usam permissoes dos secondary roles?" → ERRADO! CREATE (DDL) e autorizado APENAS pelo role primario. Secondary roles so adicionam permissoes DML.
**Armadilha do exame**: "USE SECONDARY ROLES so aceita ALL ou NONE?" → ERRADO! Voce PODE especificar roles individuais: `USE SECONDARY ROLES role1, role2;`
**Armadilha do exame**: "Quem e dono dos objetos criados com secondary roles ativos?" → O role PRIMARIO. SE VOCE VIR "secondary role e dono" → ERRADO! Secondary roles adicionam permissoes mas o role PRIMARIO e dono dos objetos criados.
**Armadilha do exame**: "USE SECONDARY ROLES e uma mudanca permanente?" → ERRADO! USE = nivel de sessao, temporario. ALTER USER SET DEFAULT_SECONDARY_ROLES = permanente. Se a questao diz "persiste apos logoff" com USE → ERRADO!
**Armadilha do exame**: "DEFAULT_SECONDARY_ROLES = ('role1', 'role2')?" → ERRADO! A propriedade do usuario so aceita ('ALL') ou () vazio. Nomes individuais de roles so funcionam com o comando de sessao USE SECONDARY ROLES.


### Exemplos de Perguntas de Cenário — Role Types

**Cenário:** A DBA creates a database role called ANALYTICS_DB.READER to manage read access within the ANALYTICS_DB database. An analyst tries to run `USE ROLE ANALYTICS_DB.READER` in their session. What happens?
**Resposta:** It fails. Database roles cannot be activated directly in a session. The database role must first be granted to an account role (e.g., `GRANT DATABASE ROLE ANALYTICS_DB.READER TO ROLE ANALYST_ROLE`), and the analyst activates the account role instead. Database roles are always accessed indirectly through account roles.

**Cenário:** A data engineer needs SELECT on tables from both the MARKETING and FINANCE databases in a single query. They have separate roles for each. How can they access both without switching roles?
**Resposta:** Use secondary roles: `USE SECONDARY ROLES ALL`. This activates all granted roles simultaneously, combining their permissions. The engineer can now query both databases in one session. Note: any new objects created will be owned by the PRIMARY role (the active role), not the secondary roles.

---

---

## 2.4 MÉTODOS DE AUTENTICAÇÃO

### Multi-Factor Authentication (MFA):
- Alimentado por Duo Security
- Usuários se inscrevem via interface web do Snowflake
- Disponível em TODAS as edições
- Pode ser obrigatório no nível da conta (AUTHENTICATION POLICY)

### Federated Authentication / SSO:
- Integração com provedores de identidade externos (IdP)
- Baseado em SAML 2.0
- Disponível em TODAS as edições

### OAuth:
- Autorizar acesso sem compartilhar credenciais de login
- External OAuth (IdP customizado) ou Snowflake OAuth
- Disponível em TODAS as edições

### Key Pair Authentication:
- Usa par de chaves RSA (chave pública + privada)
- Sem necessidade de senha
- Comum para: acesso programático, SnowSQL, conectores, contas de serviço
- Chave privada fica com o usuário, chave pública registrada no Snowflake

**Armadilha do exame**: "Key pair é usado para..." → Acesso programático/CLI sem senhas. SE VOCÊ VIR "login na interface web" com key pair → ERRADO! Key pair = contas de serviço/scripts. Interface web usa senha/SSO.
**Armadilha do exame**: "MFA é alimentado por..." → Duo Security. SE VOCÊ VIR "Google Authenticator" ou "Okta" com MFA → ERRADO! Snowflake MFA = apenas Duo Security. Okta = SSO/autenticação federada.
**Armadilha do exame**: "Inscrição no MFA é..." → Self-service pelos usuários. SE VOCÊ VIR "admin inscreve usuários" → ERRADO! Usuários se inscrevem sozinhos. Admins podem OBRIGAR MFA via política, mas inscrição é self-service.


### Exemplos de Perguntas de Cenário — Authentication Methods

**Cenário:** A company has a nightly ETL pipeline running via a Python script. The script currently uses a username/password to connect to Snowflake. The security team says passwords in scripts are a risk. What's the recommended alternative?
**Resposta:** Use Key Pair Authentication. Generate an RSA key pair, register the public key with the Snowflake user (`ALTER USER etl_user SET RSA_PUBLIC_KEY = '...'`), and configure the Python connector to use the private key. No password stored in scripts. Key pair auth is the standard for programmatic/service account access.

**Cenário:** A company uses Okta as their identity provider and wants employees to log into Snowflake using their Okta credentials. Which authentication method should they configure?
**Resposta:** Federated Authentication / SSO using SAML 2.0. Configure Okta as the external IdP for Snowflake. This is available on ALL editions. Do NOT confuse with MFA — MFA uses Duo Security for second-factor verification, while SSO/federated auth delegates the entire login to an external IdP like Okta.

---

---

## 2.5 NETWORK POLICIES

- Controlam acesso por endereço IP
- IPs permitidos (whitelist) e IPs bloqueados (blacklist)
- Podem ser aplicadas no: nível da conta OU nível do usuário
- Política de nível de usuário sobrescreve a de nível de conta
- Disponível em TODAS as edições
- Gerenciadas pelo SECURITYADMIN (ou role com MANAGE GRANTS)

**Armadilha do exame**: "Restringir acesso apenas do IP corporativo?" → Network Policy. SE VOCÊ VIR "firewall" ou "VPN necessário" → armadilha! Snowflake usa NETWORK POLICIES (listas de IPs permitidos/bloqueados), não firewalls ou VPNs.


### Exemplos de Perguntas de Cenário — Network Policies

**Cenário:** A company wants all employees to access Snowflake only from the office (IP range 10.0.0.0/16), but the DBA needs access from home too (IP 203.0.113.50). How should they configure this?
**Resposta:** Create an account-level network policy with ALLOWED_IP_LIST = '10.0.0.0/16' for the office. Then create a separate user-level network policy for the DBA that includes both the office range and the home IP. User-level policy overrides account-level, so the DBA gets access from both locations while everyone else is restricted to the office.

### Network Rules vs Network Policies (Distinção Chave)

Network Policies SOZINHAS só lidam com endereços IP (ALLOWED_IP_LIST / BLOCKED_IP_LIST). Mas e se você precisar controlar acesso por hostname, FQDN, ou ID de endpoint privado? É aí que entram as **Network Rules**.

**Network Rules** são objetos de nível de schema que agrupam identificadores de rede em unidades lógicas. Elas suportam múltiplos tipos de identificador:
- **IPV4** -- Endereços IP e ranges CIDR (ex: `192.168.1.0/24`)
- **AWSVPCEID** -- IDs de endpoint VPC da AWS (para PrivateLink na AWS)
- **AZURELINKID** -- IDs de Link de endpoint privado Azure (para PrivateLink no Azure)
- **HOST_PORT** -- hostnames/FQDNs para regras de egress (acesso de saída de UDFs/procedures)

**Network Policies** referenciam Network Rules em vez de conter listas de IPs diretamente. O fluxo:
1. Criar Network Rule(s) → definir QUEM/O QUÊ (IPs, IDs de endpoint, hostnames)
2. Criar Network Policy → referenciar regras via `ALLOWED_NETWORK_RULE_LIST` / `BLOCKED_NETWORK_RULE_LIST`
3. Ativar a política → vincular à conta, usuário, ou security integration

**Diferenças chave:**
- Network Rules = objetos de **nível de schema** (vivem dentro de database.schema)
- Network Policies = objetos de **nível de conta**
- Network Rules suportam modos INGRESS (entrada) e EGRESS (saída)
- Uma network rule pode ser referenciada por MÚLTIPLAS políticas (reutilizável)

**Regras de precedência importantes:**
- Regras de conectividade privada (AWSVPCEID / AZURELINKID) têm **precedência** sobre regras IPV4
- Se uma requisição chega via PrivateLink e corresponde a uma regra de endpoint privado permitido, TODAS as regras IPV4 são ignoradas para aquela requisição
- Lista de bloqueio tem precedência se o mesmo identificador aparece em ambas as listas

```sql
-- Exemplo: Permitir apenas PrivateLink, bloquear toda internet pública
CREATE NETWORK RULE allow_private
  MODE = INGRESS TYPE = AWSVPCEID
  VALUE_LIST = ('vpce-0fa383eb170331202');

CREATE NETWORK RULE block_public
  MODE = INGRESS TYPE = IPV4
  VALUE_LIST = ('0.0.0.0/0');

CREATE NETWORK POLICY private_only
  ALLOWED_NETWORK_RULE_LIST = ('allow_private')
  BLOCKED_NETWORK_RULE_LIST = ('block_public');
```

### ELI5: O Upgrade do Segurança (Network Rules vs Network Policies)

Lembra do segurança na boate (Network Policy)? Ele só checava seu documento de identidade (endereço IP). Esse era o ÚNICO truque dele.

Mas a boate ficou mais sofisticada. Agora eles precisam checar:
- Seu IP (documento de identidade antigo)
- Sua pulseira VIP (ID de endpoint AWS PrivateLink)
- Seu crachá da empresa (Azure Link ID)
- Sua carta convite (hostname/FQDN para acesso de saída)

O segurança não consegue lidar com todos esses documentos sozinho. Então a boate contratou **especialistas** (Network Rules). Cada especialista verifica UM tipo de documento. O segurança (Network Policy) apenas pergunta aos especialistas: "Essa pessoa está na lista de permitidos ou na lista de bloqueados?"

**O jeito antigo**: o segurança tinha uma lista de IPs em papel grudada na prancheta.
**O jeito novo**: o segurança referencia equipes de especialistas (Network Rules) que gerenciam suas próprias listas.

**Armadilha do exame**: "Network Policy sozinha pode controlar acesso por hostname/FQDN?" → ERRADO! Network Policies sozinhas só lidam com IPs. Você precisa de **Network Rules** (tipo HOST_PORT) para controle baseado em FQDN. A regra é então referenciada pela política.
**Armadilha do exame**: "Network Rules são objetos de nível de conta?" → ERRADO! Network Rules são objetos de **nível de schema** (dentro de database.schema). Network **Policies** são de nível de conta.
**Armadilha do exame**: "Você precisa bloquear explicitamente todos os IPs públicos ao usar PrivateLink?" → SIM, se quiser bloquear acesso público. Apenas permitir uma regra PrivateLink NÃO bloqueia automaticamente IPs públicos. Você precisa de uma regra IPV4 separada na lista de bloqueio com `0.0.0.0/0`.

---

### PrivateLink vs Network Policies (Defesa em Profundidade)

São DUAS COISAS DIFERENTES que resolvem DOIS PROBLEMAS DIFERENTES:

| | PrivateLink | Network Policy |
|---|---|---|
| **O que faz** | Cria um **túnel privado** entre sua rede cloud e o Snowflake | Controla **quem pode entrar** via filtragem de IP/endpoint |
| **Problema que resolve** | **Conectividade** -- dados nunca cruzam a internet pública | **Controle de acesso** -- apenas fontes aprovadas podem conectar |
| **Analogia** | Construir um túnel subterrâneo privado até o banco | Colocar um segurança na porta do banco |
| **Edição** | Business Critical+ | TODAS as edições |
| **Sem o outro** | Tráfego é privado mas QUALQUER UM na sua rede interna pode acessar o Snowflake | Tráfego vai pela internet pública mas apenas IPs aprovados podem conectar |

**Defesa em profundidade = use AMBOS juntos:**
- PrivateLink garante que o tráfego não passe pela internet pública (túnel privado)
- Network Policy garante que apenas endpoints/IPs autorizados possam conectar (controle de acesso)
- PrivateLink SOZINHO NÃO previne acesso não autorizado de dentro da sua rede privada

**Gatilhos do exame:**
- "sem internet pública" + "conexão privada" → PrivateLink (Business Critical+)
- "restringir quem pode conectar" + "filtragem de IP" → Network Policy (todas as edições)
- "segurança máxima" + "conectividade privada E controle de acesso" → PrivateLink + Network Policy juntos
- "banco" / "saúde" / "HIPAA" / "sem internet pública" → Business Critical+ (PrivateLink disponível)

**Armadilha do exame**: "PrivateLink substitui Network Policies?" → ERRADO! Servem propósitos diferentes. PrivateLink = túnel (conectividade). Network Policy = segurança (controle de acesso). Você precisa de AMBOS para segurança máxima.
**Armadilha do exame**: "PrivateLink está disponível na edição Enterprise?" → ERRADO! PrivateLink requer **Business Critical+**.

---

---

## 2.6 CRIPTOGRAFIA E GERENCIAMENTO DE CHAVES

### Criptografia padrão:
- TODOS os dados criptografados em repouso e em trânsito
- Criptografia AES-256
- Automática, sem necessidade de configuração
- Disponível em TODAS as edições

### Rotação de chaves:
- Snowflake rotaciona chaves automaticamente a cada 30 dias
- Periodic rekeying = Enterprise+ (re-criptografa dados com nova chave)

### Tri-Secret Secure (Business Critical+):
- Chave gerenciada pelo cliente + chave gerenciada pelo Snowflake = chave composta
- Cliente controla uma das chaves de criptografia
- Se o cliente revogar sua chave → dados ficam inacessíveis
- Máximo controle do cliente sobre criptografia

**Armadilha do exame**: "Chaves gerenciadas pelo cliente?" → Tri-Secret Secure (BC+). SE VOCÊ VIR "chave gerenciada pelo cliente" com edição Enterprise → ERRADO! Tri-Secret Secure requer BUSINESS CRITICAL+, não Enterprise.
**Armadilha do exame**: "Chaves rotacionadas a cada?" → 30 dias (automático). SE VOCÊ VIR "90 dias" ou "anual" → ERRADO! Snowflake rotaciona chaves a cada 30 DIAS automaticamente, todas as edições.
**Armadilha do exame**: "Edição do periodic rekeying?" → Enterprise+. SE VOCÊ VIR "periodic rekeying" com "todas as edições" → ERRADO! Rekeying (re-criptografa dados ANTIGOS) = Enterprise+. ROTAÇÃO de chaves (nova chave para novos dados) = todas as edições.


### Exemplos de Perguntas de Cenário — Encryption & Key Management

**Cenário:** A healthcare company on Business Critical edition needs maximum control over their encryption keys. If there's a security breach, they want the ability to instantly make all Snowflake data inaccessible. What feature should they use?
**Resposta:** Tri-Secret Secure (Business Critical+). This creates a composite encryption key from a customer-managed key (in their cloud KMS) + Snowflake's key. If the customer revokes their key, all data becomes instantly inaccessible. This gives maximum customer control over encryption — the "kill switch" for data access.

**Cenário:** An auditor asks: "How often are encryption keys rotated in Snowflake?" and "Is old data re-encrypted with new keys?" What are the correct answers?
**Resposta:** Keys are automatically rotated every 30 days on ALL editions — this means new data gets encrypted with the new key. However, periodic rekeying (re-encrypting OLD data with the new key) requires Enterprise+ edition. Key rotation (all editions) ≠ periodic rekeying (Enterprise+). This distinction is a common exam trap.

---

---

## 2.7 RECURSOS DE GOVERNANÇA DE DADOS

### Dynamic Data Masking (Segurança de Nível de Coluna, Enterprise+):
- Aplique políticas de masking a colunas
- Roles diferentes veem dados diferentes (ex: RH vê CPF, outros veem ****)
- Política é uma função SQL que retorna valor mascarado ou não mascarado
- Vinculada a colunas em tabelas ou views

**Armadilha do exame**: "CPF visível apenas para HR_MANAGER?" → Dynamic Data Masking. SE VOCÊ VIR "filtrar linhas" ou "esconder linhas" para visibilidade de coluna → ERRADO! Isso é Row Access Policy. Masking = valores de COLUNA, não linhas.

### Row Access Policies (Segurança de Nível de Linha, Enterprise+):
- Controlam quais LINHAS um role pode ver
- Política retorna TRUE (mostrar linha) ou FALSE (esconder linha)
- Aplicada a tabelas ou views
- Exemplo: acesso baseado em região (time dos EUA vê apenas linhas dos EUA)

### Projection Policies (Enterprise+):
- Controlam quais colunas podem ser projetadas (SELECTionadas)
- Impedem roles específicos de executar SELECT em certas colunas

### Aggregation Policies (Enterprise+):
- Forçam consultas a agregar dados (sem linhas individuais)
- Proteção de privacidade

### Object Tagging:
- Aplique tags a qualquer objeto Snowflake
- Pares chave-valor
- Rastreie dados sensíveis, categorize objetos
- Tags propagam através da linhagem
- Disponível em TODAS as edições (alguns recursos Enterprise+)

### Masking Baseado em Tags (Tag-Based Masking, Enterprise+):

Tag-based masking combina **object tagging** + **masking policies** para proteger colunas automaticamente em escala.

**O problema que resolve:** Em uma grande empresa com centenas de tabelas, vincular manualmente uma política de masking a cada coluna sensível é lento, propenso a erros, e impossível de manter conforme novas colunas são adicionadas.

**Como funciona (3 passos):**
1. **Criar uma Tag** (ex: `PII_TYPE`)
2. **Vincular masking policy À tag** (`ALTER TAG PII_TYPE SET MASKING POLICY mask_pii`)
3. **Aplicar a tag às colunas** (`ALTER TABLE ... MODIFY COLUMN cpf SET TAG PII_TYPE = 'CPF'`)

Agora, QUALQUER coluna com essa tag automaticamente recebe a masking policy aplicada. Quando uma nova coluna é tagueada, ela é instantaneamente protegida -- sem necessidade de vinculação manual de política.

**Mágica da escalabilidade:** Você pode definir uma tag no **nível da tabela**, e TODAS as colunas daquela tabela herdam a tag + sua masking policy (onde os tipos de dados correspondem). Defina no **nível do schema**, e todas as novas tabelas/colunas são protegidas automaticamente.

```sql
-- Passo 1: Criar uma tag
CREATE TAG governance.tags.pii_type;

-- Passo 2: Criar masking policy e vincular à tag
CREATE MASKING POLICY mask_pii AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('HR_ADMIN') THEN val
    ELSE '***MASCARADO***'
  END;

ALTER TAG governance.tags.pii_type SET MASKING POLICY mask_pii;

-- Passo 3: Taguear colunas -- são instantaneamente mascaradas
ALTER TABLE employees MODIFY COLUMN cpf SET TAG governance.tags.pii_type = 'CPF';
ALTER TABLE employees MODIFY COLUMN email SET TAG governance.tags.pii_type = 'EMAIL';
-- Ambas as colunas agora são mascaradas para roles não-HR, automaticamente
```

### ELI5: O Adesivo Mágico (Tag-Based Masking)

Imagine que você tem um adesivo mágico que diz "ESCONDA ISSO." Qualquer papel que você colar esse adesivo se torna invisível para estranhos, mas visível para o chefe.

Em vez de colar um "feitiço de invisibilidade" (masking policy) em cada papel (coluna) um por um, você apenas gruda o adesivo mágico (tag) em qualquer papel. O adesivo carrega o feitiço com ele.

Melhor ainda: se você colar no **pasta** (tabela), cada papel dentro da pasta ganha o feitiço. Cole no **arquivo** (schema), e cada pasta + papel dentro é protegido.

**Gatilho do exame:** "governança escalável" / "proteção automática para novas colunas" / "centenas de tabelas com PII" → Tag-based Masking.
**Gatilho do exame:** "política segue a tag" / "uma política, muitas colunas" → Tag-based Masking.

**Armadilha do exame**: "Tag-based masking requer uma política separada para cada coluna?" → ERRADO! UMA política vinculada a UMA tag pode proteger colunas ilimitadas. Esse é o ponto principal.
**Armadilha do exame**: "Novas colunas com a mesma tag precisam de vinculação manual de política?" → ERRADO! A masking policy está na TAG, não na coluna. Novas colunas com a tag são automaticamente protegidas.

### Data Classification (Enterprise+):
- Detecta automaticamente dados sensíveis (PII, PHI)
- Usa função SYSTEM$CLASSIFY
- Identifica categorias semânticas (email, telefone, CPF, etc.)
- Pode aplicar tags automaticamente

### Access History (Enterprise+):
- View ACCOUNT_USAGE.ACCESS_HISTORY
- Mostra: quem acessou quais colunas, quando
- Útil para conformidade com LGPD/GDPR, auditoria
- Rastreia acesso de leitura e escrita

### Data Lineage:
- Rastreie fluxo de dados da origem ao destino
- View OBJECT_DEPENDENCIES em ACCOUNT_USAGE
- Veja quais views/tabelas dependem de outros objetos

### Trust Center (NOVO para COF-C03):
- Ferramenta de avaliação de segurança
- Escaneia conta contra melhores práticas de segurança
- Identifica riscos de segurança e recomendações
- Benchmarks CIS

### Melhores Práticas — Segurança
- UMA política de masking por coluna (não pode empilhar)
- Use masking baseado em tags para escalabilidade (tagueie colunas, política segue a tag)
- Network policies: comece com ALLOWED_IP_LIST, adicione BLOCKED_IP_LIST para exceções
- Defina DATA_RETENTION_TIME_IN_DAYS baseado em necessidades de conformidade, não em padrões


### Exemplos de Perguntas de Cenário — Data Governance Features

**Cenário:** A company's HR table has a SALARY column. HR managers should see actual salaries, but all other roles should see '****'. What feature should they use, and what's the limitation?
**Resposta:** Dynamic Data Masking (Enterprise+). Create a masking policy that checks the current role — if HR_MANAGER, return the actual value; otherwise return '****'. Attach it to the SALARY column. Key limitation: only ONE masking policy per column (you can't stack multiple policies). For scaling across many columns, use tag-based masking — tag columns as "sensitive" and the policy follows the tag.

**Cenário:** A multinational company wants US-based analysts to only see US customer rows, and EU analysts to only see EU rows, from the same CUSTOMERS table. What feature should they use?
**Resposta:** Row Access Policy (Enterprise+). Create a policy that checks the current role and returns TRUE only for rows matching that role's region. Apply it to the CUSTOMERS table. This is Row-Level Security — it filters ROWS, not columns. Do NOT confuse with Dynamic Data Masking, which hides column VALUES (not rows).

**Cenário:** A compliance officer needs to know which analysts accessed the PATIENT_RECORDS table's SSN column last month for a HIPAA audit. Where should they look?
**Resposta:** ACCOUNT_USAGE.ACCESS_HISTORY (Enterprise+). This view tracks who accessed which columns, when, and whether it was a read or write. It provides column-level access tracking — exactly what HIPAA/GDPR audits require. It has 365 days of retention with up to 3-hour latency.

---

---

## 2.8 POLÍTICAS DE PRIVACIDADE

### Data Clean Rooms:
- Ambientes seguros para colaboração de dados multi-party
- Cada parte mantém seus dados privados
- Execute análises aprovadas sem expor dados brutos

### Differential Privacy:
- Protege contra ataques de privacidade direcionados
- Enterprise+

**Armadilha do exame**: "Data Clean Room vs Row Access Policy?" → Clean Rooms = colaboração MULTI-PARTY com dados SEPARADOS. SE VOCÊ VIR "filtrar linhas na sua própria tabela" com Clean Room → ERRADO! Isso é Row Access Policy. Clean Room = colaboração entre organizações.
**Armadilha do exame**: "Edição do Differential Privacy?" → Enterprise+. SE VOCÊ VIR "Differential Privacy" com "edição Standard" → ERRADO! Também não confunda com Data Clean Rooms (recurso totalmente diferente).


### Exemplos de Perguntas de Cenário — Privacy Policies

**Cenário:** Two competing retail companies want to find how many customers they share in common without revealing their full customer lists to each other. What Snowflake feature enables this?
**Resposta:** Data Clean Rooms. Each party loads their customer data into the clean room environment. They run approved overlap analysis queries, but raw data stays private to each party — only aggregate results (e.g., "12,500 shared customers") are visible. Neither company sees the other's full customer list.

---

---

## 2.8b EDIÇÕES E MAPEAMENTO DE CONFORMIDADE (FAVORITO DO EXAME)

Esta é uma das áreas mais testadas. Você PRECISA saber quais recursos requerem qual edição.

### Edição Standard (base -- incluída em TODAS as edições):
- Criptografia automática (AES-256, em repouso + em trânsito)
- Network policies (listas de IPs permitidos/bloqueados)
- Suporte a MFA
- OAuth, SSO, autenticação federada
- Controle de acesso a nível de objeto (RBAC + DAC)
- Time Travel padrão (até **1 dia**)
- Fail-safe (7 dias além do Time Travel)
- Object tags (básico)
- Replicação de database (cross-account/cross-region)
- Streams, Tasks, Snowpipe
- Managed Access Schemas

### Edição Enterprise (adiciona governança + performance):
- **Dynamic Data Masking** (segurança de nível de coluna)
- **Row Access Policies** (segurança de nível de linha)
- **Aggregation Policies**, **Projection Policies**
- Time Travel estendido (até **90 dias**)
- Periodic rekeying de dados criptografados
- **Data Classification** (SYSTEM$CLASSIFY)
- View **ACCESS_HISTORY** (auditoria de nível de coluna)
- Multi-cluster warehouses
- Search optimization service
- Materialized views
- Query acceleration service
- Data Quality / Data Metric Functions
- Parâmetro MIN_DATA_RETENTION_TIME_IN_DAYS

### Edição Business Critical (adiciona conformidade + conectividade privada):
- Tudo do Enterprise MAIS:
- **Tri-Secret Secure** (chaves gerenciadas pelo cliente)
- **PrivateLink** (AWS PrivateLink, Azure Private Link, GCP Private Service Connect)
- Conformidade **HIPAA** e **HITRUST CSF**
- Conformidade **PCI DSS**
- **Failover/Failback de conta** (recuperação de desastres)
- Client redirect para continuidade de negócios
- Conectividade privada para internal stages
- Endpoints privados Amazon API Gateway para external functions

### Virtual Private Snowflake (VPS) (isolamento máximo):
- Tudo do Business Critical MAIS:
- **Metadata store dedicado** (separado da infraestrutura compartilhada)
- **Pool de computação dedicado** (warehouses virtuais isolados)
- Conformidade **ITAR** (International Traffic in Arms Regulations)
- Conformidade **FedRAMP** (Federal dos EUA)
- Suporte a **GovCloud**

### Referência Rápida — Árvore de Decisão "Qual Edição?"

| Se a pergunta menciona... | Resposta |
|---|---|
| Masking, row access, projection, aggregation policies | **Enterprise+** |
| Time Travel de 90 dias | **Enterprise+** |
| Periodic rekeying | **Enterprise+** |
| Multi-cluster warehouses | **Enterprise+** |
| Search optimization, materialized views | **Enterprise+** |
| Data classification (SYSTEM$CLASSIFY) | **Enterprise+** |
| PrivateLink / conectividade privada | **Business Critical+** |
| Tri-Secret Secure / chaves gerenciadas pelo cliente | **Business Critical+** |
| HIPAA, PCI DSS, HITRUST | **Business Critical+** |
| Failover / failback | **Business Critical+** |
| Metadata dedicado / computação dedicada | **Apenas VPS** |
| ITAR, FedRAMP, GovCloud | **VPS** |
| Network policies, MFA, criptografia, replicação | **TODAS as edições** (Standard+) |
| Managed Access Schemas | **TODAS as edições** |

### ELI5: Os Níveis do Hotel (Edições)

Pense nas edições do Snowflake como níveis de hotel:

**Standard** = um quarto de hotel limpo e seguro. Você ganha uma cama (criptografia), uma fechadura na porta (network policies), e uma recepção (MFA). Funciona perfeitamente para a maioria dos hóspedes.

**Enterprise** = um hotel boutique. Você ganha tudo do Standard MAIS um cofre no quarto (masking policies), serviço de quarto que traz apenas SUA comida (row access), um concierge que rastreia cada visitante (ACCESS_HISTORY), e uma vista melhor (materialized views, search optimization).

**Business Critical** = um resort privado de luxo. Você ganha tudo do Enterprise MAIS sua própria entrada privada (PrivateLink), sua própria chave do cofre-forte (Tri-Secret Secure), certificações de conformidade na parede (HIPAA, PCI), e um resort reserva em outra cidade (failover).

**VPS** = sua própria ilha privada. Tudo do Business Critical MAIS sua própria equipe (computação dedicada), sua própria sala de registros (metadata dedicado), e autorização de nível governamental (ITAR, FedRAMP).

**Armadilha do exame**: "PrivateLink disponível no Enterprise?" → ERRADO! Business Critical+.
**Armadilha do exame**: "Replicação de database requer Business Critical?" → ERRADO! Replicação disponível em TODAS as edições. FAILOVER requer Business Critical+.
**Armadilha do exame**: "Masking policies disponíveis no Standard?" → ERRADO! Enterprise+.
**Armadilha do exame**: "Time Travel de 90 dias no Standard?" → ERRADO! Standard = 1 dia máximo. Enterprise+ = até 90 dias.

---

## 2.9 ALERTAS E NOTIFICAÇÕES

### Alerts:
- Monitore condições na sua conta
- Disparam quando uma condição é atendida
- Podem enviar notificações
- Usam condições SQL

### Notifications:
- Notificações por email
- Integrações webhook
- Disparadas por alerts, resource monitors, tasks

**Armadilha do exame**: "Alerts vs Resource Monitors?" → Alerts = condições SQL customizadas em QUALQUER dado. SE VOCÊ VIR "uso de créditos" com Alerts → armadilha! Resource Monitors rastreiam CRÉDITOS. Alerts monitoram QUALQUER condição SQL.
**Armadilha do exame**: "Quem executa avaliações de alerts?" → Camada de Cloud Services (serverless). SE VOCÊ VIR "warehouse" executando alerts → ERRADO! Alerts executam em computação de CLOUD SERVICES, NÃO em um warehouse.
**Armadilha do exame**: "Alerts podem disparar..." → Notificações E execução de tasks. SE VOCÊ VIR "suspender warehouse" com Alerts → ERRADO! Isso é ação de resource monitor. Alerts disparam notificações/tasks, não suspensão.


### Exemplos de Perguntas de Cenário — Alerts and Notifications

**Cenário:** A data team wants to be notified whenever a specific staging table hasn't been updated in the last 24 hours. Should they use a Resource Monitor or an Alert?
**Resposta:** An Alert. Alerts use custom SQL conditions to monitor ANY data condition — including checking timestamps. Example: `CREATE ALERT ... IF (SELECT DATEDIFF('hour', MAX(load_ts), CURRENT_TIMESTAMP()) FROM staging_table) > 24 THEN ...`. Resource Monitors only track credit usage, not data conditions.

**Cenário:** A finance team wants to automatically suspend a warehouse when it exceeds 80% of its monthly credit budget. Should they use an Alert or a Resource Monitor?
**Resposta:** A Resource Monitor. Set up a resource monitor with an 80% threshold and "Notify & Suspend" action. Resource monitors are specifically designed for credit tracking and warehouse control. Alerts cannot suspend warehouses — they can only send notifications or trigger tasks.

---

---

## 2.10 REPLICAÇÃO E FAILOVER

### Database Replication:
- Copie databases entre contas/regiões
- Necessário para: compartilhamento de dados cross-region, recuperação de desastres
- Database primário (leitura-escrita) → Database secundário (somente leitura)
- Atualize o secundário para sincronizar mudanças

### Account Failover (Business Critical+):
- Promova conta secundária para primária
- Para recuperação de desastres
- Continuidade de negócios quando a região primária está indisponível

**Armadilha do exame**: "Compartilhar dados cross-region?" → Precisa de REPLICAÇÃO primeiro. SE VOCÊ VIR "compartilhamento direto" com cross-region → ERRADO! Shares são apenas mesma região. Cross-region requer replicação E DEPOIS compartilhamento.
**Armadilha do exame**: "Edição do failover?" → Business Critical+. SE VOCÊ VIR "failover" com edição Enterprise → ERRADO! Account failover = BC+ apenas. Não confunda com REPLICAÇÃO de database (disponível em tiers inferiores).


### Exemplos de Perguntas de Cenário — Replication and Failover

**Cenário:** A company on AWS US-East wants to share a database with their team on Azure Europe. Can they create a direct share?
**Resposta:** No. Direct shares only work within the same region AND same cloud provider. For cross-region or cross-cloud sharing, you must first replicate the database to the target region (`CREATE DATABASE ... AS REPLICA OF ...`), then create the share in that region. Replication first, then share.

**Cenário:** A company's primary Snowflake account in US-West goes down due to a regional outage. They have a replicated account in US-East. Can they switch to the US-East account? What edition do they need?
**Resposta:** They need Business Critical+ edition to use account failover. With failover enabled, they can promote the secondary account in US-East to primary. Database replication alone (available on lower tiers) copies data but doesn't allow you to promote secondary to primary — that's the failover capability that requires BC+.

---

---

## 2.11 RESOURCE MONITORS (MUITO TESTADO)

### O que eles fazem:
- Rastreiam uso de créditos para warehouses
- Definem cotas de créditos (mensal, semanal, diária, etc.)
- SEM custo adicional (apenas monitoram)

### Ações quando o limite é atingido:
1. **Notify**: envia alerta apenas
2. **Notify & Suspend**: finaliza consultas atuais, depois suspende o warehouse
3. **Notify & Suspend Immediately (Hard Suspend)**: cancela TODAS as consultas em execução E suspende o warehouse

**Armadilha do exame**: "Hard Suspend faz o quê?" → CANCELA consultas em execução imediatamente. SE VOCÊ VIR "espera consultas finalizarem" com Hard Suspend → ERRADO! Isso é Suspend regular. HARD Suspend = cancelamento imediato.
**Armadilha do exame**: "Resource monitors custam créditos?" → NÃO, custo zero. SE VOCÊ VIR "créditos por monitor" ou "custo adicional" → ERRADO! Resource monitors são GRATUITOS. Apenas monitoram, sem custo de computação.
**Armadilha do exame**: "Quem cria resource monitors?" → ACCOUNTADMIN. SE VOCÊ VIR "SYSADMIN cria resource monitors" → ERRADO! Apenas ACCOUNTADMIN (ou role com privilégio CREATE RESOURCE MONITOR).

### Podem ser definidos em:
- Nível da conta (monitora todos os warehouses)
- Nível do warehouse (monitora warehouse específico)


### Exemplos de Perguntas de Cenário — Resource Monitors

**Cenário:** An analytics warehouse is burning through credits. The admin sets a resource monitor at 90% with "Notify & Suspend." A critical report is running when the threshold is hit. What happens to the running query?
**Resposta:** With "Notify & Suspend" (regular suspend), the running query finishes first, then the warehouse suspends. If you need to stop queries immediately, use "Notify & Suspend Immediately" (hard suspend) — that cancels ALL running queries and suspends the warehouse instantly. This is a key exam distinction.

**Cenário:** The CFO asks: "How much does it cost to set up resource monitors across all our warehouses?" What's the answer?
**Resposta:** Zero. Resource monitors have NO additional cost — they are free. They simply track credit usage and trigger actions (notify, suspend, or hard suspend) when thresholds are reached. Only ACCOUNTADMIN (or a role with CREATE RESOURCE MONITOR privilege) can create them.

---

---

## 2.12 ACCOUNT_USAGE vs INFORMATION_SCHEMA (MUITO TESTADO)

| | ACCOUNT_USAGE | INFORMATION_SCHEMA |
|---|---|---|
| Localização | Database compartilhado SNOWFLAKE | Cada database |
| Latência | Até 45 min - 3 horas | Tempo real (sem latência) |
| Retenção | 1 ano (365 dias) | 7 dias a 6 meses (varia) |
| Objetos dropados | SIM (inclui dropados) | NÃO |
| Escopo | Conta inteira | Database único |
| Acesso | ACCOUNTADMIN (por padrão) | Qualquer role com acesso ao database |

### Views-chave de ACCOUNT_USAGE:
- **QUERY_HISTORY** → todas as consultas (365 dias)
- **LOGIN_HISTORY** → tentativas de login incluindo falhas (365 dias)
- **WAREHOUSE_METERING_HISTORY** → uso de créditos do warehouse
- **METERING_DAILY_HISTORY** → TODO uso de créditos (warehouses + serverless)
- **TABLE_STORAGE_METRICS** → armazenamento incluindo Fail-safe
- **ACCESS_HISTORY** → quem acessou o quê (Enterprise+)
- **OBJECT_DEPENDENCIES** → linhagem

### Views-chave de INFORMATION_SCHEMA:
- QUERY_HISTORY() → função, máximo 7 dias
- SERVERLESS_TASK_HISTORY() → créditos de tasks
- Tempo real, sem latência

**Armadilha do exame**: "Uso de créditos para Search Optimization + Clustering?" → METERING_DAILY_HISTORY. SE VOCÊ VIR "WAREHOUSE_METERING_HISTORY" para serverless → ERRADO! WAREHOUSE = apenas warehouses. DAILY = TODOS os serviços incluindo serverless.
**Armadilha do exame**: "Logins falhados de 6 meses atrás?" → ACCOUNT_USAGE.LOGIN_HISTORY. SE VOCÊ VIR "INFORMATION_SCHEMA" com "6 meses" → ERRADO! INFORMATION_SCHEMA máximo = 7 dias. 6 meses requer ACCOUNT_USAGE (365 dias).
**Armadilha do exame**: "Inclui objetos dropados?" → ACCOUNT_USAGE. SE VOCÊ VIR "INFORMATION_SCHEMA" com "objetos dropados" → ERRADO! INFORMATION_SCHEMA exclui objetos dropados. Apenas ACCOUNT_USAGE os mostra.
**Armadilha do exame**: "Resultados de consulta em tempo real?" → INFORMATION_SCHEMA. SE VOCÊ VIR "ACCOUNT_USAGE" com "tempo real" → ERRADO! ACCOUNT_USAGE tem latência de 45min-3h. INFORMATION_SCHEMA = tempo real, sem atraso.
**Armadilha do exame**: "QUERY_HISTORY máximo no Information Schema?" → 7 dias. SE VOCÊ VIR "365 dias" com INFORMATION_SCHEMA → ERRADO! 365 dias = ACCOUNT_USAGE. INFORMATION_SCHEMA QUERY_HISTORY = máximo 7 dias.


### Exemplos de Perguntas de Cenário — ACCOUNT_USAGE vs INFORMATION_SCHEMA

**Cenário:** A security team needs to investigate failed login attempts from the past 3 months. Which view should they query?
**Resposta:** ACCOUNT_USAGE.LOGIN_HISTORY (365 days retention). INFORMATION_SCHEMA only retains data for 7 days maximum, so 3-month-old data is only available in ACCOUNT_USAGE. Note: ACCOUNT_USAGE has up to 3-hour latency, so very recent logins (last few hours) might not appear yet.

**Cenário:** A DBA needs to check the current running queries RIGHT NOW to troubleshoot a performance issue. Should they use ACCOUNT_USAGE or INFORMATION_SCHEMA?
**Resposta:** INFORMATION_SCHEMA — it's real-time with no latency. Use `SELECT * FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())` to see current and recent queries instantly. ACCOUNT_USAGE has up to 3-hour latency, which is useless for real-time troubleshooting.

**Cenário:** An admin wants to find all tables that were dropped in the last 6 months across the entire account. Which should they use?
**Resposta:** ACCOUNT_USAGE. It has two key advantages here: (1) it includes dropped objects (INFORMATION_SCHEMA does NOT show dropped objects), and (2) it has 365-day retention (INFORMATION_SCHEMA max is 7 days). ACCOUNT_USAGE also covers the entire account scope, not just one database.

---

---

## 2.13 CALCULANDO CRÉDITOS DO WAREHOUSE

### Fórmula:
Créditos = (créditos_por_hora_do_tamanho_do_warehouse) × (tempo_de_execução_em_horas) × (número_de_clusters)

### Exemplos:
- Warehouse XS rodando 1 hora = 1 crédito
- Warehouse Large rodando 30 minutos = 8 × 0.5 = 4 créditos
- Multi-cluster (2 clusters) Medium rodando 1 hora = 4 × 1 × 2 = 8 créditos

### Regras de cobrança:
- Cobrança por segundo com mínimo de 60 segundos
- Warehouse suspenso = 0 créditos
- Redimensionamento entra em vigor para NOVAS consultas (consultas em execução usam tamanho antigo)
- Cloud Services: cobrado apenas se > 10% dos créditos diários de warehouse

**Armadilha do exame**: "Cobrança mínima para um warehouse?" → 60 segundos. SE VOCÊ VIR "1 segundo" como mínimo → ERRADO! Cobrança por segundo começa APÓS o mínimo de 60 segundos. Primeiro minuto sempre cobrado integralmente.
**Armadilha do exame**: "Warehouse XL por 1 hora?" → 16 créditos. SE VOCÊ VIR "8 créditos" para XL → ERRADO! Cada tamanho DOBRA: XS=1, S=2, M=4, L=8, XL=16. L=8, XL=16.
**Armadilha do exame**: "Cloud Services sempre custam extra?" → ERRADO. SE VOCÊ VIR "sempre cobrado" com Cloud Services → armadilha! Cobrado apenas se Cloud Services exceder 10% dos créditos diários de warehouse. Abaixo de 10% = GRATUITO.


### Exemplos de Perguntas de Cenário — Calculating Warehouse Credits

**Cenário:** A company runs a multi-cluster warehouse (Medium size, 3 clusters active) for 2 hours. How many credits does this consume?
**Resposta:** Medium = 4 credits/hour. With 3 clusters running for 2 hours: 4 × 3 × 2 = 24 credits. Each cluster is a separate instance of the warehouse, so credits multiply by the number of active clusters.

**Cenário:** An admin resizes a warehouse from Small to XL while a query is still running. Does the running query benefit from the larger size?
**Resposta:** No. Running queries continue on the OLD size. Only NEW queries submitted after the resize use the XL warehouse. The running query completes on the Small warehouse. This is a common exam trap — resizing is not retroactive for in-flight queries.

---

---

## 2.14 LOGGING E TRACING

### Event Tables:
- Capturam mensagens de log, eventos de trace de UDFs e procedures
- Associe event table com um database
- Disponível em TODAS as edições (alguns recursos Enterprise+)

### Activity Logging:
- Histórico de consultas, histórico de login em ACCOUNT_USAGE
- Pode rastrear atividade de usuários para conformidade

**Armadilha do exame**: "Event tables vs histórico de consultas do ACCOUNT_USAGE?" → Event tables = logs e traces de UDFs/procedures. SE VOCÊ VIR "histórico de consultas SQL" com event tables → ERRADO! Consultas SQL vão para ACCOUNT_USAGE. Event tables = logs de runtime de UDFs/procedures.
**Armadilha do exame**: "Event tables requerem Enterprise?" → NÃO, TODAS as edições. SE VOCÊ VIR "Enterprise necessário" com event tables → ERRADO! Event tables estão disponíveis em TODAS as edições (alguns recursos avançados Enterprise+).
**Armadilha do exame**: "Onde você configura uma event table?" → Associe a um DATABASE. SE VOCÊ VIR "nível de conta" ou "nível de schema" com configuração de event table → ERRADO! Event tables são associadas a um DATABASE, não conta ou schema.


### Exemplos de Perguntas de Cenário — Logging and Tracing

**Cenário:** A Python UDF is throwing intermittent errors in production. The developer wants to add logging to understand what's happening at runtime. Where do the logs go?
**Resposta:** Configure an Event Table and associate it with the database. The UDF can emit log messages that are captured in the event table. Event tables store UDF/procedure runtime logs and trace events — this is different from ACCOUNT_USAGE.QUERY_HISTORY, which tracks SQL query execution (not UDF internal logs). Event tables are available on ALL editions.

**Cenário:** An auditor wants to see all SQL queries executed against the FINANCE database in the last 90 days. Should they use event tables or ACCOUNT_USAGE?
**Resposta:** ACCOUNT_USAGE.QUERY_HISTORY — it stores SQL query history for 365 days across the entire account. Event tables are for UDF/procedure runtime logs and traces, NOT for SQL query history. This is a key distinction: SQL queries → ACCOUNT_USAGE. UDF/procedure logs → Event Tables.

---

---

## 2.15 NÍVEIS DE PARÂMETROS E PRECEDÊNCIA

O Snowflake tem QUATRO níveis onde configurações podem ser aplicadas. Nem todos os parâmetros suportam todos os níveis.

### Os quatro níveis:
- **Conta** -- definido pelo ACCOUNTADMIN, aplica-se a todos (ALTER ACCOUNT SET ...)
- **Objeto** -- definido em um warehouse, database, schema, ou tabela específico (ALTER WAREHOUSE wh1 SET ...)
- **Usuário** -- definido POR UM ADMIN no objeto de usuário (ALTER USER debora SET ...). O usuário NÃO PODE mudar isso sozinho.
- **Sessão** -- definido pelo usuário para sua conexão atual apenas (ALTER SESSION SET ...)

Não confunda nível de USUÁRIO com nível de SESSÃO. Nível de usuário = um admin atribui uma configuração AO usuário (o usuário não pode mudar). Nível de sessão = o usuário define PARA si mesmo (temporário, apenas conexão atual).

### Regra de Precedência: O mais específico vence (para parâmetros)
- Sessão > Objeto > Conta
- Exemplo: Timeout da conta = 3600s, timeout do warehouse = 600s, você executa ALTER SESSION SET STATEMENT_TIMEOUT_IN_SECONDS = 120 -- suas queries expiram em 120s

### O Conceito do Funil (Hierarquia de Parâmetros)

Pense na precedência de parâmetros como um **funil** -- configurações fluem do nível mais amplo (Conta) até o mais estreito (Sessão), e o mais estreito vence:

```
┌─────────────────────────────────┐
│         CONTA (mais amplo)      │  ← Padrão para todos
│   ┌─────────────────────────┐   │
│   │    OBJETO (warehouse,   │   │  ← Sobrescreve conta para este objeto
│   │    database, schema,    │   │
│   │    table)               │   │
│   │   ┌─────────────────┐   │   │
│   │   │   SESSÃO         │   │   │  ← Sobrescreve tudo (mais específico)
│   │   │   (mais estreito)│   │   │
│   │   └─────────────────┘   │   │
│   └─────────────────────────┘   │
└─────────────────────────────────┘
```

**Mas existem EXCEÇÕES para "mais específico vence":**

1. **Network Policy**: Nível de usuário **SUBSTITUI** (não complementa) nível de conta. Se a conta permite IPs A+B e o usuário permite apenas C, o usuário SOMENTE pode conectar de C. Isso NÃO é aditivo -- é uma substituição completa.

2. **MIN_DATA_RETENTION_TIME_IN_DAYS** (Enterprise+): Este é um **PISO** de nível de conta. Ninguém pode definir DATA_RETENTION_TIME_IN_DAYS abaixo deste valor, mesmo em objetos individuais. Se MIN é 7, você não pode definir a retenção de uma tabela como 1 dia -- o Snowflake aplica o mínimo. Isso protege contra purga acidental ou maliciosa de dados.

3. **Políticas de segurança** (masking, row access, network): São **APLICADAS independente da sessão**. Um usuário não pode ALTER SESSION para contornar qualquer política de segurança. Ponto final.

### Parâmetros chave para conhecer:

| Parâmetro | Níveis | Notas |
|---|---|---|
| STATEMENT_TIMEOUT_IN_SECONDS | Conta, Objeto (warehouse), Sessão | Mata queries longas. Sessão sobrescreve. |
| DATA_RETENTION_TIME_IN_DAYS | Conta, Objeto (database/schema/table) | Janela de Time Travel (0-90 dias). Tabela > Schema > Database > Conta. NÃO é configurável por sessão. |
| MIN_DATA_RETENTION_TIME_IN_DAYS | Apenas Conta | Piso que objetos não podem ficar abaixo. Apenas Enterprise+. |
| NETWORK_POLICY | Conta, Usuário | Nível de usuário sobrescreve nível de conta. NÃO é configurável por sessão. Controlado apenas por admin. |
| TIMEZONE | Conta, Sessão | Padrão UTC. Sessão sobrescreve conta. |

### O que PODE vs NÃO PODE ser sobrescrito por sessão:

| Sessão pode sobrescrever? | Sim | Não |
|---|---|---|
| Exemplos | STATEMENT_TIMEOUT, TIMEZONE, DATE_OUTPUT_FORMAT, QUERY_TAG | DATA_RETENTION, NETWORK_POLICY, REQUIRE_STORAGE_INTEGRATION, MIN_DATA_RETENTION |
| Por quê | Estas são preferências de usuário / comportamento de query | Estas são segurança/governança -- controladas por admin |

### Confusão Comum

Não confunda estes conceitos parecidos:
- **Network policy no nível de usuário** vs **parâmetro de sessão**: Network policy é definida POR UM ADMIN no objeto de usuário. O usuário não pode mudar. NÃO é uma configuração de sessão.
- **DATA_RETENTION na tabela** vs **sobrescrita de sessão**: Retenção é definida no objeto. Você não pode ALTER SESSION para mudar quanto tempo o Time Travel funciona.
- **"Mais específico vence"** aplica-se a PARÂMETROS. Para POLÍTICAS DE SEGURANÇA, a regra é "sempre aplicada" -- não há cadeia de sobrescrita.
- **MIN_DATA_RETENTION vs DATA_RETENTION**: MIN é um PISO de nível de conta (Enterprise+). DATA_RETENTION é configurável por objeto. MIN impede qualquer um de ficar abaixo do piso. Se MIN=7 e alguém tenta definir uma tabela como 1, o Snowflake usa 7.

**Armadilha do exame**: "Sessão sobrescreve tudo" -- ERRADO. Sessão só sobrescreve PARÂMETROS (timeout, timezone). Políticas de segurança (network policy, masking, row access) são APLICADAS independente da sessão. SE VOCÊ VIR "ALTER SESSION" + "contornar política" numa questão -- a resposta é ERRADO.
**Armadilha do exame**: "Nível de usuário e nível de sessão são a mesma coisa" -- ERRADO. Nível de usuário = admin define NO usuário (ALTER USER). Nível de sessão = usuário define PARA si mesmo (ALTER SESSION). Network policies são nível de usuário (controladas por admin), NÃO nível de sessão.

---

## REVISÃO RÁPIDA — Domínio 2

1. RBAC = privilégios para roles para usuários. DAC = dono concede acesso.
2. ACCOUNTADMIN = role principal, faturamento, shares, resource monitors
3. SECURITYADMIN = grants, network policies
4. USERADMIN = criar usuários e roles
5. SYSADMIN = criar databases, warehouses, schemas
6. ORGADMIN = nível de organização, criar contas
7. Custom roles → conceder ao SYSADMIN (melhor prática)
8. Dono do objeto = role que o criou
9. MFA = Duo Security, auto-inscrição
10. Key pair = acesso programático, sem senha
11. Network policies = listas de IPs permitidos/bloqueados, TODAS as edições
12. Todos os dados criptografados AES-256 automaticamente
13. Tri-Secret Secure = BC+, chave gerenciada pelo cliente
14. Políticas de masking = Enterprise+, nível de coluna
15. Row access policies = Enterprise+, nível de linha
16. Data classification = Enterprise+, detecta PII automaticamente
17. Access History = Enterprise+, auditoria de quem acessou o quê
18. Trust Center = avaliação de postura de segurança (NOVO)
19. Resource monitors = custo zero, rastreiam créditos, podem suspender
20. Hard Suspend = cancela consultas em execução imediatamente
21. ACCOUNT_USAGE: 365 dias, até 3h de latência, inclui objetos dropados
22. INFORMATION_SCHEMA: tempo real, 7 dias, por database
23. METERING_DAILY_HISTORY = todo uso de créditos (serverless incluído)
24. Replicação necessária para compartilhamento cross-region
25. Failover = apenas BC+

---

## PARES CONFUSOS — Domínio 2

| Eles perguntam sobre... | A resposta é... | NÃO... |
|---|---|---|
| Quem gerencia grants | SECURITYADMIN | ACCOUNTADMIN |
| Quem cria usuários | USERADMIN | SECURITYADMIN |
| Quem cria databases | SYSADMIN | ACCOUNTADMIN |
| Quem vê faturamento | ACCOUNTADMIN | SYSADMIN |
| Quem cria Shares | ACCOUNTADMIN | SYSADMIN |
| Quem cria contas na org | ORGADMIN | ACCOUNTADMIN |
| Masking de coluna | Dynamic Data Masking (Enterprise+) | Row Access Policy |
| Filtragem de linhas | Row Access Policy (Enterprise+) | Masking Policy |
| Chaves gerenciadas pelo cliente | Tri-Secret Secure (BC+) | Periodic rekeying |
| Periodic rekeying | Enterprise+ | Business Critical |
| Custo do resource monitor | Zero (gratuito) | Créditos por monitor |
| Hard Suspend | Cancela consultas em execução | Espera consultas finalizarem |
| Suspend | Espera consultas finalizarem | Cancela imediatamente |
| Latência do Account Usage | Até 3 horas | Tempo real |
| Retenção do Information Schema | 7 dias (QUERY_HISTORY) | 365 dias |
| Objetos dropados visíveis | ACCOUNT_USAGE | INFORMATION_SCHEMA |
| METERING_DAILY_HISTORY | Todos os serviços (serverless também) | Apenas warehouses |
| WAREHOUSE_METERING_HISTORY | Apenas warehouses | Serviços serverless |

---

## RESUMO AMIGÁVEL — Domínio 2

### ÁRVORES DE DECISÃO POR CENÁRIO
Quando você ler uma questão, encontre o padrão:

**"A equipe de segurança de um cliente quer controlar quem gerencia grants de acesso em toda a conta..."**
→ SECURITYADMIN
→ NÃO ACCOUNTADMIN (ACCOUNTADMIN pode, mas SECURITYADMIN é o role designado para grants)

**"Um cliente pergunta: quem deve criar o data warehouse e databases para a equipe de analytics?"**
→ SYSADMIN (o construtor)
→ NÃO ACCOUNTADMIN (exagero para isso)

**"Uma organização precisa criar uma nova conta Snowflake em uma região diferente..."**
→ ORGADMIN
→ NÃO ACCOUNTADMIN (ACCOUNTADMIN é por conta, não nível de organização)

**"Um cliente quer que sua equipe de RH veja CPF completo mas todos os outros vejam valores mascarados..."**
→ Dynamic Data Masking (nível de coluna, Enterprise+)
→ NÃO Row Access Policy (isso filtra linhas, não colunas)

**"A equipe dos EUA de um cliente deve ver apenas linhas de clientes dos EUA..."**
→ Row Access Policy (Enterprise+)
→ NÃO Dynamic Data Masking (isso esconde valores de coluna, não linhas)

**"Um cliente de saúde precisa controlar suas próprias chaves de criptografia..."**
→ Tri-Secret Secure (Business Critical+)
→ NÃO apenas "criptografia" (criptografia é automática para todos)

**"Um cliente quer saber o uso total de créditos incluindo recursos serverless..."**
→ METERING_DAILY_HISTORY (cobre tudo)
→ NÃO WAREHOUSE_METERING_HISTORY (apenas warehouses)

**"Um cliente quer dados em tempo real sobre consultas em execução..."**
→ INFORMATION_SCHEMA (tempo real, sem latência)
→ NÃO ACCOUNT_USAGE (até 3h de atraso)

**"Um cliente quer histórico de login de 6 meses atrás..."**
→ ACCOUNT_USAGE.LOGIN_HISTORY (365 dias)
→ NÃO INFORMATION_SCHEMA (máximo 7 dias)

**"Um admin precisa parar um warehouse descontrolado de queimar créditos..."**
→ Resource Monitor → Notify & Suspend Immediately (hard suspend)
→ Custo zero para configurar o monitor em si

**"Um novo engenheiro de dados entra na empresa. O admin cria seu usuário. Qual role o engenheiro recebe automaticamente?"**
→ PUBLIC (todo usuário recebe PUBLIC automaticamente)
→ Roles adicionais devem ser explicitamente concedidos

**"Os custom roles de um cliente não conseguem acessar databases que SYSADMIN criou. Por quê?"**
→ Custom roles NÃO estão concedidos ao SYSADMIN (violação de melhor prática)
→ Correção: GRANT custom_role TO ROLE SYSADMIN (para que a hierarquia flua corretamente)

**"Uma equipe de conformidade precisa saber quais colunas um analista acessou no mês passado..."**
→ Access History (ACCOUNT_USAGE.ACCESS_HISTORY, Enterprise+)
→ Mostra quem leu/escreveu quais colunas e quando

**"Os dados de um cliente têm PII (emails, CPF, telefones) espalhados por centenas de tabelas..."**
→ Data Classification (SYSTEM$CLASSIFY, Enterprise+)
→ Detecta automaticamente categorias de dados sensíveis

**"Uma auditoria de segurança pergunta: estamos seguindo as melhores práticas de segurança do Snowflake?"**
→ Trust Center (escaneia conta, benchmarks CIS, recomendações)

**"Um cliente quer conectar seu provedor de identidade Okta para single sign-on..."**
→ Federated Authentication / SSO (SAML 2.0)
→ Disponível em TODAS as edições

**"Uma conta de serviço precisa se conectar ao Snowflake de um script Python sem senha..."**
→ Key Pair Authentication (chave pública/privada RSA)
→ NÃO OAuth (isso é para apps voltados ao usuário)

**"Um cliente tem resource monitor definido em 80% com Notify & Suspend. Consultas atuais continuam rodando. Eles querem que consultas PAREM imediatamente..."**
→ Mude para Notify & Suspend Immediately (hard suspend)
→ Suspend regular espera consultas finalizarem; Hard Suspend as cancela

**"Um cliente quer ver uma tabela dropada que foi deletada 3 meses atrás no histórico de consultas..."**
→ ACCOUNT_USAGE (inclui objetos dropados, retenção de 365 dias)
→ NÃO INFORMATION_SCHEMA (NÃO mostra objetos dropados)

**"Um cliente precisa de network policies diferentes para seus usuários admin vs usuários regulares..."**
→ Network policy de nível de usuário (sobrescreve nível de conta)
→ Nível de conta é o padrão; nível de usuário é mais específico

**"Um cliente pergunta: com que frequência o Snowflake rotaciona chaves de criptografia?"**
→ A cada 30 dias (automático, todas as edições)
→ Periodic rekeying (re-criptografa dados com nova chave) = Enterprise+
→ São DIFERENTES: rotação = nova chave para novos dados, rekeying = re-criptografa dados antigos também

**"Um database role é criado para gerenciar acesso dentro do database ANALYTICS. Um usuário pode ativá-lo diretamente?"**
→ NÃO. Database roles não podem ser ativados diretamente em uma sessão.
→ Deve ser concedido a um account role primeiro.

**"Um usuário precisa de permissões de múltiplos roles ao mesmo tempo em uma sessão..."**
→ Secondary Roles (USE SECONDARY ROLES ALL)
→ Combina permissões de todos os roles concedidos

---

### MNEMÔNICOS PARA MEMORIZAR

**Hierarquia de roles = "A-S-U-S-P" (de cima para baixo)**
- **A**CCOUNTADMIN → o chefe (faturamento, shares, resource monitors)
- **S**ECURITYADMIN → o segurança (grants, network policies)
- **U**SERADMIN → RH (cria usuários & roles)
- **S**YSADMIN → o construtor (databases, warehouses, schemas)
- **P**UBLIC → todos recebem automaticamente

**Quem faz o quê = "BASU"**
- **B**illing (faturamento) → ACCOUNTADMIN
- **A**ccess grants (concessões de acesso) → SECURITYADMIN
- **S**tuff (objetos) → SYSADMIN
- **U**sers (usuários) → USERADMIN

**ACCOUNT_USAGE vs INFORMATION_SCHEMA = "Antigo vs Agora"**
- ACCOUNT_USAGE = dados ANTIGOS (365 dias, mas atrasado até 3h)
- INFORMATION_SCHEMA = dados de AGORA (tempo real, mas apenas 7 dias)

**Níveis de criptografia = "A-P-T" (All-Periodic-Tri)**
- **A**ES-256 = TODAS as edições (automático)
- **P**eriodic rekeying = Enterprise+
- **T**ri-Secret Secure = Business Critical+

**Governança Enterprise+ = "MARC" (Masking, Access history, Row access, Classification)**
- Todos os quatro são recursos Enterprise+
- Pense: "Você MARC dados sensíveis"

---

### PRINCIPAIS ARMADILHAS — Domínio 2

1. **"ACCOUNTADMIN deve ser o role padrão"** → ERRADO. Melhor prática: usar SYSADMIN ou inferior como padrão.
2. **"SECURITYADMIN cria usuários"** → ERRADO. USERADMIN cria usuários.
3. **"ACCOUNTADMIN gerencia grants"** → COMPLICADO. SECURITYADMIN é o gerenciador designado de grants. ACCOUNTADMIN PODE fazer (herda tudo), mas o exame quer SECURITYADMIN.
4. **"Network policies requerem Enterprise"** → ERRADO. TODAS as edições.
5. **"MFA requer Enterprise"** → ERRADO. TODAS as edições.
6. **"Resource monitors custam créditos"** → ERRADO. Custo zero.
7. **"Hard Suspend espera consultas finalizarem"** → ERRADO. Hard Suspend CANCELA consultas em execução imediatamente.
8. **"INFORMATION_SCHEMA mostra objetos dropados"** → ERRADO. Apenas ACCOUNT_USAGE mostra objetos dropados.
9. **"ACCOUNT_USAGE é tempo real"** → ERRADO. Até 3 horas de latência.
10. **"Política de masking = filtragem de linhas"** → ERRADO. Masking = valores de coluna. Row Access Policy = filtragem de linhas.

---

### ATALHOS DE PADRÃO — "Se você vir ___, a resposta é ___"

| Se a questão menciona... | A resposta quase sempre é... |
|---|---|
| "faturamento", "monitoramento de custos" | ACCOUNTADMIN |
| "gerenciar grants", "revogar acesso" | SECURITYADMIN |
| "criar usuários", "criar roles" | USERADMIN |
| "criar database", "criar warehouse" | SYSADMIN |
| "criar contas na org" | ORGADMIN |
| "esconder valores de coluna por role" | Dynamic Data Masking (Enterprise+) |
| "filtrar linhas por role" | Row Access Policy (Enterprise+) |
| "chave gerenciada pelo cliente" | Tri-Secret Secure (BC+) |
| "rotação de chave a cada 30 dias" | Automático (todas as edições) |
| "periodic rekeying" | Enterprise+ |
| "detectar PII automaticamente" | Data Classification (Enterprise+) |
| "quem acessou qual coluna" | Access History (Enterprise+) |
| "postura de segurança", "benchmark CIS" | Trust Center |
| "lista de IPs permitidos/bloqueados" | Network Policy (todas as edições) |
| "acesso programático, sem senha" | Key Pair Authentication |
| "Duo Security" | MFA |
| "SAML 2.0" | Federated Auth / SSO |
| "histórico de 365 dias" | ACCOUNT_USAGE |
| "informação de consulta em tempo real" | INFORMATION_SCHEMA |
| "uso de créditos serverless" | METERING_DAILY_HISTORY |
| "uso de créditos apenas warehouse" | WAREHOUSE_METERING_HISTORY |
| "parar warehouse queimando créditos" | Resource Monitor |

---

## DICAS PARA O DIA DO EXAME — Domínio 2 (20% = ~20 questões)

**Antes de estudar este domínio:**
- Flashcard dos 5 roles de sistema + o que cada um faz — este é o tópico #1 mais testado aqui
- Flashcard diferenças ACCOUNT_USAGE vs INFORMATION_SCHEMA (latência, retenção, objetos dropados)
- Conheça os recursos de governança Enterprise+: "MARC" (Masking, Access history, Row access, Classification)

**Durante o exame — questões do Domínio 2:**
- Leia a ÚLTIMA sentença primeiro (a questão real) — depois leia o cenário
- Elimine 2 respostas obviamente erradas imediatamente
- Se perguntam "qual ROLE" → mentalmente percorra a hierarquia: ACCOUNTADMIN > SECURITYADMIN > USERADMIN > SYSADMIN > PUBLIC
- Se perguntam sobre VER dados antigos → verifique: quão antigo? Tempo real = INFORMATION_SCHEMA. Histórico = ACCOUNT_USAGE.
- Se perguntam sobre RECURSOS DE SEGURANÇA → verifique: todas as edições? Enterprise+? BC+?
- Se mencionam CRIPTOGRAFIA → pense A-P-T: AES (todas), Periodic rekeying (Ent+), Tri-Secret (BC+)

---

## UMA LINHA POR TÓPICO — Domínio 2

| Tópico | Resumo em uma linha |
|---|---|
| RBAC + DAC | RBAC: privilégios → roles → usuários. DAC: dono do objeto concede acesso. Ambos funcionam juntos. |
| ACCOUNTADMIN | Role principal: faturamento, shares, resource monitors. NÃO para uso diário. |
| SECURITYADMIN | Gerencia grants e network policies. O "segurança." |
| USERADMIN | Cria usuários e roles. O "departamento de RH." |
| SYSADMIN | Cria databases, warehouses, schemas. O "construtor." Custom roles → conceder aqui. |
| ORGADMIN | Nível de organização: cria contas entre regiões. Não está na hierarquia regular. |
| PUBLIC | Todo usuário recebe automaticamente. Nível mais baixo. |
| Database roles | Escopo para um database, não pode ativar diretamente, deve conceder a account role. |
| Secondary roles | USE SECONDARY ROLES ALL = combinar permissões de múltiplos roles em uma sessão. |
| MFA | Duo Security, auto-inscrição, todas as edições. Melhor prática para ACCOUNTADMIN. |
| SSO / Federated Auth | SAML 2.0, IdP externo (Okta, Azure AD), todas as edições. |
| OAuth | External ou Snowflake OAuth, sem compartilhamento de senha, todas as edições. |
| Key Pair Auth | Chaves RSA para acesso programático/CLI, sem necessidade de senha. |
| Network Policies | Listas de IPs permitidos/bloqueados, nível de conta ou usuário, usuário sobrescreve conta, todas as edições. |
| Criptografia | AES-256 automático (todas), periodic rekeying (Ent+), Tri-Secret Secure (BC+). |
| Dynamic Data Masking | Nível de coluna, baseado em role, Enterprise+. RH vê CPF, outros veem ****. |
| Row Access Policies | Filtragem de linhas por role, Enterprise+. Time dos EUA vê apenas linhas dos EUA. |
| Data Classification | SYSTEM$CLASSIFY detecta PII automaticamente, Enterprise+. |
| Access History | Quem acessou quais colunas e quando, Enterprise+, ACCOUNT_USAGE. |
| Trust Center | Scan de postura de segurança, benchmarks CIS, recomendações. Tópico NOVO. |
| Object Tagging | Tags chave-valor em qualquer objeto, propagam através da linhagem. |
| Resource Monitors | Rastreiam uso de créditos, custo zero, podem notificar/suspender/hard-suspend. |
| ACCOUNT_USAGE | 365 dias, até 3h de latência, inclui objetos dropados, acesso ACCOUNTADMIN. |
| INFORMATION_SCHEMA | Tempo real, máximo 7 dias, por database, qualquer role com acesso ao DB. |
| METERING_DAILY_HISTORY | Todo uso de créditos incluindo serverless (clustering, pipes, etc.). |
| Replicação | Copia databases entre contas/regiões. Necessário para compartilhamento cross-region. |
| Failover | Promove secundário para primário. Apenas BC+. Para recuperação de desastres. |

---

## FLASHCARDS — Domínio 2

**P:** Qual é a hierarquia de roles de cima para baixo?
**R:** ACCOUNTADMIN > SECURITYADMIN > USERADMIN + SYSADMIN > PUBLIC. ACCOUNTADMIN = SECURITYADMIN + SYSADMIN combinados.

**P:** O que SECURITYADMIN faz?
**R:** Possui MANAGE GRANTS — pode conceder/revogar qualquer privilégio em qualquer objeto. Também herda USERADMIN.

**P:** O que USERADMIN faz?
**R:** Cria e gerencia usuários e roles. NÃO possui objetos de dados.

**P:** O que SYSADMIN faz?
**R:** Cria e possui warehouses, databases, schemas e todos os objetos de dados. Padrão recomendado para criar objetos.

**P:** Quais modelos de controle de acesso o Snowflake usa?
**R:** Ambos RBAC (Baseado em Role) E DAC (Discricionário). RBAC para roles, DAC porque donos de objetos controlam acesso.

**P:** Qual a diferença entre ACCOUNT_USAGE e INFORMATION_SCHEMA?
**R:** ACCOUNT_USAGE: latência 45min-3h, retenção 365 dias, no database compartilhado SNOWFLAKE. INFORMATION_SCHEMA: tempo real, 7 dias a 6 meses (varia por view), apenas por database.

**P:** Como network policies funcionam?
**R:** ALLOWED_IP_LIST (whitelist) + BLOCKED_IP_LIST (blacklist). O mais restritivo vence. Pode ser definido no nível de conta ou usuário.

**P:** O que um resource monitor rastreia?
**R:** Uso de CRÉDITOS, NÃO contagem de consultas. Ações: Notify, Notify & Suspend, Notify & Suspend Immediately. Pode ser definido no nível de CONTA ou WAREHOUSE.

**P:** Qual edição é necessária para políticas de masking?
**R:** Enterprise Edition ou superior. Uma política de masking por coluna. Vinculada via ALTER TABLE.

**P:** O que é Tri-Secret Secure?
**R:** Chave gerenciada pelo cliente (via cloud KMS) + chave gerenciada pelo Snowflake = chave mestra composta. Apenas Business Critical+. Se o cliente revogar sua chave, dados ficam inacessíveis.

**P:** O que é periodic rekeying?
**R:** Snowflake automaticamente re-criptografa dados com novas chaves. Enterprise+. Acontece de forma transparente em background.

**P:** Quais são os métodos de autenticação?
**R:** Usuário/senha, MFA (via Duo), key pair authentication, SSO (SAML 2.0 via Okta/ADFS/etc.), OAuth (Snowflake OAuth ou External OAuth).

**P:** O que é object tagging?
**R:** Rotular objetos (tabelas, colunas) com tags chave-valor para governança. Útil para classificar dados sensíveis. Tags propagam via linhagem.

**P:** O que é access history?
**R:** View ACCOUNT_USAGE.ACCESS_HISTORY — mostra quem leu/escreveu quais dados, incluindo colunas. Para auditoria e conformidade.

**P:** Row access policy vs masking policy?
**R:** Row access policy: filtra LINHAS baseado em contexto do usuário (role, usuário). Masking policy: mascara valores de COLUNA (ex: mostra apenas últimos 4 dígitos do CPF).

**P:** O que resource monitors NÃO podem fazer?
**R:** Não podem cancelar consultas já em execução. Apenas impedem NOVAS consultas de iniciar. Também não rastreiam custos serverless (Snowpipe, auto-clustering).

**P:** Qual a diferença entre replicação de database e replicação de conta?
**R:** Replicação de database: copia dados + objetos. Replicação de conta: copia usuários, roles, warehouses, resource monitors, network policies.

**P:** Como calcular créditos de warehouse?
**R:** XS=1, S=2, M=4, L=8, XL=16, 2XL=32, 3XL=64, 4XL=128. Cada tamanho dobra. Cobrança por segundo, mínimo de 60 segundos.

**P:** O que é uma projection policy?
**R:** Controla quais colunas podem aparecer nos resultados da consulta. Diferente de masking — projection esconde completamente a coluna, masking transforma o valor.

**P:** O que são alerts?
**R:** Verificações SQL agendadas que disparam ações (email, task) quando condições são atendidas. Avaliadas pela computação de Cloud Services.

---

## EXPLIQUE COMO SE EU TIVESSE 5 ANOS — Domínio 2

**ACCOUNTADMIN**: O super chefe que pode fazer tudo. Use com cuidado — como dar a alguém a chave mestra do prédio inteiro.

**SECURITYADMIN**: O segurança que decide quem recebe quais chaves (concede/revoga acesso).

**USERADMIN**: A pessoa do RH que cria novos funcionários (usuários) e os atribui a equipes (roles).

**SYSADMIN**: O gerente de instalações que constrói e possui as salas (databases, warehouses) onde o trabalho acontece.

**PUBLIC**: Todos recebem este role automaticamente. É como o lobby — aberto a todos.

**RBAC**: Em vez de dar permissões a cada pessoa, você dá permissões a um role (como "Gerente"), depois dá o role às pessoas.

**Network policy**: Um segurança na porta que verifica sua identidade (endereço IP). Se você está na lista, entra. Se não, vá embora.

**Resource monitor**: Um alerta de gasto do cartão de crédito. Ele observa quantos créditos seus warehouses usam e avisa (ou os para) se você gastar demais.

**Masking policy**: Como colocar um adesivo sobre parte do número de um cartão de crédito para que pessoas vejam apenas os últimos 4 dígitos.

**Row access policy**: Como um filtro que mostra a pessoas diferentes linhas diferentes. Equipe de vendas vê apenas dados da sua região.

**Tri-Secret Secure**: Você E o Snowflake cada um segura uma chave. Ambas as chaves são necessárias para desbloquear os dados. Se você tirar sua chave, ninguém consegue ler.

**ACCOUNT_USAGE**: Um diário detalhado de tudo que aconteceu na sua conta, mas leva 45 minutos a 3 horas para escrever entradas, e mantém registros por um ano.

**INFORMATION_SCHEMA**: Uma foto rápida do que existe agora. Respostas instantâneas, mas retém de 7 dias a 6 meses (dependendo da view).

**Object tagging**: Colocar etiquetas adesivas nos seus dados dizendo "isto é sensível" ou "isto é PII" para que você possa encontrar e proteger.

**Access history**: Uma câmera de segurança gravando quem olhou quais dados e quando.

**MFA**: Uma segunda tranca na porta — mesmo se alguém roubar sua senha, ainda precisa do código do seu telefone.

**Periodic rekeying**: Snowflake automaticamente troca as fechaduras dos seus dados. Como trocar senhas regularmente, mas para criptografia.

**Projection policy**: Esconder completamente uma coluna dos resultados da consulta — não mascarar, apenas tornar invisível.

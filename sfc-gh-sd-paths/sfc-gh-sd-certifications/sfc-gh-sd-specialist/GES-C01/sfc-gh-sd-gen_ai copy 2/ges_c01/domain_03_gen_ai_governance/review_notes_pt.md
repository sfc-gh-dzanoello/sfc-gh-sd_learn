# Dominio 3: Governanca de Snowflake Gen AI (26%)

## Controle de Acesso para Funcoes Cortex

### Modelo RBAC

As funcoes de Cortex AI residem sob o schema `SNOWFLAKE.CORTEX`. O acesso e gerenciado pelo controle de acesso baseado em roles (RBAC) padrao do Snowflake, combinado com um database role dedicado.

Existem duas camadas de controle de acesso:

1. **Nivel de conta** -- o administrador da conta deve habilitar as funcoes Cortex para a conta
2. **Nivel de role** -- roles individuais devem receber o database role `CORTEX_USER` ou privilegios sobre funcoes especificas

### O Database Role CORTEX_USER

O database role `SNOWFLAKE.CORTEX.CORTEX_USER` e o mecanismo principal para conceder acesso as funcoes de Cortex AI. E um **database role** no banco de dados `SNOWFLAKE`, nao um account role.

**O que ele concede:**
- Acesso a todas as funcoes LLM do Cortex geralmente disponiveis (COMPLETE, SUMMARIZE, TRANSLATE, SENTIMENT, EXTRACT_ANSWER, etc.)
- Acesso as funcoes de embedding do Cortex (EMBED_TEXT_768, EMBED_TEXT_1024)
- NAO concede acesso a funcoes administrativas no nivel da conta

**Caracteristicas importantes:**
- E um database role predefinido -- nao e possivel modificar seus privilegios
- Deve ser concedido a account roles, nao diretamente a usuarios
- Conceder este role e a abordagem recomendada para a maioria dos casos de uso
- Por padrao, apenas ACCOUNTADMIN tem acesso as funcoes Cortex ate que CORTEX_USER seja explicitamente concedido

### Concedendo o Role CORTEX_USER

```sql
-- Conceder CORTEX_USER a um account role
USE ROLE ACCOUNTADMIN;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX.CORTEX_USER TO ROLE data_analyst;

-- Conceder a multiplos roles
GRANT DATABASE ROLE SNOWFLAKE.CORTEX.CORTEX_USER TO ROLE data_scientist;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX.CORTEX_USER TO ROLE ml_engineer;

-- Verificar a concessao
SHOW GRANTS OF DATABASE ROLE SNOWFLAKE.CORTEX.CORTEX_USER;

-- Revogar acesso
REVOKE DATABASE ROLE SNOWFLAKE.CORTEX.CORTEX_USER FROM ROLE data_analyst;
```

### Concedendo/Revogando Acesso a Funcoes Especificas

Para um controle mais granular, e possivel conceder ou revogar acesso a funcoes individuais do Cortex em vez do role CORTEX_USER completo:

```sql
-- Conceder acesso apenas a funcao COMPLETE
USE ROLE ACCOUNTADMIN;
GRANT USAGE ON FUNCTION SNOWFLAKE.CORTEX.COMPLETE(VARCHAR, VARCHAR)
  TO ROLE limited_ai_role;

-- Conceder acesso apenas a SUMMARIZE
GRANT USAGE ON FUNCTION SNOWFLAKE.CORTEX.SUMMARIZE(VARCHAR)
  TO ROLE summarizer_role;

-- Revogar uma funcao especifica
REVOKE USAGE ON FUNCTION SNOWFLAKE.CORTEX.COMPLETE(VARCHAR, VARCHAR)
  FROM ROLE limited_ai_role;

-- Conceder SENTIMENT para um role de relatorios
GRANT USAGE ON FUNCTION SNOWFLAKE.CORTEX.SENTIMENT(VARCHAR)
  TO ROLE reporting_role;
```

**Ponto-chave para o exame:** Conceder acesso a funcoes individuais proporciona acesso de privilegio minimo. Isso e mais restritivo do que conceder o role CORTEX_USER completo.

### Hierarquia de Privilegios

```
ACCOUNTADMIN
  |
  +-- SNOWFLAKE.CORTEX.CORTEX_USER (database role)
  |     |
  |     +-- Todas as funcoes LLM do Cortex
  |     +-- Funcoes de embedding
  |
  +-- Concessoes individuais de USAGE sobre funcoes
        |
        +-- Apenas a funcao especifica
```

## Governanca de Custos e Monitoramento

### Modelo de Consumo de Creditos

As funcoes Cortex consomem **creditos serverless** -- nao utilizam creditos de virtual warehouse. Cada chamada de funcao consome creditos com base em:
- **Tokens de entrada** -- o texto enviado ao modelo
- **Tokens de saida** -- o texto gerado pelo modelo
- **Tamanho do modelo** -- modelos maiores custam mais por token
- **Tipo de funcao** -- COMPLETE custa mais que SENTIMENT por chamada

### Monitoramento via Views de ACCOUNT_USAGE

```sql
-- Monitorar o consumo de creditos do Cortex ao longo do tempo
SELECT
    start_time::DATE AS usage_date,
    service_type,
    name AS function_name,
    SUM(credits_used) AS total_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.METERING_HISTORY
WHERE service_type = 'AI_SERVICES'
  AND start_time >= DATEADD('day', -30, CURRENT_TIMESTAMP())
GROUP BY 1, 2, 3
ORDER BY total_credits DESC;

-- Uso detalhado do Cortex no nivel de consulta
SELECT
    query_id,
    user_name,
    role_name,
    query_text,
    credits_used_cloud_services,
    start_time,
    total_elapsed_time
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text ILIKE '%SNOWFLAKE.CORTEX%'
  AND start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;

-- Uso de creditos por role para identificar os maiores consumidores
SELECT
    role_name,
    COUNT(*) AS query_count,
    SUM(credits_used_cloud_services) AS total_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text ILIKE '%SNOWFLAKE.CORTEX%'
  AND start_time >= DATEADD('day', -30, CURRENT_TIMESTAMP())
GROUP BY role_name
ORDER BY total_credits DESC;
```

### Monitores de Recursos

Monitores de recursos podem ser usados para definir limites de creditos e receber alertas quando o uso do Cortex se aproxima dos limites:

```sql
-- Criar um monitor de recursos para o gasto geral da conta
-- (cobre creditos serverless incluindo Cortex)
CREATE OR REPLACE RESOURCE MONITOR cortex_monitor
  WITH CREDIT_QUOTA = 1000
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 75 PERCENT DO NOTIFY
    ON 90 PERCENT DO NOTIFY
    ON 100 PERCENT DO SUSPEND;
```

### Orcamentos

Os Orcamentos do Snowflake fornecem controles de gastos mais granulares:

```sql
-- Criar um orcamento para rastrear gastos com servicos de AI
-- Orcamentos podem ser limitados a funcionalidades serverless especificas
CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!SET_SPENDING_LIMIT(5000);
```

## Privacidade de Dados com Cortex

### Politicas de Mascaramento e Cortex

As politicas de mascaramento dinamico de dados sao aplicadas **antes** de os dados chegarem as funcoes Cortex. Se uma coluna tem uma politica de mascaramento, o valor mascarado e o que e enviado ao LLM.

```sql
-- Criar uma politica de mascaramento para PII
CREATE OR REPLACE MASKING POLICY pii_mask AS (val STRING)
  RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('PII_ADMIN') THEN val
    ELSE '***MASKED***'
  END;

-- Aplicar a uma coluna
ALTER TABLE customer_feedback
  MODIFY COLUMN customer_email SET MASKING POLICY pii_mask;

-- Quando um role que nao e PII_ADMIN executa isso:
-- O LLM recebe '***MASKED***' em vez do email real
SELECT SNOWFLAKE.CORTEX.SUMMARIZE(customer_email || ': ' || feedback_text)
FROM customer_feedback;
```

**Ponto critico para o exame:** As politicas de mascaramento protegem os dados enviados PARA as funcoes Cortex. O LLM so ve o valor mascarado. Esta e uma salvaguarda fundamental de privacidade.

### Politicas de Acesso a Linhas

As politicas de acesso a linhas filtram quais linhas um usuario pode ver. Essa filtragem e aplicada **antes** das funcoes Cortex serem executadas:

```sql
-- Criar uma politica de acesso a linhas
CREATE OR REPLACE ROW ACCESS POLICY region_policy AS (region_col VARCHAR)
  RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() = 'GLOBAL_ADMIN' THEN TRUE
    WHEN region_col = 'US' AND CURRENT_ROLE() = 'US_ANALYST' THEN TRUE
    ELSE FALSE
  END;

-- Aplicar a tabela
ALTER TABLE customer_feedback
  ADD ROW ACCESS POLICY region_policy ON (region);

-- O role US_ANALYST processa apenas linhas US atraves do Cortex
SELECT SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) AS sentiment
FROM customer_feedback;
-- Apenas linhas da regiao US sao processadas
```

### Interacao de Politicas de Mascaramento com a Saida do Cortex

Tambem e possivel aplicar politicas de mascaramento a saida de views que usam funcoes Cortex:

```sql
-- Criar uma view com analise do Cortex
CREATE OR REPLACE VIEW enriched_feedback AS
SELECT
    feedback_id,
    customer_email,
    feedback_text,
    SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) AS sentiment_score,
    SNOWFLAKE.CORTEX.SUMMARIZE(feedback_text) AS summary
FROM customer_feedback;

-- Aplicar mascaramento as colunas de saida do Cortex
CREATE OR REPLACE MASKING POLICY hide_summary AS (val STRING)
  RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('AI_ADMIN', 'DATA_SCIENTIST') THEN val
    ELSE 'Acesso restrito'
  END;

ALTER VIEW enriched_feedback
  MODIFY COLUMN summary SET MASKING POLICY hide_summary;
```

## Politicas de Agregacao com Funcoes Cortex

### O Que Sao Politicas de Agregacao

As politicas de agregacao impoem um **tamanho minimo de grupo** para os resultados de consultas, prevenindo a identificacao de individuos em dados agregados. Funcionam com as funcoes Cortex para garantir que analises impulsionadas por AI respeitem restricoes de privacidade.

### MIN_GROUP_SIZE

O parametro `MIN_GROUP_SIZE` define o numero minimo de linhas que devem existir em um grupo para que os resultados sejam retornados.

```sql
-- Criar uma politica de agregacao
CREATE OR REPLACE AGGREGATION POLICY min_group_policy
  AS () RETURNS AGGREGATION_CONSTRAINT ->
  AGGREGATION_CONSTRAINT(MIN_GROUP_SIZE => 5);

-- Aplicar a uma tabela
ALTER TABLE patient_feedback
  SET AGGREGATION POLICY min_group_policy;
```

### O Que Acontece Quando MIN_GROUP_SIZE e Violado

- Se um grupo de resultados de consulta tem menos linhas que `MIN_GROUP_SIZE`, o grupo e **excluido** dos resultados
- A consulta NAO falha -- simplesmente retorna menos linhas (ou zero)
- Isso se aplica tambem aos resultados de funcoes Cortex
- Se voce executar `SNOWFLAKE.CORTEX.SENTIMENT()` em dados agrupados e um grupo tiver poucas linhas, os resultados desse grupo sao suprimidos

### Interacao com Cortex

```sql
-- Com politica de agregacao (MIN_GROUP_SIZE = 5) aplicada:
-- Grupos com menos de 5 entradas de feedback sao excluidos
SELECT
    department,
    AVG(SNOWFLAKE.CORTEX.SENTIMENT(feedback_text)) AS avg_sentiment,
    COUNT(*) AS feedback_count
FROM employee_feedback
GROUP BY department;
-- Departamentos com < 5 feedbacks nao aparecerao nos resultados
```

**Nota de exame:** As politicas de agregacao previnem ataques de re-identificacao. Quando combinadas com funcoes Cortex, garantem que a analise de AI nao possa expor registros individuais.

## Politicas de Rede e Cortex

### Conectividade Privada

As funcoes de Cortex AI podem ser acessadas via conectividade privada para garantir que o trafego de rede nao atravesse a internet publica.

**Mecanismos principais:**
- **AWS PrivateLink** -- endpoint privado para Snowflake, cobrindo o trafego do Cortex
- **Azure Private Link** -- o mesmo para contas hospedadas no Azure
- **Google Cloud Private Service Connect** -- o mesmo para GCP

### Como as Politicas de Rede se Aplicam

As politicas de rede restringem **quais enderecos IP** podem se conectar ao Snowflake. Como as funcoes Cortex sao chamadas via SQL dentro do Snowflake, a politica de rede se aplica no nivel da sessao:

```sql
-- Criar uma politica de rede
CREATE OR REPLACE NETWORK POLICY cortex_network_policy
  ALLOWED_IP_LIST = ('10.0.0.0/8', '172.16.0.0/12')
  BLOCKED_IP_LIST = ()
  COMMENT = 'Restringir acesso ao Cortex a redes internas';

-- Aplicar no nivel da conta
ALTER ACCOUNT SET NETWORK_POLICY = cortex_network_policy;

-- Ou aplicar a usuarios especificos
ALTER USER service_account SET NETWORK_POLICY = cortex_network_policy;
```

**Importante:** As funcoes Cortex sao executadas no lado do servidor dentro do Snowflake. As politicas de rede controlam quem pode estabelecer uma sessao, nao as chamadas de funcoes Cortex em si. Uma vez que um usuario tem uma sessao autenticada, as chamadas ao Cortex passam pela infraestrutura interna do Snowflake.

### Configuracao do PrivateLink

Quando o PrivateLink esta configurado:
- Todo o trafego do Snowflake (incluindo Cortex) flui pelo endpoint privado
- Nenhum dado transita pela internet publica
- A resolucao DNS aponta para IPs privados
- Esta e a configuracao recomendada para cargas de trabalho de producao com dados sensiveis

## Autenticacao por Par de Chaves para Contas de Servico

### Por Que Autenticacao por Par de Chaves

Contas de servico que chamam funcoes Cortex programaticamente devem usar **autenticacao por par de chaves** em vez de senhas por:
- Eliminacao da complexidade de rotacao de senhas
- Habilitacao de pipelines automatizados (sem login interativo)
- Maior seguranca criptografica
- Sem risco de vazamento de senhas em codigo ou logs

### Configuracao

```sql
-- Gerar par de chaves RSA (feito fora do Snowflake)
-- openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt
-- openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub

-- Atribuir chave publica ao usuario
ALTER USER cortex_service_account SET RSA_PUBLIC_KEY = 'MIIBIjANBgkqh...';

-- A conta de servico se conecta usando a chave privada
-- Nenhuma senha necessaria na configuracao de conexao
```

### Melhores Praticas para Contas de Servico que Chamam Cortex
- Usar contas de servico dedicadas por aplicacao
- Atribuir os privilegios minimos necessarios do Cortex (funcoes especificas, nao CORTEX_USER completo se possivel)
- Rotacionar pares de chaves regularmente
- Armazenar chaves privadas em sistemas de gerenciamento de segredos (nao no codigo)
- Aplicar politicas de rede para restringir o acesso de contas de servico

## Auditoria e Conformidade

### Historico de Consultas

Todas as chamadas a funcoes Cortex aparecem no historico de consultas, permitindo auditabilidade completa:

```sql
-- Encontrar todas as chamadas a funcoes Cortex nos ultimos 30 dias
SELECT
    query_id,
    user_name,
    role_name,
    warehouse_name,
    query_text,
    start_time,
    end_time,
    execution_status
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text ILIKE '%SNOWFLAKE.CORTEX.COMPLETE%'
   OR query_text ILIKE '%SNOWFLAKE.CORTEX.SUMMARIZE%'
   OR query_text ILIKE '%SNOWFLAKE.CORTEX.SENTIMENT%'
   OR query_text ILIKE '%SNOWFLAKE.CORTEX.TRANSLATE%'
   OR query_text ILIKE '%SNOWFLAKE.CORTEX.EXTRACT_ANSWER%'
AND start_time >= DATEADD('day', -30, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;
```

### Historico de Acesso

O historico de acesso rastreia quais tabelas e colunas foram acessadas pelas chamadas a funcoes Cortex:

```sql
-- Rastrear quais objetos de dados foram acessados via chamadas Cortex
SELECT
    query_id,
    user_name,
    direct_objects_accessed,
    base_objects_accessed,
    query_start_time
FROM SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY
WHERE query_start_time >= DATEADD('day', -30, CURRENT_TIMESTAMP())
  AND ARRAY_SIZE(direct_objects_accessed) > 0
ORDER BY query_start_time DESC;
```

**Ponto de exame:** O historico de acesso captura a linhagem dos dados que fluem para as funcoes Cortex. Isso e critico para auditorias de conformidade -- e possivel rastrear exatamente quais tabelas/colunas foram processadas por funcoes de AI e por quem.

### Historico de Login

Para auditar contas de servico que chamam Cortex:

```sql
SELECT
    user_name,
    event_type,
    is_success,
    client_ip,
    first_authentication_factor,
    event_timestamp
FROM SNOWFLAKE.ACCOUNT_USAGE.LOGIN_HISTORY
WHERE user_name = 'CORTEX_SERVICE_ACCOUNT'
  AND event_timestamp >= DATEADD('day', -30, CURRENT_TIMESTAMP())
ORDER BY event_timestamp DESC;
```

## Seguranca de Conteudo e Guardrails

### O Parametro Guardrails no COMPLETE

A funcao `COMPLETE` suporta um parametro `guardrails` que habilita a filtragem de seguranca de conteudo:

```sql
-- Habilitar guardrails para seguranca de conteudo
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-large2',
    'Resumir este feedback do cliente: ...',
    {
        'guardrails': TRUE
    }
);

-- Guardrails com outras opcoes
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-large2',
    [
        {'role': 'system', 'content': 'Voce e um assistente util.'},
        {'role': 'user', 'content': 'Analise este texto...'}
    ],
    {
        'guardrails': TRUE,
        'temperature': 0.3,
        'max_tokens': 1024
    }
);
```

### O Que os Guardrails Fazem
- Filtram conteudo potencialmente prejudicial ou inapropriado tanto na **entrada** quanto na **saida**
- Bloqueiam prompts inseguros antes de chegarem ao modelo
- Sanitizam a saida do modelo que possa conter conteudo prejudicial
- Operam como um filtro de passa/nao passa -- o conteudo passa ou e bloqueado
- Quando o conteudo e bloqueado, a funcao retorna uma mensagem de seguranca em vez da saida do modelo

### Quando Usar Guardrails
- Aplicacoes voltadas ao cliente onde a saida e exibida diretamente aos usuarios finais
- Aplicacoes que processam conteudo gerado por usuarios
- Casos de uso com requisitos regulatorios de seguranca de conteudo
- Qualquer cenario onde a saida nao controlada do LLM represente risco reputacional ou legal

**Dica de exame:** O parametro guardrails e especifico da funcao COMPLETE. Outras funcoes Cortex (SENTIMENT, TRANSLATE, etc.) possuem limitacoes de escopo incorporadas que reduzem os riscos de seguranca.

## Disponibilidade de Modelos por Regiao e Nuvem

### Disponibilidade Regional

Nem todos os modelos Cortex estao disponiveis em todas as regioes do Snowflake. A disponibilidade depende de:
- **Provedor de nuvem** (AWS, Azure, GCP)
- **Regiao** (us-west-2, us-east-1, eu-west-1, etc.)
- **Licenciamento do modelo** e implantacao de infraestrutura

### Dados Importantes para o Exame
- As regioes US da AWS tipicamente possuem a selecao mais ampla de modelos
- Alguns modelos podem estar disponiveis em regioes US mas nao em EU/APAC
- Os modelos Snowflake Arctic possuem a disponibilidade mais ampla (modelos proprios do Snowflake)
- A disponibilidade de modelos pode mudar conforme o Snowflake expande sua infraestrutura
- Se um modelo nao estiver disponivel na sua regiao, a chamada da funcao retorna um erro
- Consultar a documentacao do Snowflake para a matriz de disponibilidade atual

### Consideracoes entre Regioes
- Nao e possivel chamar um modelo em uma regiao diferente da regiao da sua conta
- Requisitos de residencia de dados podem limitar quais modelos voce pode usar
- Para conformidade (ex., GDPR), garantir que os modelos estejam disponiveis na regiao necessaria

## Limites de Taxa e Cotas

### Limites por Conta
- As funcoes Cortex possuem **limites de taxa** por conta para garantir uso justo
- Os limites sao medidos em **tokens por minuto** (TPM) e **requisicoes por minuto** (RPM)
- Os limites variam por modelo e funcao
- Modelos maiores geralmente possuem limites de taxa mais baixos

### Comportamento Quando os Limites Sao Atingidos
- As requisicoes sao **limitadas** -- recebem erros HTTP 429 (limite de taxa excedido)
- O sistema nao enfileira requisicoes; o chamador deve implementar logica de retentativa
- Os limites de taxa sao redefinidos por minuto

### Melhores Praticas para Limites de Taxa
- Implementar retentativa com backoff exponencial no codigo da aplicacao
- Agrupar operacoes quando possivel para reduzir a contagem de requisicoes
- Usar modelos menores para tarefas de alto volume e baixa complexidade
- Monitorar o uso para permanecer dentro dos limites
- Contatar o suporte do Snowflake se os limites forem insuficientes para sua carga de trabalho

## Melhores Praticas para Governanca em Producao

### Melhores Praticas de Controle de Acesso
1. **Privilegio minimo** -- conceder acesso a funcoes especificas em vez do CORTEX_USER completo quando possivel
2. **Roles dedicados** -- criar roles especificamente para padroes de acesso ao Cortex
3. **Contas de servico** -- usar autenticacao por par de chaves para pipelines automatizados
4. **Auditorias regulares** -- revisar quem tem acesso ao Cortex trimestralmente

### Melhores Praticas de Gestao de Custos
1. **Monitorar continuamente** -- configurar dashboards usando views de ACCOUNT_USAGE
2. **Definir orcamentos** -- usar monitores de recursos e orcamentos para limitar gastos
3. **Dimensionar modelos corretamente** -- usar o menor modelo que atenda aos requisitos de qualidade
4. **Cachear resultados** -- armazenar saidas do Cortex em tabelas para evitar chamadas redundantes
5. **Processamento em lotes** -- processar dados em lotes durante horarios de menor atividade

### Melhores Praticas de Privacidade de Dados
1. **Politicas de mascaramento primeiro** -- aplicar mascaramento antes de os dados entrarem nas funcoes Cortex
2. **Politicas de acesso a linhas** -- limitar quais linhas sao processadas por role
3. **Politicas de agregacao** -- prevenir a identificacao individual em resultados agrupados
4. **Trilhas de auditoria** -- aproveitar o historico de consultas e acesso para conformidade

### Melhores Praticas de Seguranca
1. **PrivateLink** -- usar conectividade privada para cargas de trabalho de producao
2. **Politicas de rede** -- restringir o acesso a faixas de IP conhecidas
3. **Guardrails** -- habilitar seguranca de conteudo para aplicacoes voltadas ao usuario
4. **Rotacao de chaves** -- rotacionar pares de chaves de contas de servico regularmente
5. **Sem segredos em prompts** -- nunca incorporar credenciais ou segredos em prompts de LLM

### Melhores Praticas Operacionais
1. **Tratamento de erros** -- implementar logica de retentativa para limites de taxa e erros transitorios
2. **Consciencia regional** -- verificar a disponibilidade do modelo antes de implantar
3. **Fixar versoes** -- rastrear quais modelos sua aplicacao depende
4. **Testes** -- testar as saidas do Cortex quanto a qualidade antes da implantacao em producao
5. **Monitoramento** -- alertar sobre anomalias de custos, picos de taxa de erro e mudancas de latencia

## Topicos-Chave do Exame para Lembrar

1. **CORTEX_USER e um database role** no banco de dados SNOWFLAKE, nao um account role -- deve ser concedido a account roles via `GRANT DATABASE ROLE SNOWFLAKE.CORTEX.CORTEX_USER TO ROLE <nome_role>`
2. **Acesso granular** e possivel concedendo USAGE sobre funcoes Cortex especificas em vez do role CORTEX_USER completo
3. **Politicas de mascaramento sao aplicadas antes do Cortex** -- o LLM so ve valores mascarados, protegendo PII
4. **Politicas de acesso a linhas filtram linhas antes do processamento do Cortex** -- usuarios so analisam dados que estao autorizados a ver
5. **Politicas de agregacao com MIN_GROUP_SIZE** suprimem grupos abaixo do limite -- consultas nao falham, retornam menos linhas
6. **Cortex usa creditos serverless** -- nao creditos de warehouse; monitorar via SNOWFLAKE.ACCOUNT_USAGE.METERING_HISTORY com service_type = 'AI_SERVICES'
7. **O parametro guardrails no COMPLETE** habilita a filtragem de seguranca de conteudo tanto na entrada quanto na saida
8. **Nem todos os modelos estao disponiveis em todas as regioes** -- a disponibilidade depende do provedor de nuvem e regiao; modelos Arctic possuem a disponibilidade mais ampla
9. **Limites de taxa sao por conta** medidos em tokens por minuto e requisicoes por minuto -- limites excedidos retornam erros de throttling, nao requisicoes enfileiradas
10. **Historico de consultas e historico de acesso** fornecem trilhas de auditoria completas para todas as chamadas a funcoes Cortex, rastreando quem chamou qual funcao sobre quais dados
11. **Autenticacao por par de chaves** e recomendada para contas de servico que chamam Cortex -- elimina o gerenciamento de senhas e suporta automacao
12. **PrivateLink garante que o trafego do Cortex permaneca privado** -- combinado com politicas de rede, esta e a postura de seguranca recomendada para producao

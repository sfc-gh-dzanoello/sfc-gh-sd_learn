# Dominio 5: Compartilhamento e Colaboracao -- Solucoes de Compartilhamento de Dados

> **Peso no ARA-C01:** ~10-15% do exame.
> Foco em: mecanica de compartilhamento, padroes cross-region/cloud, contas reader, marketplace e Native Apps.

---

## 5.1 COMPARTILHAMENTO SEGURO DE DADOS (SECURE DATA SHARING)

O modelo de **compartilhamento sem copia (zero-copy sharing)** e o principal diferencial do Snowflake.

### Conceitos Chave

- **Provider (Provedor)**: a conta que possui os dados e cria o share
- **Consumer (Consumidor)**: a conta que recebe o share e cria um banco de dados a partir dele
- O compartilhamento e **zero-copy** -- nenhum dado e duplicado; o consumidor le do armazenamento do provedor
- O provedor paga pelo **armazenamento**; o consumidor paga pelo **computo** (seu proprio warehouse)
- O compartilhamento usa **shares** -- objetos nomeados contendo bancos de dados, esquemas, tabelas, secure views e UDFs

**O que pode ser compartilhado:**

- Tabelas (completas ou filtradas via secure views)
- Secure views, secure materialized views
- Secure UDFs
- Esquemas (todos os objetos dentro deles)

**O que NAO pode ser compartilhado diretamente:**

- Views nao seguras (devem ser SECURE)
- Stages, pipes, tasks, streams
- Stored procedures
- Tabelas temporarias/transientes (temporary/transient)

**Fluxo de criacao de um share:**

```sql
CREATE SHARE my_share;
GRANT USAGE ON DATABASE mydb TO SHARE my_share;
GRANT USAGE ON SCHEMA mydb.public TO SHARE my_share;
GRANT SELECT ON TABLE mydb.public.customers TO SHARE my_share;
ALTER SHARE my_share ADD ACCOUNTS = consumer_account;
```

**Lado do consumidor:**

```sql
CREATE DATABASE shared_db FROM SHARE provider_account.my_share;
```

### Por Que Isso Importa

Um provedor de servicos de saude precisa compartilhar dados anonimizados de pacientes com um parceiro de pesquisa. Eles criam uma secure view que mascara informacoes pessoais (PII), adicionam ao share, e o parceiro consulta diretamente -- sem copias de dados, sem pipelines ETL, sem dados desatualizados. Em tempo real, sempre atualizado.

### Melhores Praticas

- Sempre usar **secure views** para controlar o que os consumidores veem (filtragem a nivel de linha e coluna)
- Conceder apenas os objetos minimos necessarios -- nao compartilhar bancos de dados inteiros a menos que necessario
- Monitorar o acesso a dados compartilhados via `SNOWFLAKE.ACCOUNT_USAGE.DATA_TRANSFER_HISTORY`
- Documentar seus shares e revisa-los trimestralmente

**Armadilhas do exame:**

- Armadilha: SE VOCE VIR "O consumidor paga pelo armazenamento de dados compartilhados" --> ERRADO porque o **provedor** paga pelo armazenamento; o consumidor paga apenas pelo computo
- Armadilha: SE VOCE VIR "Views regulares podem ser compartilhadas" --> ERRADO porque apenas **secure views** podem ser incluidas em shares; views nao seguras expoem a logica interna
- Armadilha: SE VOCE VIR "Dados compartilhados podem ser modificados pelo consumidor" --> ERRADO porque dados compartilhados sao de **somente leitura** para consumidores; eles nao podem fazer INSERT/UPDATE/DELETE
- Armadilha: SE VOCE VIR "Shares criam uma copia dos dados" --> ERRADO porque shares sao **zero-copy**; consumidores consultam diretamente as micro-particoes do provedor

### Perguntas Frequentes (FAQ)

**P: Um consumidor pode re-compartilhar dados que recebeu?**
R: Nao. Consumidores nao podem criar shares a partir de bancos de dados compartilhados. O encadeamento de compartilhamento e bloqueado por design.

**P: O provedor ve as consultas do consumidor?**
R: Nao. O provedor nao tem visibilidade sobre a atividade de consultas do consumidor. Os consumidores controlam seu proprio uso.

---

## 5.2 CENARIOS DE COMPARTILHAMENTO

Diferentes topologias de compartilhamento tem diferentes requisitos.

### Conceitos Chave

| Cenario | Mecanismo | Notas |
|---------|-----------|-------|
| **Mesma conta** | Nao aplicavel -- apenas usar RBAC | O compartilhamento e entre contas, nao dentro de uma mesma |
| **Mesma regiao, mesma nuvem** | Share direto | O mais simples -- zero-copy, sem replicacao |
| **Cross-region (mesma nuvem)** | Replicacao de banco de dados + share | Replicar dados para a regiao destino primeiro, depois compartilhar |
| **Cross-cloud** | Replicacao de banco de dados + share | Igual ao cross-region mas entre AWS/Azure/GCP |
| **Cliente sem Snowflake** | Reader account | O provedor cria uma conta gerenciada para o consumidor |

**Fluxo cross-region / cross-cloud:**

1. O provedor habilita a replicacao: `ALTER DATABASE mydb ENABLE REPLICATION TO ACCOUNTS target_account`
2. A conta destino cria a replica: `CREATE DATABASE mydb AS REPLICA OF source_account.mydb`
3. Atualizar a replica: `ALTER DATABASE mydb REFRESH`
4. Criar o share na regiao destino usando o banco de dados replicado
5. OU: usar **Listing + Cross-Cloud Auto-Fulfillment** (gerencia a replicacao automaticamente)

**Ponto chave:** O compartilhamento direto so funciona dentro da **mesma regiao e provedor de nuvem**. Qualquer coisa cross-region ou cross-cloud requer replicacao primeiro (ou auto-fulfillment).

### Por Que Isso Importa

Uma empresa global de varejo na AWS us-east-1 precisa compartilhar dados de vendas com um parceiro na Azure West Europe. Eles devem replicar o banco de dados para uma conta na Azure West Europe primeiro, e entao criar o share la. Sem entender isso, arquitetos propoem compartilhamento direto e ele falha silenciosamente.

### Melhores Praticas

- Para compartilhamento cross-region frequente, usar **Listings com Auto-Fulfillment** -- automatiza a replicacao
- Monitorar custos de replicacao em `REPLICATION_USAGE_HISTORY`
- A replicacao cross-cloud tem custos de transferencia de dados -- considerar isso na arquitetura
- Usar replication groups para cenarios com multiplos bancos de dados

**Armadilhas do exame:**

- Armadilha: SE VOCE VIR "O compartilhamento direto funciona entre regioes" --> ERRADO porque o compartilhamento direto requer **mesma regiao E mesma nuvem**; cross-region precisa de replicacao primeiro
- Armadilha: SE VOCE VIR "O compartilhamento cross-cloud nao e possivel no Snowflake" --> ERRADO porque E possivel via **replicacao de banco de dados** para a nuvem/regiao destino, depois compartilhar
- Armadilha: SE VOCE VIR "Auto-Fulfillment elimina todos os custos de replicacao" --> ERRADO porque auto-fulfillment automatiza a replicacao mas os **custos de transferencia de dados ainda se aplicam**

### Perguntas Frequentes (FAQ)

**P: Posso compartilhar entre duas contas da mesma organizacao mas em regioes diferentes?**
R: Sim, via replicacao de banco de dados + share, ou atraves de um listing do Marketplace com Auto-Fulfillment.

**P: A replicacao e em tempo real?**
R: Nao. A replicacao e quase em tempo real com um cronograma de atualizacao configuravel. Sempre ha algum atraso.

---

## 5.3 CONTAS READER (READER ACCOUNTS)

Para compartilhar com organizacoes que **NAO possuem uma conta Snowflake**.

### Conceitos Chave

- Criadas pelo **provedor** usando `CREATE MANAGED ACCOUNT`
- Reader accounts sao **contas gerenciadas** -- completamente controladas pelo provedor
- **O provedor paga TUDO**: armazenamento e computo
- Os usuarios de reader accounts so podem consultar dados compartilhados -- nao podem carregar seus proprios dados
- Funcionalidade limitada: sem carga de dados, sem shares a partir de reader accounts, administracao minima

**Capacidades das Reader accounts:**

- Consultar dados compartilhados via seu proprio warehouse (financiado pelo provedor)
- Criar usuarios dentro da reader account
- Usar resource monitors (para controlar custos)

**Nao podem:**

- Carregar dados na conta
- Criar shares
- Acessar o Snowflake Marketplace
- Usar funcionalidades avancadas (tasks, streams, etc.)
- Replicar dados

### Por Que Isso Importa

Uma agencia governamental quer compartilhar conjuntos de dados publicos com pequenos municipios que nao podem justificar uma assinatura do Snowflake. Reader accounts permitem que a agencia compartilhe dados sem exigir que o municipio assine um contrato com o Snowflake. Mas a agencia paga todos os custos de computo -- por isso os resource monitors sao essenciais.

### Melhores Praticas

- **Sempre** configurar resource monitors nos warehouses de reader accounts -- voce paga o computo deles
- Manter os warehouses de reader accounts pequenos (X-Small ou Small)
- Configurar auto-suspend agressivo (60 segundos)
- Auditar periodicamente o uso de reader accounts via `RESOURCE_MONITORS` e `MANAGED_ACCOUNTS`
- Considerar listings do Marketplace se deseja que os consumidores paguem seus proprios custos

**Armadilhas do exame:**

- Armadilha: SE VOCE VIR "Reader accounts podem carregar seus proprios dados" --> ERRADO porque reader accounts **so podem consultar dados compartilhados**; nenhuma carga de dados e permitida
- Armadilha: SE VOCE VIR "O consumidor paga o computo da reader account" --> ERRADO porque o **provedor paga tudo** -- armazenamento E computo para reader accounts
- Armadilha: SE VOCE VIR "Reader accounts podem criar shares para outras contas" --> ERRADO porque reader accounts nao podem criar shares, ponto final

### Perguntas Frequentes (FAQ)

**P: Uma reader account pode ser convertida em uma conta completa do Snowflake?**
R: Nao. Reader accounts nao podem ser convertidas. A organizacao precisaria assinar seu proprio contrato com o Snowflake e voce configuraria um share regular.

**P: Quantas reader accounts um provedor pode criar?**
R: Nao ha um limite rigido documentado, mas o Snowflake pode impor limites flexiveis. Contate o suporte para numeros muito grandes.

---

## 5.4 MARKETPLACE E INTERCAMBIO DE DADOS (DATA EXCHANGE)

Marketplace e o catalogo publico de dados do Snowflake. Data Exchange e privado.

### Conceitos Chave

**Snowflake Marketplace:**

- Catalogo publico onde provedores **listam** conjuntos de dados para qualquer cliente do Snowflake descobrir
- Listings gratuitos ou pagos
- **Personalized listings** -- adaptados a consumidores especificos
- **Standard listings** -- disponiveis para qualquer pessoa
- Consumidores obtem dados instantaneamente -- zero-copy sharing nos bastidores
- Provedores: Snowflake, fornecedores de dados terceiros, qualquer cliente do Snowflake

**Data Exchange (Privado):**

- Grupo **privado, somente por convite** de contas para compartilhamento
- Criado por um cliente do Snowflake ou pelo proprio Snowflake
- Membros podem publicar e descobrir listings dentro do grupo
- Caso de uso: departamentos internos, parceiros de confianca, consorcios industriais

**Cross-Cloud Auto-Fulfillment:**

- Funcionalidade do Marketplace que **replica automaticamente** os listings para consumidores em diferentes regioes/nuvens
- O provedor publica uma vez --> Snowflake gerencia a replicacao para onde quer que o consumidor esteja
- O provedor paga os custos de transferencia/replicacao de dados
- Remove o trabalho manual de replicacao no compartilhamento cross-region/cross-cloud

### Por Que Isso Importa

Uma empresa de dados meteorologicos publica previsoes diarias no Snowflake Marketplace. Uma rede de varejo na Azure East US a descobre, clica em "Get", e instantaneamente tem um banco de dados compartilhado -- sem negociacoes, sem pipelines de dados, sem ETL. Cross-Cloud Auto-Fulfillment significa que a empresa meteorologica nao precisa de contas em cada regiao.

### Melhores Praticas

- Usar Marketplace para distribuicao de dados **publica ou semi-publica**
- Usar Data Exchange para compartilhamento **privado** dentro de um grupo de confianca
- Habilitar Auto-Fulfillment se os consumidores estao em multiplas regioes/nuvens
- Monitorar o uso de listings para entender a demanda e otimizar custos
- Escrever descricoes claras de listings -- consumidores descobrem dados atraves de busca

**Armadilhas do exame:**

- Armadilha: SE VOCE VIR "Data Exchange e o mesmo que Marketplace" --> ERRADO porque Marketplace e **publico**, Data Exchange e **privado e somente por convite**
- Armadilha: SE VOCE VIR "Auto-Fulfillment e gratuito para provedores" --> ERRADO porque provedores ainda pagam **custos de replicacao e transferencia de dados**
- Armadilha: SE VOCE VIR "Consumidores devem estar na mesma regiao para usar o Marketplace" --> ERRADO porque **Auto-Fulfillment** gerencia a entrega cross-region/cross-cloud automaticamente

### Perguntas Frequentes (FAQ)

**P: Posso cobrar pelos listings do Marketplace?**
R: Sim. O Snowflake suporta listings pagos com precos baseados em uso ou fixos, gerenciados atraves do painel do provedor.

**P: Quem gerencia a cobranca para listings pagos?**
R: O Snowflake gerencia a cobranca. Consumidores pagam atraves de sua fatura do Snowflake, e o Snowflake repassa ao provedor.

---

## 5.5 DATA CLEAN ROOMS

Analise segura de dados entre multiplas partes sem expor dados brutos.

### Conceitos Chave

- **Proposito:** Duas ou mais partes analisam dados sobrepostos sem ver os dados brutos um do outro
- Construido sobre o compartilhamento do Snowflake + secure views + controles de privacidade
- **Snowflake Data Clean Rooms** -- produto gerenciado (alimentado pelo Native App Framework)
- Caso de uso tipico: anunciante + editor medindo a sobreposicao de campanhas sem expor listas de clientes
- **Garantia chave:** nenhuma parte ve os dados a nivel de linha do outro -- apenas resultados agregados/anonimizados

**Como funciona (simplificado):**

1. A Parte A compartilha seus dados no clean room
2. A Parte B compartilha seus dados no clean room
3. Consultas pre-aprovadas (templates) sao executadas sobre a sobreposicao
4. Os resultados retornados sao agregados -- limites minimos previnem a identificacao individual
5. Nenhuma parte baixa os dados brutos do outro

**Controles de privacidade:**

- **Privacidade diferencial** -- adiciona ruido estatistico para prevenir a re-identificacao
- **Limites minimos de agregacao** -- os resultados de consultas devem representar N+ individuos
- **Politicas de coluna** -- restringem quais colunas sao unificaveis/visiveis

### Por Que Isso Importa

Um banco e um varejista querem entender os clientes compartilhados para um cartao de credito co-branded. Nenhum pode compartilhar listas de clientes devido a regulamentacoes. Um data clean room permite que calculem o "tamanho da sobreposicao" e "gasto medio" sem que nenhuma parte veja registros individuais.

### Melhores Praticas

- Definir **templates de analise** antecipadamente -- restringir consultas ad-hoc
- Estabelecer limites minimos de agregacao significativos (ex. minimo 100 individuos por grupo)
- Usar o produto gerenciado de clean room do Snowflake em vez de construir do zero
- Auditar todas as consultas e resultados do clean room
- Envolver equipes juridicas/de compliance no design do clean room

**Armadilhas do exame:**

- Armadilha: SE VOCE VIR "Data clean rooms permitem que as partes vejam os dados um do outro" --> ERRADO porque clean rooms **previnem** a exposicao de dados brutos; apenas resultados agregados sao retornados
- Armadilha: SE VOCE VIR "Clean rooms exigem que os dados sejam copiados para um terceiro" --> ERRADO porque os clean rooms do Snowflake usam **zero-copy sharing** -- os dados permanecem na conta de cada parte
- Armadilha: SE VOCE VIR "Qualquer consulta pode ser executada em um clean room" --> ERRADO porque as consultas sao restritas a **templates pre-aprovados** para prevenir vazamento de dados

### Perguntas Frequentes (FAQ)

**P: Mais de duas partes podem participar de um clean room?**
R: Sim. Clean rooms com multiplas partes sao suportados, embora a complexidade aumente.

**P: Um clean room e uma conta separada do Snowflake?**
R: A logica do clean room e executada como uma Native App instalada nas contas participantes. Os dados permanecem na conta de cada parte.

---

## 5.6 NATIVE APPS

O **Snowflake Native App Framework** permite que provedores empacotem codigo + dados como aplicacoes instalaveis.

### Conceitos Chave

**Application Package:**

- O contêiner do **lado do provedor** para a app
- Contem: scripts de configuracao, codigo versionado, conteudo de dados compartilhados, UI de Streamlit, stored procedures, UDFs
- Criado com `CREATE APPLICATION PACKAGE`
- Versionado: `ALTER APPLICATION PACKAGE ADD VERSION v1_0 USING '@stage/v1'`

**Native App (Lado do consumidor):**

- Instalada pelo consumidor a partir de um listing ou diretamente
- Criada a partir de um Application Package
- Executa **dentro da conta do consumidor** -- o provedor nao pode ver os dados do consumidor
- Pode solicitar **privilegios** ao consumidor (ex. acesso a tabelas especificas)
- O consumidor controla qual acesso conceder

**O que as Native Apps podem incluir:**

- Stored procedures e UDFs (SQL, Python, Java, Scala, JavaScript)
- Dashboards de Streamlit (UI)
- Conteudo de dados compartilhados (dados de referencia)
- Tasks e streams (para processamento automatizado)
- Integracoes de acesso externo (chamar APIs externas)

**Script de configuracao (`setup.sql`):**

- Executa quando o consumidor instala a app
- Cria todos os objetos internos (esquemas, views, procedimentos, etc.)
- Define **roles de aplicacao** que mapeiam para os privilegios concedidos pelo consumidor

### Por Que Isso Importa

Uma empresa de enriquecimento de dados constroi uma Native App que recebe a tabela de clientes do consumidor, a enriquece com dados demograficos de terceiros e retorna os resultados -- tudo sem que os dados do consumidor saiam de sua conta. O provedor distribui atraves do Marketplace, e cada consumidor recebe sua propria instalacao isolada.

### Melhores Praticas

- Usar **patches versionados** para atualizacoes de apps (consumidores podem atualizar no seu ritmo)
- Minimizar solicitacoes de privilegios -- pedir apenas o que a app realmente precisa
- Incluir uma UI de Streamlit para usuarios que nao usam SQL
- Testar as apps exaustivamente em um application package de desenvolvimento antes de publicar
- Usar `manifest.yml` para declarar privilegios necessarios e configuracao

**Armadilhas do exame:**

- Armadilha: SE VOCE VIR "Native Apps executam na conta do provedor" --> ERRADO porque Native Apps executam **dentro da conta do consumidor**; o provedor nao pode ver os dados do consumidor
- Armadilha: SE VOCE VIR "Native Apps automaticamente tem acesso aos dados do consumidor" --> ERRADO porque o consumidor deve **conceder explicitamente** os privilegios; a app os solicita, o consumidor aprova
- Armadilha: SE VOCE VIR "Native Apps sao apenas bancos de dados compartilhados" --> ERRADO porque Native Apps podem incluir **codigo** (procedimentos, UDFs, Streamlit), nao apenas dados

### Perguntas Frequentes (FAQ)

**P: Uma Native App pode gravar dados na conta do consumidor?**
R: Sim, se o consumidor conceder os privilegios necessarios (ex. CREATE TABLE em um esquema).

**P: Como os consumidores recebem atualizacoes de Native Apps?**
R: Provedores publicam novas versoes/patches. Consumidores podem atualizar manualmente ou o provedor pode configurar atualizacao automatica.

---

## 5.7 PADROES DE SEGURANCA PARA COMPARTILHAMENTO

A seguranca nao e negociavel ao compartilhar dados.

### Conceitos Chave

**Secure views sao obrigatorias:**

- Views regulares expoem sua definicao (SQL) a qualquer pessoa com `SHOW VIEWS`
- Secure views ocultam a definicao e previnem a inferencia de dados baseada no otimizador
- **Todas as views em shares DEVEM ser seguras** -- o Snowflake impoe isso
- Compromisso: secure views podem ter otimizacao ligeiramente diferente (restricoes do otimizador de consultas)

**Hierarquia de privilegios do share:**

```
SHARE
  └── USAGE on DATABASE
       └── USAGE on SCHEMA
            └── SELECT on TABLE / VIEW / MATERIALIZED VIEW
            └── USAGE on UDF
```

- Deve-se conceder em cada nivel -- conceder SELECT em uma tabela sem USAGE em seu esquema nao funcionara
- `GRANT REFERENCE_USAGE ON DATABASE` -- permite ao consumidor criar views que referenciem dados compartilhados

**O compartilhamento cross-region requer replicacao primeiro:**

- Nao e possivel criar um share e adicionar um consumidor em uma regiao diferente diretamente
- Deve-se replicar o banco de dados (ou usar Auto-Fulfillment para listings)
- A replicacao pode ser continua (`REPLICATION_SCHEDULE`) ou manual (`ALTER DATABASE REFRESH`)

**Secure UDFs em shares:**

- O codigo-fonte da UDF e oculto para os consumidores (assim como as definicoes de secure views)
- Consumidores podem chama-las mas nao podem inspecionar sua logica

### Por Que Isso Importa

Um arquiteto compartilha uma view contendo dados financeiros mas esquece de torna-la segura. O consumidor executa `SHOW VIEWS` e ve a definicao SQL, que revela logica de filtragem oculta e nomes de tabelas. Agora eles conhecem tabelas que nao deveriam. Secure views previnem isso.

### Melhores Praticas

- **Sempre** usar secure views -- nunca compartilhar views regulares
- Conceder privilegios no nivel mais granular possivel
- Usar secure UDFs para logica de negocio que voce nao quer expor
- Para consumidores cross-region, planejar o atraso de replicacao nos SLAs
- Auditar shares regularmente: `SHOW SHARES`, `DESCRIBE SHARE`

**Armadilhas do exame:**

- Armadilha: SE VOCE VIR "Views regulares podem ser adicionadas a shares" --> ERRADO porque o Snowflake **exige secure views** em shares; voce recebera um erro ao adicionar uma view nao segura
- Armadilha: SE VOCE VIR "Conceder SELECT em uma tabela e suficiente para compartilhar" --> ERRADO porque voce tambem deve conceder **USAGE no DATABASE e no SCHEMA**
- Armadilha: SE VOCE VIR "Secure views tem desempenho identico as views regulares" --> ERRADO porque secure views restringem certos **comportamentos do otimizador** para prevenir vazamento de dados, o que pode impactar ligeiramente o desempenho

### Perguntas Frequentes (FAQ)

**P: Posso compartilhar uma secure materialized view?**
R: Sim. Secure materialized views podem ser incluidas em shares.

**P: Se eu deletar e recriar uma tabela que esta em um share, o consumidor perde acesso?**
R: Sim. O share referencia o objeto especifico. Voce deve re-conceder apos recriar.

---

## CARTOES DE REVISAO -- Dominio 5

**P1: Quem paga o armazenamento em um share direto?**
R1: O **provedor** paga o armazenamento. O consumidor paga apenas pelo seu proprio computo.

**P2: Um consumidor pode modificar dados compartilhados?**
R2: **Nao.** Dados compartilhados sao somente leitura para consumidores.

**P3: O que e necessario para compartilhar dados cross-region?**
R3: **Replicacao de banco de dados** para a regiao destino primeiro, depois criar o share la. Ou usar Marketplace com Auto-Fulfillment.

**P4: Que tipo de view DEVE ser usado em shares?**
R4: **Secure views** -- views regulares nao sao permitidas em shares.

**P5: Quem paga o computo em uma reader account?**
R5: O **provedor** paga tudo -- tanto armazenamento quanto computo.

**P6: Reader accounts podem carregar seus proprios dados?**
R6: **Nao.** Reader accounts so podem consultar dados compartilhados.

**P7: O que e Cross-Cloud Auto-Fulfillment?**
R7: Uma funcionalidade do Marketplace que **replica automaticamente** os listings para consumidores em diferentes regioes/nuvens, para que o provedor publique apenas uma vez.

**P8: Onde uma Native App e executada?**
R8: Na **conta do consumidor** -- o provedor nao pode ver os dados do consumidor.

**P9: O que e um Data Exchange?**
R9: Um grupo **privado, somente por convite** para compartilhar listings entre contas de confianca. Diferente do Marketplace, que e publico.

**P10: O que previne a exposicao de dados brutos em um data clean room?**
R10: **Templates de consulta pre-aprovados**, limites minimos de agregacao e controles de privacidade diferencial.

**P11: Um consumidor pode re-compartilhar dados recebidos atraves de um share?**
R11: **Nao.** O encadeamento de compartilhamento nao e permitido por design.

**P12: Qual arquivo define os metadados e privilegios de uma Native App?**
R12: O arquivo **manifest.yml** declara os privilegios necessarios, configuracao e metadados da app.

**P13: Para que serve o privilegio `REFERENCE_USAGE`?**
R13: Permite que um consumidor **crie views em seu proprio banco de dados que referenciem** objetos no banco de dados compartilhado.

**P14: Como um clean room garante a privacidade individual?**
R14: Os resultados devem atender **limites minimos de agregacao** (ex. 100+ individuos por grupo) e podem usar **ruido de privacidade diferencial**.

**P15: O que acontece se os dados compartilhados subjacentes mudam?**
R15: Os consumidores veem as mudancas **imediatamente** (para shares na mesma regiao) porque o compartilhamento e zero-copy -- eles leem as micro-particoes ao vivo do provedor.

---

## EXPLICADO PARA INICIANTES -- Dominio 5

**Explicacao #1: Compartilhamento Seguro de Dados**
Voce tem um livro de colorir. Em vez de fotocopiar paginas para seu amigo (o que desperdicaria papel), voce o deixa olhar seu livro atraves de uma janela. Ele pode ver e copiar, mas nao pode mudar seu livro, e voce nao tem duas copias.

**Explicacao #2: Provedor vs. Consumidor**
Voce assou biscoitos (provedor). Seu amigo os come (consumidor). Voce comprou os ingredientes (armazenamento). Seu amigo usa seu proprio prato e garfo (computo).

**Explicacao #3: Reader Accounts**
Seu amigo nao tem prato nem garfo. Entao voce da os seus. Voce esta pagando por tudo -- os biscoitos E o prato e garfo. Isso e uma reader account.

**Explicacao #4: Compartilhamento Cross-Region**
Seu amigo mora em outra cidade. Voce nao pode simplesmente segurar o livro de colorir -- ele esta muito longe. Voce precisa fazer uma copia e envia-la para a cidade dele primeiro (replicacao), depois ele pode olhar atraves da janela la.

**Explicacao #5: Marketplace**
Imagine uma biblioteca onde qualquer pessoa pode pegar emprestado qualquer livro de graca (ou por uma pequena taxa). Isso e o Marketplace. Qualquer pessoa pode navegar, encontrar conjuntos de dados e "pega-los emprestados" instantaneamente.

**Explicacao #6: Data Exchange**
Agora imagine um clube do livro privado. Apenas membros convidados podem compartilhar e pegar emprestados livros. Isso e o Data Exchange.

**Explicacao #7: Data Clean Rooms**
Voce e seu amigo tem, cada um, um saco de bolinhas de gude. Voces querem saber quantas cores compartilham, mas nenhum quer mostrar todas as suas bolinhas. Entao cada um coloca seu saco em uma caixa magica que so diz "Voces compartilham 3 cores" -- nao quais bolinhas especificas.

**Explicacao #8: Native Apps**
Alguem constroi um robo de brinquedo e o coloca em uma caixa com instrucoes. Voce o instala no SEU quarto, e ele brinca com SEUS brinquedos. O construtor nunca entra no seu quarto -- o robo funciona por conta propria.

**Explicacao #9: Secure Views**
Uma secure view e como um espelho unidirecional. Voce pode ver os dados atraves dele, mas nao pode ver os projetos de como o espelho foi construido ou o que esta escondido atras da parede.

**Explicacao #10: Auto-Fulfillment**
Voce vende limonada. Em vez de montar uma barraca em cada bairro voce mesmo, um ajudante magico aparece automaticamente em qualquer bairro onde alguem queira limonada. Voce so faz a receita uma vez.

# Dominio 1: Snowflake para Gen AI - Visao Geral (30%)

## O que e Snowflake Cortex AI

Snowflake Cortex AI e um servico totalmente gerenciado que fornece acesso a modelos de linguagem (LLMs) e funcoes de IA diretamente dentro do Snowflake. Elimina a necessidade de infraestrutura externa, gerenciamento de GPUs ou hospedagem de modelos -- tudo roda dentro do perimetro de seguranca e governanca do Snowflake.

### Principios Chave
- **Os dados ficam no Snowflake** -- sem movimentacao de dados para APIs externas
- **Nativo em SQL** -- todas as funcoes de IA sao chamadas via SQL padrao
- **Serverless** -- nao requer provisionamento de warehouse ou computacao
- **Governado** -- herda RBAC, politicas de mascaramento e acesso a linhas

## Arquitetura do Cortex AI

### Como Funciona
1. O usuario chama uma funcao Cortex (ex. `SNOWFLAKE.CORTEX.COMPLETE(...)`) em SQL
2. Snowflake roteia a solicitacao para infraestrutura GPU gerenciada
3. O modelo processa a entrada e retorna resultados inline
4. Nenhum dado sai do limite de seguranca do Snowflake

### Modelo de Computacao
- Funcoes Cortex usam **computacao serverless** -- nao warehouses virtuais
- A cobranca e baseada em **tokens processados** (tokens de entrada + saida)
- Cada funcao tem sua propria taxa de consumo de creditos
- Nao sao consumidos creditos de warehouse

## Modelos LLM Disponiveis

| Modelo | Provedor | Melhor Para |
|--------|----------|-------------|
| snowflake-arctic-instruct | Snowflake | Proposito geral, custo-efetivo |
| llama3.1-70b | Meta | Raciocinio complexo, contexto longo |
| llama3.1-8b | Meta | Tarefas rapidas e leves |
| mistral-large2 | Mistral | Multilingue, seguimento de instrucoes |
| mixtral-8x7b | Mistral | Equilibrio velocidade/qualidade |
| jamba-1.5-large | AI21 | Documentos longos (256K de contexto) |
| jamba-1.5-mini | AI21 | Contexto longo custo-efetivo |

### Criterios de Selecao de Modelo
- **Sensibilidade ao custo** -- modelos menores custam menos por token
- **Necessidades de qualidade** -- modelos maiores produzem melhores resultados
- **Janela de contexto** -- modelos Jamba lidam com entradas muito longas (256K tokens)
- **Latencia** -- modelos menores respondem mais rapido
- **Suporte a idiomas** -- modelos Mistral se destacam em tarefas multilingues

## Casos de Uso de Gen AI no Snowflake

### Analitica de Texto em Escala
- Analise de sentimento em avaliacoes de clientes
- Classificacao e categorizacao de conteudo
- Extracao de entidades de dados nao estruturados
- Resumo de documentos longos

### Enriquecimento de Dados
- Geracao de descricoes de produtos a partir de atributos
- Traducao de conteudo entre idiomas
- Extracao de dados estruturados de texto livre
- Aumento de registros com metadados gerados por IA

### Busca e Recuperacao
- **Cortex Search** -- servico gerenciado de RAG (Geracao Aumentada por Recuperacao)
- Busca semantica sobre dados nao estruturados
- Busca hibrida combinando palavras-chave + similaridade vetorial
- Fragmentacao e embedding automatico de documentos

### IA Conversacional
- Construcao de chatbots com Cortex Agents
- Conversas multi-turno com contexto
- Uso de ferramentas e chamadas a funcoes
- Integracao com aplicacoes Streamlit

## Servico Cortex Search

### O que E
Um servico totalmente gerenciado para construir aplicacoes RAG. Lida com fragmentacao, embedding, indexacao e recuperacao automaticamente.

### Componentes Chave
- **Dados fonte** -- tabelas com colunas de texto para buscar
- **Servico de busca** -- criado com `CREATE CORTEX SEARCH SERVICE`
- **Target lag** -- quao fresco o indice deve ser (similar a Dynamic Tables)
- **Embedding** -- embedding vetorial automatico do texto fonte
- **Recuperacao** -- busca hibrida (semantica + palavras-chave)

## Cortex Agents

### O que Sao
Camada de orquestracao pre-construida que combina LLMs com ferramentas (Cortex Search, execucao SQL, Cortex Analyst) para responder perguntas complexas autonomamente.

### Diferencas Chave com Chamadas LLM Diretas
| Caracteristica | Funcao COMPLETE | Cortex Agent |
|---------------|-----------------|--------------|
| Contexto | Usuario fornece tudo | Agente recupera via ferramentas |
| Multi-passo | Chamada unica | Cadeia automatica |
| Acesso a dados | Nenhum (so texto) | Pode consultar tabelas e docs |
| Fundamentacao | Nenhuma | Baseado em dados reais |

## Cortex Analyst

### O que E
Um motor de linguagem natural para SQL alimentado por modelos semanticos. Usuarios fazem perguntas em linguagem natural, e Cortex Analyst gera e executa SQL.

### Modelo Semantico
- Arquivo YAML definindo tabelas, colunas, metricas, dimensoes
- Mapeia termos de negocio para colunas fisicas
- Define relacionamentos e logica de calculo
- Armazenado em um stage do Snowflake

## Topicos Chave para o Exame

1. **Funcoes Cortex sao serverless** -- sem warehouse, cobradas por tokens
2. **Dados nunca saem do Snowflake** -- diferencial chave de seguranca
3. **A selecao de modelo importa** -- cada modelo tem diferentes forcas/custos
4. **Cortex Search = RAG gerenciado** -- lida com fragmentacao, embedding, recuperacao
5. **Cortex Agents vs COMPLETE** -- agentes sao multi-passo com acesso a ferramentas
6. **Cortex Analyst = NL2SQL** -- precisa de um YAML de modelo semantico
7. **Snowflake Arctic** -- familia de modelos open-source proprios do Snowflake
8. **Janelas de contexto variam** -- de 4K a 256K tokens dependendo do modelo
9. **Todas as funcoes sao SQL** -- `SNOWFLAKE.CORTEX.*`
10. **Governanca se aplica** -- RBAC e politicas de mascaramento funcionam com Cortex

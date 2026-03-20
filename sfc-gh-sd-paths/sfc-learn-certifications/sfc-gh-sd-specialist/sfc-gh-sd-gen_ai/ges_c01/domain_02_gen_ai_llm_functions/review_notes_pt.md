# Dominio 2: Snowflake Gen AI e Funcoes LLM (44%)

## Visao Geral das Funcoes Cortex LLM

Todas as funcoes de Cortex AI estao no esquema `SNOWFLAKE.CORTEX`. Sao invocaveis via SQL, serverless, e cobradas por token processado.

### Funcoes Principais

| Funcao | Proposito | Entrada | Saida |
|--------|-----------|---------|-------|
| `COMPLETE` | Geracao de texto / chat | modelo, prompt (ou mensagens) | Texto gerado |
| `EXTRACT_ANSWER` | Resposta a perguntas a partir de contexto | texto, pergunta | String de resposta |
| `SENTIMENT` | Pontuacao de sentimento | texto | Float (-1 a 1) |
| `SUMMARIZE` | Resumo de texto | texto | String de resumo |
| `TRANSLATE` | Traducao de idiomas | texto, idioma_origem, idioma_destino | Texto traduzido |
| `EMBED_TEXT_768` | Embedding de texto (768 dim) | modelo, texto | VECTOR(FLOAT, 768) |
| `EMBED_TEXT_1024` | Embedding de texto (1024 dim) | modelo, texto | VECTOR(FLOAT, 1024) |
| `CLASSIFY_TEXT` | Classificacao zero-shot | texto, categorias | Categoria + pontuacao |

## Funcao COMPLETE -- Analise em Profundidade

A funcao mais versatil. Suporta tanto prompts simples quanto mensagens de chat estruturadas.

### Modo Simples
```sql
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'snowflake-arctic-instruct',
    'Explique data sharing no Snowflake em 3 frases.'
) AS response;
```

### Modo de Mensagens de Chat
```sql
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-large2',
    [
        {'role': 'system', 'content': 'You are a Snowflake expert.'},
        {'role': 'user', 'content': 'What is a Dynamic Table?'}
    ],
    {'temperature': 0.3, 'max_tokens': 500}
) AS response;
```

### Parametro de Opcoes
| Opcao | Tipo | Descricao |
|-------|------|-----------|
| `temperature` | Float (0-1) | Aleatoriedade. 0 = deterministico, 1 = criativo |
| `max_tokens` | Integer | Comprimento maximo da saida |
| `top_p` | Float (0-1) | Limite de amostragem de nucleo |
| `guardrails` | Boolean | Habilitar filtros de seguranca de conteudo |

### COMPLETE com Saida Estruturada
```sql
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'llama3.1-70b',
    'Extract the name and email from: John Smith, john@example.com',
    {'response_format': {'type': 'json'}}
)::VARIANT:name AS name;
```

### Comportamentos Chave
- Retorna um VARCHAR no modo simples
- Retorna um VARIANT (objeto JSON) quando opcoes sao usadas -- acesse com `:choices[0]:messages`
- **Streaming NAO e suportado** em SQL -- apenas via REST API / Python
- As funcoes sao **sem estado (stateless)** -- nao ha memoria de conversacao entre chamadas
- Limites de taxa se aplicam por conta -- planeje retentativas nos pipelines

## Funcao SENTIMENT

Retorna um float entre -1 (muito negativo) e 1 (muito positivo).

```sql
SELECT
    review_text,
    SNOWFLAKE.CORTEX.SENTIMENT(review_text) AS score
FROM customer_reviews;
```

### Interpretacao da Pontuacao
| Faixa | Significado |
|-------|-------------|
| 0.5 a 1.0 | Positivo |
| -0.2 a 0.5 | Neutro |
| -1.0 a -0.2 | Negativo |

### Uso em Escala
```sql
-- Agregar sentimento por produto
SELECT
    product_id,
    AVG(SNOWFLAKE.CORTEX.SENTIMENT(review)) AS avg_sentiment,
    COUNT(*) AS review_count
FROM reviews
GROUP BY product_id
ORDER BY avg_sentiment;
```

## Funcao SUMMARIZE

Produz um resumo conciso do texto de entrada.

```sql
SELECT SNOWFLAKE.CORTEX.SUMMARIZE(article_text) AS summary
FROM news_articles
WHERE publish_date > CURRENT_DATE - 7;
```

- Comprimento da entrada: lida com textos longos (janela de contexto dependente do modelo)
- Saida: resumo de um unico paragrafo por padrao
- Sem parametro de modelo -- Snowflake seleciona o modelo ideal

## Funcao TRANSLATE

```sql
SELECT SNOWFLAKE.CORTEX.TRANSLATE(
    description,
    'en',    -- idioma de origem
    'es'     -- idioma de destino
) AS spanish_description
FROM products;
```

### Codigos de Idioma Suportados
en, es, fr, de, pt, it, ja, ko, zh, ru, ar, pl, sv, nl, e mais.

### Notas Importantes
- O idioma de origem pode ser autodetectado passando uma string vazia `''`
- A qualidade depende do modelo; idiomas europeus geralmente apresentam melhores resultados
- Funciona bem em modo batch em milhoes de linhas

## Funcao EXTRACT_ANSWER

Extrai a resposta de uma pergunta a partir de um texto de contexto fornecido.

```sql
SELECT SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
    document_text,
    'What is the annual revenue?'
) AS answer
FROM financial_reports;
```

- Retorna a resposta mais relevante do texto
- Retorna vazio se nenhuma resposta for encontrada
- NAO gera -- apenas extrai do contexto fornecido

## Funcao CLASSIFY_TEXT

Classificacao de texto zero-shot em categorias definidas pelo usuario.

```sql
SELECT SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
    ticket_description,
    ['billing', 'technical', 'account', 'feature_request']
) AS classification
FROM support_tickets;
```

- Retorna o rotulo da categoria e a pontuacao de confianca
- Nao sao necessarios dados de treinamento -- as categorias sao definidas no momento da consulta
- Funciona com qualquer conjunto razoavel de categorias

## Funcoes de Embedding

### EMBED_TEXT_768 / EMBED_TEXT_1024
Convertem texto em representacoes vetoriais densas para busca por similaridade.

```sql
-- Criar embeddings
SELECT
    doc_id,
    SNOWFLAKE.CORTEX.EMBED_TEXT_768('snowflake-arctic-embed-m', text_content) AS embedding
FROM documents;

-- Armazenar em coluna VECTOR
ALTER TABLE documents ADD COLUMN embedding VECTOR(FLOAT, 768);
UPDATE documents SET embedding = SNOWFLAKE.CORTEX.EMBED_TEXT_768(
    'snowflake-arctic-embed-m', text_content
);
```

### Modelos de Embedding Disponiveis
| Modelo | Dimensoes | Melhor Para |
|--------|-----------|-------------|
| snowflake-arctic-embed-m | 768 | Proposito geral, bom equilibrio |
| snowflake-arctic-embed-l | 1024 | Maior qualidade, mais computacao |
| e5-base-v2 | 768 | Leve, rapido |
| voyage-multilingual-2 | 1024 | Embedding multilingue |

### Busca por Similaridade Vetorial
```sql
-- Encontrar documentos similares usando similaridade cosseno
SELECT doc_id, text_content,
    VECTOR_COSINE_SIMILARITY(
        embedding,
        SNOWFLAKE.CORTEX.EMBED_TEXT_768('snowflake-arctic-embed-m', 'search query')
    ) AS similarity
FROM documents
ORDER BY similarity DESC
LIMIT 10;
```

### Funcoes de Distancia Vetorial
| Funcao | Descricao |
|--------|-----------|
| `VECTOR_COSINE_SIMILARITY(a, b)` | Similaridade cosseno (0 a 1) |
| `VECTOR_L2_DISTANCE(a, b)` | Distancia euclidiana |
| `VECTOR_INNER_PRODUCT(a, b)` | Produto escalar |

## Uso de Funcoes Cortex em Pipelines

### Com Dynamic Tables
```sql
CREATE OR REPLACE DYNAMIC TABLE enriched_reviews
  TARGET_LAG = '1 hour'
  WAREHOUSE = my_wh
AS
SELECT
    review_id,
    review_text,
    SNOWFLAKE.CORTEX.SENTIMENT(review_text) AS sentiment,
    SNOWFLAKE.CORTEX.CLASSIFY_TEXT(review_text,
        ['product', 'shipping', 'support']) AS category
FROM raw_reviews;
```

### Com Tasks
```sql
CREATE TASK enrich_new_data
  WAREHOUSE = my_wh
  SCHEDULE = 'USING CRON 0 */6 * * * UTC'
AS
  INSERT INTO enriched_data
  SELECT id, text,
    SNOWFLAKE.CORTEX.SUMMARIZE(text) AS summary
  FROM staging_data
  WHERE NOT processed;
```

### Com Streams (CDC)
```sql
CREATE STREAM reviews_stream ON TABLE raw_reviews;
-- Processar apenas registros novos/alterados
INSERT INTO enriched_reviews
SELECT r.*, SNOWFLAKE.CORTEX.SENTIMENT(r.review_text) AS sentiment
FROM reviews_stream r
WHERE METADATA$ACTION = 'INSERT';
```

## Limitacoes de Python UDF

- **Funcoes Cortex NAO podem ser chamadas de dentro de Python UDFs** diretamente
- Esta e uma limitacao arquitetonica fundamental -- UDFs rodam em um ambiente isolado (sandbox)
- Solucao alternativa: chamar funcoes Cortex em SQL antes/depois do UDF, nao dentro dele
- JavaScript UDFs possuem a mesma limitacao

## Tratamento de Erros e Limites de Taxa

### Limites de Taxa
- Limites de taxa por conta na vazao de tokens
- Varia por modelo e nivel da conta
- Retorna HTTP 429 ou erro SQL quando excedido

### Melhores Praticas para Producao
1. Adicionar logica de retentativa em pipelines baseados em tasks
2. Processar em lotes em vez de linha por linha
3. Usar modelos menores para tarefas de alto volume e menor complexidade
4. Armazenar em cache os resultados para entradas identicas repetidas
5. Monitorar o consumo de creditos atraves das views de ACCOUNT_USAGE

## Topicos Chave para o Exame

1. **COMPLETE e a mais flexivel** -- prompt simples ou mensagens estruturadas com opcoes
2. **SENTIMENT retorna -1 a 1** -- nao 0 a 1
3. **EXTRACT_ANSWER extrai, nao gera** -- a resposta deve existir no contexto
4. **TRANSLATE pode autodetectar** o idioma de origem com string vazia
5. **Modelos de embedding produzem vetores de tamanho fixo** -- 768 ou 1024 dimensoes
6. **Similaridade vetorial via VECTOR_COSINE_SIMILARITY** -- integrado, nao sao necessarias extensoes
7. **Nao e possivel chamar Cortex de Python UDFs** -- limitacao arquitetonica
8. **Dynamic Tables + Cortex = pipeline de enriquecimento automatizado**
9. **O parametro de opcoes muda o tipo de retorno** -- modo simples retorna VARCHAR, modo com opcoes retorna VARIANT
10. **A opcao guardrails** habilita a filtragem de seguranca de conteudo
11. **Todas as funcoes sao serverless** -- cobradas por tokens, nao por tempo de warehouse
12. **SUMMARIZE nao tem parametro de modelo** -- Snowflake seleciona automaticamente

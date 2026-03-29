# Domain 2: Snowflake Gen AI & LLM Functions (44%)

## Cortex LLM Functions Overview

All Cortex AI functions live under the `SNOWFLAKE.CORTEX` schema. They are SQL-callable, serverless, and billed per token processed.

### Core Functions

| Function | Purpose | Input | Output |
|----------|---------|-------|--------|
| `COMPLETE` | Text generation / chat | model, prompt (or messages) | Generated text |
| `EXTRACT_ANSWER` | Question answering from context | text, question | Answer string |
| `SENTIMENT` | Sentiment score | text | Float (-1 to 1) |
| `SUMMARIZE` | Text summarization | text | Summary string |
| `TRANSLATE` | Language translation | text, source_lang, target_lang | Translated text |
| `EMBED_TEXT_768` | Text embedding (768-dim) | model, text | VECTOR(FLOAT, 768) |
| `EMBED_TEXT_1024` | Text embedding (1024-dim) | model, text | VECTOR(FLOAT, 1024) |
| `CLASSIFY_TEXT` | Zero-shot classification | text, categories | Category + score |

## COMPLETE Function -- Deep Dive

The most versatile function. Supports both simple prompts and structured chat messages.

### Simple Mode
```sql
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'snowflake-arctic-instruct',
    'Explain data sharing in Snowflake in 3 sentences.'
) AS response;
```

### Chat Messages Mode
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

### Options Parameter
| Option | Type | Description |
|--------|------|-------------|
| `temperature` | Float (0-1) | Randomness. 0 = deterministic, 1 = creative |
| `max_tokens` | Integer | Maximum output length |
| `top_p` | Float (0-1) | Nucleus sampling threshold |
| `guardrails` | Boolean | Enable content safety filters |

### COMPLETE with Structured Output
```sql
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'llama3.1-70b',
    'Extract the name and email from: John Smith, john@example.com',
    {'response_format': {'type': 'json'}}
)::VARIANT:name AS name;
```

### Key Behaviors
- Returns a VARCHAR in simple mode
- Returns a VARIANT (JSON object) when using options -- access with `:choices[0]:messages`
- **Streaming is NOT supported** in SQL -- only via REST API / Python
- Functions are **stateless** -- no conversation memory between calls
- Rate limits apply per account -- plan for retries in pipelines

## SENTIMENT Function

Returns a float between -1 (very negative) and 1 (very positive).

```sql
SELECT
    review_text,
    SNOWFLAKE.CORTEX.SENTIMENT(review_text) AS score
FROM customer_reviews;
```

### Score Interpretation
| Range | Meaning |
|-------|---------|
| 0.5 to 1.0 | Positive |
| -0.2 to 0.5 | Neutral |
| -1.0 to -0.2 | Negative |

### Use at Scale
```sql
-- Aggregate sentiment by product
SELECT
    product_id,
    AVG(SNOWFLAKE.CORTEX.SENTIMENT(review)) AS avg_sentiment,
    COUNT(*) AS review_count
FROM reviews
GROUP BY product_id
ORDER BY avg_sentiment;
```

## SUMMARIZE Function

Produces a concise summary of the input text.

```sql
SELECT SNOWFLAKE.CORTEX.SUMMARIZE(article_text) AS summary
FROM news_articles
WHERE publish_date > CURRENT_DATE - 7;
```

- Input length: handles long texts (model-dependent context window)
- Output: single paragraph summary by default
- No model parameter -- Snowflake selects the optimal model

## TRANSLATE Function

```sql
SELECT SNOWFLAKE.CORTEX.TRANSLATE(
    description,
    'en',    -- source language
    'es'     -- target language
) AS spanish_description
FROM products;
```

### Supported Language Codes
en, es, fr, de, pt, it, ja, ko, zh, ru, ar, pl, sv, nl, and more.

### Key Notes
- Source language can be auto-detected by passing empty string `''`
- Quality is model-dependent; European languages generally best
- Works well in batch mode across millions of rows

## EXTRACT_ANSWER Function

Extracts the answer to a question from a given context text.

```sql
SELECT SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
    document_text,
    'What is the annual revenue?'
) AS answer
FROM financial_reports;
```

- Returns the most relevant answer from the text
- Returns empty if no answer found
- Does NOT generate -- only extracts from provided context

## CLASSIFY_TEXT Function

Zero-shot text classification into user-defined categories.

```sql
SELECT SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
    ticket_description,
    ['billing', 'technical', 'account', 'feature_request']
) AS classification
FROM support_tickets;
```

- Returns the category label and confidence score
- No training data needed -- categories defined at query time
- Works with any reasonable category set

## Embedding Functions

### EMBED_TEXT_768 / EMBED_TEXT_1024
Convert text to dense vector representations for similarity search.

```sql
-- Create embeddings
SELECT
    doc_id,
    SNOWFLAKE.CORTEX.EMBED_TEXT_768('snowflake-arctic-embed-m', text_content) AS embedding
FROM documents;

-- Store in VECTOR column
ALTER TABLE documents ADD COLUMN embedding VECTOR(FLOAT, 768);
UPDATE documents SET embedding = SNOWFLAKE.CORTEX.EMBED_TEXT_768(
    'snowflake-arctic-embed-m', text_content
);
```

### Available Embedding Models
| Model | Dimensions | Best For |
|-------|-----------|----------|
| snowflake-arctic-embed-m | 768 | General purpose, good balance |
| snowflake-arctic-embed-l | 1024 | Higher quality, more compute |
| e5-base-v2 | 768 | Lightweight, fast |
| voyage-multilingual-2 | 1024 | Multilingual embedding |

### Vector Similarity Search
```sql
-- Find similar documents using cosine similarity
SELECT doc_id, text_content,
    VECTOR_COSINE_SIMILARITY(
        embedding,
        SNOWFLAKE.CORTEX.EMBED_TEXT_768('snowflake-arctic-embed-m', 'search query')
    ) AS similarity
FROM documents
ORDER BY similarity DESC
LIMIT 10;
```

### Vector Distance Functions
| Function | Description |
|----------|-------------|
| `VECTOR_COSINE_SIMILARITY(a, b)` | Cosine similarity (0 to 1) |
| `VECTOR_L2_DISTANCE(a, b)` | Euclidean distance |
| `VECTOR_INNER_PRODUCT(a, b)` | Dot product |

## Using Cortex Functions in Pipelines

### With Dynamic Tables
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

### With Tasks
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

### With Streams (CDC)
```sql
CREATE STREAM reviews_stream ON TABLE raw_reviews;
-- Process only new/changed records
INSERT INTO enriched_reviews
SELECT r.*, SNOWFLAKE.CORTEX.SENTIMENT(r.review_text) AS sentiment
FROM reviews_stream r
WHERE METADATA$ACTION = 'INSERT';
```

## Python UDF Limitations

- **Cortex functions CANNOT be called from within Python UDFs** directly
- This is a fundamental architectural limitation -- UDFs run in a sandboxed environment
- Workaround: call Cortex functions in SQL before/after the UDF, not inside it
- JavaScript UDFs have the same limitation

## Error Handling and Rate Limits

### Rate Limits
- Per-account rate limits on token throughput
- Varies by model and account tier
- Returns HTTP 429 or SQL error when exceeded

### Best Practices for Production
1. Add retry logic in task-based pipelines
2. Process in batches rather than row-by-row
3. Use smaller models for high-volume, simpler tasks
4. Cache results for repeated identical inputs
5. Monitor credit consumption via ACCOUNT_USAGE views

## Key Exam Topics to Remember

1. **COMPLETE is the most flexible** -- simple prompt or structured messages with options
2. **SENTIMENT returns -1 to 1** -- not 0 to 1
3. **EXTRACT_ANSWER extracts, does not generate** -- answer must exist in context
4. **TRANSLATE can auto-detect** source language with empty string
5. **Embedding models produce fixed-size vectors** -- 768 or 1024 dimensions
6. **Vector similarity via VECTOR_COSINE_SIMILARITY** -- built-in, no extensions needed
7. **Cannot call Cortex from Python UDFs** -- architectural limitation
8. **Dynamic Tables + Cortex = automated enrichment** pipeline pattern
9. **Options parameter changes return type** -- simple mode returns VARCHAR, options mode returns VARIANT
10. **guardrails option** enables content safety filtering
11. **All functions are serverless** -- billed by tokens, not warehouse time
12. **SUMMARIZE has no model parameter** -- Snowflake auto-selects

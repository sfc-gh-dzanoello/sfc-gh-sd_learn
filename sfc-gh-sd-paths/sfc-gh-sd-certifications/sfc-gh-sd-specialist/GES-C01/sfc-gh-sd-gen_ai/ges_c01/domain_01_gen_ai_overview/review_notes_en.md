# Domain 1: Snowflake for Gen AI Overview (30%)

## What is Snowflake Cortex AI

Snowflake Cortex AI is a fully managed service that provides access to large language models (LLMs) and AI functions directly within Snowflake. It eliminates the need for external infrastructure, GPU management, or model hosting -- everything runs inside the Snowflake security and governance perimeter.

### Key Principles
- **Data stays in Snowflake** -- no data movement to external APIs
- **SQL-native** -- all AI functions callable via standard SQL
- **Serverless** -- no warehouse or compute provisioning required for Cortex functions
- **Governed** -- inherits Snowflake RBAC, masking, row access policies

## Cortex AI Architecture

### How It Works
1. User calls a Cortex function (e.g., `SNOWFLAKE.CORTEX.COMPLETE(...)`) in SQL
2. Snowflake routes the request to managed GPU infrastructure
3. The model processes the input and returns results inline
4. No data leaves the Snowflake security boundary

### Compute Model
- Cortex functions use **serverless compute** -- not virtual warehouses
- Billing is based on **tokens processed** (input + output tokens)
- Each function has its own credit consumption rate
- No warehouse credits are consumed

## Available LLM Models

Snowflake hosts multiple models for different use cases:

| Model | Provider | Best For |
|-------|----------|----------|
| snowflake-arctic-instruct | Snowflake | General purpose, cost-effective |
| llama3.1-70b | Meta | Complex reasoning, long context |
| llama3.1-8b | Meta | Fast, lightweight tasks |
| mistral-large2 | Mistral | Multilingual, instruction following |
| mixtral-8x7b | Mistral | Balanced speed/quality |
| jamba-1.5-large | AI21 | Long documents (256K context) |
| jamba-1.5-mini | AI21 | Cost-effective long context |
| gemma-7b | Google | Compact, efficient |

### Model Selection Criteria
- **Cost sensitivity** -- smaller models (8b params) cost less per token
- **Quality needs** -- larger models produce better outputs for complex tasks
- **Context window** -- Jamba models handle very long inputs (256K tokens)
- **Latency** -- smaller models respond faster
- **Language support** -- Mistral models excel at multilingual tasks

## Gen AI Use Cases in Snowflake

### Text Analytics at Scale
- Sentiment analysis on customer reviews
- Content classification and categorization
- Entity extraction from unstructured data
- Summarization of long documents

### Data Enrichment
- Generating product descriptions from attributes
- Translating content across languages
- Extracting structured data from free text
- Augmenting records with AI-generated metadata

### Search and Retrieval
- **Cortex Search** -- managed RAG (Retrieval-Augmented Generation) service
- Semantic search over unstructured data
- Hybrid search combining keyword + vector similarity
- Automatic chunking and embedding of documents

### Conversational AI
- Building chatbots with Cortex Agents
- Multi-turn conversations with context
- Tool use and function calling
- Integration with Streamlit apps

## Cortex Search Service

### What It Is
A fully managed service for building RAG applications. Handles chunking, embedding, indexing, and retrieval automatically.

### Key Components
- **Source data** -- tables with text columns to search over
- **Search service** -- created with `CREATE CORTEX SEARCH SERVICE`
- **Target lag** -- how fresh the index should be (similar to Dynamic Tables)
- **Embedding** -- automatic vector embedding of source text
- **Retrieval** -- hybrid search (semantic + keyword) out of the box

### Architecture
```
Source Table -> Cortex Search Service -> Automatic Indexing
                                      -> Hybrid Retrieval
                                      -> API / SQL Access
```

### Key SQL
```sql
CREATE OR REPLACE CORTEX SEARCH SERVICE my_search
  ON text_column
  ATTRIBUTES category, date
  WAREHOUSE = my_wh
  TARGET_LAG = '1 hour'
  AS (
    SELECT text_column, category, date
    FROM my_source_table
  );
```

## Cortex Agents

### What They Are
Pre-built orchestration layer that combines LLMs with tools (Cortex Search, SQL execution, Cortex Analyst) to answer complex questions autonomously.

### Components
- **LLM** -- the reasoning engine
- **Tools** -- Cortex Search services, Cortex Analyst semantic models, SQL exec
- **Orchestration** -- automatic tool selection and multi-step reasoning

### Key Differences from Raw LLM Calls
| Feature | COMPLETE Function | Cortex Agent |
|---------|------------------|--------------|
| Context | User provides all context | Agent retrieves context via tools |
| Multi-step | Single call | Automatic chain of calls |
| Data access | None (text only) | Can query tables, search docs |
| Grounding | None | Grounded in actual data |

## Cortex Analyst

### What It Is
A natural language to SQL engine powered by semantic models. Users ask questions in plain English, and Cortex Analyst generates and executes SQL.

### Semantic Model
- YAML file defining tables, columns, metrics, dimensions
- Maps business terms to physical columns
- Defines relationships and calculation logic
- Stored in a Snowflake stage

### How It Works
1. User asks a question in natural language
2. Cortex Analyst interprets using the semantic model
3. Generates SQL based on the model definitions
4. Returns results (data + generated SQL)

## Snowflake Notebooks for AI

### AI/ML Capabilities
- Native Python environment with GPU access
- Pre-installed ML libraries (scikit-learn, PyTorch, XGBoost)
- Direct access to Snowpark DataFrames
- Integration with Cortex functions via Python API

### Container Runtime
- Notebooks can run on **CPU or GPU** compute pools
- GPU notebooks support CUDA for deep learning
- Separate from virtual warehouses

## Key Exam Topics to Remember

1. **Cortex functions are serverless** -- no warehouse needed, billed by tokens
2. **Data never leaves Snowflake** -- key security differentiator
3. **Model selection matters** -- each model has different strengths/costs
4. **Cortex Search = managed RAG** -- handles chunking, embedding, retrieval
5. **Cortex Agents vs COMPLETE** -- agents are multi-step with tool access
6. **Cortex Analyst = NL2SQL** -- needs a semantic model YAML
7. **Snowflake Arctic** -- Snowflake's own open-source model family
8. **Context windows vary** -- from 4K to 256K tokens depending on model
9. **All functions are SQL-callable** -- `SNOWFLAKE.CORTEX.*`
10. **Governance applies** -- RBAC, masking policies work with Cortex output

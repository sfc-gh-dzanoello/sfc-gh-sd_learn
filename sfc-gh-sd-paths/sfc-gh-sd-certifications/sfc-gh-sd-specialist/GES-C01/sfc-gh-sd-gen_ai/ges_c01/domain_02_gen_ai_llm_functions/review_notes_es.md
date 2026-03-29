# Dominio 2: Snowflake Gen AI y Funciones LLM (44%)

## Descripcion General de las Funciones Cortex LLM

Todas las funciones de Cortex AI se encuentran en el esquema `SNOWFLAKE.CORTEX`. Son invocables desde SQL, serverless, y se facturan por token procesado.

### Funciones Principales

| Funcion | Proposito | Entrada | Salida |
|---------|-----------|---------|--------|
| `COMPLETE` | Generacion de texto / chat | modelo, prompt (o mensajes) | Texto generado |
| `EXTRACT_ANSWER` | Respuesta a preguntas desde contexto | texto, pregunta | Cadena de respuesta |
| `SENTIMENT` | Puntuacion de sentimiento | texto | Float (-1 a 1) |
| `SUMMARIZE` | Resumen de texto | texto | Cadena de resumen |
| `TRANSLATE` | Traduccion de idiomas | texto, idioma_origen, idioma_destino | Texto traducido |
| `EMBED_TEXT_768` | Embedding de texto (768 dim) | modelo, texto | VECTOR(FLOAT, 768) |
| `EMBED_TEXT_1024` | Embedding de texto (1024 dim) | modelo, texto | VECTOR(FLOAT, 1024) |
| `CLASSIFY_TEXT` | Clasificacion zero-shot | texto, categorias | Categoria + puntuacion |

## Funcion COMPLETE -- Analisis en Profundidad

La funcion mas versatil. Soporta tanto prompts simples como mensajes de chat estructurados.

### Modo Simple
```sql
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'snowflake-arctic-instruct',
    'Explica el data sharing en Snowflake en 3 oraciones.'
) AS response;
```

### Modo de Mensajes de Chat
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

### Parametro de Opciones
| Opcion | Tipo | Descripcion |
|--------|------|-------------|
| `temperature` | Float (0-1) | Aleatoriedad. 0 = deterministico, 1 = creativo |
| `max_tokens` | Integer | Longitud maxima de salida |
| `top_p` | Float (0-1) | Umbral de muestreo de nucleo |
| `guardrails` | Boolean | Habilitar filtros de seguridad de contenido |

### COMPLETE con Salida Estructurada
```sql
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'llama3.1-70b',
    'Extract the name and email from: John Smith, john@example.com',
    {'response_format': {'type': 'json'}}
)::VARIANT:name AS name;
```

### Comportamientos Clave
- Retorna un VARCHAR en modo simple
- Retorna un VARIANT (objeto JSON) cuando se usan opciones -- se accede con `:choices[0]:messages`
- **El streaming NO esta soportado** en SQL -- solo via REST API / Python
- Las funciones son **sin estado (stateless)** -- no hay memoria de conversacion entre llamadas
- Aplican limites de tasa por cuenta -- planificar reintentos en pipelines

## Funcion SENTIMENT

Retorna un float entre -1 (muy negativo) y 1 (muy positivo).

```sql
SELECT
    review_text,
    SNOWFLAKE.CORTEX.SENTIMENT(review_text) AS score
FROM customer_reviews;
```

### Interpretacion de Puntuacion
| Rango | Significado |
|-------|-------------|
| 0.5 a 1.0 | Positivo |
| -0.2 a 0.5 | Neutral |
| -1.0 a -0.2 | Negativo |

### Uso a Escala
```sql
-- Agregar sentimiento por producto
SELECT
    product_id,
    AVG(SNOWFLAKE.CORTEX.SENTIMENT(review)) AS avg_sentiment,
    COUNT(*) AS review_count
FROM reviews
GROUP BY product_id
ORDER BY avg_sentiment;
```

## Funcion SUMMARIZE

Produce un resumen conciso del texto de entrada.

```sql
SELECT SNOWFLAKE.CORTEX.SUMMARIZE(article_text) AS summary
FROM news_articles
WHERE publish_date > CURRENT_DATE - 7;
```

- Longitud de entrada: maneja textos largos (ventana de contexto dependiente del modelo)
- Salida: resumen de un solo parrafo por defecto
- Sin parametro de modelo -- Snowflake selecciona el modelo optimo

## Funcion TRANSLATE

```sql
SELECT SNOWFLAKE.CORTEX.TRANSLATE(
    description,
    'en',    -- idioma de origen
    'es'     -- idioma de destino
) AS spanish_description
FROM products;
```

### Codigos de Idioma Soportados
en, es, fr, de, pt, it, ja, ko, zh, ru, ar, pl, sv, nl, y mas.

### Notas Clave
- El idioma de origen puede ser autodetectado pasando una cadena vacia `''`
- La calidad depende del modelo; los idiomas europeos generalmente obtienen mejores resultados
- Funciona bien en modo batch a traves de millones de filas

## Funcion EXTRACT_ANSWER

Extrae la respuesta a una pregunta de un texto de contexto dado.

```sql
SELECT SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
    document_text,
    'What is the annual revenue?'
) AS answer
FROM financial_reports;
```

- Retorna la respuesta mas relevante del texto
- Retorna vacio si no se encuentra respuesta
- NO genera -- solo extrae del contexto proporcionado

## Funcion CLASSIFY_TEXT

Clasificacion de texto zero-shot en categorias definidas por el usuario.

```sql
SELECT SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
    ticket_description,
    ['billing', 'technical', 'account', 'feature_request']
) AS classification
FROM support_tickets;
```

- Retorna la etiqueta de categoria y la puntuacion de confianza
- No se necesitan datos de entrenamiento -- las categorias se definen en tiempo de consulta
- Funciona con cualquier conjunto razonable de categorias

## Funciones de Embedding

### EMBED_TEXT_768 / EMBED_TEXT_1024
Convierten texto en representaciones vectoriales densas para busqueda por similitud.

```sql
-- Crear embeddings
SELECT
    doc_id,
    SNOWFLAKE.CORTEX.EMBED_TEXT_768('snowflake-arctic-embed-m', text_content) AS embedding
FROM documents;

-- Almacenar en columna VECTOR
ALTER TABLE documents ADD COLUMN embedding VECTOR(FLOAT, 768);
UPDATE documents SET embedding = SNOWFLAKE.CORTEX.EMBED_TEXT_768(
    'snowflake-arctic-embed-m', text_content
);
```

### Modelos de Embedding Disponibles
| Modelo | Dimensiones | Mejor Para |
|--------|-------------|------------|
| snowflake-arctic-embed-m | 768 | Proposito general, buen equilibrio |
| snowflake-arctic-embed-l | 1024 | Mayor calidad, mas computo |
| e5-base-v2 | 768 | Ligero, rapido |
| voyage-multilingual-2 | 1024 | Embedding multilingue |

### Busqueda por Similitud Vectorial
```sql
-- Encontrar documentos similares usando similitud coseno
SELECT doc_id, text_content,
    VECTOR_COSINE_SIMILARITY(
        embedding,
        SNOWFLAKE.CORTEX.EMBED_TEXT_768('snowflake-arctic-embed-m', 'search query')
    ) AS similarity
FROM documents
ORDER BY similarity DESC
LIMIT 10;
```

### Funciones de Distancia Vectorial
| Funcion | Descripcion |
|---------|-------------|
| `VECTOR_COSINE_SIMILARITY(a, b)` | Similitud coseno (0 a 1) |
| `VECTOR_L2_DISTANCE(a, b)` | Distancia euclidiana |
| `VECTOR_INNER_PRODUCT(a, b)` | Producto punto |

## Uso de Funciones Cortex en Pipelines

### Con Dynamic Tables
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

### Con Tasks
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

### Con Streams (CDC)
```sql
CREATE STREAM reviews_stream ON TABLE raw_reviews;
-- Procesar solo registros nuevos/modificados
INSERT INTO enriched_reviews
SELECT r.*, SNOWFLAKE.CORTEX.SENTIMENT(r.review_text) AS sentiment
FROM reviews_stream r
WHERE METADATA$ACTION = 'INSERT';
```

## Limitaciones de Python UDF

- **Las funciones Cortex NO pueden ser llamadas desde Python UDFs** directamente
- Esta es una limitacion arquitectonica fundamental -- los UDFs se ejecutan en un entorno aislado (sandbox)
- Solucion alternativa: llamar las funciones Cortex en SQL antes/despues del UDF, no dentro de el
- Los JavaScript UDFs tienen la misma limitacion

## Manejo de Errores y Limites de Tasa

### Limites de Tasa
- Limites de tasa por cuenta en el rendimiento de tokens
- Varia segun el modelo y el nivel de la cuenta
- Retorna HTTP 429 o error SQL cuando se excede

### Mejores Practicas para Produccion
1. Agregar logica de reintentos en pipelines basados en tasks
2. Procesar en lotes en lugar de fila por fila
3. Usar modelos mas pequenos para tareas de alto volumen y menor complejidad
4. Almacenar en cache los resultados para entradas identicas repetidas
5. Monitorear el consumo de creditos a traves de las vistas de ACCOUNT_USAGE

## Temas Clave para el Examen

1. **COMPLETE es la mas flexible** -- prompt simple o mensajes estructurados con opciones
2. **SENTIMENT retorna -1 a 1** -- no 0 a 1
3. **EXTRACT_ANSWER extrae, no genera** -- la respuesta debe existir en el contexto
4. **TRANSLATE puede autodetectar** el idioma de origen con cadena vacia
5. **Los modelos de embedding producen vectores de tamano fijo** -- 768 o 1024 dimensiones
6. **Similitud vectorial via VECTOR_COSINE_SIMILARITY** -- integrado, no se necesitan extensiones
7. **No se puede llamar a Cortex desde Python UDFs** -- limitacion arquitectonica
8. **Dynamic Tables + Cortex = pipeline de enriquecimiento automatizado**
9. **El parametro de opciones cambia el tipo de retorno** -- modo simple retorna VARCHAR, modo con opciones retorna VARIANT
10. **La opcion guardrails** habilita el filtrado de seguridad de contenido
11. **Todas las funciones son serverless** -- se facturan por tokens, no por tiempo de warehouse
12. **SUMMARIZE no tiene parametro de modelo** -- Snowflake lo selecciona automaticamente

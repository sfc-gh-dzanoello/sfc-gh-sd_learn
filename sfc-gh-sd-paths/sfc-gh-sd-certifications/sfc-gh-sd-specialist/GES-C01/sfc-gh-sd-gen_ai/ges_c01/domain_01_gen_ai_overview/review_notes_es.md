# Dominio 1: Snowflake para Gen AI - Vision General (30%)

## Que es Snowflake Cortex AI

Snowflake Cortex AI es un servicio totalmente gestionado que proporciona acceso a modelos de lenguaje (LLMs) y funciones de IA directamente dentro de Snowflake. Elimina la necesidad de infraestructura externa, gestion de GPUs o hosting de modelos -- todo se ejecuta dentro del perimetro de seguridad y gobernanza de Snowflake.

### Principios Clave
- **Los datos permanecen en Snowflake** -- sin movimiento de datos a APIs externas
- **Nativo en SQL** -- todas las funciones de IA se llaman mediante SQL estandar
- **Serverless** -- no requiere aprovisionamiento de warehouse o computo
- **Gobernado** -- hereda RBAC, politicas de enmascaramiento y acceso a filas

## Arquitectura de Cortex AI

### Como Funciona
1. El usuario llama una funcion Cortex (ej. `SNOWFLAKE.CORTEX.COMPLETE(...)`) en SQL
2. Snowflake enruta la solicitud a infraestructura GPU gestionada
3. El modelo procesa la entrada y devuelve resultados en linea
4. Ningun dato sale del limite de seguridad de Snowflake

### Modelo de Computo
- Las funciones Cortex usan **computo serverless** -- no warehouses virtuales
- La facturacion se basa en **tokens procesados** (tokens de entrada + salida)
- Cada funcion tiene su propia tasa de consumo de creditos
- No se consumen creditos de warehouse

## Modelos LLM Disponibles

| Modelo | Proveedor | Mejor Para |
|--------|-----------|------------|
| snowflake-arctic-instruct | Snowflake | Proposito general, costo-efectivo |
| llama3.1-70b | Meta | Razonamiento complejo, contexto largo |
| llama3.1-8b | Meta | Tareas rapidas y ligeras |
| mistral-large2 | Mistral | Multilingue, seguimiento de instrucciones |
| mixtral-8x7b | Mistral | Equilibrio velocidad/calidad |
| jamba-1.5-large | AI21 | Documentos largos (256K de contexto) |
| jamba-1.5-mini | AI21 | Contexto largo costo-efectivo |

### Criterios de Seleccion de Modelo
- **Sensibilidad al costo** -- modelos pequenos cuestan menos por token
- **Necesidades de calidad** -- modelos grandes producen mejores resultados
- **Ventana de contexto** -- modelos Jamba manejan entradas muy largas (256K tokens)
- **Latencia** -- modelos pequenos responden mas rapido
- **Soporte de idiomas** -- modelos Mistral destacan en tareas multilingues

## Casos de Uso de Gen AI en Snowflake

### Analitica de Texto a Escala
- Analisis de sentimiento en resenas de clientes
- Clasificacion y categorizacion de contenido
- Extraccion de entidades de datos no estructurados
- Resumen de documentos largos

### Enriquecimiento de Datos
- Generacion de descripciones de productos desde atributos
- Traduccion de contenido entre idiomas
- Extraccion de datos estructurados desde texto libre
- Aumento de registros con metadatos generados por IA

### Busqueda y Recuperacion
- **Cortex Search** -- servicio gestionado de RAG (Generacion Aumentada por Recuperacion)
- Busqueda semantica sobre datos no estructurados
- Busqueda hibrida combinando palabras clave + similitud vectorial
- Fragmentacion y embedding automatico de documentos

### IA Conversacional
- Construccion de chatbots con Cortex Agents
- Conversaciones multi-turno con contexto
- Uso de herramientas y llamadas a funciones
- Integracion con aplicaciones Streamlit

## Servicio Cortex Search

### Que Es
Un servicio totalmente gestionado para construir aplicaciones RAG. Maneja la fragmentacion, embedding, indexacion y recuperacion automaticamente.

### Componentes Clave
- **Datos fuente** -- tablas con columnas de texto para buscar
- **Servicio de busqueda** -- creado con `CREATE CORTEX SEARCH SERVICE`
- **Target lag** -- que tan fresco debe ser el indice (similar a Dynamic Tables)
- **Embedding** -- embedding vectorial automatico del texto fuente
- **Recuperacion** -- busqueda hibrida (semantica + palabras clave)

## Cortex Agents

### Que Son
Capa de orquestacion pre-construida que combina LLMs con herramientas (Cortex Search, ejecucion SQL, Cortex Analyst) para responder preguntas complejas autonomamente.

### Diferencias Clave con Llamadas LLM Directas
| Caracteristica | Funcion COMPLETE | Cortex Agent |
|---------------|-----------------|--------------|
| Contexto | Usuario proporciona todo | Agente recupera via herramientas |
| Multi-paso | Llamada unica | Cadena automatica |
| Acceso a datos | Ninguno (solo texto) | Puede consultar tablas y docs |
| Fundamentacion | Ninguna | Basado en datos reales |

## Cortex Analyst

### Que Es
Un motor de lenguaje natural a SQL impulsado por modelos semanticos. Los usuarios hacen preguntas en lenguaje natural, y Cortex Analyst genera y ejecuta SQL.

### Modelo Semantico
- Archivo YAML que define tablas, columnas, metricas, dimensiones
- Mapea terminos de negocio a columnas fisicas
- Define relaciones y logica de calculo
- Almacenado en un stage de Snowflake

## Temas Clave para el Examen

1. **Las funciones Cortex son serverless** -- sin warehouse, facturadas por tokens
2. **Los datos nunca salen de Snowflake** -- diferenciador clave de seguridad
3. **La seleccion de modelo importa** -- cada modelo tiene diferentes fortalezas/costos
4. **Cortex Search = RAG gestionado** -- maneja fragmentacion, embedding, recuperacion
5. **Cortex Agents vs COMPLETE** -- agentes son multi-paso con acceso a herramientas
6. **Cortex Analyst = NL2SQL** -- necesita un YAML de modelo semantico
7. **Snowflake Arctic** -- familia de modelos open-source propios de Snowflake
8. **Las ventanas de contexto varian** -- de 4K a 256K tokens segun el modelo
9. **Todas las funciones son SQL** -- `SNOWFLAKE.CORTEX.*`
10. **La gobernanza aplica** -- RBAC y politicas de enmascaramiento funcionan con Cortex

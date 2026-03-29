# DOMINIO 1: CARACTERÍSTICAS Y ARQUITECTURA DE SNOWFLAKE AI DATA CLOUD
## 31% del examen = ~31 preguntas. Este es el DOMINIO MÁS GRANDE.

---

## 1.1 LAS TRES CAPAS

Snowflake = híbrido de shared-disk + shared-nothing.
Tres capas independientes que escalan de forma independiente:

```
┌─────────────────────────────────┐
│    CAPA DE CLOUD SERVICES       │  ← "El Cerebro"
│  Auth, Seguridad, Metadatos,    │
│  Optimizador de Consultas,      │
│  Transacciones. Funciona 24/7.  │
│  Se cobra solo si >10% de los   │
│  créditos diarios de warehouse  │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│        CAPA DE COMPUTE          │  ← "El Músculo"
│  Virtual Warehouses (VW)        │
│  Clusters independientes, sin   │
│  compartir entre WHs            │
│  Se cobra por segundo (mín 60s) │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│  CAPA DE ALMACENAMIENTO (DB)    │  ← "La Memoria"
│  Almacenamiento centralizado    │
│  Micro-particiones columnares   │
│  Comprimidas, encriptadas,      │
│  inmutables. Se cobra por TB/mes│
└─────────────────────────────────┘
```

### La Capa de Cloud Services se encarga de:
- Autenticación + control de acceso (RBAC + DAC)
- Análisis + optimización de consultas
- Gestión de metadatos
- Gestión de transacciones (cumplimiento ACID)
- Gestión de infraestructura
- Seguridad + encriptación

**Exam trap**: "¿Qué capa se encarga de la optimización de consultas?" → Cloud Services. SI VES "Capa de Compute optimiza" → INCORRECTO, Compute solo ejecuta consultas.
**Exam trap**: "¿Qué capa se encarga de ACID/transacciones?" → Cloud Services. SI VES "Capa de Storage" o "Capa de Compute" con "transacciones" → INCORRECTO, solo Cloud Services gestiona transacciones.
**Exam trap**: "¿Qué capa garantiza que el Usuario A no vea cambios no confirmados del Usuario B?" → Cloud Services (Gestión de Transacciones). SI VES "aislamiento" + "Compute" → INCORRECTO, aislamiento de transacciones = Cloud Services.

### Cobro de Cloud Services:
- Solo se cobra si el uso de Cloud Services > 10% del uso diario total de créditos de warehouse
- La mayoría de las cuentas nunca alcanza ese límite

Exam trap: "Cloud Services siempre se cobra por separado" → INCORRECTO. SI VES "siempre" + "cobrado" con Cloud Services → INCORRECTO, solo se cobra si excede el 10% de créditos diarios de warehouse.
Exam trap: "El límite del 10% es mensual" → INCORRECTO. SI VES "mensual" con el límite del 10% → INCORRECTO, se calcula DIARIAMENTE, no mensualmente.

### Capa de Compute:
- Virtual warehouses = clusters MPP independientes
- Un warehouse NO afecta a otro
- Carga + consulta pueden ocurrir simultáneamente en la misma tabla (warehouses diferentes)
- El caché del warehouse está aquí (se pierde cuando el warehouse se suspende)

Exam trap: "El caché del warehouse persiste después de la suspensión" → INCORRECTO. SI VES "persiste" o "se mantiene" con "suspender" → INCORRECTO, el caché SSD se PIERDE al suspender. Solo el caché de resultados (Cloud Services) sobrevive.
Exam trap: "Dos warehouses comparten recursos de compute" → INCORRECTO. SI VES "comparten" o "recursos compartidos" entre warehouses → INCORRECTO, cada warehouse es totalmente independiente.

### Capa de Almacenamiento:
- Datos almacenados en el blob storage del proveedor de nube (S3, Azure Blob, GCS)
- Formato columnar, comprimido, encriptado
- El cliente no puede acceder directamente a los archivos subyacentes
- Se cobra mensualmente por TB (comprimido)

Exam trap: "Los clientes pueden acceder directamente a los archivos de almacenamiento subyacentes" → INCORRECTO. SI VES "acceso directo" o "navegar objetos S3" → INCORRECTO, Snowflake gestiona todos los archivos — sin acceso directo.
Exam trap: "El almacenamiento se cobra por TB sin comprimir" → INCORRECTO. SI VES "sin comprimir" con cobro de almacenamiento → INCORRECTO, se cobra por TB COMPRIMIDO.


### Ejemplos de Preguntas de Escenario — Three Layers

**Escenario:** A data engineer notices that query compilation takes unusually long, but once running, queries complete quickly. Which layer is the bottleneck, and what might cause this?
**Respuesta:** Cloud Services layer — it handles query parsing, optimization, and compilation. Possible causes: very complex SQL with many joins/subqueries, or high metadata overhead. This is NOT a Compute issue since execution is fast.

**Escenario:** Two teams share the same Snowflake account. Team A runs heavy ETL jobs while Team B runs real-time dashboards. Team B complains about slow performance. The admin confirms they use separate warehouses. Is it possible that Team A's workload affects Team B?
**Respuesta:** No. Virtual warehouses are completely independent in the Compute layer. Each warehouse has its own dedicated resources. If Team B is slow, the issue is with their own warehouse size, not Team A's workload. Check if Team B's warehouse needs scaling up.

**Escenario:** An auditor asks: "Where does Snowflake physically store our data, and can we access the raw files for compliance?" What is the correct answer?
**Respuesta:** Data is stored in the cloud provider's blob storage (S3/Azure Blob/GCS) in the Storage layer, in compressed, encrypted, columnar micro-partitions. You CANNOT directly access the raw files — Snowflake manages all storage. For compliance, use ACCOUNT_USAGE views, Access History, and Time Travel instead.

**Escenario:** Your Cloud Services costs suddenly spike to 15% of your daily warehouse credits. What happened and what do you pay?
**Respuesta:** You only pay for the amount exceeding 10%. If Cloud Services = 15% and warehouse credits = 100, you pay for 5 credits of Cloud Services (15 - 10 = 5). Common causes: excessive SHOW/DESCRIBE commands, heavy metadata operations, or complex query compilation on many small queries.

---

---

## 1.2 FUNDAMENTOS DE LA CUENTA SNOWFLAKE

### Una cuenta = un proveedor de nube + una región
- Una cuenta NO puede abarcar múltiples proveedores de nube
- Para usar AWS + Azure = necesitas cuentas separadas
- Usa Organizations para vincular cuentas entre proveedores/regiones
- La replicación puede sincronizar datos entre cuentas

### Identificadores de Cuenta (dos formatos):
1. **Organización + Nombre de cuenta**: `miorg-micuenta` (preferido)
2. **Account locator**: formato legacy, específico por región (ej: `xy12345.us-east-1`)

Exam trap: "Account locator es el formato preferido" → INCORRECTO. SI VES "locator" como "preferido" o "recomendado" → INCORRECTO, `miorg-micuenta` es preferido. Locator es legacy.
Exam trap: "Una cuenta puede abarcar AWS y Azure" → INCORRECTO. SI VES "abarcar" o "múltiples proveedores" en una cuenta → INCORRECTO, una cuenta = un proveedor de nube + una región.
Exam trap: "La replicación mueve la cuenta a otra región" → INCORRECTO. SI VES "mueve" con replicación → INCORRECTO, la replicación sincroniza DATOS entre cuentas. La cuenta se queda en su lugar.


### Ejemplos de Preguntas de Escenario — Account Basics

**Escenario:** A multinational company wants to use Snowflake on AWS in us-east-1 for their US team and Azure West Europe for their EU team. How many Snowflake accounts do they need?
**Respuesta:** At least 2 accounts — one per cloud provider/region combination. They should use Snowflake Organizations to manage both accounts and database replication to sync shared data between them.

**Escenario:** A developer shares their account identifier as `xy12345.us-east-1`. A colleague in another region tries to connect using that identifier but it doesn't resolve. Why?
**Respuesta:** Account locators are region-specific and legacy format. The preferred approach is using the organization-based format `myorg-myaccount` which works globally. The locator `xy12345.us-east-1` only works for that specific region.

**Escenario:** Management wants disaster recovery across AWS regions. Can they replicate their Snowflake account from us-east-1 to us-west-2?
**Respuesta:** Yes, but it requires a second Snowflake account in us-west-2. Database replication syncs data objects, while account replication (Business Critical+) syncs users, roles, warehouses, and policies. Both accounts are linked via Organizations.

---

---

## 1.3 EDICIONES (MUY IMPORTANTE EN EL EXAMEN)

### Standard Edition — TODO esto está incluido:
- Virtual warehouses (solo cluster único)
- Time Travel de 1 día
- Fail-safe de 7 días (solo tablas permanentes)
- Encriptación automática (AES-256)
- Políticas de red, MFA, SSO, OAuth
- RBAC + DAC
- UDFs (Java, JavaScript, Python, SQL)
- Stored procedures (Java, JavaScript, Python, Scala, SQL)
- Snowpark
- Tablas dinámicas
- Tablas externas
- Tablas híbridas
- Clustering (automático)
- Compartición de datos
- Monitores de recursos
- Soporte SQL estándar
- Datos semi-estructurados (JSON, Avro, ORC, Parquet, XML)
- Soporte de datos no estructurados
- Data Quality / Data Metric Functions

### Enterprise Edition = Standard + estas adiciones:
- Warehouses multi-cluster (escalar HORIZONTALMENTE)
- Time Travel extendido (hasta 90 días)
- Seguridad a nivel de columna (políticas de enmascaramiento)
- Seguridad a nivel de fila (políticas de acceso a filas)
- Políticas de agregación
- Políticas de proyección
- Clasificación de datos
- Historial de Acceso (vista ACCOUNT_USAGE)
- Rekeying periódico de datos encriptados
- Servicio de Optimización de Búsqueda
- Servicio de Aceleración de Consultas
- Vistas materializadas
- Generación de datos sintéticos

### Business Critical = Enterprise + estas adiciones:
- Tri-Secret Secure (claves gestionadas por el cliente)
- Conectividad privada (AWS PrivateLink, Azure Private Link, GCP Private Service Connect)
- Cumplimiento PHI/HIPAA/HITRUST
- Soporte PCI DSS
- Soporte FedRAMP/ITAR
- Failover/failback de cuenta (recuperación de desastres)

### VPS (Virtual Private Snowflake) = Business Critical +:
- Entorno completamente aislado
- Almacenamiento de metadatos dedicado
- Pool de compute dedicado
- Sin recursos compartidos con otras cuentas Snowflake

### TABLA DE REFERENCIA DE EDICIONES — Qué va dónde:

| Característica | Edición |
|---|---|
| Clustering | TODAS (automático) |
| Tablas dinámicas | TODAS |
| Snowpark | TODAS |
| UDFs + Stored Procs | TODAS |
| Políticas de red | TODAS |
| MFA, SSO, OAuth | TODAS |
| Time Travel 1 día | TODAS |
| Fail-safe (7 días) | TODAS (tablas permanentes) |
| Monitores de recursos | TODAS |
| Data Quality / DMFs | TODAS |
| Warehouses multi-cluster | Enterprise+ |
| Time Travel extendido (90 días) | Enterprise+ |
| Seguridad a nivel de columna (enmascaramiento) | Enterprise+ |
| Políticas de acceso a filas | Enterprise+ |
| Optimización de Búsqueda | Enterprise+ |
| Aceleración de Consultas | Enterprise+ |
| Vistas materializadas | Enterprise+ |
| Clasificación de datos | Enterprise+ |
| Historial de Acceso | Enterprise+ |
| Rekeying periódico | Enterprise+ |
| Tri-Secret Secure | Business Critical+ |
| Conectividad privada (PrivateLink) | Business Critical+ |
| Soporte PHI/HIPAA | Business Critical+ |
| Almacenamiento de metadatos dedicado | Solo VPS |

Exam trap: "Las políticas de enmascaramiento están disponibles en Standard" → INCORRECTO. SI VES "Standard" + "enmascaramiento" o "seguridad a nivel de columna" → INCORRECTO, el enmascaramiento requiere Enterprise+.
Exam trap: "Los warehouses multi-cluster funcionan en Standard" → INCORRECTO. SI VES "Standard" + "multi-cluster" → INCORRECTO, multi-cluster requiere Enterprise+. Standard = solo cluster único.
Exam trap: "Tri-Secret Secure es Enterprise" → INCORRECTO. SI VES "Enterprise" con "Tri-Secret" → INCORRECTO, Tri-Secret = Business Critical+. No confundir con rekeying periódico (Enterprise+).


### Ejemplos de Preguntas de Escenario — Editions

**Escenario:** A healthcare company needs to store PHI (Protected Health Information) in Snowflake and must comply with HIPAA. They're currently on Enterprise edition. Is this sufficient?
**Respuesta:** No. HIPAA/PHI compliance requires Business Critical edition or higher. Enterprise provides masking policies and row access policies for data protection, but the compliance certifications (HIPAA, HITRUST, PCI DSS) are only available starting at Business Critical.

**Escenario:** A startup wants to use dynamic masking policies to hide PII from junior analysts. They have Standard edition. Will this work?
**Respuesta:** No. Masking policies (column-level security) require Enterprise edition or higher. The startup needs to upgrade to Enterprise. Standard includes network policies, MFA, SSO, and RBAC, but NOT dynamic data masking.

**Escenario:** A company's data team wants to use multi-cluster warehouses to handle 200 concurrent dashboard users during peak hours. They have Standard edition. What do they need?
**Respuesta:** Upgrade to Enterprise edition. Multi-cluster warehouses (horizontal scaling) require Enterprise+. On Standard, they're limited to a single cluster per warehouse, which means queries will queue during high concurrency.

**Escenario:** Your security team demands that encryption keys be managed by your organization (customer-managed keys) so you can revoke access at any time. Which edition and feature do you need?
**Respuesta:** Business Critical edition with Tri-Secret Secure. This creates a composite master key using both a Snowflake-managed key and a customer-managed key (via AWS KMS, Azure Key Vault, or GCP Cloud KMS). If you revoke your key, data becomes inaccessible.

---

---

## 1.4 VIRTUAL WAREHOUSES (MUY IMPORTANTE EN EL EXAMEN)

### Qué son:
- Clusters de compute MPP independientes
- Necesarios para consultas Y DML (INSERT, UPDATE, DELETE, COPY INTO)
- NO necesarios para operaciones de metadatos (SHOW, DESCRIBE, algunas consultas COUNT)

### Tamaños (Gen1):
XS=1 crédito/hr → S=2 → M=4 → L=8 → XL=16 → 2XL=32 → 3XL=64 → 4XL=128 → 5XL=256 → 6XL=512

**Patrón**: cada tamaño SUPERIOR = doble de créditos = doble de compute

Exam trap: "Un warehouse Medium es 3x un XS" → INCORRECTO. SI VES "3x" o cualquier multiplicador que no es potencia de 2 → INCORRECTO, cada tamaño DOBLA (1→2→4→8→16). M = 4x XS.
Exam trap: "SHOW y DESCRIBE requieren warehouse en ejecución" → INCORRECTO. SI VES "warehouse necesario" para SHOW/DESCRIBE → INCORRECTO, las operaciones de metadatos no necesitan warehouse.

### Warehouses Gen2 (NUEVO para COF-C03):
- Generación más nueva de warehouses estándar
- Aún no es predeterminado, no disponible en todas las regiones
- Mismos nombres de tamaño pero consumo de créditos diferente
- Mejor rendimiento por crédito para muchas cargas de trabajo

### Warehouses Optimizados para Snowpark:
- Diseñados para cargas de trabajo Snowpark (Python, Java, Scala)
- Más memoria por nodo
- Usar para: entrenamiento ML, UDFs grandes, operaciones Snowpark intensivas en datos
- Costo de crédito mayor que warehouses estándar

Exam trap: "Los Warehouses Optimizados para Snowpark son más baratos" → INCORRECTO. SI VES "más barato" o "menor costo" con Snowpark-Optimized → INCORRECTO, cuestan MÁS créditos por la memoria extra.
Exam trap: "Todo código Snowpark necesita warehouses Snowpark-Optimized" → INCORRECTO. SI VES "requiere" o "necesita" Snowpark-Optimized → INCORRECTO, los warehouses estándar ejecutan Snowpark normalmente. Optimized = solo para ML pesado.

### Warehouse Predeterminado para Notebooks:
- SYSTEM$STREAMLIT_NOTEBOOK_WH (provisionado automáticamente)
- Multi-cluster XS, máximo 10 clusters, timeout de 60 segundos
- ACCOUNTADMIN es el propietario
- Mejor práctica: usar solo para cargas Python de notebook, usar warehouse separado para consultas SQL de notebooks

### Cobro:
- Cobro por segundo
- Mínimo de 60 segundos cada vez que el warehouse inicia
- Créditos consumidos solo mientras está en ejecución
- Warehouse suspendido = cero créditos

Exam trap: "El cobro es por minuto" → INCORRECTO. SI VES "por minuto" → INCORRECTO, es por SEGUNDO con mínimo de 60 segundos.
Exam trap: "Un warehouse suspendido todavía cuesta créditos" → INCORRECTO. SI VES "suspendido" + "créditos" o "costos" → INCORRECTO, suspendido = cero créditos. Solo en ejecución = cobrado.

### Auto-Suspend + Auto-Resume:
- Auto-suspend: el warehouse se suspende después de X segundos de inactividad (el valor predeterminado varía)
- Auto-resume: el warehouse inicia automáticamente cuando llega una consulta (habilitado por defecto)
- Ambos se aplican al warehouse ENTERO, no a clusters individuales

Exam trap: "Auto-suspend se aplica por cluster en multi-cluster" → INCORRECTO. SI VES "por cluster" con auto-suspend → INCORRECTO, auto-suspend se aplica al warehouse ENTERO.
Exam trap: "Auto-resume está deshabilitado por defecto" → INCORRECTO. SI VES "deshabilitado" + "auto-resume" → INCORRECTO, auto-resume está HABILITADO por defecto.

### Escalar VERTICALMENTE vs Escalar HORIZONTALMENTE:

| | Escalar VERTICALMENTE | Escalar HORIZONTALMENTE |
|---|---|---|
| Qué | Warehouse de tamaño mayor | Más clusters (multi-cluster) |
| Cuándo | Consultas complejas, spilling | Alta concurrencia, muchos usuarios |
| Cómo | ALTER WAREHOUSE SET SIZE | Definir MAX_CLUSTER_COUNT > 1 |
| Edición | TODAS | Enterprise+ |
| Resuelve | Consultas individuales lentas, spilling | Tiempos de espera en cola |

### Warehouses Multi-cluster (Enterprise+):
- Clusters mínimos = 1 a 10
- Clusters máximos = 1 a 10
- Si MIN = MAX → **Modo Maximizado** (siempre esa cantidad de clusters)
- Si MIN < MAX → **Modo Auto-scale**

### Políticas de Escalamiento (para auto-scale):
- **Standard**: inicia nuevo cluster inmediatamente cuando una consulta entra en cola. Apaga después de 2-3 minutos inactivo. Favorece rendimiento.
- **Economy**: inicia nuevo cluster solo si se estima que estará ocupado por 6+ minutos. Favorece ahorro de costos.

**Exam trap**: "Economy prioriza..." → Ahorro de créditos / throughput. SI VES "Economy" + "rendimiento" o "rápido" → INCORRECTO, Economy favorece ahorro de costos, no velocidad.
**Exam trap**: "Standard prioriza..." → Rendimiento / respuesta rápida. SI VES "Standard" + "ahorro de costos" → INCORRECTO, Standard favorece rendimiento, inicia clusters inmediatamente.

### Por qué importa + Casos de uso

**Por qué warehouses separados?** Porque la consulta pesada de un equipo no debería ralentizar a otro equipo. Los warehouses son INDEPENDIENTES — no comparten recursos.

**Escenario real — "Nuestro dashboard BI se vuelve lento durante cargas ETL"**
Una empresa ejecuta COPY INTO (carga) y consultas Tableau en el MISMO warehouse. Durante la carga, los usuarios del dashboard esperan en cola. Solución: warehouses separados — uno para carga (auto-suspend después de 1 min), uno para BI (siempre activo durante horario laboral).

**Escenario real — "Nuestro reporte mensual tarda 3 horas en XS"**
La consulta es compleja y derrama a disco remoto. Solución: escalar VERTICALMENTE a Large o XL para esa consulta específica. El reporte se ejecuta en 15 minutos. Luego reducir de vuelta. El cobro por segundo significa que solo pagas por esos 15 minutos.

**Escenario real — "50 analistas consultando a las 9am"**
Las consultas entran en cola porque solo hay 1 cluster. Solución: warehouse multi-cluster (Enterprise+) con política de escalamiento Standard. Nuevos clusters inician inmediatamente cuando las consultas entran en cola. A las 11am cuando el tráfico baja, los clusters se apagan automáticamente.

**La trampa de escalamiento que el examen adora:**
- "Derramamiento a disco" → Escalar VERTICALMENTE (warehouse más grande, más memoria)
- "Consultas en cola" → Escalar HORIZONTALMENTE (más clusters, multi-cluster)
- NUNCA al revés. El examen VA a intentar engañarte.

---

### Mejores Prácticas para Warehouses:
- Warehouses separados para cargas de trabajo diferentes (carga vs consulta vs BI)
- Warehouses separados para equipos diferentes
- Usar auto-suspend (ahorrar créditos)
- Escalar VERTICALMENTE para consultas complejas con spilling
- Escalar HORIZONTALMENTE para problemas de concurrencia
- Empezar pequeño, redimensionar según necesidad

Exam trap: "Un warehouse grande para todas las cargas es mejor práctica" → INCORRECTO. SI VES "warehouse único" o "un warehouse para todo" → INCORRECTO, mejor práctica = warehouses SEPARADOS por carga de trabajo.
Exam trap: "Redimensionar un warehouse afecta consultas en ejecución" → INCORRECTO. SI VES "consultas en ejecución" + "redimensionar" + "afectadas" → INCORRECTO, las consultas en ejecución usan el tamaño ANTERIOR. Solo las NUEVAS consultas usan el nuevo tamaño.


### Ejemplos de Preguntas de Escenario — Virtual Warehouses

**Escenario:** A Query Profile shows significant "Bytes spilled to remote storage" for a complex join query running on an XS warehouse. What should you do?
**Respuesta:** Scale UP vertically — increase the warehouse size to Medium or Large. Spilling to remote storage means the warehouse doesn't have enough local SSD memory, so data overflows to slower remote storage. A bigger warehouse = more memory = less spilling = faster query. Do NOT add more clusters (horizontal scaling) — that only helps with concurrency, not individual query performance.

**Escenario:** At 9 AM every Monday, 80 analysts run their weekly reports simultaneously. The warehouse queue shows 60+ queries waiting. The warehouse is XL. What should you do?
**Respuesta:** Enable multi-cluster warehouse (requires Enterprise+) with auto-scale mode. Set MIN_CLUSTER_COUNT=1, MAX_CLUSTER_COUNT=5, scaling policy=Standard. This starts new clusters immediately when queries queue. The XL size is fine for individual queries — the problem is concurrency, not query complexity.

**Escenario:** A warehouse was suspended for 4 hours. A user runs the same query they ran yesterday. The query takes much longer than yesterday. Why?
**Respuesta:** The warehouse's local SSD cache (warm cache) was cleared when the warehouse was suspended. Yesterday's query benefited from cached data. Today the query must re-read data from remote storage. Note: the result cache (in Cloud Services) may still have yesterday's result IF the underlying data hasn't changed — but if data changed, a full re-scan is needed.

**Escenario:** You have a multi-cluster warehouse with MIN=1, MAX=4 and Economy scaling policy. During a burst of 30 concurrent queries, users complain about wait times. What's happening?
**Respuesta:** Economy policy only starts a new cluster if the system estimates it will be busy for 6+ minutes. Short bursts may not trigger new clusters. Switch to Standard scaling policy, which starts new clusters immediately when queries queue. Standard favors performance; Economy favors cost savings.

**Escenario:** An admin creates a Snowpark-Optimized warehouse for a team that writes simple SELECT queries on small tables. Is this the right choice?
**Respuesta:** No. Snowpark-Optimized warehouses cost more credits because they have extra memory per node. They're designed for memory-intensive workloads like ML training, large UDFs, and heavy Snowpark DataFrame operations. For simple SELECT queries, a standard warehouse is more cost-effective.

---

---

## 1.5 MICRO-PARTICIONES Y CLUSTERING DE DATOS

### Micro-particiones:
- Snowflake automáticamente divide TODOS los datos de tabla en micro-particiones
- Tamaño: 50-500 MB sin comprimir (menor cuando comprimido)
- Almacenamiento columnar dentro de cada partición
- Inmutables (no pueden ser alteradas, solo reemplazadas)
- Los usuarios NO definen ni gestionan manualmente

### Qué metadatos se almacenan por micro-partición:
- Valores mínimo y máximo para cada columna
- Número de valores distintos
- Número de valores nulos
- Propiedades adicionales de optimización

**Exam trap**: "¿Qué metadatos se almacenan?" → Valores mín/máx, conteo de distintos, conteo de nulos. SI VES "historial de consultas" o "nombres de usuarios" como metadatos → INCORRECTO, solo se almacenan metadatos estadísticos.

### Pruning de Consultas:
- Snowflake usa metadatos de micro-partición para saltar particiones irrelevantes
- Solo escanea particiones donde los datos PUEDEN corresponder al filtro
- También poda a nivel de COLUMNA dentro de las particiones (columnar = solo escanea columnas necesarias)

**Exam trap**: "¿Qué impide el pruning efectivo?" → Usar funciones en columnas filtradas. SI VES "WHERE UPPER(col)" o "WHERE CAST(col...)" → trampa! Las funciones en las columnas anulan el pruning.

### Clustering de Datos:
- Los datos se agrupan naturalmente por el orden de inserción
- Profundidad de clustering = cuántas particiones se solapan para una columna
- Menor profundidad = mejor clustering = consultas más rápidas
- Disponible en TODAS las ediciones (clustering automático)
- Claves de Clustering = tú defines por qué columnas agrupar
- Clustering Automático = servicio en segundo plano mantiene el clustering (serverless, cuesta créditos)

### Profundidad de Clustering:
- SYSTEM$CLUSTERING_DEPTH(tabla, columnas) → verificar profundidad
- SYSTEM$CLUSTERING_INFORMATION(tabla, columnas) → información detallada de clustering
- Profundidad de 1 = perfectamente agrupado (sin solapamiento)

Exam trap: "Mayor profundidad de clustering = mejor" → INCORRECTO. SI VES "mayor" + "mejor" con profundidad de clustering → INCORRECTO, MENOR profundidad = mejor. Profundidad 1 = perfecto.

### Cuándo usar claves de clustering:
- Tablas muy grandes (multi-terabyte)
- Las consultas frecuentemente filtran por columnas específicas
- La profundidad de clustering es alta (mucho solapamiento)
- NO para tablas pequeñas (desperdicio de créditos)

Exam trap: "Todas las tablas se benefician de claves de clustering" → INCORRECTO. SI VES "todas las tablas" + "claves de clustering" → INCORRECTO, solo tablas muy grandes (multi-TB) se benefician. Tablas pequeñas = desperdicio de créditos.
Exam trap: "Clustering Automático requiere Enterprise" → INCORRECTO. SI VES "Enterprise" + "clustering" → INCORRECTO, clustering = TODAS las ediciones. No confundir con warehouses multi-cluster (Enterprise+).


### Ejemplos de Preguntas de Escenario — Micro-partitions & Clustering

**Escenario:** A 10TB orders table is frequently queried with `WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31'`. The query scans 95% of all micro-partitions despite the date filter. What's the problem and the fix?
**Respuesta:** The data has poor natural clustering on `order_date` — micro-partitions have overlapping date ranges so Snowflake can't effectively prune. Fix: define a clustering key on `order_date` with `ALTER TABLE orders CLUSTER BY (order_date)`. Automatic Clustering will reorganize data in the background. Verify improvement with `SYSTEM$CLUSTERING_DEPTH('orders', '(order_date)')` — the depth should decrease over time.

**Escenario:** A developer writes `WHERE UPPER(customer_name) = 'JOHN'` on a table with a clustering key on `customer_name`. The query is still slow. Why?
**Respuesta:** Wrapping a column in a function (like UPPER()) prevents micro-partition pruning. Snowflake stores min/max metadata for the raw column values, not for function results. Rewrite as `WHERE customer_name = 'John'` (if data is consistent) or use a case-insensitive collation. This is a common exam trap.

**Escenario:** A team adds clustering keys to every table in their schema, including a 50MB lookup table. Is this appropriate?
**Respuesta:** No. Clustering keys are only beneficial for very large tables (multi-TB). A 50MB table fits into a single micro-partition — there's nothing to prune. Adding clustering keys wastes credits on Automatic Clustering maintenance with zero query benefit.

**Escenario:** You run `SYSTEM$CLUSTERING_DEPTH('sales', '(region)')` and get a depth of 15. What does this tell you?
**Respuesta:** The clustering depth of 15 means there are many micro-partitions with overlapping `region` values — poor clustering. Ideally you want depth close to 1 (no overlap). If `region` is a frequent filter column, this table would benefit from a clustering key on `region`. After setting the key, Automatic Clustering will reduce depth over time.

---

---

## 1.6 TIPOS DE TABLA (MUY EVALUADO)

### Tablas Permanentes (por defecto):
- Time Travel completo (1 día Standard, hasta 90 días Enterprise+)
- Fail-safe de 7 días después de que Time Travel expire
- Mayor costo de almacenamiento (datos + Time Travel + Fail-safe)

### Tablas Transitorias:
- Time Travel: 0 o 1 día solamente (incluso en Enterprise+, máximo 1 día)
- SIN Fail-safe
- Persisten entre sesiones
- Visibles para otros usuarios/roles con acceso
- Menor costo de almacenamiento que las permanentes
- Buenas para: datos de staging, tablas intermedias de ETL

### Tablas Temporales:
- Time Travel: 0 o 1 día
- SIN Fail-safe
- Ámbito de sesión (eliminadas cuando la sesión termina)
- Visibles solo para la sesión que las creó
- Sesiones diferentes pueden tener tablas temp con el mismo nombre
- Si la sesión se desconecta (falla de red) → la tabla se elimina inmediatamente

**Exam trap**: "¿Tabla temporal + falla de red?" → La tabla se elimina inmediatamente. SI VES "persiste" o "recuperable" después de desconexión → INCORRECTO, tabla temp = perdida instantáneamente.
**Exam trap**: "¿Transitoria vs Temporal?" → Transitoria persiste entre sesiones, Temporal es solo de la sesión. SI VES "transitoria" + "ámbito de sesión" → INCORRECTO, eso es temporal.
**Exam trap**: "¿Se puede convertir Transitoria a Permanente?" → NO (debe recrearse). SI VES "ALTER" + "convertir" entre tipos de tabla → INCORRECTO, debe CREATE nueva + copiar datos.

### Tablas Externas:
- Solo lectura
- Los datos están en stage externo (S3, Azure Blob, GCS)
- Metadatos gestionados por Snowflake
- Pueden usarse con Directory Tables
- Sin Time Travel, sin Fail-safe
- Útiles para data lakes

Exam trap: "Las tablas externas soportan INSERT/UPDATE" → INCORRECTO. SI VES "INSERT", "UPDATE", o "DML" con tablas externas → INCORRECTO, las tablas externas son SOLO LECTURA.

### Tablas Dinámicas (NUEVO para COF-C03):
- Definidas por una consulta SQL (sentencia SELECT)
- Snowflake automáticamente mantiene los resultados actualizados
- Tú defines un "target lag" (meta de frescura)
- Puede ser refresh incremental o completo
- Disponibles en TODAS las ediciones
- Reemplazan pipelines complejos de Streams + Tasks para muchos casos
- Piensa como: "Quiero que esta tabla siempre refleje el resultado de esta consulta"

### Tablas Apache Iceberg (NUEVO para COF-C03):
- Formato de tabla abierto
- Datos almacenados EN TU almacenamiento externo (S3, Azure, GCS)
- Metadatos en formato Iceberg (no propietario de Snowflake)
- Tú gestionas el almacenamiento
- Pueden ser leídas por otros motores (Spark, Flink, etc.)
- Combina rendimiento de consulta de Snowflake con formato abierto
- Usar para data lakes / lakehouses

### Tablas Híbridas:
- Optimizadas para cargas de trabajo transaccionales de baja latencia
- Almacenamiento basado en FILAS (no columnar)
- Soportan bloqueo de fila, restricciones de integridad referencial y unicidad
- Usar para Unistore (transaccional + analítico juntos)
- Disponibles en TODAS las ediciones

### Resumen de Tipos de Tabla:

| Tipo | Time Travel | Fail-safe | Ámbito | Persiste |
|---|---|---|---|---|
| Permanente | 1 día (90 Enterprise+) | 7 días | Cuenta | Sí |
| Transitoria | 0-1 día máx | NINGUNO | Cuenta | Sí |
| Temporal | 0-1 día máx | NINGUNO | Solo sesión | No |
| Externa | NINGUNO | NINGUNO | Cuenta | Sí (solo lectura) |
| Dinámica | Depende del tipo subyacente | Depende | Cuenta | Sí |
| Iceberg | Limitado | NINGUNO | Cuenta | Sí |
| Híbrida | Limitado | Limitado | Cuenta | Sí |

---

### Mejores Prácticas — Cuándo Usar Cada Tipo de Tabla
- **Permanente**: Datos de producción, datos de cumplimiento/auditoría, cualquier cosa que necesite recuperación de desastres
- **Transitoria**: Tablas de staging/ETL, agregaciones derivadas que pueden recrearse. Ahorra ~25-30% de almacenamiento vs permanente (sin Fail-safe)
- **Temporal**: Trabajo solo de sesión — consultas exploratorias, cálculos intermedios. Auto-eliminada cuando la sesión termina (NO al desconectar — las sesiones persisten durante caídas de red)
- **Externa**: Consultas de data lake donde los datos están en S3/Azure/GCS. Solo lectura
- **Dinámica**: Reemplaza pipelines de Streams+Tasks. Define target lag
- **Iceberg**: Formato abierto, TU almacenamiento. Usar cuando múltiples motores necesitan leer los mismos datos
- **Híbrida**: Cargas transaccionales de baja latencia (OLTP). NO para analytics
- NUNCA uses tablas permanentes para staging — desperdicio (Fail-safe cuesta dinero para datos que puedes recrear)


### Ejemplos de Preguntas de Escenario — Table Types

**Escenario:** Your ETL pipeline creates a staging table every morning, loads CSV files from S3, transforms data, and inserts into production tables. The staging data is deleted after each run. Currently using permanent tables for staging, and storage costs are high. What table type should you use for staging?
**Respuesta:** Transient tables. Staging data can be recreated (just re-run the pipeline), so there's no need for Fail-safe. Switching from permanent to transient saves ~25-30% on storage costs. Do NOT use temporary — you want the table to persist across sessions in case the pipeline spans multiple sessions.

**Escenario:** A data analyst creates a temporary table during an interactive session to hold intermediate results of a complex analysis. Their VPN drops and the session disconnects. What happens to the data?
**Respuesta:** The temporary table is immediately dropped — all data is lost. Temporary tables are session-scoped and cannot survive disconnection. If the work is important and takes time, use a transient table instead (persists across sessions, still no Fail-safe cost).

**Escenario:** Your company wants both Snowflake and Apache Spark to read the same dataset stored in S3. They don't want to maintain two copies. Which table type should they use?
**Respuesta:** Apache Iceberg tables. Iceberg is an open table format stored in the customer's own storage (S3/Azure/GCS). Both Snowflake and Spark can read/write Iceberg format natively. The data stays in one place with one format — no duplication.

**Escenario:** A team wants a summary table that always reflects the latest aggregated sales data with no more than 1 hour delay. They currently use a complex Streams + Tasks pipeline that occasionally fails. What's a simpler approach?
**Respuesta:** Create a Dynamic Table with `TARGET_LAG = '1 hour'`. Define the table as a SELECT query with the aggregation logic. Snowflake automatically refreshes it (incrementally when possible). No Streams, no Tasks, no pipeline code to maintain.

**Escenario:** An admin tries to run `ALTER TABLE staging_transient SET DATA_RETENTION_TIME_IN_DAYS = 45` on a transient table (Enterprise edition). Will this work?
**Respuesta:** No. Transient tables have a maximum Time Travel retention of 1 day, even on Enterprise edition (which allows up to 90 days for permanent tables). The ALTER will fail. If you need 45-day Time Travel, you must use a permanent table.

---

---

## 1.7 TIPOS DE VIEW

### View Estándar:
- Consulta SQL almacenada (sin datos almacenados)
- Re-ejecuta la consulta cada vez que se accede
- Se puede ver la definición SQL subyacente

### View Materializada (Enterprise+):
- Almacena resultados de consulta físicamente
- Auto-actualizada por servicio en segundo plano (cuesta créditos)
- Lecturas más rápidas (pre-computada)
- No puede usar todas las características SQL (limitada a tabla única)
- Mejor para: consultas costosas sobre datos que no cambian frecuentemente

### View Segura:
- Oculta la definición de la view a no-propietarios
- El optimizador de consultas puede ser limitado (no puede ver definición para optimizar)
- Usar para: compartición de datos (requerida para shares), proteger lógica de negocio
- Puede ser segura estándar o materializada segura

**Exam trap**: "¿Qué tipo de view se requiere para compartición de datos?" → View Segura. SI VES "view estándar" o "view materializada" como requerida para compartición → INCORRECTO, solo views SEGURAS funcionan en shares.


### Ejemplos de Preguntas de Escenario — View Types

**Escenario:** A company wants to share a curated dataset with an external Snowflake account via Secure Data Sharing. They have a standard view that joins 3 tables and applies business logic. Can they share this view directly?
**Respuesta:** No. Data sharing requires SECURE views. The admin must recreate the view as `CREATE SECURE VIEW ...`. Secure views hide the view definition from consumers, which is required for shares. Standard views expose their SQL definition, which is not allowed in sharing.

**Escenario:** A BI team runs the same expensive aggregation query every 15 minutes on a 2TB table that only changes once per day. The query takes 3 minutes each time. What view type would help?
**Respuesta:** A Materialized View (Enterprise+). It pre-computes and stores the results physically. Since the underlying data changes only once per day, the materialized view auto-refreshes once (cheap). The 15-minute queries become instant reads. The tradeoff: materialized views cost credits for background maintenance, and they're limited to single-table queries.

**Escenario:** A developer creates a secure view and notices that queries against it are slower than the same query run directly on the base table. Why?
**Respuesta:** Secure views limit the query optimizer's ability to optimize because the view definition is hidden. The optimizer can't push predicates through the view boundary as aggressively. This is the security-performance tradeoff of secure views. Only use secure views when security requires it (sharing, protecting business logic).

---

---

## 1.8 JERARQUÍA DE OBJETOS

```
Organización
  └── Cuenta(s)
        └── Base(s) de Datos
              └── Schema(s)
                    ├── Tablas
                    ├── Views
                    ├── Stages
                    ├── Formatos de Archivo
                    ├── Secuencias
                    ├── Pipes
                    ├── Streams
                    ├── Tasks
                    ├── UDFs
                    ├── Stored Procedures
                    ├── Modelos ML
                    └── Aplicaciones (Native Apps)
```

### Nombre Completamente Calificado: `base_de_datos.schema.objeto`
### Namespace: base_de_datos.schema

### Jerarquía de Parámetros (precedencia):
- Cuenta → definido por ACCOUNTADMIN
- Usuario → sobrescribe cuenta para ese usuario
- Sesión → sobrescribe usuario para esa sesión
- Objeto → depende del parámetro

**Clave**: Las configuraciones más específicas sobrescriben a las menos específicas.

Exam trap: "El nivel de cuenta sobrescribe el nivel de sesión" → INCORRECTO. SI VES "cuenta sobrescribe sesión" → INCORRECTO, sesión sobrescribe cuenta. Más específico gana (Objeto > Sesión > Usuario > Cuenta).


### Ejemplos de Preguntas de Escenario — Object Hierarchy

**Escenario:** A new analyst runs `SELECT * FROM customers` and gets "Object does not exist" even though the table exists. Other team members can query it fine. What's likely wrong?
**Respuesta:** The analyst's session context is set to a different database or schema. They need to either use the fully qualified name `database.schema.customers` or set the correct context with `USE DATABASE mydb; USE SCHEMA myschema;`. Check with `SELECT CURRENT_DATABASE(), CURRENT_SCHEMA()`.

**Escenario:** An admin sets `STATEMENT_TIMEOUT_IN_SECONDS = 3600` at the account level. A specific user needs longer timeouts for their ETL jobs. Can this be overridden?
**Respuesta:** Yes. Set the parameter at the user level: `ALTER USER etl_user SET STATEMENT_TIMEOUT_IN_SECONDS = 7200`. More specific settings override less specific ones: Object > Session > User > Account. The ETL user gets 7200s while all other users keep 3600s.

**Escenario:** A developer asks: "Are stages account-level objects like warehouses?" How do you answer?
**Respuesta:** No. Stages are schema-level objects — they live inside `database.schema`. Warehouses and roles are account-level objects (they exist outside any database). This distinction matters for RBAC — granting access to a stage requires schema-level privileges.

---

---

## 1.9 INTERFACES Y HERRAMIENTAS

### Snowsight:
- UI basada en web
- Escribir + ejecutar SQL
- Dashboards + visualizaciones
- Gestionar warehouses, bases de datos, usuarios

### Snowflake CLI (snow):
- Herramienta de línea de comandos
- Gestionar objetos Snowflake desde el terminal
- Ejecutar SQL
- Deploy de aplicaciones Snowpark, apps Streamlit, Native Apps

### SnowSQL:
- Cliente de línea de comandos
- Ejecutar SQL
- PUT/GET archivos (única forma de upload/download desde local)

### Integración Git (NUEVO para COF-C03):
- Conectar repositorios Git a Snowflake
- Almacenar UDFs, procedures, apps Streamlit en Git
- Control de versiones para código Snowflake
- Objeto CREATE GIT REPOSITORY

### VS Code Extension para Snowflake:
- Extensión oficial de Snowflake para Visual Studio Code
- Ejecutar consultas SQL directamente desde VS Code
- Auto-completado y resaltado de sintaxis para Snowflake SQL
- Explorador de objetos de base de datos integrado
- Soporte para Snowpark Python con depuración local
- Gestión de conexiones Snowflake

Exam trap: "Snowsight soporta comandos PUT/GET" → INCORRECTO. SI VES "Snowsight" + "PUT" o "GET" → INCORRECTO, solo SnowSQL (CLI) y conectores soportan PUT/GET.


### Ejemplos de Preguntas de Escenario — Interfaces & Tools

**Escenario:** A developer needs to upload a 2GB CSV file from their local laptop to a Snowflake internal stage. They try using Snowsight but can't find an upload option for files this large. What tool should they use?
**Respuesta:** Use SnowSQL (the CLI client) with the PUT command: `PUT file:///path/to/file.csv @my_stage`. Snowsight has a file upload limit and doesn't support the PUT/GET commands. For programmatic uploads, you can also use Snowflake connectors (Python, JDBC, etc.).

**Escenario:** A team wants to version-control their Snowflake UDFs and stored procedures in GitHub, and deploy changes automatically. How can they integrate Git with Snowflake?
**Respuesta:** Use Git Integration (NEW in COF-C03): `CREATE GIT REPOSITORY` to connect your GitHub repo to Snowflake. The code stays in Git (not stored in Snowflake storage). You can then reference Git-stored files when creating UDFs, procedures, or Streamlit apps. For CI/CD, use the Snowflake CLI (`snow`) to deploy from Git.

**Escenario:** An admin wants to explore query performance issues using the VS Code extension for Snowflake. Can they view Query Profiles from VS Code?
**Respuesta:** The VS Code extension lets you connect to Snowflake, run SQL, and browse objects. For detailed Query Profile analysis (execution plan, operator statistics, spilling details), use Snowsight — it provides the visual Query Profile with the full performance breakdown.

---

---

## 1.10 AI/ML Y DESARROLLO DE APPS (NUEVO para COF-C03)

### Snowflake Notebooks:
- Entorno de codificación interactivo dentro de Snowflake
- Soporta celdas Python + SQL
- Usar para exploración de datos, ML, análisis

### Streamlit en Snowflake:
- Construye apps de datos directamente en Snowflake
- Basado en Python (framework Streamlit)
- Los datos se quedan en Snowflake (sin movimiento de datos)
- Gobernado por la seguridad de Snowflake (RBAC)

### Snowpark:
- Escribe código en Python, Java, Scala
- API DataFrame que traduce a SQL
- El código ejecuta DENTRO del warehouse (no en tu laptop)
- "Evaluación perezosa" = nada ejecuta hasta que llamas una acción (collect, show, write)
- Disponible en TODAS las ediciones

**Exam trap**: "¿Dónde ejecuta el código Snowpark?" → Dentro del Virtual Warehouse. SI VES "lado del cliente", "máquina local", o "Cloud Services" → INCORRECTO, Snowpark ejecuta DENTRO del warehouse.
**Exam trap**: "¿Qué es evaluación perezosa?" → La consulta solo ejecuta cuando se llama una acción. SI VES "ejecución inmediata" o "ejecuta en la definición" → INCORRECTO, nada ejecuta hasta .collect()/.show().

### Snowflake Cortex (Funciones AI):
- AI_COMPLETE → generación de texto (inferencia LLM)
- AI_SENTIMENT → análisis de sentimiento
- AI_SUMMARIZE → resumen de texto
- AI_TRANSLATE → traducción de idiomas
- AI_EXTRACT → extracción de entidades
- AI_CLASSIFY → clasificación de texto
- AI_EMBED → generar embeddings
- Ejecuta dentro de Snowflake, los datos se quedan en Snowflake

### Cortex Search:
- Búsqueda semántica sobre datos de texto

### Cortex Analyst:
- Lenguaje natural a SQL
- Haz preguntas sobre tus datos en español simple
- Usa vistas semánticas / modelos semánticos

### Snowflake ML:
- Funciones ML: predicción, detección de anomalías, clasificación integrados
- Model Registry: almacenar y versionar modelos ML
- Feature Store: gestionar features de ML

Exam trap: "Cortex Analyst hace búsqueda semántica" → INCORRECTO. Analyst = lenguaje natural a SQL. Search = búsqueda semántica. Son diferentes.


### Ejemplos de Preguntas de Escenario — AI/ML and App Development

**Escenario:** A data scientist wants to build a quick dashboard to let business users explore sales data interactively. They want the app to run inside Snowflake without moving data to an external server. What should they use?
**Respuesta:** Use Streamlit in Snowflake. It allows you to build interactive Python-based data apps directly inside Snowflake. Data never leaves Snowflake, and the app is governed by Snowflake RBAC. No external hosting needed.

**Escenario:** A team has a Python ML pipeline that processes large DataFrames. They currently run it on a local server, but want to run it inside Snowflake for better scalability. What technology should they use, and where does the code execute?
**Respuesta:** Use Snowpark with a Snowpark-optimized warehouse. The Snowpark DataFrame API translates Python operations to SQL. Code executes INSIDE the virtual warehouse (not on the client machine). For memory-intensive ML workloads, use Snowpark-optimized warehouses which provide more memory per node.

**Escenario:** A company wants to add sentiment analysis to their customer feedback table without exporting data to an external ML platform. Which Cortex function should they use?
**Respuesta:** Use `AI_SENTIMENT()` — e.g., `SELECT AI_SENTIMENT(feedback_text) FROM customer_feedback`. This runs inside Snowflake, no data export needed. Do NOT confuse with AI_COMPLETE (which is for text generation/LLM inference) or AI_CLASSIFY (which is for text classification into categories).

**Escenario:** A business analyst wants to ask questions about their data in plain English and get SQL results back. They heard about Cortex Search and Cortex Analyst but aren't sure which to use. What's the difference?
**Respuesta:** Cortex Analyst converts natural language to SQL queries — it's for asking questions about structured data (e.g., "What were total sales last quarter?"). Cortex Search performs semantic search over text data — it's for finding relevant documents or text passages. The analyst wants Cortex Analyst (natural language → SQL), not Cortex Search.

**Escenario:** A developer is using Snowflake Notebooks and notices the notebook runs on a warehouse called SYSTEM$STREAMLIT_NOTEBOOK_WH. Can they change this?
**Respuesta:** Snowflake Notebooks run on dedicated notebook warehouses. While they use SYSTEM$STREAMLIT_NOTEBOOK_WH by default, you can configure the warehouse. Notebooks support both Python and SQL cells, and have access to Snowpark and ML libraries for data exploration and analysis.

---

---

## 1.11 CLONACIÓN (Clone Zero-Copy)

- CREATE ... CLONE crea una copia solo de metadatos
- Sin almacenamiento adicional hasta que los datos sean modificados
- Funciona en: bases de datos, schemas, tablas
- El clone hereda datos en el punto en el tiempo de la clonación
- El clone NO hereda historial de Time Travel del original
- Cambios en el clone NO afectan al original (y viceversa)


### Ejemplos de Preguntas de Escenario — Cloning

**Escenario:** A team needs to create a copy of a production database for testing. They're concerned about storage costs since the database is 5TB. How much additional storage will the clone use initially?
**Respuesta:** Zero additional storage initially. `CREATE DATABASE test_db CLONE prod_db` creates a zero-copy clone — it's metadata-only. Both the original and clone point to the same micro-partitions. You only pay for additional storage when data in the clone is modified (and only for the changed micro-partitions, not the entire table).

**Escenario:** After cloning a table, a developer checks Time Travel on the clone and expects to see the original table's history. They can't find it. Why?
**Respuesta:** Clones do NOT inherit Time Travel history from the original. The clone starts with only the data as it existed at the point of cloning. Time Travel on the clone begins fresh from the moment of creation. This is a common exam trap — "inherits Time Travel" is always wrong for clones.

**Escenario:** A developer clones a schema containing 10 tables. They then INSERT new rows into 3 of the cloned tables. How much additional storage is used?
**Respuesta:** Only the new/modified micro-partitions in those 3 tables consume additional storage. The other 7 unchanged tables still share micro-partitions with the original (zero extra storage). Even for the 3 modified tables, only the affected micro-partitions are new — unchanged partitions are still shared.

**Escenario:** Can you clone a view in Snowflake?
**Respuesta:** You cannot directly clone individual views. However, when you clone a database or schema, the views within it are included in the clone. The cloned views will reference the cloned tables (within the cloned schema/database), not the original tables. Cloning works on: databases, schemas, and tables.

---

---

## 1.12 DATOS SEMI-ESTRUCTURADOS

### Formatos soportados: JSON, Avro, ORC, Parquet, XML

### Tipo de dato VARIANT:
- Almacena datos semi-estructurados
- Puede contener cualquier tipo (objeto, array, escalar)
- Tamaño máximo: 16 MB por valor (comprimido)

### Funciones Clave:
- **PARSE_JSON()** → convertir string JSON a VARIANT
- **FLATTEN()** → expandir arrays/objetos en filas
- **OBJECT_KEYS()** → obtener todas las claves de un objeto JSON
- **TYPEOF()** → obtener el tipo de dato de un valor VARIANT
- **::tipo** notación → convertir VARIANT a tipo específico (ej: col:nombre::string)
- **Notación de punto**: `columna:clave.subclave` para navegar JSON

### Sub-columnarización:
- La capa de Cloud Services automáticamente analiza columnas VARIANT
- Extrae rutas frecuentemente accedidas para almacenamiento columnar optimizado
- Ocurre automáticamente, sin acción del usuario necesaria

**Exam trap**: "¿Qué servicio sub-columnariza VARIANT?" → Capa de Cloud Services. SI VES "Compute" o "Storage" haciendo sub-columnarización → INCORRECTO, Cloud Services analiza y optimiza columnas VARIANT.


### Ejemplos de Preguntas de Escenario — Semi-structured Data

**Escenario:** A company receives JSON data from an API where each record contains a nested array of order items. They need to create one row per order item for analysis. Which function should they use?
**Respuesta:** Use `FLATTEN()` to expand the nested array into individual rows. Example: `SELECT o.value:product_name::string AS product, o.value:quantity::number AS qty FROM orders, LATERAL FLATTEN(input => order_data:items) o`. FLATTEN explodes arrays/objects into rows — it's the opposite of aggregation.

**Escenario:** A data engineer loads JSON data into a VARIANT column. Queries on this column are slow. They haven't done anything special — does Snowflake optimize VARIANT data automatically?
**Respuesta:** Yes. The Cloud Services layer automatically performs sub-columnarization on VARIANT columns. It analyzes access patterns and extracts frequently-queried paths into optimized internal columnar storage. This happens automatically with no user action required. The key exam point: sub-columnarization is done by Cloud Services (not Compute, not Storage).

**Escenario:** A developer needs to access a deeply nested JSON field: `{"customer": {"address": {"city": "NYC"}}}`. The data is stored in a VARIANT column called `data`. How do they extract the city?
**Respuesta:** Use dot notation with casting: `SELECT data:customer.address.city::string AS city FROM my_table`. The colon (`:`) accesses the first level, dots (`.`) navigate deeper levels, and `::string` casts the VARIANT value to a string type. You can also use bracket notation: `data['customer']['address']['city']::string`.

**Escenario:** A team needs to load Parquet files into Snowflake. Should they convert Parquet to CSV first, or can Snowflake handle Parquet natively?
**Respuesta:** Snowflake handles Parquet natively — no conversion needed. Snowflake supports JSON, Avro, ORC, Parquet, and XML as semi-structured formats. You can load Parquet directly using COPY INTO with `TYPE = PARQUET` in the file format. Snowflake can also auto-detect the schema from Parquet files using `INFER_SCHEMA()`.

---

---

## REPASO RÁPIDO (patrones más evaluados)

1. Tres capas: Cloud Services (cerebro), Compute (músculo), Storage (memoria)
2. Cloud Services se encarga de: auth, optimizador, transacciones, metadatos
3. Warehouses cobrados por segundo, mínimo 60s
4. Cada tamaño superior = 2x créditos
5. Escalar VERTICALMENTE = tamaño mayor (consultas complejas). Escalar HORIZONTALMENTE = más clusters (concurrencia)
6. Multi-cluster = solo Enterprise+
7. Escalamiento Standard = inicia clusters rápido. Economy = ahorra créditos.
8. Micro-particiones: 50-500 MB, columnares, inmutables, automáticas
9. Pruning usa metadatos mín/máx. Funciones en columnas impiden pruning.
10. Tabla temporal = solo sesión, eliminada cuando la sesión termina (NO al desconectar)
11. Transitoria = sin Fail-safe, persiste entre sesiones
12. Permanente = Time Travel + Fail-safe
13. No es posible convertir entre tipos de tabla (debe recrearse)
14. Clone = zero-copy, sin costo de almacenamiento hasta modificación
15. VARIANT = contenedor semi-estructurado
16. PARSE_JSON + FLATTEN = funciones más evaluadas
17. Snowpark = evaluación perezosa, ejecuta DENTRO del warehouse
18. Tablas dinámicas = refresh automático, target lag
19. Iceberg = formato abierto, TU almacenamiento, interoperable
20. Todas las ediciones tienen: clustering, Snowpark, UDFs, tablas dinámicas, políticas de red
21. Enterprise+: multi-cluster, enmascaramiento, acceso a filas, optim. búsqueda, acel. consultas, TT 90 días
22. Business Critical+: Tri-Secret, PrivateLink, HIPAA
23. VPS: todo dedicado, totalmente aislado

---

## PARES CONFUSOS — Arquitectura

| Preguntan sobre... | La respuesta es... | NO es... |
|---|---|---|
| Optimización de consultas | Capa Cloud Services | Capa Compute |
| Cumplimiento ACID | Capa Cloud Services | Capa Storage |
| Dónde viven los datos físicamente | Capa Storage | Cloud Services |
| Dónde ejecutan las consultas | Capa Compute | Cloud Services |
| Cobro de créditos | Por segundo, mín 60s | Por minuto |
| Tamaño de micro-partición | 50-500 MB sin comprimir | 50-500 MB comprimido |
| Micro-particiones gestionadas por | Snowflake (automático) | Usuarios (manual) |
| Clustering disponible en | TODAS las ediciones | Enterprise+ |
| Multi-cluster disponible en | Enterprise+ | TODAS las ediciones |
| Sesión de tabla temp termina | Tabla es ELIMINADA | Tabla persiste |
| Fail-safe de tabla transitoria | NINGUNO | 7 días |
| Snowpark ejecuta código | Dentro del warehouse | En tu máquina local |
| Frescura de tabla dinámica | Target lag (tú defines) | Siempre tiempo real |
| Cuenta abarca proveedores | NO (un proveedor por cuenta) | Sí |

---

## RESUMEN AMIGABLE — Dominio 1

### MNEMÓNICOS PARA FIJAR

**Capas = C-M-M** (Cerebro, Músculo, Memoria)
- Cerebro = Cloud Services (piensa, optimiza, protege)
- Músculo = Compute (hace el trabajo pesado)
- Memoria = Storage (recuerda los datos)

**Tamaños de warehouse doblan = "Dobla Siempre"**
- XS=1, S=2, M=4, L=8, XL=16... cada paso SUPERIOR = 2x créditos

**Tipos de tabla = "PeTT-y EDI"** (Permanente, Transitoria, Temporal, Externa, Dinámica, Iceberg)
- **Pe**rmanente = protección total (TT + Fail-safe)
- **T**ransitoria = sin red de seguridad (sin Fail-safe)
- **T**emporal = sin red de seguridad Y solo sesión

**Regla de edición = "Seguridad SUBE, Recursos SUBEN"**
- Standard = básico (funciona bien para la mayoría)
- Enterprise = controla quién ve qué (enmascaramiento, acceso a filas) + rendimiento
- BC = encriptación + privacidad (Tri-Secret, PrivateLink, HIPAA)
- VPS = aislamiento total

**Truco de memoria para escalamiento = "VERTICAL para Potencia, HORIZONTAL para Personas"**
- VERTICAL = más potencia para una consulta grande
- HORIZONTAL = más espacio para muchas personas consultando

---

### TRAMPAS PRINCIPALES — Dominio 1

1. **"Clustering requiere Enterprise"** → INCORRECTO. TODAS las ediciones.
2. **"Snowpark requiere Enterprise"** → INCORRECTO. TODAS las ediciones.
3. **"Las micro-particiones son 50-500 MB comprimidas"** → INCORRECTO. Es tamaño SIN COMPRIMIR.
4. **"Los usuarios definen micro-particiones"** → INCORRECTO. Automático, siempre.
5. **"La suspensión del warehouse mantiene el caché"** → INCORRECTO. El caché SSD se PIERDE al suspender.
6. **"Las tablas temporales no tienen Time Travel"** → INCORRECTO. Hasta 1 día.
7. **"Puedes ALTER una tabla transitoria a permanente"** → INCORRECTO. Debe recrearse.
8. **"Snowpark ejecuta en tu máquina local"** → INCORRECTO. Ejecuta dentro del warehouse.
9. **"Las tablas dinámicas necesitan refresh manual"** → INCORRECTO. Automático basado en target lag.
10. **"Una cuenta Snowflake abarca AWS + Azure"** → INCORRECTO. Una cuenta = un proveedor de nube.

---

### ATAJOS DE PATRÓN — "Si ves ___, la respuesta es ___"

| Si la pregunta menciona... | La respuesta casi siempre es... |
|---|---|
| "optimización de consultas", "parsing de consultas" | Capa Cloud Services |
| "gestión de transacciones", "ACID" | Capa Cloud Services |
| "derramamiento a disco local/remoto" | Aumentar TAMAÑO del warehouse |
| "consultas en cola", "concurrencia" | Multi-cluster / escalar HORIZONTALMENTE |
| "política de escalamiento Economy" | Ahorra créditos, espera 6 min |
| "política de escalamiento Standard" | Rendimiento, inicia inmediatamente |
| "MIN = MAX clusters" | Modo Maximizado |
| "sin Fail-safe pero persiste" | Tabla transitoria |
| "sesión termina = perdido" | Tabla temporal |
| "formato abierto, almacenamiento externo" | Tabla Iceberg |
| "target lag", "pipeline de refresh automático" | Tabla dinámica |
| "evaluación perezosa" | Snowpark |
| "API DataFrame" | Snowpark |
| "AI_COMPLETE, AI_SENTIMENT" | Funciones Cortex AI |
| "lenguaje natural a SQL" | Cortex Analyst |
| "búsqueda semántica" | Cortex Search |
| "Python + SQL interactivo" | Snowflake Notebooks |
| "app de datos dentro de Snowflake" | Streamlit en Snowflake |
| "control de versiones en Snowflake" | Integración Git (CREATE GIT REPOSITORY) |

---

## CONSEJOS PARA EL DÍA DEL EXAMEN — Dominio 1 (31% = ~31 preguntas)

**Antes de estudiar este dominio:**
- Haz 10-15 flashcards SOLO para los conceptos que confundes (capas, tipos de tabla, ediciones)
- Prueba "Explica para un niño de 5 años": si no puedes explicar Cloud Services vs Compute en una frase, estudia más

**Durante el examen — Preguntas del Dominio 1:**
- Lee la ÚLTIMA frase primero (la pregunta real) — luego lee el escenario
- Elimina 2 respuestas obviamente incorrectas inmediatamente
- Si mencionan una CAPA → pregúntate: pensar/decidir = Cloud Services, hacer trabajo = Compute, almacenar = Storage
- Si mencionan ESCALAMIENTO → "VERTICAL para Potencia, HORIZONTAL para Personas"
- Si mencionan un TIPO DE TABLA → verifica: ¿persiste? ¿tiene Fail-safe?
- Si mencionan una EDICIÓN → piensa "Seguridad SUBE, Recursos SUBEN"

---

## UNA LÍNEA POR TEMA — Dominio 1

| Tema | Resumen en una línea |
|---|---|
| Arquitectura 3 capas | Cloud Services (cerebro), Compute (músculo), Storage (memoria) — totalmente independientes |
| Cloud Services | Piensa: optimización de consultas, seguridad, metadatos, gestión de transacciones |
| Compute | Hace: ejecuta consultas en warehouses, cada warehouse = cluster independiente de nodos |
| Storage | Recuerda: todos los datos en micro-particiones, columnar, comprimido, inmutable |
| Ediciones | Standard→Enterprise (enmascaramiento, multi-cluster)→BC (Tri-Secret, PrivateLink)→VPS (aislamiento total) |
| Virtual Warehouses | Tamaño camiseta (XS=1 crédito/hr, dobla en cada tamaño), auto-suspend, auto-resume |
| Multi-cluster | Escalar HORIZONTALMENTE para concurrencia, Enterprise+, política Standard o Economy |
| Micro-particiones | 50-500MB sin comprimir, columnar, inmutable, automático — tú nunca gestionas |
| Tablas permanentes | Protección total: Time Travel (1-90 días) + Fail-safe (7 días) |
| Tablas transitorias | Sin Fail-safe, máx 1 día TT, persiste entre sesiones |
| Tablas temporales | Sin Fail-safe, máx 1 día TT, perdida cuando la sesión termina |
| Tablas externas | Solo lectura, datos en almacenamiento de nube del cliente, metadatos en Snowflake |
| Tablas dinámicas | Pipeline declarativo: SQL + target lag = resultados auto-actualizados |
| Tablas Iceberg | Formato Apache Iceberg abierto, datos en almacenamiento del cliente, interoperable |
| Tablas híbridas | Baja latencia clave-valor + ACID, para cargas operacionales |
| Views | Estándar (expone SQL), Segura (oculta SQL, requerida para sharing), Materializada (pre-computada, Enterprise+) |
| Snowpark | API DataFrame (Python/Java/Scala), evaluación perezosa, ejecuta dentro del warehouse |
| Cortex AI | AI_COMPLETE, AI_SENTIMENT, AI_EXTRACT — funciones LLM integradas |
| Clonación | Zero-copy, instantáneo, independiente después de creación, sin historial TT de la fuente |

---

## FLASHCARDS — Dominio 1

**P:** ¿Cuáles son las 3 capas de Snowflake y qué hace cada una?
**R:** Cloud Services (cerebro — auth, optimizador, metadatos, transacciones), Compute (músculo — virtual warehouses ejecutan consultas), Storage (memoria — almacenamiento centralizado en la nube, micro-particiones columnares). Todas escalan independientemente.

**P:** ¿Qué capa se encarga de la optimización de consultas?
**R:** Capa Cloud Services — NO Compute. Trampa común del examen.

**P:** ¿Una cuenta Snowflake puede abarcar múltiples proveedores de nube?
**R:** No. Una cuenta = un proveedor de nube + una región. Usa Organizations para vincular cuentas entre proveedores/regiones.

**P:** ¿Qué agrega la Enterprise Edition sobre Standard?
**R:** Warehouses multi-cluster, Time Travel hasta 90 días, seguridad a nivel de columna, políticas de acceso a filas, vistas materializadas, optimización de búsqueda, aceleración de consultas, enmascaramiento dinámico, rekeying periódico.

**P:** ¿Cuál es el modelo de cobro de warehouses?
**R:** Cobro por segundo con mínimo de 60 segundos. Los créditos dependen del tamaño (XS=1, S=2, M=4, L=8... cada tamaño dobla).

**P:** Escalar VERTICALMENTE vs HORIZONTALMENTE — ¿cuándo usar cada uno?
**R:** VERTICALMENTE (warehouse más grande) = consultas complejas, spilling. HORIZONTALMENTE (multi-cluster) = más usuarios concurrentes, cola.

**P:** ¿Qué son las micro-particiones?
**R:** Columnares, comprimidas, inmutables, 50-500MB. Creadas automáticamente — NO puedes controlar su tamaño o número.

**P:** Transitoria vs Temporal — ¿cuál es la diferencia?
**R:** Ambas: 0-1 día Time Travel, SIN Fail-safe. Transitoria persiste entre sesiones. Temporal existe solo en la sesión actual y es invisible para otras sesiones.

**P:** ¿Qué es una Tabla Dinámica?
**R:** Una tabla que automáticamente se actualiza basada en una consulta y un target lag. Pipeline declarativo — sin tasks/streams necesarios.

**P:** ¿Qué es Snowpark?
**R:** Framework para escribir pipelines en Python, Java o Scala usando API DataFrame. Ejecuta en la CAPA DE COMPUTE (no Cloud Services).

**P:** ¿Qué hace el tipo VARIANT?
**R:** Almacena datos semi-estructurados (JSON, Avro, Parquet, XML). Máximo 16MB por valor. Accede a campos anidados con notación `:` y `[]`.

**P:** ¿Qué hace FLATTEN?
**R:** Convierte VARIANT/ARRAY/OBJECT en filas. Generalmente pareado con LATERAL en la cláusula FROM.

---

## EXPLICA COMO SI TUVIERA 5 AÑOS — Dominio 1

**Capa Cloud Services**: El jefe que lee tu pregunta, descubre el mejor plan y dice a los trabajadores qué hacer.

**Capa Compute**: Los trabajadores (virtual warehouses) que realmente hacen los cálculos y el trabajo pesado.

**Capa Storage**: El archivo gigante donde todos tus datos se guardan en pequeñas carpetas organizadas (micro-particiones).

**Micro-particiones**: Snowflake automáticamente corta tus datos en pequeñas cajas organizadas (50-500MB cada una) para encontrar cosas más rápido.

**Pruning**: Cuando pides datos, Snowflake revisa la etiqueta de cada caja (valores mín/máx) y salta las cajas que definitivamente no tienen lo que necesitas.

**Virtual Warehouse**: Un grupo de computadoras que hace tu trabajo. Puedes tener varios warehouses, y no se molestan entre sí.

**Ediciones**: Como planes de celular — Standard es básico, Enterprise agrega funciones (multi-cluster, 90 días Time Travel), Business Critical agrega seguridad (HIPAA, encriptación), VPS es tu Snowflake privado.

**Tabla transitoria**: Una tabla que se queda pero no guarda respaldos de largo plazo. Como escribir en un pizarrón que nadie fotografía.

**Tabla temporal**: Una tabla que desaparece cuando cierras tu sesión. Como un castillo de arena — desaparece cuando te vas de la playa.

**Tabla dinámica**: Una tabla que se actualiza automáticamente basada en una receta (consulta SQL) que escribiste. Como una hoja de cálculo que se llena sola.

**Snowpark**: Escribir código en Python/Java/Scala que ejecuta dentro de los trabajadores de Snowflake, en vez de escribir SQL.

**VARIANT**: Una caja especial que puede guardar datos desordenados (JSON, objetos anidados). Snowflake entiende lo que hay dentro.

**Clone zero-copy**: Hacer una copia de una tabla instantáneamente compartiendo las mismas cajas — ningún dato realmente se mueve hasta que alguien cambia algo.

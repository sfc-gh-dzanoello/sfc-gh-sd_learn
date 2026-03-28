# Dominio 2: Arquitectura de Datos

> **Cobertura del Temario ARA-C01:** Modelado de Datos, Jerarquía de Objetos, Recuperación de Datos

---

## 2.1 MODELADO DE DATOS

**Data Vault**

- Tres tipos de entidades principales: **Hubs** (business keys), **Links** (relaciones), **Satellites** (atributos descriptivos + historial)
- Diseñado para auditabilidad, flexibilidad y carga en paralelo
- Los hash keys permiten carga paralela basada solo en inserciones
- Ideal para: data warehouses empresariales con muchos sistemas fuente, schemas que evolucionan, requisitos de auditoría
- Desventaja: consultas más complejas, requiere modeladores experimentados

**Star Schema**

- **Fact table** central (medidas/métricas) rodeada de **dimension tables** (contexto descriptivo)
- Dimensiones desnormalizadas = lecturas rápidas, joins simples
- Ideal para: BI/analítica, dashboards, patrones de consulta conocidos
- Desventaja: el ETL es más difícil (se deben mantener las dimensiones desnormalizadas), menos flexible a cambios de schema

**Snowflake Schema**

- Similar al star schema pero las dimensiones están normalizadas (divididas en sub-dimensiones)
- Ej., `product_dim` → `category_dim` → `department_dim`
- Ideal para: ahorrar almacenamiento, reducir redundancia en dimensiones grandes
- Desventaja: más joins = consultas más lentas, más complejo para los analistas

**Cuándo usar cada uno**

| Modelo | Usar cuando... |
|---|---|
| Data Vault | Muchas fuentes, necesitas trazabilidad de auditoría, el schema cambia frecuentemente |
| Star | Schema estable, uso intensivo de BI, el rendimiento de consultas es prioridad |
| Snowflake | Dimensiones grandes con alta redundancia, el almacenamiento importa |
| Flat/OBT | Analítica simple, fuente única, mínimos joins necesarios |

### Por qué es importante
Una empresa de medios ingesta datos de más de 20 plataformas de anuncios. Los schemas cambian mensualmente. Data Vault absorbe los cambios en los Satellites sin romper los Hubs/Links. La capa de BI usa star schemas construidos encima.

### Mejores prácticas
- Usa Data Vault para la capa raw/integración, star schema para la capa de presentación
- Aprovecha la elasticidad de cómputo de Snowflake — los ahorros de almacenamiento del snowflake schema rara vez justifican la complejidad de las consultas
- Documenta los business keys y la granularidad de cada fact table

**Trampa del examen:** SI VES "star schema is best for audit trails" → INCORRECTO porque Data Vault está diseñado para auditabilidad.

**Trampa del examen:** SI VES "snowflake schema is the default recommendation for Snowflake the product" → INCORRECTO porque la coincidencia en el nombre es casual. Star schema es más común para analítica.

**Trampa del examen:** SI VES "Data Vault replaces dimensional modeling" → INCORRECTO porque Data Vault es para la capa de integración; aún se construyen star schemas encima para consumo.

### Preguntas frecuentes (FAQ)
**P: ¿Se puede usar star schema directamente sobre datos raw?**
R: Se puede, pero es frágil. Los cambios en los sistemas fuente rompen el modelo. Es mejor pasar por staging/integración primero.

**P: ¿Snowflake impone algún estándar de modelado?**
R: No. Snowflake es agnóstico al schema. Tú eliges el modelo que se adapte a tus necesidades.


### Ejemplos de Preguntas de Escenario — Data Modeling

**Escenario:** A media conglomerate acquires 5 companies, each with different source systems (SAP, Salesforce, custom APIs, flat files). Schemas change frequently due to ongoing integrations. The CFO needs a unified financial reporting layer for quarterly earnings. What data modeling approach should the architect recommend?
**Respuesta:** Use Data Vault for the integration/raw layer. Hubs capture core business entities (customer, account, transaction) via hash keys, Links capture relationships, and Satellites absorb schema changes without breaking existing structures. Each acquired company's data feeds into the same Hub/Link structure with separate Satellites tracking the source history. On top of the Data Vault layer, build star schemas for the presentation/consumption layer — the CFO's reporting team queries denormalized fact and dimension tables optimized for BI dashboards. This two-layer approach absorbs ongoing schema changes in the Data Vault while delivering stable, fast analytics in the star layer.

**Escenario:** A startup with a single Postgres source and 10 analysts wants fast dashboards. They have a small team with no Data Vault experience. The data schema is stable and changes rarely. What modeling approach fits best?
**Respuesta:** Star schema directly on the curated/presentation layer. With a single stable source, the complexity of Data Vault is unnecessary overhead. Build fact tables for core business events (orders, sessions, payments) surrounded by denormalized dimension tables (customers, products, dates). Star schema provides the simplest joins for BI tools like Tableau or Looker. Since Snowflake's elastic compute handles joins efficiently, the query performance benefits of denormalized dimensions outweigh the minimal storage savings of a normalized snowflake schema.

---

---

## 2.2 JERARQUÍA DE OBJETOS

**Estructura de arriba hacia abajo**

```
Organization
  └── Account
        └── Database
              └── Schema
                    ├── Tables (permanent, transient, temporary, external, dynamic, Iceberg)
                    ├── Views (standard, secure, materialized)
                    ├── Stages (internal, external)
                    ├── File Formats
                    ├── Sequences
                    ├── Streams
                    ├── Tasks
                    ├── Pipes
                    ├── UDFs / UDTFs
                    ├── Stored Procedures
                    ├── Tags
                    └── Policies (masking, RAP, aggregation, projection)
```

**Puntos clave**

- Todo vive dentro de un namespace `DATABASE.SCHEMA`
- Algunos objetos son a nivel de cuenta: warehouses, usuarios, roles, resource monitors, network policies, integraciones, shares
- Los stages pueden ser a nivel de tabla (`@%my_table`), a nivel de schema (`@my_stage`), o a nivel de usuario (`@~`)
- Managed access schemas: solo el propietario del schema (o quien tenga MANAGE GRANTS) puede otorgar privilegios — impide que los propietarios de objetos otorguen acceso de manera independiente

### Por qué es importante
Un equipo de plataforma de datos necesita evitar que los propietarios individuales de tablas otorguen SELECT a roles arbitrarios. Los managed access schemas centralizan el control de grants.

### Mejores prácticas
- Usa managed access schemas en producción
- Organiza los schemas por dominio o capa de datos (raw, curado, presentación)
- Nombra los objetos de manera consistente: `<dominio>_<entidad>_<sufijo>` (ej., `sales_orders_fact`)
- Mantén los objetos a nivel de cuenta (warehouses, roles) bien documentados

**Trampa del examen:** SI VES "warehouses belong to a database" → INCORRECTO porque los warehouses son objetos a nivel de cuenta.

**Trampa del examen:** SI VES "managed access schemas prevent the schema owner from granting" → INCORRECTO porque el propietario del schema SÍ PUEDE otorgar permisos en managed access schemas — la restricción es sobre los propietarios de objetos que no son el propietario del schema.

**Trampa del examen:** SI VES "network policies are database-level objects" → INCORRECTO porque son a nivel de cuenta.

### Preguntas frecuentes (FAQ)
**P: ¿Cuál es la diferencia entre `@~` y `@%table`?**
R: `@~` es el stage de usuario (uno por usuario). `@%table` es el stage de tabla (uno por tabla). Ambos son internos, pero con alcance diferente.

**P: ¿Se puede tener un schema sin una base de datos?**
R: No. Los schemas siempre viven dentro de una base de datos.


### Ejemplos de Preguntas de Escenario — Object Hierarchy

**Escenario:** A production data platform has 200 tables owned by different teams (marketing, finance, engineering). The security team discovers that individual table owners have been granting SELECT on their tables to unapproved roles, bypassing the central governance model. How should the architect prevent this?
**Respuesta:** Convert production schemas to managed access schemas using `ALTER SCHEMA ... ENABLE MANAGED ACCESS`. In a managed access schema, only the schema owner or roles with the MANAGE GRANTS privilege can issue GRANT statements on objects within the schema. Individual table owners lose the ability to grant access independently. This centralizes privilege management without requiring any changes to the object ownership model or existing data pipelines.

**Escenario:** An architect is designing the schema layout for a new analytics platform. They need separate layers for raw ingestion, cleaned/curated data, and presentation-ready datasets. Some objects (warehouses, resource monitors, network policies) need to be shared across all layers. How should this be organized?
**Respuesta:** Create a single database (or one per domain) with three schemas: `RAW`, `CURATED`, and `PRESENTATION`. Each schema represents a data layer with its own access controls. Warehouses, resource monitors, network policies, users, and roles are account-level objects — they exist outside the database hierarchy and are shared across all schemas automatically. Use managed access schemas for `CURATED` and `PRESENTATION` to enforce centralized grant control. Name objects consistently with domain prefixes (e.g., `sales_orders_fact`) for discoverability.

---

---

## 2.3 TIPOS DE TABLAS Y VISTAS

**Tipos de tablas**

| Tipo | Time Travel | Fail-safe | Persiste después de la sesión | Clonable |
|---|---|---|---|---|
| **Permanent** | 0-90 días (Enterprise) | 7 días | Sí | Sí |
| **Transient** | 0-1 día | Ninguno | Sí | Sí |
| **Temporary** | 0-1 día | Ninguno | No (alcance de sesión) | Sí (dentro de la sesión) |
| **External** | No | No | Sí (solo metadata) | No |
| **Dynamic** | 0-90 días | 7 días | Sí | No |

- **Transient:** úsalas para tablas de staging/ETL donde no necesitas Fail-safe (ahorra costos de almacenamiento)
- **Temporary:** úsalas para resultados intermedios con alcance de sesión
- **External:** capa de metadata sobre archivos en almacenamiento externo — solo lectura
- **Dynamic:** se actualizan automáticamente basándose en una consulta y un target lag

**Iceberg Tables**

- **Managed (administrada por Snowflake):** Snowflake administra la metadata de Iceberg + los archivos de datos
  - Soporte completo de DML (INSERT, UPDATE, DELETE, MERGE)
  - Snowflake maneja la compactación y la gestión de snapshots
  - Se almacenan en almacenamiento administrado por Snowflake o en un external volume del cliente
- **Unmanaged (administrada externamente / catalog-linked):** un catálogo externo (AWS Glue, Polaris) administra la metadata
  - Solo lectura desde Snowflake (o escritura limitada dependiendo del catálogo)
  - Snowflake lee la metadata de Iceberg para consultar los datos
  - Úsalas para acceso multi-motor (Spark + Snowflake sobre los mismos datos)

**Hybrid Tables**

- Diseñadas para cargas de trabajo transaccionales (OLTP) dentro de Snowflake
- Soportan búsquedas rápidas de una sola fila, índices e integridad referencial (PRIMARY KEY, FOREIGN KEY, UNIQUE enforced)
- Almacenadas en formato orientado a filas para lecturas de baja latencia por punto
- Caso de uso: datos operacionales que también necesitan unirse con datos analíticos

**Tipos de vistas**

| Tipo | ¿Materializada? | ¿Segura? | Notas |
|---|---|---|---|
| Vista estándar | No | No | Solo una consulta guardada |
| Secure view | No | Sí | Oculta la definición, barrera del optimizador |
| Materialized view | Sí | No | Pre-calculada, mantenida automáticamente |
| Secure materialized view | Sí | Sí | Ambos beneficios |

- **Secure views:** la definición de la consulta se oculta de los consumidores, el optimizador no puede empujar predicados más allá del límite de la vista
- **Materialized views:** ideales para agregaciones costosas sobre datos grandes que cambian con poca frecuencia
- Las materialized views tienen limitaciones: no permiten joins, UDFs ni subqueries en su definición

### Por qué es importante
Un marketplace de datos comparte datos mediante secure views — los consumidores no pueden ver la lógica de la consulta subyacente ni eludir la seguridad a nivel de fila.

### Mejores prácticas
- Usa tablas transient para datos de staging (evita costos innecesarios de Fail-safe)
- Usa dynamic tables en lugar de pipelines complejos de task/stream donde sea posible
- Usa secure views para todos los objetos compartidos
- Considera tablas managed Iceberg cuando necesites interoperabilidad en formato abierto

**Trampa del examen:** SI VES "transient tables have 7 days of Fail-safe" → INCORRECTO porque las tablas transient tienen cero Fail-safe.

**Trampa del examen:** SI VES "temporary tables persist after the session ends" → INCORRECTO porque se eliminan cuando la sesión termina.

**Trampa del examen:** SI VES "materialized views support joins" → INCORRECTO porque las definiciones de MVs no pueden incluir joins.

**Trampa del examen:** SI VES "hybrid tables use columnar storage" → INCORRECTO porque usan almacenamiento orientado a filas para búsquedas rápidas por punto.

**Trampa del examen:** SI VES "external tables support DML" → INCORRECTO porque las tablas externas son de solo lectura.

### Preguntas frecuentes (FAQ)
**P: ¿Se puede convertir una tabla permanent a transient?**
R: No directamente. Debes crear una nueva tabla transient y copiar los datos (o usar CTAS).

**P: ¿Las secure views tienen un costo de rendimiento?**
R: Sí. La barrera del optimizador impide algunas optimizaciones, por lo que las secure views pueden ser más lentas que las vistas estándar.

**P: ¿Cuándo usaría una tabla managed Iceberg en vez de una tabla regular de Snowflake?**
R: Cuando necesitas que los datos estén en formato abierto Iceberg para acceso multi-motor y al mismo tiempo tener DML completo de Snowflake.


### Ejemplos de Preguntas de Escenario — Table Types & Views

**Escenario:** A data platform team runs multi-step ETL pipelines that produce intermediate staging tables. These tables are recreated every run and don't need historical recovery. Storage costs are a concern because the staging data is 50 TB and growing. What table types should the architect use?
**Respuesta:** Use transient tables for all staging/intermediate tables. Transient tables have zero Fail-safe storage (saving 7 days worth of historical data storage per table) and a maximum of 1-day Time Travel. Since these tables are recreated every run, the 7-day Fail-safe of permanent tables provides no value but adds significant storage cost at 50 TB scale. For truly session-scoped scratch work within a single ETL step, temporary tables are even lighter (dropped when the session ends).

**Escenario:** A company runs both Snowflake and Apache Spark. The data science team uses Spark for ML training on feature tables, while the analytics team queries the same tables from Snowflake. Currently, data is duplicated — a Snowflake copy and a Parquet copy in S3. How should the architect eliminate the duplication?
**Respuesta:** Migrate the feature tables to managed Iceberg tables with an external volume pointing to S3. Snowflake manages the table lifecycle (writes, compaction, snapshots) and produces Iceberg-formatted data files and metadata in S3. Spark reads the same Iceberg metadata and data files directly — no duplication. Snowflake retains full DML (INSERT, UPDATE, DELETE, MERGE) support, Time Travel, and clustering. The data science team accesses the same data from Spark without any data movement or copy.

**Escenario:** A data marketplace needs to share pre-aggregated sales metrics with external consumers. The underlying query logic is proprietary. Consumers should not see the SQL definition or be able to bypass row-level security through optimizer tricks. What view type should the architect use?
**Respuesta:** Use secure views (or secure materialized views for expensive aggregations). Secure views hide the view definition from consumers and impose an optimizer fence that prevents predicate pushdown past the view boundary — this stops consumers from inferring hidden data through clever filtering. For the data marketplace use case, all shared objects should use secure views as a baseline. Note that secure views have a minor performance cost due to the optimizer fence, but this is an acceptable trade-off for data protection in a sharing context.

---

---

## 2.4 RECUPERACIÓN DE DATOS

**Time Travel**

- Consulta o restaura datos tal como existían en cualquier punto dentro del período de retención
- Métodos: `AT` / `BEFORE` con `TIMESTAMP`, `OFFSET`, o `STATEMENT` (query ID)
- Retención: 0-1 día (Standard), 0-90 días (Enterprise+)
- Funciona en tablas, schemas y bases de datos
- Tiene costo de almacenamiento por los datos modificados/eliminados

**Fail-safe**

- Período de 7 días DESPUÉS de que Time Travel expire
- NO es accesible por el usuario — solo el Soporte de Snowflake puede recuperar datos
- Solo para tablas permanent (no transient, temporary ni external)
- Existe como último recurso para escenarios catastróficos

**UNDROP**

- Restaura el objeto eliminado más recientemente: `UNDROP TABLE`, `UNDROP SCHEMA`, `UNDROP DATABASE`
- Usa datos de Time Travel internamente
- Si eliminas y recreas un objeto con el mismo nombre, el anterior sigue siendo recuperable con UNDROP (usa versionado interno)

**Zero-Copy Cloning para respaldos**

- `CREATE TABLE backup_table CLONE source_table`
- Sin almacenamiento adicional hasta que los datos divergen
- Los clones heredan la configuración de Time Travel de la fuente
- Soporta clonado de bases de datos y schemas (clonado recursivo de todos los hijos)
- Los clones son independientes — los cambios en el clon no afectan a la fuente

**Replicación para DR**

- Replicación de base de datos: copia asíncrona de una base de datos a otra cuenta/región
- Replicación de cuenta: replica usuarios, roles, warehouses, políticas
- Failover groups: conjunto de objetos replicados que pueden hacer failover juntos
- El RPO depende de la frecuencia de replicación; el RTO es el tiempo para promover el secundario

### Por qué es importante
Un analista ejecuta accidentalmente `DELETE FROM production_table`. Con 90 días de Time Travel, el equipo de datos restaura la tabla a 5 minutos antes del borrado. Sin cintas de respaldo, sin tiempo de inactividad.

### Mejores prácticas
- Configura 90 días de Time Travel en tablas críticas de producción (requiere Enterprise)
- Usa tablas transient para staging para evitar costos de almacenamiento de Fail-safe
- Clona producción a dev/test en lugar de copiar datos
- Configura replicación para bases de datos de misión crítica hacia una región secundaria
- Prueba tus procedimientos de recuperación regularmente

**Trampa del examen:** SI VES "Fail-safe data can be recovered by users via SQL" → INCORRECTO porque solo el Soporte de Snowflake puede recuperar datos de Fail-safe.

**Trampa del examen:** SI VES "Time Travel retention can be set to 90 days on Standard edition" → INCORRECTO porque Standard edition máximo es 1 día.

**Trampa del examen:** SI VES "cloning a table doubles storage immediately" → INCORRECTO porque el clonado es zero-copy; el almacenamiento solo crece cuando los datos divergen.

**Trampa del examen:** SI VES "UNDROP works on transient tables after Fail-safe" → INCORRECTO porque las tablas transient no tienen Fail-safe, y UNDROP solo funciona durante el período de Time Travel.

### Preguntas frecuentes (FAQ)
**P: Si configuro Time Travel en 0, ¿todavía puedo usar UNDROP?**
R: No. UNDROP depende de los datos de Time Travel. Con retención en 0, los datos desaparecen inmediatamente.

**P: ¿El clonado copia los grants?**
R: Al clonar bases de datos/schemas, los grants de los objetos hijos se copian. Los clones a nivel de tabla no copian los grants por defecto (a menos que uses `COPY GRANTS`).

**P: ¿Se puede replicar a un proveedor de nube diferente?**
R: Sí. La replicación cross-cloud es soportada (ej., AWS a Azure), pero ambas cuentas deben estar en la misma Organization.


### Ejemplos de Preguntas de Escenario — Data Recovery

**Escenario:** A junior engineer accidentally runs `TRUNCATE TABLE customers` on the production database containing 500M rows. The team discovers the mistake 3 hours later. The account is on Enterprise edition with the default 1-day Time Travel retention. How should the architect recover the data?
**Respuesta:** Use Time Travel to restore the data. Since only 3 hours have passed and the table has at least 1-day Time Travel, the data is fully recoverable. Option 1: `CREATE TABLE customers_restored CLONE customers BEFORE(STATEMENT => '<truncate_query_id>')` to create a point-in-time clone, then swap the tables. Option 2: `INSERT INTO customers SELECT * FROM customers BEFORE(OFFSET => -10800)` to repopulate from the 3-hour-ago snapshot. Going forward, the architect should set `DATA_RETENTION_TIME_IN_DAYS = 90` on all critical production tables (Enterprise edition supports up to 90 days) and set `MIN_DATA_RETENTION_TIME_IN_DAYS` at the account level to prevent anyone from reducing it.

**Escenario:** A data platform team needs to provide fresh copies of the 200 TB production database to 5 development teams daily for testing. Full data copies would cost 1 PB of storage. How should the architect handle this efficiently?
**Respuesta:** Use zero-copy cloning: `CREATE DATABASE dev_team_1 CLONE production`. Each clone initially shares all underlying micro-partitions with production — zero additional storage. Storage only grows as dev teams make changes to their cloned data. Each morning, drop the previous day's clones and create fresh ones. Clones inherit Time Travel settings from the source and are fully independent — dev team changes never affect production. This provides 5 teams with full production data at near-zero storage cost.

---

---

## 2.5 REPLICACIÓN Y FAILOVER

**Replicación de base de datos**

- Replica una base de datos desde la cuenta primaria a una o más cuentas secundarias
- La secundaria es de solo lectura hasta que se promueve (o hasta el failover)
- La replicación es asíncrona — la frescura de los datos depende del calendario de refresco
- La replicación inicial copia todos los datos; las posteriores son incrementales (solo cambios)

**Replicación de cuenta**

- Replica objetos a nivel de cuenta: usuarios, roles, grants, warehouses, network policies, parámetros
- Esencial para un DR verdadero — la replicación de base de datos por sí sola no cubre el control de acceso
- Se combina con la replicación de base de datos en failover groups

**Failover Groups**

- Colección nombrada de objetos que pueden hacer failover como una unidad
- Tipos de objetos: bases de datos, shares, usuarios, roles, warehouses, integraciones, network policies
- Promoción de `PRIMARY` → `SECONDARY` mediante `ALTER FAILOVER GROUP ... PRIMARY`
- Solo un primario a la vez por failover group

**Cross-Region / Cross-Cloud**

- La replicación funciona entre regiones Y entre proveedores de nube
- Ambas cuentas deben estar en la misma Organization de Snowflake
- Considera las regulaciones de residencia de datos al replicar entre regiones
- Costos de replicación: transferencia de datos + cómputo para el refresco

**Client Redirect**

- URLs de conexión que redirigen automáticamente al primario activo
- Minimiza los cambios del lado del cliente durante el failover
- Usa objetos `CONNECTION`: `CREATE CONNECTION`, `ALTER CONNECTION ... PRIMARY`

### Por qué es importante
Una empresa fintech global ejecuta el primario en AWS US-East, el secundario en AWS EU-West. Si US-East cae, promueven EU-West en minutos. Client redirect significa que las aplicaciones no necesitan cambios de configuración.

### Mejores prácticas
- Usa failover groups (no replicación de base de datos independiente) para DR en producción
- Incluye objetos de cuenta en tu failover group para una recuperación completa
- Configura client redirect para minimizar el RTO del failover
- Monitorea el retraso de replicación mediante `REPLICATION_GROUP_REFRESH_HISTORY`
- Prueba el failover trimestralmente con simulacros reales de promoción/failback

**Trampa del examen:** SI VES "secondary databases are read-write" → INCORRECTO porque las bases de datos secundarias son de solo lectura hasta que se promueven a primarias.

**Trampa del examen:** SI VES "replication requires the same cloud provider" → INCORRECTO porque se soporta replicación cross-cloud.

**Trampa del examen:** SI VES "failover is automatic" → INCORRECTO porque el failover debe iniciarse manualmente (Snowflake no hace auto-failover).

**Trampa del examen:** SI VES "client redirect works without Connection objects" → INCORRECTO porque debes crear y configurar objetos Connection para client redirect.

### Preguntas frecuentes (FAQ)
**P: ¿Cuál es la diferencia entre replicación de base de datos y failover groups?**
R: La replicación de base de datos cubre una base de datos. Los failover groups agrupan múltiples bases de datos + objetos de cuenta para un failover coordinado.

**P: ¿Hay pérdida de datos durante el failover?**
R: Potencialmente, sí. RPO = tiempo desde el último refresco de replicación exitoso. Cualquier dato escrito después del último refresco no está en el secundario.

**P: ¿Se pueden tener múltiples failover groups?**
R: Sí. Puedes tener múltiples failover groups, cada uno conteniendo diferentes conjuntos de objetos. Cada objeto solo puede pertenecer a un failover group.


### Ejemplos de Preguntas de Escenario — Replication & Failover

**Escenario:** A global fintech company runs its primary Snowflake account in AWS US-East-1. Regulators require that the platform can recover from a full regional outage within 5 minutes (RTO) with no more than 15 minutes of data loss (RPO). Applications connect via JDBC using a single connection URL. How should the architect design the DR architecture?
**Respuesta:** Set up a failover group containing all critical databases plus account-level objects (users, roles, grants, warehouses, network policies, integrations). Replicate to a secondary account in AWS EU-West-1 (or another region) within the same Organization. Schedule replication refreshes every 10-15 minutes to meet the 15-minute RPO. Configure client redirect using a Connection object — applications connect to the Connection URL, which automatically routes to the active primary. During failover, promote the secondary via `ALTER FAILOVER GROUP ... PRIMARY` and update the Connection object. Apps automatically redirect to the new primary without configuration changes, meeting the 5-minute RTO. Test failover quarterly with real promote/failback drills.

**Escenario:** A company replicates its core database to a secondary account for DR, but during a failover drill, they discover that users cannot log in to the secondary account because roles, grants, and network policies were not replicated. What did the architect miss?
**Respuesta:** The architect used database replication alone instead of a failover group with account replication. Database replication only copies the database and its contents — it does not replicate account-level objects like users, roles, grants, warehouses, network policies, or integrations. The correct approach is to create a failover group that includes both the databases AND account-level objects. This ensures that when the secondary is promoted, all access controls, role hierarchies, and network policies are already in place. Always include account objects in failover groups for complete DR.

**Escenario:** An organization operates on AWS for its primary workloads but wants a secondary DR site on Azure for cloud-provider redundancy. Is this possible with Snowflake replication?
**Respuesta:** Yes. Snowflake supports cross-cloud replication — you can replicate from an AWS account to an Azure account (or GCP) as long as both accounts are in the same Snowflake Organization. The failover group mechanism works identically across cloud providers. However, the architect should account for cross-cloud data transfer costs, potential latency differences, and data residency regulations that may restrict which regions data can be replicated to. Monitor replication lag via `REPLICATION_GROUP_REFRESH_HISTORY` to ensure RPO targets are met despite cross-cloud overhead.

---

---

## PARES CONFUSOS — Arquitectura de Datos

| Preguntan sobre... | La respuesta es... | NO... |
|---|---|---|
| **Star schema** vs **snowflake schema** | **Star** = dimensiones desnormalizadas, menos joins, consultas rápidas | **Snowflake schema** = dimensiones normalizadas, más joins, ahorra almacenamiento pero más lento |
| **Data Vault** vs **dimensional modeling** | **Data Vault** = capa de integración/raw (Hubs, Links, Satellites) | **Dimensional** = capa de presentación/BI (facts + dims). Son *complementarios*, no competidores |
| **Hub** vs **Link** vs **Satellite** | **Hub** = business key, **Link** = relación, **Satellite** = historial descriptivo | No confundir Hub (ID de entidad) con Satellite (atributos) |
| **Managed Iceberg** vs **unmanaged Iceberg** | **Managed** = Snowflake controla metadata + DML completo | **Unmanaged** = catálogo externo (Glue, Polaris) controla metadata, solo lectura desde Snowflake |
| **Time Travel** vs **Fail-safe** | **Time Travel** = accesible por usuario, 0-90 días, consulta/restaura vía SQL | **Fail-safe** = solo Soporte de Snowflake, 7 días DESPUÉS de que Time Travel expire |
| **Clone** vs **replica** | **Clone** = snapshot zero-copy *dentro* de la misma cuenta, objeto independiente | **Replica** = copia asíncrona a *otra* cuenta/región para DR |
| **Permanent** vs **transient** table | **Permanent** = Time Travel completo + 7 días de Fail-safe | **Transient** = máximo 1 día de Time Travel, **cero** Fail-safe |
| **Temporary** vs **transient** table | **Temporary** = alcance de sesión, desaparece al terminar la sesión | **Transient** = persiste entre sesiones, solo sin Fail-safe |
| **Secure view** vs **standard view** | **Secure** = oculta definición + barrera del optimizador (más lento) | **Standard** = definición visible, optimizador completo (más rápido) |
| **Materialized view** vs **dynamic table** | **MV** = auto-mantenido, no permite joins/UDFs | **Dynamic table** = más flexible (joins OK), basado en target lag, reemplaza stream+task |
| **Hybrid table** vs **regular table** | **Hybrid** = orientado a filas, PK/FK/UNIQUE enforced, búsquedas rápidas por punto (OLTP) | **Regular** = columnar, sin constraints enforced (OLAP) |
| **Database replication** vs **failover group** | **DB replication** = una base de datos copiada a secundario | **Failover group** = conjunto de DBs + objetos de cuenta que hacen failover juntos |
| **UNDROP** vs **Time Travel AT** | **UNDROP** = restaura un objeto *eliminado* | **AT/BEFORE** = consulta/restaura datos en un *punto en el tiempo* (el objeto aún existe) |
| **Client redirect** vs **DNS failover** | **Client redirect** = objeto **Connection** de Snowflake, redirige automáticamente al primario activo | NO es DNS genérico — requiere configuración explícita de Snowflake |

---

## ÁRBOLES DE DECISIÓN POR ESCENARIO — Arquitectura de Datos

**Escenario 1: "20+ sistemas fuente, los schemas cambian mensualmente, necesitan trazabilidad completa de auditoría..."**
- **CORRECTO:** **Data Vault** para la capa de integración (absorbe cambios en Satellites)
- TRAMPA: *"Star schema on raw data"* — **INCORRECTO**, star schema es frágil con cambios frecuentes de schema

**Escenario 2: "El equipo de BI necesita dashboards rápidos sobre datos estables y bien entendidos..."**
- **CORRECTO:** **Star schema** para la capa de presentación/consumo
- TRAMPA: *"Data Vault directly for BI"* — **INCORRECTO**, las consultas de Data Vault son complejas; construye star schemas encima

**Escenario 3: "Necesitan datos en formato abierto para que Spark y Snowflake puedan leer/escribir..."**
- **CORRECTO:** **Managed Iceberg table** con external volume (Snowflake escribe en formato Iceberg, Spark lee los mismos archivos)
- TRAMPA: *"External table"* — **INCORRECTO**, las tablas externas son de solo lectura y no producen formato Iceberg

**Escenario 4: "Las tablas de staging contienen datos temporales de ETL — minimizar costos de almacenamiento..."**
- **CORRECTO:** **Transient tables** (sin Fail-safe = menor costo de almacenamiento)
- TRAMPA: *"Temporary tables"* — **INCORRECTO**, las tablas temporales tienen alcance de sesión y desaparecen al terminar; no son adecuadas para ETL multi-sesión

**Escenario 5: "Un analista eliminó accidentalmente 1M de filas de producción hace 2 horas..."**
- **CORRECTO:** **Time Travel** — `INSERT INTO prod SELECT * FROM prod AT(OFFSET => -7200)` o `CREATE TABLE restore CLONE prod AT(...)`
- TRAMPA: *"Contact Snowflake Support for Fail-safe"* — **INCORRECTO**, Fail-safe es solo después de que Time Travel expire; 2 horas atrás está dentro de Time Travel

**Escenario 6: "Necesitan DR a una región de nube diferente con < 5 min de RTO para conexiones de la app..."**
- **CORRECTO:** **Failover group** (DB + objetos de cuenta) + **client redirect** (objeto Connection)
- TRAMPA: *"Database replication alone"* — **INCORRECTO**, la replicación de DB no cubre roles/usuarios/políticas, y sin objetos Connection no hay redirección automática

**Escenario 7: "Evitar que los propietarios individuales de tablas en producción otorguen acceso a sus tablas..."**
- **CORRECTO:** **Managed access schema** — centraliza el control de grants al propietario del schema
- TRAMPA: *"Just use RBAC carefully"* — **INCORRECTO**, sin managed access, cualquier propietario de objeto puede otorgar privilegios

**Escenario 8: "Datos compartidos con consumidores externos — se debe ocultar la definición de la consulta..."**
- **CORRECTO:** **Secure views** (oculta definición, previene bypass de predicate pushdown)
- TRAMPA: *"Standard views with row access policies"* — **INCORRECTO**, las vistas estándar exponen la definición SQL a los consumidores

**Escenario 9: "Necesitan una tabla resumen pre-calculada que se auto-actualice, agregación simple, sin joins..."**
- **CORRECTO:** **Materialized view** (auto-mantenida, ideal para agregaciones simples)
- TRAMPA: *"Dynamic table"* — no es incorrecto per se, pero MV es más simple y eficiente para agregaciones de una sola tabla sin joins

**Escenario 10: "La aplicación necesita búsquedas rápidas de una sola fila por primary key + joins con tablas analíticas..."**
- **CORRECTO:** **Hybrid table** (orientado a filas, PK enforced, lecturas rápidas por punto)
- TRAMPA: *"Regular Snowflake table with clustering on PK"* — **INCORRECTO**, el almacenamiento columnar no está optimizado para búsquedas de una sola fila

**Escenario 11: "El clúster de Spark es dueño del catálogo Iceberg (AWS Glue), Snowflake necesita leerlo..."**
- **CORRECTO:** **Unmanaged (catalog-linked) Iceberg table** con integración de catálogo Glue
- TRAMPA: *"Managed Iceberg table"* — **INCORRECTO**, managed significa que Snowflake toma control del catálogo, entrando en conflicto con Spark

**Escenario 12: "Clonar producción a dev para pruebas sin duplicar el almacenamiento..."**
- **CORRECTO:** **Zero-copy clone** (`CREATE DATABASE dev CLONE prod`)
- TRAMPA: *"CTAS all tables into new database"* — **INCORRECTO**, CTAS copia todos los datos inmediatamente, duplicando el almacenamiento

---

## TARJETAS DE REPASO -- Dominio 2

**P1:** ¿Cuáles son los tres tipos de entidades principales en Data Vault?
**R1:** Hubs (business keys), Links (relaciones), Satellites (atributos descriptivos + historial).

**P2:** ¿Cuál es la retención máxima de Time Travel en Enterprise edition?
**R2:** 90 días.

**P3:** ¿Las tablas transient tienen Fail-safe?
**R3:** No. Cero Fail-safe.

**P4:** ¿Las materialized views pueden incluir joins?
**R4:** No. Las MVs no pueden incluir joins, UDFs ni subqueries.

**P5:** ¿Qué es zero-copy cloning?
**R5:** Crear una copia de un objeto que comparte el almacenamiento subyacente hasta que los datos divergen. Sin almacenamiento adicional al momento de clonar.

**P6:** ¿Cuál es la diferencia entre tablas Iceberg managed y unmanaged?
**R6:** Managed: Snowflake controla metadata + datos, DML completo. Unmanaged: catálogo externo maneja metadata, limitado/solo lectura desde Snowflake.

**P7:** ¿Qué objetos puede contener un failover group?
**R7:** Bases de datos, shares, usuarios, roles, warehouses, integraciones, network policies y otros objetos de cuenta.

**P8:** ¿Cómo funciona UNDROP si eliminas y recreas una tabla con el mismo nombre?
**R8:** UNDROP usa versionado interno — restaura la versión eliminada más reciente, no la actual.

**P9:** ¿Qué hace diferentes a las hybrid tables de las tablas regulares?
**R9:** Almacenamiento orientado a filas, constraints enforced (PK, FK, UNIQUE), búsquedas rápidas por punto — diseñadas para OLTP.

**P10:** ¿La replicación es síncrona o asíncrona?
**R10:** Asíncrona. La frescura de los datos depende de la frecuencia de refresco.

**P11:** ¿Qué es un managed access schema?
**R11:** Un schema donde solo el propietario del schema (o quien tenga MANAGE GRANTS) puede otorgar privilegios sobre objetos — los propietarios individuales de objetos no pueden.

**P12:** ¿Cuál es el costo de almacenamiento adicional de Fail-safe?
**R12:** Hasta 7 días de datos históricos más allá de Time Travel, solo para tablas permanentes.

**P13:** ¿Se puede replicar entre proveedores de nube?
**R13:** Sí, siempre que ambas cuentas estén en la misma Organization.

**P14:** ¿Qué oculta una secure view?
**R14:** Su definición de consulta y previene que el optimizador empuje predicados más allá del límite de la vista.

**P15:** ¿Qué es client redirect?
**R15:** Un objeto Connection que redirige automáticamente a los clientes a la cuenta primaria activa durante el failover.

---

## EXPLÍCALO COMO SI TUVIERA 5 AÑOS -- Dominio 2

**1. Data Vault**
Imagina que tienes una caja para el nombre de cada amigo (Hub), un hilo conectando a los amigos que jugaron juntos (Link), y notas adhesivas describiendo lo que pasó en cada cita de juegos (Satellite). ¡Nunca tiras nada — solo agregas más notas adhesivas!

**2. Star Schema**
Tu colección de juguetes: el gran cofre de juguetes en el centro tiene todas tus sesiones de juego (fact table). Alrededor hay estantes etiquetados "juguetes," "amigos," "días de la semana" (dimension tables). Fácil de encontrar "¿con qué juguete jugué el martes?"

**3. Time Travel**
Tu botón mágico de deshacer. ¿Derramaste pintura en tu dibujo? Presiona deshacer y regresa a antes del derrame. ¡Funciona hasta por 90 días!

**4. Fail-safe**
Incluso después de que tu botón de deshacer deja de funcionar, tus papás guardaron una copia secreta de tus dibujos en un cajón con llave. Tú no puedes abrirlo, pero ellos pueden ayudar si algo realmente malo pasa.

**5. Zero-Copy Cloning**
Como tomar una foto de tu castillo de LEGO. La foto no usa piezas extra. Pero si cambias el castillo original, solo las partes cambiadas necesitan piezas extra.

**6. Transient vs Permanent Tables**
Las tablas permanentes son como tu juguete favorito guardado para siempre con seguro (Fail-safe). Las tablas transient son como castillos de arena — existen, pero sin seguro si viene la marea.

**7. Managed Iceberg Tables**
Construyes con LEGO, pero usas el sistema de conector universal de LEGO para que tu amigo con una marca diferente de LEGO también pueda conectarse a tu castillo. Snowflake maneja la construcción, pero cualquiera puede leer las instrucciones.

**8. Secure Views**
Una ventana mágica donde puedes ver el jardín pero no puedes ver cómo se construyó la ventana. Diferentes personas mirando por la misma ventana podrían ver flores diferentes (¡filtradas!).

**9. Replication**
Como tener una copia de respaldo de tu archivo de guardado de juego favorito en una USB en casa de la abuela. Si tu computadora se rompe, la abuela tiene el archivo. No es exactamente al segundo, pero cercano.

**10. Client Redirect**
Como un buzón que te sigue. Si te mudas de casa, el buzón automáticamente va a tu nueva casa, y las cartas de todos siguen llegando sin que sepan que te mudaste.

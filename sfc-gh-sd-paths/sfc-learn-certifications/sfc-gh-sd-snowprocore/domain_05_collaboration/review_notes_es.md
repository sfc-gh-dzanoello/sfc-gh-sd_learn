# DOMINIO 5: COLABORACIÓN DE DATOS
## 10% del examen = ~10 preguntas. Dominio más pequeño, pero puntos fáciles.

---

## 5.1 REPLICACIÓN Y FAILOVER DE DATOS

### Replicación de Base de Datos:
- Copia una base de datos de una cuenta a otra
- Base de datos primaria (lectura-escritura) → Base(s) de datos secundaria(s) (solo lectura)
- Puede replicar entre regiones y proveedores de nube
- La base de datos secundaria se refresca para sincronizar cambios de la primaria
- Requerido para: compartir datos entre regiones

### Replicación de Cuenta:
- Replica objetos a nivel de cuenta (usuarios, roles, warehouses, bases de datos)
- Para recuperación ante desastres

### Failover (Business Critical+):
- Promueve una base de datos/cuenta secundaria a primaria
- Cuando la región/cuenta primaria no está disponible
- Continuidad del negocio y recuperación ante desastres
- Failback: volver a la primaria original después de la recuperación

**Trampa del examen**: "¿Compartir datos entre regiones?" → Se necesita replicación PRIMERO, luego compartir. SI VES "compartir directo" + "entre regiones" o "diferente nube" → INCORRECTO porque compartir directo = misma región + misma nube solamente.
**Trampa del examen**: "¿Edición para failover?" → Business Critical+. SI VES "Standard" o "Enterprise" + "failover" → INCORRECTO porque failover requiere Business Critical o superior.
**Trampa del examen**: "¿La base de datos secundaria es...?" → Solo lectura hasta que se promueve. SI VES "lectura-escritura" + "base de datos secundaria" → INCORRECTO porque secundaria = solo lectura. Solo la primaria es lectura-escritura.


### Ejemplos de Preguntas de Escenario — Data Replication & Failover

**Escenario:** A multinational retail company has its primary Snowflake account in AWS US-East-1. They need to share sales data with their analytics team in AWS EU-Frankfurt. The team tries to create a direct share but gets an error. What is the correct approach?
**Respuesta:** Direct shares only work within the same cloud provider AND the same region. The company must first replicate the database to an account in AWS EU-Frankfurt using database replication (CREATE DATABASE ... AS REPLICA OF ...), then create a share from the replicated database in that region. Replication works across regions and cloud providers on any Snowflake edition.

**Escenario:** A financial services firm on Snowflake Business Critical edition has accounts in two regions for disaster recovery. Their primary region experiences an outage. The DR team needs to restore operations. What Snowflake feature should they use, and what edition is required?
**Respuesta:** They should use Failover to promote their secondary account/database to primary. Failover is available only on Business Critical edition and above — their BC edition qualifies. Once the original region recovers, they can failback (switch back to the original primary). Standard and Enterprise editions support replication but NOT failover.

**Escenario:** A healthcare company replicates their patient analytics database to a secondary account for disaster recovery. A junior analyst connects to the secondary database and tries to INSERT new records. What happens?
**Respuesta:** The INSERT will fail. Secondary databases are read-only — they can only be used for querying until they are promoted to primary via failover. Only the primary database supports read-write operations. The analyst must connect to the primary account to insert data.

---

---

## 5.2 COMPARTIR DATOS DE FORMA SEGURA (MUY PROBADO)

### Cómo funciona:
- El Proveedor COMPARTE datos con el Consumidor
- NO se copian ni mueven datos
- El Consumidor accede a los datos del Proveedor en tiempo real
- Los cambios del Proveedor son visibles para el Consumidor INMEDIATAMENTE
- Cero movimiento de datos = cero costo de almacenamiento por compartir

### Qué se puede compartir:
- Tablas
- Vistas seguras (requerido para compartir vistas)
- UDFs seguras
- Vistas materializadas seguras

### Qué NO se puede compartir directamente:
- Vistas regulares (no seguras)
- Stages
- Pipes
- Tasks

### Objeto Share:
- Creado por ACCOUNTADMIN (solo ACCOUNTADMIN puede crear shares)
- GRANT privilegios en objetos TO SHARE
- El Consumidor crea una base de datos FROM SHARE

### Proveedor vs Consumidor:
| | Proveedor | Consumidor |
|---|---|---|
| Crea share | Sí | No |
| Es dueño de los datos | Sí | No |
| Paga almacenamiento | Sí | No |
| Paga compute | No (el consumidor consulta) | Sí (su propio warehouse) |
| Puede modificar datos compartidos | Sí | No (solo lectura) |

### Regla clave: El Consumidor usa su PROPIO warehouse para consultar datos compartidos. El Proveedor no paga nada por las consultas del consumidor.

### Por qué esto importa + Casos de uso

**Escenario real — "Nuestro socio no tiene cuenta de Snowflake"**
Crea una Cuenta de Lector para ellos. TÚ (proveedor) pagas por TODO — almacenamiento + compute. La cuenta de lector es solo lectura y limitada. Usa esto solo cuando el socio no tiene cuenta de Snowflake.

**Escenario real — "Compartimos una vista pero el consumidor ve nuestra lógica SQL"**
Las vistas regulares exponen la definición SQL. Solución: usar vistas SEGURAS para TODOS los objetos compartidos. Las vistas seguras ocultan la definición SQL de los consumidores. Esto es REQUERIDO para shares.

**Escenario real — "Necesitamos compartir datos con nuestra oficina en Tokio pero nuestra cuenta está en US-West"**
Compartir directo entre regiones NO es posible. Solución: replicar tu base de datos a la región de Tokio primero (CREATE DATABASE ... AS REPLICA OF ...), luego crear un share en esa región.

---

### Mejores Prácticas — Compartir Datos
- Siempre usar vistas SEGURAS para compartir (requerido, oculta SQL)
- Solo ACCOUNTADMIN puede crear shares
- Para compartir entre regiones: replicar base de datos primero, luego crear share
- Cuentas de lector: usar SOLO cuando el consumidor no tiene cuenta Snowflake (pagas todo)
- Monitorear uso de datos compartidos con vistas de ACCOUNT_USAGE

**Trampa del examen**: "¿Quién paga compute en datos compartidos?" → Consumidor (usa su propio warehouse). SI VES "proveedor paga compute" o "warehouse del proveedor" para consultas compartidas → INCORRECTO porque el consumidor siempre usa su PROPIO warehouse.
**Trampa del examen**: "¿El proveedor actualiza datos, cuándo los ve el consumidor?" → Inmediatamente. SI VES "retraso", "refresh necesario" o "sincronización requerida" para visibilidad de datos compartidos → INCORRECTO porque datos compartidos = mismos datos subyacentes, cambios visibles instantáneamente.
**Trampa del examen**: "¿Quién crea el objeto Share?" → Solo ACCOUNTADMIN. SI VES "SYSADMIN", "SECURITYADMIN" o "USERADMIN" + "crear share" → INCORRECTO porque SOLO ACCOUNTADMIN puede crear objetos Share.
**Trampa del examen**: "¿Se puede compartir una vista regular?" → NO, debe ser Vista Segura. SI VES "vista regular" + "share" o "vista no segura" + "compartir datos" → INCORRECTO porque SOLO vistas/UDFs/MVs seguras pueden compartirse.


### Ejemplos de Preguntas de Escenario — Secure Data Sharing

**Escenario:** A logistics company (Provider) shares real-time shipment tracking data with a retail partner (Consumer). The retail partner's CFO asks: "How much are we being charged for storing the shared data?" What is the correct answer?
**Respuesta:** The Consumer pays zero for storage of shared data. The Provider owns and stores the data — storage costs are entirely the Provider's responsibility. The Consumer only pays for compute when they query the shared data using their own warehouse. Shared data involves zero data movement and zero storage duplication.

**Escenario:** A data engineering team creates a share containing a view that joins three internal tables. After the consumer creates a database from the share, they can see the SQL definition of the view and reverse-engineer the Provider's data model. How should this be fixed?
**Respuesta:** The view must be changed to a SECURE view (ALTER VIEW ... SET SECURE). Only secure views, secure UDFs, and secure materialized views can be shared. Secure views hide the SQL definition from consumers, preventing them from seeing the underlying logic or table structure. Regular (non-secure) views should never be used in shares.

**Escenario:** A Provider updates pricing data in a shared table at 2:00 PM. The Consumer runs a query at 2:01 PM. Will the Consumer see the updated prices, or is there a synchronization delay?
**Respuesta:** The Consumer will see the updated prices immediately. Secure Data Sharing provides real-time access to the Provider's underlying data — there is no copy, no sync process, and no delay. Changes made by the Provider are visible to the Consumer instantly because both are reading the same underlying micro-partitions.

**Escenario:** A SYSADMIN at a healthcare company tries to create a SHARE object to distribute anonymized patient statistics to research partners. The command fails. Why?
**Respuesta:** Only ACCOUNTADMIN can create SHARE objects in Snowflake. SYSADMIN, SECURITYADMIN, and other roles do not have the CREATE SHARE privilege. The SYSADMIN must ask the ACCOUNTADMIN to create the share, or the ACCOUNTADMIN role must be used directly.

---

---

## 5.3 CUENTAS DE LECTOR

### Qué son:
- Creadas POR el Proveedor PARA consumidores que NO tienen cuenta de Snowflake
- Cuenta gestionada — el Proveedor controla todo

### Datos clave:
- El Proveedor las crea (CREATE MANAGED ACCOUNT)
- **El Proveedor paga por todo** (almacenamiento + compute)
- Los usuarios de la cuenta de lector solo pueden consultar datos compartidos (solo lectura)
- No pueden crear sus propias bases de datos/tablas (funcionalidad limitada)
- Sin límite fijo en el número de Cuentas de Lector por Proveedor

**Trampa del examen**: "¿El consumidor no tiene cuenta Snowflake?" → Crear Cuenta de Lector. SI VES "sin cuenta Snowflake" + "compartir directo" o "Marketplace" → INCORRECTO porque sin cuenta SF, solo una Cuenta de Lector funciona.
**Trampa del examen**: "¿Quién paga compute de Cuenta de Lector?" → El PROVEEDOR. SI VES "consumidor paga" + "cuenta de lector" → INCORRECTO porque Cuenta de Lector = Proveedor paga TODO (almacenamiento + compute).
**Trampa del examen**: "¿Cuántas Cuentas de Lector puedes crear?" → Sin límite fijo. SI VES un número específico como "5", "10", "25" como límite máximo → INCORRECTO porque no hay límite fijo de Cuentas de Lector por Proveedor.


### Ejemplos de Preguntas de Escenario — Reader Accounts

**Escenario:** A weather data Provider wants to share forecast data with a small agricultural cooperative that does not have a Snowflake account and has no budget for one. The Provider's finance team asks who will pay for the cooperative's query compute costs. What is the answer?
**Respuesta:** The Provider pays for everything — both storage and compute — when using a Reader Account. Since the cooperative has no Snowflake account, a Reader Account (CREATE MANAGED ACCOUNT) is the only option. The Provider should budget for the cooperative's compute costs, as queries run on warehouses provisioned within the Reader Account but billed to the Provider.

**Escenario:** A consulting firm creates a Reader Account for a client to access shared benchmark data. The client's analyst wants to create their own tables within the Reader Account to store custom calculations. Can they do this?
**Respuesta:** No. Reader Accounts are limited to read-only access on shared data. Users in a Reader Account cannot create their own databases, tables, or other objects. If the client needs to store custom calculations, they must get their own full Snowflake account. Reader Accounts are intentionally restricted — they exist solely to query data shared by the Provider.

**Escenario:** A SaaS company shares usage analytics with 30 different enterprise clients, each without Snowflake accounts. Their architect asks if there is a limit to how many Reader Accounts they can create. What should they be told?
**Respuesta:** There is no hard limit on the number of Reader Accounts a Provider can create. The SaaS company can create Reader Accounts for all 30 clients. However, they should be aware that they (the Provider) will pay all compute and storage costs for every Reader Account, so cost monitoring is important at scale.

---

---

## 5.4 COMPARTIR DATOS Y RE-COMPARTIR

### Compartir Directo:
- Proveedor → Consumidor (uno-a-uno o uno-a-muchos)
- Ambos deben estar en el mismo proveedor de nube + región (a menos que se use replicación)
- Para entre regiones: replicar base de datos primero, luego compartir

### Re-compartir:
- El Consumidor puede re-compartir datos que recibió (si el Proveedor lo permite)
- Cadena de compartición

**Trampa del examen**: "¿Compartir directo funciona entre regiones?" → NO. Misma región + nube solamente. Entre regiones requiere replicación PRIMERO. SI VES "compartir directo" + "diferente región" o "entre nubes" → INCORRECTO porque compartir directo = misma región Y mismo proveedor de nube solamente.
**Trampa del examen**: "¿Cualquier consumidor puede re-compartir datos?" → Solo si el Proveedor lo permite explícitamente. No es automático. SI VES "consumidor re-comparte" + "por defecto" o "automáticamente" → INCORRECTO porque re-compartir requiere permiso explícito del Proveedor.
**Trampa del examen**: "¿Compartir directo = datos se copian al consumidor?" → INCORRECTO. Cero copia. El consumidor lee datos del Proveedor en su lugar. SI VES "datos copiados", "datos movidos" o "datos transferidos" + "compartir" → INCORRECTO porque compartir = cero copia, cero movimiento.


### Ejemplos de Preguntas de Escenario — Data Sharing & Resharing

**Escenario:** A pharmaceutical company in AWS US-East-1 wants to share clinical trial results directly with a research hospital in Azure West Europe. They attempt to create a direct share. Will this work?
**Respuesta:** No. Direct shares require both parties to be on the same cloud provider AND the same region. AWS US-East-1 and Azure West Europe differ in both cloud provider and region. The pharmaceutical company must first replicate the database to an account in Azure West Europe, then create a share from that replicated database.

**Escenario:** Company A shares market research data with Company B via Secure Data Sharing. Company B wants to reshare this data with Company C (a mutual business partner). Can Company B do this without any special permissions?
**Respuesta:** No. Resharing is not automatic. Company B can only reshare the data if Company A (the original Provider) explicitly grants permission to reshare. Without that permission, Company B cannot create a share of data they received from Company A. This prevents unauthorized distribution of proprietary data.

**Escenario:** A data Provider shares inventory data with 15 different retail partners, all within the same AWS US-West-2 region. One partner asks if the Provider had to create 15 separate copies of the data to serve all partners. What is the reality?
**Respuesta:** Zero copies were created. A single share can serve multiple consumers (one-to-many). All 15 retail partners read from the same underlying data in the Provider's storage. There is no data duplication, no data movement, and no additional storage cost for the Provider regardless of how many consumers access the share. Each consumer uses their own warehouse for compute.

---

---

## 5.5 SNOWFLAKE MARKETPLACE

### Qué es:
- Plataforma de descubrimiento y acceso para productos de datos
- Proveedores de datos de terceros listan sus datos
- Los consumidores navegan, solicitan acceso y usan datos
- Algunos listados son gratuitos, otros son pagos

### Tipos de Listados:

**Listados Públicos**:
- Visibles para todas las cuentas de Snowflake
- Cualquiera puede solicitar acceso
- Listados en Marketplace

**Listados Privados**:
- Visibles solo para cuentas específicas invitadas
- Compartición directa entre partes conocidas
- No descubribles públicamente

### Data Exchange (concepto más antiguo):
- Hub privado para grupo controlado de participantes
- El Proveedor controla quién puede unirse
- Los miembros pueden compartir datos dentro del exchange

**Trampa del examen**: "¿Marketplace vs Data Exchange?" → Marketplace = listados públicos/privados para descubrimiento amplio. Data Exchange = hub privado solo por invitación. SI VES "Data Exchange" + "público" o "cualquiera puede unirse" → INCORRECTO porque Data Exchange = privado, solo por invitación.
**Trampa del examen**: "¿Listado Privado vs Data Exchange?" → Listado Privado = en Marketplace pero visible solo para cuentas invitadas. Data Exchange = hub privado completamente separado. SI VES "Listado Privado" confundido con "Data Exchange" → INCORRECTO porque Listado Privado vive EN el Marketplace; Data Exchange es un hub separado.
**Trampa del examen**: "¿Listado gratuito de Marketplace = sin costo alguno?" → Sin costo de almacenamiento para consumidor (el Proveedor lo almacena), pero el consumidor aún paga compute para consultar. SI VES "listado gratuito" + "sin costo" o "completamente gratis" → INCORRECTO porque "gratuito" solo significa sin tarifa por datos — el consumidor aún paga compute.


### Ejemplos de Preguntas de Escenario — Snowflake Marketplace

**Escenario:** A global weather data company wants to make their historical climate dataset available to any Snowflake customer worldwide for discovery and purchase. Should they use a Public Listing, a Private Listing, or a Data Exchange?
**Respuesta:** A Public Listing on the Snowflake Marketplace. Public listings are visible to all Snowflake accounts and allow anyone to discover, request access, and use the data. This is the right choice for broad distribution to unknown potential customers. A Private Listing would limit visibility to invited accounts only, and a Data Exchange is a separate private hub — neither fits the goal of broad public discovery.

**Escenario:** A financial services consortium of five banks wants to share proprietary risk models only among themselves — no outside access. They need a controlled environment where only approved members can participate. What should they use?
**Respuesta:** A Data Exchange. Data Exchanges are private, invite-only hubs where the provider controls exactly who can join. This is ideal for a closed consortium where membership is restricted. A Marketplace public listing would expose the data to all Snowflake users, and a private listing still lives on the public Marketplace (just with restricted visibility). A Data Exchange is a completely separate, controlled environment.

**Escenario:** A consumer finds a "free" weather dataset on the Snowflake Marketplace and tells their manager it will cost the company nothing. Is this accurate?
**Respuesta:** Not entirely. "Free" on the Marketplace means there is no data licensing fee and no storage cost to the consumer (the Provider stores the data). However, the consumer still pays for compute — they must use their own warehouse to query the data. So while the data itself is free, querying it incurs standard Snowflake compute charges.

---

---

## 5.6 NATIVE APPS

### Qué son:
- Aplicaciones completas construidas sobre datos de Snowflake
- El Proveedor construye la app, el Consumidor la instala
- La app se ejecuta en la cuenta del Consumidor
- Los datos permanecen en la cuenta del Consumidor (privacidad)
- Pueden incluir: UI (Streamlit), procedimientos almacenados, UDFs, vistas

### Framework de Native App:
- El Proveedor crea un Application Package
- El paquete incluye: script de setup, contenido de datos, UI Streamlit, código
- El Consumidor instala y ejecuta la app
- El Proveedor puede actualizar la app (versionamiento)

**Trampa del examen**: "¿Native App se ejecuta en la cuenta del Proveedor?" → INCORRECTO. Se ejecuta en la cuenta del Consumidor. Los datos permanecen privados para el consumidor. SI VES "cuenta del proveedor" + "Native App se ejecuta" → INCORRECTO porque las Native Apps SIEMPRE se ejecutan en la cuenta del Consumidor.
**Trampa del examen**: "¿Native App vs Compartir Datos de forma Segura?" → Compartir = acceso solo lectura a datos. Native App = aplicación completa con UI + lógica + código. SI VES "compartir" cuando la pregunta describe UI, procedimientos almacenados, o lógica de aplicación → INCORRECTO porque eso es una Native App, no compartir datos simple.
**Trampa del examen**: "¿Quién paga compute para Native App?" → Consumidor (se ejecuta en su cuenta con su compute). SI VES "proveedor paga compute" + "Native App" → INCORRECTO porque la app se ejecuta en la cuenta del Consumidor, así que el Consumidor paga todo el compute.


### Ejemplos de Preguntas de Escenario — Native Apps

**Escenario:** An analytics vendor builds a churn-prediction application with a Streamlit dashboard, stored procedures, and UDFs. They want to distribute it to customers so each customer can run it on their own data without exposing that data to the vendor. What Snowflake feature should they use?
**Respuesta:** A Native App. The vendor creates an Application Package containing the Streamlit UI, stored procedures, and UDFs. Each customer installs the app in their own Snowflake account. The app runs inside the customer's account on the customer's data — the vendor never sees the customer's raw data. This preserves data privacy while distributing full application functionality.

**Escenario:** A consumer installs a Native App from a Provider. The consumer's finance team wants to know: does the Provider charge us for the compute used to run this app? Where does the app actually execute?
**Respuesta:** The Native App runs entirely in the Consumer's account, using the Consumer's compute resources (warehouses). The Consumer pays for all compute. The Provider does not pay for the Consumer's execution costs. The Provider may charge a licensing or subscription fee for the app itself (separate from Snowflake compute costs), but Snowflake compute is always the Consumer's responsibility since the app runs in their environment.

**Escenario:** A data Provider currently shares read-only tables with consumers via Secure Data Sharing. A consumer asks for interactive dashboards and custom scoring logic on the shared data. Can this be done with Secure Data Sharing alone?
**Respuesta:** No. Secure Data Sharing provides read-only data access — it cannot deliver UI, stored procedures, or application logic. The Provider should build a Native App using the Native App Framework. The Application Package can include a Streamlit UI for dashboards, stored procedures for scoring logic, and UDFs for calculations. The consumer installs it and gets the full interactive experience in their own account.

---

---

## 5.7 CLONACIÓN (Zero-Copy)

### Cómo funciona:
- CREATE TABLE/DATABASE/SCHEMA ... CLONE fuente
- Operación solo de metadatos (instantánea)
- Sin almacenamiento adicional hasta que se modifiquen datos
- El clon es independiente — los cambios no afectan al original

### Qué se puede clonar:
- Bases de datos
- Esquemas
- Tablas (permanentes, transitorias, temporales)
- Streams
- Tasks
- Stages (solo stages nombrados, no stages de usuario/tabla)
- Formatos de archivo
- Secuencias

### Qué NO se puede clonar:
- Tablas externas
- Stages internos (de usuario/tabla)

### Comportamiento del clon con privilegios:
- Al clonar una base de datos/esquema: los objetos hijos heredan los MISMOS privilegios de la fuente
- Al clonar una sola tabla: los privilegios NO se copian

### Clon + Time Travel:
- El clon captura datos en el punto ACTUAL en el tiempo (o momento especificado)
- El clon NO incluye el historial de Time Travel del original
- Se puede clonar usando Time Travel: CREATE TABLE clon CLONE fuente AT(TIMESTAMP => '...')

**Trampa del examen**: "¿Costo de almacenamiento del nuevo clon?" → Cero hasta modificaciones. SI VES "duplica almacenamiento", "costo de copia completa", o "mismo almacenamiento que el original" + "clon" → INCORRECTO porque clon = cero-copia, sin almacenamiento extra hasta que se modifiquen datos.
**Trampa del examen**: "¿El clon incluye historial de Time Travel?" → NO. SI VES "historial de Time Travel" + "el clon hereda" o "el clon incluye" → INCORRECTO porque el clon empieza fresco SIN historial de Time Travel de la fuente.
**Trampa del examen**: "¿Clonar en un punto pasado?" → Sí, usando cláusula AT/BEFORE. SI VES "no se pueden clonar datos históricos" o "el clon solo funciona con estado actual" → INCORRECTO porque SÍ PUEDES clonar en un punto pasado vía CLONE fuente AT(TIMESTAMP => '...').
**Trampa del examen**: "¿El clon de base de datos incluye privilegios?" → SÍ (objetos hijos mantienen privilegios). SI VES "sin privilegios" + "clon de base de datos" o "clon de esquema" → INCORRECTO porque clones de BD/esquema SÍ mantienen privilegios hijos. Solo clones de TABLA individual pierden privilegios.


### Ejemplos de Preguntas de Escenario — Cloning

**Escenario:** A DevOps team needs to create an exact copy of their 2TB production database for QA testing. They are concerned about doubling their storage costs and the time it will take to copy all the data. How should they proceed?
**Respuesta:** Use zero-copy cloning: CREATE DATABASE qa_db CLONE production_db. This is a metadata-only operation that completes in seconds regardless of database size. The clone initially points to the same underlying micro-partitions, so there is zero additional storage cost at creation. Storage costs only increase as the QA team modifies data in the clone — and only for the changed micro-partitions, not the entire database.

**Escenario:** A DBA clones an entire production database for a development team. The dev team asks whether the table-level grants (SELECT, INSERT) that exist in production will also exist in the cloned database. What is the answer?
**Respuesta:** Yes. When cloning a database or schema, child objects inherit the same privileges from the source. So all table-level grants (SELECT, INSERT, etc.) in the production database will be present in the cloned database. This is different from cloning a single table directly — in that case, privileges are NOT copied.

**Escenario:** A data engineer clones a table and then discovers they need the data as it existed two days ago, not at the current point in time. They also wonder if the clone contains the original table's Time Travel history. What should they know?
**Respuesta:** Clones do NOT include the Time Travel history of the source table — the clone starts fresh with its own Time Travel timeline from the moment of creation. However, the engineer can create a new clone at a past point in time using: CREATE TABLE my_clone CLONE source_table AT(TIMESTAMP => '2024-01-15 10:00:00'). This combines cloning with Time Travel to capture the table's state at the specified timestamp.

**Escenario:** A team tries to clone an external table and a table stage as part of their development environment setup. Both operations fail. Why?
**Respuesta:** External tables and internal stages (user stages and table stages) cannot be cloned. These are among the few object types excluded from cloning. Named stages CAN be cloned, but user/table stages cannot. For external tables, the team would need to recreate the external table definition manually in the target environment.

---

---

## 5.8 TIME TRAVEL (MUY PROBADO)

### Qué es:
- Acceder a datos históricos (antes de cambios)
- Consultar datos como estaban en un punto pasado en el tiempo
- Recuperar objetos eliminados

### Períodos de retención:
| Edición | Tablas Permanentes | Transitorias/Temporales |
|---|---|---|
| Standard | 0-1 día | 0-1 día |
| Enterprise+ | 0-90 días | 0-1 día |

### Parámetro: DATA_RETENTION_TIME_IN_DAYS
- Se configura a nivel de cuenta, base de datos, esquema o tabla
- Configurarlo a 0 = deshabilita Time Travel para ese objeto

### Consultas de Time Travel:
- `AT(TIMESTAMP => 'timestamp')` → datos en momento exacto
- `AT(OFFSET => -60*5)` → datos hace 5 minutos (segundos)
- `AT(STATEMENT => 'query_id')` → datos antes de una consulta específica
- `BEFORE(STATEMENT => 'query_id')` → datos antes de que la consulta se ejecutara

### Recuperar objetos eliminados:
- UNDROP TABLE nombre_tabla
- UNDROP SCHEMA nombre_esquema
- UNDROP DATABASE nombre_base_datos
- Debe ser dentro del período de retención de Time Travel

### Mejores Prácticas — Protección de Datos
- Configurar DATA_RETENTION_TIME_IN_DAYS = 90 para tablas críticas de producción (Enterprise+)
- Configurar DATA_RETENTION_TIME_IN_DAYS = 0 para datos de staging/temp (ahorrar almacenamiento)
- Usar UNDROP inmediatamente después de eliminaciones accidentales — es la recuperación más rápida
- Clonar antes de operaciones riesgosas: CREATE TABLE backup CLONE producción
- Fail-safe es solo para soporte de Snowflake — planifica la recuperación alrededor de Time Travel, no Fail-safe

**Trampa del examen**: "¿Consultar datos de hace 5 minutos?" → AT(OFFSET => -60*5). SI VES "TIMESTAMP" cuando la pregunta dice "hace X minutos" → trampa. Offset usa SEGUNDOS negativos, no timestamp.
**Trampa del examen**: "¿UNDROP TABLE funciona dentro de...?" → Período de retención de Time Travel. SI VES "Fail-safe" + "UNDROP" → INCORRECTO porque UNDROP solo funciona durante Time Travel. Fail-safe requiere soporte de Snowflake — no puedes UNDROP desde Fail-safe.
**Trampa del examen**: "¿Configurar retención a 0?" → Deshabilita Time Travel. SI VES "DATA_RETENTION_TIME_IN_DAYS = 0" + "aún tiene Time Travel" o "aún puede UNDROP" → INCORRECTO porque 0 = completamente deshabilitado, sin acceso histórico en absoluto.
**Trampa del examen**: "¿Time Travel máximo para tabla transitoria?" → 1 día (incluso en Enterprise). SI VES "90 días" + "transitoria" o "temporal" → INCORRECTO porque tablas transitorias/temporales tienen máximo de 1 día independientemente de la edición.


### Ejemplos de Preguntas de Escenario — Time Travel

**Escenario:** An analyst on an Enterprise edition account accidentally runs a DELETE statement that removes all records from a critical sales table. They realize the mistake 30 minutes later. The table has DATA_RETENTION_TIME_IN_DAYS set to 90. How can they recover the data?
**Respuesta:** Since only 30 minutes have passed and the table has 90-day Time Travel retention on Enterprise edition, they have multiple recovery options: (1) Query the data before the delete using SELECT * FROM sales_table BEFORE(STATEMENT => 'delete_query_id'), (2) Use UNDROP if the table was dropped, or (3) Create a clone at the point before the delete: CREATE TABLE sales_recovered CLONE sales_table BEFORE(STATEMENT => 'delete_query_id'). The BEFORE clause captures data just before the DELETE executed.

**Escenario:** A company on Enterprise edition creates a transient staging table for ETL processing. The data architect sets DATA_RETENTION_TIME_IN_DAYS = 90 on this table. Will this work?
**Respuesta:** No. Transient tables have a maximum Time Travel retention of 1 day, regardless of the Snowflake edition. Even though Enterprise edition supports up to 90 days for permanent tables, transient and temporary tables are capped at 1 day. The ALTER TABLE command will either fail or be silently capped to 1 day. If 90-day Time Travel is needed, the table must be created as a permanent table.

**Escenario:** A database administrator sets DATA_RETENTION_TIME_IN_DAYS = 0 on a test database to save storage. Later, a developer accidentally drops a table in that database and tries to run UNDROP TABLE. What happens?
**Respuesta:** The UNDROP will fail. Setting DATA_RETENTION_TIME_IN_DAYS = 0 completely disables Time Travel for the object. With Time Travel disabled, there is no historical data retained — no AT/BEFORE queries, no UNDROP capability. The table may still be recoverable via Fail-safe (if it was a permanent table), but only by contacting Snowflake support. To prevent this, critical tables should always have a non-zero retention period.

**Escenario:** A data engineer needs to see what a table looked like exactly 10 minutes before a specific UPDATE query ran (query ID: '01a2b3c4-...'). Should they use AT or BEFORE?
**Respuesta:** They should use BEFORE(STATEMENT => '01a2b3c4-...'). The BEFORE clause returns data as it existed immediately before the specified statement executed. The AT clause would return data at the moment the statement ran, which would include the effects of the UPDATE. If they need data 10 minutes before the query (not just immediately before), they should use AT(OFFSET => -600) where -600 is 10 minutes in negative seconds, or AT(TIMESTAMP => 'specific_timestamp') with the exact time 10 minutes prior.

---

---

## 5.9 FAIL-SAFE

### Qué es:
- Período de 7 días DESPUÉS de que Time Travel expire
- Recuperación ante desastres gestionada por Snowflake
- TÚ no puedes acceder a datos de Fail-safe directamente
- Solo el soporte de Snowflake puede recuperar datos de Fail-safe

### Qué tablas tienen Fail-safe:
- Tablas permanentes → SÍ (7 días)
- Tablas transitorias → NO
- Tablas temporales → NO

### Fail-safe NO es:
- Un respaldo que tú controlas
- Algo que puedes consultar
- Disponible para tablas transitorias/temporales

### Línea de tiempo de costo de almacenamiento:
```
Datos Activos → Datos Time Travel → Datos Fail-safe → Purgados
(actuales)      (1-90 días)          (7 días)           (perdidos para siempre)
```

**Trampa del examen**: "¿Fail-safe para tablas transitorias?" → NO hay Fail-safe. SI VES "Fail-safe" + "transitoria" o "temporal" → INCORRECTO porque SOLO las tablas permanentes tienen Fail-safe. Transitorias y temporales = cero Fail-safe.
**Trampa del examen**: "¿Puedes consultar datos de Fail-safe?" → NO (solo soporte de Snowflake). SI VES "SELECT", "consultar" o "acceder directamente" + "Fail-safe" → INCORRECTO porque NO PUEDES consultar datos de Fail-safe. Solo el soporte de Snowflake puede recuperarlos.
**Trampa del examen**: "¿Duración de Fail-safe?" → 7 días (siempre, todas las ediciones). SI VES "90 días", "varía por edición" o "configurable" + "Fail-safe" → INCORRECTO porque Fail-safe es SIEMPRE exactamente 7 días, no configurable.
**Trampa del examen**: "¿Datos eliminados hace 10 días, 1 día de Time Travel?" → En Fail-safe (contactar Snowflake), o si pasaron más de 8 días totales → perdidos permanentemente. SI VES "UNDROP" + "pasado retención de Time Travel" → INCORRECTO porque UNDROP solo funciona dentro de Time Travel. Después de eso, solo soporte de Snowflake vía Fail-safe.


### Ejemplos de Preguntas de Escenario — Fail-Safe

**Escenario:** A company uses transient tables for all their staging data to save on storage costs. After a critical ETL failure corrupts staging data 3 days ago (past the 1-day Time Travel window), the team asks if Fail-safe can recover the data. What is the answer?
**Respuesta:** No. Transient tables do NOT have Fail-safe protection — only permanent tables do. With a 1-day Time Travel window already expired, the data is permanently lost. There is no recovery path — not through UNDROP, not through Time Travel queries, and not through Fail-safe. For critical staging data that may need recovery beyond 1 day, the team should use permanent tables instead of transient tables.

**Escenario:** A DBA accidentally drops a permanent production table. Time Travel retention was set to 1 day, and the mistake is discovered 5 days later. The DBA tries UNDROP TABLE but it fails. Is the data gone forever?
**Respuesta:** Not necessarily. UNDROP only works within the Time Travel retention period (1 day in this case), so it correctly failed. However, since the table is a permanent table, it has 7 days of Fail-safe protection that begins after Time Travel expires. Day 5 falls within the Fail-safe window (Time Travel day 1 + Fail-safe days 2-8). The DBA must contact Snowflake support to request data recovery from Fail-safe. Note: recovery is not guaranteed and is a best-effort process performed by Snowflake.

**Escenario:** A finance team asks their architect to explain the total storage cost timeline for a permanent table on Enterprise edition with 90-day Time Travel. How long is data retained in total before permanent deletion?
**Respuesta:** The total data retention timeline is: Active data (current) → Time Travel (up to 90 days after modification/deletion) → Fail-safe (7 additional days after Time Travel expires) → permanently purged. So the maximum total retention before permanent deletion is 90 + 7 = 97 days. During Time Travel, users can query historical data and use UNDROP. During Fail-safe, only Snowflake support can recover data. After both periods expire, data is gone forever.

**Escenario:** A manager asks: "Can we write a script that queries our Fail-safe data periodically as an extra backup check?" Is this possible?
**Respuesta:** No. Fail-safe data cannot be accessed, queried, or interacted with by users in any way. There is no SQL command, API, or interface to read Fail-safe data. It is entirely managed by Snowflake internally and can only be recovered by contacting Snowflake support in a disaster recovery scenario. For proactive backup strategies, rely on Time Travel (which you CAN query) and cloning.

---

---

## 5.10 DATA CLEAN ROOMS

### Qué son:
- Entorno seguro para análisis de datos multi-parte
- Cada parte mantiene sus datos privados
- Ejecuta consultas/análisis aprobados sin exponer datos crudos
- Caso de uso: overlap publicitario, coincidencia de clientes

**Trampa del examen**: "¿Data Clean Room = datos compartidos entre las partes?" → INCORRECTO. Los datos crudos permanecen privados. Solo resultados agregados aprobados son visibles. SI VES "datos crudos compartidos", "las partes ven los datos de la otra" o "datos intercambiados" + "Clean Room" → INCORRECTO porque los datos crudos NUNCA salen de cada parte.
**Trampa del examen**: "¿Data Clean Room vs Compartir Datos de forma Segura?" → Compartir = una parte da acceso a datos. Clean Room = análisis multi-parte donde NINGUNA parte ve los datos crudos de la otra. SI VES "Compartir Datos" cuando el escenario describe análisis multi-parte privado → INCORRECTO porque eso es un Clean Room, no compartir regular.


### Ejemplos de Preguntas de Escenario — Data Clean Rooms

**Escenario:** Two competing retail brands want to measure how many customers they share in common to evaluate a joint loyalty program. Neither brand is willing to reveal their full customer list to the other. What Snowflake feature should they use?
**Respuesta:** A Data Clean Room. Each brand keeps their customer data private within their own Snowflake account. The Clean Room allows them to run approved aggregate queries — such as counting overlapping customers — without either party seeing the other's raw customer records. Only the agreed-upon aggregate results (e.g., "12,450 customers overlap") are visible, not the underlying individual records.

**Escenario:** An advertising agency wants to match their campaign audience data against a media company's viewer data to measure ad effectiveness. The media company's legal team insists that no raw viewer data can leave their environment. Can this be done with regular Secure Data Sharing?
**Respuesta:** No. Secure Data Sharing would give the advertising agency direct read access to the media company's data, which violates their legal requirement. A Data Clean Room is the correct solution. In a Clean Room, both parties contribute their data but neither sees the other's raw records. Only pre-approved analyses (like audience overlap counts or aggregate conversion metrics) produce results — the raw viewer data never leaves the media company's control.

**Escenario:** A pharmaceutical company and a hospital network want to jointly analyze patient outcomes for a drug trial. Regulations require that individual patient records are never exposed to the pharmaceutical company. How does a Data Clean Room help compared to just sharing the data?
**Respuesta:** In regular Secure Data Sharing, the pharmaceutical company would gain read access to the hospital's patient data — violating privacy regulations. A Data Clean Room ensures that the hospital's raw patient records are never visible to the pharmaceutical company. Both parties load their respective data, and only approved aggregate analyses (e.g., average recovery time, outcome distributions by age group) are computed and shared. Individual patient-level data remains private to each party throughout the process.

---

---

## REPASO RÁPIDO — Dominio 5

1. Compartir datos = sin copia de datos, acceso en tiempo real, cero costo de movimiento
2. El Proveedor paga almacenamiento. El Consumidor paga compute (su propio warehouse).
3. Solo ACCOUNTADMIN crea Shares
4. Solo Vistas Seguras pueden compartirse (no vistas regulares)
5. Cuenta de Lector = para consumidores sin Snowflake. El Proveedor paga todo.
6. Compartir entre regiones requiere replicación primero
7. Failover = Solo Business Critical+
8. Marketplace: listados públicos (cualquiera) vs listados privados (solo invitados)
9. Native Apps = aplicaciones completas, se ejecutan en la cuenta del consumidor
10. Clon = cero-copia, instantáneo, sin costo de almacenamiento hasta modificación
11. El clon NO incluye historial de Time Travel
12. Time Travel: 1 día Standard, hasta 90 días Enterprise+ (tablas permanentes)
13. Tablas transitorias/temporales: máximo 1 día de Time Travel independientemente de la edición
14. UNDROP = recuperar dentro del período de Time Travel
15. Fail-safe: 7 días, solo tablas permanentes, gestionado por Snowflake (no se accede directamente)
16. DATA_RETENTION_TIME_IN_DAYS = 0 deshabilita Time Travel
17. El Consumidor ve actualizaciones del Proveedor inmediatamente
18. Sin límite de Cuentas de Lector por Proveedor

---

## PARES CONFUSOS — Dominio 5

| Preguntan sobre... | La respuesta es... | NO es... |
|---|---|---|
| Quién paga consultas de datos compartidos | Consumidor (su propio warehouse) | Proveedor |
| Quién paga Cuenta de Lector | Proveedor (todo) | Consumidor |
| Compartir una vista | Debe ser Vista Segura | Vista regular funciona |
| Quién crea Share | ACCOUNTADMIN | SYSADMIN |
| Compartir entre regiones necesita | Replicación primero | Compartir directo |
| Fail-safe para transitoria | NINGUNO | 7 días |
| Acceso a Fail-safe | Solo soporte de Snowflake | Consulta directa |
| Time Travel máx (transitoria) | 1 día | 90 días |
| Time Travel máx (permanente, Enterprise) | 90 días | 1 día |
| Costo de almacenamiento del clon | Cero hasta modificación | Costo de copia completa |
| Historial Time Travel del clon | NO incluido | Incluido |
| Listado público de Marketplace | Cualquiera puede ver | Solo invitados |
| Listado privado de Marketplace | Solo cuentas invitadas | Público |
| Edición para failover | Business Critical+ | Enterprise |
| UNDROP funciona durante | Período de Time Travel | Fail-safe |
| Base de datos secundaria | Solo lectura | Lectura-escritura |

---

## RESUMEN AMIGABLE — Dominio 5

### ÁRBOLES DE DECISIÓN POR ESCENARIO
Cuando leas una pregunta, encuentra el patrón:

**"Una farmacéutica quiere compartir resultados de ensayos clínicos con un hospital socio que también usa Snowflake..."**
→ Compartir Directo (el Proveedor crea SHARE, el Consumidor crea base de datos FROM SHARE)
→ Sin datos copiados, acceso en tiempo real, cero costo de almacenamiento por compartir

**"Una startup quiere compartir datos con un pequeño proveedor que NO tiene cuenta Snowflake..."**
→ Cuenta de Lector (el Proveedor la crea, el Proveedor paga TODO)
→ El Consumidor obtiene acceso limitado de solo lectura

**"¿Quién paga cuando un consumidor consulta datos compartidos?"**
→ El CONSUMIDOR paga (usa su propio warehouse)
→ El Proveedor no paga NADA por las consultas del consumidor

**"¿Quién paga cuando un usuario de Cuenta de Lector consulta datos compartidos?"**
→ El PROVEEDOR paga (Cuenta de Lector = el Proveedor paga todo — compute + almacenamiento)

**"Una empresa global en AWS US-West necesita compartir datos con su equipo en Azure Europa..."**
→ Paso 1: Replicar la base de datos a la otra región/nube PRIMERO
→ Paso 2: Luego crear un Share en esa región
→ No se puede compartir directo entre regiones sin replicación

**"La región primaria de una empresa se cae. ¿Cómo siguen funcionando?"**
→ Failover: promover base de datos/cuenta secundaria a primaria (Business Critical+)
→ NO es solo replicación (replicación copia datos, failover cambia la activa)

**"El proveedor actualiza una tabla compartida. ¿Cuándo ve el cambio el consumidor?"**
→ INMEDIATAMENTE (sin retraso, sin refresh necesario — son los mismos datos)

**"Un cliente quiere compartir una vista con otra cuenta..."**
→ Debe ser una VISTA SEGURA (vistas regulares NO pueden compartirse)
→ También funciona: UDFs Seguras, Vistas Materializadas Seguras

**"Un proveedor de datos quiere listar sus datos climáticos para que cualquier cliente de Snowflake los descubra..."**
→ Listado Público de Marketplace (visible para todas las cuentas de Snowflake)

**"Dos bancos competidores quieren encontrar overlap de clientes sin revelar sus listas completas..."**
→ Data Clean Room (análisis multi-parte, datos crudos permanecen privados)

**"Un proveedor de software quiere distribuir una app de analítica que se ejecute dentro de la cuenta Snowflake del cliente..."**
→ Native App (el Proveedor construye Application Package, el Consumidor lo instala)
→ La app se ejecuta en la cuenta del Consumidor, los datos permanecen privados

**"Un equipo necesita crear una copia de producción para testing, sin duplicar costos de almacenamiento..."**
→ Clon (CREATE ... CLONE — cero-copia, instantáneo, sin almacenamiento extra hasta cambios)

**"¿Un clon incluye el historial de Time Travel de la tabla original?"**
→ NO. El clon empieza fresco. Sin instantáneas históricas de la fuente.

**"Un desarrollador accidentalmente eliminó una tabla hace 2 horas..."**
→ UNDROP TABLE (dentro del período de retención de Time Travel)
→ Si pasó Time Travel → podría estar en Fail-safe (contactar soporte de Snowflake)

**"¿Se pueden consultar datos de Fail-safe directamente?"**
→ NO. Solo el soporte de Snowflake puede recuperar datos de Fail-safe. No puedes acceder tú mismo.

**"Una tabla transitoria fue eliminada. ¿Fail-safe puede recuperarla?"**
→ NO. Tablas transitorias y temporales NO tienen Fail-safe.

**"Una cuenta Enterprise quiere 90 días de Time Travel en una tabla transitoria..."**
→ IMPOSIBLE. Tablas transitorias/temporales tienen máximo 1 día independientemente de la edición.

**"Un consumidor recibe un share y quiere modificar los datos que recibió..."**
→ NO PUEDE modificar datos compartidos directamente (solo lectura)
→ Debe CREATE TABLE ... AS SELECT de la vista/tabla compartida para obtener una copia local propia

**"Un cliente clona una base de datos completa. ¿Las tablas hijas mantienen sus privilegios?"**
→ SÍ. Al clonar una BASE DE DATOS o ESQUEMA, los objetos hijos heredan privilegios de la fuente.
→ Pero clonar una sola TABLA → los privilegios NO se copian.

**"Un cliente quiere clonar una tabla como existía hace 3 días..."**
→ CREATE TABLE nombre_clon CLONE fuente AT(TIMESTAMP => '2024-01-01 12:00:00')
→ Combina Clon + Time Travel en un solo comando

**"Un cliente quiere saber el costo total de almacenamiento de una tabla incluyendo Time Travel y Fail-safe..."**
→ TABLE_STORAGE_METRICS (ACCOUNT_USAGE)
→ Muestra: bytes activos + bytes time travel + bytes fail-safe

**"Un proveedor quiere compartir datos con 50 cuentas Snowflake diferentes..."**
→ Un Share puede tener múltiples consumidores (uno-a-muchos)
→ O usar listado de Marketplace para distribución más amplia

**"Un consumidor re-comparte datos que recibió de un proveedor a un tercero..."**
→ Re-compartir es posible SI el proveedor lo permite
→ Crea una cadena de compartición

**"Un cliente pregunta: ¿qué objetos NO se pueden clonar?"**
→ Tablas externas y stages internos (de usuario/tabla) NO se pueden clonar
→ Stages nombrados SÍ se pueden clonar

**"La base de datos secundaria de un cliente no se ha refrescado en 48 horas. ¿Los datos están actualizados?"**
→ NO. Las bases de datos secundarias deben refrescarse explícitamente para sincronizar.
→ No se auto-refrescan (a diferencia de las Tablas Dinámicas)

**"Un proveedor construye una Native App que incluye una UI Streamlit y procedimientos almacenados..."**
→ Todo empaquetado en un Application Package
→ El Consumidor instala → la app se ejecuta en la cuenta del Consumidor
→ El Proveedor puede enviar actualizaciones (versionamiento)

**"Un cliente quiere consultar datos exactamente como estaban antes de que se ejecutara una sentencia DELETE específica..."**
→ BEFORE(STATEMENT => 'query_id')
→ NO AT (AT da datos en el momento, BEFORE da datos justo antes de la sentencia)

**"Un cliente configura DATA_RETENTION_TIME_IN_DAYS = 0 en una tabla. ¿Qué pasa?"**
→ Time Travel se DESHABILITA para esa tabla
→ Sin UNDROP, sin consultas AT/BEFORE, sin acceso histórico
→ Fail-safe aún aplica (si es tabla permanente)

---

### MNEMOTÉCNICOS PARA RECORDAR

**Facturación de compartir = "El Proveedor Almacena, el Consumidor Computa"**
- El Proveedor paga almacenamiento (es dueño de los datos)
- El Consumidor paga compute (ejecuta consultas con su warehouse)
- EXCEPCIÓN: Cuenta de Lector → el Proveedor paga AMBOS

**Creación de share = "Solo el Jefe"**
- Solo ACCOUNTADMIN puede crear objetos Share
- NO SYSADMIN, NO SECURITYADMIN

**Qué se puede compartir = "Solo Seguro" → tablas + vistas/UDFs/MVs seguras**
- Vistas regulares → NO
- Stages, Pipes, Tasks → NO

**Retención de Time Travel = regla "1-90-1"**
- Edición Standard: máximo 1 día (todos los tipos de tabla)
- Enterprise+: hasta 90 días (solo tablas permanentes)
- Transitorias/Temporales: máximo 1 día (CUALQUIER edición)

**Ciclo de vida de datos = "A-T-F-G" → "Activos, Travel, Failsafe, Gone"**
- Datos **A**ctivos → actuales
- **T**ime Travel → 1-90 días (puedes consultar/UNDROP)
- **F**ail-safe → 7 días (solo soporte de Snowflake, solo tablas permanentes)
- **G**one → eliminados permanentemente

**Clon = "Copia el Puntero, No los Datos"**
- Instantáneo, cero costo de almacenamiento
- Independiente después de creación
- Sin historial de Time Travel de la fuente

**Edición de failover = "BC+" (Business Critical y superior)**
- Replicación = cualquier edición
- Failover = solo BC+

**Marketplace = "Público vs Privado"**
- Listado público → todos lo ven
- Listado privado → solo por invitación

---

### TRAMPAS PRINCIPALES — Dominio 5

1. **"El consumidor paga almacenamiento de datos compartidos"** → INCORRECTO. El Proveedor paga almacenamiento. El Consumidor paga compute.
2. **"Cuenta de Lector: el consumidor paga"** → INCORRECTO. El Proveedor paga TODO para Cuentas de Lector.
3. **"SYSADMIN puede crear Shares"** → INCORRECTO. Solo ACCOUNTADMIN.
4. **"Las vistas regulares se pueden compartir"** → INCORRECTO. Deben ser Vistas Seguras.
5. **"Compartir directo funciona entre regiones"** → INCORRECTO. Se necesita replicación primero.
6. **"Las actualizaciones del proveedor se retrasan para consumidores"** → INCORRECTO. Visibilidad inmediata.
7. **"Clonar duplica almacenamiento"** → INCORRECTO. Cero costo hasta que los datos se modifican.
8. **"El clon incluye historial de Time Travel"** → INCORRECTO. El clon empieza fresco.
9. **"Las tablas transitorias tienen Fail-safe"** → INCORRECTO. Sin Fail-safe (solo tablas permanentes).
10. **"Puedes consultar datos de Fail-safe"** → INCORRECTO. Solo soporte de Snowflake.
11. **"Tabla transitoria + Enterprise = 90 días de Time Travel"** → INCORRECTO. Máximo 1 día independientemente.
12. **"Failover funciona en Standard"** → INCORRECTO. Solo Business Critical+.

---

### ATAJOS DE PATRONES — "Si ves ___, la respuesta es ___"

| Si la pregunta menciona... | La respuesta casi siempre es... |
|---|---|
| "compartir datos, sin copia" | Compartir Datos de forma Segura |
| "consumidor no tiene cuenta SF" | Cuenta de Lector |
| "quién paga compute de datos compartidos" | Consumidor (su propio warehouse) |
| "quién paga Cuenta de Lector" | Proveedor (todo) |
| "quién crea objeto Share" | Solo ACCOUNTADMIN |
| "compartir una vista" | Debe ser Vista Segura |
| "compartir entre regiones" | Replicar primero, luego compartir |
| "región primaria caída" | Failover (BC+) |
| "cero copia, instantáneo" | Clon |
| "recuperar tabla eliminada" | UNDROP (dentro de Time Travel) |
| "7 días después de Time Travel" | Fail-safe |
| "solo lectura + no puede modificar" | Datos compartidos / BD secundaria |
| "proveedor de datos + descubrimiento" | Marketplace |
| "análisis multi-parte privado" | Data Clean Room |
| "app se ejecuta en cuenta del consumidor" | Native App |
| "no se puede clonar" | Tablas externas, stages de usuario/tabla |

---

## CONSEJOS PARA EL DÍA DEL EXAMEN — Dominio 5 (10% = ~10 preguntas)

**Antes de estudiar este dominio:**
- Flashcards de quién paga qué en compartir datos (Proveedor vs Consumidor)
- Memoriza: solo ACCOUNTADMIN crea Shares, solo Vistas Seguras pueden compartirse
- Conoce la regla "1-90-1" de Time Travel + ciclo de vida de Fail-safe

**Durante el examen — Preguntas del Dominio 5:**
- Si mencionan "quién paga" → Consumidor paga compute, Proveedor paga almacenamiento (excepto Cuentas de Lector)
- Si mencionan "entre regiones" → replicar PRIMERO, luego compartir
- Si mencionan "sin cuenta Snowflake" → Cuenta de Lector
- Si mencionan "clon" + "almacenamiento" → cero hasta modificación
- Si mencionan "Fail-safe" → 7 días, solo permanentes, solo soporte de Snowflake
- Si mencionan "transitoria" + "Time Travel" → máximo 1 día

---

## FLASHCARDS — Dominio 5

**P:** ¿Cómo funciona Compartir Datos de forma Segura?
**R:** El Proveedor comparte datos, el Consumidor accede en tiempo real. Sin copia. El Consumidor usa su propio warehouse (paga compute). Solo Vistas Seguras.

**P:** ¿Quién paga qué en data sharing?
**R:** Proveedor paga almacenamiento. Consumidor paga compute (su warehouse). Excepción: Cuenta de Lector = Proveedor paga todo.

**P:** ¿Qué es una Cuenta de Lector?
**R:** Cuenta creada por el Proveedor para consumidores sin Snowflake. El Proveedor paga todo. Solo lectura, funcionalidad limitada.

**P:** ¿Cómo compartir datos entre regiones?
**R:** Replicar la base de datos a la otra región primero, luego crear share allí. No se puede compartir directo entre regiones.

**P:** ¿Cuál es la regla de Time Travel?
**R:** Standard: máx 1 día. Enterprise+: hasta 90 días para tablas permanentes. Transitorias/temporales: siempre máx 1 día.

**P:** ¿Qué es Fail-safe?
**R:** 7 días después de Time Travel. Solo tablas permanentes. Solo soporte de Snowflake puede recuperar. No consultable.

**P:** ¿Cómo funciona la clonación?
**R:** Cero-copia (solo metadatos). Instantáneo. Sin almacenamiento extra hasta modificar. Sin Time Travel de la fuente. Independiente.

**P:** ¿Qué es una Native App?
**R:** Aplicación completa (UI + código) que se ejecuta en la cuenta del consumidor. El proveedor construye el Application Package, el consumidor instala.

---

## EXPLÍCALO COMO SI TUVIERA 5 AÑOS — Dominio 5

**Compartir datos**: Le dejas a tu amigo mirar tu libro, pero no le das una copia. Si tú escribes algo nuevo en el libro, tu amigo lo ve inmediatamente. Tu amigo no puede escribir en tu libro.

**Cuenta de Lector**: Tu amigo no tiene tarjeta de biblioteca. Tú le sacas una tarjeta y pagas todo para que pueda leer tus libros.

**Marketplace**: Una librería donde la gente pone sus libros para que otros los descubran y lean. Algunos libros son gratis, otros tienen precio.

**Native App**: Construyes un juguete y se lo das a tu amigo para que juegue en SU casa. El juguete funciona en su casa, no en la tuya.

**Clon**: Haces una foto mágica de tu castillo de LEGO. La foto se convierte en un castillo real idéntico, pero no usó más piezas de LEGO. Si cambias algo en la copia, ahí sí necesitas piezas nuevas.

**Time Travel**: Una máquina del tiempo para tus datos. Puedes ver cómo se veían hace 5 minutos, ayer, o hace un mes (si tienes Enterprise).

**UNDROP**: El botón de "deshacer" para cuando accidentalmente tiras algo a la basura. Funciona mientras los datos aún estén en el período de Time Travel.

**Fail-safe**: Después de que Time Travel expira, Snowflake guarda una copia secreta por 7 días más. Pero solo ELLOS pueden abrirla — tú no.

**Data Clean Room**: Dos niños quieren saber qué juguetes tienen en común, pero ninguno quiere enseñar su lista completa. Un adulto de confianza mira ambas listas y solo dice "tienen 3 juguetes en común."

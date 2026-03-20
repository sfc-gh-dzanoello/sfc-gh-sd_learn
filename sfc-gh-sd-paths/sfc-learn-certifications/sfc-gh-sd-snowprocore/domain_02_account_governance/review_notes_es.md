# DOMINIO 2: GESTIÓN DE CUENTAS Y GOBERNANZA
## 20% del examen = ~20 preguntas

---

## 2.1 CONTROL DE ACCESO (MUY IMPORTANTE EN EL EXAMEN)

### Dos modelos trabajando juntos:

**RBAC (Control de Acceso Basado en Roles)**:
- Privilegios → se otorgan a Roles → Roles se asignan a Usuarios
- Un usuario puede tener múltiples roles
- Un rol puede tener múltiples privilegios
- Los roles pueden heredar de otros roles (jerarquía)

**DAC (Control de Acceso Discrecional)**:
- El propietario del objeto controla el acceso
- Quien crea un objeto es el dueño
- El dueño puede otorgar acceso a otros

**Trampa del examen**: "¿Snowflake usa solo RBAC?" → INCORRECTO. Usa AMBOS: RBAC + DAC. SI VES "solo RBAC" o "solo DAC" → trampa.


### Ejemplos de Preguntas de Escenario — Access Control Model

**Escenario:** A data engineer on the ANALYTICS_TEAM role created a staging table. Now the FINANCE_TEAM role needs SELECT access to that table. The finance lead asks: "Who needs to grant us access?"
**Respuesta:** Under Snowflake's DAC model, the **owner** of the object controls who gets access. The ANALYTICS_TEAM role owns the table (because it created it), so someone using that role (or a higher role in the hierarchy like SECURITYADMIN with MANAGE GRANTS) must run `GRANT SELECT ON TABLE ... TO ROLE FINANCE_TEAM`. The finance team cannot grant themselves access — only the owner or a role with MANAGE GRANTS can. This is DAC in action: the owner decides.

**Escenario:** A security auditor asks: "Does Snowflake use RBAC or DAC?" A junior DBA responds: "It uses DAC because the object owner controls access." Is the DBA correct?
**Respuesta:** Partially correct but incomplete. Snowflake uses **both RBAC and DAC together**. RBAC is the primary model — privileges are granted to roles, and roles are granted to users. DAC complements it because every object has an owner role, and that owner can grant/revoke access. Saying "only DAC" ignores that all access flows through roles (RBAC). The correct answer on the exam is always "both models working together."

**Escenario:** A company wants to transfer ownership of a production database from the DEV_ADMIN role to the PROD_ADMIN role. What command is needed, and what happens to existing grants?
**Respuesta:** Use `GRANT OWNERSHIP ON DATABASE prod_db TO ROLE PROD_ADMIN`. After transfer, PROD_ADMIN becomes the new owner and controls access (DAC). By default, existing grants are preserved with the `COPY CURRENT GRANTS` option. Without it, existing grants may be revoked. This is a key DAC concept: ownership transfer changes who controls the object's access grants.

---

---

## 2.2 JERARQUÍA DE ROLES DEL SISTEMA (EL TEMA MÁS PROBADO)

```
ORGADMIN (nivel de organización — separado)

ACCOUNTADMIN = SECURITYADMIN + SYSADMIN
     │
     ├── SECURITYADMIN (gestiona grants + hereda USERADMIN)
     │        └── USERADMIN (crea usuarios y roles)
     │
     └── SYSADMIN (crea bases de datos, warehouses, esquemas)
              └── (roles personalizados deben otorgarse aquí)

PUBLIC (todos los usuarios lo tienen automáticamente)
```

### ACCOUNTADMIN — "El Jefe"
- Rol de nivel más alto en la cuenta
- Hereda TODOS los privilegios de SECURITYADMIN + SYSADMIN
- Funciones únicas: gestionar facturación, crear shares, configurar monitores de recursos
- **Mejores prácticas**: NO usar como rol por defecto. Asignar a mínimo 2 usuarios. Siempre con MFA.

### SECURITYADMIN — "El Portero"
- Posee el privilegio MANAGE GRANTS (puede otorgar/revocar cualquier privilegio)
- Gestiona políticas de red
- Hereda USERADMIN
- Es quien otorga grants, NO ACCOUNTADMIN (aunque ACCOUNTADMIN puede porque hereda todo)

### USERADMIN — "Recursos Humanos"
- Crea y gestiona usuarios y roles
- NO es propietario de objetos de datos

### SYSADMIN — "El Constructor"
- Crea bases de datos, warehouses, esquemas y todos los objetos de datos
- Los roles personalizados deben otorgarse a SYSADMIN (mejores prácticas)
- Rol por defecto recomendado para crear objetos

### ORGADMIN — "El Gerente Regional"
- Nivel de organización (no dentro de la jerarquía normal de la cuenta)
- Crea y gestiona cuentas en toda la organización
- Puede crear cuentas en diferentes regiones/nubes

### PUBLIC — "El Vestíbulo"
- Todos los usuarios reciben este rol automáticamente
- Nivel más bajo de acceso

### Por qué esto importa + Casos de uso

**Escenario real — "Un desarrollador junior creó una tabla pero nadie más puede verla"**
El desarrollador usó un rol personalizado que NO está en la jerarquía de SYSADMIN. Solución: GRANT custom_role TO ROLE SYSADMIN. Ahora SYSADMIN (y ACCOUNTADMIN) pueden ver y gestionar la tabla.

**Escenario real — "Necesitamos que alguien gestione quién accede a qué, pero NO debería poder crear bases de datos"**
→ SECURITYADMIN. Gestiona grants (MANAGE GRANTS) pero no hereda los privilegios de creación de objetos de SYSADMIN.

**Escenario real — "Un nuevo DBA necesita acceso total a todo temporalmente"**
→ Otorga ACCOUNTADMIN temporalmente, luego revoca. Mejores prácticas: nunca establzcas ACCOUNTADMIN como rol por defecto de nadie. Úsalo como acceso de emergencia.

**Trampa del examen**: "¿ACCOUNTADMIN debería ser el rol por defecto?" → INCORRECTO. Mejores prácticas: usar SYSADMIN o inferior como rol por defecto.
**Trampa del examen**: "¿SECURITYADMIN crea usuarios?" → INCORRECTO. USERADMIN crea usuarios. SECURITYADMIN hereda USERADMIN, pero el rol DESIGNADO es USERADMIN.
**Trampa del examen**: "¿SYSADMIN gestiona grants?" → INCORRECTO. SECURITYADMIN gestiona grants. SYSADMIN crea objetos.
**Trampa del examen**: "¿Los roles personalizados se otorgan directamente a ACCOUNTADMIN?" → Mejores prácticas = otorgar a SYSADMIN. SI VES "otorgar a ACCOUNTADMIN" como mejores prácticas → trampa.


### Ejemplos de Preguntas de Escenario — System-Defined Roles

**Escenario:** A new data team lead needs to create a warehouse for their analytics workload. They ask the admin to give them ACCOUNTADMIN. Is this appropriate?
**Respuesta:** No. ACCOUNTADMIN is the most powerful role and should be reserved for limited use. The correct approach is to use SYSADMIN to create the warehouse (SYSADMIN is the "builder" role for databases, schemas, and warehouses). Either grant SYSADMIN to the lead, or create a custom role with CREATE WAREHOUSE privilege and grant it to SYSADMIN in the hierarchy.

**Escenario:** An organization wants to set up SSO for all employees. Which system role should configure the network policies and security settings?
**Respuesta:** SECURITYADMIN. This role has the MANAGE GRANTS privilege and is the designated role for security-related configuration including network policies, grants, and access control. While ACCOUNTADMIN can also do this (it inherits SECURITYADMIN privileges), best practice is to use the most specific role for the task.

**Escenario:** A company has 15 custom roles but none of them can access databases created by SYSADMIN. What's likely wrong with their role hierarchy?
**Respuesta:** The custom roles are not granted to SYSADMIN. Best practice: all custom roles should be granted to SYSADMIN (`GRANT ROLE custom_role TO ROLE SYSADMIN`). This ensures the hierarchy flows properly — SYSADMIN inherits custom role privileges, and ACCOUNTADMIN inherits everything. Without this, custom roles are isolated from the hierarchy.

---

---

## 2.3 ROLES DE BASE DE DATOS

### Qué son:
- Roles con alcance dentro de UNA sola base de datos
- Se crean dentro de una base de datos
- NO se pueden activar directamente en una sesión
- Se deben otorgar a un rol de cuenta para usarlos
- Útiles para compartir (data sharing) — pueden incluirse en shares

**Trampa del examen**: "¿Pueden los roles de base de datos ser el rol activo de un usuario?" → NO. Se deben otorgar a un rol de cuenta primero. SI VES "activar directamente" + "rol de base de datos" → INCORRECTO.
**Trampa del examen**: "¿Roles de base de datos vs roles de cuenta?" → Los de base de datos tienen alcance en una BD, no se pueden activar directamente. Los de cuenta son globales y se pueden activar.


### Ejemplos de Preguntas de Escenario — Role Types

**Escenario:** A DBA creates a database role called ANALYTICS_DB.READER to manage read access within the ANALYTICS_DB database. An analyst tries to run `USE ROLE ANALYTICS_DB.READER` in their session. What happens?
**Respuesta:** It fails. Database roles cannot be activated directly in a session. The database role must first be granted to an account role (e.g., `GRANT DATABASE ROLE ANALYTICS_DB.READER TO ROLE ANALYST_ROLE`), and the analyst activates the account role instead. Database roles are always accessed indirectly through account roles.

**Escenario:** A data engineer needs SELECT on tables from both the MARKETING and FINANCE databases in a single query. They have separate roles for each. How can they access both without switching roles?
**Respuesta:** Use secondary roles: `USE SECONDARY ROLES ALL`. This activates all granted roles simultaneously, combining their permissions. The engineer can now query both databases in one session. Note: any new objects created will be owned by the PRIMARY role (the active role), not the secondary roles.

---

---

## 2.4 ROLES SECUNDARIOS

### Qué son:
- Un usuario puede tener UN rol activo (primario) y MÚLTIPLES roles secundarios
- USE SECONDARY ROLES ALL → combina permisos de todos los roles otorgados
- Permite acceder a objetos de diferentes roles sin cambiar de rol

**Trampa del examen**: "¿Solo puedes usar un rol a la vez?" → INCORRECTO (con roles secundarios). SI VES "un rol" + "a la vez" como limitación → INCORRECTO, los roles secundarios permiten combinar.


### Ejemplos de Preguntas de Escenario — Authentication Methods

**Escenario:** A company has a nightly ETL pipeline running via a Python script. The script currently uses a username/password to connect to Snowflake. The security team says passwords in scripts are a risk. What's the recommended alternative?
**Respuesta:** Use Key Pair Authentication. Generate an RSA key pair, register the public key with the Snowflake user (`ALTER USER etl_user SET RSA_PUBLIC_KEY = '...'`), and configure the Python connector to use the private key. No password stored in scripts. Key pair auth is the standard for programmatic/service account access.

**Escenario:** A company uses Okta as their identity provider and wants employees to log into Snowflake using their Okta credentials. Which authentication method should they configure?
**Respuesta:** Federated Authentication / SSO using SAML 2.0. Configure Okta as the external IdP for Snowflake. This is available on ALL editions. Do NOT confuse with MFA — MFA uses Duo Security for second-factor verification, while SSO/federated auth delegates the entire login to an external IdP like Okta.

---

---

## 2.5 AUTENTICACIÓN (PROBADO)

### MFA (Autenticación Multifactor):
- Potenciado por Duo Security
- Auto-inscripción por los usuarios
- Disponible en TODAS las ediciones
- Mejores prácticas: requerir para ACCOUNTADMIN

### SSO / Autenticación Federada:
- SAML 2.0
- IdP externo (Okta, Azure AD, ADFS)
- Disponible en TODAS las ediciones

### OAuth:
- OAuth externo (IdP de terceros)
- OAuth de Snowflake (nativo)
- Sin compartir contraseña
- Disponible en TODAS las ediciones

### Autenticación por Par de Claves:
- Claves RSA para acceso programático/CLI
- Sin contraseña necesaria
- Usado para automatización, conectores

**Trampa del examen**: "¿MFA requiere Enterprise?" → INCORRECTO. TODAS las ediciones. SI VES "Enterprise" + "MFA" → trampa.
**Trampa del examen**: "¿SSO requiere Business Critical?" → INCORRECTO. TODAS las ediciones. SI VES edición + "SSO" como requisito → trampa.


### Ejemplos de Preguntas de Escenario — Network Policies

**Escenario:** A company wants all employees to access Snowflake only from the office (IP range 10.0.0.0/16), but the DBA needs access from home too (IP 203.0.113.50). How should they configure this?
**Respuesta:** Create an account-level network policy with ALLOWED_IP_LIST = '10.0.0.0/16' for the office. Then create a separate user-level network policy for the DBA that includes both the office range and the home IP. User-level policy overrides account-level, so the DBA gets access from both locations while everyone else is restricted to the office.

---

---

## 2.6 POLÍTICAS DE RED

### Qué son:
- Listas de IP permitidas/bloqueadas
- Controlan quién puede conectarse
- Se aplican a nivel de cuenta O de usuario
- Política de usuario SOBREESCRIBE la de cuenta

### Cómo funcionan:
- ALLOWED_IP_LIST → solo estas IPs pueden conectarse
- BLOCKED_IP_LIST → estas IPs están bloqueadas
- La más restrictiva gana
- Si se establecen ambas: IP debe estar en la lista permitida Y NO en la lista bloqueada

**Trampa del examen**: "¿Las políticas de red requieren Enterprise?" → INCORRECTO. TODAS las ediciones. SI VES "Enterprise" + "política de red" → trampa.
**Trampa del examen**: "¿La política de cuenta sobreescribe la de usuario?" → INCORRECTO. La política de USUARIO sobreescribe la de cuenta.


### Ejemplos de Preguntas de Escenario — Encryption & Key Management

**Escenario:** A healthcare company on Business Critical edition needs maximum control over their encryption keys. If there's a security breach, they want the ability to instantly make all Snowflake data inaccessible. What feature should they use?
**Respuesta:** Tri-Secret Secure (Business Critical+). This creates a composite encryption key from a customer-managed key (in their cloud KMS) + Snowflake's key. If the customer revokes their key, all data becomes instantly inaccessible. This gives maximum customer control over encryption — the "kill switch" for data access.

**Escenario:** An auditor asks: "How often are encryption keys rotated in Snowflake?" and "Is old data re-encrypted with new keys?" What are the correct answers?
**Respuesta:** Keys are automatically rotated every 30 days on ALL editions — this means new data gets encrypted with the new key. However, periodic rekeying (re-encrypting OLD data with the new key) requires Enterprise+ edition. Key rotation (all editions) ≠ periodic rekeying (Enterprise+). This distinction is a common exam trap.

---

---

## 2.7 ENCRIPTACIÓN

### Capas de encriptación:

| Capa | Edición | Detalle |
|---|---|---|
| AES-256 | TODAS | Automática, siempre activa |
| Rekeying periódico | Enterprise+ | Re-encripta datos en segundo plano |
| Tri-Secret Secure | Business Critical+ | Clave del cliente + clave de Snowflake = clave maestra compuesta |

### Tri-Secret Secure:
- Clave gestionada por el cliente (vía KMS de la nube) + Clave gestionada por Snowflake
- Si el cliente revoca su clave → datos inaccesibles
- Máximo control para datos sensibles

**Trampa del examen**: "¿Tri-Secret Secure es Enterprise?" → INCORRECTO. Business Critical+. SI VES "Enterprise" + "Tri-Secret" → trampa.
**Trampa del examen**: "¿La encriptación necesita ser habilitada?" → INCORRECTO. AES-256 es automática en TODAS las ediciones. No requiere configuración.


### Ejemplos de Preguntas de Escenario — Data Governance Features

**Escenario:** A company's HR table has a SALARY column. HR managers should see actual salaries, but all other roles should see '****'. What feature should they use, and what's the limitation?
**Respuesta:** Dynamic Data Masking (Enterprise+). Create a masking policy that checks the current role — if HR_MANAGER, return the actual value; otherwise return '****'. Attach it to the SALARY column. Key limitation: only ONE masking policy per column (you can't stack multiple policies). For scaling across many columns, use tag-based masking — tag columns as "sensitive" and the policy follows the tag.

**Escenario:** A multinational company wants US-based analysts to only see US customer rows, and EU analysts to only see EU rows, from the same CUSTOMERS table. What feature should they use?
**Respuesta:** Row Access Policy (Enterprise+). Create a policy that checks the current role and returns TRUE only for rows matching that role's region. Apply it to the CUSTOMERS table. This is Row-Level Security — it filters ROWS, not columns. Do NOT confuse with Dynamic Data Masking, which hides column VALUES (not rows).

**Escenario:** A compliance officer needs to know which analysts accessed the PATIENT_RECORDS table's SSN column last month for a HIPAA audit. Where should they look?
**Respuesta:** ACCOUNT_USAGE.ACCESS_HISTORY (Enterprise+). This view tracks who accessed which columns, when, and whether it was a read or write. It provides column-level access tracking — exactly what HIPAA/GDPR audits require. It has 365 days of retention with up to 3-hour latency.

---

---

## 2.8 POLÍTICAS DE SEGURIDAD A NIVEL DE DATOS

### Enmascaramiento Dinámico de Datos (Enterprise+):
- Enmascara valores de columna basado en el rol del usuario
- Ejemplo: RRHH ve el NSS completo, otros ven ****
- Una política de enmascaramiento por columna
- Se aplica vía ALTER TABLE

### Políticas de Acceso a Filas (Enterprise+):
- Filtra FILAS basado en el rol/contexto del usuario
- Ejemplo: equipo de EE.UU. solo ve filas de EE.UU.
- Se aplica a la tabla

### Políticas de Proyección (Enterprise+):
- Controla qué columnas pueden aparecer en resultados de consulta
- Diferente de enmascaramiento: la proyección OCULTA completamente la columna
- El enmascaramiento transforma el valor, la proyección lo elimina por completo

### Políticas de Agregación (Enterprise+):
- Requiere que las consultas agreguen datos (GROUP BY)
- Previene consultas a nivel de fila individual en datos sensibles

**Trampa del examen**: "¿Política de enmascaramiento = filtrado de filas?" → INCORRECTO. Enmascaramiento = valores de COLUMNA. Política de Acceso a Filas = filtrado de FILAS.
**Trampa del examen**: "¿Enmascaramiento en Standard?" → INCORRECTO. Enterprise+ solamente. SI VES "Standard" + "enmascaramiento" → trampa.


### Ejemplos de Preguntas de Escenario — Privacy Policies

**Escenario:** Two competing retail companies want to find how many customers they share in common without revealing their full customer lists to each other. What Snowflake feature enables this?
**Respuesta:** Data Clean Rooms. Each party loads their customer data into the clean room environment. They run approved overlap analysis queries, but raw data stays private to each party — only aggregate results (e.g., "12,500 shared customers") are visible. Neither company sees the other's full customer list.

---

---

## 2.9 CLASIFICACIÓN DE DATOS (Enterprise+)

### Qué es:
- Detección automática de datos sensibles (PII, PHI)
- SYSTEM$CLASSIFY() → ejecutar clasificación
- Etiquetas de sensibilidad y categoría
- Se usa con políticas de enmascaramiento para protección automatizada

**Trampa del examen**: "¿La clasificación está disponible en Standard?" → INCORRECTO. Enterprise+ solamente.
**Trampa del examen**: "¿La clasificación aplica enmascaramiento automáticamente?" → INCORRECTO. La clasificación IDENTIFICA datos sensibles. Debes crear y aplicar políticas de enmascaramiento por separado.


### Ejemplos de Preguntas de Escenario — Alerts and Notifications

**Escenario:** A data team wants to be notified whenever a specific staging table hasn't been updated in the last 24 hours. Should they use a Resource Monitor or an Alert?
**Respuesta:** An Alert. Alerts use custom SQL conditions to monitor ANY data condition — including checking timestamps. Example: `CREATE ALERT ... IF (SELECT DATEDIFF('hour', MAX(load_ts), CURRENT_TIMESTAMP()) FROM staging_table) > 24 THEN ...`. Resource Monitors only track credit usage, not data conditions.

**Escenario:** A finance team wants to automatically suspend a warehouse when it exceeds 80% of its monthly credit budget. Should they use an Alert or a Resource Monitor?
**Respuesta:** A Resource Monitor. Set up a resource monitor with an 80% threshold and "Notify & Suspend" action. Resource monitors are specifically designed for credit tracking and warehouse control. Alerts cannot suspend warehouses — they can only send notifications or trigger tasks.

---

---

## 2.10 ETIQUETADO DE OBJETOS

### Qué es:
- Pares clave-valor en cualquier objeto (tablas, columnas, warehouses)
- Para gobernanza y organización
- Las etiquetas se propagan a través del linaje
- Ejemplo: etiquetar columna como "PII" → las tablas derivadas heredan la etiqueta

**Trampa del examen**: "¿Las etiquetas aplican seguridad automáticamente?" → INCORRECTO. Las etiquetas son para organización/rastreo. Debes crear políticas de seguridad por separado.


### Ejemplos de Preguntas de Escenario — Replication and Failover

**Escenario:** A company on AWS US-East wants to share a database with their team on Azure Europe. Can they create a direct share?
**Respuesta:** No. Direct shares only work within the same region AND same cloud provider. For cross-region or cross-cloud sharing, you must first replicate the database to the target region (`CREATE DATABASE ... AS REPLICA OF ...`), then create the share in that region. Replication first, then share.

**Escenario:** A company's primary Snowflake account in US-West goes down due to a regional outage. They have a replicated account in US-East. Can they switch to the US-East account? What edition do they need?
**Respuesta:** They need Business Critical+ edition to use account failover. With failover enabled, they can promote the secondary account in US-East to primary. Database replication alone (available on lower tiers) copies data but doesn't allow you to promote secondary to primary — that's the failover capability that requires BC+.

---

---

## 2.11 HISTORIAL DE ACCESO (Enterprise+)

### Qué es:
- ACCOUNT_USAGE.ACCESS_HISTORY → quién leyó/escribió qué datos
- Rastreo a nivel de columna
- Para auditoría y cumplimiento
- Muestra: qué usuario, qué rol, qué columnas, cuándo

**Trampa del examen**: "¿El historial de acceso está en INFORMATION_SCHEMA?" → INCORRECTO. Solo está en ACCOUNT_USAGE.


### Ejemplos de Preguntas de Escenario — Resource Monitors

**Escenario:** An analytics warehouse is burning through credits. The admin sets a resource monitor at 90% with "Notify & Suspend." A critical report is running when the threshold is hit. What happens to the running query?
**Respuesta:** With "Notify & Suspend" (regular suspend), the running query finishes first, then the warehouse suspends. If you need to stop queries immediately, use "Notify & Suspend Immediately" (hard suspend) — that cancels ALL running queries and suspends the warehouse instantly. This is a key exam distinction.

**Escenario:** The CFO asks: "How much does it cost to set up resource monitors across all our warehouses?" What's the answer?
**Respuesta:** Zero. Resource monitors have NO additional cost — they are free. They simply track credit usage and trigger actions (notify, suspend, or hard suspend) when thresholds are reached. Only ACCOUNTADMIN (or a role with CREATE RESOURCE MONITOR privilege) can create them.

---

---

## 2.12 TRUST CENTER

### Qué es:
- Panel de postura de seguridad
- Benchmarks CIS
- Recomendaciones de seguridad
- Escanea problemas de configuración
- NUEVA funcionalidad — puede aparecer en el examen


### Ejemplos de Preguntas de Escenario — ACCOUNT_USAGE vs INFORMATION_SCHEMA

**Escenario:** A security team needs to investigate failed login attempts from the past 3 months. Which view should they query?
**Respuesta:** ACCOUNT_USAGE.LOGIN_HISTORY (365 days retention). INFORMATION_SCHEMA only retains data for 7 days maximum, so 3-month-old data is only available in ACCOUNT_USAGE. Note: ACCOUNT_USAGE has up to 3-hour latency, so very recent logins (last few hours) might not appear yet.

**Escenario:** A DBA needs to check the current running queries RIGHT NOW to troubleshoot a performance issue. Should they use ACCOUNT_USAGE or INFORMATION_SCHEMA?
**Respuesta:** INFORMATION_SCHEMA — it's real-time with no latency. Use `SELECT * FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())` to see current and recent queries instantly. ACCOUNT_USAGE has up to 3-hour latency, which is useless for real-time troubleshooting.

**Escenario:** An admin wants to find all tables that were dropped in the last 6 months across the entire account. Which should they use?
**Respuesta:** ACCOUNT_USAGE. It has two key advantages here: (1) it includes dropped objects (INFORMATION_SCHEMA does NOT show dropped objects), and (2) it has 365-day retention (INFORMATION_SCHEMA max is 7 days). ACCOUNT_USAGE also covers the entire account scope, not just one database.

---

---

## 2.13 MONITORES DE RECURSOS

### Qué son:
- Rastrean el uso de CRÉDITOS (NO el conteo de consultas)
- Se pueden establecer a nivel de CUENTA o de WAREHOUSE
- Cero costo (la monitorización en sí no consume créditos)

### Acciones cuando se alcanza el umbral:
1. **Notificar** → enviar alerta
2. **Notificar y Suspender** → alertar + suspender warehouse después de que terminen las consultas actuales
3. **Notificar y Suspender Inmediatamente** → alertar + CANCELAR consultas en ejecución + suspender

### Reglas clave:
- Solo ACCOUNTADMIN puede crear monitores de recursos
- Puede rastrear uno o múltiples warehouses
- NO puede rastrear costos serverless (Snowpipe, auto-clustering, etc.)
- Se reinicia al inicio de cada intervalo (diario, semanal, mensual)

**Trampa del examen**: "¿Los monitores de recursos cuestan créditos?" → INCORRECTO. Cero costo. SI VES "consume créditos" + "monitor de recursos" → INCORRECTO.
**Trampa del examen**: "¿Suspensión dura espera a que terminen las consultas?" → INCORRECTO. Suspensión dura CANCELA las consultas en ejecución inmediatamente.
**Trampa del examen**: "¿Los monitores de recursos rastrean costos serverless?" → INCORRECTO. Solo créditos de warehouse. Snowpipe, clustering automático, etc. NO están rastreados.


### Ejemplos de Preguntas de Escenario — Calculating Warehouse Credits

**Escenario:** A company runs a multi-cluster warehouse (Medium size, 3 clusters active) for 2 hours. How many credits does this consume?
**Respuesta:** Medium = 4 credits/hour. With 3 clusters running for 2 hours: 4 × 3 × 2 = 24 credits. Each cluster is a separate instance of the warehouse, so credits multiply by the number of active clusters.

**Escenario:** An admin resizes a warehouse from Small to XL while a query is still running. Does the running query benefit from the larger size?
**Respuesta:** No. Running queries continue on the OLD size. Only NEW queries submitted after the resize use the XL warehouse. The running query completes on the Small warehouse. This is a common exam trap — resizing is not retroactive for in-flight queries.

---

---

## 2.14 ACCOUNT_USAGE vs INFORMATION_SCHEMA

### ACCOUNT_USAGE (base de datos SNOWFLAKE compartida):
- Latencia: 45 min a 3 horas
- Retención: 365 días
- Incluye objetos eliminados
- Requiere rol ACCOUNTADMIN (o privilegio IMPORTED PRIVILEGES)
- Alcance: toda la cuenta

### INFORMATION_SCHEMA (por base de datos):
- Latencia: tiempo real
- Retención: 7-14 días (varía por vista)
- NO incluye objetos eliminados
- Cualquier rol con acceso a la BD
- Alcance: solo la base de datos actual

**Trampa del examen**: "¿ACCOUNT_USAGE es en tiempo real?" → INCORRECTO. Latencia de hasta 3 horas. SI VES "tiempo real" + "ACCOUNT_USAGE" → INCORRECTO.
**Trampa del examen**: "¿INFORMATION_SCHEMA muestra objetos eliminados?" → INCORRECTO. Solo ACCOUNT_USAGE los muestra.
**Trampa del examen**: "¿INFORMATION_SCHEMA retiene datos por 365 días?" → INCORRECTO. 7 días a 6 meses (varía por vista). ACCOUNT_USAGE = 365 días.


### Ejemplos de Preguntas de Escenario — Logging and Tracing

**Escenario:** A Python UDF is throwing intermittent errors in production. The developer wants to add logging to understand what's happening at runtime. Where do the logs go?
**Respuesta:** Configure an Event Table and associate it with the database. The UDF can emit log messages that are captured in the event table. Event tables store UDF/procedure runtime logs and trace events — this is different from ACCOUNT_USAGE.QUERY_HISTORY, which tracks SQL query execution (not UDF internal logs). Event tables are available on ALL editions.

**Escenario:** An auditor wants to see all SQL queries executed against the FINANCE database in the last 90 days. Should they use event tables or ACCOUNT_USAGE?
**Respuesta:** ACCOUNT_USAGE.QUERY_HISTORY — it stores SQL query history for 365 days across the entire account. Event tables are for UDF/procedure runtime logs and traces, NOT for SQL query history. This is a key distinction: SQL queries → ACCOUNT_USAGE. UDF/procedure logs → Event Tables.

---

---

## 2.15 REPLICACIÓN Y FAILOVER

### Replicación de Base de Datos:
- Copia datos + objetos entre cuentas
- Primaria (lectura-escritura) → Secundaria(s) (solo lectura)
- Puede ser entre regiones y proveedores de nube

### Replicación de Cuenta:
- Replica objetos a nivel de cuenta (usuarios, roles, warehouses, políticas de red)
- Para recuperación ante desastres

### Failover (Business Critical+):
- Promueve base de datos/cuenta secundaria a primaria
- Cuando la región/cuenta primaria no está disponible
- Continuidad del negocio

**Trampa del examen**: "¿Failover funciona en Standard?" → INCORRECTO. Business Critical+ solamente.
**Trampa del examen**: "¿La base de datos secundaria es de lectura-escritura?" → INCORRECTO. Solo lectura hasta que se promueve.

---

## REPASO RÁPIDO — Dominio 2

1. Snowflake usa AMBOS: RBAC + DAC
2. Jerarquía: ACCOUNTADMIN > SECURITYADMIN > USERADMIN + SYSADMIN > PUBLIC
3. ACCOUNTADMIN = SECURITYADMIN + SYSADMIN combinados
4. SECURITYADMIN = gestiona grants (MANAGE GRANTS)
5. USERADMIN = crea usuarios y roles
6. SYSADMIN = crea bases de datos, warehouses, objetos. Los roles personalizados van aquí.
7. MFA, SSO, OAuth, políticas de red = TODAS las ediciones
8. Enmascaramiento, acceso a filas, clasificación, historial de acceso = Enterprise+
9. Tri-Secret Secure, PrivateLink, failover = Business Critical+
10. ACCOUNT_USAGE: 365 días, latencia de 3hr, incluye eliminados
11. INFORMATION_SCHEMA: tiempo real, máx 14 días, sin eliminados
12. Los monitores de recursos rastrean CRÉDITOS, cero costo, solo ACCOUNTADMIN los crea
13. El etiquetado de objetos se propaga a través del linaje
14. La clasificación de datos IDENTIFICA PII; el enmascaramiento lo PROTEGE

---

## PARES CONFUSOS — Dominio 2

| Preguntan sobre... | La respuesta es... | NO es... |
|---|---|---|
| Gestiona grants | SECURITYADMIN | ACCOUNTADMIN |
| Crea usuarios | USERADMIN | SECURITYADMIN |
| Crea bases de datos | SYSADMIN | ACCOUNTADMIN |
| Facturación y shares | ACCOUNTADMIN | SECURITYADMIN |
| Enmascaramiento de columna | Enmascaramiento Dinámico de Datos (Enterprise+) | Política de Acceso a Filas |
| Filtrado de filas | Política de Acceso a Filas (Enterprise+) | Enmascaramiento |
| Ocultar columna completamente | Política de Proyección | Política de Enmascaramiento |
| Clave del cliente | Tri-Secret Secure (BC+) | Rekeying periódico (Ent+) |
| Datos históricos 365 días | ACCOUNT_USAGE | INFORMATION_SCHEMA |
| Datos en tiempo real | INFORMATION_SCHEMA | ACCOUNT_USAGE |
| Cancelar consultas en ejecución + suspender | Suspender Inmediatamente | Suspender (espera a que terminen) |
| Detección automática de PII | Clasificación de Datos (Ent+) | Etiquetado de Objetos |
| Failover | Business Critical+ | Enterprise |

---

## RESUMEN AMIGABLE — Dominio 2

### ÁRBOLES DE DECISIÓN POR ESCENARIO
Cuando leas una pregunta, encuentra el patrón:

**"¿Quién debería gestionar los grants y accesos?"**
→ SECURITYADMIN (posee MANAGE GRANTS)
→ NO ACCOUNTADMIN (aunque puede, las mejores prácticas dicen SECURITYADMIN)

**"¿Quién crea usuarios nuevos?"**
→ USERADMIN
→ NO SECURITYADMIN (aunque hereda USERADMIN, el rol designado es USERADMIN)

**"¿Quién crea bases de datos y warehouses?"**
→ SYSADMIN
→ Los roles personalizados deben otorgarse a SYSADMIN

**"Un cliente necesita ver quién accedió a datos sensibles en los últimos 6 meses..."**
→ ACCOUNT_USAGE.ACCESS_HISTORY (365 días de retención, Enterprise+)
→ NO INFORMATION_SCHEMA (7 días a 6 meses según la vista)

**"Un cliente necesita ver información de consultas en tiempo real..."**
→ INFORMATION_SCHEMA.QUERY_HISTORY() (tiempo real)
→ NO ACCOUNT_USAGE (hasta 3 horas de latencia)

**"Un cliente quiere que su equipo de EE.UU. solo vea datos de EE.UU..."**
→ Política de Acceso a Filas (filtra FILAS por rol/contexto, Enterprise+)
→ NO enmascaramiento (eso oculta valores de columna, no filas)

**"Un cliente quiere ocultar números de seguro social de la mayoría de los usuarios..."**
→ Enmascaramiento Dinámico de Datos (enmascara valores de COLUMNA por rol, Enterprise+)
→ NO Política de Acceso a Filas (eso filtra filas enteras)

**"Un cliente necesita que su clave de encriptación se combine con la de Snowflake..."**
→ Tri-Secret Secure (clave del cliente + clave de Snowflake = clave maestra compuesta, BC+)
→ NO rekeying periódico (eso es solo Snowflake re-encriptando, Enterprise+)

**"Un cliente quiere ser alertado cuando un warehouse usa demasiados créditos..."**
→ Monitor de Recursos (rastrea créditos, notifica/suspende, cero costo)
→ Solo ACCOUNTADMIN puede crearlos

**"Un cliente quiere restringir el acceso a Snowflake desde IPs específicas..."**
→ Política de Red (listas de IP permitidas/bloqueadas, TODAS las ediciones)
→ Puede ser a nivel de cuenta o de usuario

---

### MNEMOTÉCNICOS PARA RECORDAR

**Jerarquía de roles = "A-S-U-S-P" (de arriba a abajo)**
- **A**CCOUNTADMIN → el jefe (facturación, shares, monitores de recursos)
- **S**ECURITYADMIN → el portero (grants, políticas de red)
- **U**SERADMIN → RRHH (crea usuarios y roles)
- **S**YSADMIN → el constructor (bases de datos, warehouses, esquemas)
- **P**UBLIC → todos lo reciben automáticamente

**Quién hace qué = "FAGS" (Facturación, Accesos, Gestión de objetos, Staff)**
- **F**acturación → ACCOUNTADMIN
- **A**ccesos (grants) → SECURITYADMIN
- **G**estión (objetos) → SYSADMIN
- **S**taff (usuarios) → USERADMIN

**ACCOUNT_USAGE vs INFORMATION_SCHEMA = "Viejo vs Ahora"**
- ACCOUNT_USAGE = datos VIEJOS (365 días, pero con retraso de hasta 3hr)
- INFORMATION_SCHEMA = datos de AHORA (tiempo real, pero solo 7-14 días)

**Capas de encriptación = "A-P-T" (Auto-Periódico-Tri)**
- **A**ES-256 = TODAS las ediciones (automático)
- **P**eriodic rekeying = Enterprise+
- **T**ri-Secret Secure = Business Critical+

**Gobernanza Enterprise+ = "MARC" (Masking, Access history, Row access, Classification)**
- Las cuatro son funcionalidades Enterprise+
- Piensa: "MARCas los datos sensibles"

---

### TRAMPAS PRINCIPALES — Dominio 2

1. **"ACCOUNTADMIN debería ser el rol por defecto"** → INCORRECTO. Mejores prácticas: usar SYSADMIN o inferior.
2. **"SECURITYADMIN crea usuarios"** → INCORRECTO. USERADMIN crea usuarios.
3. **"ACCOUNTADMIN gestiona grants"** → ENGAÑOSO. SECURITYADMIN es el gestor designado de grants. ACCOUNTADMIN PUEDE hacerlo (hereda todo), pero el examen quiere SECURITYADMIN.
4. **"Las políticas de red requieren Enterprise"** → INCORRECTO. TODAS las ediciones.
5. **"MFA requiere Enterprise"** → INCORRECTO. TODAS las ediciones.
6. **"Los monitores de recursos cuestan créditos"** → INCORRECTO. Cero costo.
7. **"Suspensión dura espera a que terminen las consultas"** → INCORRECTO. Suspensión dura CANCELA las consultas en ejecución inmediatamente.
8. **"INFORMATION_SCHEMA muestra objetos eliminados"** → INCORRECTO. Solo ACCOUNT_USAGE muestra objetos eliminados.
9. **"ACCOUNT_USAGE es en tiempo real"** → INCORRECTO. Hasta 3 horas de latencia.
10. **"Política de enmascaramiento = filtrado de filas"** → INCORRECTO. Enmascaramiento = valores de columna. Política de Acceso a Filas = filtrado de filas.

---

### ATAJOS DE PATRONES — "Si ves ___, la respuesta es ___"

| Si la pregunta menciona... | La respuesta casi siempre es... |
|---|---|
| "facturación", "monitoreo de costos" | ACCOUNTADMIN |
| "gestionar grants", "revocar acceso" | SECURITYADMIN |
| "crear usuarios", "crear roles" | USERADMIN |
| "crear base de datos", "crear warehouse" | SYSADMIN |
| "crear cuentas en la org" | ORGADMIN |
| "ocultar valores de columna por rol" | Enmascaramiento Dinámico de Datos (Enterprise+) |
| "filtrar filas por rol" | Política de Acceso a Filas (Enterprise+) |
| "clave gestionada por el cliente" | Tri-Secret Secure (BC+) |
| "rotación de claves cada 30 días" | Automática (todas las ediciones) |
| "rekeying periódico" | Enterprise+ |
| "detectar PII automáticamente" | Clasificación de Datos (Enterprise+) |
| "quién accedió a qué columna" | Historial de Acceso (Enterprise+) |
| "postura de seguridad", "benchmark CIS" | Trust Center |
| "lista de IPs permitidas/bloqueadas" | Política de Red (todas las ediciones) |
| "acceso programático, sin contraseña" | Autenticación por Par de Claves |
| "Duo Security" | MFA |
| "SAML 2.0" | Auth Federada / SSO |
| "historial de 365 días" | ACCOUNT_USAGE |
| "información de consultas en tiempo real" | INFORMATION_SCHEMA |
| "uso de créditos serverless" | METERING_DAILY_HISTORY |
| "uso de créditos solo de warehouse" | WAREHOUSE_METERING_HISTORY |
| "detener warehouse quemando créditos" | Monitor de Recursos |

---

## CONSEJOS PARA EL DÍA DEL EXAMEN — Dominio 2 (20% = ~20 preguntas)

**Antes de estudiar este dominio:**
- Flashcards de los 5 roles del sistema + qué hace cada uno — este es el tema #1 más probado aquí
- Flashcards de diferencias ACCOUNT_USAGE vs INFORMATION_SCHEMA (latencia, retención, objetos eliminados)
- Conoce las funcionalidades de gobernanza Enterprise+: "MARC" (Masking, Access history, Row access, Classification)

**Durante el examen — Preguntas del Dominio 2:**
- Lee la ÚLTIMA oración primero (la pregunta real) — luego lee el escenario
- Elimina 2 respuestas obviamente incorrectas inmediatamente
- Si preguntan "qué ROL" → recorre mentalmente la jerarquía: ACCOUNTADMIN > SECURITYADMIN > USERADMIN > SYSADMIN > PUBLIC
- Si preguntan sobre VER datos antiguos → verifica: ¿qué tan antiguos? Tiempo real = INFORMATION_SCHEMA. Histórico = ACCOUNT_USAGE.
- Si preguntan sobre FUNCIONALIDADES DE SEGURIDAD → verifica: ¿todas las ediciones? ¿Enterprise+? ¿BC+?
- Si mencionan ENCRIPTACIÓN → piensa A-P-T: AES (todas), Periodic rekeying (Ent+), Tri-Secret (BC+)

---

## UNA LÍNEA POR TEMA — Dominio 2

| Tema | Resumen en una línea |
|---|---|
| RBAC + DAC | RBAC: privilegios → roles → usuarios. DAC: el propietario del objeto otorga acceso. Ambos trabajan juntos. |
| ACCOUNTADMIN | Rol superior: facturación, shares, monitores de recursos. NO para uso diario. |
| SECURITYADMIN | Gestiona grants y políticas de red. "El portero." |
| USERADMIN | Crea usuarios y roles. "El departamento de RRHH." |
| SYSADMIN | Crea bases de datos, warehouses, esquemas. "El constructor." Roles personalizados → otorgar aquí. |
| ORGADMIN | Nivel de organización: crea cuentas entre regiones. No en la jerarquía regular. |
| PUBLIC | Todos los usuarios lo reciben automáticamente. Nivel más bajo. |
| Roles de base de datos | Alcance en una BD, no se pueden activar directamente, se deben otorgar a rol de cuenta. |
| Roles secundarios | USE SECONDARY ROLES ALL = combina permisos de múltiples roles en una sesión. |
| MFA | Duo Security, auto-inscripción, todas las ediciones. Mejores prácticas para ACCOUNTADMIN. |
| SSO / Auth Federada | SAML 2.0, IdP externo (Okta, Azure AD), todas las ediciones. |
| OAuth | OAuth externo o de Snowflake, sin compartir contraseña, todas las ediciones. |
| Auth por Par de Claves | Claves RSA para acceso programático/CLI, sin contraseña necesaria. |
| Políticas de Red | Listas de IP permitidas/bloqueadas, a nivel de cuenta o usuario, usuario sobreescribe cuenta, todas las ediciones. |
| Encriptación | AES-256 automática (todas), rekeying periódico (Ent+), Tri-Secret Secure (BC+). |
| Enmascaramiento Dinámico de Datos | A nivel de columna, basado en rol, Enterprise+. RRHH ve NSS, otros ven ****. |
| Políticas de Acceso a Filas | Filtrado a nivel de fila por rol, Enterprise+. Equipo de EE.UU. solo ve filas de EE.UU. |
| Clasificación de Datos | SYSTEM$CLASSIFY detecta PII automáticamente, Enterprise+. |
| Historial de Acceso | Quién accedió a qué columnas y cuándo, Enterprise+, ACCOUNT_USAGE. |
| Trust Center | Escaneo de postura de seguridad, benchmarks CIS, recomendaciones. NUEVO tema. |
| Etiquetado de Objetos | Etiquetas clave-valor en cualquier objeto, se propagan a través del linaje. |
| Monitores de Recursos | Rastrean uso de créditos, cero costo, pueden notificar/suspender/suspender inmediatamente. |
| ACCOUNT_USAGE | 365 días, hasta 3hr latencia, incluye objetos eliminados, acceso ACCOUNTADMIN. |
| INFORMATION_SCHEMA | Tiempo real, máx 7-14 días, por base de datos, cualquier rol con acceso a la BD. |
| METERING_DAILY_HISTORY | Todo el uso de créditos incluyendo serverless (clustering, pipes, etc.). |
| Replicación | Copia bases de datos entre cuentas/regiones. Necesaria para compartir entre regiones. |
| Failover | Promueve secundaria a primaria. Solo BC+. Para recuperación ante desastres. |

---

## FLASHCARDS — Dominio 2

**P:** ¿Cuál es la jerarquía de roles de arriba a abajo?
**R:** ACCOUNTADMIN > SECURITYADMIN > USERADMIN + SYSADMIN > PUBLIC. ACCOUNTADMIN = SECURITYADMIN + SYSADMIN combinados.

**P:** ¿Qué hace SECURITYADMIN?
**R:** Posee MANAGE GRANTS — puede otorgar/revocar cualquier privilegio en cualquier objeto. También hereda USERADMIN.

**P:** ¿Qué hace USERADMIN?
**R:** Crea y gestiona usuarios y roles. NO es propietario de objetos de datos.

**P:** ¿Qué hace SYSADMIN?
**R:** Crea y es propietario de warehouses, bases de datos, esquemas y todos los objetos de datos. Rol por defecto recomendado para crear objetos.

**P:** ¿Qué modelos de control de acceso usa Snowflake?
**R:** Ambos: RBAC (Basado en Roles) Y DAC (Discrecional). RBAC para roles, DAC porque los propietarios de objetos controlan el acceso.

**P:** ¿Cuál es la diferencia entre ACCOUNT_USAGE e INFORMATION_SCHEMA?
**R:** ACCOUNT_USAGE: latencia de 45min-3h, retención de 365 días, en base de datos compartida SNOWFLAKE. INFORMATION_SCHEMA: tiempo real, 7 días a 6 meses (varía por vista), solo por base de datos.

**P:** ¿Cómo funcionan las políticas de red?
**R:** ALLOWED_IP_LIST (lista blanca) + BLOCKED_IP_LIST (lista negra). La más restrictiva gana. Se puede establecer a nivel de cuenta o usuario.

**P:** ¿Qué rastrea un monitor de recursos?
**R:** Uso de CRÉDITOS, NO conteo de consultas. Acciones: Notificar, Notificar y Suspender, Notificar y Suspender Inmediatamente. Se puede establecer a nivel de CUENTA o WAREHOUSE.

**P:** ¿Qué edición se necesita para políticas de enmascaramiento?
**R:** Enterprise Edition o superior. Una política de enmascaramiento por columna. Se adjunta vía ALTER TABLE.

**P:** ¿Qué es Tri-Secret Secure?
**R:** Clave gestionada por el cliente (vía KMS de nube) + clave gestionada por Snowflake = clave maestra compuesta. Solo Business Critical+. Si el cliente revoca su clave, los datos son inaccesibles.

**P:** ¿Qué es el rekeying periódico?
**R:** Snowflake re-encripta automáticamente los datos con nuevas claves. Enterprise+. Ocurre de forma transparente en segundo plano.

**P:** ¿Cuáles son los métodos de autenticación?
**R:** Usuario/contraseña, MFA (vía Duo), autenticación por par de claves, SSO (SAML 2.0 vía Okta/ADFS/etc.), OAuth (Snowflake OAuth u OAuth externo).

**P:** ¿Qué es el etiquetado de objetos?
**R:** Etiquetar objetos (tablas, columnas) con pares clave-valor para gobernanza. Útil para clasificar datos sensibles. Las etiquetas se propagan vía linaje.

**P:** ¿Qué es el historial de acceso?
**R:** Vista ACCOUNT_USAGE.ACCESS_HISTORY — muestra quién leyó/escribió qué datos, incluyendo columnas. Para auditoría y cumplimiento.

**P:** ¿Política de acceso a filas vs política de enmascaramiento?
**R:** Política de acceso a filas: filtra FILAS basado en contexto del usuario (rol, usuario). Política de enmascaramiento: enmascara valores de COLUMNA (ej. mostrar solo últimos 4 dígitos del NSS).

**P:** ¿Qué NO pueden hacer los monitores de recursos?
**R:** No pueden cancelar consultas ya en ejecución. Solo previenen que NUEVAS consultas se inicien. Tampoco pueden rastrear costos serverless (Snowpipe, auto-clustering).

**P:** ¿Cuál es la diferencia entre replicación de base de datos y replicación de cuenta?
**R:** Replicación de base de datos: copia datos + objetos. Replicación de cuenta: copia usuarios, roles, warehouses, monitores de recursos, políticas de red.

**P:** ¿Cómo se calculan los créditos de warehouse?
**R:** XS=1, S=2, M=4, L=8, XL=16, 2XL=32, 3XL=64, 4XL=128. Cada tamaño se duplica. Facturación por segundo, mínimo de 60 segundos.

**P:** ¿Qué es una política de proyección?
**R:** Controla qué columnas pueden aparecer en resultados de consulta. Diferente de enmascaramiento — la proyección oculta completamente la columna, el enmascaramiento transforma el valor.

**P:** ¿Qué son las alertas?
**R:** Verificaciones SQL programadas que disparan acciones (email, tarea) cuando se cumplen condiciones. Evaluadas por el compute de Cloud Services.

---

## EXPLÍCALO COMO SI TUVIERA 5 AÑOS — Dominio 2

**ACCOUNTADMIN**: El super jefe que puede hacer todo. Úsalo con cuidado — como darle a alguien la llave maestra de todo el edificio.

**SECURITYADMIN**: El guardia de seguridad que decide quién recibe qué llaves (otorga/revoca acceso).

**USERADMIN**: La persona de RRHH que crea nuevos empleados (usuarios) y los asigna a equipos (roles).

**SYSADMIN**: El gerente de instalaciones que construye y es dueño de las habitaciones (bases de datos, warehouses) donde se trabaja.

**PUBLIC**: Todos reciben este rol automáticamente. Es como el vestíbulo — abierto para todos.

**RBAC**: En vez de dar permisos a cada persona, das permisos a un rol (como "Gerente"), luego le das a las personas el rol.

**Política de red**: Un portero en la puerta que verifica tu identificación (dirección IP). Si estás en la lista, entras. Si no, fuera.

**Monitor de recursos**: Una alerta de gasto de tarjeta de crédito. Vigila cuántos créditos usan tus warehouses y te avisa (o los detiene) si gastas demasiado.

**Política de enmascaramiento**: Como poner una pegatina sobre parte de un número de tarjeta de crédito para que la gente solo vea los últimos 4 dígitos.

**Política de acceso a filas**: Como un filtro que muestra diferentes filas a diferentes personas. El equipo de ventas solo ve los datos de su región.

**Tri-Secret Secure**: TÚ y Snowflake tienen cada uno una llave. Ambas llaves son necesarias para desbloquear los datos. Si quitas tu llave, nadie puede leerlos.

**ACCOUNT_USAGE**: Un diario detallado de todo lo que pasó en tu cuenta, pero tarda 45 minutos a 3 horas en escribir las entradas, y guarda registros por un año.

**INFORMATION_SCHEMA**: Una foto instantánea de lo que existe ahora mismo. Respuestas instantáneas, pero retiene de 7 días a 6 meses (dependiendo de la vista).

**Etiquetado de objetos**: Poner etiquetas adhesivas en tus datos diciendo "esto es sensible" o "esto es PII" para que puedas encontrarlos y protegerlos.

**Historial de acceso**: Una cámara de seguridad grabando quién miró qué datos y cuándo.

**MFA**: Un segundo candado en la puerta — incluso si alguien roba tu contraseña, aún necesita el código de tu teléfono.

**Rekeying periódico**: Snowflake cambia automáticamente las cerraduras de tus datos. Como cambiar contraseñas regularmente, pero para la encriptación.

**Política de proyección**: Ocultar completamente una columna de los resultados de consulta — no enmascararla, simplemente hacerla invisible.

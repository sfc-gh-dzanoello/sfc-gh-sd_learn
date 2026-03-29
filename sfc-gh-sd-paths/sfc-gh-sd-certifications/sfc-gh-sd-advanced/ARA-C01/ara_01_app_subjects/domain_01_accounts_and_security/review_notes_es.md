# Dominio 1: Estrategia de Cuentas y Seguridad

> **Cobertura del Temario ARA-C01:** Estrategia de Cuentas/BD, Seguridad/Privacidad/Cumplimiento, Principios de Seguridad

---

## 1.1 ESTRATEGIA DE CUENTAS

**Arquitectura de Cuenta Única vs Multi-Cuenta**

- **Cuenta única:** la más simple, todos los entornos (dev/staging/prod) comparten una cuenta
  - Más económica, menos sobrecarga administrativa
  - Riesgo: el radio de impacto es toda la cuenta (un GRANT incorrecto afecta todo)
- **Multi-cuenta:** cuentas separadas por entorno, unidad de negocio o región
  - Mayor aislamiento, políticas de seguridad independientes, facturación separada
  - Requerido para cumplimiento estricto (ej., datos PCI en su propia cuenta)
- **Snowflake Organizations:** contenedor padre que agrupa múltiples cuentas
  - Habilita replicación entre cuentas, grupos de failover y facturación centralizada
  - El rol ORGADMIN administra las cuentas dentro de la organización
  - Creación de cuentas mediante `CREATE ACCOUNT` (solo ORGADMIN)

**Patrones de Segmentación**

- **Por entorno:** cuentas de dev / staging / prod
- **Por región:** cuentas en diferentes regiones de nube para residencia de datos
- **Por unidad de negocio:** finanzas, marketing, ingeniería, cada uno tiene la suya
- **Por cumplimiento:** cuenta con alcance PCI, cuenta con alcance HIPAA

### Por Qué Esto Importa
Una empresa de salud necesita datos HIPAA aislados de los análisis de marketing. Multi-cuenta con replicación a nivel de organización les permite compartir datos no-PHI entre cuentas mientras mantienen los PHI protegidos.

### Mejores Prácticas
- Usar Organizations para administrar centralmente las cuentas y la facturación
- Replicar objetos de seguridad (network policies, RBAC) mediante replicación de cuentas
- Mantener las cuentas de producción en edición Business Critical o superior para cumplimiento

**Trampa del examen:** SI VES "usar una sola cuenta con bases de datos separadas para aislamiento PCI" → **INCORRECTO** porque PCI requiere aislamiento a nivel de cuenta, no solo a nivel de base de datos.

**Trampa del examen:** SI VES "ACCOUNTADMIN puede crear nuevas cuentas" → **INCORRECTO** porque solo ORGADMIN puede crear cuentas dentro de una Organization.

**Trampa del examen:** SI VES "Organizations requiere edición Enterprise" → **INCORRECTO** porque Organizations está disponible en todas las ediciones.

### Preguntas Frecuentes (FAQ)
**P: ¿Puedo compartir datos entre cuentas sin Organizations?**
R: Sí, mediante Secure Data Sharing (listings), pero Organizations agrega replicación, failover y administración centralizada.

**P: ¿Cada cuenta en una organización recibe facturación separada?**
R: Por defecto la facturación se consolida a nivel de organización, pero puedes ver el uso por cuenta.


### Ejemplos de Preguntas de Escenario — Account Strategy

**Escenario:** A global insurance company operates in the EU, US, and APAC. EU regulations require that EU customer data never leaves EU soil. The US team needs access to aggregated (non-PII) metrics from all regions for global dashboards. How should the architect design the Snowflake account topology?
**Respuesta:** Deploy separate Snowflake accounts per region (EU, US, APAC) within a single Snowflake Organization. Each regional account stores its own customer data in a cloud region that satisfies data residency requirements. Use database replication to replicate non-PII aggregated datasets from EU and APAC accounts to the US account for global dashboards. ORGADMIN manages account creation and centralized billing. This ensures EU data never leaves the EU account while enabling cross-region analytics on safe aggregates.

**Escenario:** A fintech startup is growing from 10 to 500 employees and currently uses a single Snowflake account for dev, staging, and production. An intern accidentally ran a `GRANT ALL ON DATABASE prod_db TO ROLE PUBLIC` in production. What architectural change prevents this class of incident?
**Respuesta:** Migrate to a multi-account architecture with separate accounts for dev, staging, and production within a Snowflake Organization. This provides account-level blast radius isolation — a misconfigured GRANT in dev cannot affect production. Additionally, use managed access schemas in the production account so that only the schema owner (or MANAGE GRANTS holder) can issue grants, preventing ad-hoc privilege escalation by individual object owners. Replicate security objects across accounts using account replication for consistent RBAC.

---

---

## 1.2 JERARQUÍA DE PARÁMETROS

**Tres Niveles (de arriba hacia abajo):**

1. **Cuenta** — establecido por ACCOUNTADMIN, aplica globalmente
2. **Objeto** — establecido en warehouse, base de datos, esquema, tabla, usuario
3. **Sesión** — establecido por el usuario para su sesión actual (`ALTER SESSION`)

**Regla de Precedencia:** El más específico gana. Sesión > Objeto > Cuenta.

**Parámetros Clave que Debes Conocer:**

| Parámetro | Nivel Típico | Notas |
|---|---|---|
| `STATEMENT_TIMEOUT_IN_SECONDS` | Cuenta / Sesión | Cancela consultas largas |
| `DATA_RETENTION_TIME_IN_DAYS` | Cuenta / Objeto | Ventana de Time Travel (0-90) |
| `MIN_DATA_RETENTION_TIME_IN_DAYS` | Solo cuenta | Piso que los objetos no pueden reducir |
| `NETWORK_POLICY` | Cuenta / Usuario | Nivel de usuario sobreescribe nivel de cuenta |
| `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` | Cuenta | Endurecimiento de seguridad |

### Por Qué Esto Importa
Un DBA establece el timeout a nivel de cuenta en 1 hora. Un científico de datos establece el timeout de sesión en 4 horas para un trabajo grande de ML. El nivel de sesión gana para ese usuario.

### Mejores Prácticas
- Establecer `MIN_DATA_RETENTION_TIME_IN_DAYS` a nivel de cuenta para evitar que los usuarios configuren Time Travel en 0
- Usar `STATEMENT_TIMEOUT_IN_SECONDS` en warehouses para prevenir consultas descontroladas
- Documentar qué parámetros están configurados en qué nivel

**Trampa del examen:** SI VES "el parámetro de cuenta siempre sobreescribe el parámetro de sesión" → **INCORRECTO** porque la sesión es más específica y gana.

**Trampa del examen:** SI VES "MIN_DATA_RETENTION_TIME_IN_DAYS se puede establecer en un esquema" → **INCORRECTO** porque es solo a nivel de cuenta.

**Trampa del examen:** SI VES "una network policy a nivel de usuario es aditiva a la de nivel de cuenta" → **INCORRECTO** porque la network policy a nivel de usuario **reemplaza** la política a nivel de cuenta para ese usuario.

### Preguntas Frecuentes (FAQ)
**P: Si establezco DATA_RETENTION_TIME_IN_DAYS = 1 en una tabla pero el MIN de la cuenta es 7, ¿cuál gana?**
R: El MIN gana — la tabla obtiene 7 días. MIN establece un piso.

**P: ¿Puede un usuario que no sea ACCOUNTADMIN establecer parámetros de cuenta?**
R: No. Solo ACCOUNTADMIN (o roles con el privilegio otorgado) puede establecer parámetros a nivel de cuenta.


### Ejemplos de Preguntas de Escenario — Parameter Hierarchy

**Escenario:** A data engineering team runs large Spark-based ETL jobs that can take up to 6 hours. The account-level `STATEMENT_TIMEOUT_IN_SECONDS` is set to 3600 (1 hour) to protect against runaway queries. The ETL jobs keep getting killed. The team asks the architect to raise the account timeout to 24 hours. What is the correct approach?
**Respuesta:** Do not raise the account-level timeout — that would expose all users to potential 24-hour runaway queries. Instead, set `STATEMENT_TIMEOUT_IN_SECONDS` at the object level on the dedicated ETL warehouse to 21600 (6 hours). Session-level and object-level parameters override the account default for that specific context. This way, BI users on other warehouses still get the 1-hour safety net while ETL has the headroom it needs.

**Escenario:** A compliance officer discovers that a developer set `DATA_RETENTION_TIME_IN_DAYS = 0` on several staging tables, meaning accidental deletes cannot be recovered via Time Travel. How should the architect prevent this from happening again across the entire account?
**Respuesta:** Set `MIN_DATA_RETENTION_TIME_IN_DAYS` at the account level (e.g., to 1 or 7 days). This parameter is account-level only and establishes a floor that no individual database, schema, or table can go below. Even if a developer sets `DATA_RETENTION_TIME_IN_DAYS = 0` on a table, the MIN floor overrides it, ensuring Time Travel is always available for at least the minimum period.

---

---

## 1.3 CONTROL DE ACCESO BASADO EN ROLES

**Conceptos Fundamentales**

- Snowflake usa **Control de Acceso Basado en Roles (RBAC)** — los privilegios se otorgan a roles, los roles se otorgan a usuarios
- Los roles forman una jerarquía: los privilegios de roles hijos fluyen HACIA ARRIBA a los roles padres
- **Roles definidos por el sistema:** ORGADMIN > ACCOUNTADMIN > SECURITYADMIN > SYSADMIN > USERADMIN > PUBLIC

**Herencia de Privilegios**

- Si el Rol A se otorga al Rol B, entonces el Rol B hereda TODOS los privilegios del Rol A
- ACCOUNTADMIN debería heredar tanto de SECURITYADMIN como de SYSADMIN
- Nunca usar ACCOUNTADMIN para trabajo diario

**Database Roles**

- Limitados a una sola base de datos (portables con la base de datos durante replicación/clonación)
- Se otorgan a roles a nivel de cuenta u otros database roles
- Ideales para compartir: los consumidores obtienen database roles, no roles de cuenta

**Patrón de Roles Funcionales vs Roles de Acceso**

- **Roles de acceso:** contienen privilegios sobre objetos (ej., `ANALYST_READ` tiene SELECT en tablas)
- **Roles funcionales:** representan funciones laborales, heredan de roles de acceso (ej., `DATA_ANALYST` hereda `ANALYST_READ` + `DASHBOARD_WRITE`)
- Este modelo de dos capas simplifica la administración a escala

**Roles Secundarios**

- `USE SECONDARY ROLES ALL` — el usuario obtiene la unión de privilegios de todos los roles otorgados
- Evita el cambio constante de roles
- El rol secundario predeterminado se puede establecer en el objeto de usuario

### Por Qué Esto Importa
Un equipo de analítica de 500 personas necesita acceso granular. Los roles funcionales (Data Analyst, Data Engineer) heredan de roles de acceso detallados. ¿Nueva contratación? Otorga un rol funcional. Listo.

### Mejores Prácticas
- Nunca otorgar privilegios directamente a usuarios — siempre usar roles
- SYSADMIN debería ser dueño de todas las bases de datos/warehouses (o roles personalizados otorgados a SYSADMIN)
- Usar database roles para objetos compartidos mediante Secure Sharing
- Separar SECURITYADMIN (administra grants) de SYSADMIN (administra objetos)

**Trampa del examen:** SI VES "ACCOUNTADMIN debería ser el rol predeterminado para administradores" → **INCORRECTO** porque ACCOUNTADMIN es solo para emergencias; el trabajo diario debe usar roles inferiores.

**Trampa del examen:** SI VES "los database roles se pueden otorgar directamente a usuarios" → **INCORRECTO** porque los database roles deben otorgarse primero a roles a nivel de cuenta (u otros database roles).

**Trampa del examen:** SI VES "la herencia de privilegios fluye hacia abajo" → **INCORRECTO** porque fluye HACIA ARRIBA en la jerarquía de roles.

### Preguntas Frecuentes (FAQ)
**P: ¿Cuál es la diferencia entre SECURITYADMIN y USERADMIN?**
R: USERADMIN administra usuarios y roles. SECURITYADMIN hereda de USERADMIN y también puede administrar grants (GRANT/REVOKE).

**P: ¿Puedo usar roles secundarios con Secure Sharing?**
R: No. Los shares usan el database role designado del share; los roles secundarios no aplican en el contexto de sharing.


### Ejemplos de Preguntas de Escenario — Role-Based Access Control

**Escenario:** A 2,000-person enterprise has 15 departments, each with analysts, engineers, and managers. New hires join weekly. Currently, each new hire requires 10+ individual GRANT statements. The security team wants a scalable model. What RBAC pattern should the architect implement?
**Respuesta:** Implement the functional-role / access-role pattern. Create fine-grained access roles that hold object-level privileges (e.g., `SALES_READ`, `SALES_WRITE`, `MARKETING_READ`). Then create functional roles representing job functions (e.g., `SALES_ANALYST`, `SALES_ENGINEER`, `MARKETING_MANAGER`) that inherit from the appropriate access roles. When a new hire joins, grant them a single functional role. All access roles should be granted to SYSADMIN for hierarchy completeness. This reduces onboarding to one GRANT per new user and simplifies auditing.

**Escenario:** A data marketplace team shares curated datasets to external consumers via Secure Data Sharing. They need consumers to have SELECT on specific views without exposing account-level role structures. What role type should the architect use?
**Respuesta:** Use database roles. Database roles are scoped to a single database and are portable with the database during sharing. Grant SELECT on the secure views to database roles within the shared database, then assign those database roles to the share. Consumers receive the database roles without visibility into the provider's account-level role hierarchy. This also ensures that if the database is replicated or cloned, the database roles travel with it.

**Escenario:** Multiple analysts complain about constantly switching roles to access tables in different databases. Each analyst has 4-5 roles granted. How should the architect solve this without restructuring the entire RBAC model?
**Respuesta:** Enable secondary roles by having analysts run `USE SECONDARY ROLES ALL` at session start (or set a default secondary role on the user object). This gives users the union of privileges from all their granted roles simultaneously, eliminating constant `USE ROLE` switching. This is a session-level change and does not affect the underlying RBAC model or security posture.

---

---

## 1.4 SEGURIDAD DE RED

**Network Policies**

- Listas de IPs permitidas/bloqueadas aplicadas a nivel de cuenta o usuario
- Usan `ALLOWED_IP_LIST` y `BLOCKED_IP_LIST`
- La política a nivel de usuario **reemplaza** (no complementa) la política a nivel de cuenta

**Network Rules (más nuevas, más flexibles)**

- Pueden referenciar rangos de IP, endpoints de VPC, nombres de host
- Se adjuntan a network policies para reglas modulares y reutilizables
- Soportan direcciones `INGRESS` (entrante) y `EGRESS` (saliente)

**AWS PrivateLink / Azure Private Link / GCP Private Service Connect**

- Conectividad privada desde tu VPC a Snowflake — sin internet público
- Requiere edición Business Critical o superior
- Obtienes una URL de endpoint privado (ej., `account.privatelink.snowflakecomputing.com`)
- NO reemplaza las network policies — usa ambas juntas

**External Access Integrations**

- Permiten que UDFs/procedimientos llamen APIs externas (ej., endpoints REST)
- Requiere crear una External Access Integration + Network Rule (egress)
- Los secretos se almacenan en objetos secret de Snowflake, no en el código

### Por Qué Esto Importa
Un banco necesita que todo el tráfico de Snowflake permanezca en su red privada. PrivateLink + network policies + bloquear acceso público = cero exposición a internet público.

### Mejores Prácticas
- Siempre establecer una network policy a nivel de cuenta (aunque sea amplia) como red de seguridad
- Usar PrivateLink para cargas de trabajo de producción en industrias reguladas
- Probar las network policies en entornos no productivos antes de aplicarlas a nivel de cuenta
- Usar network rules en lugar de listas de IP directas para mejor mantenibilidad

**Trampa del examen:** SI VES "PrivateLink está disponible en la edición Standard" → **INCORRECTO** porque requiere Business Critical o superior.

**Trampa del examen:** SI VES "las network policies soportan bloqueo por FQDN/hostname" → **INCORRECTO** para network policies solas; necesitas network rules para controles basados en hostname.

**Trampa del examen:** SI VES "PrivateLink elimina la necesidad de network policies" → **INCORRECTO** porque sirven para propósitos diferentes y deben usarse juntas.

### Preguntas Frecuentes (FAQ)
**P: Si bloqueo todas las IPs públicas, ¿puedo seguir usando Snowsight?**
R: Solo mediante la URL de Snowsight habilitada para PrivateLink o si agregas las IPs de Snowsight de Snowflake a la lista permitida.

**P: ¿Puedo tener network policies tanto a nivel de cuenta como de usuario?**
R: Sí, pero la política a nivel de usuario reemplaza completamente (no se fusiona con) la política de cuenta para ese usuario.


### Ejemplos de Preguntas de Escenario — Network Security

**Escenario:** A large bank is migrating to Snowflake and requires zero public internet exposure. Their applications run in AWS VPCs across three regions. Some teams also need Snowsight access from corporate offices with static IPs. How should the architect design the network architecture?
**Respuesta:** Enable AWS PrivateLink to establish private connectivity from each VPC to Snowflake — traffic stays on the AWS backbone and never traverses the public internet. Create a network policy at the account level that blocks all public IPs by default. For Snowsight access from corporate offices, add the corporate static IPs to the `ALLOWED_IP_LIST` in the account-level network policy (or use a user-level network policy for specific admin users who need Snowsight). PrivateLink requires Business Critical edition or higher. Use network rules for modular, reusable IP and VPC endpoint definitions.

**Escenario:** A data engineering team needs their Python UDFs to call an external REST API for geocoding. The security team does not allow arbitrary outbound internet access from Snowflake. What is the correct architecture?
**Respuesta:** Create a network rule with `MODE = EGRESS` specifying the geocoding API's hostname. Create an external access integration referencing that network rule and a Snowflake secret object containing the API key. Grant the external access integration to the UDF. This allows controlled, auditable outbound access to only the specified endpoint — no blanket internet access. The API credentials are stored in Snowflake's secret management, never in code.

---

---

## 1.5 AUTENTICACIÓN

**SSO / SAML 2.0**

- Snowflake actúa como el Proveedor de Servicios (SP)
- Tu IdP (Okta, Azure AD, etc.) autentica a los usuarios
- Se configura mediante una security integration SAML2
- Soporta SCIM para aprovisionamiento automatizado de usuarios/grupos

**OAuth**

- External OAuth: token de tu IdP (Okta, Azure AD, PingFederate)
- Snowflake OAuth: Snowflake emite el token (usado por aplicaciones asociadas como Tableau)
- Ambos usan security integrations

**MFA (Autenticación Multi-Factor)**

- MFA Duo integrado, sin costo adicional
- Se puede aplicar mediante authentication policies (`AUTHENTICATION_POLICY`)
- `CLIENT_TYPES` en la política de autenticación controla qué clientes deben usar MFA

**Autenticación por Par de Claves**

- RSA 2048-bit como mínimo
- La clave pública se almacena en el objeto de usuario, la clave privada la tiene el cliente
- Soporta rotación de claves (dos claves activas: `RSA_PUBLIC_KEY` y `RSA_PUBLIC_KEY_2`)
- Requerido para cuentas de servicio / automatización (Snowpipe, conectores)

**Authentication Policies**

- Controlan los métodos de autenticación permitidos por cuenta o por usuario
- Pueden restringir a `CLIENT_TYPES` específicos (ej., SNOWFLAKE_UI, DRIVERS)
- Pueden aplicar MFA para tipos de cliente específicos

**Autenticación Federada**

- Combina SSO + MFA para la postura más fuerte
- Los usuarios se autentican vía IdP, luego el desafío MFA

### Por Qué Esto Importa
Una empresa con 5,000 usuarios necesita SSO vía Okta, MFA obligatorio para usuarios de la interfaz, y par de claves para pipelines CI/CD. Las authentication policies permiten aplicar reglas diferentes por caso de uso.

### Mejores Prácticas
- Aplicar MFA para todos los usuarios humanos (como mínimo ACCOUNTADMIN)
- Usar autenticación por par de claves para todas las cuentas de servicio / automatización
- Usar SCIM para sincronizar usuarios/grupos desde tu IdP
- Establecer authentication policies para bloquear el acceso solo con contraseña

**Trampa del examen:** SI VES "Snowflake OAuth y External OAuth son lo mismo" → **INCORRECTO** porque Snowflake OAuth es emitido por Snowflake; External OAuth proviene de tu IdP.

**Trampa del examen:** SI VES "la autenticación por par de claves requiere edición Enterprise" → **INCORRECTO** porque está disponible en todas las ediciones.

**Trampa del examen:** SI VES "MFA se puede aplicar mediante una network policy" → **INCORRECTO** porque la aplicación de MFA usa authentication policies, no network policies.

**Trampa del examen:** SI VES "SCIM crea roles automáticamente" → **INCORRECTO** porque SCIM aprovisiona usuarios y grupos pero NO crea roles de Snowflake automáticamente.

### Preguntas Frecuentes (FAQ)
**P: ¿Puedo usar tanto SSO como inicio de sesión con contraseña?**
R: Sí, a menos que establezcas una authentication policy que bloquee la autenticación por contraseña. Por defecto ambos funcionan.

**P: ¿Qué pasa si un usuario pierde su par de claves?**
R: El administrador puede establecer una nueva clave pública en el objeto de usuario. El segundo espacio de clave permite la rotación sin tiempo de inactividad.


### Ejemplos de Preguntas de Escenario — Authentication

**Escenario:** An enterprise has 5,000 employees using Okta for SSO, plus 200 CI/CD service accounts running nightly ETL pipelines. The CISO mandates MFA for all human users accessing Snowsight but cannot require MFA for automated pipelines (which have no human to approve a push notification). How should the architect configure authentication?
**Respuesta:** Configure a SAML 2.0 security integration with Okta for SSO for all human users. Create an authentication policy that enforces MFA with `CLIENT_TYPES` set to `SNOWFLAKE_UI` (Snowsight) — this requires MFA for interactive logins but not for programmatic drivers. For the 200 CI/CD service accounts, use key-pair authentication (RSA 2048-bit minimum) with the public key stored on each service user object. Set a separate authentication policy on service accounts that allows only key-pair auth and blocks password-based access entirely. Use SCIM to auto-provision and deprovision human users from Okta.

**Escenario:** A company rotates credentials quarterly. They have 50 service accounts using key-pair authentication. How can the architect enable zero-downtime key rotation?
**Respuesta:** Snowflake supports two concurrent public keys per user object: `RSA_PUBLIC_KEY` and `RSA_PUBLIC_KEY_2`. During rotation, generate a new key pair and set it as `RSA_PUBLIC_KEY_2` on the user object. Update the service account's client configuration to use the new private key. Once confirmed working, remove the old key from `RSA_PUBLIC_KEY`. This overlapping window allows zero-downtime rotation without any service interruption.

---

---

## 1.6 GOBERNANZA DE DATOS

**Masking Policies (Dynamic Data Masking)**

- Seguridad a nivel de columna: retorna un valor enmascarado según el rol que consulta
- La política es una función SQL: `CREATE MASKING POLICY ... RETURNS <type> -> CASE WHEN ...`
- Se aplica a columnas mediante `ALTER TABLE ... ALTER COLUMN ... SET MASKING POLICY`
- Una masking policy por columna
- Soporta enmascaramiento condicional (basado en rol, otra columna, etc.)

**Row Access Policies (RAP)**

- Seguridad a nivel de fila: filtra filas según el contexto de consulta
- Retorna `TRUE` (fila visible) o `FALSE` (fila oculta)
- Una RAP por tabla/vista
- Puede referenciar tablas de mapeo para filtrado de rol-a-región

**Aggregation Policies**

- Previenen consultas que retornan resultados por debajo de un tamaño mínimo de grupo
- Protegen contra la re-identificación en analítica
- Privacidad a nivel de entidad (ej., debe agregar al menos 5 pacientes)

**Projection Policies**

- Previenen `SELECT column` directamente — la columna solo puede usarse en WHERE, JOIN, GROUP BY
- Caso de uso: permitir filtrar por SSN pero nunca mostrarlo

**Object Tagging**

- Metadatos clave-valor en cualquier objeto (tabla, columna, warehouse, etc.)
- Linaje de tags: los tags se propagan a través de vistas
- Base para masking policies basadas en tags (aplicar enmascaramiento a todas las columnas con tag X)
- Tags del sistema desde clasificación (ej., `SNOWFLAKE.CORE.SEMANTIC_CATEGORY = EMAIL`)

**Linaje de Datos (ACCESS_HISTORY)**

- `SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY` — rastrea lecturas/escrituras a nivel de columna
- Muestra qué columnas fueron accedidas, por quién, y cómo fluyeron los datos
- Retención de 365 días
- Requiere edición Enterprise o superior

### Por Qué Esto Importa
Una empresa de retail etiqueta todas las columnas PII, luego aplica una sola masking policy a cada columna con el tag PII. Cuando se agrega y etiqueta una nueva columna PII, el enmascaramiento es automático.

### Mejores Prácticas
- Usar enmascaramiento basado en tags para gobernanza escalable
- Combinar RAP + masking para defensa en profundidad
- Usar aggregation policies para datasets analíticos expuestos a audiencias amplias
- Ejecutar clasificación de datos para auto-detectar datos sensibles

**Trampa del examen:** SI VES "puedes aplicar dos masking policies a la misma columna" → **INCORRECTO** porque solo se permite una masking policy por columna.

**Trampa del examen:** SI VES "las row access policies se aplican a columnas" → **INCORRECTO** porque las RAP se aplican a tablas/vistas, no a columnas individuales.

**Trampa del examen:** SI VES "los object tags requieren edición Business Critical" → **INCORRECTO** porque el etiquetado está disponible en Enterprise y superior.

**Trampa del examen:** SI VES "las aggregation policies filtran filas" → **INCORRECTO** porque bloquean consultas que producen grupos por debajo del tamaño mínimo, no filtran filas individuales.

### Preguntas Frecuentes (FAQ)
**P: ¿Las masking policies pueden referenciar otras tablas?**
R: Sí. Puedes consultar una tabla de mapeo dentro del cuerpo de la masking policy (subconsulta).

**P: ¿Las row access policies funcionan en vistas materializadas?**
R: No. Las RAP no están soportadas en vistas materializadas.

**P: ¿Cuál es la diferencia entre projection policy y masking policy?**
R: Masking reemplaza el valor (ej., `***`). Projection evita que la columna aparezca en los resultados por completo pero permite su uso en predicados.


### Ejemplos de Preguntas de Escenario — Data Governance

**Escenario:** A healthcare analytics platform has 500+ tables, and new columns containing PHI (emails, phone numbers, SSNs) are added regularly as new data sources are onboarded. The governance team cannot manually review every new column. How should the architect automate masking at scale?
**Respuesta:** Implement tag-based masking. Run Snowflake's automatic data classification to detect sensitive columns and apply system tags (e.g., `SNOWFLAKE.CORE.SEMANTIC_CATEGORY = 'EMAIL'`). Create masking policies for each sensitivity category (EMAIL, PHONE, SSN) and bind them to the corresponding tags using tag-based masking policy assignments. When new columns are added and classified, the masking policy auto-applies based on the tag — no manual intervention needed. Combine with row access policies for defense-in-depth.

**Escenario:** A pharmaceutical company needs to share a clinical trial dataset with external researchers. Researchers must be able to filter by patient demographics (age, gender, zip code) for cohort selection, but must never see individual patient records — results must aggregate at least 20 patients per group to prevent re-identification. How should the architect configure governance?
**Respuesta:** Apply an aggregation policy on the shared dataset with a minimum group size of 20 — any query that produces groups with fewer than 20 patients is blocked. Additionally, apply projection policies on direct patient identifiers (patient_id, SSN) so researchers can use them in WHERE/JOIN/GROUP BY for cohort selection but cannot SELECT them in results. Share the data via secure views with these policies applied. This provides layered privacy: aggregation prevents small-group re-identification, and projection prevents direct identifier exposure.

**Escenario:** An internal audit requires understanding which roles accessed which PII columns over the past year, including data flows through views and downstream tables. What Snowflake feature supports this?
**Respuesta:** Query `SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY`, which provides column-level data lineage tracking with 365-day retention. It records which columns were read (`base_objects_accessed`) and written (`objects_modified`), by which role, including data flows through views and transformations. This supports audit requirements without requiring any custom logging infrastructure. Requires Enterprise edition or higher.

---

---

## 1.7 CUMPLIMIENTO

**Características de Edición para Cumplimiento**

| Requisito | Edición Mínima |
|---|---|
| HIPAA / HITRUST | Business Critical |
| PCI DSS | Business Critical |
| SOC 1/2 | Todas las ediciones |
| FedRAMP Moderate | Virtual Private Snowflake (VPS) en AWS GovCloud |
| ITAR | VPS en AWS GovCloud |
| Soporte de PHI | Business Critical con BAA |

**Tri-Secret Secure**

- La clave administrada por el cliente (CMK) envuelve la clave de Snowflake, que envuelve la clave de datos
- Requiere edición Business Critical
- Si el cliente revoca la CMK, Snowflake no puede descifrar los datos — control total del cliente
- Soportado en AWS (KMS), Azure (Key Vault), GCP (Cloud KMS)

**Storage Integrations**

- Acceso seguro y gobernado a almacenamiento en la nube externo (S3, GCS, Azure Blob)
- Usa roles IAM / service principals — sin credenciales en texto plano en SQL
- Requerido para external stages, external tables, acceso a data lake
- El parámetro `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` obliga su uso

### Por Qué Esto Importa
Una empresa de salud que almacena PHI necesita Business Critical + BAA + Tri-Secret Secure + PrivateLink. Si falta cualquiera, se rompe el cumplimiento HIPAA.

### Mejores Prácticas
- Habilitar Tri-Secret Secure para datos sobre los que necesitas control total
- Requerir storage integrations a nivel de cuenta para prevenir fuga de credenciales
- Documentar tu arquitectura de cumplimiento para los auditores
- Usar VPS solo cuando se requiera FedRAMP / ITAR (costo significativo)

**Trampa del examen:** SI VES "Tri-Secret Secure está disponible en la edición Enterprise" → **INCORRECTO** porque requiere Business Critical.

**Trampa del examen:** SI VES "el cumplimiento SOC 2 requiere Business Critical" → **INCORRECTO** porque los reportes SOC 2 están disponibles para todas las ediciones.

**Trampa del examen:** SI VES "Tri-Secret Secure significa que Snowflake no puede acceder a tus datos en absoluto" → **INCORRECTO** porque Snowflake aún administra la clave intermedia; el cliente controla la clave externa.

### Preguntas Frecuentes (FAQ)
**P: ¿Cuál es la diferencia entre Business Critical y VPS?**
R: Business Critical agrega cifrado, cumplimiento, PrivateLink. VPS agrega un despliegue de Snowflake dedicado y aislado (almacén de metadatos separado, cómputo separado).

**P: ¿Habilitar Tri-Secret Secure afecta el rendimiento?**
R: Insignificante. El envolvimiento de claves agrega una sobrecarga mínima.


### Ejemplos de Preguntas de Escenario — Compliance

**Escenario:** A US defense contractor needs to process ITAR-controlled data in Snowflake. They also have non-ITAR commercial workloads that don't require the same isolation. What Snowflake deployment model should the architect recommend?
**Respuesta:** Deploy a Virtual Private Snowflake (VPS) instance on AWS GovCloud specifically for the ITAR-controlled workloads. VPS provides a fully dedicated, isolated Snowflake deployment with a separate metadata store and compute infrastructure — the strongest isolation level Snowflake offers. For non-ITAR commercial workloads, use a standard Business Critical account in a commercial region. Both accounts can be managed under the same Snowflake Organization for centralized billing, but data and compute are completely separated. Never mix ITAR data with commercial workloads in the same account.

**Escenario:** A healthcare company stores PHI in Snowflake and must comply with HIPAA. Their CISO requires the ability to immediately revoke Snowflake's access to all data in case of a security incident. What combination of features should the architect implement?
**Respuesta:** Deploy on Business Critical edition (minimum for HIPAA/PHI support) and sign a Business Associate Agreement (BAA) with Snowflake. Enable Tri-Secret Secure, which adds a customer-managed key (CMK) via AWS KMS, Azure Key Vault, or GCP Cloud KMS that wraps Snowflake's encryption key. If the CISO needs to revoke access, they revoke the CMK — Snowflake immediately loses the ability to decrypt any data. Complement with PrivateLink for private connectivity, network policies to block all public access, and `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` to prevent credential leakage in stages.

---

---

## PARES CONFUSOS — Cuentas y Seguridad

| Preguntan sobre... | La respuesta es... | NO... |
|---|---|---|
| ¿Quién **crea usuarios/roles**? | **USERADMIN** | NO SECURITYADMIN (SECURITYADMIN *hereda* de USERADMIN pero su función propia es administrar grants) |
| ¿Quién **administra grants** (GRANT/REVOKE)? | **SECURITYADMIN** | NO USERADMIN (USERADMIN solo crea usuarios/roles) |
| ¿Quién **crea cuentas** en una organización? | **ORGADMIN** | NO ACCOUNTADMIN (ACCOUNTADMIN es por cuenta, no a nivel de organización) |
| **Roles funcionales** vs **roles de acceso** | **Funcional** = función de negocio (Data Analyst), **Acceso** = privilegios sobre objetos (READ_SALES) | No mezclar — los roles funcionales *heredan de* los roles de acceso |
| **Database roles** vs **roles de cuenta** | **Database roles** = limitados a una BD, portables con replicación/clonación | **Roles de cuenta** = a nivel de toda la cuenta, NO portables con la BD |
| **Network policy** vs **network rule** | **Policy** = lista de IPs permitidas/bloqueadas aplicada a cuenta/usuario | **Rule** = más granular (host, puerto, endpoint VPC), adjunta a policies |
| **Column masking** vs **row access policy** | **Masking** = oculta/reemplaza *valores* de columna | **RAP** = oculta *filas* completas — se aplica a tabla, no a columna |
| **Aggregation policy** vs **projection policy** | **Aggregation** = bloquea consultas por debajo del tamaño mínimo de grupo | **Projection** = evita que la columna aparezca en resultados SELECT |
| **External tokenization** vs **dynamic masking** | **External** = servicio de terceros (Protegrity) reemplaza el valor | **Dynamic masking** = integrado en Snowflake, basado en roles al momento de consulta |
| **PrivateLink** vs **VPN** | **PrivateLink** = conexión directa por backbone de nube, sin internet | **VPN** = túnel cifrado *sobre* internet |
| **Authentication policy** vs **security integration** | **Auth policy** = reglas de *cómo* los usuarios pueden iniciar sesión (MFA, tipos de cliente) | **Security integration** = *configuración* de SSO/OAuth con un IdP externo |
| Network policy a nivel de usuario + nivel de cuenta | A nivel de usuario **reemplaza** la de nivel de cuenta para ese usuario | NO es aditiva — la política de cuenta se *ignora* para ese usuario |
| **Snowflake OAuth** vs **External OAuth** | **Snowflake OAuth** = Snowflake emite el token (aplicaciones asociadas) | **External OAuth** = tu IdP emite el token |
| **SCIM** aprovisiona... | **Usuarios y grupos** automáticamente desde el IdP | NO roles — SCIM NO crea roles de Snowflake |
| Nivel de **MIN_DATA_RETENTION** | **Solo a nivel de cuenta** (establece un piso) | NO se puede establecer en esquema o tabla |

---

## ÁRBOLES DE DECISIÓN POR ESCENARIO — Cuentas y Seguridad

**Escenario 1: "Una empresa necesita datos completamente aislados para cumplimiento PCI..."**
- **CORRECTO:** **Cuentas** de Snowflake separadas (datos PCI en su propia cuenta, edición Business Critical)
- TRAMPA: *"Usar diferentes bases de datos en la misma cuenta"* — **INCORRECTO**, misma cuenta = metadatos compartidos, ACCOUNTADMIN compartido, no es aislamiento real

**Escenario 2: "Un analista debería ver SSNs enmascarados pero un gerente ve los reales..."**
- **CORRECTO:** **Dynamic data masking policy** con lógica CASE basada en roles
- TRAMPA: *"Crear dos vistas separadas"* — **INCORRECTO**, no es escalable, difícil de mantener, evade la gobernanza

**Escenario 3: "Bloquear todo el acceso por internet público a Snowflake..."**
- **CORRECTO:** **PrivateLink** + **network policy** bloqueando todas las IPs públicas
- TRAMPA: *"Solo usar una VPN"* — **INCORRECTO**, la VPN aún atraviesa internet público; PrivateLink se mantiene en el backbone de nube

**Escenario 4: "Una cuenta de servicio necesita conectarse a Snowflake desde un pipeline CI/CD..."**
- **CORRECTO:** **Autenticación por par de claves** (RSA 2048-bit)
- TRAMPA: *"Almacenar usuario/contraseña en variables de entorno"* — **INCORRECTO**, las contraseñas son menos seguras y no permiten aplicar MFA

**Escenario 5: "Prevenir que los dueños de tablas otorguen SELECT a roles no autorizados..."**
- **CORRECTO:** **Managed access schema** — solo el dueño del esquema/MANAGE GRANTS puede otorgar
- TRAMPA: *"Usar row access policies"* — **INCORRECTO**, las RAP filtran filas pero no previenen la escalación de grants

**Escenario 6: "Permitir filtrar por SSN en la cláusula WHERE pero nunca mostrar la columna..."**
- **CORRECTO:** **Projection policy** en la columna SSN
- TRAMPA: *"Masking policy"* — **INCORRECTO**, masking aún muestra la columna (con valor enmascarado). Projection la oculta completamente del SELECT

**Escenario 7: "Aplicar MFA para usuarios de Snowsight pero no para cuentas de servicio JDBC..."**
- **CORRECTO:** **Authentication policy** con `CLIENT_TYPES` configurado para aplicar MFA solo para `SNOWFLAKE_UI`
- TRAMPA: *"Network policy"* — **INCORRECTO**, las network policies controlan acceso por IP, no métodos de autenticación

**Escenario 8: "Asegurar que Time Travel nunca pueda establecerse por debajo de 7 días en ninguna tabla..."**
- **CORRECTO:** Establecer **`MIN_DATA_RETENTION_TIME_IN_DAYS = 7`** a nivel de cuenta
- TRAMPA: *"Establecer DATA_RETENTION_TIME_IN_DAYS = 7 en cada esquema"* — **INCORRECTO**, los objetos individuales pueden sobreescribir la configuración del esquema; solo MIN a nivel de cuenta establece un piso verdadero

**Escenario 9: "Las consultas analíticas deben agregar al menos 10 pacientes antes de mostrar resultados..."**
- **CORRECTO:** **Aggregation policy** con tamaño mínimo de grupo de 10
- TRAMPA: *"Row access policy"* — **INCORRECTO**, las RAP filtran filas por rol; no aplican tamaños mínimos de grupo

**Escenario 10: "El cliente quiere control total para revocar el acceso de Snowflake a sus datos..."**
- **CORRECTO:** **Tri-Secret Secure** (la clave del cliente envuelve la clave de Snowflake) en **Business Critical**
- TRAMPA: *"Solo usar el cifrado integrado de Snowflake"* — **INCORRECTO**, el cifrado predeterminado no le da al cliente un interruptor de corte

**Escenario 11: "5,000 usuarios necesitan SSO, con grupos auto-sincronizados desde Okta..."**
- **CORRECTO:** **Security integration SAML 2.0** para SSO + **SCIM** para aprovisionamiento de usuarios/grupos
- TRAMPA: *"Crear usuarios manualmente con contraseñas"* — **INCORRECTO**, no es escalable, sin desaprovisionamiento automático

**Escenario 12: "Nueva columna PII agregada — debe ser enmascarada automáticamente sin intervención manual..."**
- **CORRECTO:** **Enmascaramiento basado en tags** — etiquetar la columna como PII, la masking policy se auto-aplica a todas las columnas con ese tag
- TRAMPA: *"Aplicar una nueva masking policy a cada columna manualmente"* — **INCORRECTO**, no es escalable, fácil de omitir columnas

---

## TARJETAS DE REPASO -- Dominio 1

**P1:** ¿Qué rol puede crear nuevas cuentas en una Snowflake Organization?
**R1:** Solo ORGADMIN.

**P2:** Si un parámetro de sesión y un parámetro de cuenta entran en conflicto, ¿cuál gana?
**R2:** El parámetro de sesión (el más específico gana).

**P3:** ¿Cuál es la edición mínima para PrivateLink?
**R3:** Business Critical.

**P4:** ¿Cuántas masking policies se pueden aplicar a una sola columna?
**R4:** Una.

**P5:** ¿Cuál es la diferencia entre un rol funcional y un rol de acceso?
**R5:** Los roles de acceso contienen privilegios sobre objetos; los roles funcionales representan funciones laborales y heredan de los roles de acceso.

**P6:** ¿Qué proporciona Tri-Secret Secure?
**R6:** Clave administrada por el cliente que envuelve la clave de Snowflake — el cliente puede revocar el acceso a sus datos.

**P7:** ¿Los database roles se pueden otorgar directamente a usuarios?
**R7:** No. Deben otorgarse a roles a nivel de cuenta (u otros database roles dentro de la misma base de datos).

**P8:** ¿Qué hace `MIN_DATA_RETENTION_TIME_IN_DAYS`?
**R8:** Establece un piso para la retención de Time Travel que los objetos individuales no pueden reducir.

**P9:** ¿Qué método de autenticación deberían usar las cuentas de servicio?
**R9:** Autenticación por par de claves.

**P10:** ¿Cuál es el propósito de una projection policy?
**R10:** Evita que una columna aparezca en los resultados SELECT mientras permite su uso en WHERE/JOIN/GROUP BY.

**P11:** ¿Qué hace SCIM en Snowflake?
**R11:** Automatiza el aprovisionamiento/desaprovisionamiento de usuarios y grupos desde un IdP externo.

**P12:** Cuando se establece una network policy a nivel de usuario, ¿qué pasa con la política a nivel de cuenta para ese usuario?
**R12:** La política a nivel de usuario reemplaza completamente (no se fusiona con) la política a nivel de cuenta.

**P13:** ¿Qué edición se requiere para row access policies?
**R13:** Enterprise o superior.

**P14:** ¿Cuál es el período de retención de ACCESS_HISTORY?
**R14:** 365 días.

**P15:** ¿Se pueden combinar aggregation policies con masking policies en la misma tabla?
**R15:** Sí. Sirven para propósitos diferentes y pueden coexistir.

---

## EXPLÍCALO COMO SI TUVIERA 5 AÑOS -- Dominio 1

**1. Estrategia Multi-Cuenta**
Imagina que tienes diferentes cajas de juguetes para diferentes cuartos. La caja del dormitorio tiene juguetes para dormir, la caja del cuarto de juegos tiene juguetes para ensuciarse. Los mantienes separados para que la brillantina no llegue a tu almohada. Eso es multi-cuenta — cajas separadas para cosas separadas.

**2. Jerarquía de Parámetros**
Tus papás dicen "a dormir a las 8pm" (regla de cuenta). Pero para TU cuarto, es "a dormir a las 8:30pm" (regla de objeto). Y esta noche, como es tu cumpleaños, es "a dormir a las 9pm" (regla de sesión). ¡La regla más específica gana!

**3. Herencia de Roles**
Eres el "monitor de galletas" en la escuela. Eso significa que puedes repartir galletas. Tu maestra es la "jefa del salón" y ella tiene TODOS los poderes de monitor, incluyendo los tuyos. Los poderes fluyen HACIA ARRIBA.

**4. Network Policies**
Es como la lista de invitados en una fiesta de cumpleaños. Solo los niños en la lista pueden entrar. Si tu mamá hace una lista especial solo para ti, reemplaza la lista principal — no se suma a ella.

**5. PrivateLink**
En vez de caminar a la casa de tu amigo por la banqueta pública, construyes un túnel secreto entre sus casas. Nadie más puede verte caminar. Eso es PrivateLink.

**6. Masking Policies**
Escribes una nota secreta. Cuando tu mejor amigo la lee, ve las palabras reales. Cuando cualquier otro la lee, ve "XXXXX." Misma nota, diferentes vistas.

**7. Row Access Policies**
Un libro mágico para colorear donde solo puedes ver las páginas que tienen TU nombre. Otros niños tienen el mismo libro pero ven páginas diferentes.

**8. Tri-Secret Secure**
Cierras tu diario con TU candado. Luego lo pones en una caja con el candado de SNOWFLAKE. Se necesitan ambos candados para leerlo. Puedes quitar tu candado en cualquier momento y nadie puede leerlo.

**9. SSO / SAML**
En vez de recordar una contraseña para cada sitio web, tienes una llave mágica (tu credencial de la escuela) que abre todas las puertas.

**10. Object Tagging**
Poner stickers de colores en tus juguetes: rojo para "frágil," azul para "compartir con amigos." Después puedes decir "esconde TODOS los juguetes con sticker rojo" sin listar cada uno.
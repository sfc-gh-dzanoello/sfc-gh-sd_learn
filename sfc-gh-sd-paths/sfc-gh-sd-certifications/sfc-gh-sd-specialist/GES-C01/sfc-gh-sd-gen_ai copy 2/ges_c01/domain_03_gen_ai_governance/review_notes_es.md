# Dominio 3: Gobernanza de Snowflake Gen AI (26%)

## Control de Acceso para Funciones Cortex

### Modelo RBAC

Las funciones de Cortex AI residen bajo el esquema `SNOWFLAKE.CORTEX`. El acceso se gestiona mediante el control de acceso basado en roles (RBAC) estandar de Snowflake, combinado con un rol de base de datos dedicado.

Existen dos capas de control de acceso:

1. **Nivel de cuenta** -- el administrador de la cuenta debe habilitar las funciones de Cortex para la cuenta
2. **Nivel de rol** -- los roles individuales deben recibir el rol de base de datos `CORTEX_USER` o privilegios sobre funciones especificas

### El Rol de Base de Datos CORTEX_USER

El rol de base de datos `SNOWFLAKE.CORTEX.CORTEX_USER` es el mecanismo principal para otorgar acceso a las funciones de Cortex AI. Es un **rol de base de datos** en la base de datos `SNOWFLAKE`, no un rol de cuenta.

**Lo que otorga:**
- Acceso a todas las funciones LLM de Cortex generalmente disponibles (COMPLETE, SUMMARIZE, TRANSLATE, SENTIMENT, EXTRACT_ANSWER, etc.)
- Acceso a las funciones de embedding de Cortex (EMBED_TEXT_768, EMBED_TEXT_1024)
- NO otorga acceso a funciones administrativas a nivel de cuenta

**Caracteristicas importantes:**
- Es un rol de base de datos predefinido -- no se pueden modificar sus privilegios
- Debe otorgarse a roles de cuenta, no directamente a usuarios
- Otorgar este rol es el enfoque recomendado para la mayoria de los casos de uso
- Por defecto, solo ACCOUNTADMIN tiene acceso a las funciones de Cortex hasta que se otorgue explicitamente CORTEX_USER

### Otorgar el Rol CORTEX_USER

```sql
-- Otorgar CORTEX_USER a un rol de cuenta
USE ROLE ACCOUNTADMIN;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX.CORTEX_USER TO ROLE data_analyst;

-- Otorgar a multiples roles
GRANT DATABASE ROLE SNOWFLAKE.CORTEX.CORTEX_USER TO ROLE data_scientist;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX.CORTEX_USER TO ROLE ml_engineer;

-- Verificar el otorgamiento
SHOW GRANTS OF DATABASE ROLE SNOWFLAKE.CORTEX.CORTEX_USER;

-- Revocar acceso
REVOKE DATABASE ROLE SNOWFLAKE.CORTEX.CORTEX_USER FROM ROLE data_analyst;
```

### Otorgar/Revocar Acceso a Funciones Especificas

Para un control mas granular, se puede otorgar o revocar acceso a funciones individuales de Cortex en lugar del rol CORTEX_USER completo:

```sql
-- Otorgar acceso solo a la funcion COMPLETE
USE ROLE ACCOUNTADMIN;
GRANT USAGE ON FUNCTION SNOWFLAKE.CORTEX.COMPLETE(VARCHAR, VARCHAR)
  TO ROLE limited_ai_role;

-- Otorgar acceso solo a SUMMARIZE
GRANT USAGE ON FUNCTION SNOWFLAKE.CORTEX.SUMMARIZE(VARCHAR)
  TO ROLE summarizer_role;

-- Revocar una funcion especifica
REVOKE USAGE ON FUNCTION SNOWFLAKE.CORTEX.COMPLETE(VARCHAR, VARCHAR)
  FROM ROLE limited_ai_role;

-- Otorgar SENTIMENT para un rol de reportes
GRANT USAGE ON FUNCTION SNOWFLAKE.CORTEX.SENTIMENT(VARCHAR)
  TO ROLE reporting_role;
```

**Punto clave para el examen:** Otorgar acceso a funciones individuales proporciona acceso de minimo privilegio. Esto es mas restrictivo que otorgar el rol completo CORTEX_USER.

### Jerarquia de Privilegios

```
ACCOUNTADMIN
  |
  +-- SNOWFLAKE.CORTEX.CORTEX_USER (rol de base de datos)
  |     |
  |     +-- Todas las funciones LLM de Cortex
  |     +-- Funciones de embedding
  |
  +-- Otorgamientos individuales de USAGE sobre funciones
        |
        +-- Solo la funcion especifica
```

## Gobernanza de Costos y Monitoreo

### Modelo de Consumo de Creditos

Las funciones de Cortex consumen **creditos serverless** -- no utilizan creditos de virtual warehouse. Cada llamada a funcion consume creditos basandose en:
- **Tokens de entrada** -- el texto enviado al modelo
- **Tokens de salida** -- el texto generado por el modelo
- **Tamano del modelo** -- modelos mas grandes cuestan mas por token
- **Tipo de funcion** -- COMPLETE cuesta mas que SENTIMENT por llamada

### Monitoreo via Vistas de ACCOUNT_USAGE

```sql
-- Monitorear el consumo de creditos de Cortex a lo largo del tiempo
SELECT
    start_time::DATE AS usage_date,
    service_type,
    name AS function_name,
    SUM(credits_used) AS total_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.METERING_HISTORY
WHERE service_type = 'AI_SERVICES'
  AND start_time >= DATEADD('day', -30, CURRENT_TIMESTAMP())
GROUP BY 1, 2, 3
ORDER BY total_credits DESC;

-- Uso detallado de Cortex a nivel de consulta
SELECT
    query_id,
    user_name,
    role_name,
    query_text,
    credits_used_cloud_services,
    start_time,
    total_elapsed_time
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text ILIKE '%SNOWFLAKE.CORTEX%'
  AND start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;

-- Uso de creditos por rol para identificar los mayores consumidores
SELECT
    role_name,
    COUNT(*) AS query_count,
    SUM(credits_used_cloud_services) AS total_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text ILIKE '%SNOWFLAKE.CORTEX%'
  AND start_time >= DATEADD('day', -30, CURRENT_TIMESTAMP())
GROUP BY role_name
ORDER BY total_credits DESC;
```

### Monitores de Recursos

Los monitores de recursos pueden usarse para establecer limites de creditos y recibir alertas cuando el uso de Cortex se acerca a los umbrales:

```sql
-- Crear un monitor de recursos para el gasto general de la cuenta
-- (cubre creditos serverless incluyendo Cortex)
CREATE OR REPLACE RESOURCE MONITOR cortex_monitor
  WITH CREDIT_QUOTA = 1000
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 75 PERCENT DO NOTIFY
    ON 90 PERCENT DO NOTIFY
    ON 100 PERCENT DO SUSPEND;
```

### Presupuestos

Los Presupuestos de Snowflake proporcionan controles de gasto mas granulares:

```sql
-- Crear un presupuesto para rastrear el gasto en servicios de AI
-- Los presupuestos pueden limitarse a funciones serverless especificas
CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!SET_SPENDING_LIMIT(5000);
```

## Privacidad de Datos con Cortex

### Politicas de Enmascaramiento y Cortex

Las politicas de enmascaramiento dinamico de datos se aplican **antes** de que los datos lleguen a las funciones de Cortex. Si una columna tiene una politica de enmascaramiento, el valor enmascarado es lo que se envia al LLM.

```sql
-- Crear una politica de enmascaramiento para PII
CREATE OR REPLACE MASKING POLICY pii_mask AS (val STRING)
  RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('PII_ADMIN') THEN val
    ELSE '***MASKED***'
  END;

-- Aplicar a una columna
ALTER TABLE customer_feedback
  MODIFY COLUMN customer_email SET MASKING POLICY pii_mask;

-- Cuando un rol que no es PII_ADMIN ejecuta esto:
-- El LLM recibe '***MASKED***' en lugar del email real
SELECT SNOWFLAKE.CORTEX.SUMMARIZE(customer_email || ': ' || feedback_text)
FROM customer_feedback;
```

**Punto critico para el examen:** Las politicas de enmascaramiento protegen los datos enviados A las funciones de Cortex. El LLM solo ve el valor enmascarado. Esta es una salvaguarda clave de privacidad.

### Politicas de Acceso a Filas

Las politicas de acceso a filas filtran que filas puede ver un usuario. Este filtrado se aplica **antes** de que las funciones de Cortex se ejecuten:

```sql
-- Crear una politica de acceso a filas
CREATE OR REPLACE ROW ACCESS POLICY region_policy AS (region_col VARCHAR)
  RETURNS BOOLEAN ->
  CASE
    WHEN CURRENT_ROLE() = 'GLOBAL_ADMIN' THEN TRUE
    WHEN region_col = 'US' AND CURRENT_ROLE() = 'US_ANALYST' THEN TRUE
    ELSE FALSE
  END;

-- Aplicar a la tabla
ALTER TABLE customer_feedback
  ADD ROW ACCESS POLICY region_policy ON (region);

-- El rol US_ANALYST solo procesa filas de US a traves de Cortex
SELECT SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) AS sentiment
FROM customer_feedback;
-- Solo se procesan las filas de la region US
```

### Interaccion de Politicas de Enmascaramiento con la Salida de Cortex

Tambien se pueden aplicar politicas de enmascaramiento a la salida de vistas que usan funciones de Cortex:

```sql
-- Crear una vista con analisis de Cortex
CREATE OR REPLACE VIEW enriched_feedback AS
SELECT
    feedback_id,
    customer_email,
    feedback_text,
    SNOWFLAKE.CORTEX.SENTIMENT(feedback_text) AS sentiment_score,
    SNOWFLAKE.CORTEX.SUMMARIZE(feedback_text) AS summary
FROM customer_feedback;

-- Aplicar enmascaramiento a las columnas de salida de Cortex
CREATE OR REPLACE MASKING POLICY hide_summary AS (val STRING)
  RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('AI_ADMIN', 'DATA_SCIENTIST') THEN val
    ELSE 'Acceso restringido'
  END;

ALTER VIEW enriched_feedback
  MODIFY COLUMN summary SET MASKING POLICY hide_summary;
```

## Politicas de Agregacion con Funciones Cortex

### Que Son las Politicas de Agregacion

Las politicas de agregacion imponen un **tamano minimo de grupo** para los resultados de consultas, previniendo la identificacion de individuos en datos agregados. Funcionan con las funciones de Cortex para asegurar que los analisis impulsados por AI respeten las restricciones de privacidad.

### MIN_GROUP_SIZE

El parametro `MIN_GROUP_SIZE` define el numero minimo de filas que deben existir en un grupo para que se devuelvan resultados.

```sql
-- Crear una politica de agregacion
CREATE OR REPLACE AGGREGATION POLICY min_group_policy
  AS () RETURNS AGGREGATION_CONSTRAINT ->
  AGGREGATION_CONSTRAINT(MIN_GROUP_SIZE => 5);

-- Aplicar a una tabla
ALTER TABLE patient_feedback
  SET AGGREGATION POLICY min_group_policy;
```

### Que Sucede Cuando se Viola MIN_GROUP_SIZE

- Si un grupo de resultados de consulta tiene menos filas que `MIN_GROUP_SIZE`, el grupo se **excluye** de los resultados
- La consulta NO falla -- simplemente devuelve menos filas (o cero)
- Esto aplica tambien a los resultados de funciones de Cortex
- Si ejecutas `SNOWFLAKE.CORTEX.SENTIMENT()` sobre datos agrupados y un grupo tiene muy pocas filas, los resultados de ese grupo se suprimen

### Interaccion con Cortex

```sql
-- Con politica de agregacion (MIN_GROUP_SIZE = 5) aplicada:
-- Los grupos con menos de 5 entradas de feedback se excluyen
SELECT
    department,
    AVG(SNOWFLAKE.CORTEX.SENTIMENT(feedback_text)) AS avg_sentiment,
    COUNT(*) AS feedback_count
FROM employee_feedback
GROUP BY department;
-- Los departamentos con < 5 feedbacks no apareceran en los resultados
```

**Nota de examen:** Las politicas de agregacion previenen ataques de re-identificacion. Cuando se combinan con funciones de Cortex, aseguran que el analisis de AI no pueda exponer registros individuales.

## Politicas de Red y Cortex

### Conectividad Privada

Las funciones de Cortex AI pueden accederse mediante conectividad privada para asegurar que el trafico de red no atraviese internet publico.

**Mecanismos clave:**
- **AWS PrivateLink** -- endpoint privado para Snowflake, cubriendo el trafico de Cortex
- **Azure Private Link** -- lo mismo para cuentas alojadas en Azure
- **Google Cloud Private Service Connect** -- lo mismo para GCP

### Como se Aplican las Politicas de Red

Las politicas de red restringen **que direcciones IP** pueden conectarse a Snowflake. Como las funciones de Cortex se llaman via SQL dentro de Snowflake, la politica de red se aplica a nivel de sesion:

```sql
-- Crear una politica de red
CREATE OR REPLACE NETWORK POLICY cortex_network_policy
  ALLOWED_IP_LIST = ('10.0.0.0/8', '172.16.0.0/12')
  BLOCKED_IP_LIST = ()
  COMMENT = 'Restringir acceso a Cortex a redes internas';

-- Aplicar a nivel de cuenta
ALTER ACCOUNT SET NETWORK_POLICY = cortex_network_policy;

-- O aplicar a usuarios especificos
ALTER USER service_account SET NETWORK_POLICY = cortex_network_policy;
```

**Importante:** Las funciones de Cortex se ejecutan del lado del servidor dentro de Snowflake. Las politicas de red controlan quien puede establecer una sesion, no las llamadas a funciones de Cortex en si. Una vez que un usuario tiene una sesion autenticada, las llamadas a Cortex pasan por la infraestructura interna de Snowflake.

### Configuracion de PrivateLink

Cuando PrivateLink esta configurado:
- Todo el trafico de Snowflake (incluyendo Cortex) fluye a traves del endpoint privado
- Ningun dato transita por internet publico
- La resolucion DNS apunta a IPs privadas
- Esta es la configuracion recomendada para cargas de trabajo de produccion con datos sensibles

## Autenticacion por Par de Claves para Cuentas de Servicio

### Por Que Autenticacion por Par de Claves

Las cuentas de servicio que llaman funciones de Cortex programaticamente deben usar **autenticacion por par de claves** en lugar de contrasenas por:
- Eliminacion de la complejidad de rotacion de contrasenas
- Habilitacion de pipelines automatizados (sin inicio de sesion interactivo)
- Mayor seguridad criptografica
- Sin riesgo de filtracion de contrasenas en codigo o logs

### Configuracion

```sql
-- Generar par de claves RSA (se hace fuera de Snowflake)
-- openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt
-- openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub

-- Asignar clave publica al usuario
ALTER USER cortex_service_account SET RSA_PUBLIC_KEY = 'MIIBIjANBgkqh...';

-- La cuenta de servicio se conecta usando la clave privada
-- No se necesita contrasena en la configuracion de conexion
```

### Mejores Practicas para Cuentas de Servicio que Llaman Cortex
- Usar cuentas de servicio dedicadas por aplicacion
- Asignar los privilegios minimos necesarios de Cortex (funciones especificas, no CORTEX_USER completo si es posible)
- Rotar pares de claves regularmente
- Almacenar claves privadas en sistemas de gestion de secretos (no en codigo)
- Aplicar politicas de red para restringir el acceso de cuentas de servicio

## Auditoria y Cumplimiento

### Historial de Consultas

Todas las llamadas a funciones de Cortex aparecen en el historial de consultas, permitiendo auditabilidad completa:

```sql
-- Encontrar todas las llamadas a funciones de Cortex en los ultimos 30 dias
SELECT
    query_id,
    user_name,
    role_name,
    warehouse_name,
    query_text,
    start_time,
    end_time,
    execution_status
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text ILIKE '%SNOWFLAKE.CORTEX.COMPLETE%'
   OR query_text ILIKE '%SNOWFLAKE.CORTEX.SUMMARIZE%'
   OR query_text ILIKE '%SNOWFLAKE.CORTEX.SENTIMENT%'
   OR query_text ILIKE '%SNOWFLAKE.CORTEX.TRANSLATE%'
   OR query_text ILIKE '%SNOWFLAKE.CORTEX.EXTRACT_ANSWER%'
AND start_time >= DATEADD('day', -30, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;
```

### Historial de Acceso

El historial de acceso rastrea que tablas y columnas fueron accedidas por las llamadas a funciones de Cortex:

```sql
-- Rastrear que objetos de datos fueron accedidos via llamadas a Cortex
SELECT
    query_id,
    user_name,
    direct_objects_accessed,
    base_objects_accessed,
    query_start_time
FROM SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY
WHERE query_start_time >= DATEADD('day', -30, CURRENT_TIMESTAMP())
  AND ARRAY_SIZE(direct_objects_accessed) > 0
ORDER BY query_start_time DESC;
```

**Punto de examen:** El historial de acceso captura el linaje de datos que fluyen hacia las funciones de Cortex. Esto es critico para auditorias de cumplimiento -- se puede rastrear exactamente que tablas/columnas fueron procesadas por funciones de AI y por quien.

### Historial de Inicio de Sesion

Para auditar cuentas de servicio que llaman Cortex:

```sql
SELECT
    user_name,
    event_type,
    is_success,
    client_ip,
    first_authentication_factor,
    event_timestamp
FROM SNOWFLAKE.ACCOUNT_USAGE.LOGIN_HISTORY
WHERE user_name = 'CORTEX_SERVICE_ACCOUNT'
  AND event_timestamp >= DATEADD('day', -30, CURRENT_TIMESTAMP())
ORDER BY event_timestamp DESC;
```

## Seguridad de Contenido y Guardrails

### El Parametro Guardrails en COMPLETE

La funcion `COMPLETE` soporta un parametro `guardrails` que habilita el filtrado de seguridad de contenido:

```sql
-- Habilitar guardrails para seguridad de contenido
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-large2',
    'Resumir este feedback del cliente: ...',
    {
        'guardrails': TRUE
    }
);

-- Guardrails con otras opciones
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-large2',
    [
        {'role': 'system', 'content': 'Eres un asistente util.'},
        {'role': 'user', 'content': 'Analiza este texto...'}
    ],
    {
        'guardrails': TRUE,
        'temperature': 0.3,
        'max_tokens': 1024
    }
);
```

### Que Hacen los Guardrails
- Filtran contenido potencialmente danino o inapropiado en **ambos** entrada y salida
- Bloquean prompts inseguros antes de que lleguen al modelo
- Sanitizan la salida del modelo que pueda contener contenido danino
- Operan como un filtro de pasa/no pasa -- el contenido pasa o se bloquea
- Cuando el contenido se bloquea, la funcion devuelve un mensaje de seguridad en lugar de la salida del modelo

### Cuando Usar Guardrails
- Aplicaciones orientadas al cliente donde la salida se muestra directamente a usuarios finales
- Aplicaciones que procesan contenido generado por usuarios
- Casos de uso con requisitos regulatorios de seguridad de contenido
- Cualquier escenario donde la salida no controlada del LLM represente riesgo reputacional o legal

**Consejo de examen:** El parametro guardrails es especifico de la funcion COMPLETE. Otras funciones de Cortex (SENTIMENT, TRANSLATE, etc.) tienen limitaciones de alcance incorporadas que reducen los riesgos de seguridad.

## Disponibilidad de Modelos por Region y Nube

### Disponibilidad Regional

No todos los modelos de Cortex estan disponibles en todas las regiones de Snowflake. La disponibilidad depende de:
- **Proveedor de nube** (AWS, Azure, GCP)
- **Region** (us-west-2, us-east-1, eu-west-1, etc.)
- **Licenciamiento del modelo** y despliegue de infraestructura

### Datos Clave para el Examen
- Las regiones US de AWS tipicamente tienen la seleccion mas amplia de modelos
- Algunos modelos pueden estar disponibles en regiones US pero no en EU/APAC
- Los modelos Snowflake Arctic tienen la disponibilidad mas amplia (modelos propios de Snowflake)
- La disponibilidad de modelos puede cambiar conforme Snowflake expande su infraestructura
- Si un modelo no esta disponible en tu region, la llamada a la funcion devuelve un error
- Consultar la documentacion de Snowflake para la matriz de disponibilidad actual

### Consideraciones entre Regiones
- No se puede llamar a un modelo en una region diferente a la region de tu cuenta
- Los requisitos de residencia de datos pueden limitar que modelos puedes usar
- Para cumplimiento (ej., GDPR), asegurar que los modelos esten disponibles en la region requerida

## Limites de Tasa y Cuotas

### Limites por Cuenta
- Las funciones de Cortex tienen **limites de tasa** por cuenta para asegurar un uso justo
- Los limites se miden en **tokens por minuto** (TPM) y **solicitudes por minuto** (RPM)
- Los limites varian por modelo y funcion
- Los modelos mas grandes generalmente tienen limites de tasa mas bajos

### Comportamiento Cuando se Alcanzan los Limites
- Las solicitudes se **limitan** -- reciben errores HTTP 429 (limite de tasa excedido)
- El sistema no encola solicitudes; el llamador debe implementar logica de reintento
- Los limites de tasa se restablecen por minuto

### Mejores Practicas para Limites de Tasa
- Implementar reintento con backoff exponencial en el codigo de la aplicacion
- Agrupar operaciones cuando sea posible para reducir el conteo de solicitudes
- Usar modelos mas pequenos para tareas de alto volumen y baja complejidad
- Monitorear el uso para mantenerse dentro de los limites
- Contactar al soporte de Snowflake si los limites son insuficientes para tu carga de trabajo

## Mejores Practicas para Gobernanza en Produccion

### Mejores Practicas de Control de Acceso
1. **Minimo privilegio** -- otorgar acceso a funciones especificas en lugar del CORTEX_USER completo cuando sea posible
2. **Roles dedicados** -- crear roles especificamente para patrones de acceso a Cortex
3. **Cuentas de servicio** -- usar autenticacion por par de claves para pipelines automatizados
4. **Auditorias regulares** -- revisar quien tiene acceso a Cortex trimestralmente

### Mejores Practicas de Gestion de Costos
1. **Monitorear continuamente** -- configurar dashboards usando vistas de ACCOUNT_USAGE
2. **Establecer presupuestos** -- usar monitores de recursos y presupuestos para limitar el gasto
3. **Dimensionar modelos correctamente** -- usar el modelo mas pequeno que cumpla los requisitos de calidad
4. **Cachear resultados** -- almacenar salidas de Cortex en tablas para evitar llamadas redundantes
5. **Procesamiento por lotes** -- procesar datos en lotes durante horas de menor actividad

### Mejores Practicas de Privacidad de Datos
1. **Politicas de enmascaramiento primero** -- aplicar enmascaramiento antes de que los datos entren a funciones de Cortex
2. **Politicas de acceso a filas** -- limitar que filas se procesan por rol
3. **Politicas de agregacion** -- prevenir la identificacion individual en resultados agrupados
4. **Rastros de auditoria** -- aprovechar el historial de consultas y acceso para cumplimiento

### Mejores Practicas de Seguridad
1. **PrivateLink** -- usar conectividad privada para cargas de trabajo de produccion
2. **Politicas de red** -- restringir el acceso a rangos de IP conocidos
3. **Guardrails** -- habilitar seguridad de contenido para aplicaciones orientadas al usuario
4. **Rotacion de claves** -- rotar pares de claves de cuentas de servicio regularmente
5. **Sin secretos en prompts** -- nunca incrustar credenciales o secretos en prompts de LLM

### Mejores Practicas Operacionales
1. **Manejo de errores** -- implementar logica de reintento para limites de tasa y errores transitorios
2. **Conciencia regional** -- verificar la disponibilidad del modelo antes de desplegar
3. **Fijar versiones** -- rastrear que modelos usa tu aplicacion
4. **Pruebas** -- probar las salidas de Cortex por calidad antes del despliegue en produccion
5. **Monitoreo** -- alertar sobre anomalias de costos, picos de tasa de error y cambios de latencia

## Temas Clave del Examen para Recordar

1. **CORTEX_USER es un rol de base de datos** en la base de datos SNOWFLAKE, no un rol de cuenta -- debe otorgarse a roles de cuenta via `GRANT DATABASE ROLE SNOWFLAKE.CORTEX.CORTEX_USER TO ROLE <nombre_rol>`
2. **El acceso granular** es posible otorgando USAGE sobre funciones de Cortex especificas en lugar del rol CORTEX_USER completo
3. **Las politicas de enmascaramiento se aplican antes de Cortex** -- el LLM solo ve valores enmascarados, protegiendo PII
4. **Las politicas de acceso a filas filtran filas antes del procesamiento de Cortex** -- los usuarios solo analizan datos que estan autorizados a ver
5. **Las politicas de agregacion con MIN_GROUP_SIZE** suprimen grupos por debajo del umbral -- las consultas no fallan, devuelven menos filas
6. **Cortex usa creditos serverless** -- no creditos de warehouse; monitorear via SNOWFLAKE.ACCOUNT_USAGE.METERING_HISTORY con service_type = 'AI_SERVICES'
7. **El parametro guardrails en COMPLETE** habilita el filtrado de seguridad de contenido tanto en entrada como en salida
8. **No todos los modelos estan disponibles en todas las regiones** -- la disponibilidad depende del proveedor de nube y la region; los modelos Arctic tienen la disponibilidad mas amplia
9. **Los limites de tasa son por cuenta** medidos en tokens por minuto y solicitudes por minuto -- los limites excedidos devuelven errores de throttling, no solicitudes en cola
10. **El historial de consultas y el historial de acceso** proporcionan rastros de auditoria completos para todas las llamadas a funciones de Cortex, rastreando quien llamo que funcion sobre que datos
11. **La autenticacion por par de claves** es recomendada para cuentas de servicio que llaman Cortex -- elimina la gestion de contrasenas y soporta automatizacion
12. **PrivateLink asegura que el trafico de Cortex sea privado** -- combinado con politicas de red, esta es la postura de seguridad recomendada para produccion

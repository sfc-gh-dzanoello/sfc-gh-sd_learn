# Dominio 5: Compartir y Colaborar -- Soluciones de Intercambio de Datos

> **Peso en ARA-C01:** ~10-15% del examen.
> Enfoque en: mecanica de comparticion, patrones cross-region/cloud, cuentas reader, marketplace y Native Apps.

---

## 5.1 INTERCAMBIO SEGURO DE DATOS (SECURE DATA SHARING)

El modelo de **comparticion sin copia (zero-copy sharing)** es el diferenciador principal de Snowflake.

### Conceptos Clave

- **Provider (Proveedor)**: la cuenta que posee los datos y crea el share
- **Consumer (Consumidor)**: la cuenta que recibe el share y crea una base de datos a partir de el
- El intercambio es **zero-copy** -- no se duplican datos; el consumidor lee del almacenamiento del proveedor
- El proveedor paga el **almacenamiento**; el consumidor paga el **computo** (su propio warehouse)
- El intercambio usa **shares** -- objetos con nombre que contienen bases de datos, esquemas, tablas, vistas seguras y UDFs

**Que se puede compartir:**

- Tablas (completas o filtradas mediante vistas seguras)
- Secure views, secure materialized views
- Secure UDFs
- Esquemas (todos los objetos dentro de ellos)

**Que NO se puede compartir directamente:**

- Vistas no seguras (deben ser SECURE)
- Stages, pipes, tasks, streams
- Stored procedures
- Tablas temporales/transitorias (temporary/transient)

**Flujo de creacion de un share:**

```sql
CREATE SHARE my_share;
GRANT USAGE ON DATABASE mydb TO SHARE my_share;
GRANT USAGE ON SCHEMA mydb.public TO SHARE my_share;
GRANT SELECT ON TABLE mydb.public.customers TO SHARE my_share;
ALTER SHARE my_share ADD ACCOUNTS = consumer_account;
```

**Lado del consumidor:**

```sql
CREATE DATABASE shared_db FROM SHARE provider_account.my_share;
```

### Por Que Importa

Un proveedor de servicios de salud necesita compartir datos anonimizados de pacientes con un socio de investigacion. Crean una vista segura que enmascara la informacion personal (PII), la agregan a un share, y el socio la consulta directamente -- sin copias de datos, sin pipelines ETL, sin datos desactualizados. En tiempo real, siempre actualizado.

### Mejores Practicas

- Siempre usar **secure views** para controlar lo que ven los consumidores (filtrado a nivel de fila y columna)
- Otorgar solo los objetos minimos necesarios -- no compartir bases de datos completas a menos que sea necesario
- Monitorear el acceso a datos compartidos via `SNOWFLAKE.ACCOUNT_USAGE.DATA_TRANSFER_HISTORY`
- Documentar los shares y revisarlos trimestralmente

**Trampas del examen:**

- Trampa: SI VES "El consumidor paga el almacenamiento de datos compartidos" --> INCORRECTO porque el **proveedor** paga el almacenamiento; el consumidor solo paga el computo
- Trampa: SI VES "Las vistas regulares se pueden compartir" --> INCORRECTO porque solo las **secure views** pueden incluirse en shares; las vistas no seguras exponen la logica interna
- Trampa: SI VES "Los datos compartidos pueden ser modificados por el consumidor" --> INCORRECTO porque los datos compartidos son de **solo lectura** para los consumidores; no pueden hacer INSERT/UPDATE/DELETE
- Trampa: SI VES "Los shares crean una copia de los datos" --> INCORRECTO porque los shares son **zero-copy**; los consumidores consultan directamente las micro-particiones del proveedor

### Preguntas Frecuentes (FAQ)

**P: Puede un consumidor re-compartir datos que recibio?**
R: No. Los consumidores no pueden crear shares a partir de bases de datos compartidas. El encadenamiento de comparticion esta bloqueado por diseno.

**P: El proveedor ve las consultas del consumidor?**
R: No. El proveedor no tiene visibilidad sobre la actividad de consultas del consumidor. Los consumidores controlan su propio uso.

---

## 5.2 ESCENARIOS DE COMPARTICION

Diferentes topologias de comparticion tienen diferentes requisitos.

### Conceptos Clave

| Escenario | Mecanismo | Notas |
|-----------|-----------|-------|
| **Misma cuenta** | No aplica -- solo usar RBAC | La comparticion es entre cuentas, no dentro de una misma |
| **Misma region, misma nube** | Share directo | El mas simple -- zero-copy, sin replicacion |
| **Cross-region (misma nube)** | Replicacion de base de datos + share | Replicar datos a la region destino primero, luego compartir |
| **Cross-cloud** | Replicacion de base de datos + share | Igual que cross-region pero entre AWS/Azure/GCP |
| **Cliente sin Snowflake** | Reader account | El proveedor crea una cuenta administrada para el consumidor |

**Flujo cross-region / cross-cloud:**

1. El proveedor habilita la replicacion: `ALTER DATABASE mydb ENABLE REPLICATION TO ACCOUNTS target_account`
2. La cuenta destino crea la replica: `CREATE DATABASE mydb AS REPLICA OF source_account.mydb`
3. Actualizar la replica: `ALTER DATABASE mydb REFRESH`
4. Crear el share en la region destino usando la base de datos replicada
5. O: usar **Listing + Cross-Cloud Auto-Fulfillment** (maneja la replicacion automaticamente)

**Punto clave:** La comparticion directa solo funciona dentro de la **misma region y proveedor de nube**. Cualquier cosa cross-region o cross-cloud requiere replicacion primero (o auto-fulfillment).

### Por Que Importa

Una empresa global de retail en AWS us-east-1 necesita compartir datos de ventas con un socio en Azure West Europe. Deben replicar la base de datos a una cuenta en Azure West Europe primero, y luego crear el share alli. Sin entender esto, los arquitectos proponen comparticion directa y esta falla silenciosamente.

### Mejores Practicas

- Para comparticion cross-region frecuente, usar **Listings con Auto-Fulfillment** -- automatiza la replicacion
- Monitorear costos de replicacion en `REPLICATION_USAGE_HISTORY`
- La replicacion cross-cloud tiene costos de transferencia de datos -- considerar esto en la arquitectura
- Usar replication groups para escenarios con multiples bases de datos

**Trampas del examen:**

- Trampa: SI VES "La comparticion directa funciona entre regiones" --> INCORRECTO porque la comparticion directa requiere **misma region Y misma nube**; cross-region necesita replicacion primero
- Trampa: SI VES "La comparticion cross-cloud no es posible en Snowflake" --> INCORRECTO porque SI es posible via **replicacion de base de datos** a la nube/region destino, luego compartir
- Trampa: SI VES "Auto-Fulfillment elimina todos los costos de replicacion" --> INCORRECTO porque auto-fulfillment automatiza la replicacion pero los **costos de transferencia de datos siguen aplicando**

### Preguntas Frecuentes (FAQ)

**P: Puedo compartir entre dos cuentas de la misma organizacion pero en diferentes regiones?**
R: Si, via replicacion de base de datos + share, o a traves de un listing de Marketplace con Auto-Fulfillment.

**P: La replicacion es en tiempo real?**
R: No. La replicacion es casi en tiempo real con un calendario de actualizacion configurable. Siempre hay algo de retraso.

---

## 5.3 CUENTAS READER (READER ACCOUNTS)

Para compartir con organizaciones que **NO tienen una cuenta de Snowflake**.

### Conceptos Clave

- Creadas por el **proveedor** usando `CREATE MANAGED ACCOUNT`
- Las reader accounts son **cuentas administradas** -- completamente controladas por el proveedor
- **El proveedor paga TODO**: almacenamiento y computo
- Los usuarios de reader accounts solo pueden consultar datos compartidos -- no pueden cargar sus propios datos
- Funcionalidad limitada: sin carga de datos, sin shares desde reader accounts, administracion minima

**Capacidades de las Reader accounts:**

- Consultar datos compartidos via su propio warehouse (financiado por el proveedor)
- Crear usuarios dentro de la reader account
- Usar resource monitors (para controlar costos)

**No pueden:**

- Cargar datos en la cuenta
- Crear shares
- Acceder al Snowflake Marketplace
- Usar funciones avanzadas (tasks, streams, etc.)
- Replicar datos

### Por Que Importa

Una agencia gubernamental quiere compartir conjuntos de datos publicos con pequenos municipios que no pueden justificar una suscripcion a Snowflake. Las reader accounts permiten a la agencia compartir datos sin requerir que el municipio firme un contrato con Snowflake. Pero la agencia paga todos los costos de computo -- por lo que los resource monitors son esenciales.

### Mejores Practicas

- **Siempre** configurar resource monitors en los warehouses de reader accounts -- tu pagas su computo
- Mantener los warehouses de reader accounts pequenos (X-Small o Small)
- Configurar auto-suspend agresivo (60 segundos)
- Auditar periodicamente el uso de reader accounts via `RESOURCE_MONITORS` y `MANAGED_ACCOUNTS`
- Considerar listings de Marketplace si se desea que los consumidores paguen sus propios costos

**Trampas del examen:**

- Trampa: SI VES "Las reader accounts pueden cargar sus propios datos" --> INCORRECTO porque las reader accounts **solo pueden consultar datos compartidos**; no se permite carga de datos
- Trampa: SI VES "El consumidor paga el computo de la reader account" --> INCORRECTO porque el **proveedor paga todo** -- almacenamiento Y computo para reader accounts
- Trampa: SI VES "Las reader accounts pueden crear shares a otras cuentas" --> INCORRECTO porque las reader accounts no pueden crear shares, punto

### Preguntas Frecuentes (FAQ)

**P: Se puede convertir una reader account a una cuenta completa de Snowflake?**
R: No. Las reader accounts no pueden convertirse. La organizacion necesitaria firmar su propio contrato con Snowflake y se configuraria un share regular.

**P: Cuantas reader accounts puede crear un proveedor?**
R: No hay un limite estricto documentado, pero Snowflake puede imponer limites flexibles. Contactar soporte para numeros muy grandes.

---

## 5.4 MARKETPLACE E INTERCAMBIO DE DATOS (DATA EXCHANGE)

Marketplace es el catalogo publico de datos de Snowflake. Data Exchange es privado.

### Conceptos Clave

**Snowflake Marketplace:**

- Catalogo publico donde los proveedores **listan** conjuntos de datos para que cualquier cliente de Snowflake los descubra
- Listings gratuitos o de pago
- **Personalized listings** -- adaptados a consumidores especificos
- **Standard listings** -- disponibles para cualquiera
- Los consumidores obtienen datos instantaneamente -- zero-copy sharing detras de escena
- Proveedores: Snowflake, proveedores de datos de terceros, cualquier cliente de Snowflake

**Data Exchange (Privado):**

- Grupo **privado, solo por invitacion** de cuentas para compartir
- Creado por un cliente de Snowflake o por Snowflake mismo
- Los miembros pueden publicar y descubrir listings dentro del grupo
- Caso de uso: departamentos internos, socios de confianza, consorcios industriales

**Cross-Cloud Auto-Fulfillment:**

- Funcion de Marketplace que **replica automaticamente** los listings a consumidores en diferentes regiones/nubes
- El proveedor publica una vez --> Snowflake maneja la replicacion a donde sea que este el consumidor
- El proveedor paga los costos de transferencia/replicacion de datos
- Elimina la carga manual de replicacion en comparticion cross-region/cross-cloud

### Por Que Importa

Una empresa de datos meteorologicos publica pronosticos diarios en Snowflake Marketplace. Una cadena de retail en Azure East US lo descubre, hace clic en "Get", e instantaneamente tiene una base de datos compartida -- sin negociaciones, sin pipelines de datos, sin ETL. Cross-Cloud Auto-Fulfillment significa que la empresa meteorologica no necesita cuentas en cada region.

### Mejores Practicas

- Usar Marketplace para distribucion de datos **publica o semi-publica**
- Usar Data Exchange para comparticion **privada** dentro de un grupo de confianza
- Habilitar Auto-Fulfillment si los consumidores estan en multiples regiones/nubes
- Monitorear el uso de listings para entender la demanda y optimizar costos
- Escribir descripciones claras de listings -- los consumidores descubren datos mediante busqueda

**Trampas del examen:**

- Trampa: SI VES "Data Exchange es lo mismo que Marketplace" --> INCORRECTO porque Marketplace es **publico**, Data Exchange es **privado y solo por invitacion**
- Trampa: SI VES "Auto-Fulfillment es gratuito para los proveedores" --> INCORRECTO porque los proveedores siguen pagando **costos de replicacion y transferencia de datos**
- Trampa: SI VES "Los consumidores deben estar en la misma region para usar Marketplace" --> INCORRECTO porque **Auto-Fulfillment** maneja la entrega cross-region/cross-cloud automaticamente

### Preguntas Frecuentes (FAQ)

**P: Puedo cobrar por los listings de Marketplace?**
R: Si. Snowflake soporta listings de pago con precios basados en uso o fijos, administrados a traves del panel del proveedor.

**P: Quien gestiona la facturacion para listings de pago?**
R: Snowflake maneja la facturacion. Los consumidores pagan a traves de su factura de Snowflake, y Snowflake remite al proveedor.

---

## 5.5 DATA CLEAN ROOMS

Analisis seguro de datos entre multiples partes sin exponer datos crudos.

### Conceptos Clave

- **Proposito:** Dos o mas partes analizan datos superpuestos sin ver los datos crudos del otro
- Construido sobre la comparticion de Snowflake + secure views + controles de privacidad
- **Snowflake Data Clean Rooms** -- producto administrado (impulsado por el Native App Framework)
- Caso de uso tipico: anunciante + editor midiendo la superposicion de campanas sin exponer listas de clientes
- **Garantia clave:** ninguna parte ve los datos a nivel de fila del otro -- solo resultados agregados/anonimizados

**Como funciona (simplificado):**

1. La Parte A comparte sus datos en el clean room
2. La Parte B comparte sus datos en el clean room
3. Consultas pre-aprobadas (plantillas) se ejecutan sobre la superposicion
4. Los resultados devueltos son agregados -- umbrales minimos previenen la identificacion individual
5. Ninguna parte descarga los datos crudos del otro

**Controles de privacidad:**

- **Privacidad diferencial** -- agrega ruido estadistico para prevenir la re-identificacion
- **Umbrales minimos de agregacion** -- los resultados de consultas deben representar N+ individuos
- **Politicas de columna** -- restringen que columnas son unibles/visibles

### Por Que Importa

Un banco y un retailer quieren entender los clientes compartidos para una tarjeta de credito co-branded. Ninguno puede compartir listas de clientes debido a regulaciones. Un data clean room les permite calcular el "tamano de superposicion" y "gasto promedio" sin que ninguna parte vea registros individuales.

### Mejores Practicas

- Definir **plantillas de analisis** por adelantado -- restringir consultas ad-hoc
- Establecer umbrales minimos de agregacion significativos (ej. minimo 100 individuos por grupo)
- Usar el producto administrado de clean room de Snowflake en lugar de construir desde cero
- Auditar todas las consultas y resultados del clean room
- Involucrar a los equipos legales/de cumplimiento en el diseno del clean room

**Trampas del examen:**

- Trampa: SI VES "Los data clean rooms permiten que las partes vean los datos del otro" --> INCORRECTO porque los clean rooms **previenen** la exposicion de datos crudos; solo se devuelven resultados agregados
- Trampa: SI VES "Los clean rooms requieren que los datos se copien a un tercero" --> INCORRECTO porque los clean rooms de Snowflake usan **zero-copy sharing** -- los datos permanecen en la cuenta de cada parte
- Trampa: SI VES "Cualquier consulta puede ejecutarse en un clean room" --> INCORRECTO porque las consultas estan restringidas a **plantillas pre-aprobadas** para prevenir fuga de datos

### Preguntas Frecuentes (FAQ)

**P: Pueden mas de dos partes participar en un clean room?**
R: Si. Los clean rooms multi-parte estan soportados, aunque la complejidad aumenta.

**P: Es un clean room una cuenta separada de Snowflake?**
R: La logica del clean room se ejecuta como una Native App instalada en las cuentas participantes. Los datos permanecen en la cuenta de cada parte.

---

## 5.6 NATIVE APPS

El **Snowflake Native App Framework** permite a los proveedores empaquetar codigo + datos como aplicaciones instalables.

### Conceptos Clave

**Application Package:**

- El contenedor del **lado del proveedor** para la app
- Contiene: scripts de configuracion, codigo versionado, contenido de datos compartidos, UI de Streamlit, stored procedures, UDFs
- Se crea con `CREATE APPLICATION PACKAGE`
- Versionado: `ALTER APPLICATION PACKAGE ADD VERSION v1_0 USING '@stage/v1'`

**Native App (Lado del consumidor):**

- Instalada por el consumidor desde un listing o directamente
- Creada a partir de un Application Package
- Se ejecuta **dentro de la cuenta del consumidor** -- el proveedor no puede ver los datos del consumidor
- Puede solicitar **privilegios** al consumidor (ej. acceso a tablas especificas)
- El consumidor controla que acceso otorgar

**Que pueden incluir las Native Apps:**

- Stored procedures y UDFs (SQL, Python, Java, Scala, JavaScript)
- Dashboards de Streamlit (UI)
- Contenido de datos compartidos (datos de referencia)
- Tasks y streams (para procesamiento automatizado)
- Integraciones de acceso externo (llamar APIs externas)

**Script de configuracion (`setup.sql`):**

- Se ejecuta cuando el consumidor instala la app
- Crea todos los objetos internos (esquemas, vistas, procedimientos, etc.)
- Define **roles de aplicacion** que se mapean a los privilegios otorgados por el consumidor

### Por Que Importa

Una empresa de enriquecimiento de datos construye una Native App que toma la tabla de clientes del consumidor, la enriquece con datos demograficos de terceros, y devuelve los resultados -- todo sin que los datos del consumidor salgan de su cuenta. El proveedor distribuye a traves de Marketplace, y cada consumidor obtiene su propia instalacion aislada.

### Mejores Practicas

- Usar **parches versionados** para actualizaciones de apps (los consumidores pueden actualizar a su ritmo)
- Minimizar las solicitudes de privilegios -- pedir solo lo que la app realmente necesita
- Incluir una UI de Streamlit para usuarios que no usan SQL
- Probar las apps exhaustivamente en un application package de desarrollo antes de publicar
- Usar `manifest.yml` para declarar privilegios requeridos y configuracion

**Trampas del examen:**

- Trampa: SI VES "Las Native Apps se ejecutan en la cuenta del proveedor" --> INCORRECTO porque las Native Apps se ejecutan **dentro de la cuenta del consumidor**; el proveedor no puede ver los datos del consumidor
- Trampa: SI VES "Las Native Apps automaticamente tienen acceso a los datos del consumidor" --> INCORRECTO porque el consumidor debe **otorgar explicitamente** los privilegios; la app los solicita, el consumidor los aprueba
- Trampa: SI VES "Las Native Apps son solo bases de datos compartidas" --> INCORRECTO porque las Native Apps pueden incluir **codigo** (procedimientos, UDFs, Streamlit), no solo datos

### Preguntas Frecuentes (FAQ)

**P: Puede una Native App escribir datos en la cuenta del consumidor?**
R: Si, si el consumidor otorga los privilegios necesarios (ej. CREATE TABLE en un esquema).

**P: Como reciben los consumidores actualizaciones de Native Apps?**
R: Los proveedores publican nuevas versiones/parches. Los consumidores pueden actualizar manualmente o el proveedor puede configurar actualizacion automatica.

---

## 5.7 PATRONES DE SEGURIDAD PARA COMPARTICION

La seguridad no es negociable al compartir datos.

### Conceptos Clave

**Las secure views son obligatorias:**

- Las vistas regulares exponen su definicion (SQL) a cualquiera con `SHOW VIEWS`
- Las secure views ocultan la definicion y previenen la inferencia de datos basada en el optimizador
- **Todas las vistas en shares DEBEN ser seguras** -- Snowflake impone esto
- Compromiso: las secure views pueden tener optimizacion ligeramente diferente (restricciones del optimizador de consultas)

**Jerarquia de privilegios del share:**

```
SHARE
  └── USAGE on DATABASE
       └── USAGE on SCHEMA
            └── SELECT on TABLE / VIEW / MATERIALIZED VIEW
            └── USAGE on UDF
```

- Se debe otorgar en cada nivel -- otorgar SELECT en una tabla sin USAGE en su esquema no funcionara
- `GRANT REFERENCE_USAGE ON DATABASE` -- permite al consumidor crear vistas que referencien datos compartidos

**La comparticion cross-region requiere replicacion primero:**

- No se puede crear un share y agregar un consumidor en una region diferente directamente
- Se debe replicar la base de datos (o usar Auto-Fulfillment para listings)
- La replicacion puede ser continua (`REPLICATION_SCHEDULE`) o manual (`ALTER DATABASE REFRESH`)

**Secure UDFs en shares:**

- El codigo fuente de la UDF esta oculto para los consumidores (igual que las definiciones de secure views)
- Los consumidores pueden llamarlas pero no pueden inspeccionar su logica

### Por Que Importa

Un arquitecto comparte una vista que contiene datos financieros pero olvida hacerla segura. El consumidor ejecuta `SHOW VIEWS` y ve la definicion SQL, que revela logica de filtrado oculta y nombres de tablas. Ahora conocen tablas que no deberian. Las secure views previenen esto.

### Mejores Practicas

- **Siempre** usar secure views -- nunca compartir vistas regulares
- Otorgar privilegios en el nivel mas granular posible
- Usar secure UDFs para logica de negocio que no se quiere exponer
- Para consumidores cross-region, planificar el retraso de replicacion en los SLAs
- Auditar shares regularmente: `SHOW SHARES`, `DESCRIBE SHARE`

**Trampas del examen:**

- Trampa: SI VES "Las vistas regulares pueden agregarse a shares" --> INCORRECTO porque Snowflake **requiere secure views** en shares; se obtendra un error al agregar una vista no segura
- Trampa: SI VES "Otorgar SELECT en una tabla es suficiente para compartir" --> INCORRECTO porque tambien se debe otorgar **USAGE en la DATABASE y el SCHEMA**
- Trampa: SI VES "Las secure views tienen rendimiento identico a las vistas regulares" --> INCORRECTO porque las secure views restringen ciertos **comportamientos del optimizador** para prevenir fuga de datos, lo que puede impactar ligeramente el rendimiento

### Preguntas Frecuentes (FAQ)

**P: Puedo compartir una secure materialized view?**
R: Si. Las secure materialized views pueden incluirse en shares.

**P: Si elimino y recreo una tabla que esta en un share, el consumidor pierde acceso?**
R: Si. El share referencia el objeto especifico. Se debe re-otorgar despues de recrear.

---

## TARJETAS DE REPASO -- Dominio 5

**P1: Quien paga el almacenamiento en un share directo?**
R1: El **proveedor** paga el almacenamiento. El consumidor paga solo su propio computo.

**P2: Puede un consumidor modificar datos compartidos?**
R2: **No.** Los datos compartidos son de solo lectura para los consumidores.

**P3: Que se requiere para compartir datos cross-region?**
R3: **Replicacion de base de datos** a la region destino primero, luego crear el share alli. O usar Marketplace con Auto-Fulfillment.

**P4: Que tipo de vista DEBE usarse en shares?**
R4: **Secure views** -- las vistas regulares no estan permitidas en shares.

**P5: Quien paga el computo en una reader account?**
R5: El **proveedor** paga todo -- tanto almacenamiento como computo.

**P6: Pueden las reader accounts cargar sus propios datos?**
R6: **No.** Las reader accounts solo pueden consultar datos compartidos.

**P7: Que es Cross-Cloud Auto-Fulfillment?**
R7: Una funcion de Marketplace que **replica automaticamente** los listings a consumidores en diferentes regiones/nubes, para que el proveedor solo publique una vez.

**P8: Donde se ejecuta una Native App?**
R8: En la **cuenta del consumidor** -- el proveedor no puede ver los datos del consumidor.

**P9: Que es un Data Exchange?**
R9: Un grupo **privado, solo por invitacion** para compartir listings entre cuentas de confianza. A diferencia de Marketplace, que es publico.

**P10: Que previene la exposicion de datos crudos en un data clean room?**
R10: **Plantillas de consulta pre-aprobadas**, umbrales minimos de agregacion y controles de privacidad diferencial.

**P11: Puede un consumidor re-compartir datos recibidos a traves de un share?**
R11: **No.** El encadenamiento de comparticion no esta permitido por diseno.

**P12: Que archivo define los metadatos y privilegios de una Native App?**
R12: El archivo **manifest.yml** declara los privilegios requeridos, configuracion y metadatos de la app.

**P13: Para que se usa el privilegio `REFERENCE_USAGE`?**
R13: Permite a un consumidor **crear vistas en su propia base de datos que referencien** objetos en la base de datos compartida.

**P14: Como garantiza un clean room la privacidad individual?**
R14: Los resultados deben cumplir **umbrales minimos de agregacion** (ej. 100+ individuos por grupo) y pueden usar **ruido de privacidad diferencial**.

**P15: Que sucede si los datos compartidos subyacentes cambian?**
R15: Los consumidores ven los cambios **inmediatamente** (para shares en la misma region) porque la comparticion es zero-copy -- leen las micro-particiones en vivo del proveedor.

---

## EXPLICADO PARA PRINCIPIANTES -- Dominio 5

**Explicacion #1: Intercambio Seguro de Datos**
Tienes un libro para colorear. En lugar de fotocopiar paginas para tu amigo (lo que desperdicia papel), le permites mirar tu libro a traves de una ventana. Puede ver y calcar, pero no puede cambiar tu libro, y no tienes dos copias.

**Explicacion #2: Proveedor vs. Consumidor**
Horneaste galletas (proveedor). Tu amigo se las come (consumidor). Tu compraste los ingredientes (almacenamiento). Tu amigo usa su propio plato y tenedor (computo).

**Explicacion #3: Reader Accounts**
Tu amigo no tiene plato ni tenedor. Asi que le das los tuyos. Estas pagando por todo -- las galletas Y el plato y tenedor. Eso es una reader account.

**Explicacion #4: Comparticion Cross-Region**
Tu amigo vive en otra ciudad. No puedes simplemente sostener el libro para colorear -- esta muy lejos. Necesitas hacer una copia y enviarla a su ciudad primero (replicacion), luego puede mirar a traves de la ventana alli.

**Explicacion #5: Marketplace**
Imagina una biblioteca donde cualquiera puede tomar prestado cualquier libro gratis (o por una pequena tarifa). Eso es Marketplace. Cualquiera puede navegar, encontrar conjuntos de datos y "tomarlos prestados" instantaneamente.

**Explicacion #6: Data Exchange**
Ahora imagina un club de lectura privado. Solo los miembros invitados pueden compartir y tomar prestados libros. Eso es Data Exchange.

**Explicacion #7: Data Clean Rooms**
Tu y tu amigo tienen cada uno una bolsa de canicas. Quieren saber cuantos colores comparten, pero ninguno quiere mostrar todas sus canicas. Asi que cada uno pone su bolsa en una caja magica que solo les dice "Comparten 3 colores" -- no cuales canicas especificas.

**Explicacion #8: Native Apps**
Alguien construye un robot de juguete y lo pone en una caja con instrucciones. Lo instalas en TU habitacion, y juega con TUS juguetes. El constructor nunca entra a tu habitacion -- el robot funciona por su cuenta.

**Explicacion #9: Secure Views**
Una secure view es como un espejo unidireccional. Puedes ver los datos a traves de el, pero no puedes ver los planos de como se construyo el espejo o que esta oculto detras de la pared.

**Explicacion #10: Auto-Fulfillment**
Vendes limonada. En lugar de montar un puesto en cada vecindario tu mismo, un ayudante magico aparece automaticamente en cualquier vecindario donde alguien quiera limonada. Tu solo haces la receta una vez.

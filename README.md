# DBA-Prueba-tecnica-Neology
La siguiente prueba tiene como objetivo evaluar a los postulantes para un perfil de Administrador de Bases de Datos — DBA.

## Instrucciones de la prueba técnica

La siguiente prueba tiene como objetivo evaluar a los postulantes para un perfil de Administrador de Bases de Datos — DBA.

## Introducción

Este repositorio contiene los requerimientos de un caso práctico orientado a evaluar las capacidades técnicas necesarias para administrar bases de datos relacionales y no relacionales dentro del área de Desarrollo de Software de Neology.

El ejercicio utiliza como contexto un sistema de control de acceso vehicular para un estacionamiento.

## ¿Qué se busca evaluar?

Principalmente, los siguientes aspectos:

* Diseño de modelos de datos relacionales.
* Integridad, consistencia y trazabilidad de la información.
* Conocimientos de MariaDB y Oracle.
* Creación y optimización de consultas SQL.
* Interpretación de planes de ejecución.
* Diseño y uso adecuado de índices.
* Administración de usuarios, roles y privilegios.
* Estrategias de respaldo, restauración y recuperación.
* Monitoreo y diagnóstico de problemas.
* Conocimiento de bases de datos no relacionales.
* Documentación y claridad para explicar decisiones técnicas.

## Consideraciones generales

* Tiempo máximo recomendado: 5 horas efectivas.
* El candidato podrá organizar el trabajo de acuerdo con su experiencia.
* La implementación ejecutable deberá realizarse en MariaDB.
* No es necesario instalar Oracle; deberán documentarse las consideraciones necesarias para implementar la solución en Oracle.
* No se espera una solución productiva completa, sino una propuesta funcional, reproducible y bien argumentada.
* Si algún punto no puede completarse, deberá documentarse cómo se resolvería.
* No deberán incluirse contraseñas o secretos reales en el repositorio.

## Objetivo general

Diseñar y preparar la base de datos para un sistema que permita gestionar el acceso de vehículos a un estacionamiento, registrar entradas y salidas, calcular cobros, generar reportes y conservar trazabilidad histórica.

## Reglas de negocio

* Los vehículos oficiales no pagan.
* Los vehículos residentes pagan $0.05 por minuto.
* Los vehículos no residentes pagan $0.50 por minuto al registrar su salida.
* Un vehículo no puede tener más de una estancia abierta.
* Una salida no puede ser anterior a la entrada.
* Los residentes acumulan su tiempo y cargos durante el mes.
* Al iniciar un nuevo mes debe conservarse el historial.
* Las modificaciones relevantes deben ser auditables.
* El modelo debe permitir agregar nuevos tipos de vehículos y tarifas.

# Parte 1 — Modelo de datos

Diseñar un modelo relacional que contemple, como mínimo:

* Tipos de vehículo.
* Vehículos.
* Residentes.
* Estancias.
* Tarifas.
* Pagos o cargos.
* Cierres mensuales.
* Auditoría de operaciones.

El modelo deberá incluir:

* Llaves primarias y foráneas.
* Restricciones de integridad.
* Campos obligatorios.
* Restricciones de unicidad.
* Manejo de fechas y horas.
* Índices iniciales.
* Estrategia para conservar información histórica.

## Entregables

* `database/schema.sql`
* `database/data.sql`
* `docs/modelo-datos.md`
* Diagrama entidad-relación en PNG, PDF o Mermaid.

# Parte 2 — Datos y consultas SQL

El archivo `data.sql` deberá incluir información suficiente para validar diferentes escenarios:

* Vehículos oficiales.
* Vehículos residentes.
* Vehículos no residentes.
* Estancias abiertas.
* Estancias finalizadas.
* Información de diferentes días y meses.

Crear consultas para:

1. Consultar los vehículos que se encuentran actualmente dentro del estacionamiento.
2. Calcular la duración y el importe correspondiente a una estancia.
3. Generar el reporte mensual de residentes.
4. Consultar ingresos por día y por tipo de vehículo.
5. Consultar el promedio de permanencia por tipo de vehículo.
6. Identificar vehículos con más de una estancia abierta.
7. Detectar registros con fechas inconsistentes.
8. Consultar los vehículos con mayor tiempo acumulado durante el mes.

Los cálculos deberán considerar correctamente los diferentes tipos de vehículo y tarifas.

## Entregable

* `database/queries.sql`

# Parte 3 — Operación de cierre mensual

Crear un procedimiento, script transaccional o propuesta equivalente que permita iniciar un nuevo mes.

El proceso deberá:

* Calcular el cierre de los residentes.
* Conservar el histórico del periodo anterior.
* Evitar la eliminación de información.
* Prevenir ejecuciones duplicadas.
* Garantizar consistencia en caso de error.
* Permitir identificar cuándo y quién ejecutó el cierre.

## Entregable

* `database/monthly-close.sql`

# Parte 4 — Optimización y rendimiento

Considere que la tabla de estancias puede superar varios millones de registros.

El candidato deberá:

1. Seleccionar al menos dos consultas del ejercicio.
2. Obtener y documentar su plan de ejecución.
3. Identificar posibles problemas de rendimiento.
4. Proponer o implementar índices.
5. Explicar el orden de las columnas de cada índice.
6. Documentar el impacto de los índices en las operaciones de escritura.
7. Indicar si utilizaría particionamiento y bajo qué condiciones.
8. Presentar una comparación antes y después de la optimización.

Para MariaDB se puede utilizar `EXPLAIN` o `EXPLAIN ANALYZE`.

También deberá explicar brevemente cómo realizaría el análisis equivalente en Oracle mediante herramientas como `EXPLAIN PLAN`, `DBMS_XPLAN` o SQL Trace.

## Entregables

* `database/indexes.sql`
* `docs/performance-analysis.md`

# Parte 5 — Seguridad

Crear una propuesta de usuarios y roles para:

* Aplicación.
* Reportes de solo lectura.
* Operación y soporte.
* Administración de la base de datos.

La propuesta deberá considerar:

* Principio de mínimo privilegio.
* Separación de responsabilidades.
* Restricción de acceso a datos sensibles.
* Auditoría de operaciones administrativas.
* Manejo seguro de credenciales.
* Revocación de permisos.

## Entregable

* `database/security.sql`

No deberán incluirse credenciales reales.

# Parte 6 — Respaldo, restauración y recuperación

Documentar una estrategia que incluya:

* Respaldo completo.
* Respaldos incrementales o uso de binary logs.
* Restauración de la base de datos.
* Recuperación a un punto en el tiempo.
* Validación periódica de respaldos.
* Retención y cifrado.
* RPO y RTO propuestos.
* Replicación y recuperación ante desastres.

La implementación deberá incluir, como mínimo, un ejemplo funcional de respaldo y restauración para MariaDB.

También deberá describirse brevemente la alternativa correspondiente para Oracle, utilizando RMAN y las opciones de alta disponibilidad que el candidato considere apropiadas.

## Entregables

* `scripts/backup.sh`
* `scripts/restore.sh`
* `docs/backup-recovery.md`

# Parte 7 — Diagnóstico de incidente

Considere el siguiente escenario:

> La aplicación presenta tiempos de respuesta elevados. La base de datos alcanzó el límite de conexiones, existen sesiones bloqueadas y el almacenamiento se encuentra al 85 % de capacidad.

Documentar:

1. Validaciones iniciales.
2. Consultas o comandos de diagnóstico.
3. Cómo identificar sesiones bloqueadas.
4. Cómo determinar las consultas de mayor consumo.
5. Acciones inmediatas para estabilizar el servicio.
6. Acciones preventivas.
7. Riesgos antes de cancelar una sesión o consulta.
8. Consideraciones equivalentes para MariaDB y Oracle.

## Entregable

* `docs/incident-response.md`

# Parte 8 — Componente no relacional

Proponer una solución no relacional para almacenar eventos de auditoría o actividad del sistema.

La propuesta deberá incluir:

* Tecnología seleccionada.
* Ejemplo de documento o estructura.
* Estrategia de índices.
* Consultas principales.
* Retención y crecimiento esperado.
* Consistencia requerida.
* Ventajas y desventajas frente al modelo relacional.
* Información que no debería almacenarse en esta base.

No es obligatorio implementar el motor no relacional.

## Entregable

* `docs/nosql-design.md`

# Estructura esperada

```text
DBA-Prueba-tecnica-Neology/
├── database/
│   ├── schema.sql
│   ├── data.sql
│   ├── queries.sql
│   ├── indexes.sql
│   ├── monthly-close.sql
│   └── security.sql
├── scripts/
│   ├── backup.sh
│   └── restore.sh
├── docs/
│   ├── modelo-datos.md
│   ├── performance-analysis.md
│   ├── backup-recovery.md
│   ├── incident-response.md
│   └── nosql-design.md
├── docker-compose.yml
└── README.md
```

# Entrega

El repositorio deberá incluir:

* Instrucciones para levantar MariaDB.
* Instrucciones para crear la estructura.
* Instrucciones para cargar los datos.
* Instrucciones para ejecutar las consultas.
* Evidencias de ejecución.
* Supuestos y decisiones técnicas.
* Limitaciones conocidas.
* Historial de commits comprensible.

El candidato deberá crear una rama con el siguiente formato:

```text
entrega/nombre-apellido
```

Si no cuenta con permisos sobre el repositorio, podrá realizar un fork o generar un repositorio privado y compartir el acceso.

Enviar el enlace de la entrega a la consultora, copiando a:

* [vmiranda@neology.mx](mailto:vmiranda@neology.mx)
* [lluna@neopartners.mx](mailto:lluna@neopartners.mx)

# Criterios de evaluación

| Criterio                              | Ponderación |
| ------------------------------------- | ----------: |
| Modelo de datos e integridad          |        25 % |
| Consultas y reglas de negocio         |        20 % |
| Optimización y planes de ejecución    |        20 % |
| Respaldo, recuperación y continuidad  |        15 % |
| Seguridad y administración de accesos |        10 % |
| Diseño no relacional                  |         5 % |
| Documentación y reproducibilidad      |         5 % |

## Extras recomendados

* Generación automatizada de datos.
* Pruebas automáticas de integridad.
* Propuesta de monitoreo.
* Estrategia de archivado.
* Particionamiento implementado.
* Automatización de respaldos.
* Comparación detallada entre MariaDB y Oracle.

> No te preocupes si no puedes completar todos los requisitos dentro del tiempo establecido. Se valorará principalmente la calidad, el criterio técnico, la capacidad de priorización y la claridad para explicar las decisiones.

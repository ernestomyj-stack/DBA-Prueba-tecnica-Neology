Diagnóstico de incidente

La aplicación presenta tiempos de respuesta elevados. La base de datos alcanzó el límite de conexiones, existen sesiones bloqueadas y el almacenamiento se encuentra al 85 % de capacidad.

Validaciones iniciales

Antes de cancelar sesiones o realizar modificaciones sobre la base de datos, se deberá obtener información del estado actual del servidor y BD :

Uso de CPU y memoria.
Espacio disponible en disco.
Cantidad de conexiones.
Sesiones activas.
Sesiones bloqueadas.
Consultas de larga duración.
Transacciones abiertas.

En la BD también debemos revisar  cuántas conexiones existen actualmente:
SHOW STATUS LIKE 'Threads_connected';
SHOW STATUS LIKE 'Threads_running';
También se debe conocer el límite configurado:
SHOW VARIABLES LIKE 'max_connections';
Con esto podemos determinar si el servidor está cerca o ya alcanzó su capacidad configurada.
Por ejemplo:
Threads_connected = 500
max_connections   = 500
indicaría que el límite de conexiones ha sido alcanzado.

Identificar sesiones activas

SELECT
    ID,
    USER,
    HOST,
    DB,
    COMMAND,
    TIME,
    STATE,
    INFO
FROM information_schema.PROCESSLIST
ORDER BY TIME DESC;
Esto permite identificar conexiones que llevan mucho tiempo ejecutándose y determinar qué consulta está causando el problema.

Una vez identificada una consulta problemática, se deberá analizar su plan de ejecución mediante:
EXPLAIN
SELECT ...;
El objetivo será determinar si existen:
Full table scans.
Índices inexistentes.
Índices incorrectos.
Joins costosos.


Antes de terminar alguna sesión debemos evaluar o solicitar autorización para poderla finalizar

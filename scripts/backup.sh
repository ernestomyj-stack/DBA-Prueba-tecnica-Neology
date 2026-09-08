
Se debe realizar un respaldo completo de la base de datos con la utileria de mariadb-dump.

El respaldo deberá ejecutarse de forma periódica, preferentemente durante periodos de baja actividad, se recomienda utilizar tareas programadas para que se ejecuten durante la noche.
Cuando son BD muy transaccionales se recomienda generar respaldos diario, aunque cuidando el tema del almacenamiento, para ello seria adecuado comprimir los backups.

mariadb-dump \
  --user=backup \
  --password \
  --host=127.0.0.1 \
  --single-transaction \
  --databases estacionamiento \
  > /backup/estacionamiento_full.sql
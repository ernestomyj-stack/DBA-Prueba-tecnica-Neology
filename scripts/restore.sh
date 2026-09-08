Restore

Ante una pérdida total de la base de datos, primero se debe disponer de un respaldo completo válido.

mariadb -u root -p estacionamiento

Después de la restauración se deberá validar:

Existencia de las bases de datos.
Existencia de las tablas.
Conteo de registros.
Consistencia de la información.



Recuperación a un punto en el tiempo


para este procedimiento vamos a validar que contemos con un full backup de nuestra BD, adicional debemos tener habilitado los archivos de binlog,
debemos revisar hasta qe punto en el tiempo necesitamos hacer nuestra recuperacion.

mariadb-binlog \
  --stop-datetime="2026-09-07 14:34:59" \
  /var/lib/mysql/mariadb-bin.000001 \
  | mariadb --user=root --password
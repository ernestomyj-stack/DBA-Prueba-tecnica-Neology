Oracle — Estrategia de respaldo y recuperación  RMAN


Para Oracle, la solución propuesta para la estrategia de respaldo y recuperación será RMAN (Recovery Manager), herramienta nativa de Oracle diseñada 
para realizar respaldos y recuperación de bases de datos.RMAN permite implementar una estrategia de respaldo completa, incluyendo respaldos full, 
respaldos incrementales y recuperación a un punto específico en el tiempo.

La estrategia propuesta contempla los siguientes componentes:

1. Respaldos completos

Se utilizarán respaldos completos de la base de datos para contar con una copia base a partir de la cual pueda realizarse una recuperación ante una falla.
Estos respaldos podrán programarse de acuerdo con los requerimientos del negocio, por ejemplo, de manera semanal, complementándolos con respaldos incrementales diarios.

2. Respaldos incrementales

RMAN permite realizar respaldos incrementales, lo que permite reducir el volumen de información que debe almacenarse y disminuir el tiempo requerido para realizar los respaldos.
Una estrategia podría consistir en realizar un backup full semanal y backups incrementales durante los días siguientes.

De esta manera, no es necesario generar diariamente una copia completa de toda la base de datos, optimizando el uso del almacenamiento.

3. Archive Logs

Para poder realizar una recuperación a un punto en el tiempo, se deberán conservar los Archived Redo Logs.
Los Archived Redo Logs contienen los cambios generados en la base de datos y permiten aplicar las operaciones realizadas después del respaldo.

En caso de requerir una recuperación a un punto específico en el tiempo, RMAN puede restaurar el backup correspondiente y posteriormente aplicar los Archived Redo Logs hasta el momento deseado.

  
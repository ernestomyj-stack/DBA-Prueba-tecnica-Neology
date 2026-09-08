Pues en mi caso yo definiria  3  perfiles:

Aplicación

El usuario utilizado por la aplicación tendrá únicamente los permisos necesarios para realizar las operaciones propias del sistema.
No tendrá permisos para modificar la estructura de la base de datos.


Consulta

El usuario destinado a consulta tendrá permisos de solo lectura.Podrá consultar información necesaria para generar reportes operativos y estadísticos
, pero no podrá insertar, modificar ni eliminar información.
Para proteger información sensible de los residentes, se recomienda utilizar vistas que expongan únicamente los datos necesarios para los reportes.


Administrador (DBA)

El perfil DBA tendrá los privilegios necesarios para administrar la base de datos, incluyendo mantenimiento, creación y modificación de objetos, 
índices, procedimientos, roles y permisos.


CREATE ROLE IF NOT EXISTS rol_app;

CREATE ROLE IF NOT EXISTS rol_consulta;

CREATE ROLE IF NOT EXISTS rol_dba;
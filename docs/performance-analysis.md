Los índices representan un costo adicional para las operaciones de escritura y almacenamiento, por lo que
 no se propone indexar indiscriminadamente todas las columnas.

El particionamiento por fecha se evaluaría cuando el volumen y patrón de consultas lo justifiquen, especialmente
 ante tablas de decenas o cientos de millones de registros.

La tabla estancia es una de las tablas con mayor crecimiento del modelo, 
debido a que cada ingreso de un vehículo genera un nuevo registro. 
Considerando que esta tabla puede superar varios millones de registros, realizar consultas mediante un 
recorrido completo de la tabla (Full Table Scan) puede generar un consumo elevado de CPU, memoria e I/O
y aumentar considerablemente el tiempo de respuesta.

Por esta razón seria recomendable crear índices sobre las columnas que participan con mayor frecuencia
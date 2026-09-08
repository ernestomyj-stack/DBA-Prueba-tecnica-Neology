-- ============================================================
-- DATOS INICIALES DE CATÁLOGOS
-- ============================================================

INSERT INTO tipo_vehiculo
    (nombre, categoria, descripcion)
VALUES
    (
        'Automóvil residente',
        'RESIDENTE',
        'Vehículo propiedad de un residente'
    ),
    (
        'Motocicleta residente',
        'RESIDENTE',
        'Motocicleta propiedad de un residente'
    ),
    (
        'Automóvil visitante',
        'NO_RESIDENTE',
        'Vehículo de persona no residente'
    ),
    (
        'Vehículo oficial',
        'OFICIAL',
        'Vehículo oficial sin costo'
    );


-- ============================================================
-- TARIFAS INICIALES
-- ============================================================

INSERT INTO tarifa
    (
        id_tipo_vehiculo,
        nombre,
        importe_por_minuto,
        fecha_inicio
    )
SELECT
    id_tipo_vehiculo,
    CONCAT('Tarifa ', nombre),
    CASE categoria
        WHEN 'RESIDENTE' THEN 0.0500
        WHEN 'NO_RESIDENTE' THEN 0.5000
        WHEN 'OFICIAL' THEN 0.0000
    END,
    '2026-01-01 00:00:00'
FROM tipo_vehiculo;


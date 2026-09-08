USE estacionamiento;

-- ============================================================
-- 1. VEHÍCULOS ACTUALMENTE DENTRO DEL ESTACIONAMIENTO
-- ============================================================
-- 

SELECT
    v.id_vehiculo,
    v.placa,
    tv.nombre AS tipo_vehiculo,
    tv.categoria,
    CONCAT(r.nombre, ' ', r.apellido_paterno, ' ', COALESCE(r.apellido_materno, '')) AS residente,
    e.fecha_entrada,
    TIMESTAMPDIFF(MINUTE, e.fecha_entrada, NOW()) AS minutos_dentro
FROM estancia e
INNER JOIN vehiculo v
    ON v.id_vehiculo = e.id_vehiculo
INNER JOIN tipo_vehiculo tv
    ON tv.id_tipo_vehiculo = v.id_tipo_vehiculo
LEFT JOIN residente r
    ON r.id_residente = v.id_residente
WHERE e.fecha_salida IS NULL
ORDER BY e.fecha_entrada;


-- ============================================================
-- 2. DURACIÓN E IMPORTE CORRESPONDIENTE A UNA ESTANCIA
-- ============================================================
-- 


SELECT
    e.id_estancia,
    v.placa,
    tv.categoria,
    e.fecha_entrada,
    e.fecha_salida,

    TIMESTAMPDIFF(
        MINUTE,
        e.fecha_entrada,
        COALESCE(e.fecha_salida, NOW())
    ) AS minutos_estancia,

    COALESCE(t.importe_por_minuto, 0.0000) AS importe_por_minuto,

    ROUND(
        TIMESTAMPDIFF(
            MINUTE,
            e.fecha_entrada,
            COALESCE(e.fecha_salida, NOW())
        ) * COALESCE(t.importe_por_minuto, 0.0000),
        2
    ) AS importe_total

FROM estancia e
INNER JOIN vehiculo v
    ON v.id_vehiculo = e.id_vehiculo
INNER JOIN tipo_vehiculo tv
    ON tv.id_tipo_vehiculo = v.id_tipo_vehiculo

LEFT JOIN tarifa t
    ON t.id_tipo_vehiculo = v.id_tipo_vehiculo
    AND e.fecha_entrada >= t.fecha_inicio
    AND (
        t.fecha_fin IS NULL
        OR e.fecha_entrada <= t.fecha_fin
    )
    AND t.activo = TRUE

WHERE e.id_estancia = :id_estancia;


-- ============================================================
-- 3. REPORTE MENSUAL DE RESIDENTES
-- ============================================================
-- Parámetros:
--   :anio = año del reporte
--   :mes  = mes del reporte
--

SELECT
    r.id_residente,
    CONCAT(
        r.nombre, ' ',
        r.apellido_paterno, ' ',
        COALESCE(r.apellido_materno, '')
    ) AS residente,
    r.numero_vivienda,

    COUNT(DISTINCT e.id_estancia) AS total_estancias,

    COALESCE(SUM(
        CASE
            WHEN e.fecha_salida IS NOT NULL
            THEN TIMESTAMPDIFF(
                MINUTE,
                e.fecha_entrada,
                e.fecha_salida
            )
            ELSE 0
        END
    ), 0) AS minutos_acumulados,

    COALESCE(SUM(c.importe_total), 0.00) AS total_cargos,

    COALESCE(SUM(
        CASE
            WHEN p.estado = 'APLICADO'
            THEN p.importe
            ELSE 0
        END
    ), 0.00) AS total_pagado,

    COALESCE(SUM(c.importe_total), 0.00)
    -
    COALESCE(SUM(
        CASE
            WHEN p.estado = 'APLICADO'
            THEN p.importe
            ELSE 0
        END
    ), 0.00) AS saldo_pendiente

FROM residente r

LEFT JOIN vehiculo v
    ON v.id_residente = r.id_residente

LEFT JOIN estancia e
    ON e.id_vehiculo = v.id_vehiculo
    AND YEAR(e.fecha_entrada) = :anio
    AND MONTH(e.fecha_entrada) = :mes

LEFT JOIN cargo c
    ON c.id_estancia = e.id_estancia
    AND c.estado <> 'CANCELADO'

LEFT JOIN pago p
    ON p.id_cargo = c.id_cargo
    AND p.estado = 'APLICADO'

GROUP BY
    r.id_residente,
    r.nombre,
    r.apellido_paterno,
    r.apellido_materno,
    r.numero_vivienda

ORDER BY
    r.numero_vivienda;


-- ============================================================
-- 4. INGRESOS POR DÍA Y POR TIPO DE VEHÍCULO
-- ============================================================

SELECT
    DATE(p.fecha_pago) AS fecha,
    tv.categoria AS tipo_vehiculo,

    COUNT(DISTINCT p.id_pago) AS cantidad_pagos,

    SUM(p.importe) AS ingreso_total

FROM pago p
INNER JOIN cargo c
    ON c.id_cargo = p.id_cargo
INNER JOIN vehiculo v
    ON v.id_vehiculo = c.id_vehiculo
INNER JOIN tipo_vehiculo tv
    ON tv.id_tipo_vehiculo = v.id_tipo_vehiculo

WHERE p.estado = 'APLICADO'

GROUP BY
    DATE(p.fecha_pago),
    tv.categoria

ORDER BY
    fecha,
    tv.categoria;


-- ============================================================
-- 5. PROMEDIO DE PERMANENCIA POR TIPO DE VEHÍCULO
-- ============================================================

SELECT
    tv.categoria AS tipo_vehiculo,

    COUNT(e.id_estancia) AS total_estancias,

    ROUND(
        AVG(
            TIMESTAMPDIFF(
                MINUTE,
                e.fecha_entrada,
                e.fecha_salida
            )
        ),
        2
    ) AS promedio_minutos,

    ROUND(
        AVG(
            TIMESTAMPDIFF(
                MINUTE,
                e.fecha_entrada,
                e.fecha_salida
            )
        ) / 60,
        2
    ) AS promedio_horas

FROM estancia e
INNER JOIN vehiculo v
    ON v.id_vehiculo = e.id_vehiculo
INNER JOIN tipo_vehiculo tv
    ON tv.id_tipo_vehiculo = v.id_tipo_vehiculo

WHERE e.fecha_salida IS NOT NULL

GROUP BY
    tv.categoria

ORDER BY
    promedio_minutos DESC;


-- ============================================================
-- 6. IDENTIFICAR VEHÍCULOS CON MÁS DE UNA ESTANCIA ABIERTA
-- ============================================================
-- Esta consulta sirve también para detectar inconsistencias.

SELECT
    v.id_vehiculo,
    v.placa,
    tv.categoria,
    COUNT(e.id_estancia) AS estancias_abiertas

FROM vehiculo v
INNER JOIN tipo_vehiculo tv
    ON tv.id_tipo_vehiculo = v.id_tipo_vehiculo
INNER JOIN estancia e
    ON e.id_vehiculo = v.id_vehiculo

WHERE e.fecha_salida IS NULL

GROUP BY
    v.id_vehiculo,
    v.placa,
    tv.categoria

HAVING COUNT(e.id_estancia) > 1

ORDER BY
    estancias_abiertas DESC;


-- ============================================================
-- 7. DETECTAR REGISTROS CON FECHAS INCONSISTENTES
-- ============================================================

-- Estancias cuya salida es anterior a la entrada
SELECT
    'ESTANCIA' AS tabla_afectada,
    e.id_estancia AS id_registro,
    e.id_vehiculo,
    e.fecha_entrada,
    e.fecha_salida,
    'La fecha de salida es anterior a la fecha de entrada'
        AS inconsistencia
FROM estancia e
WHERE e.fecha_salida IS NOT NULL
  AND e.fecha_salida < e.fecha_entrada;


-- Vehículos cuya fecha de baja es anterior al alta
SELECT
    'VEHICULO' AS tabla_afectada,
    v.id_vehiculo AS id_registro,
    v.fecha_alta,
    v.fecha_baja,
    'La fecha de baja es anterior a la fecha de alta'
        AS inconsistencia
FROM vehiculo v
WHERE v.fecha_baja IS NOT NULL
  AND v.fecha_baja < v.fecha_alta;


-- Residentes cuya fecha de baja es anterior al alta
SELECT
    'RESIDENTE' AS tabla_afectada,
    r.id_residente AS id_registro,
    r.fecha_alta,
    r.fecha_baja,
    'La fecha de baja es anterior a la fecha de alta'
        AS inconsistencia
FROM residente r
WHERE r.fecha_baja IS NOT NULL
  AND r.fecha_baja < r.fecha_alta;


-- Tarifas con fechas de vigencia inconsistentes
SELECT
    'TARIFA' AS tabla_afectada,
    t.id_tarifa AS id_registro,
    t.fecha_inicio,
    t.fecha_fin,
    'La fecha fin es anterior a la fecha de inicio'
        AS inconsistencia
FROM tarifa t
WHERE t.fecha_fin IS NOT NULL
  AND t.fecha_fin < t.fecha_inicio;


-- ============================================================
-- 8. VEHÍCULOS CON MAYOR TIEMPO ACUMULADO DURANTE EL MES
-- ============================================================
-- Parámetros:
--   :anio
--   :mes

SELECT
    v.id_vehiculo,
    v.placa,
    tv.categoria,

    CONCAT(
        r.nombre, ' ',
        r.apellido_paterno
    ) AS residente,

    COUNT(e.id_estancia) AS total_estancias,

    SUM(
        TIMESTAMPDIFF(
            MINUTE,
            e.fecha_entrada,
            e.fecha_salida
        )
    ) AS minutos_acumulados,

    ROUND(
        SUM(
            TIMESTAMPDIFF(
                MINUTE,
                e.fecha_entrada,
                e.fecha_salida
            )
        ) / 60,
        2
    ) AS horas_acumuladas

FROM estancia e

INNER JOIN vehiculo v
    ON v.id_vehiculo = e.id_vehiculo

INNER JOIN tipo_vehiculo tv
    ON tv.id_tipo_vehiculo = v.id_tipo_vehiculo

LEFT JOIN residente r
    ON r.id_residente = v.id_residente

WHERE e.fecha_salida IS NOT NULL
  AND YEAR(e.fecha_entrada) = :anio
  AND MONTH(e.fecha_entrada) = :mes

GROUP BY
    v.id_vehiculo,
    v.placa,
    tv.categoria,
    r.nombre,
    r.apellido_paterno

ORDER BY
    minutos_acumulados DESC;


-- ============================================================
-- 9. VALIDAR CÁLCULO DE CARGOS SEGÚN TIPO DE VEHÍCULO
-- ============================================================
-- Esta consulta permite demostrar que:
--
-- RESIDENTE     = $0.05/minuto
-- NO_RESIDENTE  = $0.50/minuto
-- OFICIAL       = $0.00/minuto
--
-- respetando la tarifa vigente.

SELECT
    e.id_estancia,
    v.placa,
    tv.categoria,

    TIMESTAMPDIFF(
        MINUTE,
        e.fecha_entrada,
        e.fecha_salida
    ) AS minutos,

    t.importe_por_minuto AS tarifa_minuto,

    ROUND(
        TIMESTAMPDIFF(
            MINUTE,
            e.fecha_entrada,
            e.fecha_salida
        ) * t.importe_por_minuto,
        2
    ) AS importe_calculado

FROM estancia e

INNER JOIN vehiculo v
    ON v.id_vehiculo = e.id_vehiculo

INNER JOIN tipo_vehiculo tv
    ON tv.id_tipo_vehiculo = v.id_tipo_vehiculo

INNER JOIN tarifa t
    ON t.id_tipo_vehiculo = v.id_tipo_vehiculo
    AND e.fecha_entrada >= t.fecha_inicio
    AND (
        t.fecha_fin IS NULL
        OR e.fecha_entrada <= t.fecha_fin
    )
    AND t.activo = TRUE

WHERE e.fecha_salida IS NOT NULL

ORDER BY
    e.fecha_entrada DESC;


-- ============================================================
-- 10. DETECTAR CARGOS CUYO IMPORTE NO COINCIDE CON LA ESTANCIA
-- ============================================================

SELECT
    c.id_cargo,
    c.id_estancia,
    v.placa,
    tv.categoria,

    c.minutos_cobrados,
    c.importe_por_minuto,
    c.importe_total,

    ROUND(
        c.minutos_cobrados * c.importe_por_minuto,
        2
    ) AS importe_esperado

FROM cargo c

INNER JOIN estancia e
    ON e.id_estancia = c.id_estancia

INNER JOIN vehiculo v
    ON v.id_vehiculo = c.id_vehiculo

INNER JOIN tipo_vehiculo tv
    ON tv.id_tipo_vehiculo = v.id_tipo_vehiculo

WHERE c.estado <> 'CANCELADO'

  AND ROUND(
        c.minutos_cobrados * c.importe_por_minuto,
        2
      ) <> c.importe_total

ORDER BY
    c.id_cargo;


-- ============================================================
-- 11. RESUMEN GENERAL DEL MES
-- ============================================================
-- Parámetros:
--   :anio
--   :mes

SELECT
    :anio AS anio,
    :mes AS mes,

    COUNT(DISTINCT e.id_estancia) AS total_estancias,

    COALESCE(
        SUM(
            TIMESTAMPDIFF(
                MINUTE,
                e.fecha_entrada,
                e.fecha_salida
            )
        ),
        0
    ) AS total_minutos,

    COALESCE(
        SUM(c.importe_total),
        0.00
    ) AS total_cargos,

    COALESCE(
        SUM(
            CASE
                WHEN p.estado = 'APLICADO'
                THEN p.importe
                ELSE 0
            END
        ),
        0.00
    ) AS total_ingresos

FROM estancia e

LEFT JOIN cargo c
    ON c.id_estancia = e.id_estancia
    AND c.estado <> 'CANCELADO'

LEFT JOIN pago p
    ON p.id_cargo = c.id_cargo
    AND p.estado = 'APLICADO'

WHERE YEAR(e.fecha_entrada) = :anio
  AND MONTH(e.fecha_entrada) = :mes
  AND e.fecha_salida IS NOT NULL;
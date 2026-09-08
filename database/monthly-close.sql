
CREATE PROCEDURE cerrar_mes(
    IN p_anio SMALLINT UNSIGNED,
    IN p_mes TINYINT UNSIGNED,
    IN p_usuario VARCHAR(100)
)
BEGIN

    DECLARE v_fecha_inicio DATE;
    DECLARE v_fecha_fin DATE;

    DECLARE v_total_estancias BIGINT UNSIGNED DEFAULT 0;
    DECLARE v_total_minutos BIGINT UNSIGNED DEFAULT 0;
    DECLARE v_total_cargos DECIMAL(14,2) DEFAULT 0.00;
    DECLARE v_total_pagos DECIMAL(14,2) DEFAULT 0.00;

    DECLARE v_cierre_id BIGINT UNSIGNED;

    DECLARE v_error BOOLEAN DEFAULT FALSE;

    /*
     * ----------------------------------------------------------
     * MANEJO DE ERRORES
     * ----------------------------------------------------------
     *
     * Ante cualquier error se hace ROLLBACK.
     */
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_error = TRUE;
        ROLLBACK;
    END;


    /*
     * ----------------------------------------------------------
     * VALIDACIÓN DEL PERIODO
     * ----------------------------------------------------------
     */

    IF p_anio IS NULL OR p_mes IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El año y el mes son obligatorios';
    END IF;

    IF p_mes < 1 OR p_mes > 12 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El mes debe estar entre 1 y 12';
    END IF;

    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El usuario que ejecuta el cierre es obligatorio';
    END IF;


    SET v_fecha_inicio =
        STR_TO_DATE(
            CONCAT(p_anio, '-', LPAD(p_mes, 2, '0'), '-01'),
            '%Y-%m-%d'
        );

    SET v_fecha_fin =
        LAST_DAY(v_fecha_inicio);


    /*
     * ----------------------------------------------------------
     * INICIO DE TRANSACCIÓN
     * ----------------------------------------------------------
     */

    START TRANSACTION;


    /*
     * ----------------------------------------------------------
     * PREVENIR EJECUCIONES DUPLICADAS
     * ----------------------------------------------------------
     *
     * Se bloquea el registro del periodo si ya existe.
     */

    SELECT id_cierre
    INTO v_cierre_id
    FROM cierre_mensual
    WHERE anio = p_anio
      AND mes = p_mes
    FOR UPDATE;


    /*
     * Si ya existe un cierre, no se vuelve a ejecutar.
     */

    IF v_cierre_id IS NOT NULL THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'El periodo indicado ya tiene un cierre registrado';

    END IF;


    /*
     * ----------------------------------------------------------
     * VALIDAR QUE NO EXISTAN ESTANCIAS ABIERTAS DEL PERIODO
     * ----------------------------------------------------------
     *
     * No debemos cerrar un mes si existen estancias sin salida
     * que pertenecen al periodo.
     */

    IF EXISTS (
        SELECT 1
        FROM estancia
        WHERE fecha_entrada >= v_fecha_inicio
          AND fecha_entrada < DATE_ADD(v_fecha_fin, INTERVAL 1 DAY)
          AND fecha_salida IS NULL
    ) THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'No se puede cerrar el periodo: existen estancias abiertas';

    END IF;


    /*
     * ----------------------------------------------------------
     * CREAR REGISTRO DEL CIERRE
     * ----------------------------------------------------------
     */

    INSERT INTO cierre_mensual (
        anio,
        mes,
        fecha_inicio,
        fecha_fin,
        fecha_cierre,
        usuario_cierre,
        total_estancias,
        total_minutos,
        total_cargos,
        total_pagos,
        estado
    )
    VALUES (
        p_anio,
        p_mes,
        v_fecha_inicio,
        v_fecha_fin,
        NOW(),
        p_usuario,
        0,
        0,
        0.00,
        0.00,
        'ABIERTO'
    );

    SET v_cierre_id = LAST_INSERT_ID();


    /*
     * ----------------------------------------------------------
     * GENERAR CARGOS DEL PERIODO
     * ----------------------------------------------------------
     *
     * Solo se generan cargos que todavía no existan.
     *
     * La tarifa se determina por:
     *
     *   1. Tipo de vehículo
     *   2. Fecha de entrada
     *   3. Vigencia de la tarifa
     */

    INSERT INTO cargo (
        id_estancia,
        id_vehiculo,
        id_residente,
        id_tarifa,
        id_cierre,
        minutos_cobrados,
        importe_por_minuto,
        importe_total,
        fecha_cargo,
        periodo_anio,
        periodo_mes,
        estado
    )
    SELECT
        e.id_estancia,
        v.id_vehiculo,
        v.id_residente,
        t.id_tarifa,
        v_cierre_id,

        TIMESTAMPDIFF(
            MINUTE,
            e.fecha_entrada,
            e.fecha_salida
        ) AS minutos_cobrados,

        t.importe_por_minuto,

        ROUND(
            TIMESTAMPDIFF(
                MINUTE,
                e.fecha_entrada,
                e.fecha_salida
            ) * t.importe_por_minuto,
            2
        ) AS importe_total,

        NOW(),

        p_anio,
        p_mes,

        'PENDIENTE'

    FROM estancia e

    INNER JOIN vehiculo v
        ON v.id_vehiculo = e.id_vehiculo

    INNER JOIN tarifa t
        ON t.id_tipo_vehiculo = v.id_tipo_vehiculo

        /*
         * Tarifa vigente al momento de la entrada
         */
        AND e.fecha_entrada >= t.fecha_inicio

        AND (
            t.fecha_fin IS NULL
            OR e.fecha_entrada <= t.fecha_fin
        )

        AND t.activo = TRUE

    LEFT JOIN cargo c
        ON c.id_estancia = e.id_estancia

    WHERE e.fecha_entrada >= v_fecha_inicio
      AND e.fecha_entrada < DATE_ADD(v_fecha_fin, INTERVAL 1 DAY)

      AND e.fecha_salida IS NOT NULL

      /*
       * Evitar generar dos veces el cargo
       */
      AND c.id_cargo IS NULL;


    /*
     * ----------------------------------------------------------
     * CALCULAR TOTALES DEL CIERRE
     * ----------------------------------------------------------
     */

    SELECT
        COUNT(*),
        COALESCE(
            SUM(
                TIMESTAMPDIFF(
                    MINUTE,
                    e.fecha_entrada,
                    e.fecha_salida
                )
            ),
            0
        )
    INTO
        v_total_estancias,
        v_total_minutos

    FROM estancia e

    WHERE e.fecha_entrada >= v_fecha_inicio
      AND e.fecha_entrada < DATE_ADD(v_fecha_fin, INTERVAL 1 DAY)
      AND e.fecha_salida IS NOT NULL;


    /*
     * Total de cargos
     */

    SELECT
        COALESCE(
            SUM(importe_total),
            0.00
        )
    INTO v_total_cargos

    FROM cargo

    WHERE id_cierre = v_cierre_id
      AND estado <> 'CANCELADO';


    /*
     * Total de pagos
     */

    SELECT
        COALESCE(
            SUM(p.importe),
            0.00
        )
    INTO v_total_pagos

    FROM pago p

    INNER JOIN cargo c
        ON c.id_cargo = p.id_cargo

    WHERE c.id_cierre = v_cierre_id
      AND p.estado = 'APLICADO';


    /*
     * ----------------------------------------------------------
     * ACTUALIZAR CIERRE
     * ----------------------------------------------------------
     */

    UPDATE cierre_mensual

    SET
        total_estancias = v_total_estancias,
        total_minutos = v_total_minutos,
        total_cargos = v_total_cargos,
        total_pagos = v_total_pagos,
        fecha_cierre = NOW(),
        usuario_cierre = p_usuario,
        estado = 'CERRADO'

    WHERE id_cierre = v_cierre_id;


    /*
     * ----------------------------------------------------------
     * VALIDACIÓN FINAL
     * ----------------------------------------------------------
     */

    IF v_error = FALSE THEN

        COMMIT;

        SELECT
            v_cierre_id AS id_cierre,
            p_anio AS anio,
            p_mes AS mes,
            v_fecha_inicio AS fecha_inicio,
            v_fecha_fin AS fecha_fin,
            v_total_estancias AS total_estancias,
            v_total_minutos AS total_minutos,
            v_total_cargos AS total_cargos,
            v_total_pagos AS total_pagos,
            p_usuario AS usuario_cierre,
            'CERRADO' AS estado;

    ELSE

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'El cierre mensual no pudo completarse';

    END IF;

END $$

DELIMITER ;
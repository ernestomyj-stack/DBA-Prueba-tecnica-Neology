
CREATE INDEX idx_residente_vivienda
    ON residente (numero_vivienda);

CREATE INDEX idx_residente_activo
    ON residente (activo);


CREATE INDEX idx_vehiculo_residente
    ON vehiculo (id_residente);

CREATE INDEX idx_vehiculo_tipo
    ON vehiculo (id_tipo_vehiculo);

CREATE INDEX idx_vehiculo_activo
    ON vehiculo (activo);


CREATE INDEX idx_tarifa_tipo_fecha
    ON tarifa (
        id_tipo_vehiculo,
        fecha_inicio,
        fecha_fin
    );

CREATE INDEX idx_tarifa_activo
    ON tarifa (activo);



CREATE INDEX idx_estancia_vehiculo
    ON estancia (id_vehiculo);

CREATE INDEX idx_estancia_entrada
    ON estancia (fecha_entrada);

CREATE INDEX idx_estancia_salida
    ON estancia (fecha_salida);

CREATE INDEX idx_estancia_vehiculo_entrada
    ON estancia (
        id_vehiculo,
        fecha_entrada
    );



CREATE INDEX idx_cargo_residente
    ON cargo (id_residente);

CREATE INDEX idx_cargo_vehiculo
    ON cargo (id_vehiculo);

CREATE INDEX idx_cargo_estancia
    ON cargo (id_estancia);

CREATE INDEX idx_cargo_periodo
    ON cargo (
        periodo_anio,
        periodo_mes
    );

CREATE INDEX idx_cargo_cierre
    ON cargo (id_cierre);

CREATE INDEX idx_cargo_estado
    ON cargo (estado);



CREATE INDEX idx_pago_cargo
    ON pago (id_cargo);

CREATE INDEX idx_pago_fecha
    ON pago (fecha_pago);

CREATE INDEX idx_pago_estado
    ON pago (estado);


CREATE INDEX idx_cierre_estado
    ON cierre_mensual (estado);



CREATE INDEX idx_auditoria_fecha
    ON auditoria_operacion (fecha_hora);

CREATE INDEX idx_auditoria_tabla_registro
    ON auditoria_operacion (
        tabla_afectada,
        id_registro
    );

CREATE INDEX idx_auditoria_usuario
    ON auditoria_operacion (usuario);

CREATE INDEX idx_auditoria_operacion
    ON auditoria_operacion (operacion);



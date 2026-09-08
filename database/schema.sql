CREATE DATABASE estacionamiento
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
	
	USE estacionamiento;
	
CREATE TABLE tipo_vehiculo (
    id_tipo_vehiculo INT NOT NULL AUTO_INCREMENT,
    nombre           VARCHAR(50) NOT NULL,
    categoria        VARCHAR(20) NOT NULL,
    descripcion      VARCHAR(255) NULL,
    activo           BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion   DATETIME NOT NULL ,

    CONSTRAINT pk_tipo_vehiculo
        PRIMARY KEY (id_tipo_vehiculo),

    CONSTRAINT uk_tipo_vehiculo_nombre
        UNIQUE (nombre),

    CONSTRAINT chk_tipo_vehiculo_categoria
        CHECK (categoria IN (
            'RESIDENTE',
            'NO_RESIDENTE',
            'OFICIAL'
        ))
) ENGINE=InnoDB;



CREATE TABLE residente (
    id_residente        INT NOT NULL AUTO_INCREMENT,
    nombre              VARCHAR(100) NOT NULL,
    apellido_paterno    VARCHAR(100) NOT NULL,
    apellido_materno    VARCHAR(100) NULL,
    email               VARCHAR(150) NULL,
    telefono            VARCHAR(30) NULL,
    numero_vivienda     VARCHAR(30) NOT NULL,
    activo              BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_alta          DATETIME NOT NULL ,
    fecha_baja          DATETIME NULL,
    fecha_creacion      DATETIME NOT NULL ,
    fecha_actualizacion DATETIME NOT NULL 
                        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_residente
        PRIMARY KEY (id_residente),

    CONSTRAINT uk_residente_email
        UNIQUE (email),

    CONSTRAINT chk_residente_fechas
        CHECK (
            fecha_baja IS NULL
            OR fecha_baja >= fecha_alta
        )
) ENGINE=InnoDB;


CREATE TABLE vehiculo (
    id_vehiculo        INT NOT NULL AUTO_INCREMENT,
    id_residente       INT NULL,
    id_tipo_vehiculo   INT NOT NULL,
    placa              VARCHAR(20) NOT NULL,
    marca              VARCHAR(50) NULL,
    modelo             VARCHAR(50) NULL,
    color              VARCHAR(30) NULL,
    anio               SMALLINT UNSIGNED NULL,
    activo             BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_alta         DATETIME NOT NULL ,
    fecha_baja         DATETIME NULL,
    fecha_creacion     DATETIME NOT NULL ,
    fecha_actualizacion DATETIME NOT NULL 
                       ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_vehiculo
        PRIMARY KEY (id_vehiculo),

    CONSTRAINT uk_vehiculo_placa
        UNIQUE (placa),

    CONSTRAINT fk_vehiculo_residente
        FOREIGN KEY (id_residente)
        REFERENCES residente (id_residente),

    CONSTRAINT fk_vehiculo_tipo
        FOREIGN KEY (id_tipo_vehiculo)
        REFERENCES tipo_vehiculo (id_tipo_vehiculo),

    CONSTRAINT chk_vehiculo_anio
        CHECK (
            anio IS NULL
            OR anio BETWEEN 1900 AND 2100
        ),

    CONSTRAINT chk_vehiculo_fechas
        CHECK (
            fecha_baja IS NULL
            OR fecha_baja >= fecha_alta
        )
) ENGINE=InnoDB;

CREATE INDEX idx_vehiculo_residente
    ON vehiculo (id_residente);

CREATE INDEX idx_vehiculo_tipo
    ON vehiculo (id_tipo_vehiculo);

CREATE INDEX idx_vehiculo_activo
    ON vehiculo (activo);


CREATE TABLE tarifa (
    id_tarifa             INT NOT NULL AUTO_INCREMENT,
    id_tipo_vehiculo      INT NOT NULL,
    nombre                VARCHAR(100) NOT NULL,
    importe_por_minuto    DECIMAL(10,4) NOT NULL,
    fecha_inicio          DATETIME NOT NULL,
    fecha_fin             DATETIME NULL,
    activo                BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion        DATETIME NOT NULL ,

    CONSTRAINT pk_tarifa
        PRIMARY KEY (id_tarifa),

    CONSTRAINT fk_tarifa_tipo
        FOREIGN KEY (id_tipo_vehiculo)
        REFERENCES tipo_vehiculo (id_tipo_vehiculo),

    CONSTRAINT chk_tarifa_importe
        CHECK (importe_por_minuto >= 0),

    CONSTRAINT chk_tarifa_fechas
        CHECK (
            fecha_fin IS NULL
            OR fecha_fin >= fecha_inicio
        )
) ENGINE=InnoDB;

CREATE INDEX idx_tarifa_tipo_fecha
    ON tarifa (
        id_tipo_vehiculo,
        fecha_inicio,
        fecha_fin
    );

CREATE INDEX idx_tarifa_activo
    ON tarifa (activo);


CREATE TABLE estancia (
    id_estancia       INT NOT NULL AUTO_INCREMENT,
    id_vehiculo       INT NOT NULL,
    fecha_entrada     DATETIME NOT NULL,
    fecha_salida      DATETIME NULL,
    minutos_estancia  INT UNSIGNED NULL,
    fecha_creacion    DATETIME NOT NULL ,

    CONSTRAINT pk_estancia
        PRIMARY KEY (id_estancia),

    CONSTRAINT fk_estancia_vehiculo
        FOREIGN KEY (id_vehiculo)
        REFERENCES vehiculo (id_vehiculo),

    CONSTRAINT chk_estancia_fechas
        CHECK (
            fecha_salida IS NULL
            OR fecha_salida >= fecha_entrada
        ),

    CONSTRAINT chk_estancia_minutos
        CHECK (
            minutos_estancia IS NULL
            OR minutos_estancia >= 0
        )
) ENGINE=InnoDB;

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


CREATE TABLE cierre_mensual (
    id_cierre          INT NOT NULL AUTO_INCREMENT,
    anio               SMALLINT UNSIGNED NOT NULL,
    mes                TINYINT UNSIGNED NOT NULL,
    fecha_inicio       DATETIME NOT NULL,
    fecha_fin          DATETIME NOT NULL,
    fecha_cierre       DATETIME NULL,
    usuario_cierre     VARCHAR(100) NULL,
    total_minutos      INT NOT NULL DEFAULT 0,
    total_cargos       DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    total_pagos        DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    total_pendiente    DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    estado             VARCHAR(20) NOT NULL DEFAULT 'ABIERTO',
    fecha_creacion     DATETIME NOT NULL ,

    CONSTRAINT pk_cierre_mensual
        PRIMARY KEY (id_cierre),

    CONSTRAINT uk_cierre_anio_mes
        UNIQUE (anio, mes),

    CONSTRAINT chk_cierre_mes
        CHECK (mes BETWEEN 1 AND 12),

    CONSTRAINT chk_cierre_fechas
        CHECK (fecha_fin >= fecha_inicio),

    CONSTRAINT chk_cierre_estado
        CHECK (
            estado IN (
                'ABIERTO',
                'CERRADO',
                'REABIERTO'
            )
        ),

    CONSTRAINT chk_cierre_totales
        CHECK (
            total_minutos >= 0
            AND total_cargos >= 0
            AND total_pagos >= 0
            AND total_pendiente >= 0
        )
) ENGINE=InnoDB;

CREATE INDEX idx_cierre_estado
    ON cierre_mensual (estado);


CREATE TABLE cargo (
    id_cargo             INT NOT NULL AUTO_INCREMENT,
    id_estancia          INT NOT NULL,
    id_vehiculo          INT NOT NULL,
    id_residente         INT NULL,
    id_tarifa            INT NOT NULL,
    id_cierre            INT NULL,

    minutos_cobrados     INT UNSIGNED NOT NULL,
    importe_por_minuto   DECIMAL(10,4) NOT NULL,
    importe_total        DECIMAL(14,2) NOT NULL,

    fecha_cargo          DATETIME NOT NULL ,
    periodo_anio         SMALLINT UNSIGNED NOT NULL,
    periodo_mes          TINYINT UNSIGNED NOT NULL,

    estado               VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    fecha_creacion       DATETIME NOT NULL ,

    CONSTRAINT pk_cargo
        PRIMARY KEY (id_cargo),

    CONSTRAINT uk_cargo_estancia
        UNIQUE (id_estancia),

    CONSTRAINT fk_cargo_estancia
        FOREIGN KEY (id_estancia)
        REFERENCES estancia (id_estancia),

    CONSTRAINT fk_cargo_vehiculo
        FOREIGN KEY (id_vehiculo)
        REFERENCES vehiculo (id_vehiculo),

    CONSTRAINT fk_cargo_residente
        FOREIGN KEY (id_residente)
        REFERENCES residente (id_residente),

    CONSTRAINT fk_cargo_tarifa
        FOREIGN KEY (id_tarifa)
        REFERENCES tarifa (id_tarifa),

    CONSTRAINT fk_cargo_cierre
        FOREIGN KEY (id_cierre)
        REFERENCES cierre_mensual (id_cierre),

    CONSTRAINT chk_cargo_importes
        CHECK (
            minutos_cobrados >= 0
            AND importe_por_minuto >= 0
            AND importe_total >= 0
        ),

    CONSTRAINT chk_cargo_mes
        CHECK (
            periodo_mes BETWEEN 1 AND 12
        ),

    CONSTRAINT chk_cargo_estado
        CHECK (
            estado IN (
                'PENDIENTE',
                'PAGADO',
                'CANCELADO'
            )
        )
) ENGINE=InnoDB;

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



CREATE TABLE pago (
    id_pago          INT NOT NULL AUTO_INCREMENT,
    id_cargo         INT NOT NULL,
    fecha_pago       DATETIME NOT NULL ,
    importe          DECIMAL(14,2) NOT NULL,
    metodo_pago      VARCHAR(30) NOT NULL,
    referencia       VARCHAR(100) NULL,
    estado           VARCHAR(20) NOT NULL DEFAULT 'APLICADO',
    fecha_creacion   DATETIME NOT NULL ,

    CONSTRAINT pk_pago
        PRIMARY KEY (id_pago),

    CONSTRAINT fk_pago_cargo
        FOREIGN KEY (id_cargo)
        REFERENCES cargo (id_cargo),

    CONSTRAINT chk_pago_importe
        CHECK (importe > 0),

    CONSTRAINT chk_pago_metodo
        CHECK (
            metodo_pago IN (
                'EFECTIVO',
                'TRANSFERENCIA',
                'TARJETA',
                'DEPOSITO'
            )
        ),

    CONSTRAINT chk_pago_estado
        CHECK (
            estado IN (
                'APLICADO',
                'CANCELADO'
            )
        )
) ENGINE=InnoDB;

CREATE INDEX idx_pago_cargo
    ON pago (id_cargo);

CREATE INDEX idx_pago_fecha
    ON pago (fecha_pago);


CREATE TABLE auditoria_operacion (
    id_auditoria       INT NOT NULL AUTO_INCREMENT,
    fecha_hora         DATETIME NOT NULL ,
    usuario            VARCHAR(100) NOT NULL,
    operacion          VARCHAR(20) NOT NULL,
    tabla_afectada     VARCHAR(100) NOT NULL,
    id_registro        INT NULL,
    valor_anterior     JSON NULL,
    valor_nuevo        JSON NULL,
    ip_origen          VARCHAR(45) NULL,
    resultado          VARCHAR(20) NOT NULL DEFAULT 'EXITOSO',

    CONSTRAINT pk_auditoria
        PRIMARY KEY (id_auditoria),

    CONSTRAINT chk_auditoria_operacion
        CHECK (
            operacion IN (
                'INSERT',
                'UPDATE',
                'DELETE',
                'CIERRE'
            )
        ),

    CONSTRAINT chk_auditoria_resultado
        CHECK (
            resultado IN (
                'EXITOSO',
                'ERROR'
            )
        )
) ENGINE=InnoDB;

CREATE INDEX idx_auditoria_fecha
    ON auditoria_operacion (fecha_hora);

CREATE INDEX idx_auditoria_tabla_registro
    ON auditoria_operacion (
        tabla_afectada,
        id_registro
    );

CREATE INDEX idx_auditoria_usuario
    ON auditoria_operacion (usuario);
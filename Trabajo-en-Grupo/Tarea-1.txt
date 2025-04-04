-- EJERCICIO 1: CREAR USUARIO Y TABLESPACE
-- SYSTEM
CREATE USER PLYTIX IDENTIFIED BY "Febrero.2025";
ALTER USER PLYTIX DEFAULT TABLESPACE TS_PLYTIX QUOTA 100M ON TS_PLYTIX;

GRANT CREATE SESSION TO PLYTIX;
GRANT CONNECT TO PLYTIX;
GRANT CREATE TABLE TO PLYTIX;
GRANT CREATE VIEW TO PLYTIX;
GRANT CREATE MATERIALIZED VIEW TO PLYTIX;
GRANT CREATE SEQUENCE TO PLYTIX;
GRANT CREATE PROCEDURE TO PLYTIX;

CREATE TABLESPACE TS_INDICES DATAFILE 'ts_indices.dbf' SIZE 50M AUTOEXTEND ON;

ALTER USER PLYTIX QUOTA 50M ON TS_INDICES;

-- SELECT * FROM DBA_DATA_FILES;

-- EJERCICIO 2:
-- Generado por Oracle SQL Developer Data Modeler 23.1.0.087.0806
--   en:        2025-03-31 12:27:56 CEST
--   sitio:      Oracle Database 11g
--   tipo:      Oracle Database 11g



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE activos (
    id        INTEGER NOT NULL,
    nombre    VARCHAR2(50) NOT NULL,
    tamaño    INTEGER NOT NULL,
    tipo      VARCHAR2(50),
    url       VARCHAR2(100),
    cuenta_id INTEGER NOT NULL
);

ALTER TABLE activos ADD CONSTRAINT activos_pk PRIMARY KEY ( id,
                                                            cuenta_id );

CREATE TABLE atributo_producto (
    valor              VARCHAR2(50),
    producto_gtin      NUMBER NOT NULL,
    atributos_id       INTEGER NOT NULL,
    producto_cuenta_id INTEGER NOT NULL
);

ALTER TABLE atributo_producto
    ADD CONSTRAINT atributo_producto_pk PRIMARY KEY ( producto_gtin,
                                                      producto_cuenta_id,
                                                      atributos_id );

CREATE TABLE atributos (
    id     INTEGER NOT NULL,
    nombre VARCHAR2(50) NOT NULL,
    tipo   VARCHAR2(50),
    creado DATE
);

ALTER TABLE atributos ADD CONSTRAINT atributos_pk PRIMARY KEY ( id );

CREATE TABLE categoría (
    id        INTEGER NOT NULL,
    nombre    VARCHAR2(50) NOT NULL,
    cuenta_id INTEGER NOT NULL
);

ALTER TABLE categoría ADD CONSTRAINT categoría_pk PRIMARY KEY ( id,
                                                                cuenta_id );

CREATE TABLE categoria_activos (
    id        INTEGER NOT NULL,
    nombre    VARCHAR2(50) NOT NULL,
    cuenta_id INTEGER NOT NULL
);

ALTER TABLE categoria_activos ADD CONSTRAINT categoria_activos_pk PRIMARY KEY ( cuenta_id );

CREATE TABLE cuenta (
    id              INTEGER NOT NULL,
    nombre          VARCHAR2(50) NOT NULL,
    direccionfiscal VARCHAR2(50) NOT NULL,
    nif             VARCHAR2(9) NOT NULL,
    fechaalta       DATE NOT NULL,
    usuario_id      INTEGER,
    plan_id         INTEGER NOT NULL
);

CREATE UNIQUE INDEX cuenta__idx ON
    cuenta (
        usuario_id
    ASC );

ALTER TABLE cuenta ADD CONSTRAINT cuenta_pk PRIMARY KEY ( id );

CREATE TABLE plan (
    id                 INTEGER NOT NULL,
    productos          INTEGER NOT NULL,
    activos            INTEGER NOT NULL,
    almacenamiento     VARCHAR2(10) NOT NULL,
    categoriasproducto INTEGER,
    categoriasactivos  INTEGER,
    relaciones         INTEGER NOT NULL,
    precio             INTEGER NOT NULL
);

ALTER TABLE plan ADD CONSTRAINT plan_pk PRIMARY KEY ( id );

CREATE TABLE producto (
    gtin       NUMBER NOT NULL,
    sku        VARCHAR2(100) NOT NULL,
    nombre     VARCHAR2(50) NOT NULL,
    miniatura  VARCHAR2(100),
    textocorto VARCHAR2(100),
    creado     DATE,
    modificado DATE,
    cuenta_id  INTEGER NOT NULL
);

ALTER TABLE producto ADD CONSTRAINT producto_pk PRIMARY KEY ( gtin,
                                                              cuenta_id );

CREATE TABLE relacionado (
    nombre              VARCHAR2(50) NOT NULL,
    sentido             VARCHAR2(50),
    producto_gtin       NUMBER NOT NULL,
    producto_gtin1      NUMBER NOT NULL,
    producto_cuenta_id  INTEGER NOT NULL,
    producto_cuenta_id1 INTEGER NOT NULL
);

ALTER TABLE relacionado
    ADD CONSTRAINT relacionado_pk PRIMARY KEY ( producto_gtin,
                                                producto_cuenta_id,
                                                producto_gtin1,
                                                producto_cuenta_id1 );

CREATE TABLE relation_16 (
    activos_id        INTEGER NOT NULL,
    activos_cuenta_id INTEGER NOT NULL,
    cat_act_cuenta_id INTEGER NOT NULL
);

ALTER TABLE relation_16
    ADD CONSTRAINT relation_16_pk PRIMARY KEY ( activos_id,
                                                activos_cuenta_id,
                                                cat_act_cuenta_id );

CREATE TABLE relation_4 (
    producto_gtin      NUMBER NOT NULL,
    producto_cuenta_id INTEGER NOT NULL,
    activos_id         INTEGER NOT NULL,
    activos_cuenta_id  INTEGER NOT NULL
);

ALTER TABLE relation_4
    ADD CONSTRAINT relation_4_pk PRIMARY KEY ( producto_gtin,
                                               producto_cuenta_id,
                                               activos_id,
                                               activos_cuenta_id );

CREATE TABLE relation_7 (
    producto_gtin       NUMBER NOT NULL,
    producto_cuenta_id  INTEGER NOT NULL,
    categoría_id        INTEGER NOT NULL,
    categoría_cuenta_id INTEGER
);

ALTER TABLE relation_7
    ADD CONSTRAINT relation_7_pk PRIMARY KEY ( producto_gtin,
                                               producto_cuenta_id,
                                               categoría_id,
                                               categoría_cuenta_id );

CREATE TABLE usuario (
    id             INTEGER NOT NULL,
    nombreusuario  VARCHAR2(20) NOT NULL,
    nombrecompleto VARCHAR2(50) NOT NULL,
    avatar         VARCHAR2(100),
    teléfono       INTEGER,
    cuenta_id1     INTEGER NOT NULL,
    cuenta_id      INTEGER
);

COMMENT ON COLUMN usuario.nombreusuario IS
    'Usuario con el que se conecta a la base de datos de Oracle';

CREATE UNIQUE INDEX usuario__idx ON
    usuario (
        cuenta_id
    ASC );

ALTER TABLE usuario ADD CONSTRAINT usuario_pk PRIMARY KEY ( id );

ALTER TABLE activos
    ADD CONSTRAINT activos_cuenta_fk FOREIGN KEY ( cuenta_id )
        REFERENCES cuenta ( id );

ALTER TABLE atributo_producto
    ADD CONSTRAINT atributo_producto_atributos_fk FOREIGN KEY ( atributos_id )
        REFERENCES atributos ( id );

ALTER TABLE atributo_producto
    ADD CONSTRAINT atributo_producto_producto_fk FOREIGN KEY ( producto_gtin,
                                                               producto_cuenta_id )
        REFERENCES producto ( gtin,
                              cuenta_id );

ALTER TABLE categoria_activos
    ADD CONSTRAINT categoria_activos_cuenta_fk FOREIGN KEY ( cuenta_id )
        REFERENCES cuenta ( id );

ALTER TABLE categoría
    ADD CONSTRAINT categoría_cuenta_fk FOREIGN KEY ( cuenta_id )
        REFERENCES cuenta ( id );

ALTER TABLE cuenta
    ADD CONSTRAINT cuenta_plan_fk FOREIGN KEY ( plan_id )
        REFERENCES plan ( id );

ALTER TABLE producto
    ADD CONSTRAINT producto_cuenta_fk FOREIGN KEY ( cuenta_id )
        REFERENCES cuenta ( id );

ALTER TABLE relacionado
    ADD CONSTRAINT relacionado_producto_fk FOREIGN KEY ( producto_gtin,
                                                         producto_cuenta_id )
        REFERENCES producto ( gtin,
                              cuenta_id );

ALTER TABLE relacionado
    ADD CONSTRAINT relacionado_producto_fkv1 FOREIGN KEY ( producto_gtin1,
                                                           producto_cuenta_id1 )
        REFERENCES producto ( gtin,
                              cuenta_id );

ALTER TABLE relation_16
    ADD CONSTRAINT relation_16_activos_fk FOREIGN KEY ( activos_id,
                                                        activos_cuenta_id )
        REFERENCES activos ( id,
                             cuenta_id );

ALTER TABLE relation_16
    ADD CONSTRAINT relation_16_cat_act_fk FOREIGN KEY ( cat_act_cuenta_id )
        REFERENCES categoria_activos ( cuenta_id );

ALTER TABLE relation_4
    ADD CONSTRAINT relation_4_activos_fk FOREIGN KEY ( activos_id,
                                                       activos_cuenta_id )
        REFERENCES activos ( id,
                             cuenta_id );

ALTER TABLE relation_4
    ADD CONSTRAINT relation_4_producto_fk FOREIGN KEY ( producto_gtin,
                                                        producto_cuenta_id )
        REFERENCES producto ( gtin,
                              cuenta_id );

ALTER TABLE relation_7
    ADD CONSTRAINT relation_7_categoría_fk FOREIGN KEY ( categoría_id,
                                                         categoría_cuenta_id )
        REFERENCES categoría ( id,
                               cuenta_id );

ALTER TABLE relation_7
    ADD CONSTRAINT relation_7_producto_fk FOREIGN KEY ( producto_gtin,
                                                        producto_cuenta_id )
        REFERENCES producto ( gtin,
                              cuenta_id );

ALTER TABLE usuario
    ADD CONSTRAINT usuario_cuenta_fk FOREIGN KEY ( cuenta_id1 )
        REFERENCES cuenta ( id );



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            13
-- CREATE INDEX                             2
-- ALTER TABLE                             29
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0

--------------------------------------------------------------------------------
---------------------------- PRACTICA II. PLSQL --------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EJERCICIO 1.
--------------------------------------------------------------------------------
-- Cree una tabla llamada TB_OBJETOS con los siguientes atributos: NOMBRE,
-- CODIGO, FECHA_CREACION, FECHA_MODIFICACION, TIPO, ESQUEMA_ORIGINAL. Recorra
-- la vista ALL_OBJECTS y rellena esta tabla con los datos que se aportan en la 
-- vista. Use un cursor y no un INSERT.
--------------------------------------------------------------------------------
-- Creamos la tabla.
CREATE TABLE TB_OBJETOS AS
SELECT 
    OBJECT_NAME NOMBRE,
    OBJECT_ID CODIGO,
    CREATED FECHA_CREACION,
    LAST_DDL_TIME FECHA_MODIFICACION,
    OBJECT_TYPE TIPO,
    OWNER ESQUEMA_ORIGINAL
FROM ALL_OBJECTS
WHERE 1 = 0;                            
-- Ponemos esta última condición siempre falsa para que no inserte datos en la 
-- tabla y hacerlo ahora con un cursor.

-- Vamos insertando datos a la tabla con el cursor
DECLARE 
    CURSOR C IS SELECT * FROM ALL_OBJECTS;
    CONTADOR NUMBER := 0;
BEGIN
    FOR R IN C LOOP -- R ES COMO SI FUESE UN STRUCT
        INSERT INTO TB_OBJETOS(NOMBRE, CODIGO, FECHA_CREACION, 
                                FECHA_MODIFICACION, TIPO, ESQUEMA_ORIGINAL)
            VALUES (
                R.OBJECT_NAME,
                R.OBJECT_ID,
                R.CREATED,
                R.LAST_DDL_TIME,
                R.OBJECT_TYPE,
                R. OWNER );
        IF CONTADOR = 1000 THEN
            CONTADOR := 0;
            COMMIT;
        ELSE
            CONTADOR := CONTADOR + 1;
        END IF;
    END LOOP;
    COMMIT;
END;
/

--------------------------------------------------------------------------------
-- EJERCICIO 2.
--------------------------------------------------------------------------------
-- Cree una tabla TB_ESTILO con los siguientes atributos: TIPO_OBJETO, PREFIJO. 
-- En esta tabla se guardas unas normas de estilo de modo que a cada tipo de 
-- objeto le corresponde un prefijo en su indicador. Así por ejemplo guardamos
-- la tupla ('PROCEDURE', 'PR_') para indicar que un nombre correcto de
-- procedimiento es PR_HOLA_MUNDO.
--------------------------------------------------------------------------------
-- Creamos tabla
CREATE TABLE TB_ESTILOS AS
    SELECT DISTINCT TIPO TIPO_OBJETO, SUBSTR(TIPO, 1, 2) || '_' PREFIJO 
    FROM TB_OBJETOS;

-- Actualizamos que Table empiece por TB_
UPDATE "USUARIOADMIN"."TB_ESTILOS" 
    SET PREFIJO = 'TB_' 
    WHERE TIPO_OBJETO = 'TABLE';
    
-- CREAMOS EL PROCEDIMIENTO
ALTER TABLE TB_OBJETOS ADD(
    ESTADO VARCHAR2(15),
    NOMBRE_CORRECTO VARCHAR2(128)
);

create or replace PROCEDURE PR_COMPROBAR 
(
    ESQUEMA IN VARCHAR2
)   AS 
    CURSOR C IS 
        SELECT NOMBRE, TIPO, ESQUEMA_ORIGINAL, PREFIJO 
        FROM TB_OBJETOS JOIN TB_ESTILOS ON TIPO = TIPO_OBJETO
        WHERE ESQUEMA IS NULL OR ESQUEMA = ESQUEMA_ORIGINAL
        FOR UPDATE;
    NUEVO_NOMBRE TB_OBJETOS.NOMBRE_CORRECTO%TYPE;
BEGIN
  FOR R IN C LOOP
    IF R.PREFIJO = SUBSTR(R.NOMBRE, 1, LENGTH(R.PREFIJO)) 
        THEN
            UPDATE TB_OBJETOS
            SET ESTADO = 'CORRECTO',
                NOMBRE_CORRECTO = R.NOMBRE
            WHERE R.NOMBRE = NOMBRE;
            DBMS_OUTPUT.PUT_LINE ('CORRECTO: '||R.NOMBRE);
        ELSE
            NUEVO_NOMBRE := R.PREFIJO ||R.NOMBRE;
            IF LENGTH(NUEVO_NOMBRE)>128 THEN
                NUEVO_NOMBRE:=SUBSTR(NUEVO_NOMBRE, 1, 128);
            END IF;
            --DBMS_OUTPUT.PUT_LINE ('INCORRECTO: '||R.NOMBRE);  
            --UPDATE TB_OBJETOS
            --SET ESTADO = 'INCORRECTO',
                --NOMBRE_CORRECTO = NUEVO_NOMBRE
            --WHERE R.NOMBRE = NOMBRE;
    END IF;
  END LOOP;
  COMMIT;
END PR_COMPROBAR;
/
-- No termina de funcionarme correctamente

-- AHORA EJECUTAMOS
SET SERVEROUTPUT ON;

BEGIN 
    pr_comprobar(NULL);
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('mal mal mal');
        RAISE NO_DATA_FOUND;
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('iNESPERADO');
        RAISE;
END;

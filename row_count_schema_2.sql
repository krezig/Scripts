--
-- Copyright (c) TecnoEnt.com 2010. Reservados todos los derechos
--
-- NOMBRE: row_count_schema_2.sql
--
-- DESCRIPCION
--   Este script genera un reporte (row_count_USUARIO.lst) contando la cantidad
--   de filas de todas las tablas del schema en que se ejecute.
--
-- USO
--    Desde una ventana de SQL*Plus, ingrese:
--      START row_count_schema_2.sql

SET TERMOUT OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET TRIMSPOOL ON

COLUMN u noprint new_value usuario

SPOOL temp.sql

SELECT 'SELECT ''' || table_name || ':'' || COUNT(*) ' ||
       'FROM ' || table_name || ';', user u
FROM user_tables
ORDER BY table_name;

SPOOL OFF

SET TERMOUT ON
SPOOL row_count_&usuario..lst
@temp.sql
SPOOL OFF

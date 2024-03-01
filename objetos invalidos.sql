select owner, object_name, object_type, status from dba_objects where owner in ('TRECA', 'OBLI_TRECA', 'RELOG_TRECA') and status = 'INVALID' order by OWNER,OBJECT_NAME DESC;

BEGIN
DBMS_UTILITY.COMPILE_SCHEMA('RECAUDADOR');
END;

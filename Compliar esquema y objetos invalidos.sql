BEGIN

END;
/
BEGIN
DBMS_UTILITY.COMPILE_SCHEMA('RECAUDADOR');
DBMS_UTILITY.COMPILE_SCHEMA('OBLI_RECAUDADOR');
DBMS_UTILITY.COMPILE_SCHEMA('RELOG_RECAUDADOR');
END;
/
BEGIN

END;
/


select owner, object_name, object_type, status from dba_objects where owner in ('DEMO_RECAVAG') and status = 'INVALID' order by OWNER,OBJECT_NAME DESC;

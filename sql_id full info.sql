
set long 100000;
set pagesize 50000;
spool C:\oracle\product\display_sql.txt; --especificar donde se guardata el output

SELECT
     s.sid,
     s.serial#,
     s.status,
     s.schemaname,
     s.osuser,
     s.machine,
     s.program,
     s.prev_exec_start,
     t.module,
     s.sql_id,
     t.sql_fulltext
 FROM
    v$sql t  JOIN v$session s
on t.sql_id = s.sql_id and s.sql_id in(<especificar los SQL ID a buscar>) ;


spool off;


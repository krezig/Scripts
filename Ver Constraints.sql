BEGIN
DBMS_OUTPUT.ENABLE(1000000);
FOR c IN
(SELECT c.owner, c.table_name, c.constraint_name
FROM user_constraints c, user_tables t
WHERE c.table_name = t.table_name
AND C.STATUS = 'ENABLED'
ORDER BY c.constraint_type DESC)
LOOP
dbms_output.put_line('ALTER TABLE ' || C.OWNER || '.' || C.TABLE_NAME || ' disable constraint ' || C.CONSTRAINT_NAME||' cascade;');

END LOOP;
END;

select 'alter table '|| C.OWNER || '.' ||c.table_name||' disable constraint '||c.constraint_name||' cascade;' FROM user_constraints c, user_tables t
WHERE c.table_name = t.table_name
AND C.STATUS = 'ENABLED';


select 'alter table '|| C.OWNER || '.' ||c.table_name||' enable constraint '||c.constraint_name||';' FROM user_constraints c, user_tables t
WHERE c.table_name = t.table_name
AND C.STATUS = 'DISABLED';



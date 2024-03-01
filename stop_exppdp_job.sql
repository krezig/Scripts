--First Method: Kill Data pump job by datapump export prompt:
--After initiating export backup, Kindly make sure datapump job by issuing the following query as sysdba:

SQL> select * from dba_datapump_jobs;

--Now connect to datapump export prompt with JOB_NAME(attach) as below & issue the datapump command: KILL_JOB.

expdp system/passwd attach=SYS_EXPORT_FULL_01

Export> KILL_JOB
Are you sure you wish to stop this job ([yes]/no): yes
[oracle@dbserver ~]$


--Second Method: Kill Datapump job by running SQL package:
--After inititating the oracle datapump export, ensure datapump job by issuing the following query as sysdba:

SQL> select * from dba_datapump_jobs;

--To kill datapump job, We need two parameter as input to SQL package are: JOB_NAME of the datapump job & OWNER_NAME who initiated export.

SQL> DECLARE
h1 NUMBER;
BEGIN
h1:=DBMS_DATAPUMP.ATTACH(‘SYS_EXPORT_FULL_01‘,’SYSTEM‘);
DBMS_DATAPUMP.STOP_JOB (h1,1,0);
END;
/

PL/SQL procedure successfully completed.
SQL>
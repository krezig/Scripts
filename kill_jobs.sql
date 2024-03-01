*****   CONSULTAS    *****
select job, schema_user, last_date, broken,misc_env from dba_jobs;

select job, schema_user, last_date, broken,what from dba_jobs where schema_user='RECAUDADOR' AND Broken='N';
*****   ELIMINAR DEL SCHEDULER   *****

BEGIN
DBMS_SCHEDULER.DROP_JOB (job_name => 'my_job1');
END;
/
*****   TRABAJO CON JOB DE OTRO USUARIO CON SYS/SYSTEM   *****

- Eliminar JOB
EXEC DBMS_IJOB.REMOVE(123);

- Terminar la Ejecuci�n
EXEC DBMS_IJOB.BROKEN(123,TRUE);





---------------------------------------------------


If you want to kill a running job, do it in 3 steps. First find the jobs running related session.

SELECT /*+ RULE */ D.JOB, V.SID, V.SERIAL#, LOG_USER USERNAME, WHAT,
DECODE(TRUNC(SYSDATE - LOGON_TIME), 0, NULL,
TRUNC(SYSDATE - LOGON_TIME) || ' Days' || ' + ') ||
TO_CHAR(TO_DATE(TRUNC(MOD(SYSDATE-LOGON_TIME,1) * 86400), 'SSSSS'), 'HH24:MI:SS') RUNNING,
D.FAILURES, 'alter system kill session ' || '''' || V.SID || ', ' || V.SERIAL# || '''' || ' immediate;' KILL_SQL
FROM DBA_JOBS_RUNNING D, V$SESSION V, DBA_JOBS J
WHERE V.SID = D.SID
AND D.JOB = J.JOB;

Second login as the owner of the job and mark it BROKEN

BEGIN
 DBMS_JOB.BROKEN(JOB,TRUE);
END;
COMMIT;

Third as sysdba kill the related session

ALTER SYSTEM KILL SESSION 'SID, SERIAL#' IMMEDIATE;

Tip : Marking the job as Broken is necessary; otherwise, the job queue process will restart the job as soon as it notices the session has been killed. 




To check running jobs on oracle RAC you can use query:

SELECT J.JOB, V.SID, S.SERIAL#, S.STATUS, LOWNER USERNAME, WHAT, 
DECODE(TRUNC(SYSDATE - LOGON_TIME), 0, NULL,
TRUNC(SYSDATE - LOGON_TIME) || ' Days' || ' + ') ||
TO_CHAR(TO_DATE(TRUNC(MOD(SYSDATE-LOGON_TIME,1) * 86400), 'SSSSS'), 'HH24:MI:SS') RUNNING, 
J.FAILURES, V.INST_ID INSTANCE, 
'alter system kill session ' || '''' || S.SID || ', ' || S.SERIAL# || '''' || ' immediate;' KILL_SQL
  FROM SYS.JOB$ J, GV$LOCK V, GV$SESSION S
  WHERE V.TYPE = 'JQ' 
  AND J.JOB = V.ID2 
  AND S.SID = V.SID
  ;
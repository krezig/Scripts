CREATE OR REPLACE PROCEDURE proc_kill_inactive_sessions IS
   CURSOR kill_sessions_cur
   IS
      SELECT s.SID, s.serial#
        FROM v$session s
       WHERE s.status = 'INACTIVE'
	AND USERNAME = 'RECAUDADOR'
	AND machine = 'servicios.spf.tabasco.gob.mx';

   v_cmd   VARCHAR2 (100);
BEGIN
   FOR kill_sessions_rec IN kill_sessions_cur
   LOOP
      v_cmd :=
            'Alter system kill session '''
         || kill_sessions_rec.SID
         || ','
         || kill_sessions_rec.serial#
         || ''' immediate';

      EXECUTE IMMEDIATE v_cmd;
   END LOOP;
END;
/


BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'test.kill_old_report_sessions_job',
    comments        => 'Kill old reports if they have been running for longer than 1 hour.',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN admin_tasks_user.kill_old_report_sessions; END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'freq=hourly; byminute=0,15,30,45; bysecond=0;',
    enabled         => TRUE);
END;
/
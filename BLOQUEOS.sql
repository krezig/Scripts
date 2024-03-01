#revision general de bloqueos, revision rapida a grandes rasgos


select session_id, lock_type, mode_held from dba_locks where blocking_others= 'Blocking';
select * from dba_blockers;
select * from dba_waiters;
SELECT STATE, MACHINE, OSUSER, SCHEMANAME, STATUS, LOCKWAIT, USERNAME, SID, SERIAL# FROM V$SESSION WHERE SID = 20 OR SID = 152 OR SID = 400 ;

BD RE_DECLARACIONES_CALCULO


#revision del audit trail


SELECT username, action_name, priv_used,USERHOST, EXTENDED_TIMESTAMP, returncode from dba_audit_trail where username = 'DEV_DN0009' order by EXTENDED_TIMESTAMP desc;


-- Shows objects accessed in the schema for a given Session ID.
--
 
SET PAUSE ON
SET PAUSE 'Press Return to Continue'
SET PAGESIZE 60
SET LINESIZE 300
SET VERIFY OFF
 
COLUMN object FORMAT A32
COLUMN type FORMAT A15
COLUMN sid FORMAT 9999
COLUMN username FORMAT A20
COLUMN osuser FORMAT A10
COLUMN program FORMAT A40
 
SELECT a.object,
       a.type,
       a.sid,
       b.username,
       b.osuser,
       b.program
FROM   v$access a,
       v$session b
WHERE  a.sid   = b.sid
AND    a.owner = UPPER('&ENTER_SCHEMA_NAME')
AND    a.sid = &enter_session_id
ORDER BY a.object
/

/*V$ACCESS – You can use the V$ACCESS view to see which users have locks on which objects in your database*/
     SELECT SID, OWNER, OBJECT, TYPE
     FROM V$ACCESS
     WHERE OBJECT = 'object_name';

      select 'alter system kill session' || V$ACCESS.sid || ',' || v$session.serial# || 'immediate;' from v$access join v$session  on (V$ACCESS.sid = v$session.sid) where v$access.object = 'RE_UTIL';
/*$SESSION_EVENT and V$SESSION_WAIT – use these views to see what Oracle wait events the session(s) are waiting on*/
     SELECT *
     FROM V$SESSION_EVENT
     WHERE SID = <sid>
     ORDER BY TIME_WAITED DESC;

     SELECT *
     FROM V$SESSION_WAIT
     WHERE SID = <sid>;

/*V$LOCKED_OBJECT – This view will also help you see who is locking the object*/

SELECT * FROM V$LOCKED_OBJECT;

/*DBA_DDL_LOCKS – use this view to see what DDL locks are on objects with the schema or against the object you are interested in*/

   SELECT *
     FROM DBA_DDL_LOCKS
     WHERE NAME = <PAQUETE> AND MODE_HELD <> 'Null';

     /*V$ACCESS displays information about locks that are currently imposed on library cache objects. The locks are imposed to ensure that they are not aged out of the library cache while they are required for SQL execution.
     SID: Session number that is accessing an object
     OWNER: Owner of the object
     OBJECT: Name of the object
     TYPE: Type identifier for the object
          */

          SELECT *
     FROM V$ACCESS
     WHERE OBJECT = 'RE_UTIL';

     /*REVISION DE SESIONES BLOQUEADAS*/

     --BLOQUEO DE SESIONES

select blocking_session,sid,serial#,username,
machine,program,process
from v$session where sid=(select blocking_session
                          from v$session
                          where blocking_session_status='VALID');

/* V$SESSION_EVENT
This view lists information on waits for an event by a session. 
Note that the TIME_WAITED and AVERAGE_WAIT columns will contain a value
 of zero on those platforms that do not support a fast timing mechanism. 
 If you are running on one of these platforms and you want this column to reflect true wait times, 
 you must set TIMED_STATISTICS to true in the parameter file. 
 Please remember that doing this will have a small negative effect on system performance.
 
 TOTAL_WAITS Total number of waits for the event by the session
 TOTAL_TIMEOUTS Total number of timeouts for the event by the session
 TIME_WAITED Total amount of time waited for the event by the session (in hundredths of a second)*/

 SELECT *
     FROM V$SESSION_EVENT
     WHERE SID = <sid>
     ORDER BY TIME_WAITED DESC;
/*V$SESSION_WAIT displays the resources or events for which active sessions are waiting.
The following are tuning considerations:
P1RAW, P2RAW, and P3RAW display the same values as the P1, P2, and P3 columns,
 except that the numbers are displayed in hexadecimal.
The WAIT_TIME column contains a value of -2 on platforms that do not support a fast timing mechanism.
 If you are running on one of these platforms and you want this column to reflect true wait times,
  then you must set the TIMED_STATISTICS initialization parameter to true. 
  Remember that doing this has a small negative effect on system performance.
In previous releases, the WAIT_TIME column contained an arbitrarily large value instead of a negative value to 
indicate the platform did not have a fast timing mechanism.
The STATE column interprets the value of WAIT_TIME and describes the state of the current or most recent wait.

EVENT Resource or event for which the session is waiting (https://docs.oracle.com/cd/B19306_01/server.102/b14237/waitevents.htm#REFRN101)

 WAIT_TIME A nonzero value is the session's last wait time. A zero value means the session is currently waiting.
 
 SECONDS_IN_WAIT If WAIT_TIME = 0, then SECONDS_IN_WAIT is the seconds spent in the current wait condition.
  If WAIT_TIME > 0, then SECONDS_IN_WAIT is the seconds since the start of the last wait, 
  and SECONDS_IN_WAIT - WAIT_TIME / 100 is the active seconds since the last wait ended.
  
  STATE Wait state: 
0 - WAITING (the session is currently waiting)
-2 - WAITED UNKNOWN TIME (duration of last wait is unknown)
-1 - WAITED SHORT TIME (last wait <1/100th of a second)
>0 - WAITED KNOWN TIME (WAIT_TIME = duration of last wait)*/

     SELECT *
     FROM V$SESSION_WAIT
     WHERE SID = <sid>;


/* Basically, whilst someone or something else (a scheduled job perhaps?) is executing the package,
 then you won’t be able to perform the recompile.  To get around this, you need to identify the locking session and kill it.
Executing this script as SYS (or another user with the appropriate privileges) 
will prompt you for the package name and reveal the culprit(s):*/


BREAK ON sid ON lock_id1 ON kill_sid

COL sid            FOR 999999
COL lock_type      FOR A38
COL mode_held      FOR A12
COL mode_requested FOR A12
COL lock_id1       FOR A20
COL lock_id2       FOR A20
COL kill_sid       FOR A50

SELECT s.sid,
       l.lock_type,
       l.mode_held,
       l.mode_requested,
       l.lock_id1,
       'alter system kill session '''|| s.sid|| ','|| s.serial#|| ''' immediate;' kill_sid
FROM   dba_lock_internal l,
       v$session s
WHERE  s.sid = l.session_id
AND    UPPER(l.lock_id1) LIKE '%&package_name%'
AND    l.lock_type = 'Body Definition Lock'
/

/*Check out what the offending session is doing:
BREAK ON sid ON username ON osuser ON os_pid ON program*/

SELECT s.sid,
       NVL(s.username, 'ORACLE PROC') username,
       s.osuser,
       p.spid os_pid,
       s.program,
       t.sql_text
FROM   v$session s,
       v$sqltext t,
       v$process p
WHERE  s.sql_hash_value = t.hash_value
AND    s.paddr = p.addr
AND    s.sid = &session_id
AND    t.piece = 0 -- optional to list just the first line
ORDER BY s.sid, t.hash_value, t.piece
/



/*otro modo de obtener bloqueos activos*/

select  decode(lob.kglobtyp, 
        0, 'NEXT OBJECT ', 
        1, 'INDEX ', 
        2, 'TABLE ', 
        3, 'CLUSTER ', 
        4, 'VIEW ', 
        5, 'SYNONYM ', 
        6, 'SEQUENCE ', 
        7, 'PROCEDURE ', 
        8, 'FUNCTION ', 
        9, 'PACKAGE ', 
        11, 'PACKAGE BODY ', 
        12, 'TRIGGER ', 
        13, 'TYPE ', 
        14, 'TYPE BODY ', 
        19, 'TABLE PARTITION ', 
        20, 'INDEX PARTITION ', 
        21, 'LOB ', 
        22, 'LIBRARY ', 
        23, 'DIRECTORY ', 
        24, 'QUEUE ', 
        28, 'JAVA SOURCE ', 
        29, 'JAVA CLASS ', 
        30, 'JAVA RESOURCE ', 
        32, 'INDEXTYPE ', 
        33, 'OPERATOR ', 
        34, 'TABLE SUBPARTITION ', 
        35, 'INDEX SUBPARTITION ', 
        40, 'LOB PARTITION ', 
        41, 'LOB SUBPARTITION ', 
        42, 'MATERIALIZED VIEW ', 
        43, 'DIMENSION ', 
        44, 'CONTEXT ', 
        46, 'RULE SET ', 
        47, 'RESOURCE PLAN ', 
        48, 'CONSUMER GROUP ', 
        51, 'SUBSCRIPTION ', 
        52, 'LOCATION ', 
        55, 'XML SCHEMA ', 
        56, 'JAVA DATA ', 
        57, 'SECURITY PROFILE ', 
        59, 'RULE ', 
        62, 'EVALUATION CONTEXT ', 
        'UNDEFINED ') object_type, 
        lob.kglnaobj object_name, 
        pn.kglpnmod lock_mode_held, 
        pn.kglpnreq lock_mode_requested, 
        ses.sid, 
        ses.serial#, 
        ses.username 
from    sys.v$session_wait vsw, 
        sys.x$kglob lob, 
        sys.x$kglpn pn, 
        sys.v$session ses 
where   vsw.event = 'library cache lock ' 
and     vsw.p1raw = lob.kglhdadr 
and     lob.kglhdadr = pn.kglpnhdl 
and     pn.kglpnmod != 0 
and     pn.kglpnuse = ses.saddr 
/
ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
export ORACLE_HOME
ORACLE_SID=rec
export ORACLE_SID
PATH=$ORACLE_HOME/bin:$PATH
export PATH

dumpfile=`date +"Backup_rec_prod_%Y%m%d"`
echo $dumpfile
expdp parfile=/home/oracle/scripts/.parfile directory=EXPDP_DIR dumpfile=$dumpfile.dmp logfile=$dumpfile.log  full=y
#!/bin/sh

RMAN_LOG_FILE=/home/oracle/log_respaldos/backup_fra_0_$(date +%Y%m%d).log

# Log the start of this script.

echo Script ==== started on `date` ==== >> $RMAN_LOG_FILE

# rman commands for database

ORACLE_HOME=/u01/app/oracle/product/12.2.0/db_1
export ORACLE_HOME
ORACLE_SID=rec01
export ORACLE_SID
RMAN=$ORACLE_HOME/bin/rman

$RMAN target / nocatalog msglog $RMAN_LOG_FILE append <<EOF

# RMAN run block
#allocate channel for maintenance type disk;

RUN {
allocate channel ch00 device type disk;
backup incremental level 0 database format '/u03/fra/backup/Full0_%U' plus archivelog format '/u03/fra/backup/Arc0_%U' delete input;
}
RELEASE CHANNEL ch00;
allocate channel for maintenance device type disk;
crosscheck backup;
delete noprompt obsolete device type disk;
EXIT;
EOF

### Borra los log anteriores a 60 dias
find /home/oracle/log_respaldos/backup_* -mtime +60 -exec rm {} \;

echo ==== Script finalizado `date` ==== >> $RMAN_LOG_FILE


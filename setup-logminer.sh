#!/bin/sh

# Set archive log mode and enable GG replication
ORACLE_SID=ORCLCDB
export ORACLE_SID
sqlplus /nolog <<- EOF
	CONNECT sys/top_secret AS SYSDBA
	alter system set db_recovery_file_dest_size = 10G;
	alter system set db_recovery_file_dest = '/opt/oracle/oradata/recovery_area' scope=spfile;
	shutdown immediate
	startup mount
	alter database archivelog;
	alter database open;
        -- Should show "Database log mode: Archive Mode"
	archive log list
	exit;
EOF

# Enable LogMiner required database features/settings
sqlplus sys/top_secret@//localhost:1521/ORCLCDB as sysdba <<- EOF
  ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
  ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED;
  exit;
EOF

# Create Log Miner Tablespace and User
sqlplus sys/top_secret@//localhost:1521/ORCLCDB as sysdba <<- EOF
  CREATE TABLESPACE LOGMINER_TBS DATAFILE '/opt/oracle/oradata/ORCLCDB/logminer_tbs.dbf' SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
  exit;
EOF

sqlplus sys/top_secret@//localhost:1521/ORCLPDB1 as sysdba <<- EOF
  CREATE TABLESPACE LOGMINER_TBS DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB1/logminer_tbs.dbf' SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
  exit;
EOF

sqlplus sys/top_secret@//localhost:1521/ORCLCDB as sysdba <<- EOF
  CREATE USER debezium IDENTIFIED BY dbz DEFAULT TABLESPACE LOGMINER_TBS QUOTA UNLIMITED ON LOGMINER_TBS CONTAINER=ALL;

  GRANT CREATE SESSION TO debezium CONTAINER=ALL;
  GRANT SET CONTAINER TO debezium CONTAINER=ALL;
  GRANT SELECT ON V_\$DATABASE TO debezium CONTAINER=ALL;
  GRANT FLASHBACK ANY TABLE TO debezium CONTAINER=ALL;
  GRANT SELECT ANY TABLE TO debezium CONTAINER=ALL;
  GRANT SELECT_CATALOG_ROLE TO debezium CONTAINER=ALL;
  GRANT EXECUTE_CATALOG_ROLE TO debezium CONTAINER=ALL;
  GRANT SELECT ANY TRANSACTION TO debezium CONTAINER=ALL;
  GRANT SELECT ANY DICTIONARY TO debezium CONTAINER=ALL;
  GRANT LOGMINING TO debezium CONTAINER=ALL;

  GRANT CREATE TABLE TO debezium CONTAINER=ALL;
  GRANT ALTER ANY TABLE TO debezium CONTAINER=ALL;
  GRANT LOCK ANY TABLE TO debezium CONTAINER=ALL;
  GRANT CREATE SEQUENCE TO debezium CONTAINER=ALL;

  GRANT EXECUTE ON DBMS_LOGMNR TO debezium CONTAINER=ALL;
  GRANT EXECUTE ON DBMS_LOGMNR_D TO debezium CONTAINER=ALL;
  GRANT SELECT ON V_\$LOGMNR_LOGS TO debezium CONTAINER=ALL;
  GRANT SELECT ON V_\$LOGMNR_CONTENTS TO debezium CONTAINER=ALL;
  GRANT SELECT ON V_\$LOGFILE TO debezium CONTAINER=ALL;
  GRANT SELECT ON V_\$ARCHIVED_LOG TO debezium CONTAINER=ALL;
  GRANT SELECT ON V_\$ARCHIVE_DEST_STATUS TO debezium CONTAINER=ALL;

  exit;
EOF

sqlplus sys/top_secret@//localhost:1521/ORCLPDB1 as sysdba <<- EOF
  CREATE USER debezium IDENTIFIED BY dbz;
  GRANT CONNECT TO debezium;
  GRANT CREATE SESSION TO debezium;
  GRANT CREATE TABLE TO debezium;
  GRANT CREATE SEQUENCE to debezium;
  ALTER USER debezium QUOTA 100M on users;
  exit;
EOF
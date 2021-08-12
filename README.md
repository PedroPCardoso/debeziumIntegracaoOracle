# debezium-oracle
Repository to post images erros when trying to configure debezium


https://www.youtube.com/watch?v=mzho5QS6CSk  -- Configurando banco

docker run --name oracledb19 -p 1521:1521 --network tutorial_oracle_kafka  -e ORACLE_PWD=top_secret oracle/database:19.3.0-se2

docker exec -ti oracledb19 bash
cd /opt/oracle/oradata/
ls -la
mkdir -p recovery_area
curl https://raw.githubusercontent.com/debezium/oracle-vagrant-box/master/setup-logminer.sh | sh

curl  https://raw.githubusercontent.com/debezium/debezium-examples/master/tutorial/debezium-with-oracle-jdbc/init/inventory.sql | sqlplus debezium/dbz@//localhost:1521/ORCLPDB1

curl https://raw.githubusercontent.com/PedroPCardoso/debeziumIntegracaoOracle/main/newInventory.sql | sqlplus debezium/dbz@//localhost:1521/ORCLPDB1


export DEBEZIUM_VERSION=1.5
docker-compose -f docker-compose-oracle.yaml up --build

curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @iw.json

curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @register-oracle-local.json

echo "INSERT INTO customers VALUES (NULL, 'John', 'Doe', 'john.doe@example.com');" | docker exec -i oracledb19 sqlplus debezium/dbz@//localhost:1521/ORCLPDB1


c##dbzuser

ORCLCDB


GRANT CONNECT, RESOURCE, DBA TO  c##dbzuser;
sqlplus sys/top_secret@//localhost:1521/ORCLPDB1 as sysdba;
curl  https://raw.githubusercontent.com/debezium/debezium-examples/master/tutorial/debezium-with-oracle-jdbc/init/inventory.sql | sqlplus c##dbzuser/dbz@//localhost:1521/ORCLPDB1

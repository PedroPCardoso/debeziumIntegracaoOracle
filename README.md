   
   # Integracao Kafka Oracle
## rodando o Ambiente kafka
Dentro da pasta tutorial:
- cd tutorial
- export DEBEZIUM_VERSION=1.6 
- docker-compose -f docker-compose-oracle.yaml up --build 


## Rodar o banco na mesma rede
tutorial_oracle_kafka no caso atual:

docker run --name oracledb19 -p 1521:1521 --network tutorial_oracle_kafka  -e ORACLE_PWD=top_secret oracle/database:19.3.0-se2

 ##### Demora um pouco a criação do seu banco, mas após a conclusão, você deverá abrir outro terminal e rodar os seguintes comandos::


- docker exec -ti oracledb19 bash
 
- cd /opt/oracle/oradata/
 
- ls -la
 
- mkdir -p recovery_area
 
- curl https://raw.githubusercontent.com/debezium/oracle-vagrant-box/master/setup-logminer.sh | sh
 

 - curl  https://raw.githubusercontent.com/debezium/debezium-examples/master/tutorial/debezium-with-oracle-jdbc/init/inventory.sql | sqlplus debezium/dbz@//localhost:1521/ORCLPDB1
 
## Conectando o banco no kafka

 - docker network ls 
 
se tudo estiver ok, você vera a rede tutorial_oracle_kafka
 - docker network inspect tutorial_oracle_kafka 
 
 Encontre o IP da sua maquina oracle, e substitua no arquivo register-oracle-local.json

 Agora você já pode conectar:

- curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @register-oracle-local.json




Adicionando um novo elemento:

- echo "INSERT INTO customers VALUES (NULL, 'John', 'Doe', 'john.doe@example.com');" | docker exec -i oracledb19 sqlplus debezium/dbz@//localhost:1521/ORCLPDB1

#!/bin/sh
NEO4J_HOME=/var/lib/neo4j
CONF=${NEO4J_HOME}/conf/neo4j.conf
DATA_DIR="/csv"

if [ ! -d $DATA_DIR ]; then
    mkdir $DATA_DIR

    /parse_leaks.sh bahamas_leaks $DATA_DIR
    /parse_leaks.sh offshore_leaks $DATA_DIR
    /parse_leaks.sh panama_papers $DATA_DIR
    /parse_leaks.sh paradise_papers $DATA_DIR

    /load_db.sh $DATA_DIR $NEO4J_HOME

    cd $NEO4J_HOME

    echo 'dbms.security.procedures.unrestricted=apoc.*,algo.*' >> $CONF
    echo 'dbms.security.auth_enabled=false' >> $CONF
    echo 'browser.remote_content_hostname_whitelist=*' >> $CONF

    cp -R plugins ./data/databases/graph.db/
    ./bin/neo4j-shell -path ./data/databases/graph.db -config ./conf/neo4j.conf -file /configure.cql
fi

cd $NEO4J_HOME
./bin/neo4j-shell -path ./data/databases/graph.db -config ./conf/neo4j.conf
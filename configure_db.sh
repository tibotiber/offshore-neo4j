#!/bin/sh
NEO4J_HOME=/var/lib/neo4j
CONF=${NEO4J_HOME}/conf/neo4j.conf

# /download_db.sh bahamas_leaks
# /download_db.sh offshore_leaks
# /download_db.sh panama_papers
/download_db.sh paradise_papers

cd $NEO4J_HOME

echo 'dbms.security.procedures.unrestricted=apoc.*,algo.*' >> $CONF
echo 'dbms.security.auth_enabled=false' >> $CONF
echo 'browser.remote_content_hostname_whitelist=*' >> $CONF

cp -R plugins ./data/databases/graph.db/
./bin/neo4j-shell -path ./data/databases/graph.db -config ./conf/neo4j.conf -file /configure.cql
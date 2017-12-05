#!/bin/sh
DATA_DIR=$1
NEO4J_HOME=$2

cd $DATA_DIR

for i in ${DATA_DIR}/*.csv
do
    echo "removing "n." in file: $i"
    sed -i -e '1,1 s/n\.//g' $i
done

for i in ${DATA_DIR}/*.csv
do
    echo "adding ID to node_id property in file: $i"
    sed -i -e '1,1 s/node_id/node_id:ID/g' $i
done

sed -i -e '1,1 s/node_1,rel_type,node_2/node_id:START_ID,rel_type:TYPE,node_id:END_ID/' ${DATA_DIR}/edges.csv

grep -q 'rel_type' $DATA_DIR/edges.csv && sed -i -e '1 d' ${DATA_DIR}/edges.csv
tr '[:lower:]' '[:upper:]' < ${DATA_DIR}/edges.csv | sed  -e 's/[^A-Z0-9,_ ]//g' -e 's/  */_/g' -e 's/,_/_/g' > ${DATA_DIR}/edges_cleaned.csv

echo 'node_id:START_ID,rel_type:TYPE,node_id:END_ID,sourceID,valid_until,start_date,end_date' > ${DATA_DIR}/all_edges_header.csv

$NEO4J_HOME/bin/neo4j-import --into ${NEO4J_HOME}/data/databases/graph.db \
  --nodes:Address ${DATA_DIR}/nodes.address.csv \
  --nodes:Entity ${DATA_DIR}/nodes.entity.csv \
  --nodes:Other ${DATA_DIR}/nodes.intermediary.csv \
  --nodes:Intermediary ${DATA_DIR}/nodes.other.csv \
  --nodes:Officer ${DATA_DIR}/nodes.officer.csv \
  --relationships ${DATA_DIR}/all_edges_header.csv,${DATA_DIR}/edges_cleaned.csv \
  --ignore-empty-strings true \
  --skip-duplicate-nodes true \
  --skip-bad-relationships true \
  --bad-tolerance  1500 \
  --multiline-fields=true

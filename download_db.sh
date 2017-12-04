#!/bin/sh
LEAK=$1
NEO4J_HOME=/var/lib/neo4j
DATA_FILE="csv_$LEAK.2017-11-17.zip"
DATA_DIR="/csv"

mkdir $DATA_DIR
cd $DATA_DIR

mkdir $LEAK
cd $LEAK

if [ ! -f "./$DATA_FILE" ]; then
  echo "Downloading data ($LEAK)"
  wget "https://offshoreleaks-data.icij.org/offshoreleaks/csv/$DATA_FILE"
else
  echo "Not downloading data ($LEAK) as file already exists"
fi

if [ ! -f "./$LEAK.edges.csv" ]; then
  unzip "$DATA_FILE"
fi

for i in ${DATA_DIR}/${LEAK}/*.csv
do
    echo "removing "n." in file: $i"
    sed -i -e '1,1 s/n\.//g' $i
done

for i in ${DATA_DIR}/${LEAK}/*.csv
do
    echo "adding ID to node_id property in file: $i"
    sed -i -e '1,1 s/node_id/node_id:ID/g' $i
done

sed -i -e '1,1 s/node_1,rel_type,node_2/node_id:START_ID,rel_type:TYPE,node_id:END_ID/' ${DATA_DIR}/${LEAK}/$LEAK.edges.csv

grep -q 'rel_type' $DATA_DIR/$LEAK/$LEAK.edges.csv && sed -i -e '1 d' ${DATA_DIR}/${LEAK}/$LEAK.edges.csv
tr '[:lower:]' '[:upper:]' < ${DATA_DIR}/${LEAK}/$LEAK.edges.csv | sed  -e 's/[^A-Z0-9,_ ]//g' -e 's/  */_/g' -e 's/,_/_/g' > ${DATA_DIR}/${LEAK}/$LEAK.edges_cleaned.csv

echo 'node_id:START_ID,rel_type:TYPE,node_id:END_ID,sourceID,valid_until,start_date,end_date' > ${DATA_DIR}/${LEAK}/all_edges_header.csv

$NEO4J_HOME/bin/neo4j-import --into ${NEO4J_HOME}/data/databases/graph.db \
  --nodes:Address ${DATA_DIR}/${LEAK}/$LEAK.nodes.address.csv \
  --nodes:Entity ${DATA_DIR}/${LEAK}/$LEAK.nodes.entity.csv \
  --nodes:Other ${DATA_DIR}/${LEAK}/$LEAK.nodes.intermediary.csv \
  --nodes:Intermediary ${DATA_DIR}/${LEAK}/$LEAK.nodes.other.csv \
  --nodes:Officer ${DATA_DIR}/${LEAK}/$LEAK.nodes.officer.csv \
  --relationships ${DATA_DIR}/${LEAK}/all_edges_header.csv,${DATA_DIR}/${LEAK}/$LEAK.edges_cleaned.csv \
  --ignore-empty-strings true \
  --skip-duplicate-nodes true \
  --skip-bad-relationships true \
  --bad-tolerance  1500 \
  --multiline-fields=true

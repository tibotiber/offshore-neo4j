#!/bin/sh
LEAK=$1
DATA_DIR=$2
LEAKS_DIR="/icij_leaks"
LEAKS_FILE="csv_$LEAK.2017-11-17.zip"

# unzip leak and move to data dir
cd $LEAKS_DIR
if [ ! -f "./$LEAK.edges.csv" ]; then
    unzip "$LEAKS_FILE"
    mkdir $DATA_DIR/$LEAK
    mv *.csv $DATA_DIR/$LEAK
fi

# merge leak into csv file for import to neo4j
for i in ${DATA_DIR}/${LEAK}/*.csv
do
    cat $i >> $(echo $i | sed -e "s/\(.*\)\/\([a-z_]*\)\/\([a-z_]*\).\(.*\)$/\1\/\4/")
done
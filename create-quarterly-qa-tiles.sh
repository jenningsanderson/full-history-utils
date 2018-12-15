if [ $# -lt 2 ]; 
    then 
    echo "Not enough arguments, Usage:" 
    echo ""
    echo "    $ create-quarterly-qa-tiles.sh [YEAR-QUARTER] [TIMESTRING]"
    echo "    TIMESTRING FORMAT: 2010-04-01T00:00:00Z"
    exit 0 
fi 

echo "First step: cut the right time"
mason_packages/.link/bin/osmium time-filter --verbose --overwrite -o $1.osm.pbf history-latest.osm.pbf $2

echo "Step 2: osmium export that right into tippecanoe :)"
mason_packages/.link/bin/osmium export -c osmiumconfig --overwrite -f geojsonseq -r -o - --verbose $1.osm.pbf | mason_packages/.link/bin/tippecanoe -l osm -n $1 -o $1-qa-tiles.mbtiles -f -z12 -Z12 -ps -pf -pk -P -b0 -d20 --no-tile-stats --no-duplication

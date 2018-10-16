#!/bin/bash
echo ""
echo "Running Complete Workflow for history file:"
echo "--Input history file: $1"
echo "--Base file name:     $2"
echo ""

echo "Prep Step 0.5: Throw out coastlines and administrative boundaries"
mason_packages/.link/bin/osmium tags-filter -v --overwrite --invert-match -e filter_tags --omit-referenced -o $2_filtered.osh.pbf $1

echo "Deleting $1"
rm $1

echo "Preparation Step 1: osmium time-filter"
mason_packages/.link/bin/osmium time-filter --overwrite -v -o $2_filtered.osm.pbf $2_filtered.osh.pbf

echo "Preparation Step 2: osmium export"
mason_packages/.link/bin/osmium export --verbose -c osmiumconfig -f geojsonseq $2_filtered.osm.pbf > $2.geojsonseq

echo "Deleting $2_filtered.osm.pbf"
rm $2_filtered.osm.pbf

echo ""
echo "Now beginning OSM-Wayback"
echo "-------------------------"
echo "Commands that excecute are denoted with (*)"
echo ""
echo "==================================================="
echo "|| Step 1: Create Lookup Index from history file ||"
echo "==================================================="
echo ""
 echo "* ~/osm-wayback/build_lookup_index $2_INDEX $2_filtered.osh.pbf"
time ~/osm-wayback/build/build_lookup_index $2_INDEX $2_filtered.osh.pbf

echo "Deleting $2_filtered.osh.pbf"
rm $2_filtered.osh.pbf

echo""
echo "=============================================="
echo "|| Step 2: Feed GeoJSONSeq into add_history ||"
echo "=============================================="
echo ""
echo "* cat $2.geojsonseq | ~/osm-wayback/build/add_history $2_INDEX > $2.history"
time cat $2.geojsonseq | ~/osm-wayback/build/add_history $2_INDEX > $2.history

echo "Deleting $2.geojsonseq"
rm $2.geojsonseq

echo ""
echo "================================================"
echo "|| Step 3: Enrich history file with locations ||"
echo "================================================"
echo ""
echo "* cat $2.history | ~/osm-wayback/build/add_geometry $2_INDEX > $2.history.geometries"
time cat $2.history | ~/osm-wayback/build/add_geometry $2_INDEX > $2.history.geometries

echo "Deleting RocksDB Index:  $2_INDEX"
rm -r $2_INDEX

echo "Deleting $2.history"
rm  $2.history

echo ""
echo "======================================================="
echo "|| Step 4: Create TopoJSON Histories from Geometries ||"
echo "======================================================="
echo ""
echo "* node ~/osm-wayback/geometry-reconstruction/index.js $2.history.geometries > $2_historical_geometries_topojson.geojsonseq"
time node ~/osm-wayback/geometry-reconstruction/index.js $2.history.geometries > $2_historical_geometries_topojson.geojsonseq

echo "Copying geometry file to S3"
aws --profile=epic s3 cp $2.history.geometries s3://openstreetmap-analysis/
echo "Deleting $2.history.geometries"
rm $2.history.geometries

echo ""
echo "==============================================="
echo "|| Step 5: Run geojsonseq through tippecanoe ||"
echo "==============================================="
echo ""
echo "* ~/osm-wayback/mason_packages/.link/bin/tippecanoe -Pf -pf -pk -ps -Z15 -z15 --no-tile-stats --no-duplication -o $2_historical.mbtiles -l historical_topojson $2_historical_geometries_topojson.geojsonseq"
time ~/osm-wayback/mason_packages/.link/bin/tippecanoe -Pf -pf -pk -ps -Z15 -z15 --no-tile-stats --no-duplication -o $2_historical.mbtiles -l historical_topojson $2_historical_geometries_topojson.geojsonseq

echo "Deleting $2_historical_geometries_topojson.geojsonseq"
rm $2_historical_geometries_topojson.geojsonseq

echo "Copying historical tiles to S3"
aws --profile=epic s3 cp $2_historical.mbtiles s3://openstreetmap-analysis/$2_historical.mbtiles

echo "Deleting mbtiles for safety"
rm $2_historical.mbtiles
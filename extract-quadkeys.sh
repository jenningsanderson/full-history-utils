echo "Running quadkey extracts"
mkdir QUAD_EXTRACTS
cd QUAD_EXTRACTS
../mason_packages/.link/bin/osmium extract --overwrite --verbose --with-history --set-bounds --config=../quadkey_extract_config.json ../history-latest.osm.pbf

// copy cities.json (GeoJSON) from https://github.com/interline-io/osm-extracts/blob/master/cities.json
const cities = require("./cities.json");

const extracts = cities.features.map(city => {
  const {
    geometry: { coordinates: polygon },
    properties: { id, name }
  } = city;

  return {
    output: `${id}.osh.pbf`,
    description: name,
    polygon
  };
});

const config = {
  extracts
};

process.stdout.write(JSON.stringify(config));

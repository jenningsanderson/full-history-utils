// copy cities.json (GeoJSON) from https://github.com/interline-io/osm-extracts/blob/master/cities.json
const cities = require("../us-cities.json");

const extracts = cities.features.map(city => {
  const {
    geometry: { coordinates: polygon },
    properties: { id, name }
  } = city;
       
  var bbox = [polygon[0][0][0],polygon[0][0][1],polygon[0][2][0],polygon[0][2][1]]

  return {
    output: `${id}.osh.pbf`,
    description: name,
    bbox: bbox
  };
});

const config = {
  extracts
};

process.stdout.write(JSON.stringify(config,null,2));

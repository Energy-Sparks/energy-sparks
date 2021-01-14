$(function () {
  if ($('div#geo-json-map').length) {
    fireRequestForJson();
  }
});

function fireRequestForJson() {

  // Add AJAX request for data
  var features = $.ajax({
    url: '/map.json',
    dataType: "json",
    success: console.log("Locations loaded."),
    error: function(xhr) {
      alert(xhr.statusText)
    }
  })

  function onEachFeature(feature, layer) {
    console.log(feature.properties.key);
    if (feature.properties && feature.properties.schoolName) {
      layer.bindPopup(feature.properties.schoolName);
    }
  }

  $.when(features).done(function() {
    var map = L.map('geo-json-map').setView([54.303790, -2.194200], 6);

    var CartoDB_Positron = L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
      subdomains: 'abcd',
      maxZoom: 19
    }).addTo(map);

    // Add requested external GeoJSON to map
    L.geoJSON(features.responseJSON, {
      onEachFeature: onEachFeature,
      pointToLayer: function (feature, latlng) {
        return L.marker(latlng);
      }
    }).addTo(map);
  });
}

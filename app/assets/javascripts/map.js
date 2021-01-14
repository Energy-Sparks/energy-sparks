$(function () {
  if ($('div#geo-json-map').length) {
    fireRequestForJson();
  }
});

function fireRequestForJson() {

  // Add AJAX request for data
  var features = $.ajax({
    url: '/maps.json',
    dataType: "json",
    success: console.log("Locations loaded."),
    error: function(xhr) {
      alert(xhr.statusText);
    }
  });

  function onEachFeature(feature, layer) {
    if (feature.properties && feature.properties.schoolName) {
      layer.bindPopup(popupHtml(feature.properties));
    }
  }

  function popupHtml(props) {
    var str = "";
    str += "<a href='" + props.schoolPath + "'>" + props.schoolName + "</a>";
    str += "<hr/>";
    str += "<p>School type: " + props.schoolType + "</p>";
    str += "<p>Fuel types: ";
    if (props.has_electricity) {
      str += "&nbsp;<i class='fas fa-bolt'></i>";
    }
    if (props.has_gas) {
      str += "&nbsp;<i class='fas fa-fire'></i>";
    }
    if (props.has_solar_pv) {
      str += "&nbsp;<i class='fas fa-sun'></i>";
    }
    str += "</p>";
    str += "<p>Pupils: " + props.number_of_pupils + "</p>";
    return str;
  }

  $.when(features).done(function() {
    var map = L.map('geo-json-map').setView([54.9, -2.194200], 6);

    L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
      subdomains: 'abcd',
      maxZoom: 19
    }).addTo(map);

    // L.tileLayer('https://{s}.tile.openstreetmap.fr/{z}/{x}/{y}.png', {
    //   attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    // }).addTo(map);

    // L.tileLayer('https://tiles.stadiamaps.com/tiles/outdoors/{z}/{x}/{y}{r}.png', {
    //   maxZoom: 20,
    //   attribution: '&copy; <a href="https://stadiamaps.com/">Stadia Maps</a>, &copy; <a href="https://openmaptiles.org/">OpenMapTiles</a> &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors'
    // }).addTo(map);

    // Add requested external GeoJSON to map
    L.geoJSON(features.responseJSON, {
      onEachFeature: onEachFeature,
      pointToLayer: function (feature, latlng) {
        return L.marker(latlng);
      }
    }).addTo(map);
  });
}

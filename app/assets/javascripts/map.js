$(function () {
  if ($('div#geo-json-map').length) {
    fireRequestForJson();
  }
});

function fireRequestForJson() {

  var dataUrl = '/map.json';

  var mapDiv = document.querySelector('div#geo-json-map');
  var schoolGroupId = mapDiv.dataset.schoolGroupId;

  var dataParams = {};
  if (schoolGroupId) {
    dataParams.school_group_id = schoolGroupId;
  }

  // Add AJAX request for data
  var features = $.ajax({
    url: dataUrl,
    data: dataParams,
    dataType: "json",
    success: console.log("Locations loaded."),
    error: function(xhr) {
      alert(xhr.statusText);
    }
  });

  function onEachFeature(feature, layer) {
    layer.bindPopup(popupHtml(feature.properties));
  }

  function popupHtml(props) {
    var str = "";
    str += "<a href='" + props.schoolPath + "'>" + props.schoolName + "</a>";
    str += "<br/>";
    str += "<p>School type: " + props.schoolType + "</p>";
    str += "<p>Fuel types: ";
    if (props.hasElectricity) {
      str += "&nbsp;<i class='fas fa-bolt'></i>";
    }
    if (props.hasGas) {
      str += "&nbsp;<i class='fas fa-fire'></i>";
    }
    if (props.hasSolarPv) {
      str += "&nbsp;<i class='fas fa-sun'></i>";
    }
    str += "</p>";
    str += "<p>Pupils: " + props.numberOfPupils + "</p>";
    return str;
  }

  function makeMap() {

    // approx centre of full UK map
    var center = [54.9, -2.1942];

    // approx area for full UK map
    var maxBounds = [[61, 3], [49, -10]];

    var minZoom = 6;
    var maxZoom = 16;
    var zoom = minZoom;

    // Initialize the map.
    var mapOptions = {
      center: center,
      zoom: zoom,
      minZoom: minZoom,
      maxZoom: maxZoom,
    };

    // Stadia Outdoors
    var serviceUrl = 'https://tiles.stadiamaps.com/tiles/outdoors/{z}/{x}/{y}{r}.png';
    var attribution = '&copy; <a href="https://stadiamaps.com/">Stadia Maps</a>, &copy; <a href="https://openmaptiles.org/">OpenMapTiles</a> &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors';
    var subdomains = '';

    // Initialize the map.
    var tileOptions = {
      attribution: attribution,
      subdomains: subdomains
    };

    // make the map
    var map = L.map('geo-json-map', mapOptions);
    L.tileLayer(serviceUrl, tileOptions).addTo(map);

    // bound the map from scrolling away from UK
    map.setMaxBounds(maxBounds);

    return map;
  }

  $.when(features).done(function() {

    // Add requested external GeoJSON to map
    var markers = L.geoJSON(features.responseJSON, {
      onEachFeature: onEachFeature,
      pointToLayer: function (feature, latlng) {
        return L.marker(latlng);
      }
    });

    // apply clustering
    var clusters = L.markerClusterGroup({
      maxClusterRadius: function(zoom) {
        return (zoom > 7 ? 0 : 20);
      }
    });
    clusters.addLayers(markers);

    var map = makeMap();
    map.addLayer(clusters);

    // bound the map to the markers, if present
    if (markers.getBounds().isValid()) {
      map.fitBounds(markers.getBounds(), {padding: [20,20]});
    }
  });
}

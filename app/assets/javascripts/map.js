$(function () {
  var mapDiv = $('div#geo-json-map');
  if (mapDiv.length) {
    fireRequestForJson(mapDiv);
  }
});

function fireRequestForJson(mapDiv) {

  var dataUrl = '/map.json';
  var schoolGroupId = mapDiv.data('schoolGroupId');

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
    // dynamically load the popup content when clicked
    layer.bindPopup(function(target) {
      const popup = target.getPopup();
      fetch('/map/popup?id=' + feature.id).then(response => response.text()).then(
          function(html) {
            popup.setContent(html);
          }
      );
      return 'Loading';
    });
  }

  function makeMap() {
    // approx centre of full UK map
    var center = [54.90, -3.4936];

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
      tap: false
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

  var map = makeMap();

  $.when(features).done(function() {
    // Add requested external GeoJSON to map
    var markers = L.geoJSON(features.responseJSON, {
      onEachFeature: onEachFeature
    });

    // apply clustering
    var clusters = L.markerClusterGroup({
      chunkedLoading: true,
      maxClusterRadius: function(zoom) {
        if (zoom > 12)
          return 0;
        else if (zoom > 9) {
          return 30;
        }
        else {
          return 40;
        }
      }
    });
    clusters.addLayers(markers);
    map.addLayer(clusters);
  });
}

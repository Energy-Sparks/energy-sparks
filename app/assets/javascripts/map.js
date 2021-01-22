$(function () {
  if ($('div#geo-json-map').length) {
    fireRequestForJson();
  }
});

function fireRequestForJson() {

  var dataUrl = '/map.json';

  var dataParams = {};
  if (gon.school_group_id) {
    dataParams.school_group_id = gon.school_group_id;
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
    if (feature.properties && feature.properties.schoolName) {
      layer.bindPopup(popupHtml(feature.properties));
    }
  }

  function popupHtml(props) {
    var str = "";
    str += "<a href='" + props.schoolPath + "'>" + props.schoolName + "</a>";
    str += "<br/>";
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


//
// OTHER MAP SERVICES
//

// OS
// var center = [54.9, -4.5];
// var api_key = gon.global.OSDATAHUB_API_KEY;
// var serviceUrl = 'https://api.os.uk/maps/raster/v1/zxy/Light_3857/{z}/{x}/{y}.png?key=' + api_key;
// var attribution = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>';
// var subdomains = '';

// Google
// var serviceUrl = 'http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}&language=en-GB';
// var attribution = '&copy; <a href="https://www.google.com">Google Maps</a> &copy; 2021</a>';
// var subdomains = ['mt0','mt1','mt2','mt3'];

// Mapbox
// var api_key = gon.global.MAPBOX_API_KEY;
// var serviceUrl = 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=' + api_key;
// // var serviceUrl = 'https://api.mapbox.com/styles/v1/mapbox/light-v10/tiles/{z}/{x}/{y}?access_token=' + api_key;
// var attribution = '© <a href="https://www.mapbox.com/feedback/">Mapbox</a> © <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>';
// var subdomains = '';

// Carto Light All
// var serviceUrl = 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
// var attribution = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>';
// var subdomains = 'abcd';

// Carto Voyager
// var serviceUrl = 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
// var attribution = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>';
// var subdomains = 'abcd';

// OpenStreetMap
// var serviceUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
// var attribution = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors';
// var subdomains = '';

// other Stadia
// var serviceUrl = 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png';



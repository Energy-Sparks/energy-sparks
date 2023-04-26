// Loads the correct tab given a url with a hash to the tab
// Changes the url hash when a new tab is selected
// Give a class of url-aware to nav-tabs container for this to work

$(document).ready(function() {
  if (location.hash) {
    $(".url-aware a[href='" + location.hash + "']").tab("show");
  }
  $(document.body).on("click", ".url-aware a[data-toggle='tab']", function(event) {
    location.hash = this.getAttribute("href");
  });
});

$(window).on("popstate", function() {
    var anchor = location.hash || $(".url-aware a[data-toggle='tab']").first().attr("href");
    $(".url-aware a[href='" + anchor + "']").tab("show");
});

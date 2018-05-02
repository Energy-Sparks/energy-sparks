$(document).on('turbolinks:load', function() {
  if (document.location.hash) {
    $(`.nav-tabs a[href="${document.location.hash}"]`).tab('show');
  }
});

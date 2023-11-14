$(function() {

  // Change the link's icon while the request is performing
  $(document).on('click', 'a.check-button[data-remote]', function(event, b, c) {
    var icon = $(this).find('i');
    icon.data('old-class', icon.attr('class'));
    icon.attr('class', 'fas fa-spinner fa-spin');
  });

  if ($("a.check-button[data-remote]").length) {
    // Change the link's icon back after it's finished.
    $(document).on('ajax:complete', function(e) {
      var icon = $(e.target).find('i');
      if (icon.data('old-class')) {
        icon.attr('class', icon.data('old-class'));
        icon.data('old-class', null);
      }
    })
  }

})

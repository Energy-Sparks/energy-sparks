"use strict"

$(document).ready(function() {
  if ($(".multi-select").length) {
    $(".multi-select").click(function(event) {
      var groupId = event.target.id;
      var checked = $(event.target).prop('checked');
      var toCheck = $("." + groupId + "_group");

      toCheck.prop('checked', checked);
    });
  }
});

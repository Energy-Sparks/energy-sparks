"use strict"

$(document).ready(function() {
  $("body").on("change", ".user-update", function(ev) {
    $(this.form).submit();
  })
});

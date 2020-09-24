"use strict"

function setupSchoolGroupAndClusterControls() {
  $(".user_school_group_id").hide();
  $(".user_cluster_schools").hide();
  switch($("#user_role option:selected").val()) {
    case 'group_admin':
      $(".user_school_group_id").show();
      break;
    case 'school_admin':
      $(".user_cluster_schools").show();
      break;
  }
}

$(document).ready(function() {
  $("body").on("change", ".user-update", function(ev) {
    $(this.form).submit();
  });
  $("body").on("change", "#user_role", function(ev) {
    setupSchoolGroupAndClusterControls();
  });
  setupSchoolGroupAndClusterControls();
});

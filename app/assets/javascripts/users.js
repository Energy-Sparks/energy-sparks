"use strict"

function setupSchoolGroupAndClusterControls() {
  $(".user_school_group_id").hide();
  $(".user_cluster_schools").hide();
  $(".user_staff_role_id").hide();
  switch($("#user_role option:selected").val()) {
    case 'staff':
      $(".user_staff_role_id").show();
      break;
    case 'school_admin':
      $(".user_staff_role_id").show();
      $(".user_cluster_schools").show();
      break;
    case 'group_admin':
      $(".user_school_group_id").show();
      break;
  }
}

$(document).ready(function() {
  $("body").on("change", ".user-update", function(ev) {
    $(this.form).submit();
  });
  if ($("#user_role").length) {
    $("body").on("change", "#user_role", function(ev) {
      setupSchoolGroupAndClusterControls();
    });
    setupSchoolGroupAndClusterControls();
  }
});

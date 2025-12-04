"use strict";

function setupSchoolGroupAndClusterControls() {
  document.querySelectorAll(".user_school_id, .user_school_group_id, .user_cluster_schools, .user_staff_role_id")
    .forEach(el => el.style.display = "none");

  const roleSelect = document.getElementById("user_role");
  if (!roleSelect) return;

  const selectedRole = roleSelect.value;

  // Show fields dependent on selected role
  switch (selectedRole) {
    case "pupil":
    case "student":
      document.querySelectorAll(".user_school_id").forEach(el => el.style.display = "");
      break;
    case "staff":
      document.querySelectorAll(".user_staff_role_id, .user_school_id").forEach(el => el.style.display = "");
      break;
    case "school_admin":
      document.querySelectorAll(".user_staff_role_id, .user_school_id, .user_cluster_schools")
        .forEach(el => el.style.display = "");
      break;
    case "group_admin":
    case "group_manager":
      document.querySelectorAll(".user_school_group_id")
        .forEach(el => el.style.display = "");
      break;
  }

  const groupSelect = document.getElementById("school_group_select");

  // Filter school group options by role
  // Relies on a data-group-type attribute on the school groups
  if (groupSelect) {
    const allowedTypes = {
      group_admin: ["multi_academy_trust", "local_authority", "general"],
      group_manager: ["project", "local_authority_area", "diocese"]
    };

    const allowed = allowedTypes[selectedRole] || null;

    // create array from options to iterate over them
    [...groupSelect.options].forEach(option => {
      const optionType = option.dataset.groupType;
      if (!optionType) {
        option.hidden = false; // keep blank/default option visible
      } else if (allowed && allowed.includes(optionType)) {
        option.hidden = false;
      } else {
        option.hidden = true;
      }
    });

    // If current selection is hidden, reset the field
    if (groupSelect.selectedOptions.length && groupSelect.selectedOptions[0].hidden) {
      groupSelect.value = "";
    }
  }
}

document.addEventListener("DOMContentLoaded", () => {
  if (document.querySelector(".admin-user-form")) {

    const roleSelect = document.getElementById("user_role");
    if (roleSelect) {
      roleSelect.addEventListener("change", setupSchoolGroupAndClusterControls);
      setupSchoolGroupAndClusterControls();
    }
  }

  const picker = document.getElementById("admin-user-picker");
  if (picker) {
    picker.addEventListener("change", () => {
      const val = picker.value;
      if (val && val.match(/^[/#]/)) {
        window.location.href = val;
      }
    });
  }
});

"use strict";

document.addEventListener("DOMContentLoaded", function () {

  document.addEventListener("change", function (event) {
    const input = event.target;

    if (!input.matches(".ensure-one-checked input")) return;

    const wrapper = input.closest(".ensure-one-checked");

    const checkedCount =
      wrapper.querySelectorAll('input[type="checkbox"]:checked').length;

    // dispose all tooltips
    document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(el => {
      const tooltip = bootstrap.Tooltip.getInstance(el);
      if (tooltip) tooltip.hide();
    });

    if (checkedCount === 0) {
      const next = wrapper.querySelector(`label[for="${input.id}"][data-bs-toggle="tooltip"]`);
      if (next) {
        let tooltip = bootstrap.Tooltip.getInstance(next);

        if (!tooltip) {
          tooltip = new bootstrap.Tooltip(next);
        }
        tooltip.show();
      }
      input.checked = true;
    }
  });


  document.addEventListener("mouseover", function (event) {
    if (!event.target.closest(".ensure-one-checked")) return;

    document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(el => {
      const tooltip = bootstrap.Tooltip.getInstance(el);
      if (tooltip) tooltip.hide();
    });
  });

});
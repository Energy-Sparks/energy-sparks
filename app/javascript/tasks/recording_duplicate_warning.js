"use strict";

// Checks whether an activity or action has already been recorded for the selected date.
//
// Makes a call to a controller method which returns a duplicate warning
// if there has already been a recording made on that date.
document.addEventListener("DOMContentLoaded", () => {
  const containers = document.querySelectorAll(".tempus-dominus-date");

  containers.forEach(container => {
    const input = container.querySelector("input[data-duplicate-check-url]");
    if (!input) return;

    const warning = container.parentElement.querySelector("[data-duplicate-task-warning]");

    if (!warning) return;

    const checkDuplicate = () => {
      if (input.value === input.dataset.lastDuplicateValue) return;

      input.dataset.lastDuplicateValue = input.value;
      warning.innerHTML = "";

      if (!input.value || !/^\d{2}\/\d{2}\/\d{4}$/.test(input.value)) return;

      const url = new URL(input.dataset.duplicateCheckUrl, window.location.origin);
      url.searchParams.set("date", input.value);

      fetch(url)
        .then(response => {
          if (!response.ok) throw new Error("Duplicate check failed");
          return response.text();activi
        })
        .then(html => {
          warning.innerHTML = html;
        })
        .catch(error => console.warn("Duplicate check failed:", error));
    };

    // Use jQuery to listen for the datetimepicker change event, no other way
    // to do this without upgrading Tempus Dominus to v6 (also no longer being maintained)
    window.jQuery(container).on("change.datetimepicker", checkDuplicate);
    // Also listen for input events in case the user types in a date manually
    input.addEventListener("input", checkDuplicate);
  });
});

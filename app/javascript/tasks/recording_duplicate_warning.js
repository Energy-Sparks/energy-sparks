"use strict";

// Checks whether an activity or action has already been recorded for the selected date.
//
// Makes a call to a controller method which returns a duplicate warning
// if there has already been a recording made on that date.
document.addEventListener("DOMContentLoaded", () => {
  const tempus_dominus_date = document.querySelector(".tempus-dominus-date");
  if (!tempus_dominus_date) return;

  const input = tempus_dominus_date.querySelector("input[data-duplicate-check-url]");
  const warning = tempus_dominus_date.parentElement.querySelector("[data-duplicate-task-warning]");
  const submit = document.querySelector('input[type="submit"]');

  if (!input || !warning || !submit) return;

  const checkDuplicate = () => {
    if (input.value === input.dataset.lastDuplicateValue) return;
    input.dataset.lastDuplicateValue = input.value;
    if (!input.value || !/^\d{2}\/\d{2}\/\d{4}$/.test(input.value)) return;

    const url = new URL(input.dataset.duplicateCheckUrl, window.location.origin);
    url.searchParams.set("date", input.value);

    warning.innerHTML = "";

    fetch(url)
      .then(response => {
        if (!response.ok) throw new Error("Duplicate check failed");
        return response.text();
      })
      .then(html => {
        warning.innerHTML = html;

        if (html.trim()) {
          submit.value = submit.dataset.duplicateText;
        } else {
          submit.value = submit.dataset.originalText;
        }
      })
      .catch(error => console.warn("Duplicate check failed:", error));
  };

  // Use jQuery to listen for the datetimepicker change event, no other way
  // to do this without upgrading Tempus Dominus to v6 (also no longer being maintained)
  window.jQuery(tempus_dominus_date).on("change.datetimepicker", checkDuplicate);
  // Also listen for input events in case the user types in a date manually
  input.addEventListener("input", checkDuplicate);

  // Check for duplicate on page load too
  checkDuplicate();
});

"use strict";

const findDuplicateCheckContext = (container) => {
  const input = container.querySelector("input[data-duplicate-check-url]");
  if (!input) return;

  let warning;
  for (let node = container.parentElement; node; node = node.parentElement) {
    warning = node.querySelector("[data-duplicate-task-warning]");
    if (warning) break;
  }

  return warning && { input, warning };
};

const checkDateDuplicate = ({ input, warning }) => {
  if (input.value === input.dataset.lastDuplicateValue) return;
  input.dataset.lastDuplicateValue = input.value;

  warning.innerHTML = "";
  if (!input.value) return;

  const url = new URL(input.dataset.duplicateCheckUrl, window.location.origin);
  url.searchParams.set("date", input.value);

  fetch(url)
    .then((response) => {
      if (!response.ok) throw new Error("Duplicate check failed");
      return response.text();
    })
    .then((html) => {
      warning.innerHTML = html;
    })
    .catch((error) => console.warn("Duplicate check failed:", error));
};

const initRecordingDuplicateWarning = () => {
  document.querySelectorAll(".tempus-dominus-date").forEach((container) => {
    const context = findDuplicateCheckContext(container);
    if (!context) return;

    // Tempus Dominus (bootstrap-4) fires this jQuery event when a date is picked.
    window.jQuery(container).on("change.datetimepicker", () => {
      checkDateDuplicate(context);
    });

    // Also covers typing directly into the field.
    context.input.addEventListener("input", () => checkDateDuplicate(context));
  });
};

document.addEventListener("DOMContentLoaded", initRecordingDuplicateWarning);

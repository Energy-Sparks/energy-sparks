"use strict"

document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll('.preserve-tab-link .tab-content a.btn.edit').forEach((element) => {
    element.addEventListener('click', (event) => {
      event.preventDefault();
      window.location.href = `${element.href}${encodeURIComponent(window.location.hash)}`;
    });
  });
});

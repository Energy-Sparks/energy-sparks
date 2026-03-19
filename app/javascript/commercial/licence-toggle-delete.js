document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".licence-toggle-delete").forEach((button) => {
    button.addEventListener("click", () => {
      const id = button.dataset.target;

      const mainRow = document.getElementById(`licence-${id}-main-row`);
      const commentsRow = document.getElementById(`licence-${id}-comments-row`);
      const destroyField = mainRow.querySelector(".destroy-flag");

      const deleting = destroyField.value === "0"; // flip state

      destroyField.value = deleting ? "1" : "0";

      [mainRow, commentsRow].forEach((row) =>
        row.classList.toggle("pending-delete", deleting)
      );

      button.textContent = deleting ? "Undo" : "Delete";
      button.classList.toggle("btn-danger", !deleting);
      button.classList.toggle("btn-outline-secondary", deleting);
    });
  });
});

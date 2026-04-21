document.addEventListener("DOMContentLoaded", () => {
  const container = document.getElementById("licence-rows");

  container.addEventListener("click", (event) => {
    const button = event.target.closest(".licence-toggle-delete");
    if (!button) return;

    const id = button.dataset.target;

    const mainRow = document.getElementById(`licence-${id}-main-row`);
    const commentsRow = document.getElementById(`licence-${id}-comments-row`);
    const destroyField = mainRow.querySelector(".destroy-flag");

    const deleting = destroyField.value === "0";

    destroyField.value = deleting ? "1" : "0";

    [mainRow, commentsRow].forEach((row) =>
      row.classList.toggle("pending-delete", deleting)
    );

    button.textContent = deleting ? "Undo" : "Delete";
    button.classList.toggle("btn-danger", !deleting);
    button.classList.toggle("btn-outline-secondary", deleting);
  });
});

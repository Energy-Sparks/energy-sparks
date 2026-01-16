document.addEventListener("DOMContentLoaded", () => {
  const typeInputs = document.querySelectorAll(".contract-holder-type");
  const select = document.querySelector(".contract-holder-select");

  if (!typeInputs.length || !select) return;

  function loadOptionsFor(type, preselectedId = null) {
    fetch(`/admin/commercial/contracts/contract_holder_options?type=${type}`)
      .then(response => response.json())
      .then(records => {
        select.innerHTML = "";

        const blank = document.createElement("option");
        blank.value = "";
        blank.textContent = `Select ${type}`;
        select.appendChild(blank);

        records.forEach(record => {
          const option = document.createElement("option");
          option.value = record.id;
          option.textContent = record.name;

          if (preselectedId && String(preselectedId) === String(record.id)) {
            option.selected = true;
          }

          select.appendChild(option);
        });
      });
  }

  typeInputs.forEach(input => {
    input.addEventListener("change", () => {
      loadOptionsFor(input.value);
    });
  });

  const checkedType = document.querySelector(".contract-holder-type:checked");

  if (checkedType) {
    const preselectedId = select.dataset.selectedId;
    loadOptionsFor(checkedType.value, preselectedId);
  }
});

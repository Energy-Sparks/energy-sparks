// Initialise Tom Select on any element with the tom-select class
//
// Configuration available:
// data-placeholder    - placeholder text
// data-max-items      - maximum number of selectable items (leave out for no limit)

import TomSelect from "tom-select"

const initialise = () => {
  document.querySelectorAll("select.tom-select").forEach((element) => {
    if (element.tomselect) {
      return
    }

    const options = {
      plugins: ["remove_button"],
      create: false,
      maxOptions: null,
      hideSelected: false
    }

    if (element.dataset.placeholder) {
      options.placeholder = element.dataset.placeholder
    }

    if (element.dataset.maxItems) {
      options.maxItems = parseInt(element.dataset.maxItems, 10)
    }

    new TomSelect(element, options)
  })
}

document.addEventListener("DOMContentLoaded", initialise)

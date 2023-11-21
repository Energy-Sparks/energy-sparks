"use strict"

const panel_switcher = (function () {
  function updatePanel() {
    let selected = this.value;
    let component = $(this).closest('.panel-switcher-component');
    // hide all panels
    component.find('.panel').prop('hidden', true);
    // show panel with the selected name
    component.find('.panel.' + selected).prop('hidden', false);
  }
  return {
    updatePanel: updatePanel
  }
})();

window.addEventListener("load", (event) => {
  $('.panel-switcher-component').on('change', 'input', panel_switcher.updatePanel);
});

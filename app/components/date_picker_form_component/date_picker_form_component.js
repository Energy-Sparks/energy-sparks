"use strict"

window.onload = function() {
  document.querySelectorAll(`[id^="datepickerformcomponent"]`).forEach(element => {
    $('#' + element.id).datetimepicker({
      format: 'DD/MM/YYYY',
      allowInputToggle: true,
      locale: moment.locale()
    });
  });
};

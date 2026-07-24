"use strict";

function initTempusDominus(root = document) {
  $(root).find('div.input-group.tempus-dominus-date').each(function() {
    var date_picker = $(this);
    var options = {
      format: 'DD/MM/YYYY',
      allowInputToggle: true,
      locale: moment.locale()
    };

    var allowInputToggle = date_picker.children('input').data('allowInputToggle');
    if (allowInputToggle != null) {
      options.allowInputToggle = allowInputToggle;
    }

    var maxDate = date_picker.children('input').data('maxDate');
    if (maxDate) {
      options.maxDate = moment(new Date(maxDate));
    }

    date_picker.datetimepicker(options);
  });

  $(root).find('div.input-group.tempus-dominus-date-time').each(function() {
    var date_picker = $(this);
    var maxDateTime = date_picker.children('input').data('maxDateTime');
    var options = {
      format: 'DD/MM/YYYY HH:mm',
      allowInputToggle: true,
      sideBySide: true,
      locale: moment.locale()
    };

    if (maxDateTime && maxDateTime.length) {
      options.maxDate = moment(new Date(maxDateTime));
    }

    date_picker.datetimepicker(options);
  });
}

$(document).ready(function() {
  initTempusDominus();
});

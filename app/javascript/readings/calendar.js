'use strict';

function loadReadingsCalendarData(dataUrl, calendarElement) {
  fetch(dataUrl)
    .then((response) => response.json())
    .then((response) => {
      const data = [];
      const returnedData = response.calendar_events;

      for (let i = 0; i < returnedData.length; i++) {
        data.push({
          id: returnedData[i].id,
          calendarEventTypeId: returnedData[i].calendarEventTypeId,
          name: returnedData[i].name,
          startDate: new Date(returnedData[i].startDate),
          endDate: new Date(returnedData[i].endDate),
          color: returnedData[i].color
        });
      }

      $(calendarElement).data('calendar').setDataSource(data);
    });
}

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.readings-calendar').forEach((calendarElement) => {
    $(calendarElement).calendar({
      enableContextMenu: false,
      enableRangeSelection: false,
      style: 'background',

      mouseOnDay: function (e) {
        if (e.events.length > 0) {
          let content = '';

          for (const event of e.events) {
            const startDate = event.startDate;
            const endDate = event.endDate;

            content +=
              '<div class="event-tooltip-content">' +
              '<div class="event-name" style="color:' +
              event.color +
              '"><strong>' +
              event.name +
              '</strong></div>' +
              '<div class="event-location">' +
              startDate.toDateString() +
              '</div>' +
              '</div>';
          }

          $(e.element).popover({
            trigger: 'manual',
            container: 'body',
            html: true,
            content: content
          });

          $(e.element).popover('show');
        }
      },

      mouseOutDay: function (e) {
        if (e.events.length > 0) {
          $(e.element).popover('hide');
        }
      },

      dayContextMenu: function (e) {
        $(e.element).popover('hide');
      }
    });

    const dataUrl =
      calendarElement.dataset.url ||
      `${window.location.pathname}.json`;

    loadReadingsCalendarData(dataUrl, calendarElement);
  });
});

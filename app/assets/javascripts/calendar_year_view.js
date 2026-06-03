"use strict"

function loadCalendarData(dataUrl, calendarDiv) {
  $.ajax({
    url: dataUrl,
    dataType: "json",
    success: function(response) {
      var data = [];
      var returnedData = response.calendar_events;
      for (var i = 0; i < returnedData.length; i++) {
        data.push({
          id: returnedData[i].id,
          calendarEventTypeId: returnedData[i].calendarEventTypeId,
          name: returnedData[i].name,
          startDate: new Date(returnedData[i].startDate),
          endDate: new Date(returnedData[i].endDate),
          color: returnedData[i].color,
          basedOn: returnedData[i].basedOn
        });
      }
      calendarDiv.data('calendar').setDataSource(data);
    }
  });
}

function loadCurrentEvents(dataUrl, currentEventsDiv) {
  $.ajax({
    url: dataUrl,
    success: function(response) {
      currentEventsDiv.html(response);
    }
  });
}

$(document).ready(function() {
  if ($("#calendar").length) {
    const id = (id) => document.getElementById(id);
    const q = (selector) => document.querySelector(selector);

    function editEvent(event) {
      const lastEvent =  event.events[event.events.length - 1];
      setupModal(lastEvent, lastEvent.startDate, lastEvent.endDate);
      enableEdit(false, null);
      $('#event-modal').modal();
    }

    function newEvent(event) {
      switch (event.events.length) {
        case 0:
          enableEdit(false, null);
          break
        case 1:
          enableEdit(true, event);
          break;
        default:
          return editEvent(event);
      }
      setupModal(null, event.date, event.date);
      $('#event-modal').modal();
    }

    function setupModal(event, start_date, end_date) {
      let method = 'post';
      let action_suffix = '';
      let event_type_id = '';
      let new_title_display = 'initial';
      let edit_title_display = 'none';
      if (event) {
        method = 'patch';
        action_suffix = `/${event.id}`;
        event_type_id = event.calendarEventTypeId;
        new_title_display = 'none';
        edit_title_display = 'initial';
      }
      const calendarId = id('event-modal').dataset.calendar;
      id('event_form').setAttribute('action', `/calendars/${calendarId}/calendar_events${action_suffix}`);
      setFormMethod(method)
      id('calendar_event_calendar_event_type_id').value = event_type_id;
      q('#event-modal input[name="calendar_event[start_date]"]').value = start_date.toLocaleDateString('en-GB');
      q('#event-modal input[name="calendar_event[end_date]"]').value = end_date.toLocaleDateString('en-GB');
      id('event-model-new-title').style.display = new_title_display;
      id('event-model-edit-title').style.display = edit_title_display;
      enableDelete(!!event);
    }

    function enableEdit(enable, event) {
      const button = id('edit_button');
      button.style.display = enable ? 'initial' : 'none';
      if (enable) {
        button.onclick = (e) => {
          e.preventDefault();
          editEvent(event);
        };
      }
    }

    function enableDelete(enable) {
      const button = id('delete_button');
      button.style.display = enable ? 'block' : 'none';
      button.onclick = (e) => {
        e.preventDefault();
        setFormMethod('delete');
        id('event_form').requestSubmit();
      };
    }

    function setFormMethod(method) {
      q('#event-modal input[name="_method"]').value = method;
    }

    $(function() {
      var currentYear = new Date().getFullYear();

      $('#calendar').calendar({
        enableContextMenu: false,
        enableRangeSelection: false,
        style: 'background',
        clickDay: function(e) {
          newEvent({ date: e.date, events: e.events });
        },
        mouseOnDay: function(e) {
          if(e.events.length > 0) {
            var content = '';
            for(var i in e.events) {
              var startDate = e.events[i].startDate;
              var endDate = e.events[i].endDate;
              content += '<div class="event-tooltip-content">'
              + '<div class="event-name" style="color:' + e.events[i].color + '">' + e.events[i].name + '</div>'
              + '<div class="event-location">' + startDate.toDateString() + ' - ' + endDate.toDateString() + '</div>'
              + '</div><hr />';
            }

            $(e.element).popover({
              trigger: 'manual',
              container: 'body',
              html:true,
              content: content
            });

            $(e.element).popover('show');
          }
        },
        mouseOutDay: function(e) {
          if(e.events.length > 0) {
            $(e.element).popover('hide');
          }
        },
        dayContextMenu: function(e) {
          $(e.element).popover('hide');
        },
      });
    });

    var currentEventsDiv = $('#current_events');

    $('a[data-toggle="tab"].reloadable').on('shown.bs.tab', function (e) {
      loadCurrentEvents($(this).data('reload-url'), currentEventsDiv);
    });

    var dataUrl = window.location.pathname + '.json';
    var calendarDiv = $('#calendar');

    loadCalendarData(dataUrl, calendarDiv);
  }

  if ($("#data-calendar").length) {

    $(function() {
      var currentYear = new Date().getFullYear();

      $('#data-calendar').calendar({
        enableContextMenu: false,
        enableRangeSelection: false,
        style: 'background',
        mouseOnDay: function(e) {
          if(e.events.length > 0) {
            var content = '';
            for(var i in e.events) {
              var startDate = e.events[i].startDate;
              var endDate = e.events[i].endDate;
              content += '<div class="event-tooltip-content">'
              + '<div class="event-name" style="color:' + e.events[i].color + '">' + e.events[i].name + '</div>'
              + '<div class="event-location">' + startDate.toDateString() + ' - ' + endDate.toDateString() + '</div>'
              + '</div><hr />';
            }

            $(e.element).popover({
              trigger: 'manual',
              container: 'body',
              html:true,
              content: content
            });

            $(e.element).popover('show');
          }
        },
        mouseOutDay: function(e) {
          if(e.events.length > 0) {
            $(e.element).popover('hide');
          }
        },
        dayContextMenu: function(e) {
          $(e.element).popover('hide');
        },
      });
    });

    if ($('#data-calendar').data('url')) {
      var dataUrl = $('#data-calendar').data('url');
    } else {
      var dataUrl = window.location.pathname + '.json';
    }

    var calendarDiv = $('#data-calendar');

    loadCalendarData(dataUrl, calendarDiv);
  }

});

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

    function editEvent(event) {
      const lastEvent =  event.events[event.events.length - 1];
      const startDate = lastEvent.startDate;
      const endDate = lastEvent.endDate;
      const calendarId =  $('#event-modal').data('calendar');
      $('form#event_form').attr('action', '/calendars/' + calendarId + '/calendar_events/' + lastEvent.id)
      $('#event-modal input[name="_method"]').val('patch');

      $("#calendar_event_calendar_event_type_id").val(lastEvent.calendarEventTypeId);

      $('#event-modal input[name="calendar_event[start_date]"]').val(startDate.toLocaleDateString("en-GB"));
      $('#event-modal input[name="calendar_event[end_date]"]').val(endDate.toLocaleDateString("en-GB"));

      $('#delete_button').show();

      $('#delete_button').on('click', function(event) {
        event.preventDefault();

        $('#event-modal input[name="_method"]').val('delete');
        $('form#event_form').submit();
      });
      document.getElementById('event-model-new-title').style.display = 'none';
      document.getElementById('event-model-edit-title').style.display = 'inherit';
      document.getElementById('edit_button').style.display = 'none';
      $('#event-modal').modal();
    }

    function newEvent(event) {
      if (event.events.length) {
          if (event.events.at(-1).basedOn) {
            document.getElementById('edit_button').style.display = 'initial';
            document.getElementById('edit_button').addEventListener('click', function(e) {
              e.preventDefault();
              editEvent(event);
            });
          } else {
            return editEvent(event);
          }
      } else {
        document.getElementById('edit_button').style.display = 'none';
      }

      var calendarId =  $('#event-modal').data('calendar');
      $('form#event_form').attr('action', '/calendars/' + calendarId + '/calendar_events')
      $('#event-modal input[name="_method"]').val('post');

      $("#calendar_event_calendar_event_type_id").val('');

      $('#event-modal input[name="calendar_event[start_date]"]').val(event.date.toLocaleDateString("en-GB"));
      $('#event-modal input[name="calendar_event[end_date]"]').val(event.date.toLocaleDateString("en-GB"));

      $('#delete_button').hide();

      document.getElementById('event-model-new-title').style.display = 'initial';
      document.getElementById('event-model-edit-title').style.display = 'none';
      $('#event-modal').modal();
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

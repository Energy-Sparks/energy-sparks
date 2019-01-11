"use strict"

$(document).ready(function() {
  if ($("#calendar").length) {

    function setUpDatePickers(input_field_name) {
      $('#event-modal input[name="' + input_field_name + '"]').datepicker({
        dateFormat: 'dd/mm/yy',
        altFormat: 'yy-mm-dd',
        orientation: 'bottom'
      });
    }

    function editEvent(event) {

      var startDate = null;
      var endDate = null;

      if (event.events.length) {
        var lastEvent =  event.events[event.events.length - 1];
        startDate = lastEvent.startDate;
        endDate = lastEvent.endDate;
        var calendarId =  $('#calendar_event_calendar_id').val();

        $('form#event_form').attr('action', '/calendars/' + calendarId + '/calendar_events/' + lastEvent.id)

        $("#calendar_event_calendar_event_type_id").val(lastEvent.calendarEventTypeId);
        $('#event-modal input[name="calendar_event[title]"]').val(lastEvent.name);
      } else {
        startDate = event.startDate;
        endDate = event.endDate;
      }
      $('#event-modal input[name="event-index"]').val(event ? event.id : '');
      $('#event-modal input[name="calendar_event[start_date]"]').val(startDate ? startDate.toLocaleDateString("en-GB") : '');
      $('#event-modal input[name="calendar_event[end_date]"]').val(endDate ? endDate.toLocaleDateString("en-GB") : '');

      $('#event-modal').modal();
    }

    $(function() {
      var currentYear = new Date().getFullYear();

      $('#calendar').calendar({
        enableContextMenu: false,
        enableRangeSelection: true,
        style: 'background',
        //contextMenuItems:[{ text: 'Update', click: editEvent }],
        selectRange: function(e) {
          editEvent({ startDate: e.startDate, endDate: e.endDate, events: e.events });
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
              + '</div>';
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

    var currentPath = window.location.pathname;
    var dataUrl = window.location.pathname + '.json';

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
            color: returnedData[i].color
          });
        }
        $('.calendar').data('calendar').setDataSource(data);
      }
    });
  }
});
"use strict"

$(document).ready(function() {
  if ($("#calendar").length) {

    function editEvent(event) {

      var lastEvent =  event.events[event.events.length - 1];
      var startDate = lastEvent.startDate;
      var endDate = lastEvent.endDate;

      var calendarId =  $('#event-modal').data('calendar');

      $(".event-action").html('Edit');
      $('form#event_form').attr('action', '/calendars/' + calendarId + '/calendar_events/' + lastEvent.id)
      $('#event-modal input[name="_method"]').val('patch');

      $("#calendar_event_calendar_event_type_id").val(lastEvent.calendarEventTypeId);
      $('#event-modal input[name="calendar_event[title]"]').val(lastEvent.title);

      $('#event-modal input[name="calendar_event[start_date]"]').val(startDate.toLocaleDateString("en-GB"));
      $('#event-modal input[name="calendar_event[end_date]"]').val(endDate.toLocaleDateString("en-GB"));

      $('#delete_button').show();

      $('#delete_button').on('click', function(event) {
        event.preventDefault();

        $('#event-modal input[name="_method"]').val('delete');
        $('form#event_form').submit();
      });

      $('#event-modal').modal();
    }

    function newEvent(event) {
      var calendarId =  $('#event-modal').data('calendar');

      $(".event-action").html('New');
      $('form#event_form').attr('action', '/calendars/' + calendarId + '/calendar_events')
      $('#event-modal input[name="_method"]').val('post');

      $("#calendar_event_calendar_event_type_id").val('');
      $('#event-modal input[name="calendar_event[title]"]').val('');

      $('#event-modal input[name="calendar_event[start_date]"]').val(event.date.toLocaleDateString("en-GB"));
      $('#event-modal input[name="calendar_event[end_date]"]').val(event.date.toLocaleDateString("en-GB"));

      $('#delete_button').hide();

      $('#event-modal').modal();
    }

    $(function() {
      var currentYear = new Date().getFullYear();

      $('#calendar').calendar({
        enableContextMenu: false,
        enableRangeSelection: false,
        style: 'background',
        clickDay: function(e) {
          if(e.events.length){
            editEvent({ events: e.events });
          }else{
            newEvent({ date: e.date });
          }
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
            color: returnedData[i].color,
            title: returnedData[i].title
          });
        }
        $('.calendar').data('calendar').setDataSource(data);
      }
    });
  }
});

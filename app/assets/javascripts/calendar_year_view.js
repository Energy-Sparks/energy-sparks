"use strict"

$(document).ready(function() {
  if ($("#calendar").length) {
    function editEvent(event) {
      console.log('edit');

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
      $('#event-modal input[name="calendar_event[start_date]"]').datepicker({
        dateFormat: 'dd/mm/yy',
        altFormat: 'yy-mm-dd',
        orientation: 'bottom'
      });
      $('#event-modal input[name="calendar_event[end_date]"]').val(endDate ? endDate.toLocaleDateString("en-GB") : '');
      $('#event-modal input[name="calendar_event[end_date]"]').datepicker({
        dateFormat: 'dd/mm/yy',
        altFormat: 'yy-mm-dd',
        orientation: 'bottom'
      });

      $('#event-modal').modal();
    }

    function deleteEvent(event) {
      var dataSource = $('#calendar').data('calendar').getDataSource();

      for(var i in dataSource) {
        if(dataSource[i].id == event.id) {
          dataSource.splice(i, 1);
          break;
        }
      }

      $('#calendar').data('calendar').setDataSource(dataSource);
    }

    function saveEvent() {
      var event = {
        id: $('#event-modal input[name="event-index"]').val(),
        name: $('#event-modal input[name="event-name"]').val(),
        location: $('#event-modal input[name="event-location"]').val(),
        startDate: $('#event-modal input[name="event-start-date"]').datepicker('getDate'),
        endDate: $('#event-modal input[name="event-end-date"]').datepicker('getDate')
      }

      var dataSource = $('#calendar').data('calendar').getDataSource();

      if(event.id) {
        for(var i in dataSource) {
          if(dataSource[i].id == event.id) {
            dataSource[i].name = event.name;
            dataSource[i].location = event.location;
            dataSource[i].startDate = event.startDate;
            dataSource[i].endDate = event.endDate;
          }
        }
      }
      else
      {
        var newId = 0;
        for(var i in dataSource) {
          if(dataSource[i].id > newId) {
            newId = dataSource[i].id;
          }
        }

        newId++;
        event.id = newId;

        dataSource.push(event);
      }

      $('#calendar').data('calendar');
      $('#event-modal').modal('hide');
    }

    $(function() {
      var currentYear = new Date().getFullYear();

      $('#calendar').calendar({
        enableContextMenu: true,
        enableRangeSelection: true,
        style: 'background',
        contextMenuItems:[
        {
          text: 'Update',
          click: editEvent
        },
        {
          text: 'Delete',
          click: deleteEvent
        }
        ],
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

      $('#save-event').click(function() {
        saveEvent();
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
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'turbolinks:load', ->
  $("#activity_date_picker").datepicker
    dateFormat: 'dd/mm/yy'
    altFormat: 'yy-mm-dd'
    altField: "#activity_happened_on"
    maxDate: 0
    orientation: 'bottom'
  # clear altfield if picker field is cleared
  $("#activity_date_picker").change ->
    $("#activity_happened_on").val ""  unless $(this).val()

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'turbolinks:load', ->
  $(".term_datepicker").datepicker
    dateFormat: 'dd/mm/yy'
    altFormat: 'yy-mm-dd'
    orientation: 'bottom'
  # set altField from data attribute
  $(".term_datepicker").each ->
    altfield = $(this).data("altfield")
    $(this).datepicker("option", "altField", altfield)

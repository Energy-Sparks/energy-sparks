"use strict"

$(document).ready(function() {
  //when we click on a letter make sure its marked as active
  $(document).on('click','li.letter a',function(){
    $(this).closest('.pagination').children('.page-item').removeClass('active');
    $(this).parent().addClass('active');
  });

  //when we submit a search deselect the letters
  $(document).on('submit','form#schools-search',function(){
    $(this).closest('#schools-content').find('.pagination').children('.page-item').removeClass('active');
  });

  $(document).on('submit','form#school-groups-search',function(){
    $(this).closest('#school-groups-content').find('.pagination').children('.page-item').removeClass('active');
  });

});

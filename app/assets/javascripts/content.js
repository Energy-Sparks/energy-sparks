"use strict";

$(document).ready(function() {
  $('a.preview-tab[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    var tab = $(e.target);
    var pane  = $(tab.attr('href'));
    var url = pane.data('content-url');
    var form = pane.parents('form');

    var data = form.find("[name!='_method']").serialize();

    $.ajax({
      method: 'POST',
      url: url,
      data: data,
      error: function(jqXHR, textStatus, errorThrown){
        pane.find('.loading').hide();
        pane.find('.content').html('<div class="alert alert-danger">Preview failed</div>');
      },
      success: function(data, textStatus, jqXHR){
        pane.find('.loading').hide();
        pane.find('.content').html(data);
        processAnalysisCharts();
      }
    });
  });

  $('a.preview-tab[data-toggle="tab"]').on('hidden.bs.tab', function (e) {
    var tab = $(e.target);
    var pane  = $(tab.attr('href'));
    pane.find('.loading').show();
    pane.find('.content').html('');
  });

  $('.content-section .tab-pane:has(.is-invalid)').each(function(){
    var tab_pane = $(this);
    var tab = $('#' + tab_pane.attr('aria-labelledby'));
    tab.find('.text-danger').removeClass('d-none');
  });
});

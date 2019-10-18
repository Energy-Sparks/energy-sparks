addEventListener("trix-initialize", function(event) {

  var parentWrapper = $(event.target).parents('.chart-list');

  if(parentWrapper.length){
    var buttonHTML = $('#trix-chart-list-components button[data-trix-action="chart"]');
    var dialogHTML = $('#trix-chart-list-components .trix-dialog');

    $(event.target.toolbarElement).find('.trix-button-group--text-tools').append(buttonHTML);
    $(event.target.toolbarElement).find('.trix-dialogs').append(dialogHTML);
  }

});

document.addEventListener("trix-action-invoke", function(event) {
  if(event.actionName === "x-insert-chart"){
    var element = event.target;
    var parentWrapper = $(element).parents('.chart-list');
    element.editor.insertHTML("{{#chart}}" + $('select[name="chart-list-chart"]').val() + "{{/chart}}");
  }
})

window.onload = function(){
  $('.panel-switcher-component').on('change', 'input', function() {
    let selected = this.value;
    let component = $(this).closest('.panel-switcher-component');
    // hide all panels
    component.find('.panel').prop('hidden', true);
    // show panel with selected name
    component.find('.panel.' + selected).prop('hidden', false);
  });
}

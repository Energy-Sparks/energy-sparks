"use strict"

export const notifier = ( function() {

  function page(level, message, fade = true) {
    notify('page', level, message, fade);
  }

  function app(level, message, fade = true) {
    notify('app', level, message, fade);
  }

  function notify(where, level, message, fade = true) {
    // where = page or app
    // level = boostrap alert level
    let alert = $('#' + where + '-notifier');
    let classes = 'alert alert-' + level;
    alert.removeClass().addClass(classes).text(message);
    if(fade) {
      alert.fadeTo(5000, 500).slideUp(1000);
    } else {
      alert.show();
    }
  }

  // public methods
  return {
    app: app,
    page: page
  }

}());
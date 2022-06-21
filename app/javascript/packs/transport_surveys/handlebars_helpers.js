Handlebars.registerHelper('pluralise', function(number, single, plural) {
  if (number > 1) {
    return plural;
  } else {
    return single;
  }
});

Handlebars.registerHelper('nice_date', function(dateString) {
  let date = moment(dateString);
  if (date.isSame(moment().format("YYYY-MM-DD"))) {
    return "today";
  } else {
    return date.format("ddd Do MMM YYYY");
  }
});

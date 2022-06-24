import { nice_date } from './helpers';

Handlebars.registerHelper('pluralise', function(number, single, plural) {
  if (number > 1) {
    return plural;
  } else {
    return single;
  }
});

Handlebars.registerHelper('nice_date', function(dateString) {
  return nice_date(dateString);
});

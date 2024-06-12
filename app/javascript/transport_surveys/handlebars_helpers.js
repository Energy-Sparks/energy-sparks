import { nice_date, pluralise } from 'transport_surveys/helpers';

Handlebars.registerHelper('unsaved_responses', function(element, count, date, today) {
  return pluralise(element, {count: count, date: nice_date(date, today)});
});

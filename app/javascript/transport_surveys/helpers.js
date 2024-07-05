"use strict"

export function pluralise(element, vars) {
  let statement = "";
  if (vars.count > 1) {
    statement = element.other;
  } else {
    statement = element.one;
  }
  for (var key in vars) {
    statement = statement.replace(`%{${key}}`, vars[key]);
  }
  return statement;
}

export function nice_date(dateString, today) {
  let date = moment(dateString);
  if (date.isSame(moment().format("YYYY-MM-DD"))) {
    return today;
  } else {
    return date.format("ddd Do MMM YYYY");
  }
};
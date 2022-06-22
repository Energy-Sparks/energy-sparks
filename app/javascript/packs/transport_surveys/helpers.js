"use strict"

export function pluralise(word, amount = 1) {
  return `${word}${amount == 1 ? '' : 's'}`;
};

export function nice_date(dateString) {
  let date = moment(dateString);
  if (date.isSame(moment().format("YYYY-MM-DD"))) {
    return "today";
  } else {
    return date.format("ddd Do MMM YYYY");
  }
};
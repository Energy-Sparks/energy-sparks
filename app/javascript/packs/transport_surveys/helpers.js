"use strict"

export function pluralise(word, amount = 1) {
  return `${word}${amount == 1 ? '' : 's'}`;
};
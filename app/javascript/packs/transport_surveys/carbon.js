// logic mostly lifted from the old app.


export const carbonExamples = [
  {
    name: 'Tree',
    emoji: '🌳',
    kgPerActivity: 0.06,
    unit: 'day',
    statement: (amount, unit, emoji) => `1 tree would absorb this amount of CO2 in ${amount} ${unit} ${emoji}!`,
  }, {
    name: 'TV',
    emoji: '📺',
    kgPerActivity: 0.008,
    unit: 'hour',
    statement: (amount, unit, emoji) => `That\'s the same as ${amount} ${unit} of TV! ${emoji}!`,
  }, {
    name: 'Gaming',
    emoji: '🎮',
    kgPerActivity: 0.04,
    unit: 'hour',
    statement: (amount, unit, emoji) => `That\'s the same as playing ${amount} ${unit} of computer games! ${emoji}!`,
  }, {
    name: 'Meat dinners',
    emoji: '🍲',
    kgPerActivity: 1,
    unit: 'meat dinner',
    statement: (amount, unit, emoji) => `That\'s the same as ${amount} ${unit} ${emoji}!`,
  }, {
    name: 'Veggie dinners',
    emoji: '🥗',
    kgPerActivity: 0.5,
    unit: 'veggie dinner',
    statement: (amount, unit, emoji) => `That\'s the same as ${amount} ${unit} ${emoji}!`,
  }
];

export const carbonEquivalence = function(carbonKgs) {
  if (carbonKgs === 0) {
    return "That's Carbon Neutral 🌳!";
  } else {
    // pick random example until one returning a non-zero amount is found
    var examples = carbonExamples;
    while (examples.length > 0) {
      let i = Math.floor(Math.random() * examples.length);
      let example = examples[i];
      let amount = Math.round(carbonKgs / example.kgPerActivity);
      if (amount >= 1) {
        return example.statement(amount, pluralise(example.unit, amount), example.emoji);
      } else {
        examples.splice(i, 1); // remove as tried this example
      }
    }
    return ""; // no equivalence found
  }
};

export const pluralise = function(word, amount = 1) {
  return `${word}${amount == 1 ? '' : 's'}`;
}

const parkAndStrideTimeMins = function(timeMins) {
  // take 15 mins off a park and stride journey
  return (timeMins > 15 ? timeMins - 15 : 0);
};

export const carbonCalc = function(transport, timeMins, passengers) {
  if (transport) {
    timeMins = transport.park_and_stride == true ? parkAndStrideTimeMins(timeMins) : timeMins;
    var total_carbon = ((transport.speed_km_per_hour * timeMins) / 60) * transport.kg_co2e_per_km;
    total_carbon = transport.can_share == true ? (total_carbon / passengers) : total_carbon;
    return total_carbon;
  } else {
    return 0;
  }
};

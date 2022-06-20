// Would be nice to pull these straight from Analytics at some point
const UK_ELECTRIC_GRID_CO2_KG_KWH = 0.230;
const TREE_CO2_KG_YEAR = 22;
const TV_POWER_KW = 0.04;
const COMPUTER_CONSOLE_POWER_KW = 0.2;
const CARNIVORE_DINNER_CO2_KG = 1.0;
const VEGETARIAN_DINNER_CO2_KG = 0.5;
const SMARTPHONE_CHARGE_kWH = 3.6 * 2.0 / 1000.0;

const carbonExamples = [
  {
    name: 'Tree',
    emoji: '🌳',
    co2_kg: TREE_CO2_KG_YEAR / 365,
    unit: 'day',
    statement: (amount, unit, emoji) => `1 tree would absorb this amount of CO2 in ${amount} ${unit} ${emoji}!`,
  }, {
    name: 'TV',
    emoji: '📺',
    co2_kg: TV_POWER_KW * UK_ELECTRIC_GRID_CO2_KG_KWH,
    unit: 'hour',
    statement: (amount, unit, emoji) => `That\'s the same as ${amount} ${unit} of TV ${emoji}!`,
  }, {
    name: 'Gaming',
    emoji: '🎮',
    co2_kg: COMPUTER_CONSOLE_POWER_KW * UK_ELECTRIC_GRID_CO2_KG_KWH,
    unit: 'hour',
    statement: (amount, unit, emoji) => `That\'s the same as playing ${amount} ${unit} of computer games ${emoji}!`,
  }, {
    name: 'Meat dinners',
    emoji: '🍲',
    co2_kg: CARNIVORE_DINNER_CO2_KG,
    unit: 'meat dinner',
    statement: (amount, unit, emoji) => `That\'s the same as ${amount} ${unit} ${emoji}!`,
  }, {
    name: 'Veggie dinners',
    emoji: '🥗',
    co2_kg: VEGETARIAN_DINNER_CO2_KG,
    unit: 'veggie dinner',
    statement: (amount, unit, emoji) => `That\'s the same as ${amount} ${unit} ${emoji}!`,
  }, {
    name: 'Smart phones',
    emoji: '📱',
    co2_kg: SMARTPHONE_CHARGE_kWH * UK_ELECTRIC_GRID_CO2_KG_KWH,
    unit: 'smart phone',
    statement: (amount, unit, emoji) => `That\'s the same as charging ${amount} ${unit} ${emoji}!`,
  }
];

const parkAndStrideTimeMins = function(timeMins) {
  // take 15 mins off a park and stride journey
  return (timeMins > 15 ? timeMins - 15 : 0);
};

export const carbonEquivalence = function(carbonKgs) {
  if (carbonKgs === 0) {
    return "That's Carbon Neutral 🌳!";
  } else {
    // pick random example until one returning a non-zero amount is found
    var examples = carbonExamples;
    while (examples.length > 0) {
      let i = Math.floor(Math.random() * examples.length);
      let example = examples[i];
      let amount = Math.round(carbonKgs / example.co2_kg);
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

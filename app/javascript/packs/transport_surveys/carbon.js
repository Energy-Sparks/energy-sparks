
import { pluralise } from './helpers';

export const carbon = ( function() {

  var rates = {};

  function init(cfg) {
    rates = cfg;
  }

  const equivalences = [
    {
      name: 'tree',
      emoji: '🌳',
      unit: 'day',
      rate: () => rates.tree / 365,
      statement: (amount, unit, emoji) => `1 tree would absorb this amount of CO2 in ${amount} ${unit} ${emoji}!`,
    }, {
      name: 'tv',
      emoji: '📺',
      unit: 'hour',
      rate: () => rates.tv,
      statement: (amount, unit, emoji) => `That\'s the same as ${amount} ${unit} of TV ${emoji}!`,
    }, {
      name: 'computer_console',
      emoji: '🎮',
      unit: 'hour',
      rate: () => rates.computerConsole,
      statement: (amount, unit, emoji) => `That\'s the same as playing ${amount} ${unit} of computer games ${emoji}!`,
    }, {
      name: 'smartphone',
      emoji: '📱',
      unit: 'smart phone',
      rate: () => rates.smartphone,
      statement: (amount, unit, emoji) => `That\'s the same as charging ${amount} ${unit} ${emoji}!`,
    } , {
      name: 'carnivore_dinner',
      emoji: '🍲',
      unit: 'meat dinner',
      rate: () => rates.carnivoreDinner,
      statement: (amount, unit, emoji) => `That\'s the same as ${amount} ${unit} ${emoji}!`,
    }, {
      name: 'vegetarian_dinner',
      emoji: '🥗',
      unit: 'veggie dinner',
      rate: () => rates.vegetarianDinner,
      statement: (amount, unit, emoji) => `That\'s the same as ${amount} ${unit} ${emoji}!`,
    }
  ];

  function parkAndStrideTimeMins(timeMins) {
    // take 15 mins off a park and stride journey
    return (timeMins > 15 ? timeMins - 15 : 0);
  }

  function equivalence(carbonKgs) {
    if (carbonKgs === 0) {
      return "That's Carbon Neutral 🌳!";
    } else {
      // pick random equivalence until one returning a non-zero amount is found
      let tried = [...equivalences.keys()];
      while (tried.length > 0) {
        let i = Math.floor(Math.random() * tried.length);
        let example = equivalences[tried[i]];
        let amount = Math.round(carbonKgs / example.rate());
        if (amount >= 1) {
          return example.statement(amount, pluralise(example.unit, amount), example.emoji);
        } else {
          tried.splice(i, 1); // remove as tried this example
        }
      }
      return ""; // no equivalence found
    }
  }

  function calc(transport, timeMins, passengers) {
    if (transport) {
      timeMins = transport.park_and_stride == true ? parkAndStrideTimeMins(timeMins) : timeMins;
      var total_carbon = ((transport.speed_km_per_hour * timeMins) / 60) * transport.kg_co2e_per_km;
      total_carbon = transport.can_share == true ? (total_carbon / passengers) : total_carbon;
      return total_carbon;
    } else {
      return 0;
    }
  };

  // public methods
  return {
    init: init,
    calc: calc,
    equivalence: equivalence
  }

}());

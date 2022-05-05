// logic mostly lifted from the old app.

export const carbonExamples = [
	{
		name: 'Tree',
    emoji: '🌳',
    equivalentStatement: function(carbonKgs) {
      const treeAbsorbsionKgPerDay = 0.06;
      let days = Math.round(carbonKgs / treeAbsorbsionKgPerDay);
			return `1 tree would absorb this amount of CO2 in ${days} day(s) 🌳!`;
		}
  }, {
		name: 'TV',
    emoji: '📺',
    equivalentStatement: function(carbonKgs) {
      const tvKgPerHour = 0.008;
      let hours = Math.round(carbonKgs / tvKgPerHour);
      return `That's the same as ${hours} hour${hours === 1 ? '' : 's'} of TV 📺!`;
		},
	}, {
    name: 'Gaming',
    emoji: '🎮',
    equivalentStatement: function(carbonKgs) {
      const gamingKgPerHour = 0.008;
      let hours = Math.round(carbonKgs / gamingKgPerHour);
      return `That's the same as playing ${hours} hour${hours === 1 ? '' : 's'} of computer games 🎮!`;
		},
	}, {
    name: 'Meat dinners',
    emoji: '🍲',
    equivalentStatement: function(carbonKgs) {
      const kgPerMeatDinner = 1;
      let meatDinners = Math.round(carbonKgs / kgPerMeatDinner);
      return `That's the same as ${meatDinners} meat dinner${meatDinners === 1 ? '' : 's'} 🍲!`;
		},
  }, {
    name: 'Veggie dinners',
    emoji: '🥗',
    equivalentStatement: function(carbonKgs) {
      const kgPerVeggieDinner = 0.5;
      let veggieDinners = Math.round(carbonKgs / kgPerVeggieDinner);
      return `That's the same as ${veggieDinners} veggie dinner${veggieDinners === 1 ? '' : 's'} 🥗!`;
		},
  },
 ];

export const funWeight = function(carbonKgs) {
  if (carbonKgs === 0) {
    return "That's Carbon Neutral 🌳!";
  } else {
    let randomEquivalent = carbonExamples[Math.floor(Math.random() * carbonExamples.length)];
    return randomEquivalent.equivalentStatement(carbonKgs);
  }
};

const parkAndStrideTimeMins = function(timeMins) {
	// take 15 mins off a park and stride journey
	return (timeMins > 15 ? timeMins - 15 : 0);
}

export const carbonCalc = function(transport, timeMins, passengers) {
	if (transport) {
		timeMins = transport.image === '🚶🚘' ? parkAndStrideTimeMins(timeMins) : timeMins; // need a better way of identifying park and stride!
		return (((transport.speed_km_per_hour * timeMins) / 60) * transport.kg_co2e_per_km) / passengers ;
	} else {
		return 0;
	}
}

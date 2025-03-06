export const carbon = ( function() {

  var local = {
    neutral: '',
    equivalences: '',
    parkAndStrideMins: ''
  }

  // private methods
  function init(cfg) {
    local = cfg;
  }

  function statement(statement, amount, image) {
    return statement.replace(/%{count}/, amount).replace(/(%{image})/, image);
  }

  function parkAndStrideTimeMins(timeMins) {
    // take 10 mins off a park and stride journey
    return (timeMins > local.parkAndStrideMins ? timeMins - local.parkAndStrideMins : 0);
  }

  function equivalence(carbonKgs) {
    if (carbonKgs === 0) {
      return local.neutral;
    } else {
      // pick random equivalence until one returning a non-zero amount is found
      let tried = [...local.equivalences.keys()];
      while (tried.length > 0) {
        let i = Math.floor(Math.random() * tried.length);
        let example = local.equivalences[tried[i]];
        let amount = Math.round(carbonKgs / example.rate);
        if (amount > 1) {
          return statement(example.statement.other, amount, example.image);
        } else if (amount == 1) {
          return statement(example.statement.one, amount, example.image);
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

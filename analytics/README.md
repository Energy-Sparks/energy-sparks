# Project Title

Energy Sparks analytics library and test framework

# Background

Energy Sparks is a UK based charity which helps schools reduce their carbon emissions, saves energy costs, and provides energy and climate change education to school pupils. The charity provides an online platform https://energysparks.uk/ which provides these educational resources and analysis of half hourly gas and electricity smart meter data. This library analyses the smart meter data to provide insight into a school's energy usage and carbon emissions. The library is used by the 'front end' to provide the Energy Sparks website, which is held in a separate repository: https://github.com/BathHacked/energy-sparks#.

This library provides a number of functions
- validation and aggregation used to produce a wide variety of energy and carbon emission charts
  - validation via `AggregateDataService.validate_meter_data` and `ValidateAmrData` which it uses
  - aggregation via `AggregateDataService.aggregate_heat_and_electricity_meters`
- energy equivalences to aid understanding e.g. 'the energy you used today is equivalent to the carbon emissions of driving a car 100 km'
- 'alerts' framework
  - used to monitor schools energy usage and provide feedback to schools where they can save energy and how their energy usage has changed - presented on the website and emailed/texted by the https://github.com/Energy-Sparks/energy-sparks to users'
  - generates variables used to drive application alert messages and weekly alerts
  - generates the benchmark metrics used in school comparison tool
- contextual advice to schools
- building energy modelling - currently implemented within a regression modelling framework
- tools for comparing and benchmarking schools with each other
- meter aggregation and disaggregation including special handling of solar PV and storage heaters
- a variety of external mainly JSON interfaces for pulling in relevant weather, solar PV, carbon emissions and meter data
  - mostly used directly by https://github.com/Energy-Sparks/energy-sparks
  - under `lib/dashboard/data_sources`

## Getting Started

TBD: - the library can be run standalone from the 'front end' using CSV or YAML files to replace data held on the 'front end' database, rendering HTML and charts to Excel. Further information to follow on how to set this up........

### Prerequisites

See above

### Installing

TBD

## Running the tests

We use RSpec, which is a testing tool for Ruby.  You can read more about RSpec here https://rspec.info/
You can run all tests by running rspec at the command line with:
`bundle exec rspec`

The analytics also has it's own custom suite of tests which can be found in the `script/standard` directory.  These can be run at the command line with:
`ANALYTICSTESTDIR=test_output bundle exec ruby script/standard/{name_of_test_script}.rb`
where `ANALYTICSTESTDIR` equals the directory that you want all test output to be saved.

### Break down into end to end tests

TBD

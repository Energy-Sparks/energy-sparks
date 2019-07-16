# frozen_string_literal: true

namespace :development do
  task active_freshford_with_meters: [:environment] do
    school = School.find_by(urn: 109_195)
    school.update(active: true)
    Meter.create(school: school, meter_type: :gas, active: true, name: 'Gas', mpan_mprn: 67_095_200)
    Meter.create(school: school, meter_type: :electricity, active: true, name: 'Electricity', mpan_mprn: 2_000_006_183_919)
  end
end

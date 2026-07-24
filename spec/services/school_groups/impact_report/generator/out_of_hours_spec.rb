# frozen_string_literal: true

require 'rails_helper'

describe SchoolGroups::ImpactReport::Generator::OutOfHours do
  subject(:generator) { described_class.new(school.school_group, visible_schools) }

  let(:school) { create(:school, :with_school_group) }
  let(:visible_schools) { school.school_group.assigned_schools.visible }

  describe '#metrics' do
    before do
      alert_generation_run = create(:alert_generation_run, school:)
      create(:alert, school: school, alert_generation_run:,
                     alert_type: create(:alert_type, class_name: AlertOutOfHoursGasUsage),
                     variables: { out_of_hours_kwh: 1,
                                  out_of_hours_co2: 2,
                                  out_of_hours_gbpcurrent: 3 })
      create(:alert, school: school, alert_generation_run:,
                     alert_type: create(:alert_type, class_name: AlertOutOfHoursGasUsagePreviousYear))
      create(:alert, school: school, alert_generation_run:,
                     alert_type: create(:alert_type, class_name: AlertAdditionalPrioritisationData))
      create(:alert, school: school, alert_generation_run:,
                     alert_type: create(:alert_type, class_name: AlertOutOfHoursElectricityUsage),
                     variables: { out_of_hours_kwh: 4,
                                  out_of_hours_co2: 5,
                                  out_of_hours_gbpcurrent: 6 })
      create(:alert, school: school, alert_generation_run:,
                     alert_type: create(:alert_type, class_name: AlertOutOfHoursElectricityUsagePreviousYear))
      [Comparison::AnnualChangeInGasOutOfHoursUse, Comparison::AnnualChangeInElectricityOutOfHoursUse].each(&:refresh)
    end

    def metric(unit, value, fuel_type, **)
      { enough_data: true, metric_category: :energy_efficiency, metric_type: :out_of_hours, fuel_type:,
        number_of_schools: 1, value:, unit: }
        .merge(**)
    end

    it 'has the right metrics' do
      expect(generator.metrics).to contain_exactly(
        metric(:kwh, 1, :gas), metric(:co2, 2, :gas), metric(:gbp, 3, :gas),
        metric(:kwh, 4, :electricity), metric(:co2, 5, :electricity), metric(:gbp, 6, :electricity)
      )
    end
  end
end

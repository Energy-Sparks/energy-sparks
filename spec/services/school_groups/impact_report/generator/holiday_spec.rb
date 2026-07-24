# frozen_string_literal: true

require 'rails_helper'

describe SchoolGroups::ImpactReport::Generator::Holiday do
  subject(:generator) { described_class.new(school.school_group, visible_schools) }

  let(:school) { create(:school, :with_school_group) }
  let(:visible_schools) { school.school_group.assigned_schools.visible }

  describe '#metrics' do
    before do
      alert_generation_run = create(:alert_generation_run, school:)
      create(:alert, school:, alert_generation_run:,
                     alert_type: create(:alert_type, class_name: AlertPreviousHolidayComparisonElectricity),
                     variables: { difference_gbpcurrent: -1,
                                  difference_kwh: -2 })
      create(:alert, school:, alert_generation_run:,
                     alert_type: create(:alert_type, class_name: AlertPreviousYearHolidayComparisonElectricity),
                     variables: { difference_gbpcurrent: -3,
                                  difference_kwh: -4 })
      create(:alert, school:, alert_generation_run:,
                     alert_type: create(:alert_type, class_name: AlertPreviousHolidayComparisonGas),
                     variables: { difference_gbpcurrent: -5,
                                  difference_kwh: -6 })
      create(:alert, school:, alert_generation_run:,
                     alert_type: create(:alert_type, class_name: AlertPreviousYearHolidayComparisonGas),
                     variables: { difference_gbpcurrent: -7,
                                  difference_kwh: -8 })
      # school with increase that should be ignored
      create(:alert, school: create(:school, school_group: school.school_group), alert_generation_run:,
                     alert_type: create(:alert_type, class_name: AlertPreviousHolidayComparisonElectricity),
                     variables: { difference_gbpcurrent: 1,
                                  difference_kwh: 2 })
      [Comparison::ChangeInElectricityHolidayConsumptionPreviousHoliday,
       Comparison::ChangeInElectricityHolidayConsumptionPreviousYearsHoliday,
       Comparison::ChangeInGasHolidayConsumptionPreviousHoliday,
       Comparison::ChangeInGasHolidayConsumptionPreviousYearsHoliday].map(&:refresh)
    end

    def metric(holiday, unit, value, fuel_type, **)
      { enough_data: true, metric_category: :energy_efficiency, metric_type: :"holiday_#{holiday}", unit:,
        fuel_type:, number_of_schools: 1, value: }
        .merge(**)
    end

    it 'has the right metrics' do
      expect(generator.metrics).to contain_exactly(metric(:previous, :gbp, 1, :electricity),
                                                   metric(:previous, :kwh, 2, :electricity),
                                                   metric(:previous_year, :gbp, 3, :electricity),
                                                   metric(:previous_year, :kwh, 4, :electricity),
                                                   metric(:previous, :gbp, 5, :gas),
                                                   metric(:previous, :kwh, 6, :gas),
                                                   metric(:previous_year, :gbp, 7, :gas),
                                                   metric(:previous_year, :kwh, 8, :gas))
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SchoolGroups::ImpactReport::Generator::PotentialSavings do
  subject(:generator) { described_class.new(school_group, visible_schools) }

  let(:school_group) { create(:school_group) }
  let(:visible_schools) { school_group.assigned_schools.visible }
  let(:schools) { create_list(:school, 3, school_group:) }

  before do
    rating = create(:alert_type_rating, alert_type: create(:alert_type, class_name: AlertOutOfHoursElectricityUsage))
    total_savings = { rating => double(schools:,
                                       average_one_year_saving_gbp: 1200) }
    priority_actions = instance_double(SchoolGroups::PriorityActions, total_savings:)
    allow(SchoolGroups::PriorityActions).to receive(:new).with(schools).and_return(priority_actions)
  end

  describe '#metrics' do
    def metric(metric_type, fuel_type = :electricity, **)
      {
        enough_data: false, metric_category: :potential_savings,
        metric_type:, fuel_type:, number_of_schools: 0, unit: :gbp,
        value: 0
      }.merge(**)
    end

    it 'has the right metrics' do
      expect(generator.metrics).to contain_exactly(
        metric(:out_of_hours, value: 1200, number_of_schools: 3, enough_data: true),
        metric(:baseload),
        metric(:peak),
        metric(:use),
        metric(:heating_down, :gas),
        metric(:heating_early, :gas),
        metric(:heating_off, :gas),
        metric(:insulate_pipes, :gas),
        metric(:out_of_hours, :gas),
        metric(:thermostatic_control, :gas),
        metric(:use, :gas),
        metric(:solar_panels, :solar_pv),
        metric(:heating_off, :storage_heater)
      )
    end
  end
end

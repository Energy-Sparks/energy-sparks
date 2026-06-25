# frozen_string_literal: true

require 'rails_helper'

describe SchoolGroups::ImpactReport::Generator::Targets do
  subject(:generator) { described_class.new(school.school_group, visible_schools) }

  let(:school) { create(:school, :with_school_group) }
  let(:visible_schools) { school.school_group.assigned_schools.visible }

  describe '#metrics' do
    before do
      create(:school_target, :with_monthly_consumption, school:)
      create(:school_target, :with_monthly_consumption, fuel_type: :gas,
                                                        school: create(:school, school_group: school.school_group))
      [Comparison::GasTargets, Comparison::ElectricityTargets].each(&:refresh)
    end

    def metric(**)
      { enough_data: true, metric_category: :energy_efficiency, metric_type: :targets, number_of_schools: 1, value: 1,
        unit: nil }.merge(**)
    end

    it 'has the right metrics' do
      expect(generator.metrics).to contain_exactly(metric(fuel_type: :electricity), metric(fuel_type: :gas))
    end
  end
end

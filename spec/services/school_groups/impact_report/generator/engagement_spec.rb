# frozen_string_literal: true

require 'rails_helper'

describe SchoolGroups::ImpactReport::Generator::Engagement do
  subject(:generator) { described_class.new(school.school_group, visible_schools) }

  let(:school) { create(:school, :with_school_group) }
  let(:visible_schools) { school.school_group.assigned_schools.visible }

  describe '#metrics' do
    subject(:metrics) { generator.metrics.reject { |metric| metric[:value].zero? } }

    def metric(metric_type, **)
      { metric_category: :engagement, metric_type:, number_of_schools: 1, value: 1, enough_data: true, fuel_type: nil,
        unit: nil }
        .merge(**)
    end

    context 'with activities in visible schools within the last 12 months' do
      before do
        create(:activity, school:, happened_on: 6.months.ago)
        create(:activity, school:, happened_on: 13.months.ago)
        create(:activity, school: create(:school, visible: false, school_group: school.school_group),
                          created_at: 1.month.ago)
      end

      it 'counts correctly' do
        expect(metrics).to contain_exactly(metric(:activities), metric(:points, value: 25))
      end
    end

    context 'with intervention observations for visible schools within the last 12 months' do
      before do
        create(:observation, :intervention, school:, at: 3.months.ago)
        create(:observation, :intervention, school:, at: 14.months.ago)
      end

      it 'counts correctly' do
        expect(metrics).to contain_exactly(metric(:actions), metric(:points, value: 30))
      end
    end

    context 'with active targets for visible schools' do
      before do
        travel_to(Date.new(2026, 5, 15))
        target = create(:school_target, school:)
        create(:school_target, school:, start_date: target.start_date - 1.year)
      end

      it 'counts correctly' do
        expect(metrics).to contain_exactly(metric(:targets), metric(:points, value: 10))
      end
    end
  end
end

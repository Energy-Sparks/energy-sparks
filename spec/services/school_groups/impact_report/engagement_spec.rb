# frozen_string_literal: true

require 'rails_helper'

describe SchoolGroups::ImpactReport::Engagement do
  subject(:engagement) { described_class.new(SchoolGroups::ImpactReport.new(school.school_group)) }

  let(:school) { create(:school, :with_school_group) }

  describe '#metrics' do
    subject(:metrics) { engagement.metrics.reject { |metric| metric[:value].zero? } }

    context 'with activities in visible schools within the last 12 months' do
      before do
        create(:activity, school:, happened_on: 6.months.ago)
        create(:activity, school:, happened_on: 13.months.ago)
        create(:activity, school: create(:school, visible: false, school_group: school.school_group),
                          created_at: 1.month.ago)
      end

      it 'counts correctly' do
        expect(metrics).to contain_exactly(
          { enough_data: true, fuel_type: nil, metric_category: :engagement, metric_type: :activities,
            number_of_schools: 1, value: 1 },
          { enough_data: true, fuel_type: nil, metric_category: :engagement, metric_type: :points,
            number_of_schools: 1, value: 25 }
        )
      end
    end

    context 'with intervention observations for visible schools within the last 12 months' do
      before do
        create(:observation, :intervention, school:, at: 3.months.ago)
        create(:observation, :intervention, school:, at: 14.months.ago)
      end

      it 'counts correctly' do
        expect(metrics).to contain_exactly(
          { enough_data: true, fuel_type: nil, metric_category: :engagement, metric_type: :actions,
            number_of_schools: 1, value: 1 },
          { enough_data: true, fuel_type: nil, metric_category: :engagement, metric_type: :points,
            number_of_schools: 1, value: 30 }
        )
      end
    end

    context 'with counts currently active targets for visible schools' do
      before do
        target = create(:school_target, school:)
        create(:school_target, school:, start_date: target.start_date - 1.year)
      end

      it 'counts correctly' do
        expect(metrics).to contain_exactly(
          { enough_data: true, fuel_type: nil, metric_category: :engagement, metric_type: :targets,
            number_of_schools: 1, value: 1 },
          { enough_data: true, fuel_type: nil, metric_category: :engagement, metric_type: :points,
            number_of_schools: 1, value: 10 }
        )
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe SchoolGroups::ImpactReport::Engagement do
  subject(:engagement) { described_class.new(SchoolGroups::ImpactReport.new(school.school_group)) }

  let(:school) { create(:school, :with_school_group) }

  describe '#activities' do
    it 'counts activities in visible schools within the last 12 months' do
      create(:activity, school:, happened_on: 6.months.ago)
      create(:activity, school:, happened_on: 13.months.ago)
      create(:activity, school: create(:school, visible: false, school_group: school.school_group),
                        created_at: 1.month.ago)
      expect(engagement.activities).to eq(1)
    end
  end

  describe '#actions' do
    it 'counts intervention observations for visible schools within the last 12 months' do
      create(:observation, :intervention, school:, at: 3.months.ago)
      create(:observation, :intervention, school:, at: 14.months.ago)
      expect(engagement.actions).to eq(1)
    end
  end

  describe '#points' do
    it 'sums observation points for visible schools within the last 12 months' do
      activity_type = create(:activity_type, score: 1)
      create(:activity, school:, activity_type:, happened_on: 6.months.ago)
      create(:activity, school:, activity_type:, happened_on: 13.months.ago)
      expect(engagement.points).to eq(1)
    end
  end

  describe '#targets' do
    it 'counts currently active targets for visible schools' do
      target = create(:school_target, school:)
      create(:school_target, school:, start_date: target.start_date - 1.year)
      expect(engagement.targets).to eq(1)
    end
  end
end

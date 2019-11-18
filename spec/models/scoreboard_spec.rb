require 'rails_helper'

describe Scoreboard, :scoreboards, type: :model do

  let!(:scoreboard) { create :scoreboard }

  subject { scoreboard }

  describe '#safe_destroy' do

    it 'does not let you delete if there is an associated group' do
      create(:school_group, scoreboard: subject)
      expect{
        subject.safe_destroy
      }.to raise_error(
        EnergySparks::SafeDestroyError, 'Scoreboard has associated groups'
      ).and(not_change{ Scoreboard.count })
    end

    it 'lets you delete if there are no groups' do
      expect{
        subject.safe_destroy
      }.to change{Scoreboard.count}.from(1).to(0)
    end
  end

  describe '#scored_schools' do

    let!(:group)    { create(:school_group, scoreboard: subject) }
    let!(:template_calendar) { create(:template_calendar)}
    let!(:schools)  { (1..5).collect { |n| create :school, :with_points, score_points: 6 - n, school_group: group, activities_happened_on: 6.months.ago, template_calendar: template_calendar}}

    it 'returns schools in points order' do
      expect(subject.scored_schools.map(&:id)).to eq(schools.map(&:id))
    end

    context 'with academic years' do
      let(:this_academic_year) { create(:academic_year, start_date: 12.months.ago, end_date: Time.zone.today, calendar: template_calendar) }
      let(:last_academic_year) { create(:academic_year, start_date: 24.months.ago, end_date: 12.months.ago, calendar: template_calendar) }

      it 'accepts an academic year and restricts' do
        expect(subject.scored_schools(academic_year: this_academic_year).map(&:sum_points).any?(&:zero?)).to eq(false)
        expect(subject.scored_schools(academic_year: last_academic_year).map(&:sum_points).all?(&:nil?)).to eq(true)
      end

      it 'also defaults to the current academic year' do
        create :school, :with_points, score_points: 6, school_group: group, activities_happened_on: 18.months.ago
        expect(subject.scored_schools(academic_year: last_academic_year).to_a.size).to be 6
        expect(subject.scored_schools(academic_year: this_academic_year).to_a.size).to be 6
        expect(subject.scored_schools.to_a.size).to be 6
      end
    end

  end
end

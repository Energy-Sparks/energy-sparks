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
    let!(:schools)  { (1..5).collect { |n| create :school, :with_points, score_points: 6 - n, school_group: group, activities_happened_on: 6.months.ago}}

    it 'returns schools in points order' do
      expect(subject.scored_schools.map(&:id)).to eq(schools.map(&:id))
    end

    it 'accepts an academic year and restricts' do
      academic_year_1 = create(:academic_year, start_date: 12.months.ago, end_date: Time.zone.today, calendar_area: scoreboard.calendar_area)
      academic_year_2 = create(:academic_year, start_date: 24.months.ago, end_date: 12.months.ago, calendar_area: scoreboard.calendar_area)
      expect(subject.scored_schools(academic_year: academic_year_1).map(&:sum_points).any?(&:zero?)).to eq(false)
      expect(subject.scored_schools(academic_year: academic_year_2).map(&:sum_points).all?(&:nil?)).to eq(true)
    end

    it 'returns the position of a school' do
      (0..4).each do |n|
        expect(subject.position(schools[n])).to eq n
      end
    end
  end

end

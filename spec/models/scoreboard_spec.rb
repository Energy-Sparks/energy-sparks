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
    let!(:schools)  { (1..5).collect { |n| create :school, :with_points, score_points: 6 - n, school_group: group }}

    it 'returns schools in points order' do
      expect(subject.scored_schools.map(&:id)).to eq(schools.map(&:id))
    end

    it 'returns the position of a school' do
      (0..4).each do |n|
        expect(subject.position(schools[n])).to eq n
      end
    end
  end

  describe 'surrounding_schools' do
    let(:group)    { create(:school_group, scoreboard: subject) }

    let!(:school_1){ create :school, :with_points, score_points: 10, school_group: group }
    let!(:school_2){ create :school, :with_points, score_points: 20, school_group: group }
    let!(:school_3){ create :school, :with_points, score_points: 30, school_group: group }
    let!(:school_4){ create :school, :with_points, score_points: 40, school_group: group }
    let!(:school_5){ create :school, :with_points, score_points: 50, school_group: group }

    it 'returns the schools either side if you fall within the table' do
      surrounding_schools = subject.surrounding_schools(school_3)
      expect(surrounding_schools[0]).to eq(school_4)
      expect(surrounding_schools[1]).to eq(school_3)
      expect(surrounding_schools[2]).to eq(school_2)
    end

    it 'returns the two next lower schools if you are 1st' do
      surrounding_schools = subject.surrounding_schools(school_5)
      expect(surrounding_schools[0]).to eq(school_5)
      expect(surrounding_schools[1]).to eq(school_4)
      expect(surrounding_schools[2]).to eq(school_3)
    end

    it 'returns the two next higher schools if you are last' do
      surrounding_schools = subject.surrounding_schools(school_1)
      expect(surrounding_schools[0]).to eq(school_3)
      expect(surrounding_schools[1]).to eq(school_2)
      expect(surrounding_schools[2]).to eq(school_1)
    end

    it 'returns both schools if there are only two schools' do
      new_group = create(:school_group, scoreboard: scoreboard)
      school_1.update!(school_group: new_group)
      school_2.update!(school_group: new_group)
      group.update!(scoreboard: nil)

      surrounding_schools = subject.surrounding_schools(school_1)
      expect(surrounding_schools[0]).to eq(school_2)
      expect(surrounding_schools[1]).to eq(school_1)
      expect(surrounding_schools.size).to eq(2)
    end

    it 'returns only the current school if there are no other schools' do
      new_group = create(:school_group, scoreboard: scoreboard)
      school_1.update!(school_group: new_group)
      group.update!(scoreboard: nil)

      surrounding_schools = subject.surrounding_schools(school_1)
      expect(surrounding_schools[0]).to eq(school_1)
      expect(surrounding_schools.size).to eq(1)
    end

  end
end

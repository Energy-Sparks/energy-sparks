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
end

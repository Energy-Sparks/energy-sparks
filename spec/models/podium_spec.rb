
require 'rails_helper'

describe Podium do

  let!(:scoreboard) { create :scoreboard }

  let!(:school_0){ create :school, scoreboard: scoreboard }
  let!(:school_1){ create :school, :with_points, score_points: 1, scoreboard: scoreboard }
  let!(:school_2){ create :school, :with_points, score_points: 2, scoreboard: scoreboard }
  let!(:school_3){ create :school, :with_points, score_points: 3, scoreboard: scoreboard }
  let!(:school_4){ create :school, :with_points, score_points: 4, scoreboard: scoreboard }
  let!(:school_5){ create :school, :with_points, score_points: 5, scoreboard: scoreboard }

  it 'includes the calculated points' do
    podium = Podium.create(scoreboard: scoreboard, school: school_3)
    expect(podium.low_to_high.map(&:points)).to eq([2, 3, 4])
  end

  it 'includes the normalised points' do
    podium = Podium.create(scoreboard: scoreboard, school: school_3)
    expect(podium.low_to_high.map(&:normalised_points).any?(&:nil?)).to eq(false)
  end

  it 'includes the recent points' do
    podium = Podium.create(scoreboard: scoreboard, school: school_3, recent_boundary: 2.months.ago)
    expect(podium.low_to_high.map(&:recent_points)).to eq([2,3,4])

    podium = Podium.create(scoreboard: scoreboard, school: school_3, recent_boundary: 2.days.ago)
    expect(podium.low_to_high.map(&:recent_points)).to eq([0,0,0])
  end

  it 'includes the ordinal high to low position as an integer' do
    podium = Podium.create(scoreboard: scoreboard, school: school_5)
    expect(podium.high_to_low.map(&:position)).to eq([1, 2, 3])
  end

  describe 'when the school has no points' do
    it 'does not have a position for the school' do
      podium = Podium.create(scoreboard: scoreboard, school: school_0)
      expect(podium.includes_school?).to eq(false)
    end

    it 'populates first second and third with the lowest scoring schools' do
      podium = Podium.create(scoreboard: scoreboard, school: school_0)
      expect(podium.high_to_low[0].school).to eq(school_3)
      expect(podium.high_to_low[1].school).to eq(school_2)
      expect(podium.high_to_low[2].school).to eq(school_1)
    end
  end

  context 'when the school scores in the middle of the scoreboard' do
    it 'returns the schools either side if you fall within the table' do
      podium = Podium.create(scoreboard: scoreboard, school: school_3)
      expect(podium.high_to_low[0].school).to eq(school_4)
      expect(podium.high_to_low[1].school).to eq(school_3)
      expect(podium.high_to_low[2].school).to eq(school_2)
    end
  end

  context 'when you are first on the scoreboard' do
    it 'returns the 2 schools below you in lowest and middle scoring positions' do
      podium = Podium.create(scoreboard: scoreboard, school: school_5)
      expect(podium.high_to_low[0].school).to eq(school_5)
      expect(podium.high_to_low[1].school).to eq(school_4)
      expect(podium.high_to_low[2].school).to eq(school_3)
    end
  end

  context 'if you are last on the scoreboard' do
    it 'returns the two next higher schools' do
      podium = Podium.create(scoreboard: scoreboard, school: school_1)
      expect(podium.high_to_low[0].school).to eq(school_3)
      expect(podium.high_to_low[1].school).to eq(school_2)
      expect(podium.high_to_low[2].school).to eq(school_1)
    end
  end

  context 'when there are only two schools' do
    it 'returns both schools' do
      new_scoreboard = create(:scoreboard)
      school_1.update!(scoreboard: new_scoreboard)
      school_2.update!(scoreboard: new_scoreboard)

      podium = Podium.create(scoreboard: new_scoreboard, school: school_1)
      expect(podium.high_to_low[0].school).to eq(school_2)
      expect(podium.high_to_low[1].school).to eq(school_1)
      expect(podium.high_to_low.size).to eq(2)
    end
  end

  context 'when there is only one school' do
    it 'returns only the current school' do
      new_scoreboard = create(:scoreboard)
      school_1.update!(scoreboard: new_scoreboard)

      podium = Podium.create(scoreboard: new_scoreboard, school: school_1)
      expect(podium.high_to_low[0].school).to eq(school_1)
      expect(podium.high_to_low.size).to eq(1)
    end
  end

end

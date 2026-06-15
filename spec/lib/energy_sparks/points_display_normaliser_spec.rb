require 'energy_sparks/points_display_normaliser'

describe EnergySparks::PointsDisplayNormaliser do
  let(:points) {}

  subject(:normalised_points) { EnergySparks::PointsDisplayNormaliser.normalise(points) }

  context 'when points is empty' do
    let(:points) { [] }

    it 'returns an empty array' do
      expect(normalised_points).to be_empty
    end
  end

  context 'when all points are the same' do
    let(:points) { [20, 20, 20] }

    it 'returns 0.5s' do
      expect(normalised_points).to eq([0.5, 0.5, 0.5])
    end
  end

  context 'when there is a nil point' do
    let(:points) { [0, 4, 10] }

    it { expect(normalised_points).to eq([0, 0.4, 1]) }
  end

  it 'equally spaces values if the values are a distance apart proportinal to their size' do
    factor_1 = EnergySparks::PointsDisplayNormaliser.normalise([1, 2, 3])
    factor_10 = EnergySparks::PointsDisplayNormaliser.normalise([10, 20, 30])
    factor_100 = EnergySparks::PointsDisplayNormaliser.normalise([100, 200, 300])

    expect(factor_1).to eq(factor_10)
    expect(factor_10).to eq(factor_100)
  end
end

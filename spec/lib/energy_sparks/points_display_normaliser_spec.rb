require 'energy_sparks/points_display_normaliser'

describe EnergySparks::PointsDisplayNormaliser do
  it 'returns and empty array when no points are passed in' do
    expect(EnergySparks::PointsDisplayNormaliser.normalise([])).to eq([])
  end

  it 'returns 0.5s if all the points are the same' do
    expect(EnergySparks::PointsDisplayNormaliser.normalise([20, 20, 20])).to eq([0.5, 0.5, 0.5])
  end

  it 'equally spaces values if the values are a distance apart proportinal to their size' do
    factor_1 = EnergySparks::PointsDisplayNormaliser.normalise([1, 2, 3])
    factor_10 = EnergySparks::PointsDisplayNormaliser.normalise([10, 20, 30])
    factor_100 = EnergySparks::PointsDisplayNormaliser.normalise([100, 200, 300])

    expect(factor_1).to eq(factor_10)
    expect(factor_10).to eq(factor_100)
  end
end

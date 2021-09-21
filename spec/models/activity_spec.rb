require 'rails_helper'

describe 'Activity' do

  let!(:activity_1) { create(:activity, happened_on: '2020-02-01') }
  let!(:activity_2) { create(:activity, happened_on: '2020-03-01') }
  let!(:activity_3) { create(:activity, happened_on: '2020-04-01') }

  it '#between' do
    expect( Activity.between('2020-01-01', '2020-01-31') ).to match_array([])
    expect( Activity.between('2020-01-01', '2020-02-01') ).to match_array([activity_1])
    expect( Activity.between('2020-01-01', '2020-03-31') ).to match_array([activity_1, activity_2])
    expect( Activity.between('2020-01-01', '2020-04-01') ).to match_array([activity_1, activity_2, activity_3])
  end
end

require 'rails_helper'

describe AmrMeterCollection do

  let(:school){ create(:school, :with_school_group, :with_calendar) }
  let(:seven) { TimeOfDay.new(7, 00) }
  let(:four) { TimeOfDay.new(4, 00) }
  let!(:monday_opening) { SchoolTime.create!(school: school, day: :monday, opening_time: 0650, closing_time: 1520) }

  before(:each) do
    allow_any_instance_of(ScheduleDataManagerService).to receive(:process_feed_data)
    @amr_meter_collection = AmrMeterCollection.new(school)
  end

  it 'should know school opening times' do
    monday_date = Date.parse('2019-01-28')
    expect(@amr_meter_collection.is_school_usually_open?(monday_date, seven)).to be true
  end

  it 'should return false if it is not a day in the list' do
    sunday_date = Date.parse('2019-01-27')
    expect(@amr_meter_collection.is_school_usually_open?(sunday_date, seven)).to be false
  end

  it 'should return false if it is a day in the list, but out of ours' do
    monday_date = Date.parse('2019-01-27')
    expect(@amr_meter_collection.is_school_usually_open?(monday_date, four)).to be false
  end
end

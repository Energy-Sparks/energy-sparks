require 'rails_helper'

describe ActivityCreator do

  let(:activity_category){ create :activity_category }
  let(:activity_type){ create :activity_type, activity_category: activity_category, score: 50}

  it 'sets the activity category if the activity type has one' do
    activity = build(:activity, activity_type: activity_type, activity_category: nil)
    ActivityCreator.new(activity).process
    expect(activity.activity_category).to eq(activity_category)
  end

  it 'sets the points from the type' do
    activity = build(:activity, activity_type: activity_type)
    ActivityCreator.new(activity).process
    expect(activity.points).to eq(50)
  end

  it 'saves the activity' do
    activity = build(:activity, activity_type: activity_type)
    ActivityCreator.new(activity).process
    expect(activity).to be_persisted
  end

end

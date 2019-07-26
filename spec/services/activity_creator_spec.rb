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

  context 'with a programme' do
    let!(:school)         { create :school }
    let(:programme_type)  { create :programme_type_with_activity_types }
    let(:activity_type)   { programme_type.activity_types.first }
    let!(:programme)      { Programmes::Creator.new(school, programme_type).create }

    it 'completes the activity in the programme' do
      activity = build(:activity, activity_type: activity_type, school: school)
      ActivityCreator.new(activity).process

      expect(programme.programme_activities.find_by(activity_type: activity_type).activity_id).to be activity.id
    end

    it "completes the programme if all the activities are completed" do
      programme.programme_activities.each do |programme_activity|
        activity = build(:activity, activity_type: programme_activity.activity_type, school: school)
        ActivityCreator.new(activity).process
      end
      programme.reload
      expect(programme.completed?).to eq(true)
    end

    it "doesn't complete if the programme isn't active" do
      programme_type.update(active: false)
      activity = build(:activity, activity_type: activity_type, school: school)
      ActivityCreator.new(activity).process

      expect(programme.programme_activities.find_by(activity_type: activity_type).activity_id).to be nil
    end
  end
end

require 'rails_helper'

describe ActivityCreator do

  let(:activity_category){ create :activity_category }
  let(:activity_type){ create :activity_type, activity_category: activity_category, score: 50}

  it 'sets the activity category if the activity type has one' do
    activity = build(:activity, activity_type: activity_type, activity_category: nil)
    ActivityCreator.new(activity).process
    expect(activity.activity_category).to eq(activity_category)
  end

  it 'saves the activity' do
    activity = build(:activity, activity_type: activity_type)
    ActivityCreator.new(activity).process
    expect(activity).to be_persisted
  end

  it 'creates an observation for the activity with the points' do
    activity = build(:activity, activity_type: activity_type)
    ActivityCreator.new(activity).process
    observation = Observation.find_by!(activity_id: activity.id)
    expect(observation.observation_type).to eq("activity")
    expect(observation.school).to eq(activity.school)
    expect(observation.at).to eq(activity.happened_on)
    expect(observation.points).to eq(50)
  end


  it 'scores no points for a previous academic year' do
    activity = build(:activity, activity_type: activity_type, happened_on: 3.years.ago)
    ActivityCreator.new(activity).process
    observation = Observation.find_by!(activity_id: activity.id)
    expect(observation.points).to eq(nil)
  end

  context 'with a programme' do
    let!(:school)         { create :school }
    let(:programme_type)  { create :programme_type_with_activity_types }
    let(:activity_type)   { programme_type.activity_types.first }
    let!(:programme)      { Programmes::Creator.new(school, programme_type).create }

    it 'completes the activity in the programme' do
      activity = build(:activity, activity_type: activity_type, school: school)
      ActivityCreator.new(activity).process

      expect(programme.programme_activities.count).to eql 1
      expect(programme.programme_activities.find_by(activity_type: activity_type).activity_id).to be activity.id
    end

    it "completes the programme if all the activities are completed" do
      programme_type.activity_types.each do |activity_type|
        activity = build(:activity, activity_type: activity_type, school: school)
        ActivityCreator.new(activity).process
      end
      programme.reload
      expect(programme.completed?).to eq(true)
    end

    it "doesn't add activity in programme if the programme isn't active" do
      programme_type.update(active: false)
      activity = build(:activity, activity_type: activity_type, school: school)
      ActivityCreator.new(activity).process

      expect(programme.programme_activities.count).to eql 0
    end
  end
end

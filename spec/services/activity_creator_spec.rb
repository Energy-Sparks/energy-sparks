# frozen_string_literal: true

require 'rails_helper'

describe ActivityCreator do
  let(:activity_category) { create(:activity_category) }
  let(:activity_type) { create(:activity_type, activity_category:, score: 50) }
  let(:user) { create(:user) }

  it 'sets the activity category if the activity type has one' do
    activity = build(:activity, activity_type:, activity_category: nil)
    described_class.new(activity, user).process
    expect(activity.activity_category).to eq(activity_category)
  end

  it 'saves the activity' do
    activity = build(:activity, activity_type:)
    described_class.new(activity, user).process
    expect(activity).to be_persisted
  end

  it 'creates an observation for the activity with the points' do
    activity = build(:activity, activity_type:)
    described_class.new(activity, user).process
    observation = Observation.find_by!(activity_id: activity.id)
    expect(observation.observation_type).to eq('activity')
    expect(observation.school).to eq(activity.school)
    expect(observation.at).to eq(activity.happened_on)
    expect(observation.points).to eq(50)
    expect(observation.created_by).to eq(user)
  end

  it 'scores no points for a previous academic year' do
    activity = build(:activity, activity_type:, happened_on: 3.years.ago)
    described_class.new(activity, user).process
    observation = Observation.find_by!(activity_id: activity.id)
    expect(observation.points).to be_zero
  end

  context 'with a programme' do
    let!(:school)           { create(:school) }
    let!(:school_2)         { create(:school) }
    let(:programme_type)    { create(:programme_type_with_activity_types) }
    let(:programme_type_2)  { create(:programme_type_with_activity_types) }
    let(:activity_type)     { programme_type.activity_types.first }
    let(:activity_type_2)   { programme_type_2.activity_types.first }
    let(:activity_type_3)   { create(:activity_type) }
    let(:activity_2)        { create(:activity, activity_type: activity_type_2, school: school_1) }
    let!(:programme)        { Programmes::Creator.new(school, programme_type).create }
    let!(:programme_2)      { Programmes::Creator.new(school, programme_type_2).create }

    it 'a school is recording an activity that is in a programme' do
      expect(activity_type.programme_types).to eq([programme_type])
      expect(school.programmes).not_to include([programme_type])
      activity = build(:activity, activity_type:, school:)
      expect { described_class.new(activity, user).process }.to change {
        programme.programme_activities.count
      }.by(1).and change(Observation, :count).by(1).and change(activity, :updated_at)
      expect(programme.programme_activities.find_by(activity_type:).activity_id).to be activity.id
    end

    it "a school is recording an activity that isn't in a programme" do
      expect(activity_type_3.programme_types).to eq([])
      activity = build(:activity, activity_type: activity_type_3, school:)

      expect { described_class.new(activity, user).process }.to change {
        programme.programme_activities.count
      }.by(0).and change(Observation, :count).by(1).and change(activity, :updated_at)
    end

    it "a school is recording an activity that is in a programme, but not one they're part of" do
      expect(activity_type_2.programme_types).to eq([programme_type_2])
      expect(school.programmes).not_to include([programme_type_2])

      activity = build(:activity, activity_type: activity_type_2, school:)
      expect { described_class.new(activity, user).process }.to change {
        programme.programme_activities.count
      }.by(0).and change(Observation, :count).by(1).and change(activity, :updated_at)
    end

    it 'completes the programme if all the activities are completed' do
      programme_type.activity_types.each do |activity_type|
        activity = build(:activity, activity_type:, school:)
        described_class.new(activity, user).process
      end
      programme.reload
      expect(programme.completed?).to be(true)
    end

    context 'when extra activities are recorded, which are no longer in the programme' do
      before do
        extra_activity_type = create(:activity_type)
        extra_activity = create(:activity, activity_type: extra_activity_type)
        programme.programme_activities.create(activity_type: extra_activity_type, activity: extra_activity)
      end

      it 'still completes the programme when all activities are completed' do
        programme_type.activity_types.each do |activity_type|
          activity = build(:activity, activity_type:, school:)
          described_class.new(activity, user).process
        end
        programme.reload
        expect(programme.completed?).to be(true)
      end
    end

    it "doesn't add activity in programme if the programme isn't active" do
      programme_type.update(active: false)
      activity = build(:activity, activity_type:, school:)
      described_class.new(activity, user).process

      expect(programme.programme_activities.count).to be 0
    end

    it 'adds activity even if previous programme activity existed' do
      programme.programme_activities.create(activity_type:, activity: create(:activity))
      activity = build(:activity, activity_type:, school:)
      described_class.new(activity, user).process

      programme.reload

      expect(programme.activities.count).to eq 1
      expect(programme.activities).to include(activity)
    end
  end

  context 'creates an completed audit observation' do
    let(:activity_category) { create(:activity_category, name: 'Zebras') }
    let(:school) { create(:school) }

    it 'creates an observation for the activity with the points' do
      audit = create(:audit, :with_activity_and_intervention_types, school:)
      audit.activity_types[0...-1].each do |activity_type|
        activity = Activity.new(happened_on: audit.created_at, school: audit.school,
                                activity_type_id: activity_type.id, activity_category:)
        described_class.new(activity, user).process
      end
      expect(Observation.audit_activities_completed.count).to eq(0)

      expect do
        activity = Activity.new(school:, happened_on: Time.zone.now, activity_type: audit.activity_types.last)
        described_class.new(activity, user).process
      end.to change { Observation.audit_activities_completed.count }.by(1)
    end
  end
end

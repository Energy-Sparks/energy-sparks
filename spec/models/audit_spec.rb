require 'rails_helper'

describe Audit do

  let(:school) { create :school }
  let(:title) { 'Test Audit' }
  let(:activity_type) { create :activity_type }
  let(:intervention_type) { create :intervention_type }

  let(:audit) { create(:audit, school: school, title: title) }

  context 'when no title' do
    let(:title) { '' }
    it 'fails validation' do
      expect {
        audit.save!
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#with_activity_types' do
    it 'returns only audits with assciated activity types' do
      audit_1 = create(:audit)
      audit_1.audit_activity_types.create(activity_type: activity_type)
      audit_2 = create(:audit)
      audit_2.audit_activity_types.create(activity_type: activity_type)
      audit_3 = create(:audit)
      expect(Audit.all).to match_array([audit_1, audit_2, audit_3])
      expect(Audit.with_activity_types).to match_array([audit_1, audit_2])
    end
  end

  it 'has collection of activity types with notes' do
    audit.audit_activity_types.create(activity_type: activity_type, notes: 'some activity type')
    expect( audit.activity_types ).to eq([activity_type])
    expect( audit.audit_activity_types.last.notes ).to eq('some activity type')
  end

  it 'has collection of intervention types with notes' do
    audit.audit_intervention_types.create(intervention_type: intervention_type, notes: 'some intervention type')
    expect( audit.intervention_types ).to eq([intervention_type])
    expect( audit.audit_intervention_types.last.notes ).to eq('some intervention type')
  end

  it 'allows duplicate activity types and intervention types' do
    audit = create(:audit)
    audit.audit_activity_types.create(activity_type: activity_type)
    audit.audit_activity_types.create(activity_type: activity_type)
    audit.audit_intervention_types.create(intervention_type: intervention_type)
    audit.audit_intervention_types.create(intervention_type: intervention_type)
    expect(audit.activity_types.count).to eq(2)
    expect(audit.activity_types.uniq.count).to eq(1)
    expect(audit.intervention_types.count).to eq(2)
    expect(audit.intervention_types.uniq.count).to eq(1)
  end

  context 'when using factory' do
    it 'creates audit with multiple activities and interventions' do
      audit = create(:audit, :with_activity_and_intervention_types)
      expect(audit.activity_types.count).to eq(3)
      expect(audit.intervention_types.count).to eq(3)
    end
  end

  describe '#activities_completed?' do
    let(:activity_category) { create(:activity_category, name: 'Zebras') }

    it 'returns true if the associated school has completed all activites that corresponds with the activity types listed in the audit and logged after the audit was created' do
      audit = create(:audit, :with_activity_and_intervention_types)
      expect(audit.activity_types.count).to eq(3)
      expect(audit.activities_completed?).to eq(false)
      audit.activity_types.each do |activity_type|
        Activity.create!(happened_on: audit.created_at, school: audit.school, activity_type_id: activity_type.id, activity_category: activity_category)
      end
      expect(audit.school.activities.count).to eq(3)
      expect(audit.activities_completed?).to eq(true)
    end

    it 'returns false if the associated school has completed all activites that corresponds with the activity types listed in the audit but logged before the audit was created' do
      audit = create(:audit, :with_activity_and_intervention_types)
      expect(audit.activity_types.count).to eq(3)
      expect(audit.school.activities.count).to eq(0)
      expect(audit.activities_completed?).to eq(false)
      audit.activity_types.each do |activity_type|
        Activity.create!(happened_on: '2022-06-24', school: audit.school, activity_type_id: activity_type.id, activity_category: activity_category)
      end
      expect(audit.school.activities.count).to eq(3)
      expect(audit.activities_completed?).to eq(false)
    end

    it 'returns false if the associated school has not completed all activites that corresponds with the activity types listed in the audit' do
      audit = create(:audit, :with_activity_and_intervention_types)
      expect(audit.activity_types.count).to eq(3)
      expect(audit.school.activities.count).to eq(0)
      expect(audit.activities_completed?).to eq(false)
      audit.activity_types[0...-1].each do |activity_type|
        Activity.create!(happened_on: audit.created_at, school: audit.school, activity_type_id: activity_type.id, activity_category: activity_category)
      end
      expect(audit.school.activities.count).to eq(2)
      expect(audit.activities_completed?).to eq(false)
    end
  end

  describe 'create_activities_completed_observation!' do
    let(:activity_category) { create(:activity_category, name: 'Zebras') }

    it 'creates *ONLY ONE* observation for the audit with the site setting points when all activities are completed' do
      audit = create(:audit, :with_activity_and_intervention_types)
      expect(audit.activity_types.count).to eq(3)
      expect(audit.school.activities.count).to eq(0)
      expect { audit.create_activities_completed_observation! }.to change { Observation.audit_activities_completed.count }.by(0)
      audit.activity_types.each do |activity_type|
        Activity.create!(happened_on: audit.created_at + 12.months, school: audit.school, activity_type_id: activity_type.id, activity_category: activity_category)
      end
      expect { audit.create_activities_completed_observation! }.to change { Observation.audit_activities_completed.count }.by(1)
      expect { audit.create_activities_completed_observation! }.to change { Observation.audit_activities_completed.count }.by(0)
    end

    it 'does not create an observation for the audit with the site setting points when all activities are completed but are outside of 12 months of the audit creation date' do
      audit = create(:audit, :with_activity_and_intervention_types)
      expect(audit.activity_types.count).to eq(3)
      expect(audit.school.activities.count).to eq(0)
      expect { audit.create_activities_completed_observation! }.to change { Observation.audit_activities_completed.count }.by(0)
      audit.activity_types.each do |activity_type|
        Activity.create!(happened_on: audit.created_at + 13.months, school: audit.school, activity_type_id: activity_type.id, activity_category: activity_category)
      end
      expect { audit.create_activities_completed_observation! }.to change { Observation.audit_activities_completed.count }.by(0)
    end
  end
end

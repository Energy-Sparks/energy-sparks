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
      expect do
        audit.save!
      end.to raise_error(ActiveRecord::RecordInvalid)
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
    expect(audit.activity_types).to eq([activity_type])
    expect(audit.audit_activity_types.last.notes).to eq('some activity type')
  end

  it 'has collection of intervention types with notes' do
    audit.audit_intervention_types.create(intervention_type: intervention_type, notes: 'some intervention type')
    expect(audit.intervention_types).to eq([intervention_type])
    expect(audit.audit_intervention_types.last.notes).to eq('some intervention type')
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
    let(:audit) { create(:audit, :with_activity_and_intervention_types) }

    context 'when no activites are completed' do
      it { expect(audit.activities_completed?).to be(false) }
    end

    context 'when all audit activities are completed' do
      let(:completed_time) { audit.created_at }

      before do
        audit.activity_types.each do |activity_type|
          Activity.create!(happened_on: completed_time, school: audit.school, activity_type_id: activity_type.id, activity_category: activity_category)
        end
      end

      it { expect(audit.school.activities.count).to eq(3) }

      context 'when logged after audit was created' do
        let(:completed_time) { audit.created_at }

        it { expect(audit.activities_completed?).to eq(true) }
      end

      context 'when logged before audit was created' do
        let(:completed_time) { '2022-06-24' }

        it { expect(audit.activities_completed?).to eq(false) }
      end
    end

    context 'when one activity is logged before the audit was created' do
      before do
        audit.activity_types.each_with_index do |activity_type, i|
          completed_time = i == 0 ? '2022-06-24' : audit.created_at
          Activity.create!(happened_on: completed_time, school: audit.school, activity_type_id: activity_type.id, activity_category: activity_category)
        end
      end

      it { expect(audit.school.activities.count).to eq(3) }
      it { expect(audit.activities_completed?).to eq(false) }
    end

    context 'when not all activities are complete' do
      before do
        audit.activity_types[0...-1].each do |activity_type|
          Activity.create!(happened_on: audit.created_at, school: audit.school, activity_type_id: activity_type.id, activity_category: activity_category)
        end
      end

      it { expect(audit.school.activities.count).to eq(2) }
      it { expect(audit.activities_completed?).to eq(false) }
    end
  end

  describe 'create_activities_completed_observation!' do
    let(:activity_category) { create(:activity_category, name: 'Zebras') }

    context 'with 3 activities, non complete' do
      let(:audit) { create(:audit, :with_activity_and_intervention_types) }

      it { expect(audit.activity_types.count).to eq(3) }

      it 'has no completed activities' do
        expect(audit.school.activities.count).to eq(0)
      end

      it "doesn't add observation" do
        expect { audit.create_activities_completed_observation! }.to change { audit.observations.audit_activities_completed.count }.by(0)
      end

      context 'when all activities are completed' do
        let(:completed_timeframe) { 12.months }

        before do
          audit.activity_types.each do |activity_type|
            Activity.create!(happened_on: audit.created_at + completed_timeframe, school: audit.school, activity_type_id: activity_type.id, activity_category: activity_category)
          end
          audit.create_activities_completed_observation!
        end

        context 'when activities are completed inside of 12 months of the audit creation date' do
          it 'adds observation' do
            expect(audit.observations.audit_activities_completed.count).to be(1)
          end

          it "doesn't add a second observation" do
            audit.create_activities_completed_observation!
            expect(audit.observations.audit_activities_completed.count).to be(1)
          end
        end

        context 'when activities are completed outside of 12 months of the audit creation date' do
          let(:completed_timeframe) { 13.months }

          it "doesn't add observation" do
            expect(audit.observations.audit_activities_completed.count).to be(0)
          end
        end
      end
    end
  end
end

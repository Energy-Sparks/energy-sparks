require 'rails_helper'

describe Audit do

  let(:school) { create :school }
  let(:title) { 'Test Audit' }
  let(:activity_type) { create :activity_type }
  let(:intervention_type) { create :intervention_type }

  let(:audit) { Audit.create!(school: school, title: title) }

  context 'when no title' do
    let(:title) { '' }
    it 'fails validation' do
      expect {
        audit.save!
      }.to raise_error(ActiveRecord::RecordInvalid)
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

  context 'when using factory' do
    it 'factory has multiple activities and interventions' do
      audit = create(:audit, :with_activity_and_intervention_types)
      expect(audit.activity_types.count).to eq(3)
      expect(audit.intervention_types.count).to eq(3)
    end
  end
end

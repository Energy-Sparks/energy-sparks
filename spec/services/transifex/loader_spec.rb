require 'rails_helper'

describe Transifex::Loader, type: :service do

  let(:service)                  { Transifex::Loader.new }

  it 'creates a transifex load record' do
    expect{ service.perform }.to change(TransifexLoad, :count).by(1)
  end

  context 'when there are errors' do
    let!(:activity_category)        { create(:activity_category) }
    let!(:activity_type)        { create(:activity_type, active: true, activity_category: activity_category) }

    before(:each) do
      allow_any_instance_of(Transifex::Synchroniser).to receive(:pull).and_raise("Sync error")
    end
    it 'logs errors in the database' do
      expect{ service.perform }.to change(TransifexLoadError, :count).by(2)
      expect(TransifexLoadError.first.record_type).to eq("ActivityType")
      expect(TransifexLoadError.first.record_id).to eq activity_type.id
      expect(TransifexLoadError.first.error).to eq("Sync error")
    end
    it 'logs errors in Rollbar' do
      expect(Rollbar).to receive(:error).with(an_instance_of(RuntimeError), job: :transifex_load, record_type: "ActivityType", record_id: activity_type.id)
      expect(Rollbar).to receive(:error).with(an_instance_of(RuntimeError), job: :transifex_load, record_type: "ActivityCategory", record_id: activity_category.id)
      service.perform
    end
  end

  context 'when there are no errors' do
    let!(:activity_category)        { create(:activity_category) }
    let!(:intervention_type_group)  { create(:intervention_type_group) }

    let!(:activity_type)        { create(:activity_type, active: true, activity_category: activity_category) }
    let!(:activity_type2)        { create(:activity_type, active: false, activity_category: activity_category) }

    let!(:intervention_type)    { create(:intervention_type, active: true, intervention_type_group: intervention_type_group) }
    let!(:intervention_type2)    { create(:intervention_type, active: false, intervention_type_group: intervention_type_group) }
    let!(:help_page)            { create(:help_page) }
    let!(:case_study)           { create(:case_study) }

    let!(:programme_type)           { create(:programme_type) }
    let!(:programme_type2)           { create(:programme_type, active: false) }

    before(:each) do
      allow_any_instance_of(Transifex::Synchroniser).to receive(:pull).and_return(true)
      allow_any_instance_of(Transifex::Synchroniser).to receive(:push).and_return(true)
      service.perform
    end

    it 'updates the pull count' do
      expect(TransifexLoad.first.pulled).to eq 7
    end

    it 'updates the push count' do
      expect(TransifexLoad.first.pushed).to eq 7
    end
  end

end

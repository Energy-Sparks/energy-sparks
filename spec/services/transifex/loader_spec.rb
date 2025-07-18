require 'rails_helper'

describe Transifex::Loader, type: :service do
  let(:logger)      { double(info: true) }
  let(:locale)      { :cy }
  let(:full_sync)   { true }
  let(:service)     { Transifex::Loader.new(locale, logger, full_sync) }

  around do |example|
    ClimateControl.modify FEATURE_FLAG_SYNC_ADVICE_PAGE_TRANSLATIONS: 'false' do
      example.run
    end
  end

  it 'creates a transifex load record' do
    expect { service.perform }.to change(TransifexLoad, :count).by(1)
  end

  context 'when configured to only pull' do
    let!(:activity_category)  { create(:activity_category) }
    let!(:activity_type)      { create(:activity_type, active: true, activity_category: activity_category) }
    let(:full_sync) { false }

    before do
      expect_any_instance_of(Transifex::Synchroniser).not_to receive(:push)
      allow_any_instance_of(Transifex::Synchroniser).to receive(:pull).and_return(true)
    end

    it 'does pull but not push' do
      service.perform
    end
  end

  context 'when there are errors' do
    let!(:activity_category)  { create(:activity_category) }
    let!(:activity_type)      { create(:activity_type, active: true, activity_category: activity_category) }

    before do
      allow_any_instance_of(Transifex::Synchroniser).to receive(:pull).and_raise('Sync error')
    end

    it 'logs errors in the database' do
      expect { service.perform }.to change(TransifexLoadError, :count).by(2)
      expect(TransifexLoadError.first.record_type).to eq('ActivityType')
      expect(TransifexLoadError.first.record_id).to eq activity_type.id
      expect(TransifexLoadError.first.error).to eq('Sync error')
    end

    it 'logs errors in Rollbar' do
      expect(Rollbar).to receive(:error).with(an_instance_of(RuntimeError), job: :transifex_load, record_type: 'ActivityType', record_id: activity_type.id)
      expect(Rollbar).to receive(:error).with(an_instance_of(RuntimeError), job: :transifex_load, record_type: 'ActivityCategory', record_id: activity_category.id)
      service.perform
    end
  end

  context 'when there are no errors' do
    let!(:advice_page_text)         { 'advice page learn more' }
    let!(:activity_category)        { create(:activity_category) }
    let!(:intervention_type_group)  { create(:intervention_type_group) }
    let!(:activity_type)            { create(:activity_type, active: true, activity_category: activity_category) }
    let!(:activity_type2)           { create(:activity_type, active: false, activity_category: activity_category) }
    let!(:intervention_type)        { create(:intervention_type, active: true, intervention_type_group: intervention_type_group) }
    let!(:intervention_type2)       { create(:intervention_type, active: false, intervention_type_group: intervention_type_group) }
    let!(:help_page)                { create(:help_page) }
    let!(:case_study)               { create(:case_study) }
    let!(:programme_type)           { create(:programme_type) }
    let!(:programme_type2)          { create(:programme_type, active: false) }
    let!(:transport_type)           { create(:transport_type) }
    let!(:consent_statement)        { create(:consent_statement) }
    let!(:comparison_report_group)  { create(:report_group) }
    let!(:comparison_report)        { create(:report, report_group: comparison_report_group) }
    let!(:comparison_footnote)      { create(:footnote) }
    let!(:advice_page)              { create(:advice_page, learn_more: advice_page_text) }
    let!(:category)                 { create(:category, published: true) }

    before do
      allow_any_instance_of(Transifex::Synchroniser).to receive(:pull).and_return(true)
      allow_any_instance_of(Transifex::Synchroniser).to receive(:push).and_return(true)
      service.perform
    end

    it 'updates the pull count' do
      expect(TransifexLoad.first.pulled).to eq 14
    end

    it 'updates the push count' do
      expect(TransifexLoad.first.pushed).to eq 14
    end

    context 'when synching advice pages' do
      context 'when a record has no contents' do
        let!(:advice_page_text) { '' }

        it 'skips the pull' do
          expect(TransifexLoad.first.pulled).to eq 13
        end

        it 'skips the push' do
          expect(TransifexLoad.first.pushed).to eq 13
        end
      end
    end
  end
end

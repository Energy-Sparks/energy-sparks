require 'rails_helper'

RSpec.describe ManualDataLoadRun, type: :model do
  describe '#delete' do
    it 'destroys a manual data load run and all associated manual data load run log entries' do
      ManualDataLoadRun.delete_all
      new_manual_data_load_run = ManualDataLoadRun.create!(
        amr_uploaded_reading: create(:amr_uploaded_reading),
        status: 'done'
      )
      ManualDataLoadRunLogEntry.create(manual_data_load_run: new_manual_data_load_run, message: 'SUCCESS')
      ManualDataLoadRunLogEntry.create(manual_data_load_run: new_manual_data_load_run, message: 'SUCCESS')
      expect(new_manual_data_load_run.manual_data_load_run_log_entries.count).to eq(2)
      expect do
        new_manual_data_load_run.destroy
      end.to change(ManualDataLoadRun, :count).by(-1) &
             change(ManualDataLoadRunLogEntry, :count).by(-2) &
             change(AmrUploadedReading, :count).by(-1)
    end
  end
end

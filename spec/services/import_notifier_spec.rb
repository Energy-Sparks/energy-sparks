require 'rails_helper'

describe ImportNotifier do

  let(:sheffield_config) { create(:amr_data_feed_config, description: 'Sheffield', import_warning_days: 5) }
  let(:bath_config) { create(:amr_data_feed_config, description: 'Bath') }

  describe '#data' do

    it 'gets collects all the import logs from the configs' do
      sheffield_import_log = create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, records_imported: 200, import_time: 1.day.ago)
      bath_import_log = create(:amr_data_feed_import_log, amr_data_feed_config: bath_config, records_imported: 1, import_time: 1.day.ago)
      data = ImportNotifier.new.data(from: 2.days.ago, to: Time.now)
      expect(data[sheffield_config][:import_logs]).to eq([sheffield_import_log])
      expect(data[bath_config][:import_logs]).to eq([bath_import_log])
    end

    it 'restricts logs on the date' do
      sheffield_import_log = create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, records_imported: 200, import_time: 1.day.ago)
      bath_import_log = create(:amr_data_feed_import_log, amr_data_feed_config: bath_config, records_imported: 1, import_time: 1.year.ago)
      data = ImportNotifier.new.data(from: 2.days.ago, to: Time.now)
      expect(data[sheffield_config][:import_logs]).to eq([sheffield_import_log])
      expect(data[bath_config][:import_logs]).to eq([])
    end

    it 'gets all the meters that have not had validated data for X days' do
      sheffield_import_log = create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, records_imported: 200, import_time: 1.day.ago)
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, config: sheffield_config, log: sheffield_import_log)
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, config: sheffield_config, log: sheffield_import_log)
      data = ImportNotifier.new.data(from: 2.days.ago, to: Time.now)
      expect(data[sheffield_config][:import_logs]).to eq([sheffield_import_log])
      expect(data[sheffield_config][:meters_running_behind]).to match_array([meter_1])
    end

    it 'does not return any late meters if there is no day set' do
      sheffield_config.update!(import_warning_days: nil)
      sheffield_import_log = create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, records_imported: 200, import_time: 1.day.ago)
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, config: sheffield_config, log: sheffield_import_log)
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, config: sheffield_config, log: sheffield_import_log)
      data = ImportNotifier.new.data(from: 2.days.ago, to: Time.now)
      expect(data[sheffield_config][:import_logs]).to eq([sheffield_import_log])
      expect(data[sheffield_config][:meters_running_behind]).to match_array([])
    end

    it 'gets all the meters from the imports where there is missing data' do
      sheffield_import_log = create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, records_imported: 200, import_time: 1.day.ago)
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, config: sheffield_config, log: sheffield_import_log)
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, config: sheffield_config, log: sheffield_import_log)

      meter_1.amr_data_feed_readings.last.update!(readings: Array.new(48, ''))
      data = ImportNotifier.new.data(from: 2.days.ago, to: Time.now)
      expect(data[sheffield_config][:meters_with_blank_data]).to match_array([meter_1])
    end

    it 'gets all the meters from the imports where there is zero data' do
      sheffield_import_log = create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, records_imported: 200, import_time: 1.day.ago)
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, config: sheffield_config, log: sheffield_import_log)
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, config: sheffield_config, log: sheffield_import_log)

      meter_1.amr_data_feed_readings.last.update!(readings: Array.new(48, 0))
      data = ImportNotifier.new.data(from: 2.days.ago, to: Time.now)
      expect(data[sheffield_config][:meters_with_zero_data]).to match_array([meter_1])
    end

    it 'gets all the import logs which have an error message' do
      error_messages = 'Something went wrong'
      import_log = create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, error_messages: error_messages, import_time: 1.day.ago)
      data = ImportNotifier.new.import_logs_with_errors(from: 2.days.ago, to: Time.now)
      expect(data).to match_array([import_log])
    end

    it 'does not include solar export with zero data' do
      sheffield_import_log = create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, records_imported: 200, import_time: 1.day.ago)
      meter_1 = create(:exported_solar_pv_meter, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, config: sheffield_config, log: sheffield_import_log)

      meter_1.amr_data_feed_readings.last.update!(readings: Array.new(48, 0))
      data = ImportNotifier.new.data(from: 2.days.ago, to: Time.now)
      expect(data[sheffield_config][:meters_with_zero_data]).to be_empty
    end
  end

  describe '#notify' do
    it 'sends an email with the import count for each logged import with its config details' do
      create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, records_imported: 200, import_time: 1.day.ago)
      create(:amr_data_feed_import_log, amr_data_feed_config: bath_config, records_imported: 1, import_time: 1.day.ago)

      ImportNotifier.new.notify(from: 2.days.ago, to: Time.now)

      email = ActionMailer::Base.deliveries.last

      expect(email.subject).to include('Energy Sparks import')

      email_body = email.html_part.body.to_s
      expect(email_body).to include('Sheffield')
      expect(email_body).to include('200')
      expect(email_body).to include('Bath')
      expect(email_body).to_not include('Import Issues')
    end

    it 'sends an email with the import issues if appropriate' do
      error_messages = 'Something went wrong'
      create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, error_messages: error_messages, import_time: 1.day.ago)

      ImportNotifier.new.notify(from: 2.days.ago, to: Time.now)

      email = ActionMailer::Base.deliveries.last

      expect(email.subject).to include('Energy Sparks import')

      email_body = email.html_part.body.to_s
      expect(email_body).to include('Sheffield')
      expect(email_body).to include('Import Issues')
      expect(email_body).to include(error_messages)
    end

    it 'sends an email with the import warnings if appropriate' do
      mpan = 123
      create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, import_time: 1.day.ago)
      warning = AmrReadingWarning.create(amr_data_feed_import_log: log, mpan_mprn: mpan, warning: :missing_readings, warning_message: AmrReadingData::WARNINGS[:missing_readings])

      ImportNotifier.new.notify(from: 2.days.ago, to: Time.now)

      email = ActionMailer::Base.deliveries.last

      expect(email.subject).to include('Energy Sparks import')

      email_body = email.html_part.body.to_s
      expect(email_body).to include('Sheffield')
      expect(email_body).to include('Import Warnings')
      expect(email_body).to include(error_messages)
    end

    it 'can override the emails subject' do
      ImportNotifier.new(description: 'early morning import').notify(from: 2.days.ago, to: Time.now)
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to include('Energy Sparks early morning import')
    end
  end
end

require 'rails_helper'

describe ImportNotifier do

  let(:sheffield_school) { create(:school, :with_school_group, name: "Sheffield School")}
  let(:bath_school) { create(:school, :with_school_group, name: "Bath School")}
  let(:sheffield_config) { create(:amr_data_feed_config, description: 'Sheffield', import_warning_days: 5) }
  let(:bath_config) { create(:amr_data_feed_config, description: 'Bath', import_warning_days: 2) }

  let(:sheffield_import_log) { create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, records_imported: 200, import_time: 1.day.ago) }

  describe '#meters_running_behind' do
    it 'gets all the meters that have not had validated data for X days' do
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, config: sheffield_config, log: sheffield_import_log)
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, config: sheffield_config, log: sheffield_import_log)
      meters_running_behind = ImportNotifier.new.meters_running_behind()
      expect(meters_running_behind).to match_array([meter_1])
    end

    it 'ignores inactive meters when warning about meters running behind' do
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, config: sheffield_config, log: sheffield_import_log)
      inactive_meter = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, active: false, start_date: 20.days.ago, end_date: 9.days.ago, config: sheffield_config, log: sheffield_import_log)
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, config: sheffield_config, log: sheffield_import_log)
      meters_running_behind = ImportNotifier.new.meters_running_behind()
      expect(meters_running_behind).to match_array([meter_1])
    end

    it 'ignores meters when config doesnt have warning days' do
      sheffield_config.update!(import_warning_days: nil)
      sheffield_import_log = create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, records_imported: 200, import_time: 1.day.ago)
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, config: sheffield_config, log: sheffield_import_log)
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, config: sheffield_config, log: sheffield_import_log)
      meters_running_behind = ImportNotifier.new.meters_running_behind()
      expect(meters_running_behind).to match_array([])
    end
  end

  describe '#meters_with_blank_data' do
    it 'gets all the meters from the imports where there is missing data' do
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, config: sheffield_config, log: sheffield_import_log)
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, config: sheffield_config, log: sheffield_import_log)

      meter_1.amr_data_feed_readings.last.update!(readings: Array.new(48, ''))
      meters_with_blank_data = ImportNotifier.new.meters_with_blank_data(from: 2.days.ago, to: Time.now)
      expect(meters_with_blank_data).to match_array([meter_1])
    end
  end

  describe '#meters_with_zero_data' do
    it 'gets all the meters from the imports where there is zero data' do
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, config: sheffield_config, log: sheffield_import_log)
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, config: sheffield_config, log: sheffield_import_log)

      meter_1.amr_data_feed_readings.last.update!(readings: Array.new(48, 0))
      meters_with_zero_data = ImportNotifier.new.meters_with_zero_data(from: 2.days.ago, to: Time.now)
      expect(meters_with_zero_data).to match_array([meter_1])
    end

    it 'does not include solar export with zero data' do
      meter_1 = create(:exported_solar_pv_meter, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, config: sheffield_config, log: sheffield_import_log)

      meter_1.amr_data_feed_readings.last.update!(readings: Array.new(48, 0))
      meters_with_zero_data = ImportNotifier.new.meters_with_zero_data(from: 2.days.ago, to: Time.now)
      expect(meters_with_zero_data).to be_empty
    end
  end

  describe '#meters_running_behind' do
    it 'removes duplicates, when meters are loaded via multiple configs' do
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, config: sheffield_config, log: sheffield_import_log)
      bath_import_log = create(:amr_data_feed_import_log, amr_data_feed_config: bath_config, records_imported: 200, import_time: 1.day.ago)
      readings = create(:amr_data_feed_reading, meter: meter_1, reading_date: 9.days.ago, amr_data_feed_config: bath_config, amr_data_feed_import_log: bath_import_log)
      meters_running_behind = ImportNotifier.new.meters_running_behind()
      expect(meters_running_behind).to match_array([meter_1])
    end

    it 'sorts meters' do
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, config: sheffield_config, log: sheffield_import_log)
      bath_import_log = create(:amr_data_feed_import_log, amr_data_feed_config: bath_config, records_imported: 200, import_time: 1.day.ago)
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, config: bath_config, log: bath_import_log)
      meters_running_behind = ImportNotifier.new.meters_running_behind()
      expect(meters_running_behind).to match_array([meter_2, meter_1])
    end
  end

  describe '#notify' do
    it 'formats the email properly' do
      create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, records_imported: 200, import_time: 1.day.ago)
      create(:amr_data_feed_import_log, amr_data_feed_config: bath_config, records_imported: 1, import_time: 1.day.ago)
      ImportNotifier.new.notify(from: 2.days.ago, to: Time.now)

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to include('Energy Sparks import')
      email_body = email.body.to_s
      expect(email_body).to include("Data issues")
    end

    it 'contains the meter information' do
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, config: sheffield_config, log: sheffield_import_log, school: sheffield_school)
      bath_import_log = create(:amr_data_feed_import_log, amr_data_feed_config: bath_config, records_imported: 200, import_time: 1.day.ago)
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, config: bath_config, log: bath_import_log, school: bath_school)
      ImportNotifier.new.notify(from: 2.days.ago, to: Time.now)

      email = ActionMailer::Base.deliveries.last

      expect(email.subject).to include('Energy Sparks import')
      email_body = email.body.to_s
      expect(email_body).to include(meter_1.mpan_mprn.to_s)
      expect(email_body).to include(meter_1.school_name)
      expect(email_body).to include(meter_2.mpan_mprn.to_s)
      expect(email_body).to include(meter_2.school_name)
    end

    it 'can override the emails subject' do
      ImportNotifier.new(description: 'early morning import').notify(from: 2.days.ago, to: Time.now)
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to include('Energy Sparks early morning import')
    end
  end
end

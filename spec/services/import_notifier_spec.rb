require 'rails_helper'

describe ImportNotifier do

  let(:sheffield_school) { create(:school, :with_school_group, name: "Sheffield School")}
  let(:bath_school) { create(:school, :with_school_group, name: "Bath School")}
  let(:sheffield_config) { create(:amr_data_feed_config, description: 'Sheffield') }
  let(:bath_config) { create(:amr_data_feed_config, description: 'Bath') }
  let(:other_config) { create(:amr_data_feed_config, description: 'Other') }

  let(:sheffield_import_log) { create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, records_imported: 200, import_time: 1.day.ago) }

  describe '#meters_running_behind' do
    it 'gets all the meters that have not had validated data for X days' do
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, data_source: create(:data_source, import_warning_days: 5))
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, data_source: create(:data_source, import_warning_days: 5))
      meters_running_behind = ImportNotifier.new.meters_running_behind
      expect(SiteSettings.current.default_import_warning_days).to eq(10)
      expect(meters_running_behind).to match_array([meter_1])
    end

    it 'ignores inactive meters when warning about meters running behind' do
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, data_source: create(:data_source, import_warning_days: 5))
      inactive_meter = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, active: false, start_date: 20.days.ago, end_date: 9.days.ago, data_source: create(:data_source, import_warning_days: 5))
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, data_source: create(:data_source, import_warning_days: 5))
      meters_running_behind = ImportNotifier.new.meters_running_behind
      expect(SiteSettings.current.default_import_warning_days).to eq(10)
      expect(meters_running_behind).to match_array([meter_1])
    end

    it 'defaults to the site setting default when a meters data source does not have any import warning days' do
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, data_source: create(:data_source, import_warning_days: nil))
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, data_source: create(:data_source, import_warning_days: nil))
      expect(SiteSettings.current.default_import_warning_days).to eq(10)
      expect(ImportNotifier.new.meters_running_behind).to match_array([])
      SiteSettings.current.update(default_import_warning_days: 5)
      expect(SiteSettings.current.default_import_warning_days).to eq(5)
      expect(ImportNotifier.new.meters_running_behind).to match_array([meter_1])
      SiteSettings.current.update(default_import_warning_days: 2)
      expect(SiteSettings.current.default_import_warning_days).to eq(2)
      expect(ImportNotifier.new.meters_running_behind).to match_array([meter_2, meter_1])
    end

    it 'defaults to the site setting default when a meters does not have a data source' do
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, data_source: nil)
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, data_source: nil)
      expect(SiteSettings.current.default_import_warning_days).to eq(10)
      expect(ImportNotifier.new.meters_running_behind).to match_array([])
      SiteSettings.current.update(default_import_warning_days: 5)
      expect(SiteSettings.current.default_import_warning_days).to eq(5)
      expect(ImportNotifier.new.meters_running_behind).to match_array([meter_1])
      SiteSettings.current.update(default_import_warning_days: 2)
      expect(SiteSettings.current.default_import_warning_days).to eq(2)
      expect(ImportNotifier.new.meters_running_behind).to match_array([meter_2, meter_1])
    end

    it 'checks against the warning days for config of the unvalidated reading' do
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, data_source: create(:data_source, import_warning_days: 5))
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 2.days.ago, data_source: create(:data_source, import_warning_days: 5))
      meters_running_behind = ImportNotifier.new.meters_running_behind
      expect(SiteSettings.current.default_import_warning_days).to eq(10)
      expect(meters_running_behind).to match_array([meter_1])
    end

    it 'sorts meters' do
      school_group_1 = create(:school_group, name: 'AAAAAAA')
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, school: create(:school, school_group: school_group_1), start_date: 20.days.ago, end_date: 9.days.ago, data_source: create(:data_source, import_warning_days: 5))
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, school: create(:school), start_date: 20.days.ago, end_date: 9.days.ago, data_source: create(:data_source, import_warning_days: 5))
      meter_3 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, school: create(:school), start_date: 20.days.ago, end_date: 9.days.ago, data_source: create(:data_source, import_warning_days: 5))
      expect(ImportNotifier.new.find_meters_running_behind.map(&:id)).to eq([meter_1.id, meter_2.id, meter_3.id])
      expect(ImportNotifier.new.meters_running_behind.map(&:id)).to eq([meter_2.id, meter_3.id, meter_1.id])
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

    #future requirement
    xit 'does not include gas data in the summer' do
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: Date.new(2022,8,1), end_date: Date.new(2022,9,1), config: sheffield_config, log: sheffield_import_log)
      meter_1.amr_data_feed_readings.last.update!(readings: Array.new(48, 0))
      meters_with_zero_data = ImportNotifier.new.meters_with_zero_data(from: Date.new(2022,8,1), to: Time.now)
      expect(meters_with_zero_data).to match_array([])
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
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, school: sheffield_school, data_source: create(:data_source, import_warning_days: 5))
      bath_import_log = create(:amr_data_feed_import_log, amr_data_feed_config: bath_config, records_imported: 200, import_time: 1.day.ago)
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, school: bath_school, data_source: create(:data_source, import_warning_days: 2))
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

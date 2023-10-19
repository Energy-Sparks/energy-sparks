require 'rails_helper'

describe ImportNotifier do
  let(:amr_data_feed_config) { create(:amr_data_feed_config, description: 'Sheffield') }
  let(:amr_data_feed_import_log) { create(:amr_data_feed_import_log, amr_data_feed_config: amr_data_feed_config, records_imported: 200, import_time: 1.day.ago) }

  let(:start_date)       { 20.days.ago }
  let(:end_date)         { 9.days.ago }

  let(:data_source)      { create(:data_source, import_warning_days: 5) }
  let(:school)           { create(:school, :with_school_group) }

  let!(:meter_1)         do
    create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings,
    school: school, start_date: start_date, end_date: end_date, data_source: data_source)
  end

  describe '#meters_running_behind' do
    let(:meters_running_behind) { ImportNotifier.new.meters_running_behind }

    context 'and the school is inactive' do
      let(:school)         { create(:school, active: false)}

      it 'does not include the meters' do
        expect(meters_running_behind).to match_array([])
      end
    end

    context 'and there is a meter running behind' do
      let!(:meter_2) do
        create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings,
        school: school, start_date: start_date, end_date: 2.days.ago, data_source: data_source)
      end

      it 'gets all the meters that have not had validated data for X days' do
        expect(SiteSettings.current.default_import_warning_days).to eq(10)
        expect(meters_running_behind).to match_array([meter_1])
      end
    end

    context 'and there are inactive meters' do
      let!(:meter_2) do
        create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings,
        school: school, start_date: start_date, end_date: 2.days.ago, data_source: data_source)
      end

      let!(:inactive_meter) do
        create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings,
          active: false, school: school, start_date: start_date, end_date: end_date, data_source: data_source)
      end

      it 'ignores inactive meters when warning about meters running behind' do
        expect(SiteSettings.current.default_import_warning_days).to eq(10)
        expect(meters_running_behind).to match_array([meter_1])
      end
    end

    context 'and data source does not have an import warning day config' do
      let(:data_source)      { create(:data_source, import_warning_days: nil) }
      let!(:meter_2) do
        create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings,
        school: school, start_date: start_date, end_date: 2.days.ago, data_source: data_source)
      end

      it 'defaults to the site setting default when a meters data source does not have any import warning days' do
        expect(SiteSettings.current.default_import_warning_days).to eq(10)
        expect(ImportNotifier.new.meters_running_behind).to match_array([])
        SiteSettings.current.update(default_import_warning_days: 5)
        expect(SiteSettings.current.default_import_warning_days).to eq(5)
        expect(ImportNotifier.new.meters_running_behind).to match_array([meter_1])
        SiteSettings.current.update(default_import_warning_days: 2)
        expect(SiteSettings.current.default_import_warning_days).to eq(2)
        expect(ImportNotifier.new.meters_running_behind).to match_array([meter_2, meter_1])
      end
    end

    context 'and meter does not have a data source' do
      let(:data_source) { nil }
      let!(:meter_2) do
        create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings,
        school: school, start_date: start_date, end_date: 2.days.ago, data_source: data_source)
      end

      it 'defaults to the site setting default when a meters does not have a data source' do
        expect(SiteSettings.current.default_import_warning_days).to eq(10)
        expect(ImportNotifier.new.meters_running_behind).to match_array([])
        SiteSettings.current.update(default_import_warning_days: 5)
        expect(SiteSettings.current.default_import_warning_days).to eq(5)
        expect(ImportNotifier.new.meters_running_behind).to match_array([meter_1])
        SiteSettings.current.update(default_import_warning_days: 2)
        expect(SiteSettings.current.default_import_warning_days).to eq(2)
        expect(ImportNotifier.new.meters_running_behind).to match_array([meter_2, meter_1])
      end
    end

    context 'and there are up to date meters' do
      let!(:meter_2) do
        create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings,
        school: school, start_date: start_date, end_date: 2.days.ago, data_source: data_source)
      end

      it 'checks against the warning days' do
        expect(SiteSettings.current.default_import_warning_days).to eq(10)
        expect(meters_running_behind).to match_array([meter_1])
      end
    end

    context 'when sorting meters' do
      let(:start_date)       { 20.days.ago }
      let(:end_date)         { 9.days.ago }

      let(:data_source)      { create(:data_source, import_warning_days: 5) }
      let(:school_group_a)   { create(:school_group, name: 'AAA') }
      let(:school_group_b)   { create(:school_group, name: 'BBB') }

      let(:meter_1_school)   { create(:school, school_group: school_group_a) }
      let(:meter_2_school)   { create(:school, name: "A School", school_group: school_group_b) }
      let(:meter_3_school)   { create(:school, name: "B School", school_group: school_group_b) }
      let(:meter_4_school)   { create(:school) } #no group

      let!(:meter_1)         { create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, school: meter_1_school, start_date: start_date, end_date: end_date, data_source: data_source) }
      let!(:meter_2)         { create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, school: meter_2_school, start_date: start_date, end_date: end_date, data_source: data_source) }
      let!(:meter_3)         { create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, school: meter_3_school, start_date: start_date, end_date: end_date, data_source: data_source) }
      let!(:meter_4)         { create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, school: meter_4_school, start_date: start_date, end_date: end_date, data_source: data_source) }

      it 'sorts meters' do
        #nil group first, then by school group name, then meter type and school
        expect(ImportNotifier.new.meters_running_behind.map(&:id)).to match_array([meter_4.id, meter_1.id, meter_2.id, meter_3.id])
      end
    end
  end

  describe '#meters_with_blank_data' do
    let(:end_date)         { 2.days.ago }

    let!(:meter_1)         do
      create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings,
      school: school, start_date: start_date, end_date: end_date, data_source: data_source, config: amr_data_feed_config, log: amr_data_feed_import_log)
    end

    let!(:meter_2) do
      create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings,
        school: school, start_date: start_date, end_date: end_date, data_source: data_source, config: amr_data_feed_config, log: amr_data_feed_import_log)
    end

    let(:meters_with_blank_data) { ImportNotifier.new.meters_with_blank_data(from: 2.days.ago, to: Time.zone.now) }

    before do
      meter_1.amr_data_feed_readings.last.update!(readings: Array.new(48, ''))
    end

    context 'and the school is inactive' do
      let(:school) { create(:school, active: false)}

      it 'ignores the meter' do
        expect(meters_with_blank_data).to match_array([])
      end
    end

    context 'and there is blank data' do
      it 'returns the meter' do
       expect(meters_with_blank_data).to match_array([meter_1])
      end
    end
  end

  describe '#meters_with_zero_data' do
    let(:end_date)         { 2.days.ago }

    let!(:meter_1)         do
      create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings,
      school: school, start_date: start_date, end_date: end_date, data_source: data_source, config: amr_data_feed_config, log: amr_data_feed_import_log)
    end

    let!(:meter_2) do
      create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings,
        school: school, start_date: start_date, end_date: end_date, data_source: data_source, config: amr_data_feed_config, log: amr_data_feed_import_log)
    end

    let(:meters_with_zero_data) { ImportNotifier.new.meters_with_zero_data(from: 2.days.ago, to: Time.zone.now) }

    before do
      meter_1.amr_data_feed_readings.last.update!(readings: Array.new(48, 0))
    end

    context 'and the school is inactive' do
      let(:school) { create(:school, active: false)}

      it 'ignores the meter' do
        expect(meters_with_zero_data).to match_array([])
      end
    end

    context 'and there is zero data' do
      it 'returns the meter' do
       expect(meters_with_zero_data).to match_array([meter_1])
      end
    end

    context 'when the meter is solar export' do
      let!(:meter_1) { create(:exported_solar_pv_meter, :with_unvalidated_readings, start_date: start_date, end_date: end_date) }

      it 'does not include solar export with zero data' do
        expect(meters_with_zero_data).to be_empty
      end
    end

    #future requirement
    xit 'does not include gas data in the summer'
  end

  describe '#notify' do
    let!(:sheffield_school)          { create(:school, :with_school_group, name: "Sheffield School")}
    let!(:bath_school)               { create(:school, :with_school_group, name: "Bath School")}
    let!(:amr_data_feed_config)      { create(:amr_data_feed_config, description: 'Sheffield') }
    let!(:bath_amr_data_feed_config) { create(:amr_data_feed_config, description: 'Bath') }

    let!(:log_1) do
      create(:amr_data_feed_import_log,
      amr_data_feed_config: amr_data_feed_config, records_imported: 200, import_time: 1.day.ago)
    end
    let!(:log_2) do
      create(:amr_data_feed_import_log,
      amr_data_feed_config: bath_amr_data_feed_config, records_imported: 1, import_time: 1.day.ago)
    end

    let(:description)               { nil }

    let(:email)                     { ActionMailer::Base.deliveries.last }

    before do
      ImportNotifier.new(description: description).notify(from: 2.days.ago, to: Time.zone.now)
    end

    it 'formats the email properly' do
      expect(email.subject).to include('Energy Sparks import')
      email_body = email.html_part.body
      expect(email_body).to include("Data issues")
    end

    context 'with meter data' do
      let!(:bath_import_log) do
        create(:amr_data_feed_import_log, amr_data_feed_config: bath_amr_data_feed_config,
        records_imported: 200, import_time: 1.day.ago)
      end

      let!(:meter_1) do
        create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings,
        start_date: start_date, end_date: end_date, school: sheffield_school, data_source: data_source)
      end

      let!(:meter_2) do
        create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings,
        start_date: start_date, end_date: end_date, school: bath_school, data_source: create(:data_source, import_warning_days: 2))
      end

      let(:admin_1) { create(:admin, name: 'Admin One') }
      let(:admin_2) { create(:admin, name: 'Admin Two') }

      let!(:bath_school)               { create(:school, school_group: create(:school_group, default_issues_admin_user: admin_1))}
      let!(:sheffield_school)          { create(:school, school_group: create(:school_group, default_issues_admin_user: admin_2))}

      it 'contains the meter information in the email' do
        ImportNotifier.new.notify(from: 2.days.ago, to: Time.zone.now)
        email_body = email.html_part.body
        expect(email_body).to include(meter_1.mpan_mprn.to_s)
        expect(email_body).to include(meter_1.school_name)
        expect(email_body).to include(meter_2.mpan_mprn.to_s)
        expect(email_body).to include(meter_2.school_name)
        expect(email_body).to include(admin_1.name)
        expect(email_body).to include(admin_2.name)
      end

      it 'has an attachment' do
        attachment = email.attachments[0]
        expect(attachment.content_type).to include('text/csv')
        expect(attachment.filename).to eq("[energy-sparks-unknown] Energy Sparks import report: #{Time.zone.today.strftime('%d/%m/%Y')}.csv")
        expect(attachment.body.raw_source.split("\r\n").first).to eq("\"\",Area,Meter type,School,MPAN/MPRN,Meter system,Data source,Procurement route,Last validated reading date,Admin meter status,Issues,Notes,Group admin name")
      end
    end

    context 'with a description provided' do
      let(:description) {'Energy Sparks early morning import' }

      it 'overrides the subject' do
        expect(email.subject).to include(description)
      end
    end
  end
end

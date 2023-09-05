require 'rails_helper'

RSpec.describe ImportMailer, include_application_helper: true do
  describe '#import_summary' do
    let(:sheffield_school) { create(:school, :with_school_group, name: "Sheffield School")}
    let(:bath_school) { create(:school, :with_school_group, name: "Bath School")}
    let(:sheffield_config) { create(:amr_data_feed_config, description: 'Sheffield') }
    let(:bath_config) { create(:amr_data_feed_config, description: 'Bath') }
    let(:admin_1) { create(:admin, name: 'Admin One') }
    let(:admin_2) { create(:admin, name: 'Admin Two') }

    it 'sends an email for ' do
      meter_1 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, school: sheffield_school, data_source: create(:data_source, import_warning_days: 5))
      bath_import_log = create(:amr_data_feed_import_log, amr_data_feed_config: bath_config, records_imported: 200, import_time: 1.day.ago)
      meter_2 = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings, start_date: 20.days.ago, end_date: 9.days.ago, school: bath_school, data_source: create(:data_source, import_warning_days: 2))
      bath_school.school_group.update(default_issues_admin_user_id: admin_1.id)
      sheffield_school.school_group.update(default_issues_admin_user_id: admin_2.id)
      ImportNotifier.new.notify(from: 2.days.ago, to: Time.now)
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to include('Energy Sparks import')
      expect(email.html_part.body).to include("Data issues")
      expect(email.html_part.body).to include(meter_1.mpan_mprn.to_s)
      expect(email.html_part.body).to include(meter_1.school_name)
      expect(email.html_part.body).to include(meter_2.mpan_mprn.to_s)
      expect(email.html_part.body).to include(meter_2.school_name)
      attachments = email.attachments[0]
      expect(attachments.content_type).to include('text/csv')
      expect(attachments.filename).to eq("[energy-sparks-unknown] Energy Sparks import report: #{Date.today.strftime('%d/%m/%Y')}.csv")
      expect(attachments.body.raw_source).to eq("\"\",Area,Meter type,School,MPAN/MPRN,Half-Hourly,Data source,Procurement route,Last validated reading date,Admin meter status,Issues,Notes,Group admin name\r\nMeter with stale data,#{sheffield_school.school_group.name},Gas,Sheffield School,#{meter_1.mpan_mprn},No,#{meter_1.data_source.name},,#{meter_1.last_validated_reading&.strftime('%d/%m/%Y')},\"\",0,0,Admin Two\r\nMeter with stale data,#{bath_school.school_group.name},Gas,Bath School,#{meter_2.mpan_mprn},No,#{meter_2.data_source.name},,#{meter_2.last_validated_reading&.strftime('%d/%m/%Y')},\"\",0,0,Admin One\r\n")
    end
  end
end

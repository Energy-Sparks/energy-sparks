require 'rails_helper'

RSpec.describe AdminMailer, include_application_helper: true do
  let(:email) { ActionMailer::Base.deliveries.last }

  around do |example|
    ClimateControl.modify ENVIRONMENT_IDENTIFIER: 'unknown' do
      example.run
    end
  end

  describe '#school_group_meters_report' do
    shared_examples 'a report with gaps in the meter readings' do
      let(:base_date) { Time.zone.today - 1.year }

      before do
        create(:amr_validated_reading, meter: active_meter, reading_date: base_date, status: 'ORIG')
        15.times do |idx|
          create(:amr_validated_reading, meter: active_meter, reading_date: base_date + 1 + idx.days, status: 'NOT_ORIG')
        end
        create(:amr_validated_reading, meter: active_meter, reading_date: base_date + 17, status: 'ORIG')
        create(:amr_validated_reading, meter: active_meter, reading_date: base_date + 18, status: 'NOT_ORIG')
      end

      it 'shows count of modified dates and gaps' do
        expect(body).to include 'Large gaps (last 2 years)'
        expect(body).to include 'Modified readings (last 2 years)'

        within '.gappy-dates' do
          expect(body).to include "15 days (#{(base_date + 1.day).to_fs(:es_short)} to #{(base_date + 15.days).to_fs(:es_short)})"
        end

        within '.modified-dates' do
          expect(body).to include '16'
        end
      end
    end

    shared_examples 'a report with standard fields' do |active_only: true|
      it 'includes school and meters for active meters' do
        expect(body).to have_content(active_meter.school.name)
        expect(body).to have_content(active_meter.mpan_mprn)
      end

      it 'includes school and meters for inactive meters', unless: active_only do
        expect(body).to have_content(inactive_meter.school.name)
        expect(body).to have_content(inactive_meter.mpan_mprn)
      end

      it 'does not include school and meters for inactive meters', if: active_only do
        expect(body).not_to have_content(inactive_meter.school.name)
        expect(body).not_to have_content(inactive_meter.mpan_mprn)
      end
    end

    #### tests start here ####

    before { freeze_time }

    let(:school_group) { create :school_group }
    let(:to) { 'test@test.com' }

    let!(:active_meter) { create :gas_meter, mpan_mprn: 12345678, active: true, school: create(:school, school_group: school_group) }
    let!(:inactive_meter) { create :gas_meter, mpan_mprn: 87654321, active: false, school: create(:school, school_group: school_group) }

    let(:all_meters) { false }
    let(:meter_report) { SchoolGroups::MeterReport.new(school_group, all_meters: all_meters) }

    before do
      AdminMailer.with(to: to, meter_report: meter_report).school_group_meters_report.deliver
    end

    context 'All meters' do
      let(:all_meters) { true }

      it { expect(email.subject).to eql("[energy-sparks-unknown] Energy Sparks - Meter report for #{school_group.name} - all meters") }
    end

    context 'Only active meters' do
      let(:all_meters) { false }

      it { expect(email.subject).to eql("[energy-sparks-unknown] Energy Sparks - Meter report for #{school_group.name} - active meters") }
    end

    context 'html report' do
      let(:body) { email.html_part.body.raw_source }

      it 'has heading' do
        expect(body).to include("#{school_group.name} meter report")
      end

      it_behaves_like 'a report with gaps in the meter readings'

      context 'All meters' do
        let(:all_meters) { true }

        it_behaves_like 'a report with standard fields', active_only: false
      end

      context 'Active meters' do
        let(:all_meters) { false }

        it_behaves_like 'a report with standard fields', active_only: true
      end
    end

    context 'csv report' do
      let(:attachment) { email.attachments[0] }

      let(:body) { attachment.body.raw_source }

      it { expect(email.attachments.count).to eq(1) }
      it { expect(attachment.content_type).to include('text/csv') }
      it { expect(attachment.filename).to eq(meter_report.csv_filename) }


      it_behaves_like 'a report with gaps in the meter readings'

      context 'All meters' do
        let(:all_meters) { true }

        it_behaves_like 'a report with standard fields', active_only: false
      end

      context 'Active meters' do
        let(:all_meters) { false }

        it_behaves_like 'a report with standard fields', active_only: true
      end
    end
  end

  describe '#issues_report' do
    before { travel_to(Time.zone.now) }

    let(:admin) { create(:admin) }
    let(:note) { create(:issue, issue_type: :note) }
    let(:new_issue) { create(:issue, issue_type: :issue, status: :open, owned_by: admin, created_at: 5.days.ago, review_date: 1.week.from_now) }
    let(:school_group) { create(:school_group) }
    let(:school) { create(:school, school_group: school_group) }
    let(:issue) { create(:issue, issue_type: :issue, status: :open, owned_by: admin, created_at: 2.weeks.ago, review_date: 1.day.ago, issueable: school) }
    let(:closed_issue) { create(:issue, issue_type: :issue, status: :closed, owned_by: admin) }
    let(:someone_elses_issue) { create(:issue, issue_type: :issue, status: :open, owned_by: nil) }
    let(:inactive_school_issue) { create :issue, owned_by: admin, issueable: create(:school, active: false) }

    let!(:issues) { [] }
    let(:attachment) { email.attachments[0] }
    let(:body) { email.html_part.body.raw_source }

    before do
      AdminMailer.with(user: admin).issues_report.deliver
    end

    context 'showing only open issues for user' do
      let(:issues) { [issue, note, closed_issue, someone_elses_issue] }

      it { expect(email.subject).to eql "[energy-sparks-unknown] Energy Sparks - Issue report for #{admin.display_name}" }

      it 'displays issue' do
        expect(body).to have_link(issue.title, href: admin_school_issue_url(issue.issueable, issue))
        expect(body).to have_content(school_group.name)
        expect(body).to have_content(issue.fuel_type.capitalize)
        expect(body).to have_content(issue.issueable.name)
        expect(body).to have_content(short_dates(issue.review_date))
        expect(body).to have_content(issue.created_by.display_name)
        expect(body).to have_content(short_dates(issue.created_at))
        expect(body).to have_content(issue.updated_by.display_name)
        expect(body).to have_content(short_dates(issue.updated_at))
        expect(body).to have_link('Edit', href: edit_admin_issue_url(issue))
      end

      it { expect(body).to have_link("View all issues for: #{admin.display_name}", href: admin_issues_url(user: admin)) }
      it { expect(body).not_to have_content(note.title) }
      it { expect(body).not_to have_content(closed_issue.title) }
      it { expect(body).not_to have_content(someone_elses_issue.title) }
    end

    context 'when there are new issues for user' do
      let(:issues) { [new_issue] }

      it { expect(body).to have_content('new!') }
    end

    context 'when there are only old issues for user' do
      let(:issues) { [issue] }

      it { expect(body).not_to have_content('new!') }
    end

    context "when there aren't any issues for user" do
      it "doesn't send email" do
        expect(email).to be_nil
      end
    end

    context 'with issues for inactive schools' do
      let(:issues) { [inactive_school_issue] }

      it "doesn't send email" do
        expect(email).to be_nil
      end
    end

    context 'csv report' do
      let(:issues) { [new_issue] }

      it { expect(email.attachments.count).to eq(1) }
      it { expect(attachment.content_type).to include('text/csv') }
      it { expect(attachment.filename).to eq('issues_report.csv') }


      describe 'CSV attachment content' do
        let(:csv_lines) { attachment.body.raw_source.split("\r\n") }
        let(:headers)   { csv_lines.first }
        let(:body)      { csv_lines.second }

        it 'includes the correct headers' do
          expect(headers).to eq(
            'Issue type,Issue for,New,Group,Title,Fuel,Next review date,Created by,Created,Updated by,Updated,View,Edit'
          )
        end

        it 'includes the correct issue data row' do
          expect(body).to eq(
            "issue,#{new_issue.issueable.name},New this week!,#{new_issue.school_group}," \
            "#{new_issue.title},Gas,#{new_issue.review_date.strftime('%d/%m/%Y')}," \
            "#{new_issue.created_by.display_name},#{new_issue.created_at.strftime('%d/%m/%Y')}," \
            "#{new_issue.updated_by.display_name},#{new_issue.updated_at.strftime('%d/%m/%Y')}," \
            "http://localhost/admin/schools/#{new_issue.issueable.slug}/issues/#{new_issue.id}," \
            "http://localhost/admin/issues/#{new_issue.id}/edit"
          )
        end
      end
    end
  end
end

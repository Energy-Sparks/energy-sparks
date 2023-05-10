require 'rails_helper'

RSpec.describe AdminMailer do
  let(:school_group) { create :school_group }
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:to) { 'test@test.com' }

  let(:meter) { active_meter }

  describe '#school_group_meters_report' do

    shared_examples "a report with gaps in the meter readings" do
      let(:base_date) { Date.today - 1.year }

      before do
        create(:amr_validated_reading, meter: meter, reading_date: base_date, status: 'ORIG')
        15.times do |idx|
          create(:amr_validated_reading, meter: meter, reading_date: base_date + 1 + idx.days, status: 'NOT_ORIG')
        end
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 17, status: 'ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 18, status: 'NOT_ORIG')
      end

      it 'shows count of modified dates and gaps' do
        expect(body).to include 'Large gaps (last 2 years)'
        expect(body).to include 'Modified readings (last 2 years)'

        within '.gappy-dates' do
          expect(body).to include "15 days (#{(base_date + 1.day).to_s(:es_short)} to #{(base_date + 15.days).to_s(:es_short)})"
        end

        within '.modified-dates' do
          expect(body).to include '16'
        end
      end
    end

    shared_examples "a report with standard fields" do
      it 'includes school and meters' do
        expect(body).to have_content(meter.school.name)
        expect(body).to have_content(meter.mpan_mprn)
      end
    end

    #### tests start here ####

    let!(:active_meter) { create :gas_meter, active: true, school: create(:school, school_group: school_group) }
    let!(:inactive_meter) { create :gas_meter, active: false, school: create(:school, school_group: school_group) }

    let(:meter_report) { SchoolGroups::MeterReport.new(school_group, all_meters: false) }

    before do
      AdminMailer.with(to: to, meter_report: meter_report).school_group_meters_report.deliver
    end

    it { expect(email.subject).to eql ("[energy-sparks-unknown] Energy Sparks - Meter report for #{school_group.name}") }

    context "html report" do
      let(:body) { email.html_part.body.raw_source }

      it "has required fields" do
        expect(body).to include("#{school_group.name} active meter report")
      end

      it_behaves_like "a report with gaps in the meter readings"
      it_behaves_like "a report with standard fields"
    end

    context "csv report" do
      before { Timecop.freeze(Time.zone.now) }
      after { Timecop.return }
      let(:attachment) { email.attachments[0] }

      it { expect(email.attachments.count).to eq(1) }
      it { expect(attachment.content_type).to include('text/csv') }
      it { expect(attachment.filename).to eq(meter_report.csv_filename) }

      let(:body) { attachment.body.raw_source }

      it_behaves_like "a report with gaps in the meter readings"
      it_behaves_like "a report with standard fields"
    end
  end
end

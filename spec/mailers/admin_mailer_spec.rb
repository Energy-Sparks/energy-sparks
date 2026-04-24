# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminMailer, :include_application_helper do
  include EmailHelpers

  let(:email) { ActionMailer::Base.deliveries.last }

  before { stub_const('ENV', ENV.to_h.merge('SEND_AUTOMATED_EMAILS' => 'true', 'ENVIRONMENT_IDENTIFIER' => 'unknown')) }

  describe '#school_group_meters_report' do
    shared_examples 'a report with gaps in the meter readings' do
      let(:base_date) { Time.zone.today - 1.year }

      before do
        create(:amr_validated_reading, meter: active_meter, reading_date: base_date, status: 'ORIG')
        15.times do |idx|
          create(:amr_validated_reading, meter: active_meter, reading_date: base_date + 1 + idx.days,
                                         status: 'NOT_ORIG')
        end
        create(:amr_validated_reading, meter: active_meter, reading_date: base_date + 17, status: 'ORIG')
        create(:amr_validated_reading, meter: active_meter, reading_date: base_date + 18, status: 'NOT_ORIG')
      end

      it 'shows count of modified dates and gaps' do
        expect(body).to include 'Large gaps (last 2 years)'
        expect(body).to include 'Modified readings (last 2 years)'

        within '.gappy-dates' do
          expect(body).to include \
            "15 days (#{(base_date + 1.day).to_fs(:es_short)} to #{(base_date + 15.days).to_fs(:es_short)})"
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
        expect(body).to have_no_content(inactive_meter.school.name)
        expect(body).to have_no_content(inactive_meter.mpan_mprn)
      end
    end

    #### tests start here ####

    before { freeze_time }

    let(:school_group) { create(:school_group) }
    let(:to) { 'test@test.com' }

    let!(:active_meter) do
      create(:gas_meter, mpan_mprn: 12_345_678, active: true, school: create(:school, school_group: school_group))
    end
    let!(:inactive_meter) do
      create(:gas_meter, mpan_mprn: 87_654_321, active: false, school: create(:school, school_group: school_group))
    end

    let(:all_meters) { false }
    let(:meter_report) { SchoolGroups::MeterReport.new(school_group, all_meters: all_meters) }

    before do
      described_class.with(to: to, meter_report: meter_report).school_group_meters_report.deliver
    end

    context 'All meters' do
      let(:all_meters) { true }

      it {
        expect(email.subject).to eql("[energy-sparks-unknown] Energy Sparks - Meter report for #{school_group.name} - all meters")
      }
    end

    context 'Only active meters' do
      let(:all_meters) { false }

      it {
        expect(email.subject).to eql("[energy-sparks-unknown] Energy Sparks - Meter report for #{school_group.name} - active meters")
      }
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

  describe '#lagging_data_sources' do
    let(:admin) { create(:admin) }
    let(:data_source) { create(:data_source, alert_percentage_threshold: 50, name: 'Lagging Source') }
    let(:school) { create(:school) }
    let(:lagging) { data_source.exceeded_alert_threshold? ? [data_source] : [] }

    context 'when showing data sources which have exceeded their threshold' do
      before do
        [create(:gas_meter, active: true, data_source:, school:),
         create_list(:gas_meter_with_validated_reading_dates, 3, end_date: 11.days.ago, active: true, data_source:,
                                                                 school:)]
        described_class.with(to: :admin, lagging:).lagging_data_sources.deliver if lagging.present?
      end

      it { expect(email.subject).to eq '[energy-sparks-unknown] Energy Sparks - Lagging Data Sources' }
      it { expect(email).to have_link('Data Sources', href: admin_data_sources_url) }

      it 'shows table with data' do
        expect(email).to have_link('Lagging Source', href: admin_data_source_url(data_source))
        expect(email).to have_content('4')
        expect(email).to have_content('3')
        expect(email).to have_content('75')
        expect(email).to have_content('50')
      end
    end

    context 'when there are no lagging data sources' do
      before do
        described_class.with(to: :admin, lagging:).lagging_data_sources.deliver if lagging.present?
      end

      it 'does not send email' do
        expect(email).to be_nil
      end
    end

    context 'when there are only inactive lagging meters' do
      let(:inactive_lagging_meter) do
        2.times do
          create(:gas_meter_with_validated_reading_dates, end_date: 11.days.ago, active: false, data_source:,
                                                          school: school)
        end
      end

      it 'does not send an email' do
        expect(email).to be_nil
      end
    end
  end
end

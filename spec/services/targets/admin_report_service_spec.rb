require 'rails_helper'

describe Targets::AdminReportService, type: :service do
  let(:school_group)         { create(:school_group) }
  let!(:school)              { create(:school, school_group: school_group) }
  let!(:school_target)       { create(:school_target, school: school) }
  let(:progress_summary)     { build(:progress_summary, school_target: school_target) }

  let(:service) { Targets::AdminReportService.new }

  before do
    allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
    allow_any_instance_of(Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
    allow_any_instance_of(Targets::ProgressService).to receive(:progress_summary).and_return(progress_summary)
  end

  describe '#progress_report_as_csv' do
    let(:report) { service.progress_report_as_csv }

    it 'is not empty' do
      expect(report).not_to be_nil
      expect(CSV.parse(report).size).to eq 2
    end

    it 'has expected data' do
      array = CSV.parse(report)[1]
      expect(array).to eq([
                            school_group.name,
                            school.name,
                            'true',
                            'true',
                            school_target.start_date.strftime('%Y-%m-%d').to_s,
                            school_target.target_date.strftime('%Y-%m-%d').to_s,
                            "-#{school_target.electricity}%",
                            FormatEnergyUnit.format(:relative_percent, progress_summary.electricity_progress.progress, :html, false, true, :target).to_s,
                            "-#{school_target.gas}%",
                            FormatEnergyUnit.format(:relative_percent, progress_summary.gas_progress.progress, :html, false, true, :target).to_s,
                            "-#{school_target.storage_heaters}%",
                            FormatEnergyUnit.format(:relative_percent, progress_summary.storage_heater_progress.progress, :html, false, true, :target).to_s
                          ])
    end
  end

  describe '#target_data_report_as_csv' do
    let(:report) { service.target_data_report_as_csv }

    before do
      allow_any_instance_of(School).to receive(:has_electricity?).and_return(true)
      allow_any_instance_of(School).to receive(:has_gas?).and_return(false)
      allow_any_instance_of(School).to receive(:has_storage_heaters?).and_return(false)
      allow_any_instance_of(TargetsService).to receive(:enough_holidays?).and_return(true)
      allow_any_instance_of(TargetsService).to receive(:enough_temperature_data?).and_return(true)
      allow_any_instance_of(TargetsService).to receive(:enough_readings_to_calculate_target?).and_return(true)
      allow_any_instance_of(TargetsService).to receive(:annual_kwh_estimate_required?).and_return(false)
      allow_any_instance_of(TargetsService).to receive(:annual_kwh_estimate?).and_return(false)
      allow_any_instance_of(TargetsService).to receive(:can_calculate_one_year_of_synthetic_data?).and_return(true)
      allow_any_instance_of(TargetsService).to receive(:recent_data?).and_return(true)
    end

    it 'is not empty' do
      expect(report).not_to be_nil
      expect(CSV.parse(report).size).to eq 2
    end

    it 'has expected data' do
      array = CSV.parse(report)[1]
      expect(array).to eq([
                            school_group.name,
                            school.name,
                            'true',
                            'true',
                            'electricity',
                            'true',
                            'true',
                            'true',
                            'true',
                            'false',
                            'false',
                            'true'
                          ])
    end
  end

  describe '#send_email_report' do
    before do
      service.send_email_report
    end

    let(:email)       { ActionMailer::Base.deliveries.last }
    # use html_part here as this is a multi-part mime message with attachment
    let(:email_body)  { email.html_part.body.to_s }
    let(:today)       { Time.zone.now.strftime('%Y-%m-%d') }

    it 'sends an email' do
      expect(ActionMailer::Base.deliveries.count).to be 1
    end

    it 'has right recipient' do
      expect(email.to).to contain_exactly('operations@energysparks.uk')
    end

    it 'has the right subject' do
      expect(email.subject).to eql 'Target Progress and Data Report'
    end

    it 'includes summary' do
      expect(email_body).to include('There are 1 currently active school targets')
    end

    it 'has the expected 2 attachments' do
      expect(email.attachments.first.mime_type).to eql 'text/csv'
      expect(email.attachments.first.filename).to eql "progress-report-#{today}.csv"
      expect(email.attachments.last.mime_type).to eql 'text/csv'
      expect(email.attachments.last.filename).to eql "target-data-report-#{today}.csv"
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe SchoolGroupMeterReportJob do
  subject(:job) { described_class.new }

  let(:school_group) { create(:school_group) }
  let(:to) { 'admin@example.com' }

  before { stub_env(SEND_AUTOMATED_EMAILS: true) }

  describe '#perform' do
    [false, true].each do |all_meters|
      context "when all_meters is #{all_meters}" do
        it 'delivers the meter report to the requested recipient' do
          expect { job.perform(to:, school_group:, all_meters:) }.to \
            change { ActionMailer::Base.deliveries.count }.by(1)
          email = ActionMailer::Base.deliveries.last
          expect(email.to).to eq([to])
          expect(email.subject).to eq('[energy-sparks-unknown] Energy Sparks - Meter report for ' \
                                      "#{school_group.name} - #{all_meters ? 'all' : 'active'} meters")
        end
      end
    end
  end
end

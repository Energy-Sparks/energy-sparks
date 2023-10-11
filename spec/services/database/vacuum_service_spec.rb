require 'rails_helper'

describe Database::VacuumService do
  subject(:vacuum_service) { Database::VacuumService.new(tables) }

  let(:tables) { %i[amr_data_feed_readings amr_reading_warnings] }

  describe '#perform' do
    # Vacuum can't run inside in a transaction block! ts: false means we don't use transactions for rolling back data created in tests
    context 'under normal running conditions', ts: false do
      it "doesn't raise" do
        expect { subject.perform }.not_to raise_error
      end

      it 'logs no error' do
        expect(Rails.logger).not_to receive(:error)
        subject.perform
      end
    end

    context 'an error occurs' do
      before do
        tables.each do |table|
          expect(ActiveRecord::Base.connection).to receive(:execute).with("VACUUM ANALYSE #{table}").and_raise(ActiveRecord::ActiveRecordError.new('ERROR'))
        end
      end

      it 'logs error' do
        tables.each do |table|
          expect(Rails.logger).to receive(:error).with("VACUUM ANALYSE #{table} error: ERROR")
        end
        subject.perform
      end

      it 'calls rollbar' do
        tables.each do |table|
          expect(Rollbar).to receive(:error).with("VACUUM ANALYSE #{table} error: ERROR")
        end
        subject.perform
      end

      it "doesn't raise" do
        expect { subject.perform }.not_to raise_error
      end
    end
  end
end

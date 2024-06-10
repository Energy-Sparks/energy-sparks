require 'rails_helper'

describe Database::VacuumService do
  # Vacuum can't run inside in a transaction block!
  self.use_transactional_tests = false

  let(:tables) { [:amr_data_feed_readings, :amr_reading_warnings] }

  subject(:vacuum_service) { Database::VacuumService.new(tables) }

  describe '#perform' do
    context 'under normal running conditions' do
      it "doesn't raise" do
        expect { subject.perform(vacuum: true) }.not_to raise_error
      end

      it 'logs no error' do
        expect(Rails.logger).not_to receive(:error)
        subject.perform(vacuum: true)
      end
    end

    context 'with analyse only' do
      before do
        tables.each do |table|
          expect(ActiveRecord::Base.connection).to receive(:execute).with("ANALYSE #{table}").and_raise(ActiveRecord::ActiveRecordError.new('ERROR'))
        end
      end

      it 'logs expected sql' do
        tables.each do |table|
          expect(Rails.logger).to receive(:error).with("ANALYSE #{table} error: ERROR")
        end
        subject.perform
      end
    end

    context 'an error occurs' do
      before do
        tables.each do |table|
          expect(ActiveRecord::Base.connection).to receive(:execute).with("VACUUM ANALYSE #{table}").and_raise(ActiveRecord::ActiveRecordError.new('ERROR'))
        end
      end

      it 'logs expected sql' do
        tables.each do |table|
          expect(Rails.logger).to receive(:error).with("VACUUM ANALYSE #{table} error: ERROR")
        end
        subject.perform(vacuum: true)
      end

      it 'calls rollbar' do
        tables.each do |table|
          expect(Rollbar).to receive(:error).with("VACUUM ANALYSE #{table} error: ERROR")
        end
        subject.perform(vacuum: true)
      end

      it "doesn't raise" do
        expect { subject.perform(vacuum: true) }.not_to raise_error
      end
    end
  end
end

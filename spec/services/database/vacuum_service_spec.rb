require 'rails_helper'

describe Database::VacuumService do

  let(:tables) { [:amr_data_feed_readings, :amr_reading_warnings] }
  subject(:vacuum_service) { Database::VacuumService.new(tables) }

  describe "#perform" do
    context "under normal running conditions" do
      it "calls vacuum analyse on each table" do
        tables.each do |table|
          expect(ActiveRecord::Base.connection).to receive(:execute).with("VACUUM ANALYSE #{table}")
        end
        subject.perform
      end

      it "doesn't raise" do
        expect { subject.perform }.not_to raise_error
      end
    end

    context "an error occurs" do
      before do
        tables.each do |table|
          expect(ActiveRecord::Base.connection).to receive(:execute).with("VACUUM ANALYSE #{table}").and_raise("ERROR")
        end
      end

      it "logs error" do
        tables.each do |table|
          expect(Rails.logger).to receive(:error).with("VACUUM ANALYSE #{table} error: ERROR")
        end
        subject.perform
      end

      it "calls rollbar" do
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

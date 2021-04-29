require 'rails_helper'

module Amr
  describe N3rgyReadingsUpserter do

    let(:meter)           { create(:electricity_meter) }
    let(:config)          { create(:amr_data_feed_config)}
    let(:end_date)     { Date.today }
    let(:start_date) { end_date - 1 }
    let(:readings)        {
      {
        meter.meter_type => {
            mpan_mprn:        meter.mpan_mprn,
            readings:         { start_date: OneDayAMRReading.new(meter.mpan_mprn, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)) },
            missing_readings: []
          }
      }
    }
    let(:import_log)    { create(:amr_data_feed_import_log) }

    let(:upserter) { Amr::N3rgyReadingsUpserter.new(meter: meter, config: config, readings: readings, import_log: import_log) }

    it "inserts new readings" do
      expect( AmrDataFeedReading.count ).to eql 0
      upserter.perform
      expect( AmrDataFeedReading.count ).to eql 1
    end

    it "handles empty reading for meter" do
      expect( AmrDataFeedReading.count ).to eql 0
      readings[meter.meter_type][:readings] = {}
      upserter.perform
      expect( AmrDataFeedReading.count ).to eql 0
    end

    it "logs counts of inserts and updates" do
      expect(import_log).to receive(:update).with(records_imported: 1, records_updated: 0)
      upserter.perform
    end

    context  "if mpan is new" do

      let(:readings) {
        {
          meter.meter_type => {
            mpan_mprn:      meter.mpan_mprn,
            readings:       { start_date: OneDayAMRReading.new("1234567890009", start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)) },
            missing_readings: []
          }
        }
      }

      it "does not create meters" do
        upserter.perform
        expect( Meter.count ).to eql 1
        expect( Meter.first.id ).to eql meter.id
      end
    end

  end
end

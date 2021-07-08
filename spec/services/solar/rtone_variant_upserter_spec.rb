require 'rails_helper'

module Solar
  describe RtoneVariantUpserter do

    let(:meter)         { create(:electricity_meter) }
    let(:installation)  { create(:rtone_variant_installation, meter: meter)}
    let(:import_log)    { create(:amr_data_feed_import_log) }

    let(:start_date)    { Date.today - 1 }

    let(:readings)      {
      {
        mpan_mprn:        meter.mpan_mprn,
        readings:         { start_date: OneDayAMRReading.new(meter.mpan_mprn, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)) },
        missing_readings: []
      }
    }

    let(:upserter) { Solar::RtoneVariantUpserter.new(rtone_variant_installation: installation, readings: readings, import_log: import_log) }

    it "inserts new readings" do
      expect( AmrDataFeedReading.count ).to eql 0
      upserter.perform
      expect( AmrDataFeedReading.count ).to eql 1
    end

  end
end

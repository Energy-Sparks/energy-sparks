require 'rails_helper'

module Amr
  describe N3rgyDownloader do
    let(:n3rgy_api) { double("n3rgy_api") }
    let(:meter)     { create(:electricity_meter) }
    let(:config)    { create(:amr_data_feed_config)}
    let(:today)     { Date.today }
    let(:yesterday) { today - 1 }

    it "should invoke the api" do
      expect(n3rgy_api).to receive(:readings)
      loader = Amr::N3rgyDownloader.new( n3rgy_api: n3rgy_api, meter: meter, start_date: nil, end_date: nil)
      loader.readings
    end

    it "should pass in correct params" do
      expect(n3rgy_api).to receive(:readings).with(meter.mpan_mprn, meter.meter_type, today, yesterday)
      loader = Amr::N3rgyDownloader.new( n3rgy_api: n3rgy_api, meter: meter, start_date: today, end_date: yesterday )
      loader.readings
    end

  end
end

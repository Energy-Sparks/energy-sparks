require 'rails_helper'

module Amr
  describe SingleReadConverter do
    context 'normal file format' do
      let(:readings) do
        [{ :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 00:30:00", :readings => ["14.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 01:00:00", :readings => ["15"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 01:30:00", :readings => ["15.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 02:00:00", :readings => ["15"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 02:30:00", :readings => ["15"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 03:00:00", :readings => ["15"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 03:30:00", :readings => ["14.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 04:00:00", :readings => ["15.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 04:30:00", :readings => ["15"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 05:00:00", :readings => ["15.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 05:30:00", :readings => ["15.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 06:00:00", :readings => ["19.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 06:30:00", :readings => ["29.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 07:00:00", :readings => ["29.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 07:30:00", :readings => ["30.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 08:00:00", :readings => ["29.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 08:30:00", :readings => ["34.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 09:00:00", :readings => ["34.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 09:30:00", :readings => ["34.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 10:00:00", :readings => ["33.5"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 10:30:00", :readings => ["33.5"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 11:00:00", :readings => ["33.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 11:30:00", :readings => ["33.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 12:00:00", :readings => ["34.5"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 12:30:00", :readings => ["33.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 13:00:00", :readings => ["34"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 13:30:00", :readings => ["32.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 14:00:00", :readings => ["34.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 14:30:00", :readings => ["35.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 15:00:00", :readings => ["33"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 15:30:00", :readings => ["33.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 16:00:00", :readings => ["32.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 16:30:00", :readings => ["33.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 17:00:00", :readings => ["37.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 17:30:00", :readings => ["38.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 18:00:00", :readings => ["37.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 18:30:00", :readings => ["36.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 19:00:00", :readings => ["32.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 19:30:00", :readings => ["33.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 20:00:00", :readings => ["31.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 20:30:00", :readings => ["27.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 21:00:00", :readings => ["23.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 21:30:00", :readings => ["16.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 22:00:00", :readings => ["16.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 22:30:00", :readings => ["15.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 23:00:00", :readings => ["15.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 23:30:00", :readings => ["15.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 00:00:00", :readings => ["15.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 00:30:00", :readings => ["1.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 01:00:00", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 01:30:00", :readings => ["1.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 02:00:00", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 02:30:00", :readings => ["1.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 03:00:00", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 03:30:00", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 04:00:00", :readings => ["1.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 04:30:00", :readings => ["6.5"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 05:00:00", :readings => ["2.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 05:30:00", :readings => ["3.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 06:00:00", :readings => ["1.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 06:30:00", :readings => ["1.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 07:00:00", :readings => ["2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 07:30:00", :readings => ["3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 08:00:00", :readings => ["2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 08:30:00", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 09:00:00", :readings => ["1.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 09:30:00", :readings => ["1.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 10:00:00", :readings => ["1.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 10:30:00", :readings => ["0.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 11:00:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 11:30:00", :readings => ["0.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 12:00:00", :readings => ["1.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 12:30:00", :readings => ["0.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 13:00:00", :readings => ["0.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 13:30:00", :readings => ["0.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 14:00:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 14:30:00", :readings => ["1.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 15:00:00", :readings => ["1.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 15:30:00", :readings => ["2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 16:00:00", :readings => ["2.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 16:30:00", :readings => ["3.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 17:00:00", :readings => ["1.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 17:30:00", :readings => ["0.5"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 18:00:00", :readings => ["0.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 18:30:00", :readings => ["0.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 19:00:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 19:30:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 20:00:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 20:30:00", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 21:00:00", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 21:30:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 22:00:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 22:30:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 23:00:00", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 23:30:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "28 Aug 2019 00:00:00", :readings => ["1.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 00:30:00", :readings => ["1.4"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 01:00:00", :readings => ["1.3"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 01:30:00", :readings => ["1.4"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 02:00:00", :readings => ["1.3"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 02:30:00", :readings => ["1.4"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 03:00:00", :readings => ["1.3"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 03:30:00", :readings => ["1.3"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 04:00:00", :readings => ["1.4"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 04:30:00", :readings => ["6.5"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 05:00:00", :readings => ["2.3"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 05:30:00", :readings => ["3.2"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 06:00:00", :readings => ["1.8"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 06:30:00", :readings => ["1.6"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 07:00:00", :readings => ["2"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 07:30:00", :readings => ["3"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 08:00:00", :readings => ["2"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 08:30:00", :readings => ["1.3"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 09:00:00", :readings => ["1.7"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 09:30:00", :readings => ["1.4"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 10:00:00", :readings => ["1.1"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 10:30:00", :readings => ["0.9"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 11:00:00", :readings => ["1.2"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 11:30:00", :readings => ["0.9"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 12:00:00", :readings => ["1.7"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 12:30:00", :readings => ["0.8"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 13:00:00", :readings => ["0.8"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 13:30:00", :readings => ["0.8"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 14:00:00", :readings => ["1.2"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 14:30:00", :readings => ["1.1"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 15:00:00", :readings => ["1.7"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 15:30:00", :readings => ["2"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 16:00:00", :readings => ["2.8"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 16:30:00", :readings => ["3.8"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 17:00:00", :readings => ["1.6"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 17:30:00", :readings => ["0.5"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 18:00:00", :readings => ["0.7"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 18:30:00", :readings => ["0.9"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 19:00:00", :readings => ["1.2"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 19:30:00", :readings => ["1.2"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 20:00:00", :readings => ["1.2"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 20:30:00", :readings => ["1.3"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 21:00:00", :readings => ["1.3"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 21:30:00", :readings => ["1.2"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 22:00:00", :readings => ["1.2"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 22:30:00", :readings => ["1.2"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 23:00:00", :readings => ["1.3"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "27 Aug 2019 23:30:00", :readings => ["1.2"], meter_id: 123 },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168314", :reading_date => "28 Aug 2019 00:00:00", :readings => ["1.6"], meter_id: 123 },
                      ]
      end

      let(:output) do
        [{ amr_data_feed_config_id: 6, meter_id: nil, reading_date: Date.parse('26 Aug 2019'), mpan_mprn: "1710035168313", readings: [14.4, 15.0, 15.1, 15.0, 15.0, 15.0, 14.9, 15.1, 15.0, 15.1, 15.7, 19.6, 29.9, 29.7, 30.2, 29.6, 34.1, 34.4, 34.7, 33.5, 33.5, 33.4, 33.6, 34.5, 33.7, 34.0, 32.7, 34.2, 35.1, 33.0, 33.4, 32.6, 33.1, 37.6, 38.9, 37.7, 36.7, 32.9, 33.1, 31.1, 27.6, 23.3, 16.7, 16.6, 15.9, 15.6, 15.4, 15.2] },
         { amr_data_feed_config_id: 6, meter_id: nil, reading_date: Date.parse('27 Aug 2019'), mpan_mprn: "1710035168313", readings: [1.4, 1.3, 1.4, 1.3, 1.4, 1.3, 1.3, 1.4, 6.5, 2.3, 3.2, 1.8, 1.6, 2.0, 3.0, 2.0, 1.3, 1.7, 1.4, 1.1, 0.9, 1.2, 0.9, 1.7, 0.8, 0.8, 0.8, 1.2, 1.1, 1.7, 2.0, 2.8, 3.8, 1.6, 0.5, 0.7, 0.9, 1.2, 1.2, 1.2, 1.3, 1.3, 1.2, 1.2, 1.2, 1.3, 1.2, 1.6] },
         { amr_data_feed_config_id: 6, meter_id: 123, reading_date: Date.parse('27 Aug 2019'), mpan_mprn: "1710035168314", readings: [1.4, 1.3, 1.4, 1.3, 1.4, 1.3, 1.3, 1.4, 6.5, 2.3, 3.2, 1.8, 1.6, 2.0, 3.0, 2.0, 1.3, 1.7, 1.4, 1.1, 0.9, 1.2, 0.9, 1.7, 0.8, 0.8, 0.8, 1.2, 1.1, 1.7, 2.0, 2.8, 3.8, 1.6, 0.5, 0.7, 0.9, 1.2, 1.2, 1.2, 1.3, 1.3, 1.2, 1.2, 1.2, 1.3, 1.2, 1.6] },]
      end

      it 'converts a list of single readings per half hour into a day per reading format' do
        expect(SingleReadConverter.new(readings).perform).to eq output
      end
    end

    context 'offset file format' do
      let(:offset_readings) do
        [{ :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 00:00:00", :readings => ["13.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 00:30:00", :readings => ["14.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 01:00:00", :readings => ["15"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 01:30:00", :readings => ["15.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 02:00:00", :readings => ["15"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 02:30:00", :readings => ["15"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 03:00:00", :readings => ["15"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 03:30:00", :readings => ["14.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 04:00:00", :readings => ["15.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 04:30:00", :readings => ["15"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 05:00:00", :readings => ["15.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 05:30:00", :readings => ["15.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 06:00:00", :readings => ["19.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 06:30:00", :readings => ["29.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 07:00:00", :readings => ["29.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 07:30:00", :readings => ["30.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 08:00:00", :readings => ["29.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 08:30:00", :readings => ["34.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 09:00:00", :readings => ["34.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 09:30:00", :readings => ["34.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 10:00:00", :readings => ["33.5"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 10:30:00", :readings => ["33.5"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 11:00:00", :readings => ["33.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 11:30:00", :readings => ["33.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 12:00:00", :readings => ["34.5"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 12:30:00", :readings => ["33.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 13:00:00", :readings => ["34"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 13:30:00", :readings => ["32.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 14:00:00", :readings => ["34.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 14:30:00", :readings => ["35.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 15:00:00", :readings => ["33"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 15:30:00", :readings => ["33.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 16:00:00", :readings => ["32.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 16:30:00", :readings => ["33.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 17:00:00", :readings => ["37.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 17:30:00", :readings => ["38.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 18:00:00", :readings => ["37.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 18:30:00", :readings => ["36.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 19:00:00", :readings => ["32.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 19:30:00", :readings => ["33.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 20:00:00", :readings => ["31.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 20:30:00", :readings => ["27.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 21:00:00", :readings => ["23.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 21:30:00", :readings => ["16.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 22:00:00", :readings => ["16.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 22:30:00", :readings => ["15.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 23:00:00", :readings => ["15.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "26 Aug 2019 23:30:00", :readings => ["15.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 00:00:00", :readings => ["15.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 00:30:00", :readings => ["1.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 01:00:00", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 01:30:00", :readings => ["1.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 02:00:00", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 02:30:00", :readings => ["1.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 03:00:00", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 03:30:00", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 04:00:00", :readings => ["1.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 04:30:00", :readings => ["6.5"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 05:00:00", :readings => ["2.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 05:30:00", :readings => ["3.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 06:00:00", :readings => ["1.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 06:30:00", :readings => ["1.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 07:00:00", :readings => ["2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 07:30:00", :readings => ["3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 08:00:00", :readings => ["2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 08:30:00", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 09:00:00", :readings => ["1.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 09:30:00", :readings => ["1.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 10:00:00", :readings => ["1.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 10:30:00", :readings => ["0.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 11:00:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 11:30:00", :readings => ["0.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 12:00:00", :readings => ["1.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 12:30:00", :readings => ["0.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 13:00:00", :readings => ["0.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 13:30:00", :readings => ["0.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 14:00:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 14:30:00", :readings => ["1.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 15:00:00", :readings => ["1.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 15:30:00", :readings => ["2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 16:00:00", :readings => ["2.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 16:30:00", :readings => ["3.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 17:00:00", :readings => ["1.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 17:30:00", :readings => ["0.5"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 18:00:00", :readings => ["0.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 18:30:00", :readings => ["0.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 19:00:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 19:30:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 20:00:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 20:30:00", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 21:00:00", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 21:30:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 22:00:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 22:30:00", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 23:00:00", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => "27 Aug 2019 23:30:00", :readings => ["1.2"] },
                      ]
      end

      let(:offset_output) do
        [
          { amr_data_feed_config_id: 6, meter_id: nil, reading_date: Date.parse('26 Aug 2019'), mpan_mprn: "1710035168313", readings: [14.4, 15.0, 15.1, 15.0, 15.0, 15.0, 14.9, 15.1, 15.0, 15.1, 15.7, 19.6, 29.9, 29.7, 30.2, 29.6, 34.1, 34.4, 34.7, 33.5, 33.5, 33.4, 33.6, 34.5, 33.7, 34.0, 32.7, 34.2, 35.1, 33.0, 33.4, 32.6, 33.1, 37.6, 38.9, 37.7, 36.7, 32.9, 33.1, 31.1, 27.6, 23.3, 16.7, 16.6, 15.9, 15.6, 15.4, 15.2] },
          { amr_data_feed_config_id: 6, meter_id: nil, reading_date: Date.parse('27 Aug 2019'), mpan_mprn: "1710035168313", readings: [1.4, 1.3, 1.4, 1.3, 1.4, 1.3, 1.3, 1.4, 6.5, 2.3, 3.2, 1.8, 1.6, 2.0, 3.0, 2.0, 1.3, 1.7, 1.4, 1.1, 0.9, 1.2, 0.9, 1.7, 0.8, 0.8, 0.8, 1.2, 1.1, 1.7, 2.0, 2.8, 3.8, 1.6, 0.5, 0.7, 0.9, 1.2, 1.2, 1.2, 1.3, 1.3, 1.2, 1.2, 1.2, 1.3, 1.2, nil] },
        ]
      end

      it 'converts a list of single readings per half hour into a day per reading format' do
        expect(SingleReadConverter.new(offset_readings).perform).to eq offset_output
      end
    end

    context 'With reading dates in ISO 8601 format (produced by xlsx to csv conversion)' do
      let(:reading_date) { Time.zone.parse('26 Aug 2019') }
      let(:readings) { 48.times.collect {|i| { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => (reading_date + ((i + 1) * 30).minutes).iso8601, :readings => [(i + 1).to_s] } } }
      let(:output) { [{ amr_data_feed_config_id: 6, meter_id: nil, reading_date: reading_date.to_date, mpan_mprn: "1710035168313", readings: 48.times.collect {|i| (i + 1) } }] }

      it 'converts a list of single readings per half hour into a day per reading format' do
        expect(SingleReadConverter.new(readings).perform).to eq output
      end
    end

    context 'split date and time column file format' do
      let(:readings) do
        [
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '00:00', :reading_date => "26/08/2019", :readings => ["14.4"] }, #1
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '00:30', :reading_date => "26/08/2019", :readings => ["15"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '01:00', :reading_date => "26/08/2019", :readings => ["15.1"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '01:30', :reading_date => "26/08/2019", :readings => ["15"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '02:00', :reading_date => "26/08/2019", :readings => ["15"] }, #5
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '02:30', :reading_date => "26/08/2019", :readings => ["15"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '03:00', :reading_date => "26/08/2019", :readings => ["14.9"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '03:30', :reading_date => "26/08/2019", :readings => ["15.1"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '04:00', :reading_date => "26/08/2019", :readings => ["15"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '04:30', :reading_date => "26/08/2019", :readings => ["15.1"] }, #10
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '05:00', :reading_date => "26/08/2019", :readings => ["15.7"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '05:30', :reading_date => "26/08/2019", :readings => ["19.6"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '06:00', :reading_date => "26/08/2019", :readings => ["29.9"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '06:30', :reading_date => "26/08/2019", :readings => ["29.7"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '07:00', :reading_date => "26/08/2019", :readings => ["30.2"] }, #15
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '07:30', :reading_date => "26/08/2019", :readings => ["29.6"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '08:00', :reading_date => "26/08/2019", :readings => ["34.1"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '08:30', :reading_date => "26/08/2019", :readings => ["34.4"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '09:00', :reading_date => "26/08/2019", :readings => ["34.7"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '09:30', :reading_date => "26/08/2019", :readings => ["33.5"] }, #20
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '10:00', :reading_date => "26/08/2019", :readings => ["33.5"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '10:30', :reading_date => "26/08/2019", :readings => ["33.4"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '11:00', :reading_date => "26/08/2019", :readings => ["33.6"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '11:30', :reading_date => "26/08/2019", :readings => ["34.5"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '12:00', :reading_date => "26/08/2019", :readings => ["33.7"] }, #25
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '12:30', :reading_date => "26/08/2019", :readings => ["34"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '13:00', :reading_date => "26/08/2019", :readings => ["32.7"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '13:30', :reading_date => "26/08/2019", :readings => ["34.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '14:00', :reading_date => "26/08/2019", :readings => ["35.1"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '14:30', :reading_date => "26/08/2019", :readings => ["33"] }, #30
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '15:00', :reading_date => "26/08/2019", :readings => ["33.4"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '15:30', :reading_date => "26/08/2019", :readings => ["32.6"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '16:00', :reading_date => "26/08/2019", :readings => ["33.1"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '16:30', :reading_date => "26/08/2019", :readings => ["37.6"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '17:00', :reading_date => "26/08/2019", :readings => ["38.9"] }, #35
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '17:30', :reading_date => "26/08/2019", :readings => ["37.7"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '18:00', :reading_date => "26/08/2019", :readings => ["36.7"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '18:30', :reading_date => "26/08/2019", :readings => ["32.9"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '19:00', :reading_date => "26/08/2019", :readings => ["33.1"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '19:30', :reading_date => "26/08/2019", :readings => ["31.1"] }, #40
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '20:00', :reading_date => "26/08/2019", :readings => ["27.6"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '20:30', :reading_date => "26/08/2019", :readings => ["23.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '21:00', :reading_date => "26/08/2019", :readings => ["16.7"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '21:30', :reading_date => "26/08/2019", :readings => ["16.6"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '22:00', :reading_date => "26/08/2019", :readings => ["15.9"] }, #45
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '22:30', :reading_date => "26/08/2019", :readings => ["15.6"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '23:00', :reading_date => "26/08/2019", :readings => ["15.4"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '23:30', :reading_date => "26/08/2019", :readings => ["48.0"] }, #48
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '00:00', :reading_date => "27/08/2019", :readings => ["15.2"] }, #1
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '00:30', :reading_date => "27/08/2019", :readings => ["1.4"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '01:00', :reading_date => "27/08/2019", :readings => ["1.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '01:30', :reading_date => "27/08/2019", :readings => ["1.4"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '02:00', :reading_date => "27/08/2019", :readings => ["1.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '02:30', :reading_date => "27/08/2019", :readings => ["1.4"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '03:00', :reading_date => "27/08/2019", :readings => ["1.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '03:30', :reading_date => "27/08/2019", :readings => ["1.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '04:00', :reading_date => "27/08/2019", :readings => ["1.4"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '04:30', :reading_date => "27/08/2019", :readings => ["6.5"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '05:00', :reading_date => "27/08/2019", :readings => ["2.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '05:30', :reading_date => "27/08/2019", :readings => ["3.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '06:00', :reading_date => "27/08/2019", :readings => ["1.8"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '06:30', :reading_date => "27/08/2019", :readings => ["1.6"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '07:00', :reading_date => "27/08/2019", :readings => ["2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '07:30', :reading_date => "27/08/2019", :readings => ["3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '08:00', :reading_date => "27/08/2019", :readings => ["2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '08:30', :reading_date => "27/08/2019", :readings => ["1.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '09:00', :reading_date => "27/08/2019", :readings => ["1.7"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '09:30', :reading_date => "27/08/2019", :readings => ["1.4"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '10:00', :reading_date => "27/08/2019", :readings => ["1.1"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '10:30', :reading_date => "27/08/2019", :readings => ["0.9"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '11:00', :reading_date => "27/08/2019", :readings => ["1.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '11:30', :reading_date => "27/08/2019", :readings => ["0.9"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '12:00', :reading_date => "27/08/2019", :readings => ["1.7"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '12:30', :reading_date => "27/08/2019", :readings => ["0.8"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '13:00', :reading_date => "27/08/2019", :readings => ["0.8"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '13:30', :reading_date => "27/08/2019", :readings => ["0.8"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '14:00', :reading_date => "27/08/2019", :readings => ["1.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '14:30', :reading_date => "27/08/2019", :readings => ["1.1"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '15:00', :reading_date => "27/08/2019", :readings => ["1.7"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '15:30', :reading_date => "27/08/2019", :readings => ["2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '16:00', :reading_date => "27/08/2019", :readings => ["2.8"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '16:30', :reading_date => "27/08/2019", :readings => ["3.8"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '17:00', :reading_date => "27/08/2019", :readings => ["1.6"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '17:30', :reading_date => "27/08/2019", :readings => ["0.5"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '18:00', :reading_date => "27/08/2019", :readings => ["0.7"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '18:30', :reading_date => "27/08/2019", :readings => ["0.9"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '19:00', :reading_date => "27/08/2019", :readings => ["1.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '19:30', :reading_date => "27/08/2019", :readings => ["1.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '20:00', :reading_date => "27/08/2019", :readings => ["1.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '20:30', :reading_date => "27/08/2019", :readings => ["1.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '21:00', :reading_date => "27/08/2019", :readings => ["1.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '21:30', :reading_date => "27/08/2019", :readings => ["1.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '22:00', :reading_date => "27/08/2019", :readings => ["1.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '22:30', :reading_date => "27/08/2019", :readings => ["1.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '23:00', :reading_date => "27/08/2019", :readings => ["1.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '23:30', :reading_date => "27/08/2019", :readings => ["99.0"] }
        ]
      end

      let(:indexed_output) do
        [
          { amr_data_feed_config_id: 6, meter_id: nil, reading_date: Date.parse('26 Aug 2019'), mpan_mprn: "1710035168313", readings: [14.4, 15.0, 15.1, 15.0, 15.0, 15.0, 14.9, 15.1, 15.0, 15.1, 15.7, 19.6, 29.9, 29.7, 30.2, 29.6, 34.1, 34.4, 34.7, 33.5, 33.5, 33.4, 33.6, 34.5, 33.7, 34.0, 32.7, 34.2, 35.1, 33.0, 33.4, 32.6, 33.1, 37.6, 38.9, 37.7, 36.7, 32.9, 33.1, 31.1, 27.6, 23.3, 16.7, 16.6, 15.9, 15.6, 15.4, 48.0] },
          { amr_data_feed_config_id: 6, meter_id: nil, reading_date: Date.parse('27 Aug 2019'), mpan_mprn: "1710035168313", readings: [15.2, 1.4, 1.3, 1.4, 1.3, 1.4, 1.3, 1.3, 1.4, 6.5, 2.3, 3.2, 1.8, 1.6, 2.0, 3.0, 2.0, 1.3, 1.7, 1.4, 1.1, 0.9, 1.2, 0.9, 1.7, 0.8, 0.8, 0.8, 1.2, 1.1, 1.7, 2.0, 2.8, 3.8, 1.6, 0.5, 0.7, 0.9, 1.2, 1.2, 1.2, 1.3, 1.3, 1.2, 1.2, 1.2, 1.3, 99.0] },
        ]
      end

      it 'converts a list of single readings per half hour into a day per reading format' do
        results = SingleReadConverter.new(readings, indexed: true).perform
        expect(results).to eq indexed_output
      end

      it 'handles files with multiple mpans' do
        #create test data that consists of 2 days readings for 2 different meters
        two_meters_worth_of_readings = readings + readings.map {|r| { amr_data_feed_config_id: 6, mpan_mprn: "123456789012", reading_date: r[:reading_date], period: r[:period], readings: r[:readings] } }

        results = SingleReadConverter.new(two_meters_worth_of_readings, indexed: true).perform

        #create expected output: 2 x 2 days readings for 2 meters
        expected_results = indexed_output + indexed_output.map {|r| { amr_data_feed_config_id: 6, meter_id: nil, mpan_mprn: "123456789012", reading_date: r[:reading_date], readings: r[:readings] } }

        expect(results).to eq expected_results
      end
    end

    context 'indexed file format' do
      let(:readings) do
        [{ :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 1, :reading_date => "26/08/2019", :readings => ["14.4"] }, #1
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 2, :reading_date => "26/08/2019", :readings => ["15"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 3, :reading_date => "26/08/2019", :readings => ["15.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 4, :reading_date => "26/08/2019", :readings => ["15"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 5, :reading_date => "26/08/2019", :readings => ["15"] }, #5
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 6, :reading_date => "26/08/2019", :readings => ["15"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 7, :reading_date => "26/08/2019", :readings => ["14.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 8, :reading_date => "26/08/2019", :readings => ["15.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 9, :reading_date => "26/08/2019", :readings => ["15"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 10, :reading_date => "26/08/2019", :readings => ["15.1"] }, #10
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 11, :reading_date => "26/08/2019", :readings => ["15.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 12, :reading_date => "26/08/2019", :readings => ["19.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 13, :reading_date => "26/08/2019", :readings => ["29.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 14, :reading_date => "26/08/2019", :readings => ["29.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 15, :reading_date => "26/08/2019", :readings => ["30.2"] }, #15
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 16, :reading_date => "26/08/2019", :readings => ["29.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 17, :reading_date => "26/08/2019", :readings => ["34.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 18, :reading_date => "26/08/2019", :readings => ["34.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 19, :reading_date => "26/08/2019", :readings => ["34.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 20, :reading_date => "26/08/2019", :readings => ["33.5"] }, #20
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 21, :reading_date => "26/08/2019", :readings => ["33.5"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 22, :reading_date => "26/08/2019", :readings => ["33.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 23, :reading_date => "26/08/2019", :readings => ["33.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 24, :reading_date => "26/08/2019", :readings => ["34.5"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 25, :reading_date => "26/08/2019", :readings => ["33.7"] }, #25
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 26, :reading_date => "26/08/2019", :readings => ["34"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 27, :reading_date => "26/08/2019", :readings => ["32.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 28, :reading_date => "26/08/2019", :readings => ["34.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 29, :reading_date => "26/08/2019", :readings => ["35.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 30, :reading_date => "26/08/2019", :readings => ["33"] }, #30
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 31, :reading_date => "26/08/2019", :readings => ["33.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 32, :reading_date => "26/08/2019", :readings => ["32.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 33, :reading_date => "26/08/2019", :readings => ["33.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 34, :reading_date => "26/08/2019", :readings => ["37.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 35, :reading_date => "26/08/2019", :readings => ["38.9"] }, #35
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 36, :reading_date => "26/08/2019", :readings => ["37.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 37, :reading_date => "26/08/2019", :readings => ["36.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 38, :reading_date => "26/08/2019", :readings => ["32.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 39, :reading_date => "26/08/2019", :readings => ["33.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 40, :reading_date => "26/08/2019", :readings => ["31.1"] }, #40
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 41, :reading_date => "26/08/2019", :readings => ["27.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 42, :reading_date => "26/08/2019", :readings => ["23.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 43, :reading_date => "26/08/2019", :readings => ["16.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 44, :reading_date => "26/08/2019", :readings => ["16.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 45, :reading_date => "26/08/2019", :readings => ["15.9"] }, #45
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 46, :reading_date => "26/08/2019", :readings => ["15.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 47, :reading_date => "26/08/2019", :readings => ["15.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 48, :reading_date => "26/08/2019", :readings => ["48.0"] }, #48
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 1, :reading_date => "27/08/2019", :readings => ["15.2"] }, #1
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 2, :reading_date => "27/08/2019", :readings => ["1.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 3, :reading_date => "27/08/2019", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 4, :reading_date => "27/08/2019", :readings => ["1.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 5, :reading_date => "27/08/2019", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 6, :reading_date => "27/08/2019", :readings => ["1.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 7, :reading_date => "27/08/2019", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 8, :reading_date => "27/08/2019", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 9, :reading_date => "27/08/2019", :readings => ["1.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 10, :reading_date => "27/08/2019", :readings => ["6.5"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 11, :reading_date => "27/08/2019", :readings => ["2.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 12, :reading_date => "27/08/2019", :readings => ["3.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 13, :reading_date => "27/08/2019", :readings => ["1.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 14, :reading_date => "27/08/2019", :readings => ["1.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 15, :reading_date => "27/08/2019", :readings => ["2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 16, :reading_date => "27/08/2019", :readings => ["3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 17, :reading_date => "27/08/2019", :readings => ["2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 18, :reading_date => "27/08/2019", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 19, :reading_date => "27/08/2019", :readings => ["1.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 20, :reading_date => "27/08/2019", :readings => ["1.4"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 21, :reading_date => "27/08/2019", :readings => ["1.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 22, :reading_date => "27/08/2019", :readings => ["0.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 23, :reading_date => "27/08/2019", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 24, :reading_date => "27/08/2019", :readings => ["0.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 25, :reading_date => "27/08/2019", :readings => ["1.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 26, :reading_date => "27/08/2019", :readings => ["0.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 27, :reading_date => "27/08/2019", :readings => ["0.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 28, :reading_date => "27/08/2019", :readings => ["0.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 29, :reading_date => "27/08/2019", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 30, :reading_date => "27/08/2019", :readings => ["1.1"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 31, :reading_date => "27/08/2019", :readings => ["1.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 32, :reading_date => "27/08/2019", :readings => ["2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 33, :reading_date => "27/08/2019", :readings => ["2.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 34, :reading_date => "27/08/2019", :readings => ["3.8"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 35, :reading_date => "27/08/2019", :readings => ["1.6"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 36, :reading_date => "27/08/2019", :readings => ["0.5"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 37, :reading_date => "27/08/2019", :readings => ["0.7"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 38, :reading_date => "27/08/2019", :readings => ["0.9"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 39, :reading_date => "27/08/2019", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 40, :reading_date => "27/08/2019", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 41, :reading_date => "27/08/2019", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 42, :reading_date => "27/08/2019", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 43, :reading_date => "27/08/2019", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 44, :reading_date => "27/08/2019", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 45, :reading_date => "27/08/2019", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 46, :reading_date => "27/08/2019", :readings => ["1.2"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 47, :reading_date => "27/08/2019", :readings => ["1.3"] },
         { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: 48, :reading_date => "27/08/2019", :readings => ["99.0"] }, #48
                      ]
      end

      let(:indexed_output) do
        [
          { amr_data_feed_config_id: 6, meter_id: nil, reading_date: Date.parse('26 Aug 2019'), mpan_mprn: "1710035168313", readings: [14.4, 15.0, 15.1, 15.0, 15.0, 15.0, 14.9, 15.1, 15.0, 15.1, 15.7, 19.6, 29.9, 29.7, 30.2, 29.6, 34.1, 34.4, 34.7, 33.5, 33.5, 33.4, 33.6, 34.5, 33.7, 34.0, 32.7, 34.2, 35.1, 33.0, 33.4, 32.6, 33.1, 37.6, 38.9, 37.7, 36.7, 32.9, 33.1, 31.1, 27.6, 23.3, 16.7, 16.6, 15.9, 15.6, 15.4, 48.0] },
          { amr_data_feed_config_id: 6, meter_id: nil, reading_date: Date.parse('27 Aug 2019'), mpan_mprn: "1710035168313", readings: [15.2, 1.4, 1.3, 1.4, 1.3, 1.4, 1.3, 1.3, 1.4, 6.5, 2.3, 3.2, 1.8, 1.6, 2.0, 3.0, 2.0, 1.3, 1.7, 1.4, 1.1, 0.9, 1.2, 0.9, 1.7, 0.8, 0.8, 0.8, 1.2, 1.1, 1.7, 2.0, 2.8, 3.8, 1.6, 0.5, 0.7, 0.9, 1.2, 1.2, 1.2, 1.3, 1.3, 1.2, 1.2, 1.2, 1.3, 99.0] },
        ]
      end

      it 'converts a list of single readings per half hour into a day per reading format' do
        results = SingleReadConverter.new(readings, indexed: true).perform
        expect(results).to eq indexed_output
      end

      it 'handles files with multiple mpans' do
        #create test data that consists of 2 days readings for 2 different meters
        two_meters_worth_of_readings = readings + readings.map {|r| { amr_data_feed_config_id: 6, mpan_mprn: "123456789012", reading_date: r[:reading_date], period: r[:period], readings: r[:readings] } }

        results = SingleReadConverter.new(two_meters_worth_of_readings, indexed: true).perform

        #create expected output: 2 x 2 days readings for 2 meters
        expected_results = indexed_output + indexed_output.map {|r| { amr_data_feed_config_id: 6, meter_id: nil, mpan_mprn: "123456789012", reading_date: r[:reading_date], readings: r[:readings] } }

        expect(results).to eq expected_results
      end
    end

    context 'missing mpan_mprn' do
      let(:readings) { [{ :amr_data_feed_config_id => 6, :mpan_mprn => nil, reading_date: Date.parse('27 Aug 2019').to_s, readings: [15.2, 1.4, 1.3, 1.4, 1.3, 1.4, 1.3, 1.3, 1.4, 6.5, 2.3, 3.2, 1.8, 1.6, 2.0, 3.0, 2.0, 1.3, 1.7, 1.4, 1.1, 0.9, 1.2, 0.9, 1.7, 0.8, 0.8, 0.8, 1.2, 1.1, 1.7, 2.0, 2.8, 3.8, 1.6, 0.5, 0.7, 0.9, 1.2, 1.2, 1.2, 1.3, 1.3, 1.2, 1.2, 1.2, 1.3, 99.0] }] }

      it 'ignores row' do
        results = SingleReadConverter.new(readings).perform
        expect(results).to be_empty
      end
    end

    context 'missing date' do
      let(:readings) { [{ :amr_data_feed_config_id => 6, :mpan_mprn => "12345678", reading_date: nil, readings: [15.2, 1.4, 1.3, 1.4, 1.3, 1.4, 1.3, 1.3, 1.4, 6.5, 2.3, 3.2, 1.8, 1.6, 2.0, 3.0, 2.0, 1.3, 1.7, 1.4, 1.1, 0.9, 1.2, 0.9, 1.7, 0.8, 0.8, 0.8, 1.2, 1.1, 1.7, 2.0, 2.8, 3.8, 1.6, 0.5, 0.7, 0.9, 1.2, 1.2, 1.2, 1.3, 1.3, 1.2, 1.2, 1.2, 1.3, 99.0] }] }

      it 'ignores row' do
        results = SingleReadConverter.new(readings).perform
        expect(results).to be_empty
      end
    end

    context 'dodgy data' do
      let(:readings) { [{ :amr_data_feed_config_id => 6, :mpan_mprn => "Primary school", :reading_date => "123456789012", :readings => ["01/01/2019"] }] }

      it 'kind of handles dodgy data' do
        expect { SingleReadConverter.new(readings).perform }.to raise_error(ArgumentError)
      end
    end

    context 'more than 48 readings' do
      let(:readings) do
        data = []
        49.times { |idx| data << { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: idx + 1, :reading_date => "25/08/2019", :readings => ["14.4"] } }
        48.times { |idx| data << { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", period: idx + 1, :reading_date => "26/08/2019", :readings => ["7"] } }
        data
      end

      subject(:results) { SingleReadConverter.new(readings, indexed: true).perform }

      it "truncates after 48 readings" do
        expect(results.first[:readings].length).to be(48)
        expect(results.second[:readings].length).to be(48)
      end
    end
  end
end

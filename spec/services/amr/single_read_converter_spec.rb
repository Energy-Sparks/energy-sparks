require 'rails_helper'

module Amr
  describe SingleReadConverter do
    let(:valid_reading_times) do
      [
        '00:00', '0:00',
        '00:30', '0:30',
        '01:00', '1:00',
        '01:30', '1:30',
        '02:00', '2:00',
        '02:30', '2:30',
        '03:00', '3:00',
        '03:30', '3:30',
        '04:00', '4:00',
        '04:30', '4:30',
        '05:00', '5:00',
        '05:30', '5:30',
        '06:00', '6:00',
        '06:30', '6:30',
        '07:00', '7:00',
        '07:30', '7:30',
        '08:00', '8:00',
        '08:30', '8:30',
        '09:00', '9:00',
        '09:30', '9:30',
        '10:00', '10:30', '11:00', '11:30', '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00', '17:30', '18:00', '18:30', '19:00', '19:30', '20:00', '20:30', '21:00', '21:30', '22:00', '22:30', '23:00', '23:30'
      ]
    end

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
      let(:readings_2) { 48.times.collect {|i| { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", :reading_date => (reading_date + ((i + 1) * 30).minutes).iso8601, :readings => [(i + 1).to_s] } } }
      let(:output) { [{ amr_data_feed_config_id: 6, meter_id: nil, reading_date: reading_date.to_date, mpan_mprn: "1710035168313", readings: 48.times.collect {|i| (i + 1) } }] }

      it 'converts a list of single readings per half hour into a day per reading format' do
        expect(SingleReadConverter.new(readings_2).perform).to eq output
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
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '0', :reading_date => "27/08/2019", :readings => ["15.2"] }, #1
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '30', :reading_date => "27/08/2019", :readings => ["1.4"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '100', :reading_date => "27/08/2019", :readings => ["1.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '130', :reading_date => "27/08/2019", :readings => ["1.4"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '200', :reading_date => "27/08/2019", :readings => ["1.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '230', :reading_date => "27/08/2019", :readings => ["1.4"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '300', :reading_date => "27/08/2019", :readings => ["1.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '330', :reading_date => "27/08/2019", :readings => ["1.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '400', :reading_date => "27/08/2019", :readings => ["1.4"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '430', :reading_date => "27/08/2019", :readings => ["6.5"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '500', :reading_date => "27/08/2019", :readings => ["2.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '530', :reading_date => "27/08/2019", :readings => ["3.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '600', :reading_date => "27/08/2019", :readings => ["1.8"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '630', :reading_date => "27/08/2019", :readings => ["1.6"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '700', :reading_date => "27/08/2019", :readings => ["2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '730', :reading_date => "27/08/2019", :readings => ["3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '800', :reading_date => "27/08/2019", :readings => ["2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '830', :reading_date => "27/08/2019", :readings => ["1.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '900', :reading_date => "27/08/2019", :readings => ["1.7"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '930', :reading_date => "27/08/2019", :readings => ["1.4"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1000', :reading_date => "27/08/2019", :readings => ["1.1"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1030', :reading_date => "27/08/2019", :readings => ["0.9"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1100', :reading_date => "27/08/2019", :readings => ["1.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1130', :reading_date => "27/08/2019", :readings => ["0.9"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1200', :reading_date => "27/08/2019", :readings => ["1.7"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1230', :reading_date => "27/08/2019", :readings => ["0.8"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1300', :reading_date => "27/08/2019", :readings => ["0.8"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1330', :reading_date => "27/08/2019", :readings => ["0.8"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1400', :reading_date => "27/08/2019", :readings => ["1.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1430', :reading_date => "27/08/2019", :readings => ["1.1"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1500', :reading_date => "27/08/2019", :readings => ["1.7"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1530', :reading_date => "27/08/2019", :readings => ["2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1600', :reading_date => "27/08/2019", :readings => ["2.8"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1630', :reading_date => "27/08/2019", :readings => ["3.8"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1700', :reading_date => "27/08/2019", :readings => ["1.6"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1730', :reading_date => "27/08/2019", :readings => ["0.5"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1800', :reading_date => "27/08/2019", :readings => ["0.7"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1830', :reading_date => "27/08/2019", :readings => ["0.9"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1900', :reading_date => "27/08/2019", :readings => ["1.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '1930', :reading_date => "27/08/2019", :readings => ["1.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '2000', :reading_date => "27/08/2019", :readings => ["1.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '2030', :reading_date => "27/08/2019", :readings => ["1.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '2100', :reading_date => "27/08/2019", :readings => ["1.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '2130', :reading_date => "27/08/2019", :readings => ["1.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '2200', :reading_date => "27/08/2019", :readings => ["1.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '2230', :reading_date => "27/08/2019", :readings => ["1.2"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '2300', :reading_date => "27/08/2019", :readings => ["1.3"] },
          { :amr_data_feed_config_id => 6, :mpan_mprn => "1710035168313", reading_time: '2330', :reading_date => "27/08/2019", :readings => ["99.0"] }
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
        two_meters_worth_of_readings = readings + readings.map {|r| { amr_data_feed_config_id: 6, mpan_mprn: "123456789012", reading_date: r[:reading_date], reading_time: r[:reading_time], readings: r[:readings] } }

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

    describe '.convert_time_string_to_usable_time' do
      it 'converts a string of numbers to a valid time string' do
        valid_reading_times.each do |time_string|
          expect(Amr::SingleReadConverter.convert_time_string_to_usable_time(time_string)).to eq(time_string)
        end

        # There's an additional test for possible zero values below so drop the first 2 valid_reading_times
        valid_reading_times.drop(2).each do |time_string|
          time_string_without_colon = time_string.delete(':')
          expect(Amr::SingleReadConverter.convert_time_string_to_usable_time(time_string_without_colon)).to eq(time_string.rjust(5, '0'))
        end

        %w[0 00 000 0000].each do |time_string|
          expect(Amr::SingleReadConverter.convert_time_string_to_usable_time(time_string)).to eq('00:00')
        end

        expect(Amr::SingleReadConverter.convert_time_string_to_usable_time('30')).to eq('00:30')
      end

      it 'raises an error if a string cannot be converted to a valid time string' do
        valid_reading_times.each do |time_string|
          time_string_as_integer = time_string.to_i
          expect do
            Amr::SingleReadConverter.convert_time_string_to_usable_time(time_string_as_integer)
          end.to raise_error(Amr::SingleReadConverter::InvalidTimeStringError)
        end

        ['abc', 130, 0o130, '24:00', '2400', '12345'].each do |time_string|
          expect do
            Amr::SingleReadConverter.convert_time_string_to_usable_time(time_string)
          end.to raise_error(Amr::SingleReadConverter::InvalidTimeStringError)
        end
      end
    end

    describe '.valid_time_string?' do
      it 'returns true if a time string is in a format valid and usable by TimeOfDay parse' do
        valid_reading_times.each do |time_string|
          expect(Amr::SingleReadConverter).to be_valid_time_string(time_string)
        end
      end

      it 'returns false if a time string is not in a format valid and usable by TimeOfDay parse' do
        ['0', '00', '000', '1', '130', 0, 1, 130, '24:30', '25:00'].each do |time_string|
          expect(Amr::SingleReadConverter).not_to be_valid_time_string(time_string)
        end
      end
    end
  end
end

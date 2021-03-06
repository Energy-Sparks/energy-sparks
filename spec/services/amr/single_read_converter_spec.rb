require 'rails_helper'

module Amr
  describe SingleReadConverter do
    context 'normal file format' do
      let(:readings) { [{:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 00:30:00", :readings=>["14.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 01:00:00", :readings=>["15"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 01:30:00", :readings=>["15.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 02:00:00", :readings=>["15"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 02:30:00", :readings=>["15"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 03:00:00", :readings=>["15"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 03:30:00", :readings=>["14.9"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 04:00:00", :readings=>["15.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 04:30:00", :readings=>["15"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 05:00:00", :readings=>["15.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 05:30:00", :readings=>["15.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 06:00:00", :readings=>["19.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 06:30:00", :readings=>["29.9"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 07:00:00", :readings=>["29.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 07:30:00", :readings=>["30.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 08:00:00", :readings=>["29.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 08:30:00", :readings=>["34.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 09:00:00", :readings=>["34.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 09:30:00", :readings=>["34.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 10:00:00", :readings=>["33.5"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 10:30:00", :readings=>["33.5"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 11:00:00", :readings=>["33.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 11:30:00", :readings=>["33.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 12:00:00", :readings=>["34.5"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 12:30:00", :readings=>["33.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 13:00:00", :readings=>["34"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 13:30:00", :readings=>["32.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 14:00:00", :readings=>["34.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 14:30:00", :readings=>["35.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 15:00:00", :readings=>["33"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 15:30:00", :readings=>["33.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 16:00:00", :readings=>["32.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 16:30:00", :readings=>["33.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 17:00:00", :readings=>["37.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 17:30:00", :readings=>["38.9"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 18:00:00", :readings=>["37.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 18:30:00", :readings=>["36.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 19:00:00", :readings=>["32.9"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 19:30:00", :readings=>["33.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 20:00:00", :readings=>["31.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 20:30:00", :readings=>["27.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 21:00:00", :readings=>["23.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 21:30:00", :readings=>["16.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 22:00:00", :readings=>["16.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 22:30:00", :readings=>["15.9"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 23:00:00", :readings=>["15.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 23:30:00", :readings=>["15.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 00:00:00", :readings=>["15.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 00:30:00", :readings=>["1.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 01:00:00", :readings=>["1.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 01:30:00", :readings=>["1.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 02:00:00", :readings=>["1.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 02:30:00", :readings=>["1.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 03:00:00", :readings=>["1.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 03:30:00", :readings=>["1.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 04:00:00", :readings=>["1.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 04:30:00", :readings=>["6.5"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 05:00:00", :readings=>["2.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 05:30:00", :readings=>["3.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 06:00:00", :readings=>["1.8"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 06:30:00", :readings=>["1.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 07:00:00", :readings=>["2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 07:30:00", :readings=>["3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 08:00:00", :readings=>["2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 08:30:00", :readings=>["1.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 09:00:00", :readings=>["1.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 09:30:00", :readings=>["1.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 10:00:00", :readings=>["1.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 10:30:00", :readings=>["0.9"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 11:00:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 11:30:00", :readings=>["0.9"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 12:00:00", :readings=>["1.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 12:30:00", :readings=>["0.8"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 13:00:00", :readings=>["0.8"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 13:30:00", :readings=>["0.8"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 14:00:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 14:30:00", :readings=>["1.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 15:00:00", :readings=>["1.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 15:30:00", :readings=>["2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 16:00:00", :readings=>["2.8"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 16:30:00", :readings=>["3.8"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 17:00:00", :readings=>["1.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 17:30:00", :readings=>["0.5"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 18:00:00", :readings=>["0.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 18:30:00", :readings=>["0.9"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 19:00:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 19:30:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 20:00:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 20:30:00", :readings=>["1.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 21:00:00", :readings=>["1.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 21:30:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 22:00:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 22:30:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 23:00:00", :readings=>["1.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 23:30:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"28 Aug 2019 00:00:00", :readings=>["1.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 00:30:00", :readings=>["1.4"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 01:00:00", :readings=>["1.3"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 01:30:00", :readings=>["1.4"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 02:00:00", :readings=>["1.3"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 02:30:00", :readings=>["1.4"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 03:00:00", :readings=>["1.3"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 03:30:00", :readings=>["1.3"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 04:00:00", :readings=>["1.4"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 04:30:00", :readings=>["6.5"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 05:00:00", :readings=>["2.3"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 05:30:00", :readings=>["3.2"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 06:00:00", :readings=>["1.8"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 06:30:00", :readings=>["1.6"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 07:00:00", :readings=>["2"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 07:30:00", :readings=>["3"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 08:00:00", :readings=>["2"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 08:30:00", :readings=>["1.3"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 09:00:00", :readings=>["1.7"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 09:30:00", :readings=>["1.4"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 10:00:00", :readings=>["1.1"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 10:30:00", :readings=>["0.9"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 11:00:00", :readings=>["1.2"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 11:30:00", :readings=>["0.9"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 12:00:00", :readings=>["1.7"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 12:30:00", :readings=>["0.8"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 13:00:00", :readings=>["0.8"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 13:30:00", :readings=>["0.8"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 14:00:00", :readings=>["1.2"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 14:30:00", :readings=>["1.1"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 15:00:00", :readings=>["1.7"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 15:30:00", :readings=>["2"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 16:00:00", :readings=>["2.8"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 16:30:00", :readings=>["3.8"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 17:00:00", :readings=>["1.6"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 17:30:00", :readings=>["0.5"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 18:00:00", :readings=>["0.7"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 18:30:00", :readings=>["0.9"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 19:00:00", :readings=>["1.2"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 19:30:00", :readings=>["1.2"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 20:00:00", :readings=>["1.2"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 20:30:00", :readings=>["1.3"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 21:00:00", :readings=>["1.3"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 21:30:00", :readings=>["1.2"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 22:00:00", :readings=>["1.2"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 22:30:00", :readings=>["1.2"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 23:00:00", :readings=>["1.3"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"27 Aug 2019 23:30:00", :readings=>["1.2"], meter_id: 123},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168314", :reading_date=>"28 Aug 2019 00:00:00", :readings=>["1.6"], meter_id: 123},
                      ] }

      let(:output) { [{ amr_data_feed_config_id: 6, meter_id: nil, reading_date: Date.parse('26 Aug 2019'), mpan_mprn: "1710035168313", readings: [14.4, 15.0, 15.1, 15.0, 15.0, 15.0, 14.9, 15.1, 15.0, 15.1, 15.7, 19.6, 29.9, 29.7, 30.2, 29.6, 34.1, 34.4, 34.7, 33.5, 33.5, 33.4, 33.6, 34.5, 33.7, 34.0, 32.7, 34.2, 35.1, 33.0, 33.4, 32.6, 33.1, 37.6, 38.9, 37.7, 36.7, 32.9, 33.1, 31.1, 27.6, 23.3, 16.7, 16.6, 15.9, 15.6, 15.4, 15.2]},
                      { amr_data_feed_config_id: 6, meter_id: nil, reading_date: Date.parse('27 Aug 2019'), mpan_mprn: "1710035168313", readings: [1.4, 1.3, 1.4, 1.3, 1.4, 1.3, 1.3, 1.4, 6.5, 2.3, 3.2, 1.8, 1.6, 2.0, 3.0, 2.0, 1.3, 1.7, 1.4, 1.1, 0.9, 1.2, 0.9, 1.7, 0.8, 0.8, 0.8, 1.2, 1.1, 1.7, 2.0, 2.8, 3.8, 1.6, 0.5, 0.7, 0.9, 1.2, 1.2, 1.2, 1.3, 1.3, 1.2, 1.2, 1.2, 1.3, 1.2, 1.6]},
                      { amr_data_feed_config_id: 6, meter_id: 123, reading_date: Date.parse('27 Aug 2019'), mpan_mprn: "1710035168314", readings: [1.4, 1.3, 1.4, 1.3, 1.4, 1.3, 1.3, 1.4, 6.5, 2.3, 3.2, 1.8, 1.6, 2.0, 3.0, 2.0, 1.3, 1.7, 1.4, 1.1, 0.9, 1.2, 0.9, 1.7, 0.8, 0.8, 0.8, 1.2, 1.1, 1.7, 2.0, 2.8, 3.8, 1.6, 0.5, 0.7, 0.9, 1.2, 1.2, 1.2, 1.3, 1.3, 1.2, 1.2, 1.2, 1.3, 1.2, 1.6]}, ] }

      it 'converts a list of single readings per half hour into a day per reading format' do
        expect(SingleReadConverter.new(readings).perform).to eq output
      end

    end

    context 'offset file format' do
      let(:offset_readings) { [{:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 00:00:00", :readings=>["13.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 00:30:00", :readings=>["14.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 01:00:00", :readings=>["15"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 01:30:00", :readings=>["15.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 02:00:00", :readings=>["15"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 02:30:00", :readings=>["15"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 03:00:00", :readings=>["15"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 03:30:00", :readings=>["14.9"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 04:00:00", :readings=>["15.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 04:30:00", :readings=>["15"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 05:00:00", :readings=>["15.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 05:30:00", :readings=>["15.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 06:00:00", :readings=>["19.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 06:30:00", :readings=>["29.9"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 07:00:00", :readings=>["29.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 07:30:00", :readings=>["30.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 08:00:00", :readings=>["29.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 08:30:00", :readings=>["34.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 09:00:00", :readings=>["34.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 09:30:00", :readings=>["34.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 10:00:00", :readings=>["33.5"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 10:30:00", :readings=>["33.5"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 11:00:00", :readings=>["33.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 11:30:00", :readings=>["33.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 12:00:00", :readings=>["34.5"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 12:30:00", :readings=>["33.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 13:00:00", :readings=>["34"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 13:30:00", :readings=>["32.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 14:00:00", :readings=>["34.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 14:30:00", :readings=>["35.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 15:00:00", :readings=>["33"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 15:30:00", :readings=>["33.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 16:00:00", :readings=>["32.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 16:30:00", :readings=>["33.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 17:00:00", :readings=>["37.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 17:30:00", :readings=>["38.9"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 18:00:00", :readings=>["37.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 18:30:00", :readings=>["36.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 19:00:00", :readings=>["32.9"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 19:30:00", :readings=>["33.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 20:00:00", :readings=>["31.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 20:30:00", :readings=>["27.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 21:00:00", :readings=>["23.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 21:30:00", :readings=>["16.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 22:00:00", :readings=>["16.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 22:30:00", :readings=>["15.9"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 23:00:00", :readings=>["15.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 23:30:00", :readings=>["15.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 00:00:00", :readings=>["15.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 00:30:00", :readings=>["1.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 01:00:00", :readings=>["1.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 01:30:00", :readings=>["1.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 02:00:00", :readings=>["1.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 02:30:00", :readings=>["1.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 03:00:00", :readings=>["1.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 03:30:00", :readings=>["1.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 04:00:00", :readings=>["1.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 04:30:00", :readings=>["6.5"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 05:00:00", :readings=>["2.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 05:30:00", :readings=>["3.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 06:00:00", :readings=>["1.8"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 06:30:00", :readings=>["1.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 07:00:00", :readings=>["2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 07:30:00", :readings=>["3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 08:00:00", :readings=>["2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 08:30:00", :readings=>["1.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 09:00:00", :readings=>["1.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 09:30:00", :readings=>["1.4"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 10:00:00", :readings=>["1.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 10:30:00", :readings=>["0.9"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 11:00:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 11:30:00", :readings=>["0.9"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 12:00:00", :readings=>["1.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 12:30:00", :readings=>["0.8"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 13:00:00", :readings=>["0.8"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 13:30:00", :readings=>["0.8"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 14:00:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 14:30:00", :readings=>["1.1"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 15:00:00", :readings=>["1.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 15:30:00", :readings=>["2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 16:00:00", :readings=>["2.8"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 16:30:00", :readings=>["3.8"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 17:00:00", :readings=>["1.6"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 17:30:00", :readings=>["0.5"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 18:00:00", :readings=>["0.7"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 18:30:00", :readings=>["0.9"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 19:00:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 19:30:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 20:00:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 20:30:00", :readings=>["1.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 21:00:00", :readings=>["1.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 21:30:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 22:00:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 22:30:00", :readings=>["1.2"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 23:00:00", :readings=>["1.3"]},
                        {:amr_data_feed_config_id=>6, :mpan_mprn=>"1710035168313", :reading_date=>"27 Aug 2019 23:30:00", :readings=>["1.2"]},
                      ] }

      let(:offset_output) { [
                      { amr_data_feed_config_id: 6, meter_id: nil, reading_date: Date.parse('26 Aug 2019'), mpan_mprn: "1710035168313", readings: [14.4, 15.0, 15.1, 15.0, 15.0, 15.0, 14.9, 15.1, 15.0, 15.1, 15.7, 19.6, 29.9, 29.7, 30.2, 29.6, 34.1, 34.4, 34.7, 33.5, 33.5, 33.4, 33.6, 34.5, 33.7, 34.0, 32.7, 34.2, 35.1, 33.0, 33.4, 32.6, 33.1, 37.6, 38.9, 37.7, 36.7, 32.9, 33.1, 31.1, 27.6, 23.3, 16.7, 16.6, 15.9, 15.6, 15.4, 15.2]},
                      { amr_data_feed_config_id: 6, meter_id: nil, reading_date: Date.parse('27 Aug 2019'), mpan_mprn: "1710035168313", readings: [1.4, 1.3, 1.4, 1.3, 1.4, 1.3, 1.3, 1.4, 6.5, 2.3, 3.2, 1.8, 1.6, 2.0, 3.0, 2.0, 1.3, 1.7, 1.4, 1.1, 0.9, 1.2, 0.9, 1.7, 0.8, 0.8, 0.8, 1.2, 1.1, 1.7, 2.0, 2.8, 3.8, 1.6, 0.5, 0.7, 0.9, 1.2, 1.2, 1.2, 1.3, 1.3, 1.2, 1.2, 1.2, 1.3, 1.2, nil]},
                       ] }

      it 'converts a list of single readings per half hour into a day per reading format' do
        expect(SingleReadConverter.new(offset_readings).perform).to eq offset_output
      end
    end

    context 'dodgy data' do
      let(:readings) { [{:amr_data_feed_config_id=>6, :mpan_mprn=>"Primary school", :reading_date=>"123456789012", :readings=>["01/01/2019"]}] }

      it 'kind of handles dodgy data' do
        expect{ SingleReadConverter.new(readings).perform }.to raise_error(ArgumentError)
      end
    end
  end
end

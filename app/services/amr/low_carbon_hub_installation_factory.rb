require 'dashboard'

module Amr
  class LowCarbonHubInstallationFactory
    def initialize(school, rbee_meter_id, low_carbon_hub_api = LowCarbonHubMeterReadings.new)
      @low_carbon_hub_api = low_carbon_hub_api
      @school = school
      @rbee_meter_id = rbee_meter_id
    end

    def perform
      installation = LowCarbonHubInstallation.create(school: @school, rbee_meter_id: @rbee_meter_id, information: information)
      meter_setup(installation)
    end

    private

    def meter_setup(installation)
      initial_readings

# {:solar_pv=>
#   {:mpan_mprn=>70000000123085, :readings=>
#     {Tue, 02 Aug 2016=>#<OneDayAMRReading:0x00007fc0e68208f8 @meter_id="70000000123085", @date=Tue, 02 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>,
#     Wed, 03 Aug 2016=>#<OneDayAMRReading:0x00007fc0e6820830 @meter_id="70000000123085", @date=Wed, 03 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>,
#     Thu, 04 Aug 2016=>#<OneDayAMRReading:0x00007fc0e6820768 @meter_id="70000000123085", @date=Thu, 04 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>,
#     Fri, 05 Aug 2016=>#<OneDayAMRReading:0x00007fc0e68206a0 @meter_id="70000000123085", @date=Fri, 05 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>,
#     Sat, 06 Aug 2016=>#<OneDayAMRReading:0x00007fc0e68205d8 @meter_id="70000000123085", @date=Sat, 06 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>,
#     Sun, 07 Aug 2016=>#<OneDayAMRReading:0x00007fc0e6820510 @meter_id="70000000123085", @date=Sun, 07 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.239, 0.254, 0.062, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.5549999999999999>}, :missing_readings=>[]},

#     :electricity=>{:mpan_mprn=>90000000123085, :readings=>{Tue, 02 Aug 2016=>#<OneDayAMRReading:0x00007fc0e68203f8 @meter_id="90000000123085", @date=Tue, 02 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>,
#     Wed, 03 Aug 2016=>#<OneDayAMRReading:0x00007fc0e6820330 @meter_id="90000000123085", @date=Wed, 03 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>,
#     Thu, 04 Aug 2016=>#<OneDayAMRReading:0x00007fc0e6820268 @meter_id="90000000123085", @date=Thu, 04 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>,
#      Fri, 05 Aug 2016=>#<OneDayAMRReading:0x00007fc0e68201a0 @meter_id="90000000123085", @date=Fri, 05 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>,
#      Sat, 06 Aug 2016=>#<OneDayAMRReading:0x00007fc0e68200d8 @meter_id="90000000123085", @date=Sat, 06 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>,
#      Sun, 07 Aug 2016=>#<OneDayAMRReading:0x00007fc0e6820010 @meter_id="90000000123085", @date=Sun, 07 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>}, :missing_readings=>[]},
#      :exported_solar_pv=>{:mpan_mprn=>60000000123085, :readings=>{Tue, 02 Aug 2016=>#<OneDayAMRReading:0x00007fc0e682beb0 @meter_id="60000000123085", @date=Tue, 02 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>,
#      Wed, 03 Aug 2016=>#<OneDayAMRReading:0x00007fc0e682bde8 @meter_id="60000000123085", @date=Wed, 03 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>,
#      Thu, 04 Aug 2016=>#<OneDayAMRReading:0x00007fc0e682bd20 @meter_id="60000000123085", @date=Thu, 04 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>,
#      Fri, 05 Aug 2016=>#<OneDayAMRReading:0x00007fc0e682bc58 @meter_id="60000000123085", @date=Fri, 05 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>,
#      Sat, 06 Aug 2016=>#<OneDayAMRReading:0x00007fc0e682bb90 @meter_id="60000000123085", @date=Sat, 06 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>,
#      Sun, 07 Aug 2016=>#<OneDayAMRReading:0x00007fc0e682bac8 @meter_id="60000000123085", @date=Sun, 07 Aug 2016, @upload_datetime=Fri, 13 Sep 2019 13:49:31 +0100, @type="ORIG", @substitute_date=nil, @kwh_data_x48=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @one_day_kwh=0.0>}, :missing_readings=>[]}}

    end

    def information
      @low_carbon_hub_api.full_installation_information(@rbee_meter_id)
    end

    def initial_readings
      readings(first_reading_date, first_reading_date + 5.days)
    end

    def first_reading_date
      @low_carbon_hub_api.first_meter_reading_date(@rbee_meter_id)
    end

    def readings(start_date = Date.yesterday, end_date = Date.yesterday - 5.days)
      @low_carbon_hub_api.download(
        @rbee_meter_id,
        @school.urn,
        start_date,
        end_date
      )
    end
  end
end

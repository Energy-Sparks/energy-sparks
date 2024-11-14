module Solar
  class LowCarbonHubDownloadAndUpsert < BaseDownloadAndUpsert
    def initialize(
        installation:,
        start_date:,
        end_date:
      )
      super(start_date: start_date, end_date: end_date, installation: installation)
    end

    def download_and_upsert
      readings = LowCarbonHubDownloader.new(installation: @installation, start_date: start_date, end_date: end_date, api: low_carbon_hub_api).readings

      LowCarbonHubUpserter.new(installation: @installation, readings: readings, import_log: import_log).perform
    end

    def job
      :rtone_download
    end

    private

    def low_carbon_hub_api
      @low_carbon_hub_api ||= DataFeeds::LowCarbonHubMeterReadings.new(username, password)
    end

    def username
      @installation.username || ENV['ENERGYSPARKSRBEEUSERNAME']
    end

    def password
      @installation.password || ENV['ENERGYSPARKSRBEEPASSWORD']
    end
  end
end

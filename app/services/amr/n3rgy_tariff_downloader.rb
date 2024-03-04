module Amr
  # Response for fetching latest tariff data for a meter, then interpreting the
  # response so its ready for processing
  #
  # Because of the way v2 of n3rgy API works we can't request tariffs for specific
  # dates, just the tariffs as they are on the meter at the moment.
  #
  # The API always responds with the tariff information for yesterday and today.
  #
  # So we poll the tariffs on a daily basis and cannot access any historical tariffs.
  class N3rgyTariffDownloader
    def initialize(meter:)
      @meter = meter
    end

    # Returns parsed version of current tariff for meter. Or nil if there are
    # no tariffs on meter, or tariffs are unsupported.
    #
    # Returned hash has one of two forms:
    # {
    #   standingCharge: 0.0, flat_rate: 0.0
    # }
    #
    # OR
    #
    # { standingCharge: 0.0,
    #   differential: [{ start: "00:00", end: "07:00" value: 0.0, units: 'kwh'}]
    # }
    def current_tariff
      response = api_client.tariff(@meter.mpan_mprn, @meter.meter_type)
      return parse_tariff(response)
    end

    private

    # Parses an n3rgy API response for tariffs into a simpler structure compatible
    # with how we store tariff Information.
    #
    def parse_tariff(response)
      # Ignore if response isn't as expected
      return nil unless valid_response?(response)
      # Ignore if no tariffs stored on meter
      return nil unless tariffs_for_meter?(response)

      periods = yesterdays_price_periods(response)
      # Ignore if the tariffs aren't flat rate or differential
      # generates warning in Rollbar
      return nil unless supported_pricing?(periods)

      standing_charge = standing_charge(response)
      if periods.count == 1
        flat_rate = to_pounds(periods.first.dig('prices', 0, 'value'))
        {
          standing_charge: standing_charge,
          flat_rate: flat_rate
        }
      else
        {
          standing_charge: standing_charge,
          differential: differential_prices(periods)
        }
      end
    end

    def valid_response?(response)
      valid = response.dig('devices', 0, 'tariffs').present? &&
              response.dig('devices', 0, 'months').present?
      Rollbar.error('Unexpected/incomplete tariff response from n3rgy API', meter: @meter.mpan_mprn, school: @meter.school.name) unless valid
      valid
    end

    def standing_charge(response)
      to_pounds(fetch_tariff_key(response, 'standingCharge'))
    end

    # Accepts array of hashes of form:
    # { start: "00:00", end: "07:00", type: "TOU", value: 0.0 }
    #
    # Returns hash with adjusted time periods, value in pounds and
    # with units
    def differential_prices(periods)
      periods.map do |period|
        # Adjust to end of day
        end_time = period['end'] == '23:59' ? '00:00' : period['end']
        {
          start_time: period['start'],
          end_time: end_time,
          value: to_pounds(period['prices'][0]['value']),
          units: 'kwh'
        }
      end
    end

    # When the supplier has not pushed tariffs to the meter, then we
    # get a zero price from n3rgy rather than an empty or missing response.
    def tariffs_for_meter?(response)
      return false if nil_or_zero?(response, 'primaryActiveTariffPrice') || nil_or_zero?(response, 'standingCharge')
      true
    end

    def nil_or_zero?(response, key)
      val = fetch_tariff_key(response, key)
      val.nil? || val == 0.0
    end

    def fetch_tariff_key(response, key)
      response.dig('devices', 0, 'tariffs', 0, key)
    end

    # API response returns 2 days of tariffs. Yesterday and today
    # So fetch the time periods for the first day
    def yesterdays_price_periods(response)
      response.dig('devices', 0, 'months', 0, 'days', 0, 'timePeriods')
    end

    def supported_pricing?(periods)
      return false if periods.nil?
      return true if all_tou_prices?(periods)
      # Warn that school has non-TOU tariff
      Rollbar.warning('None TOU tariff returned by n3rgy API', meter: @meter.mpan_mprn, school: @meter.school.name)
      false
    end

    # We currently only support TOU (time of use) tariffs, not Block or others
    # Check the type associated with every price in every period
    def all_tou_prices?(periods)
      periods.all? do |period|
        period['prices'].present? && period['prices'].all? do |price|
          price['type'] == 'TOU'
        end
      end
    end

    # ROUNDING?
    def to_pounds(val)
      val.nil? ? nil : val / 100.0
    end

    def api_client
      DataFeeds::N3rgy::DataApiClient.production_client
    end
  end
end

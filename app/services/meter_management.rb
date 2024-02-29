require 'dashboard'

class MeterManagement
  include Wisper::Publisher

  def initialize(meter, n3rgy_api_factory: Amr::N3rgyApiFactory.new)
    @n3rgy_api_factory = n3rgy_api_factory
    @meter = meter
    subscribe(Targets::FuelTypeEventListener.new)
  end

  def n3rgy_consented?
    return false unless @meter.dcc_meter?
    mpxns = MeterReadingsFeeds::N3rgy.new(api_key: ENV['N3RGY_API_KEY'], production: true).mpxns
    mpxns.include? @meter.mpan_mprn
  rescue => e
    Rails.logger.warn "Error fetching list of consented mpans #{e.class} #{e.message}"
    Rails.logger.warn e.backtrace.join("\n")
    Rollbar.warning(e)
    return nil
  end

  def available_cache_range
    return [] unless @meter.dcc_meter?
    @n3rgy_api_factory.data_api(@meter).readings_available_date_range(@meter.mpan_mprn, @meter.fuel_type)
  rescue => e
    Rails.logger.warn "Error fetching available cache range for #{@meter.mpan_mprn} #{e.class} #{e.message}"
    Rails.logger.warn e.backtrace.join("\n")
    Rollbar.warning(e, meter: @meter.id, mpan: @meter.mpan_mprn)
    return [:api_error]
  end

  def is_meter_known_to_n3rgy?
    @n3rgy_api_factory.data_api(@meter).find(@meter.mpan_mprn)
  rescue => e
    Rails.logger.warn "Error looking up #{@meter.mpan_mprn} #{e.class} #{e.message}"
    Rails.logger.warn e.backtrace.join("\n")
    Rollbar.warning(e, meter: @meter.id, mpan: @meter.mpan_mprn)
    return false
  end

  def check_n3rgy_status
    @n3rgy_api_factory.data_api(@meter).status(@meter.mpan_mprn)
  rescue => e
    Rails.logger.warn "Error checking status of #{@meter.mpan_mprn} #{e.class} #{e.message}"
    Rails.logger.warn e.backtrace.join("\n")
    Rollbar.warning(e, meter: @meter.id, mpan: @meter.mpan_mprn)
    return :api_error
  end

  def process_creation!
    assign_amr_data_feed_readings
    DccCheckerJob.perform_later(@meter) if Meter.main_meter.exists?(@meter.id)
  end

  def process_mpan_mpnr_change!
    @meter.transaction do
      remove_amr_validated_readings
      nullify_amr_data_feed_readings
      assign_amr_data_feed_readings
    end
  end

  def delete_meter!
    @meter.transaction do
      AggregateSchoolService.new(@meter.school).invalidate_cache
      @meter.destroy
    end
  end

  def activate_meter!
    result = true
    @meter.transaction do
      @meter.update!(active: true)
      if @meter.can_grant_consent?
        result = Meters::DccGrantTrustedConsents.new([@meter]).perform
      end
    end
    broadcast(:meter_activated, @meter)
    result
  end

  def deactivate_meter!
    result = true
    @meter.transaction do
      @meter.update!(active: false)
    end
    broadcast(:meter_deactivated, @meter)
    result
  end

  def remove_data!(archive: false)
    result = true
    if @meter.can_withdraw_consent?
      Meters::DccWithdrawTrustedConsents.new([@meter]).perform
    end
    @meter.transaction do
      @meter.amr_data_feed_readings.delete_all unless archive
      @meter.amr_validated_readings.delete_all
    end
    result
  end

  private

  def assign_amr_data_feed_readings
    AmrDataFeedReading.where(mpan_mprn: @meter.mpan_mprn).update_all(meter_id: @meter.id)
  end

  def remove_amr_validated_readings
    @meter.amr_validated_readings.delete_all(:delete_all)
  end

  def nullify_amr_data_feed_readings
    @meter.amr_data_feed_readings.update_all(meter_id: nil)
  end
end

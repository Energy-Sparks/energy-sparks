require 'dashboard'

class MeterManagement
  def initialize(meter, n3rgy_api_factory: Amr::N3rgyApiFactory.new)
    @n3rgy_api_factory = n3rgy_api_factory
    @meter = meter
  end

  def check_n3rgy_status
    @n3rgy_api_factory.data_api(@meter).find(@meter.mpan_mprn)
  rescue => e
    Rails.logger.error "Exception: checking status of meter #{@meter.mpan_mprn} : #{e.class} #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    Rollbar.error(e)
    return :api_error
  end

  def elements
    return nil unless @meter.dcc_meter?
    @n3rgy_api_factory.data_api(@meter).elements(@meter.mpan_mprn, @meter.meter_type)
  rescue => e
    Rails.logger.error "Exception: checking elements of meter #{@meter.mpan_mprn} : #{e.class} #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    Rollbar.error(e)
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
      @meter.delete
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
    result
  end

  def deactivate_meter!
    result = true
    @meter.transaction do
      @meter.update!(active: false)
      if @meter.can_withdraw_consent?
        result = Meters::DccWithdrawTrustedConsents.new([@meter]).perform
      end
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

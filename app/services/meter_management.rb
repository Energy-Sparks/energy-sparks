require 'dashboard'

class MeterManagement
  include Wisper::Publisher

  def initialize(meter)
    @meter = meter
    subscribe(Targets::FuelTypeEventListener.new)
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
      if @meter.can_withdraw_consent?
        Meters::DccWithdrawTrustedConsents.new([@meter]).perform
      end
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
    Meters::DccWithdrawTrustedConsents.new([@meter]).perform if @meter.can_withdraw_consent?
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

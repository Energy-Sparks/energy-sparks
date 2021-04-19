module MeterAttributesHelper
  def build_tariff_attributes(meter)
    tariff_attributes = Amr::AnalyticsTariffFactory.new(meter).build
    return nil unless tariff_attributes.present?
    return sanitize(ap(tariff_attributes, index: false, plain: true))
  rescue => e
    Rails.logger.error "Exception: build tariff attributes for #{meter.mpan_mprn} : #{e.class} #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    Rollbar.error(e, meter_id: meter.mpan_mprn)
    e.message
  end
end

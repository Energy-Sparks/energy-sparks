class DccMailerPreview < ActionMailer::Preview
  def dcc_meter_status_email
    DccMailer.with(meter_ids: Meter.where(meter_type: Meter.non_gas_meter_types).sample(5).map(&:id)).dcc_meter_status_email
  end
end

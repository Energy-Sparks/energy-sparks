class DccMailer < ApplicationMailer
  def dcc_meter_status_email
    @meters = Meter.find(params[:meter_ids])
    make_bootstrap_mail(to: 'operations@energysparks.uk', subject: 'New smart meters found')
  end
end

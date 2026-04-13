# frozen_string_literal: true

class DccMailer < ApplicationMailer
  def dcc_meter_status_email(to: nil)
    @meters = Meter.find(params[:meter_ids])
    make_bootstrap_mail(to: to || 'operations@energysparks.uk', subject: 'New smart meters found')
  end
end

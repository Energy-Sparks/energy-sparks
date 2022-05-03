require 'twilio-ruby'

class SendSms
  def initialize(body, to_number)
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    @from_phone_number = ENV['TWILIO_PHONE_NUMBER']
    @twilio_client = Twilio::REST::Client.new(account_sid, auth_token)
    @body = body
    @to_number = to_number
  end

  def send
    @twilio_client.messages.create(body: @body, to: @to_number, from: @from_phone_number) unless ENV['SUPPRESS_ALERT_MESSAGES'] == 'true'
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe SendSms do
  describe '#send' do
    it 'calls expected URL' do
      stub = stub_request(:post, 'https://api.twilio.com/2010-04-01/Accounts//Messages.json')
             .with(body: { 'Body' => 'body text', 'From' => 'from_number', 'To' => 'to_number' })
             .to_return(status: 200)
      ClimateControl.modify(SEND_AUTOMATED_SMS: 'true', TWILIO_PHONE_NUMBER: 'from_number') do
        described_class.new('body text', 'to_number').send
      end
      expect(stub).to have_been_requested
    end
  end
end

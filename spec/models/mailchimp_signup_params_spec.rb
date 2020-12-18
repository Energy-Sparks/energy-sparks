require 'rails_helper'

describe MailchimpSignupParams do
  let(:email_address) { 'foo@bar.com' }
  let(:tags) { 'one, two' }
  let(:interests) { { '123' => 'abc', '456' => 'def'} }
  let(:merge_fields) { {} }

  before :each do
    @mailchimp_signup_params = MailchimpSignupParams.new(
        email_address: email_address,
        tags: tags,
        interests: interests,
        merge_fields: merge_fields)
  end

  context 'when all required parameters specified' do
    it 'is valid' do
      expect(@mailchimp_signup_params.valid?).to be true
    end
  end

  context 'when no interest specified' do
    let(:interests) { { '123' => '', '456' => ''} }
    it 'is not valid' do
      expect(@mailchimp_signup_params.valid?).to be false
      expect(@mailchimp_signup_params.errors[:interests]).to include("At least one group must be specified")
    end
  end
end

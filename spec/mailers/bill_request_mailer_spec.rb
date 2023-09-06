require 'rails_helper'

RSpec.describe BillRequestMailer do

  let(:user) { create(:user, preferred_locale: :cy) }
  let(:school) { create(:school, name: 'Test School') }
  let(:electricity_meter) { create(:electricity_meter) }
  let(:gas_meter) { create(:gas_meter) }

  around do |example|
    ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
      ClimateControl.modify WELSH_APPLICATION_HOST: 'cy.localhost' do
        example.run
      end
    end
  end

  before :each do
    BillRequestMailer.with_user_locales(users: [user], school: school, electricity_meters: [electricity_meter], gas_meters: [gas_meter]) { |mailer| mailer.request_bill.deliver_now }
    @email = ActionMailer::Base.deliveries.last
  end

  describe '#request_bill' do
    it 'sends an email with cy strings' do
      expect(@email.subject).to eql ("Uwchlwythwch fil ynni diweddar i Sbarcynni")
      expect(@email.body.to_s).to include("Uwchlwythwch fil ynni ar gyfer Test School")
      expect(@email.body.to_s).to include("http://cy.localhost/schools/test-school/consent_documents")
    end
  end
end

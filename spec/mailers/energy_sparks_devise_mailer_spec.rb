require 'rails_helper'

RSpec.describe EnergySparksDeviseMailer do
  let(:school)                { create(:school) }
  let(:user)                  { create(:user, school: school) }
  let(:country)               { "england" }

  around do |example|
    ClimateControl.modify WELSH_APPLICATION_HOST: 'cy.localhost' do
      example.run
    end
  end

  describe '#confirmation_instructions' do
    before do
      school.update(country: country)
      user.send_confirmation_instructions
      expect(ActionMailer::Base.deliveries.count).to be 1
      @email = ActionMailer::Base.deliveries.last
    end

    context 'when school has country of england' do
      it 'sends an email in en' do
        expect(@email.subject).to eq("Energy Sparks: confirm your account")
      end

      it 'contains links to default site but not cy site' do
        expect(@email.html_part.decoded).to include("http://localhost/users/confirmation?confirmation_token=")
        expect(@email.html_part.decoded).not_to include("http://cy.localhost/users/confirmation?confirmation_token=")
      end
    end

    context 'when school has country of wales' do
      let(:country) { "wales" }

      it 'sends an email in en and cy' do
        expect(@email.subject).to eq("Energy Sparks: confirm your account / Sbarcynni: cadarnhau eich cyfrif")
      end

      it 'contains links to default site and cy site' do
        expect(@email.html_part.decoded).to include("http://localhost/users/confirmation?confirmation_token=")
        expect(@email.html_part.decoded).to include("http://cy.localhost/users/confirmation?confirmation_token=")
      end
    end

    context 'when school has country of england' do
      let(:country) { "england" }

      it 'sends an email in en only' do
        expect(@email.subject).to eq("Energy Sparks: confirm your account")
      end
    end

    context 'when school group has country of wales (for group admins)' do
      let(:school_group)        { create(:school_group, default_country: 'wales') }
      let(:user)                { create(:group_admin, school_group: school_group) }

      it 'sends an email in en and cy' do
        expect(@email.subject).to eq("Energy Sparks: confirm your account / Sbarcynni: cadarnhau eich cyfrif")
      end
    end
  end
end

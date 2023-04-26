require 'rails_helper'

RSpec.describe 'AlertMailer', type: :system do

  let(:admin) { create(:admin) }
  let(:email) { create(:email) }

  context '#show' do
    before do
      sign_in(admin)
      visit admin_emails_alert_mailer_path(email)
    end

    it 'renders email' do
      expect(page).to have_content('Your weekly alerts')
      expect(page).to have_content('Why am I receiving these emails?')
    end
  end
end

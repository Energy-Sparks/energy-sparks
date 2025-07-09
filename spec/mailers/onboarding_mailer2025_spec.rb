# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OnboardingMailer2025 do
  let(:school) { create(:school, name: 'Test School', school_group: create(:school_group)) }
  let(:preferred_locale) { :en }

  around do |example|
    ClimateControl.modify WELSH_APPLICATION_HOST: 'cy.localhost' do
      create(:school_onboarding, school_name: 'Test School', created_by: user, school:, country: 'wales')
      create(:onboarding_user, school:, preferred_locale:)

      example.run
    end
  end

  def replace_variables(email_content)
    prefix = preferred_locale == :en ? '' : "#{preferred_locale}."
    ActionController::Base.helpers.sanitize(email_content.gsub('%{root_url}', "http://#{prefix}localhost/"))
  end

  def email
    ActionMailer::Base.deliveries.last
  end

  describe '#onboarded_email' do
    before do
      described_class.with_user_locales(users: [user], school: school) do |mailer|
        mailer.onboarded_email.deliver_now
      end
    end

    context 'when the preferred locale is en' do
      it 'sends the onboarded email in en' do
        expect(email.subject).to eq("#{school.name} is now live on Energy Sparks")
        translations = I18n.t('onboarding_mailer2025.onboarded_email.', locale: preferred_locale)
        expect(translations.length).to eq(9)
        html = Nokogiri::HTML(email.html_part.decoded)
        html.css('*[style]').each { |node| node.remove_attribute('style') }
        translations.except(:subject).each_value do |text|
          expect(html.to_s).to include(replace_variables(text))
        end
      end
    end
  end
end

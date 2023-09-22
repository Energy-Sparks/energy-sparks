require 'rails_helper'

RSpec.describe OnboardingMailer do
  let(:school)            { create(:school, name: 'Test School', school_group: create(:school_group)) }
  let(:preferred_locale)  { :cy }
  let(:user)              { create(:onboarding_user, school: school, preferred_locale: preferred_locale) }
  let(:country)           { 'wales' }
  let(:school_onboarding) { create(:school_onboarding, school_name: 'Test School', created_by: user, school: school, country: country) }
  let(:email)             { ActionMailer::Base.deliveries.last }

  around do |example|
    ClimateControl.modify WELSH_APPLICATION_HOST: 'cy.localhost' do
      example.run
    end
  end

  def replace_variables(email_content, locale=:en)
    prefix = (locale == :en) ? "" : "#{locale}."
    email_content.gsub('%{school_name}', school.name)
                 .gsub('%{contact_url}', "http://#{prefix}localhost/contact")
                 .gsub('%{activity_categories_url}', "http://#{prefix}localhost/activity_categories")
                 .gsub('%{intervention_type_groups_url}', "http://#{prefix}localhost/intervention_type_groups")
                 .gsub('%{school_url}', "http://#{prefix}localhost/schools/test-school")
                 .gsub('%{user_guide_videos_url}', "http://#{prefix}localhost/user-guide-youtube")
                 .gsub('%{training_url}', "http://#{prefix}localhost/training")
  end

  describe '#onboarding_email' do
    before { OnboardingMailer.with(school_onboarding: school_onboarding).onboarding_email.deliver_now }
    context "country is wales" do
      let(:country) { 'wales' }
      it "subject is in both languages" do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.onboarding_email.subject') + " / " + I18n.t('onboarding_mailer.onboarding_email.subject', locale: :cy))
      end
      it "has English text" do
        I18n.t('onboarding_mailer.onboarding_email').except(:subject).values.each do |email_content|
          expect(email.body.to_s).to include(email_content.gsub('%{school_name}', school.name))
        end
        expect(email.body.to_s).to include("http://localhost/school_setup/")
      end
      it "has Welsh text" do
        expect(email.body.to_s).to include(I18n.t('onboarding_mailer.onboarding_email.paragraph_1_html', school_name: school.name, locale: :cy))
        expect(email.body.to_s).to include(I18n.t('onboarding_mailer.onboarding_email.paragraph_2', locale: :cy))
        expect(email.body.to_s).to include(I18n.t('onboarding_mailer.onboarding_email.set_up_your_school_on_energy_sparks', locale: :cy))
        expect(email.body.to_s).to include("http://cy.localhost/school_setup/")
      end
    end
    context "country is england" do
      let(:country) { 'england' }
      it "subject is in English" do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.onboarding_email.subject'))
      end
      it "has English text" do
        I18n.t('onboarding_mailer.onboarding_email').except(:subject).values.each do |email_content|
          expect(email.body.to_s).to include(email_content.gsub('%{school_name}', school.name))
        end
        expect(email.body.to_s).to include("http://localhost/school_setup/")
      end
      it "does not have the Welsh text" do
        expect(email.body.to_s).to_not include(I18n.t('onboarding_mailer.onboarding_email.paragraph_1_html', school_name: school.name, locale: :cy))
        expect(email.body.to_s).to_not include(I18n.t('onboarding_mailer.onboarding_email.paragraph_2', locale: :cy))
        expect(email.body.to_s).to_not include(I18n.t('onboarding_mailer.onboarding_email.set_up_your_school_on_energy_sparks', locale: :cy))
        expect(email.body.to_s).to_not include("http://cy.localhost/school_setup/")
      end
    end
  end

  ##### this doesn't need translating as it's an admin email
  describe '#completion_email' do
    it 'sends the completion email' do
      OnboardingMailer.with(school_onboarding: school_onboarding).completion_email.deliver_now
      expect(email.subject).to eq(I18n.t('onboarding_mailer.completion_email.subject').gsub('%{school}', school.name).gsub('%{school_group}', school.area_name))
      I18n.t('onboarding_mailer.completion_email').except(:subject).values.each do |email_content|
        expect(email.body.to_s).to include(email_content.gsub('%{school_name}', school.name).gsub('%{school_group}', school.area_name))
      end
    end
  end

  describe '#reminder_email' do
    before { OnboardingMailer.with(school_onboarding: school_onboarding).reminder_email.deliver_now }
    context "country is wales" do
      let(:country) { 'wales' }
      it 'the subject is in both languages' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.reminder_email.subject') + " / " + I18n.t('onboarding_mailer.reminder_email.subject', locale: :cy))
      end
      it 'has the Welsh text' do
        I18n.t('onboarding_mailer.reminder_email', locale: :cy).except(:subject).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(email_content.gsub('%{school_name}', school.name))
        end
        expect(email.body.to_s).to include("http://cy.localhost/school_setup/")
      end
      it 'has the English text' do
        I18n.t('onboarding_mailer.reminder_email').except(:subject).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(email_content.gsub('%{school_name}', school.name))
        end
        expect(email.body.to_s).to include("http://localhost/school_setup/")
      end
    end

    context "country is england" do
      let(:country) { 'england' }
      it "has the English text" do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.reminder_email.subject'))
        I18n.t('onboarding_mailer.reminder_email').except(:subject).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(email_content.gsub('%{school_name}', school.name))
        end
        expect(email.body.to_s).to include("http://localhost/school_setup/")
      end
      it 'does not have Welsh text' do
        expect(email.subject).to_not include(I18n.t('onboarding_mailer.reminder_email.subject', locale: :cy))
        I18n.t('onboarding_mailer.reminder_email', locale: :cy).except(:subject).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to_not include(email_content.gsub('%{school_name}', school.name))
        end
        expect(email.body.to_s).to_not include("http://cy.localhost/school_setup/")
      end
    end
  end

  describe '#activation_email' do
    before { OnboardingMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.activation_email.deliver_now } }
    context "preferred locale is cy" do
      let(:preferred_locale) { :cy }
      it 'sends the activation email in cy' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.activation_email.subject', locale: :cy).gsub('%{school}', school.name))
        I18n.t('onboarding_mailer.activation_email', locale: :cy).except(:subject, :set_your_first_targets).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(
            replace_variables(email_content, :cy)
          )
        end
      end
    end
    context "preferred locale is en" do
      let(:preferred_locale) { :en }
      it 'sends the activation email in en' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.activation_email.subject').gsub('%{school}', school.name))
        I18n.t('onboarding_mailer.activation_email', locale: :en).except(:subject, :set_your_first_targets).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(
            replace_variables(email_content, :en)
          )
        end
      end
    end
  end

  describe '#onboarded_email' do
    before { OnboardingMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.onboarded_email.deliver_now } }
    context "preferred locale is cy" do
      let(:preferred_locale) { :cy }
      it 'sends the onboarded email in cy' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.onboarded_email.subject', locale: :cy).gsub('%{school}', school.name))
        I18n.t('onboarding_mailer.onboarded_email', locale: :cy).except(:subject).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(
            replace_variables(email_content, :cy)
          )
        end
      end
    end
    context "preferred locale is en" do
      let(:preferred_locale) { :en }
      it 'sends the onboarded email in en' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.onboarded_email.subject').gsub('%{school}', school.name))
        I18n.t('onboarding_mailer.onboarded_email', locale: :en).except(:subject).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(
            replace_variables(email_content, :en)
          )
        end
      end
    end
  end

  describe '#data_enabled_email' do
    before { OnboardingMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.data_enabled_email.deliver_now } }
    context "preferred locale is cy" do
      let(:preferred_locale) { :cy }
      it 'sends the data enabled_email in cy' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.data_enabled_email.subject', locale: :cy).gsub('%{school}', school.name))
        I18n.t('onboarding_mailer.data_enabled_email', locale: :cy).except(:subject, :set_your_first_targets).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(
            replace_variables(email_content, :cy)
          )
        end
      end
    end
    context "preferred locale is en" do
      let(:preferred_locale) { :en }
      it 'sends the data enabled_email in en' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.data_enabled_email.subject', locale: :en).gsub('%{school}', school.name))
        I18n.t('onboarding_mailer.data_enabled_email', locale: :en).except(:subject, :set_your_first_targets).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(
            replace_variables(email_content, :en)
          )
        end
      end
    end
  end

  describe '#welcome_email' do
    before { OnboardingMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.welcome_email.deliver_now } }
    context "preferred locale is cy" do
      let(:preferred_locale) { :cy }
      it 'sends the welcome email in cy' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.welcome_email.subject', locale: :cy))
        I18n.t('onboarding_mailer.welcome_email', locale: :cy).except(:subject).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(
            replace_variables(email_content, :cy)
          )
        end
      end
    end
    context "preferred locale is en" do
      let(:preferred_locale) { :en }
      it 'sends the welcome email in en' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.welcome_email.subject', locale: :en))
        I18n.t('onboarding_mailer.welcome_email', locale: :en).except(:subject).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(
            replace_variables(email_content, :en)
          )
        end
      end
    end
  end
end

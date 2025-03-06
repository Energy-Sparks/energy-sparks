require 'rails_helper'

RSpec.describe OnboardingMailer do
  let(:school)            { create(:school, name: 'Test School', school_group: create(:school_group)) }
  let(:preferred_locale)  { :cy }
  let(:user)              { create(:onboarding_user, school: school, preferred_locale: preferred_locale) }
  let(:country)           { 'wales' }
  let(:school_onboarding) { create(:school_onboarding, school_name: 'Test School', created_by: user, school: school, country: country) }
  let(:email)             { ActionMailer::Base.deliveries.last }
  let(:body) { ActionController::Base.helpers.sanitize(email.html_part.decoded) }

  around do |example|
    ClimateControl.modify WELSH_APPLICATION_HOST: 'cy.localhost' do
      example.run
    end
  end

  def replace_variables(email_content, locale: :en)
    prefix = locale == :en ? '' : "#{locale}."
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

    context 'country is wales' do
      let(:country) { 'wales' }

      it 'subject is in both languages' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.onboarding_email.subject') + ' / ' + I18n.t('onboarding_mailer.onboarding_email.subject', locale: :cy))
      end

      it 'has English text' do
        I18n.t('onboarding_mailer.onboarding_email').except(:subject).each_value do |email_content|
          expect(body).to include(email_content.gsub('%{school_name}', school.name))
        end
        expect(body).to include('http://localhost/school_setup/')
      end

      it 'has Welsh text' do
        expect(body).to include(I18n.t('onboarding_mailer.onboarding_email.paragraph_1_html', school_name: school.name, locale: :cy))
        expect(body).to include(I18n.t('onboarding_mailer.onboarding_email.paragraph_2', locale: :cy))
        expect(body).to include(I18n.t('onboarding_mailer.onboarding_email.set_up_your_school_on_energy_sparks', locale: :cy))
        expect(body).to include('http://cy.localhost/school_setup/')
      end
    end

    context 'country is england' do
      let(:country) { 'england' }

      it 'subject is in English' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.onboarding_email.subject'))
      end

      it 'has English text' do
        I18n.t('onboarding_mailer.onboarding_email').except(:subject).each_value do |email_content|
          expect(body).to include(email_content.gsub('%{school_name}', school.name))
        end
        expect(body).to include('http://localhost/school_setup/')
      end

      it 'does not have the Welsh text' do
        expect(body).not_to include(I18n.t('onboarding_mailer.onboarding_email.paragraph_1_html', school_name: school.name, locale: :cy))
        expect(body).not_to include(I18n.t('onboarding_mailer.onboarding_email.paragraph_2', locale: :cy))
        expect(body).not_to include(I18n.t('onboarding_mailer.onboarding_email.set_up_your_school_on_energy_sparks', locale: :cy))
        expect(body).not_to include('http://cy.localhost/school_setup/')
      end
    end
  end

  ##### this doesn't need translating as it's an admin email
  describe '#completion_email' do
    it 'sends the completion email' do
      OnboardingMailer.with(school_onboarding: school_onboarding).completion_email.deliver_now
      expect(email.subject).to eq(I18n.t('onboarding_mailer.completion_email.subject').gsub('%{school}', school.name).gsub('%{school_group}', school.area_name))
      I18n.t('onboarding_mailer.completion_email').except(:subject).each_value do |email_content|
        expect(body).to include(email_content.gsub('%{school_name}', school.name).gsub('%{school_group}', school.area_name))
      end
    end
  end

  shared_examples 'a reminder email in locale' do |locale:, context:|
    it "has the #{locale} text" do
      expect(body).to include(I18n.t("title.#{context}", scope: scope, locale: locale))
      expect(body).to include(I18n.t("paragraph_1_html.#{context}", scope: scope, locale: locale, school_name: school.name))
      expect(body).to include(I18n.t("paragraph_2.#{context}", scope: scope, locale: locale))
      expect(body).to include(I18n.t("paragraph_3.#{context}", scope: scope, locale: locale))
      expect(body).to include(I18n.t('the_energy_sparks_team', scope: scope, locale: locale))
    end

    it 'has the welsh link', if: locale == :cy do
      expect(body).to include('http://cy.localhost/school_setup/')
    end

    it 'has the english link', if: locale == :en do
      expect(body).to include('http://localhost/school_setup/')
    end
  end

  shared_examples 'a reminder email not in locale' do |locale:, context:|
    it "does not have the #{locale} text" do
      expect(body).not_to include(I18n.t("title.#{context}", scope: scope, locale: locale))
      expect(body).not_to include(I18n.t("paragraph_1_html.#{context}", scope: scope, locale: locale, school_name: school.name))
      expect(body).not_to include(I18n.t("paragraph_2.#{context}", scope: scope, locale: locale))
      expect(body).not_to include(I18n.t("paragraph_3.#{context}", scope: scope, locale: locale))
      expect(body).not_to include(I18n.t('the_energy_sparks_team', scope: scope, locale: locale))
    end

    it 'does not have the welsh link', if: locale == :cy do
      expect(body).not_to include('http://cy.localhost/school_setup/')
    end

    it 'does not have the english link', if: locale == :en do
      expect(body).not_to include('http://localhost/school_setup/')
    end
  end

  describe '#reminder_email' do
    before do
      OnboardingMailer.with(school_onboardings: school_onboardings, email: school_onboarding.contact_email).reminder_email.deliver_now
    end

    let(:scope) { [:onboarding_mailer, :reminder_email] }
    let(:school_onboardings) { [] }


    context 'country is wales' do
      let(:country) { 'wales' }

      context 'with single onboarding' do
        let(:school_onboardings) { [school_onboarding] }

        it 'singular subject is in both languages' do
          expect(email.subject).to eq(I18n.t('subject.one', scope: scope, locale: :en) + ' / ' + I18n.t('subject.one', scope: scope, locale: :cy))
        end

        it_behaves_like 'a reminder email in locale', locale: :cy, context: 'one'
        it_behaves_like 'a reminder email in locale', locale: :en, context: 'one'
      end

      context 'with multiple onboardings for same email address' do
        let(:school_onboardings) { [school_onboarding, create(:school_onboarding, contact_email: school_onboarding.contact_email)] }

        it 'the multiples subject is in both languages' do
          expect(email.subject).to eq(I18n.t('subject.other', scope: scope, locale: :en) + ' / ' + I18n.t('subject.other', scope: scope, locale: :cy))
        end

        it 'has links to schools for both languages' do
          expect(body).to have_link(school_onboardings[0].school_name,
            href: "http://localhost/school_setup/#{school_onboardings[0].uuid}")
          expect(body).to have_link(school_onboardings[0].school_name,
            href: "http://cy.localhost/school_setup/#{school_onboardings[0].uuid}")
          expect(body).to have_link(school_onboardings[1].school_name,
            href: "http://localhost/school_setup/#{school_onboardings[1].uuid}")
          expect(body).to have_link(school_onboardings[1].school_name,
            href: "http://cy.localhost/school_setup/#{school_onboardings[1].uuid}")
        end

        it_behaves_like 'a reminder email in locale', locale: :cy, context: 'other'
        it_behaves_like 'a reminder email in locale', locale: :en, context: 'other'
      end
    end

    context 'country is england' do
      let(:country) { 'england' }

      context 'with single onboarding' do
        let(:school_onboardings) { [school_onboarding] }

        it 'singular subject is in English only' do
          expect(email.subject).to eq(I18n.t('subject.one', scope: scope, locale: :en))
        end

        it_behaves_like 'a reminder email in locale', locale: :en, context: 'one'
        it_behaves_like 'a reminder email not in locale', locale: :cy, context: 'one'
      end

      context 'with multiple onboardings for same email address' do
        let(:school_onboardings) { [school_onboarding, create(:school_onboarding, contact_email: school_onboarding.contact_email)] }

        it 'the multiples subject is in English only' do
          expect(email.subject).to eq(I18n.t('subject.other', scope: scope, locale: :en))
        end

        it 'has links to schools in English' do
          expect(body).to have_link(school_onboardings[0].school_name,
            href: "http://localhost/school_setup/#{school_onboardings[0].uuid}")
          expect(body).to have_link(school_onboardings[1].school_name,
            href: "http://localhost/school_setup/#{school_onboardings[1].uuid}")
        end

        it "doesn't have links to schools in Welsh" do
          expect(body).not_to have_link(school_onboardings[0].school_name,
            href: "http://cy.localhost/school_setup/#{school_onboardings[0].uuid}")
          expect(body).not_to have_link(school_onboardings[1].school_name,
            href: "http://cy.localhost/school_setup/#{school_onboardings[1].uuid}")
        end

        it_behaves_like 'a reminder email in locale', locale: :en, context: 'other'
        it_behaves_like 'a reminder email not in locale', locale: :cy, context: 'other'
      end
    end
  end

  describe '#onboarded_email' do
    before { OnboardingMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.onboarded_email.deliver_now } }

    context 'preferred locale is cy' do
      let(:preferred_locale) { :cy }

      it 'sends the onboarded email in cy' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.onboarded_email.subject', locale: :cy).gsub('%{school}', school.name))
        I18n.t('onboarding_mailer.onboarded_email', locale: :cy).except(:subject).each_value do |text|
          expect(body).to include(replace_variables(text, locale: :cy))
        end
      end
    end

    context 'preferred locale is en' do
      let(:preferred_locale) { :en }

      it 'sends the onboarded email in en' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.onboarded_email.subject').gsub('%{school}', school.name))
        I18n.t('onboarding_mailer.onboarded_email', locale: :en).except(:subject).each_value do |text|
          expect(body).to include(replace_variables(text, locale: :en))
        end
      end
    end
  end

  describe '#data_enabled_email' do
    before { OnboardingMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.data_enabled_email.deliver_now } }

    context 'preferred locale is cy' do
      let(:preferred_locale) { :cy }

      it 'sends the data enabled_email in cy' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.data_enabled_email.subject', locale: :cy).gsub('%{school}', school.name))
        I18n.t('onboarding_mailer.data_enabled_email', locale: :cy).except(:subject, :set_your_first_targets).each_value do |text|
          expect(body).to include(replace_variables(text, locale: :cy))
        end
      end
    end

    context 'preferred locale is en' do
      let(:preferred_locale) { :en }

      it 'sends the data enabled_email in en' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.data_enabled_email.subject', locale: :en).gsub('%{school}', school.name))
        I18n.t('onboarding_mailer.data_enabled_email', locale: :en).except(:subject, :set_your_first_targets).each_value do |text|
          expect(body).to include(replace_variables(text, locale: :en))
        end
      end
    end
  end

  describe '#welcome_email' do
    before { OnboardingMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.welcome_email.deliver_now } }

    context 'preferred locale is cy' do
      let(:preferred_locale) { :cy }

      it 'sends the welcome email in cy' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.welcome_email.subject', locale: :cy))
        I18n.t('onboarding_mailer.welcome_email', locale: :cy).except(:subject).each_value do |text|
          expect(body).to include(replace_variables(text, locale: :cy))
        end
      end
    end

    context 'preferred locale is en' do
      let(:preferred_locale) { :en }

      it 'sends the welcome email in en' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.welcome_email.subject', locale: :en))
        I18n.t('onboarding_mailer.welcome_email', locale: :en).except(:subject).each_value do |text|
          expect(body).to include(replace_variables(text, locale: :en))
        end
      end
    end
  end
end

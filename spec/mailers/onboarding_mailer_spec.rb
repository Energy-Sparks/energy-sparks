require 'rails_helper'

RSpec.describe OnboardingMailer do
  let(:school){ create(:school, name: 'Test School') }
  let(:user){ create(:onboarding_user, school: school, preferred_locale: :cy) }
  let(:school_onboarding) { create(:school_onboarding, school_name: 'Test School', created_by: user, school: school, country: 'wales') }
  let(:enable_locale_emails) { 'false' }

  around do |example|
    ClimateControl.modify FEATURE_FLAG_EMAILS_WITH_PREFERRED_LOCALE: enable_locale_emails do
      ClimateControl.modify WELSH_APPLICATION_HOST: 'cy.localhost' do
        example.run
      end
    end
  end

  describe '#onboarding_email' do
    context 'when locale emails disabled' do
      it 'sends the onboarding email in english only' do
        OnboardingMailer.with(school_onboarding: school_onboarding).onboarding_email.deliver_now
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq(I18n.t('onboarding_mailer.onboarding_email.subject'))
        I18n.t('onboarding_mailer.onboarding_email').except(:subject).values.each do |email_content|
          expect(email.body.to_s).to include(email_content.gsub('%{school_name}', school.name))
        end
        expect(email.body.to_s).to include("http://localhost/school_setup/")
        I18n.t('onboarding_mailer.onboarding_email', locale: :cy).except(:subject).values.each do |email_content|
          expect(email.body.to_s).not_to include(email_content.gsub('%{school_name}', school.name))
        end
        expect(email.body.to_s).not_to include("http://cy.localhost/school_setup/")
      end
    end
    context 'when locale emails enabled' do
      let(:enable_locale_emails) { 'true' }
      it 'sends the onboarding email in both languages' do
        OnboardingMailer.with(school_onboarding: school_onboarding).onboarding_email.deliver_now
        email = ActionMailer::Base.deliveries.last
        #subject includes both english and welsh
        expect(email.subject).to eq(I18n.t('onboarding_mailer.onboarding_email.subject') + " / " + I18n.t('onboarding_mailer.onboarding_email.subject', locale: :cy))
        #body includes all english phrases
        I18n.t('onboarding_mailer.onboarding_email').except(:subject).values.each do |email_content|
          expect(email.body.to_s).to include(email_content.gsub('%{school_name}', school.name))
        end
        expect(email.body.to_s).to include("http://localhost/school_setup/")
        #body includes some expected welsh phrases
        expect(email.body.to_s).to include(I18n.t('onboarding_mailer.onboarding_email.paragraph_1_html', school_name: school.name, locale: :cy))
        expect(email.body.to_s).to include(I18n.t('onboarding_mailer.onboarding_email.paragraph_2', locale: :cy))
        expect(email.body.to_s).to include(I18n.t('onboarding_mailer.onboarding_email.set_up_your_school_on_energy_sparks', locale: :cy))
        expect(email.body.to_s).to include("http://cy.localhost/school_setup/")
      end
    end
  end

  describe '#completion_email' do
    it 'sends the completion email' do
      OnboardingMailer.with(school_onboarding: school_onboarding).completion_email.deliver_now
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq(I18n.t('onboarding_mailer.completion_email.subject').gsub('%{school}', school.name))
      I18n.t('onboarding_mailer.completion_email').except(:subject).values.each do |email_content|
        expect(email.body.to_s).to include(email_content.gsub('%{school_name}', school.name))
      end
    end
  end

  describe '#reminder_email' do
    context 'when locale emails disabled' do
      it 'sends the reminder email in english only' do
        OnboardingMailer.with(school_onboarding: school_onboarding).reminder_email.deliver_now
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq(I18n.t('onboarding_mailer.reminder_email.subject'))
        I18n.t('onboarding_mailer.reminder_email').except(:subject).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(email_content.gsub('%{school_name}', school.name))
        end
        expect(email.body.to_s).to include("http://localhost/school_setup/")
        I18n.t('onboarding_mailer.reminder_email', locale: :cy).except(:subject).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).not_to include(email_content.gsub('%{school_name}', school.name))
        end
        expect(email.body.to_s).not_to include("http://cy.localhost/school_setup/")
      end
    end
    context 'when locale emails enabled' do
      let(:enable_locale_emails) { 'true' }
      it 'sends the reminder email' do
        OnboardingMailer.with(school_onboarding: school_onboarding).reminder_email.deliver_now
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq(I18n.t('onboarding_mailer.reminder_email.subject') + " / " + I18n.t('onboarding_mailer.reminder_email.subject', locale: :cy))
        I18n.t('onboarding_mailer.reminder_email').except(:subject).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(email_content.gsub('%{school_name}', school.name))
        end
        expect(email.body.to_s).to include("http://localhost/school_setup/")
        I18n.t('onboarding_mailer.reminder_email', locale: :cy).except(:subject).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(email_content.gsub('%{school_name}', school.name))
        end
        expect(email.body.to_s).to include("http://cy.localhost/school_setup/")
      end
    end
  end

  describe '#activation_email' do
    context 'when locale emails disabled' do
      let(:enable_locale_emails) { 'false' }
      it 'sends the activation email' do
        OnboardingMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.activation_email.deliver_now }
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq(I18n.t('onboarding_mailer.activation_email.subject').gsub('%{school}', school.name))
        I18n.t('onboarding_mailer.activation_email').except(:subject, :set_your_first_targets).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(
            email_content.gsub('%{school_name}', school.name)
                         .gsub('%{contact_url}', 'http://localhost/contact')
                         .gsub('%{activity_categories_url}', 'http://localhost/activity_categories')
                         .gsub('%{intervention_type_groups_url}', 'http://localhost/intervention_type_groups')
                         .gsub('%{intervention_type_groups_url}', 'http://localhost/intervention_type_groups')
                         .gsub('%{school_url}', 'http://localhost/schools/test-school')
                         .gsub('%{user_guide_videos_url}', 'http://localhost/user-guide-videos')
                         .gsub('%{training_url}', 'http://localhost/training')
          )
        end
      end
    end
    context 'when locale emails enabled' do
      let(:enable_locale_emails) { 'true' }
      it 'sends the activation email in cy' do
        OnboardingMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.activation_email.deliver_now }
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq(I18n.t('onboarding_mailer.activation_email.subject', locale: :cy).gsub('%{school}', school.name))
        I18n.t('onboarding_mailer.activation_email', locale: :cy).except(:subject, :set_your_first_targets).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(
                                                                                email_content.gsub('%{school_name}', school.name)
                                                                                             .gsub('%{contact_url}', 'http://cy.localhost/contact')
                                                                                             .gsub('%{activity_categories_url}', 'http://cy.localhost/activity_categories')
                                                                                             .gsub('%{intervention_type_groups_url}', 'http://cy.localhost/intervention_type_groups')
                                                                                             .gsub('%{intervention_type_groups_url}', 'http://cy.localhost/intervention_type_groups')
                                                                                             .gsub('%{school_url}', 'http://cy.localhost/schools/test-school')
                                                                                             .gsub('%{user_guide_videos_url}', 'http://cy.localhost/user-guide-videos')
                                                                                             .gsub('%{training_url}', 'http://cy.localhost/training')
                                                                              )
        end
      end
    end
  end

  describe '#onboarded_email' do
    it 'sends the onboarded email' do
      OnboardingMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.onboarded_email.deliver_now }
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq(I18n.t('onboarding_mailer.onboarded_email.subject').gsub('%{school}', school.name))
      I18n.t('onboarding_mailer.onboarded_email').except(:subject).values.each do |email_content|
        expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(
          email_content.gsub('%{school_name}', school.name)
                       .gsub('%{contact_url}', 'http://localhost/contact')
                       .gsub('%{activity_categories_url}', 'http://localhost/activity_categories')
                       .gsub('%{intervention_type_groups_url}', 'http://localhost/intervention_type_groups')
                       .gsub('%{school_url}', 'http://localhost/schools/test-school')
                       .gsub('%{user_guide_videos_url}', 'http://localhost/user-guide-videos')
                       .gsub('%{training_url}', 'http://localhost/training')
        )
      end
    end
    context 'when locale emails enabled' do
      let(:enable_locale_emails) { 'true' }
      it 'sends the onboarded email in cy' do
        OnboardingMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.onboarded_email.deliver_now }
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq(I18n.t('onboarding_mailer.onboarded_email.subject', locale: :cy).gsub('%{school}', school.name))
        I18n.t('onboarding_mailer.onboarded_email', locale: :cy).except(:subject).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(
                                                                                email_content.gsub('%{school_name}', school.name)
                                                                                             .gsub('%{contact_url}', 'http://cy.localhost/contact')
                                                                                             .gsub('%{activity_categories_url}', 'http://cy.localhost/activity_categories')
                                                                                             .gsub('%{intervention_type_groups_url}', 'http://cy.localhost/intervention_type_groups')
                                                                                             .gsub('%{school_url}', 'http://cy.localhost/schools/test-school')
                                                                                             .gsub('%{user_guide_videos_url}', 'http://cy.localhost/user-guide-videos')
                                                                                             .gsub('%{training_url}', 'http://cy.localhost/training')
                                                                              )
        end
      end
    end
  end

  describe '#data_enabled_email' do
    it 'sends the data enabled_email' do
      OnboardingMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.data_enabled_email.deliver_now }
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq(I18n.t('onboarding_mailer.data_enabled_email.subject').gsub('%{school}', school.name))
      I18n.t('onboarding_mailer.data_enabled_email').except(:subject, :set_your_first_targets).values.each do |email_content|
        expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(
          email_content.gsub('%{school_name}', school.name)
                       .gsub('%{contact_url}', 'http://localhost/contact')
                       .gsub('%{contact_url}', 'http://localhost/contact')
                       .gsub('%{activity_categories_url}', 'http://localhost/activity_categories')
                       .gsub('%{school_url}', 'http://localhost/schools/test-school')
                       .gsub('%{user_guide_videos_url}', 'http://localhost/user-guide-videos')
                       .gsub('%{training_url}', 'http://localhost/training')
        )
      end
    end
    context 'when locale emails enabled' do
      let(:enable_locale_emails) { 'true' }
      it 'sends the data enabled_email in cy' do
        OnboardingMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.data_enabled_email.deliver_now }
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq(I18n.t('onboarding_mailer.data_enabled_email.subject', locale: :cy).gsub('%{school}', school.name))
        I18n.t('onboarding_mailer.data_enabled_email', locale: :cy).except(:subject, :set_your_first_targets).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(
                                                                                email_content.gsub('%{school_name}', school.name)
                                                                                             .gsub('%{contact_url}', 'http://cy.localhost/contact')
                                                                                             .gsub('%{contact_url}', 'http://cy.localhost/contact')
                                                                                             .gsub('%{activity_categories_url}', 'http://cy.localhost/activity_categories')
                                                                                             .gsub('%{school_url}', 'http://cy.localhost/schools/test-school')
                                                                                             .gsub('%{user_guide_videos_url}', 'http://cy.localhost/user-guide-videos')
                                                                                             .gsub('%{training_url}', 'http://cy.localhost/training')
                                                                              )
        end
      end
    end
  end

  describe '#welcome_email' do
    it 'sends the welcome email' do
      OnboardingMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.welcome_email.deliver_now }
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq(I18n.t('onboarding_mailer.welcome_email.subject'))
      I18n.t('onboarding_mailer.welcome_email').except(:subject).values.each do |email_content|
        expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(
          email_content.gsub('%{school_name}', school.name)
                       .gsub('%{contact_url}', 'http://localhost/contact')
                       .gsub('%{contact_url}', 'http://localhost/contact')
                       .gsub('%{activity_categories_url}', 'http://localhost/activity_categories')
                       .gsub('%{school_url}', 'http://localhost/schools/test-school')
                       .gsub('%{user_guide_videos_url}', 'http://localhost/user-guide-videos')
                       .gsub('%{training_url}', 'http://localhost/training')
        )
      end
    end
    context 'when locale emails enabled' do
      let(:enable_locale_emails) { 'true' }
      it 'sends the welcome email in cy' do
        OnboardingMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.welcome_email.deliver_now }
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq(I18n.t('onboarding_mailer.welcome_email.subject', locale: :cy))
        I18n.t('onboarding_mailer.welcome_email', locale: :cy).except(:subject).values.each do |email_content|
          expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(
                                                                                email_content.gsub('%{school_name}', school.name)
                                                                                             .gsub('%{contact_url}', 'http://cy.localhost/contact')
                                                                                             .gsub('%{contact_url}', 'http://cy.localhost/contact')
                                                                                             .gsub('%{activity_categories_url}', 'http://cy.localhost/activity_categories')
                                                                                             .gsub('%{school_url}', 'http://cy.localhost/schools/test-school')
                                                                                             .gsub('%{user_guide_videos_url}', 'http://cy.localhost/user-guide-videos')
                                                                                             .gsub('%{training_url}', 'http://cy.localhost/training')
                                                                              )
        end
      end
    end
  end
end

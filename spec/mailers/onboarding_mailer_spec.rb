require 'rails_helper'

RSpec.describe OnboardingMailer do
  let(:school){ create(:school, name: 'Test School') }
  let(:user){ create(:onboarding_user, school: school) }
  let(:school_onboarding) { create(:school_onboarding, school_name: 'Test School', created_by: user, school: school) }

  describe '#onboarding_email' do
    it 'sends the onboarding email' do
      OnboardingMailer.with(emails: ['test@blah.com'], school_onboarding: school_onboarding).onboarding_email.deliver_now
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq(I18n.t('onboarding_mailer.onboarding_email.subject'))
      I18n.t('onboarding_mailer.onboarding_email').except(:subject).values.each do |email_content|
        expect(email.body.to_s).to include(email_content.gsub('%{school_name}', school.name))
      end
    end
  end

  describe '#completion_email' do
    it 'sends the completion email' do
      OnboardingMailer.with(emails: ['test@blah.com'], school_onboarding: school_onboarding).completion_email.deliver_now
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq(I18n.t('onboarding_mailer.completion_email.subject').gsub('%{school}', school.name))
      I18n.t('onboarding_mailer.completion_email').except(:subject).values.each do |email_content|
        expect(email.body.to_s).to include(email_content.gsub('%{school_name}', school.name))
      end
    end
  end

  describe '#reminder_email' do
    it 'sends the reminder email' do
      OnboardingMailer.with(emails: ['test@blah.com'], school_onboarding: school_onboarding).reminder_email.deliver_now
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq(I18n.t('onboarding_mailer.reminder_email.subject'))
      I18n.t('onboarding_mailer.reminder_email').except(:subject).values.each do |email_content|
        expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(email_content.gsub('%{school_name}', school.name))
      end
    end
  end

  describe '#activation_email' do
    it 'sends the activation email' do
      OnboardingMailer.with(to: 'test@blah.com', emails: ['test@blah.com'], school: school).activation_email.deliver_now
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

  describe '#onboarded_email' do
    it 'sends the onboarded email' do
      OnboardingMailer.with(emails: ['test@blah.com'], school: school, to: 'test@blah.com').onboarded_email.deliver_now
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
  end

  describe '#data_enabled_email' do
    it 'sends the data enabled_email' do
      OnboardingMailer.with(emails: ['test@blah.com'], school: school, to: 'test@blah.com').data_enabled_email.deliver_now
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
  end

  describe '#welcome_email' do
    it 'sends the welcome email' do
      OnboardingMailer.with(emails: ['test@blah.com'], user: user).welcome_email.deliver_now
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
  end
end

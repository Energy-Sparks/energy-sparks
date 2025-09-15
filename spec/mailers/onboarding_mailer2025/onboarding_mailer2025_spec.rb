# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OnboardingMailer2025 do
  include ActiveJob::TestHelper
  include EmailHelpers

  let(:school) { create_school }
  let(:preferred_locale) { :en }
  let(:user) { create(:onboarding_user, school:, preferred_locale:) }

  before do
    create(:school_onboarding, school_name: 'Test School', created_by: user, school:, country: 'wales')
    Flipper.enable(:onboarding_mailer_2025)
  end

  around do |example|
    ClimateControl.modify(WELSH_APPLICATION_HOST: 'cy.localhost') { example.run }
  end

  def create_school(**kwargs)
    create(:school, name: 'Test School', school_group: create(:school_group), **kwargs)
  end

  def email
    expect(ActionMailer::Base.deliveries.length).to eq(1)
    ActionMailer::Base.deliveries.last
  end

  def read_md(name)
    File.read(File.join(__dir__, "#{name}.md")).gsub('[CALENDAR_ID]', school.calendar_id.to_s)
  end

  describe '#onboarded_email' do
    def setup_and_send(preferred_locale)
      create(:school_admin, school:, preferred_locale:)
      OnboardedEmailSender.new(school).send
    end

    it 'sends the onboarded email in en' do
      setup_and_send(:en)
      expect(email.subject).to eq("#{school.name} is now live on Energy Sparks")
      expect(bootstrap_email_body_to_markdown(email)).to eq(read_md('onboarded_email'))
    end

    it 'sends the onboarded email in cy' do
      setup_and_send(:cy)
      expect(email.subject).to eq('Mae Test School bellach yn fyw ar Sbarcynni')
      expect(bootstrap_email_body_to_markdown(email)).to eq(read_md('onboarded_email_cy'))
    end
  end

  describe '#welcome_email' do
    let(:school) { create_school(data_enabled: false) }

    before do
      user.after_confirmation
      perform_enqueued_jobs
    end

    context 'with a school admin, not data enabled' do
      let(:user) { create(:school_admin, school:) }

      it 'sends the welcome email in en' do
        expect(email.subject).to eq('Welcome to Energy Sparks')
        expect(bootstrap_email_body_to_markdown(email)).to eq(read_md('welcome_email_school_admin_not_data_enabled'))
      end
    end

    context 'with a staff user not data enabled' do
      let(:user) { create(:staff, school:) }

      it 'sends the welcome email in en' do
        expect(email.subject).to eq('Welcome to Energy Sparks')
        expect(bootstrap_email_body_to_markdown(email)).to eq(read_md('welcome_email_staff_not_data_enabled'))
      end
    end

    context 'when data visible' do
      let(:school) { create_school }
      let(:user) { create(:staff, school:) }

      it 'sends the welcome email in en' do
        expect(email.subject).to eq('Welcome to Energy Sparks')
        expect(bootstrap_email_body_to_markdown(email)).to eq(read_md('welcome_email_data_enabled'))
      end
    end
  end

  def create_management_priority
    create(:management_priority, content_generation_run: create(:content_generation_run, school:),
                                 alert: create(:alert, template_data: { average_one_year_saving_gbp: '£1' },
                                                       variables: { average_one_year_saving_gbp: 1,
                                                                    one_year_saving_co2: 1 }))
  end

  describe '#welcome_existing' do
    let(:school) { create_school(dashboard_message: create(:dashboard_message)) }

    before do
      create_management_priority
      OnboardingMailer.mailer.with(user:, school:, locale: preferred_locale).welcome_existing.deliver_now
    end

    it 'sends the expected email' do
      expect(email.subject).to eq('Welcome to the Test School Energy Sparks account')
      expect(bootstrap_email_body_to_markdown(email)).to eq(read_md('welcome_existing'))
    end
  end

  describe '#data_enabled_email' do
    let(:school) { create_school(dashboard_message: create(:dashboard_message)) }

    def setup_and_send(user_type, preferred_locale)
      create_management_priority
      create(user_type, school:, preferred_locale:)
      DataEnabledEmailSender.new(school).send
    end

    it 'sends the staff email' do
      setup_and_send(:staff, :en)
      expect(email.subject).to eq('Energy data is now available on Energy Sparks for Test School')
      expect(bootstrap_email_body_to_markdown(email).chomp).to eq(read_md('data_enabled_email').chomp)
    end

    it 'sends the admin email' do
      setup_and_send(:school_admin, :en)
      expect(email.subject).to eq('Energy data is now available on Energy Sparks for Test School')
      expect(bootstrap_email_body_to_markdown(email).chomp).to eq(read_md('data_enabled_email_admin').chomp)
    end

    it 'sends the staff email in welsh' do
      setup_and_send(:staff, :cy)
      expect(email.subject).to eq('Energy data is now available on Energy Sparks for Test School')
      expect(bootstrap_email_body(email).css('a').map { |a| URI(a['href']).host }.uniq).to \
        contain_exactly('cy.localhost', 'www.youtube.com')
    end
  end
end

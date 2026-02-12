# frozen_string_literal: true

require 'rails_helper'

describe OnboardingMailer, :aggregate_failures do
  include ActiveJob::TestHelper
  include EmailHelpers

  before { stub_const('ENV', ENV.to_h.merge('WELSH_APPLICATION_HOST' => 'cy.localhost')) }

  let(:school)            { create(:school, name: 'Test School', school_group: create(:school_group)) }
  let(:preferred_locale)  { :cy }
  let(:user)              { create(:onboarding_user, school: school, preferred_locale:) }
  let(:country)           { 'wales' }
  let(:school_onboarding) do
    create(:school_onboarding, school_name: 'Test School', created_by: user, school:, country:)
  end
  let(:body) { ActionController::Base.helpers.sanitize(email.html_part.decoded) }

  def email
    expect(ActionMailer::Base.deliveries.length).to eq(1)
    ActionMailer::Base.deliveries.last
  end

  describe '#onboarding_email' do
    before { described_class.with(school_onboarding: school_onboarding).onboarding_email.deliver_now }

    context 'when country is wales' do
      it 'subject is in both languages' do
        expect(email.subject).to eq(I18n.t('onboarding_mailer.onboarding_email.subject') + ' / ' + I18n.t(
          'onboarding_mailer.onboarding_email.subject', locale: :cy
        ))
      end

      it 'has English text' do
        I18n.t('onboarding_mailer.onboarding_email').except(:subject).each_value do |email_content|
          expect(body).to include(email_content.gsub('%{school_name}', school.name))
        end
        expect(body).to include('http://localhost/school_setup/')
      end

      it 'has Welsh text' do
        expect(body).to include(I18n.t('onboarding_mailer.onboarding_email.paragraph_1_html', school_name: school.name,
                                                                                              locale: :cy))
        expect(body).to include(I18n.t('onboarding_mailer.onboarding_email.paragraph_2', locale: :cy))
        expect(body).to include(I18n.t('onboarding_mailer.onboarding_email.set_up_your_school_on_energy_sparks',
                                       locale: :cy))
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
        expect(body).not_to include(I18n.t('onboarding_mailer.onboarding_email.paragraph_1_html',
                                           school_name: school.name, locale: :cy))
        expect(body).not_to include(I18n.t('onboarding_mailer.onboarding_email.paragraph_2', locale: :cy))
        expect(body).not_to include(I18n.t('onboarding_mailer.onboarding_email.set_up_your_school_on_energy_sparks',
                                           locale: :cy))
        expect(body).not_to include('http://cy.localhost/school_setup/')
      end
    end
  end

  ##### this doesn't need translating as it's an admin email
  describe '#completion_email' do
    it 'sends the completion email' do
      described_class.with(school_onboarding: school_onboarding).completion_email.deliver_now
      expect(email.subject).to eq(I18n.t('onboarding_mailer.completion_email.subject')
                                      .gsub('%{school}', school.name)
                                      .gsub('%{school_group}', school.area_name))
      I18n.t('onboarding_mailer.completion_email').except(:subject).each_value do |email_content|
        expect(body).to include(email_content.gsub('%{school_name}', school.name)
                                             .gsub('%{school_group}', school.area_name))
      end
    end
  end

  shared_examples 'a reminder email in locale' do |locale:, context:|
    it "has the #{locale} text" do
      expect(body).to include(I18n.t("title.#{context}", scope:, locale:))
      expect(body).to include(I18n.t("paragraph_1_html.#{context}", scope: scope, locale: locale,
                                                                    school_name: school.name))
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
      expect(body).not_to include(I18n.t("title.#{context}", scope:, locale:))
      expect(body).not_to include(I18n.t("paragraph_1_html.#{context}", scope:, locale:,
                                                                        school_name: school.name))
      expect(body).not_to include(I18n.t("paragraph_2.#{context}", scope:, locale:))
      expect(body).not_to include(I18n.t("paragraph_3.#{context}", scope:, locale:))
      expect(body).not_to include(I18n.t('the_energy_sparks_team', scope:, locale:))
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
      described_class.with(school_onboardings: school_onboardings,
                           email: school_onboarding.contact_email).reminder_email.deliver_now
    end

    let(:scope) { %i[onboarding_mailer reminder_email] }
    let(:school_onboardings) { [] }

    context 'country is wales' do
      let(:country) { 'wales' }

      context 'with single onboarding' do
        let(:school_onboardings) { [school_onboarding] }

        it 'singular subject is in both languages' do
          expect(email.subject).to eq(I18n.t('subject.one', scope: scope,
                                                            locale: :en) + ' / ' + I18n.t('subject.one', scope: scope,
                                                                                                         locale: :cy))
        end

        it_behaves_like 'a reminder email in locale', locale: :cy, context: 'one'
        it_behaves_like 'a reminder email in locale', locale: :en, context: 'one'
      end

      context 'with multiple onboardings for same email address' do
        let(:school_onboardings) do
          [school_onboarding, create(:school_onboarding, contact_email: school_onboarding.contact_email)]
        end

        it 'the multiples subject is in both languages' do
          expect(email.subject).to eq(I18n.t('subject.other', scope: scope,
                                                              locale: :en) + ' / ' + I18n.t('subject.other',
                                                                                            scope: scope, locale: :cy))
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
        let(:school_onboardings) do
          [school_onboarding, create(:school_onboarding, contact_email: school_onboarding.contact_email)]
        end

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
          expect(body).to have_no_link(school_onboardings[0].school_name,
                                       href: "http://cy.localhost/school_setup/#{school_onboardings[0].uuid}")
          expect(body).to have_no_link(school_onboardings[1].school_name,
                                       href: "http://cy.localhost/school_setup/#{school_onboardings[1].uuid}")
        end

        it_behaves_like 'a reminder email in locale', locale: :en, context: 'other'
        it_behaves_like 'a reminder email not in locale', locale: :cy, context: 'other'
      end
    end
  end

  # let(:school) { create_school }
  # let(:preferred_locale) { :en }
  # let(:user) { create(:onboarding_user, school:, preferred_locale:) }

  # before do
  #   create(:school_onboarding, school_name: 'Test School', created_by: user, school:, country: 'wales')
  # end

  def create_school(**)
    create(:school, name: 'Test School', school_group: create(:school_group), **)
  end

  def read_md(name)
    File.read(File.join(__dir__, 'onboarding_mailer2025', "#{name}.md"))
        .gsub('[CALENDAR_ID]', school.calendar_id.to_s)
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
    let(:preferred_locale) { :en }

    before do
      create_management_priority
      described_class.with(user:, school:, locale: preferred_locale).welcome_existing.deliver_now
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

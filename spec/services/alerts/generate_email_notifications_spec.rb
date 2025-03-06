# frozen_string_literal: true

require 'rails_helper'

describe Alerts::GenerateEmailNotifications, :include_application_helper do
  include Rails.application.routes.url_helpers

  let(:school)               { create(:school) }
  let(:alert_generation_run) { create(:alert_generation_run, school: school) }
  let(:alert_1)              { create(:alert, school: school, alert_generation_run: alert_generation_run) }
  let(:alert_2)              { create(:alert, school: school, alert_generation_run: alert_generation_run) }
  let!(:school_admin)        { create(:school_admin, school: school) }
  let!(:email_contact)       { create(:contact_with_name_email, school: school) }

  let(:alert_type_rating_1) do
    create(:alert_type_rating, alert_type: alert_1.alert_type, email_active: true, find_out_more_active: true)
  end
  let(:alert_type_rating_2) { create(:alert_type_rating, alert_type: alert_2.alert_type, email_active: true) }

  let!(:content_version_1) do
    create(:alert_type_rating_content_version, alert_type_rating: alert_type_rating_1,
                                               email_title: 'You need to do something!', email_content: 'You really do')
  end
  let!(:content_version_2) do
    create(:alert_type_rating_content_version, alert_type_rating: alert_type_rating_2,
                                               email_title: 'You need to fix something!', email_content: 'You really do')
  end

  let!(:subscription_generation_run) { create(:subscription_generation_run, school: school) }

  let(:alert_subscription_event_1) { AlertSubscriptionEvent.find_by!(content_version: content_version_1) }
  let(:alert_subscription_event_2) { AlertSubscriptionEvent.find_by!(content_version: content_version_2) }

  let(:email) { ActionMailer::Base.deliveries.last }
  let(:email_body) { email.html_part.decoded }
  let(:matcher) { Capybara.string(email_body.to_s) }

  around do |example|
    ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
      example.run
    end
  end

  shared_examples 'an email was sent' do
    it 'sends email with correct subject' do
      expect(ActionMailer::Base.deliveries.count).to be 1
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq(email_subject)
    end

    context 'when alerts are re-run' do
      before do
        ActionMailer::Base.deliveries.clear
        described_class.new(subscription_generation_run: subscription_generation_run).perform
      end

      it 'doesnt send emails again' do
        expect(ActionMailer::Base.deliveries).to be_empty
        expect(Email.count).to be 1
      end
    end
  end

  shared_examples 'an alert email was sent' do
    let(:params) do
      {
        utm_source: 'weekly-alert',
        utm_medium: 'email',
        utm_campaign: 'alerts'
      }
    end

    it 'includes all alert content' do
      expect(email_body).to include('You need to do something')
      expect(email_body).to include('You need to fix something')
      expect(email_body).not_to include('Find out more')
    end

    it 'include unsubscription section' do
      expect(email_body).to include('Why am I receiving these emails?')
      expect(matcher).to have_link('updating your profile')
      expect(matcher).not_to have_content(school_admin.email)
    end

    it 'includes links to dashboard and analysis pages' do
      expect(email_body).to include('Stay up to date')
      expect(matcher).to have_link('school dashboard', href: school_url(school, params: params, host: 'localhost'))
      expect(matcher).to have_link('detailed analysis',
                                   href: school_advice_url(school, params: params, host: 'localhost'))
      expect(matcher).to have_link('View your school dashboard',
                                   href: school_url(school, params: params, host: 'localhost'))
    end

    it 'records that emails were sent' do
      expect(alert_subscription_event_1.status).to eq 'sent'
      expect(alert_subscription_event_2.status).to eq 'sent'
      expect(alert_subscription_event_1.email_id).not_to be_nil
      expect(alert_subscription_event_1.email_id).to eq alert_subscription_event_2.email_id
      expect(Email.find(alert_subscription_event_1.email_id).sent?).to be true
    end
  end

  def shared_before(alerts: [])
    Alerts::GenerateSubscriptionEvents.new(school, subscription_generation_run:).perform([alert_1, alert_2] + alerts)
    described_class.new(subscription_generation_run:).perform
    alert_subscription_event_1.reload
    alert_subscription_event_2.reload
  end

  def create_email_alert(fuel_type)
    alert_type = create(:alert_type, fuel_type:)
    alert = create(:alert, school:, alert_generation_run:, alert_type:)
    alert_type_rating = create(:alert_type_rating, alert_type:, email_active: true)
    create(:alert_type_rating_content_version, alert_type_rating:)
    alert
  end

  describe '#perform' do
    before do
      Flipper.enable(:profile_pages)
      alerts = %i[electricity storage_heater solar_pv].map { |fuel_type| create_email_alert(fuel_type) }
      shared_before(alerts:)
    end

    it 'send to correct users' do
      expect(email.to).to contain_exactly(email_contact.email_address)
    end

    it_behaves_like 'an alert email was sent'

    it 'does not include unsubscription links' do
      expect(email_body).not_to include("Don't show me alerts like this")
    end

    it_behaves_like 'an email was sent' do
      let(:email_subject) { I18n.t('alert_mailer.alert_email.subject_2024', school_name: school.name) }
    end

    it 'has the new links' do
      params = weekly_alert_utm_parameters
      expect(matcher).to have_link('full list of alerts', href: alerts_school_advice_url(school, params:))
      expect(matcher).to have_link('priority actions', href: priorities_school_advice_url(school, params:))
      expect(matcher).to have_link('detailed analysis', href: school_advice_url(school, params:))
      expect(matcher).to have_link('Choose activity', href: school_recommendations_url(school, params:))
    end

    it 'has the new alerts list' do
      expect(matcher).to have_css('h4', text: 'Long term trends and advice')
      expect(matcher.first('.negative')).to have_text('You need to do something!')
      expect(matcher.first('.negative')).to have_css('img[src*="fa-fire"]')
      expect(matcher.all('.negative')[2]).to have_css('img[src*="fa-bolt"]')
      expect(matcher.all('.negative')[3]).to have_css('img[src*="fa-fire-alt"]')
      expect(matcher.all('.negative')[4]).to have_css('img[src*="fa-sun"]')
    end
  end

  context 'when adding targets section' do
    context 'and theres enough data' do
      let(:active) { true }

      before do
        allow_any_instance_of(Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
        shared_before
      end

      it 'prompts for first target if not set' do
        expect(matcher).to have_link('Set your first target')
      end
    end

    context 'and target is set' do
      let(:active) { true }
      let!(:target) { create(:school_target, school: school) }

      before do
        allow_any_instance_of(Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
        shared_before
      end

      it 'links to progress report' do
        expect(school.has_current_target?).to be true
        expect(matcher).to have_no_link('Set your first target')
        expect(matcher).to have_link('View your progress report')
      end
    end

    context 'but feature is disabled for our school' do
      let!(:target) { create(:school_target, school: school) }

      before do
        school.update!(enable_targets_feature: false)
        allow_any_instance_of(Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
        shared_before
      end

      it 'the link isnt included' do
        expect(matcher).to have_no_link('View your progress report')
        expect(matcher).to have_no_link('Set a new target')
        expect(matcher).to have_no_link('Set your first target')
      end
    end

    context 'and feature is active and target is expired' do
      let!(:target) do
        create(:school_target, school: school, start_date: Date.yesterday.prev_year, target_date: Date.yesterday)
      end

      before do
        allow_any_instance_of(Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
        shared_before
      end

      it 'prompts to set new target' do
        expect(matcher).to have_no_link('Set your first target')
        expect(matcher).to have_link('Set a new target')
      end
    end
  end

  context 'when generating email content' do
    let(:alert_type) { create(:alert_type, advice_page: create(:advice_page, key: :baseload)) }
    let(:alert_1) { create(:alert, school: school, alert_type: alert_type, alert_generation_run: alert_generation_run) }

    before do
      alert_type_rating_1.update!(find_out_more_active: true)
      Alerts::GenerateContent.new(school).perform
      shared_before
    end

    it 'links to a find out more if there is one associated with the content' do
      email = ActionMailer::Base.deliveries.last
      expect(email.html_part.decoded).to include('Find out more')
    end
  end
end

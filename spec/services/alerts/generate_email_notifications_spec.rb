# frozen_string_literal: true

require 'rails_helper'

describe Alerts::GenerateEmailNotifications, :include_application_helper do
  include EmailHelpers
  include Rails.application.routes.url_helpers

  let(:school_admin) { create(:school_admin) }
  let(:school) { school_admin.school }
  let(:alert_generation_run) { create(:alert_generation_run, school:) }
  let(:alerts) { create_list(:alert, 2, school:, alert_generation_run:) }
  let(:events) { AlertSubscriptionEvent.where(alert: alerts).order(:alert_id).to_a }
  let!(:email_contact) { create(:contact_with_name_email, school:) }
  let!(:subscription_generation_run) { create(:subscription_generation_run, school:) }

  before do
    stub_env(SEND_AUTOMATED_EMAILS: 'true')
    alerts.map(&:alert_type).zip([[true, 'You need to do something!'], [false, 'You need to fix something!']]).each do
      |alert_type, (find_out_more_active, email_title)|
      alert_type_rating = create(:alert_type_rating, alert_type:, email_active: true, find_out_more_active:)
      create(:alert_type_rating_content_version, alert_type_rating:, email_title:, email_content: 'You really do')
    end
  end

  def email_body = last_email.html_part.decoded
  def matcher = Capybara.string(email_body.to_s)

  shared_examples 'an email was sent' do
    it 'sends email with correct subject' do
      expect(last_email.subject).to eq(email_subject)
    end

    context 'when alerts are re-run' do
      before do
        ActionMailer::Base.deliveries.clear
        described_class.new(subscription_generation_run:).perform
      end

      it 'doesnt send emails again' do
        expect(ActionMailer::Base.deliveries).to be_empty
        expect(Email.count).to be 1
      end
    end
  end

  shared_examples 'an alert email was sent' do
    let(:params) do
      { utm_source: 'weekly-alert',
        utm_medium: 'email',
        utm_campaign: 'alerts' }
    end

    it 'includes all alert content' do
      alerts.each { |alert| expect(email_body).to include(alert.alert_type.ratings.first.current_content.email_title) }
      expect(email_body).not_to include('Find out more')
    end

    it 'include unsubscription section' do
      expect(email_body).to include('Why am I receiving these emails?')
      expect(matcher).to have_link('updating your profile')
      expect(matcher).to have_no_text(school_admin.email)
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
      expect(events.map(&:status)).to eq(%w[sent sent])
      expect(events.first.email_id).not_to be_nil
      expect(events.map(&:email_id)).to all(eq(events.first.email_id))
      expect(Email.find(events.first.email_id).sent?).to be true
    end
  end

  def shared_before(extra_alerts: [])
    Alerts::GenerateSubscriptionEvents.new(school, subscription_generation_run:).perform(alerts + extra_alerts)
    described_class.new(subscription_generation_run:).perform
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
      extra_alerts = %i[electricity storage_heater solar_pv].map { |fuel_type| create_email_alert(fuel_type) }
      shared_before(extra_alerts:)
    end

    it 'send to correct users' do
      expect(last_email.to).to contain_exactly(email_contact.email_address)
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

    it 'shows the long term advice with the gas icon', :aggregate_failures do
      expect(matcher).to have_css('h4', text: 'Long term trends and advice')
      expect(matcher.first('.negative')).to have_text('You need to do something!')
      expect(matcher.first('.negative')).to have_css('img[src*="fa-fire"]')
      expect(matcher.all('.negative')[2]).to have_css('img[src*="fa-bolt"]')
      expect(matcher.all('.negative')[3]).to have_css('img[src*="fa-fire-alt"]')
      expect(matcher.all('.negative')[4]).to have_css('img[src*="fa-sun"]')
    end
  end

  context 'when there is no alert content for email' do
    it 'does not send an email or record a delivery when there are no alerts' do
      Alerts::GenerateSubscriptionEvents.new(school, subscription_generation_run:).perform([])

      expect { described_class.new(subscription_generation_run:).perform }.not_to change(Email, :count)
      expect(ActionMailer::Base.deliveries).to be_empty
      expect(subscription_generation_run.alert_subscription_events).to be_empty
    end

    it 'does not send an email when alerts only have SMS content' do
      create(:contact_with_name_phone, school:)
      alerts.first.alert_type.ratings.first.update!(email_active: false, sms_active: true)
      alerts.last.alert_type.ratings.first.update!(email_active: false)
      Alerts::GenerateSubscriptionEvents.new(school, subscription_generation_run:).perform(alerts)

      expect(subscription_generation_run.alert_subscription_events.pluck(:communication_type)).to eq(['sms'])
      expect { described_class.new(subscription_generation_run:).perform }.not_to change(Email, :count)
      expect(ActionMailer::Base.deliveries).to be_empty
      expect(subscription_generation_run.alert_subscription_events.first).to be_pending
    end
  end

  context 'when generating subscriptions for non-displayable alerts' do
    before { alerts.first.update!(displayable: false) }

    it 'does not send an email when none of the alerts are displayable' do
      alerts.last.update!(displayable: false)

      expect do
        Alerts::GenerateSubscriptions.new(school).perform(subscription_frequency: [:weekly])
      end.not_to change(Email, :count)
      expect(ActionMailer::Base.deliveries).to be_empty
      expect(AlertSubscriptionEvent.count).to eq(0)
    end

    it 'sends only the displayable alert when other alerts are not displayable' do
      Alerts::GenerateSubscriptions.new(school).perform(subscription_frequency: [:weekly])

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(email_body).not_to include(alerts.first.alert_type.ratings.first.current_content.email_title)
      expect(email_body).to include(alerts.last.alert_type.ratings.first.current_content.email_title)
      expect(events.map(&:alert)).to eq([alerts.last])
      expect(events.first).to be_sent
    end
  end

  context 'when adding targets section' do
    before do
      target_service = instance_double(Targets::SchoolTargetService, enough_data?: true)
      allow(Targets::SchoolTargetService).to receive(:new).with(school).and_return(target_service)
    end

    context 'and theres enough data' do
      before { shared_before }

      it 'prompts for first target if not set' do
        expect(matcher).to have_link('Set your first target')
      end
    end

    context 'and target is set' do
      before do
        create(:school_target, school:)
        shared_before
      end

      it 'links to progress report' do
        expect(school.has_current_target?).to be true
        expect(matcher).to have_no_link('Set your first target')
        expect(matcher).to have_link('View your progress report')
      end
    end

    context 'when the feature is disabled for our school' do
      before do
        create(:school_target, school:)
        school.update!(enable_targets_feature: false)
        shared_before
      end

      it 'the link isnt included' do
        expect(matcher).to have_no_link('View your progress report')
        expect(matcher).to have_no_link('Set a new target')
        expect(matcher).to have_no_link('Set your first target')
      end
    end

    context 'and feature is active and target is expired' do
      before do
        create(:school_target, school:, start_date: Date.yesterday.prev_year, target_date: Date.yesterday)
        shared_before
      end

      it 'prompts to set new target' do
        expect(matcher).to have_no_link('Set your first target')
        expect(matcher).to have_link('Set a new target')
      end
    end
  end

  context 'when generating email content' do
    before do
      alerts.first.alert_type.update!(advice_page: create(:advice_page, key: :baseload))
      alerts.first.alert_type.ratings.first.update!(find_out_more_active: true)
      Alerts::GenerateContent.new(school).perform
      shared_before
    end

    it 'links to a find out more if there is one associated with the content' do
      expect(email_body).to include('Find out more')
    end
  end

  context 'with target_advice_pages2025' do
    def email_text
      matcher.text.delete("\u00A0").each_line.map(&:strip).reject(&:empty?).join("\n")
    end

    before { Flipper.enable(:target_advice_pages2025) }

    let(:school) { create(:school, :with_fuel_configuration, :with_meter_dates) }

    it 'shows failing targets' do
      create(:school_target, :with_monthly_consumption, school:)
      shared_before
      expect(email_text).to \
        include("Priority alerts\nUnfortunately you are not meeting your target to reduce your electricity usage")
    end

    it 'shows achieving targets' do
      create(:school_target, :with_monthly_consumption, school:, current_consumption: 1000)
      shared_before
      expect(email_text).to \
        include("Priority alerts\n" \
                'Well done, you are making progress towards achieving your target to reduce your electricity usage!')
    end

    it 'does not show an expired target' do
      create(:school_target, :with_monthly_consumption, school:, start_date: 1.year.ago)
      shared_before
      expect(email_text).to include("Latest updates\nLong term trends and advice\n")
    end
  end
end

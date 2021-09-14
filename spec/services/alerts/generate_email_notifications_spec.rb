require 'rails_helper'

describe Alerts::GenerateEmailNotifications do
  let(:school)               { create(:school) }
  let(:alert_generation_run) { create(:alert_generation_run, school: school) }
  let(:alert_1)              { create(:alert, school: school, alert_generation_run: alert_generation_run) }
  let(:alert_2)              { create(:alert, school: school, alert_generation_run: alert_generation_run) }
  let!(:school_admin)        { create(:school_admin, school: school) }
  let!(:email_contact)       { create(:contact_with_name_email, school: school) }

  let(:alert_type_rating_1){ create :alert_type_rating, alert_type: alert_1.alert_type, email_active: true }
  let(:alert_type_rating_2){ create :alert_type_rating, alert_type: alert_2.alert_type, email_active: true }

  let!(:content_version_1){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating_1, email_title: 'You need to do something!', email_content: 'You really do'}
  let!(:content_version_2){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating_2, email_title: 'You need to fix something!', email_content: 'You really do'}

  let!(:subscription_generation_run){ create(:subscription_generation_run, school: school) }

  let(:alert_subscription_event_1) { AlertSubscriptionEvent.find_by!(content_version: content_version_1) }
  let(:alert_subscription_event_2) { AlertSubscriptionEvent.find_by!(content_version: content_version_2) }

  context '#perform' do

    before(:each) do
      Alerts::GenerateSubscriptionEvents.new(school, subscription_generation_run: subscription_generation_run).perform([alert_1, alert_2])
      Alerts::GenerateEmailNotifications.new(subscription_generation_run: subscription_generation_run).perform
      alert_subscription_event_1.reload
      alert_subscription_event_2.reload
    end

    it 'sends email' do
      expect(ActionMailer::Base.deliveries.count).to be 1
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to include('Energy Sparks alerts')
    end

    it 'records that emails were sent' do
      expect(alert_subscription_event_1.status).to eq 'sent'
      expect(alert_subscription_event_2.status).to eq 'sent'
      expect(alert_subscription_event_1.email_id).to_not be_nil
      expect(alert_subscription_event_1.email_id).to eq alert_subscription_event_2.email_id
      expect(Email.find(alert_subscription_event_1.email_id).sent?).to be true
    end

    context 'when alerts are re-run' do
      before(:each) do
        ActionMailer::Base.deliveries.clear
        Alerts::GenerateEmailNotifications.new(subscription_generation_run: subscription_generation_run).perform
      end
      it 'doesnt send emails again' do
        expect(ActionMailer::Base.deliveries).to be_empty
        expect(Email.count).to be 1
      end
    end

    context 'when generating email body' do
        let(:email) { ActionMailer::Base.deliveries.last }
        let(:email_body) { email.html_part.body.to_s }
        let(:matcher) { Capybara::Node::Simple.new(email_body.to_s) }

        it 'includes all alert content' do
          expect(email_body).to include('You need to do something')
          expect(email_body).to include('You need to fix something')
          expect(email_body).to_not include('Find out more')
        end

        it 'includes unsubscription links' do
          expect(email_body).to include("Don't show me alerts like this")
          expect(email_body).to include(alert_subscription_event_1.unsubscription_uuid)
        end

        it 'include unsubscription section' do
          expect(email_body).to include("Why am I receiving these emails?")
          expect(email_body).to include(school_admin.email)
        end

        it 'includes links to dashboard and analysis pages' do
          expect(email_body).to include("Stay up to date")
          expect(matcher).to have_link("school dashboard")
          expect(matcher).to have_link("detailed analysis")
          expect(matcher).to have_link("View your school dashboard")
        end
    end
  end

  context 'when adding targets section' do
    let(:active)  { false }
    let(:email) { ActionMailer::Base.deliveries.last }
    let(:email_body) { email.html_part.body.to_s }
    let(:matcher) { Capybara::Node::Simple.new(email_body.to_s) }

    context 'and feature isnt active' do
      let(:active)  { false }

      before(:each) do
        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(active)
        allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
        Alerts::GenerateSubscriptionEvents.new(school, subscription_generation_run: subscription_generation_run).perform([alert_1, alert_2])
        Alerts::GenerateEmailNotifications.new(subscription_generation_run: subscription_generation_run).perform
        alert_subscription_event_1.reload
        alert_subscription_event_2.reload
      end

      it 'isnt included' do
        expect(matcher).to_not have_link("View your progress report")
        expect(matcher).to_not have_link("Set a new target")
        expect(matcher).to_not have_link("Set your first target")
      end
    end

    context 'and feature is active and theres enough data' do
      let(:active)  { true }

      before(:each) do
        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(active)
        allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
        Alerts::GenerateSubscriptionEvents.new(school, subscription_generation_run: subscription_generation_run).perform([alert_1, alert_2])
        Alerts::GenerateEmailNotifications.new(subscription_generation_run: subscription_generation_run).perform
        alert_subscription_event_1.reload
        alert_subscription_event_2.reload
      end

      it 'prompts for first target if not set' do
        expect(matcher).to have_link("Set your first target")
      end
    end

    context 'and feature is active and target is set' do
      let(:active)  { true }
      let!(:target)          { create(:school_target, school: school) }

      before(:each) do
        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(active)
        allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
        Alerts::GenerateSubscriptionEvents.new(school, subscription_generation_run: subscription_generation_run).perform([alert_1, alert_2])
        Alerts::GenerateEmailNotifications.new(subscription_generation_run: subscription_generation_run).perform
        alert_subscription_event_1.reload
        alert_subscription_event_2.reload
      end

      it 'links to progress report' do
        expect(school.has_current_target?).to be true
        expect(matcher).to_not have_link("Set your first target")
        expect(matcher).to have_link("View your progress report")
      end

    end

    context 'but feature is disabled for our school' do
      let(:active)  { true }
      let!(:target)          { create(:school_target, school: school) }

      before(:each) do
        school.update!(enable_targets_feature: false)
        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(active)
        allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
        Alerts::GenerateSubscriptionEvents.new(school, subscription_generation_run: subscription_generation_run).perform([alert_1, alert_2])
        Alerts::GenerateEmailNotifications.new(subscription_generation_run: subscription_generation_run).perform
        alert_subscription_event_1.reload
        alert_subscription_event_2.reload
      end

      it 'the link isnt included' do
        expect(matcher).to_not have_link("View your progress report")
        expect(matcher).to_not have_link("Set a new target")
        expect(matcher).to_not have_link("Set your first target")
      end

    end

    context 'and feature is active and target is expired' do
      let(:active)  { true }
      let!(:target) { create(:school_target, school: school, start_date: Date.yesterday.prev_year, target_date: Date.yesterday) }

      before(:each) do
        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(active)
        allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
        Alerts::GenerateSubscriptionEvents.new(school, subscription_generation_run: subscription_generation_run).perform([alert_1, alert_2])
        Alerts::GenerateEmailNotifications.new(subscription_generation_run: subscription_generation_run).perform
        alert_subscription_event_1.reload
        alert_subscription_event_2.reload
      end

      it 'prompts to set new target' do
        expect(matcher).to_not have_link("Set your first target")
        expect(matcher).to have_link("Set a new target")
      end
    end

  end

  context 'when generating email content' do
    before(:each) do
      alert_type_rating_1.update!(find_out_more_active: true)
      Alerts::GenerateContent.new(school).perform
      Alerts::GenerateSubscriptionEvents.new(school, subscription_generation_run: subscription_generation_run).perform([alert_1, alert_2])
      Alerts::GenerateEmailNotifications.new(subscription_generation_run: subscription_generation_run).perform
    end

    it 'links to a find out more if there is one associated with the content' do
      email = ActionMailer::Base.deliveries.last
      expect(email.html_part.body.to_s).to include('Find out more')
    end
  end

end

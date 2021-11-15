require 'rails_helper'

RSpec.describe Targets::TargetMailerService do

  include Rails.application.routes.url_helpers

  let!(:school)             { create(:school) }
  let!(:service)            { Targets::TargetMailerService.new }

  before(:each) do
    allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
    allow_any_instance_of(Targets::SchoolTargetService).to receive(:enough_data?).and_return(enough_data)
  end

  describe '#list_schools' do
      let!(:other_school)       { create(:school) }

      let(:enough_data) { true }
      let(:list_of_schools) { service.list_schools }

      it 'should list all schools without a target' do
        expect(list_of_schools).to contain_exactly(school, other_school)
      end

      it 'ignores non-visible schools' do
        other_school.update!(visible: false)
        expect(list_of_schools).to contain_exactly(school)
      end

      it 'ignores schools that are not data enabled' do
        other_school.update!(data_enabled: false)
        expect(list_of_schools).to contain_exactly(school)
      end

      it 'should ignore schools with a target' do
        create(:school_target, school: school)
        expect(list_of_schools).to contain_exactly(other_school)
      end

      it 'should ignore schools that have received an invite' do
        create(:school_target_event, school: school, event: :first_target_sent)
        expect(list_of_schools).to contain_exactly(other_school)
      end

      context 'when a school cant use feature because of data' do
        context 'because they lack data' do
          let(:enough_data) { false }
          it 'should ignore schools that cant use feature' do
            expect(list_of_schools).to be_empty
          end
        end
        context 'because its disabled for them' do
          before(:each) do
            school.update!(enable_targets_feature: false)
          end
          it 'should ignore schools that cant use feature' do
            expect(list_of_schools).to contain_exactly(other_school)
          end
        end
      end
  end

  describe '#list_schools_requiring_reminder' do
    let!(:other_school)       { create(:school) }

    let(:enough_data) { true }
    let(:list_of_schools) { service.list_schools_requiring_reminder }

    it 'should list only schools that have had an invite 30 days ago' do
      create(:school_target_event, school: school, event: :first_target_sent, created_at: Date.today - 45)
      expect(list_of_schools).to contain_exactly(school)
    end

    it 'should not list schools that have had a recent invite' do
      create(:school_target_event, school: school, event: :first_target_sent)
      expect(list_of_schools).to be_empty
    end

    it 'ignores non-visible schools' do
      create(:school_target_event, school: school, event: :first_target_sent, created_at: Date.today - 45)
      school.update!(visible: false)
      expect(list_of_schools).to be_empty
    end

    it 'should ignore schools with a target' do
      create(:school_target_event, school: school, event: :first_target_sent, created_at: Date.today - 45)
      create(:school_target, school: school)
      expect(list_of_schools).to be_empty
    end

    context 'when a school cant use feature because of data' do
      let!(:event) { create(:school_target_event, school: school, event: :first_target_sent, created_at: Date.today - 45) }

      context 'because they lack data' do
        let(:enough_data) { false }
        it 'should ignore schools that cant use feature' do
          expect(list_of_schools).to be_empty
        end
      end

      context 'because its disabled for them' do
        before(:each) do
          school.update!(enable_targets_feature: false)
        end
        it 'should ignore schools that cant use feature' do
          expect(list_of_schools).to be_empty
        end
      end
    end
  end

  describe '#list_schools_requiring_review' do
      let!(:other_school)       { create(:school) }
      let(:enough_data) { true }
      let(:list_of_schools) { service.list_schools_requiring_review }

      it 'should ignore schools with no target' do
        expect(list_of_schools).to be_empty
      end

      it 'should ignore schools with a current target' do
        create(:school_target, school: school)
        expect(list_of_schools).to be_empty
      end

      it 'should list school with an expired target' do
        create(:school_target, school: school, start_date: Date.yesterday.prev_year, target_date: Date.yesterday)
        expect(list_of_schools).to contain_exactly(school)
      end

      it 'ignores non-visible schools' do
        create(:school_target, school: school, start_date: Date.yesterday.prev_year, target_date: Date.yesterday)
        school.update!(visible: false)
        expect(list_of_schools).to be_empty
      end

      it 'should ignore schools that have received an email to review/set new target' do
        create(:school_target, school: school, start_date: Date.yesterday.prev_year, target_date: Date.yesterday)
        create(:school_target, school: other_school, start_date: Date.yesterday.prev_year, target_date: Date.yesterday)
        create(:school_target_event, school: school, event: :review_target_sent)
        expect(list_of_schools).to contain_exactly(other_school)
      end

      context 'when a school cant use feature' do
        let(:enough_data) { false }
        it 'should ignore schools that cant use feature' do
          create(:school_target, school: school, start_date: Date.yesterday.prev_year, target_date: Date.yesterday)
          create(:school_target, school: other_school, start_date: Date.yesterday.prev_year, target_date: Date.yesterday)
          expect(list_of_schools).to be_empty
        end
      end

  end

  describe '#invite_schools_to_set_first_target' do
    let!(:school_admin)  { create(:school_admin, school: school) }
    let!(:staff)         { create(:staff, school: school) }

    let(:enough_data) { true }

    let(:email)       { ActionMailer::Base.deliveries.last }
    let(:email_body)  { email.html_part.body.to_s }
    let(:matcher)     { Capybara::Node::Simple.new(email_body.to_s) }

    it 'sends an email' do
      service.invite_schools_to_set_first_target
      expect(ActionMailer::Base.deliveries.count).to eql 1
      expect(email.subject).to eql "Set your first energy saving target"
    end

    it 'doesnt send an email if one was sent already' do
      create(:school_target_event, school: school, event: :first_target_sent)
      service.invite_schools_to_set_first_target
      expect(ActionMailer::Base.deliveries.count).to eql 0
    end

    it 'sends email to all staff' do
      service.invite_schools_to_set_first_target
      expect(email.to).to contain_exactly(school_admin.email, staff.email)
    end

    it 'records that an email was sent' do
      service.invite_schools_to_set_first_target
      expect(school.has_school_target_event?(:first_target_sent)).to be true
    end

    it 'generates correct email' do
      service.invite_schools_to_set_first_target
      expect(email_body).to include("Set your first energy saving target")
      expect(matcher).to have_link("Set your first target")
    end

    it 'should add utm parameters' do
      service.invite_schools_to_set_first_target
      params = {
        "utm_source": "invite",
        "utm_medium": "email",
        "utm_campaign": "targets"
      }
      expect(matcher).to have_link("Set your first target", href: school_school_targets_url(school, params: params, host: "localhost"))
    end

  end

  describe '#invite_schools_to_review_target' do
    let!(:school_admin)   { create(:school_admin, school: school) }
    let!(:staff)          { create(:staff, school: school) }
    let!(:target)         { create(:school_target, school: school, start_date: Date.yesterday.prev_year, target_date: Date.yesterday)}

    let(:enough_data) { true }

    let(:email)       { ActionMailer::Base.deliveries.last }
    let(:email_body)  { email.html_part.body.to_s }
    let(:matcher)     { Capybara::Node::Simple.new(email_body.to_s) }

    it 'sends an email' do
      service.invite_schools_to_review_target
      expect(ActionMailer::Base.deliveries.count).to eql 1
      expect(email.subject).to eql "Review your progress and set a new saving target"
    end

    it 'doesnt send an email if one was sent already' do
      create(:school_target_event, school: school, event: :review_target_sent)
      service.invite_schools_to_review_target
      expect(ActionMailer::Base.deliveries.count).to eql 0
    end

    it 'sends email to all staff' do
      service.invite_schools_to_review_target
      expect(email.to).to contain_exactly(school_admin.email, staff.email)
    end

    it 'records that an email was sent' do
      service.invite_schools_to_review_target
      expect(school.has_school_target_event?(:review_target_sent)).to be true
    end

    it 'generates correct email' do
      service.invite_schools_to_review_target
      expect(email_body).to include("Set your next energy saving target")
      expect(matcher).to have_link("Set a new target")
    end

    it 'should add utm parameters' do
      service.invite_schools_to_review_target
      params = {
        "utm_source": "review",
        "utm_medium": "email",
        "utm_campaign": "targets"
      }
      expect(matcher).to have_link("Set a new target", href: school_school_targets_url(school, params: params, host: "localhost"))
    end

  end

  describe '#remind_schools_to_set_first_target' do
    let!(:school_admin)  { create(:school_admin, school: school) }
    let!(:staff)         { create(:staff, school: school) }

    let!(:event) { create(:school_target_event, school: school, event: :first_target_sent, created_at: Date.today - 45) }

    let(:enough_data) { true }

    let(:email)       { ActionMailer::Base.deliveries.last }
    let(:email_body)  { email.html_part.body.to_s }
    let(:matcher)     { Capybara::Node::Simple.new(email_body.to_s) }

    it 'sends an email' do
      service.remind_schools_to_set_first_target
      expect(ActionMailer::Base.deliveries.count).to eql 1
      expect(email.subject).to eql "Reminder to set your first energy saving target"
    end

    it 'doesnt send an email if one was sent already' do
      create(:school_target_event, school: school, event: :first_target_reminder_sent)
      service.remind_schools_to_set_first_target
      expect(ActionMailer::Base.deliveries.count).to eql 0
    end

    it 'sends email to all staff' do
      service.remind_schools_to_set_first_target
      expect(email.to).to contain_exactly(school_admin.email, staff.email)
    end

    it 'records that an email was sent' do
      service.remind_schools_to_set_first_target
      expect(school.has_school_target_event?(:first_target_reminder_sent)).to be true
    end

    it 'generates correct email' do
      service.remind_schools_to_set_first_target
      expect(email_body).to include("Set your first energy saving target")
      expect(matcher).to have_link("Set your first target")
    end

    it 'should add utm parameters' do
      service.remind_schools_to_set_first_target
      params = {
        "utm_source": "invite",
        "utm_medium": "email",
        "utm_campaign": "targets"
      }
      expect(matcher).to have_link("Set your first target", href: school_school_targets_url(school, params: params, host: "localhost"))
    end

  end

end

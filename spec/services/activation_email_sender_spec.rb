require 'rails_helper'

describe ActivationEmailSender, :schools, type: :service do

  let(:service) { ActivationEmailSender.new(school) }

  describe 'send' do
    let(:school){ create :school, visible: false}

    context 'where the school has not been created via the onboarding process' do
      let!(:school_admin)  { create(:school_admin, school: school) }
      let!(:staff) { create(:staff, school: school) }

      before(:each) do
        service.send
      end

      it 'sends an activation email to staff and admins' do
        email = ActionMailer::Base.deliveries.last
        expect(email).to_not be nil
        expect(email.subject).to include('is live on Energy Sparks')
        expect(email.to).to match [school_admin.email, staff.email]
      end
    end

    context 'where the school has been created as part of the onboarding process' do
      let(:onboarding_user){ create :onboarding_user }
      let!(:school_onboarding){ create :school_onboarding, school: school, created_user: onboarding_user}

      context 'when an email has already been sent' do
        before(:each) do
          school_onboarding.events.create!(event: :activation_email_sent)
          service.send
        end
        it 'doesnt send another' do
          expect(ActionMailer::Base.deliveries.size).to eq(0)
        end
      end

      context 'when sending activation email' do
        it 'sends if one has not been sent' do
          service.send
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to include('is live on Energy Sparks')
          expect(email.to).to eql [onboarding_user.email]
        end

        it 'records target invite if feature is active and enough data' do
          allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
          allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
          service.send
          expect(school.has_school_target_event?(:first_target_sent)).to be true
        end

        it 'does not records target invite if feature is in active' do
          allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(false)
          service.send
          expect(school.has_school_target_event?(:first_target_sent)).to be false
        end

        it 'does not records target invite if not enough data is in active' do
          allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(false)
          allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
          service.send
          expect(school.has_school_target_event?(:first_target_sent)).to be false
        end

        it 'records that an email was sent' do
          service.send
          expect(school_onboarding).to have_event(:activation_email_sent)
        end

        context 'when there are staff and admins' do
          let!(:school_admin)  { create(:school_admin, school: school) }
          let!(:staff) { create(:staff, school: school) }

          it 'sends the email to staff and admins' do
            service.send
            email = ActionMailer::Base.deliveries.last
            expect(email.to).to match [onboarding_user.email, school_admin.email, staff.email]
          end

          context 'but no created user' do
            #can happen when admin completes process for a school
            let(:school_onboarding) do
              create :school_onboarding,
                created_user: nil
            end
            it 'still sends email to staff and admins' do
              service.send
              email = ActionMailer::Base.deliveries.last
              expect(email.to).to match [school_admin.email, staff.email]
            end
          end
        end

        context 'the email contains' do
          let(:email) { ActionMailer::Base.deliveries.last }

          let(:email_body) { email.html_part.body.to_s }
          let(:matcher) { Capybara::Node::Simple.new(email_body.to_s) }

          it 'link to school dashboard' do
            service.send
            expect(matcher).to have_link("View your school dashboard")
          end
          it 'links to help content and contact' do
            service.send
            expect(matcher).to have_link("User Guide")
            expect(matcher).to have_link("Training Videos")
            expect(matcher).to have_link("Join a webinar")
            expect(matcher).to have_link("Get in touch")
          end

          context 'request to set targets' do
            let(:enough_data) { true }
            it 'when feature is active and enough data' do
              allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
              allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
              service.send
              expect(email_body).to include("Set your first targets")
              expect(matcher).to have_link("Set your first target")
            end

            it 'not when feature is inactive' do
              allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(true)
              allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(false)
              service.send
              expect(email_body).to_not include("Set your first targets")
              expect(matcher).to_not have_link("Set your first target")
            end

            it 'but not when not enough data' do
              allow_any_instance_of(::Targets::SchoolTargetService).to receive(:enough_data?).and_return(false)
              allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
              service.send
              expect(email_body).to_not include("Set your first targets")
              expect(matcher).to_not have_link("Set your first target")
            end
          end
        end
      end
    end
  end
end

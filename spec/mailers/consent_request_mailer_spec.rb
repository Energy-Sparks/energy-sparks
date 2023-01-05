require 'rails_helper'

RSpec.describe ConsentRequestMailer do

  let(:school)        { create(:school, name: 'Test School') }
  let(:user)          { create(:user, school: school, email: 'en@example.com') }
  let(:user_cy)       { create(:user, school: school, email: 'cy@example.com', preferred_locale: 'cy') }

  describe '#request_consent' do

    context 'when locale is cy' do

      before do
        I18n.locale = 'cy'
      end

      after do
        I18n.locale = 'en'
      end

      around do |example|
        ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
          example.run
        end
      end

      context 'when locale emails not enabled' do
        around do |example|
          ClimateControl.modify FEATURE_FLAG_EMAILS_WITH_PREFERRED_LOCALE: 'false' do
            example.run
          end
        end

        it 'sends an email with en strings even if I18n is cy' do
          ConsentRequestMailer.with(users: [user], school: school).request_consent.deliver_now
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eql ("We need permission to access your school's energy data")
          expect(email.body.to_s).to include("Please provide permission for Energy Sparks to access data for Test School")
        end

        it 'sends an email with en strings even if user is cy' do
          ConsentRequestMailer.with(users: [user_cy], school: school).request_consent.deliver_now
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eql ("We need permission to access your school's energy data")
          expect(email.body.to_s).to include("Please provide permission for Energy Sparks to access data for Test School")
        end
      end

      context 'when emails are sent with preferred locale' do
        around do |example|
          ClimateControl.modify FEATURE_FLAG_EMAILS_WITH_PREFERRED_LOCALE: 'true' do
            example.run
          end
        end

        it 'sends an email with cy strings if user preference is cy' do
          ConsentRequestMailer.with(users: [user, user_cy], school: school, locales: [:en, :cy]).request_consent.deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(2)
          email = ActionMailer::Base.deliveries.first
          expect(email.subject).to eql ("We need permission to access your school's energy data")
          expect(email.body.to_s).to include("Please provide permission for Energy Sparks to access data for Test School")
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eql ("Mae angen caniatâd arnom i gael mynediad at ddata ynni eich ysgol")
          expect(email.body.to_s).to include("Rhowch ganiat&#226;d i Energy Sparks gael mynediad at ddata ar gyfer Test School")
        end
      end
    end
  end
end

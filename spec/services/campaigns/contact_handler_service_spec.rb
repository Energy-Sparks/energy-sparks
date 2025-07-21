require 'rails_helper'

describe Campaigns::ContactHandlerService do
  subject(:service) { described_class.new(request_type, contact) }

  let(:deliveries) { ActionMailer::Base.deliveries }
  let(:request_type) { :school_demo }
  let(:contact) do
    {
      first_name: 'Jane',
      last_name: 'Smith',
      email: 'jane@example.org',
      tel: '01225 444444',
      job_title: 'CFO',
      organisation: 'Fake Academies',
      org_type: [:primary, :secondary],
      consent: true
    }
  end

  let(:capsule) { instance_double(CapsuleCrm::Client) }

  before do
    deliveries.clear
    allow(CapsuleCrm::Client).to receive(:new).and_return(capsule)
  end

  describe '#perform' do
    let(:admin_email) { ActionMailer::Base.deliveries.first }
    let(:user_email) { ActionMailer::Base.deliveries.second }

    context 'with successful party creation in Capsule' do
      let(:party) do
        {
          'party' => {
            'id' => 1234
          }
        }
      end

      before do
        allow(capsule).to receive(:create_party).and_return(party)
      end

      context 'with failed opportunity creation' do
        before do
          allow(capsule).to receive(:create_opportunity).and_raise(CapsuleCrm::ApiFailure)
          allow(Rollbar).to receive(:warning)
          service.perform
        end

        it 'sends two emails' do
          expect(deliveries.count).to eq 2
        end

        it 'includes capsule link to contact' do
          expect(admin_email.html_part.decoded).to include('View Contact')
          expect(admin_email.html_part.decoded).not_to include('View Opportunity')
        end

        it 'logs warning in Rollbar' do
          expect(Rollbar).to have_received(:warning)
        end
      end

      context 'with successful opportunity creation' do
        let(:opportunity) do
          {
            'opportunity' => {
              'id' => 5678
            }
          }
        end

        before do
          allow(capsule).to receive(:create_opportunity).and_return(opportunity)
          service.perform
        end

        it 'sends two emails' do
          expect(deliveries.count).to eq 2
        end

        it 'includes capsule links' do
          expect(admin_email.html_part.decoded).to include('View Contact')
          expect(admin_email.html_part.decoded).to include('View Opportunity')
        end
      end
    end

    context 'with failed party creation in Capsule' do
      before do
        allow(capsule).to receive(:create_party).and_raise(CapsuleCrm::ApiFailure)
        allow(Rollbar).to receive(:warning)
        service.perform
      end

      it 'logs warning in Rollbar' do
        expect(Rollbar).to have_received(:warning)
      end

      it 'sends two emails' do
        expect(deliveries.count).to be(2)
      end

      it 'does not include capsule links' do
        expect(admin_email.html_part.decoded).not_to include('View Contact')
        expect(admin_email.html_part.decoded).not_to include('View Opportunity')
      end
    end

    context 'when sending emails' do
      let(:request_type) { }
      let(:deliveries) { ActionMailer::Base.deliveries }

      before do
        allow(capsule).to receive(:create_party).and_raise(CapsuleCrm::ApiFailure)
        service.perform
      end

      context 'when request type is :school_info' do
        let(:request_type) { :school_info }

        it { expect(deliveries.size).to eq(2) }

        it 'sends admin email' do
          expect(admin_email.subject).to eq '[energy-sparks-unknown] Campaign form: Fake Academies - School info'
        end

        it 'sends user email' do
          expect(user_email.subject).to eq I18n.t('campaign_mailer.send_information.subject')
        end
      end

      context 'when request type is :group_info' do
        let(:request_type) { :group_info }

        it { expect(deliveries.size).to eq(2) }

        it 'sends admin email' do
          expect(admin_email.subject).to eq '[energy-sparks-unknown] Campaign form: Fake Academies - Group info'
        end

        it 'sends user email' do
          expect(user_email.subject).to eq I18n.t('campaign_mailer.send_information.subject')
        end
      end

      context 'when request type is :school_demo' do
        let(:request_type) { :school_demo }

        it { expect(deliveries.size).to eq(2) }

        it 'sends admin email' do
          expect(admin_email.subject).to eq '[energy-sparks-unknown] Campaign form: Fake Academies - School demo'
        end

        it 'sends user email' do
          expect(user_email.subject).to eq I18n.t('campaign_mailer.school_demo.subject')
        end
      end

      context 'when request type is :group_demo' do
        let(:request_type) { :group_demo }

        it { expect(deliveries.size).to eq(1) }

        it 'sends admin email' do
          expect(admin_email.subject).to eq '[energy-sparks-unknown] Campaign form: Fake Academies - Group demo'
        end
      end
    end
  end

  describe '#create_party_from_contact' do
    subject(:capsule_data) do
      service.send(:create_party_from_contact)
    end

    it 'creates expected format for CapsuleCRM' do
      expect(capsule_data).to eq({
        party: {
          type: :person,
          firstName: 'Jane',
          lastName: 'Smith',
          jobTitle: 'CFO',
          organisation: { name: 'Fake Academies' },
          emailAddresses: [{ address: 'jane@example.org' }],
          phoneNumbers: [{ number: '01225 444444' }],
          tags: [
            { name: 'Campaign' },
            { name: 'School demo' },
            { name: 'Primary' },
            { name: 'Secondary' }
          ],
          fields: [
            { definition: { id: described_class::MARKETING_CONSENT_FIELD_ID }, value: true }
          ]
        }
      })
    end
  end

  describe '#create_opportunity_for_party' do
    subject(:capsule_data) do
      service.send(:create_opportunity_for_party, party)
    end

    let(:party) do
      {
        'party' => {
          'id' => 12345
        }
      }
    end

    it 'creates expected hash' do
      expect(capsule_data).to eq({
        opportunity: {
          party: { id: 12345 },
          name: 'Fake Academies',
          description: 'Auto-generated opportunity from campaign contact form',
          milestone: { id: described_class::NEW_MILESTONE_ID },
          tags: [
            { name: 'Campaign' },
            { name: 'School demo' }
          ]
        }
      })
    end
  end

  describe '#can_create_party?' do
    # rubocop:disable Rails/Inquiry
    it 'returns true in production' do
      allow(Rails).to receive(:env) { 'production'.inquiry }
      ClimateControl.modify ENVIRONMENT_IDENTIFIER: 'production' do
        expect(service.send(:can_create_party?)).to be(true)
      end
    end

    it 'returns false on test server' do
      allow(Rails).to receive(:env) { 'production'.inquiry }
      ClimateControl.modify ENVIRONMENT_IDENTIFIER: 'test' do
        expect(service.send(:can_create_party?)).to be(false)
      end
    end

    it 'returns true in dev' do
      allow(Rails).to receive(:env) { 'development'.inquiry }
      expect(service.send(:can_create_party?)).to be(true)
    end
    # rubocop:enable Rails/Inquiry
  end
end

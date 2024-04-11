require 'rails_helper'

describe Campaigns::ContactHandlerService do
  subject(:service) { described_class.new(request_type, contact) }

  let(:request_type) { :book_demo }
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
    allow(CapsuleCrm::Client).to receive(:new).and_return(capsule)
  end

  describe '#perform' do
    let(:email) { ActionMailer::Base.deliveries.last }

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
        end

        it 'sends an email' do
          expect { service.perform }.to change(ActionMailer::Base.deliveries, :count)
          expect(ActionMailer::Base.deliveries.count).to eq 1
        end

        it 'includes capsule link to contact' do
          service.perform
          expect(email.html_part.decoded).to include('View Contact')
          expect(email.html_part.decoded).not_to include('View Opportunity')
        end

        it 'logs warning in Rollbar' do
          expect(Rollbar).to receive(:warning)
          service.perform
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
        end

        it 'sends an email' do
          expect { service.perform }.to change(ActionMailer::Base.deliveries, :count)
          expect(ActionMailer::Base.deliveries.count).to eq 1
        end

        it 'includes capsule links' do
          service.perform
          expect(email.html_part.decoded).to include('View Contact')
          expect(email.html_part.decoded).to include('View Opportunity')
        end
      end
    end

    context 'with failed party creation in Capsule' do
      before do
        allow(capsule).to receive(:create_party).and_raise(CapsuleCrm::ApiFailure)
      end

      it 'logs warning in Rollbar' do
        expect(Rollbar).to receive(:warning)
        service.perform
      end

      it 'sends an email' do
        expect { service.perform }.to change(ActionMailer::Base.deliveries, :count)
      end

      it 'does not include capsule links' do
        service.perform
        expect(email.html_part.decoded).not_to include('View Contact')
        expect(email.html_part.decoded).not_to include('View Opportunity')
      end
    end

    context 'with more information request' do
      let(:request_type) { :more_information }

      before do
        allow(capsule).to receive(:create_party).and_raise(CapsuleCrm::ApiFailure)
      end

      it 'sends several emails' do
        expect { service.perform }.to change(ActionMailer::Base.deliveries, :count)
        expect(ActionMailer::Base.deliveries.count).to eq 2

        expected_email_subjects = [
          '[energy-sparks-unknown] Campaign form: Fake Academies - More information',
          I18n.t('campaign_mailer.send_information.subject')
        ]

        subjects = ActionMailer::Base.deliveries.map(&:subject)
        expect(subjects).to match_array(expected_email_subjects)
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
            { name: 'Book demo' },
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
            { name: 'Book demo' }
          ]
        }
      })
    end
  end
end

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
      org_type: ['Primary school (state)', 'Secondary school (state)'],
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
            { name: 'Primary school (state)' },
            { name: 'Secondary school (state)' }
          ],
          fields: [
            { id: described_class::MARKETING_CONSENT_FIELD_ID, value: true }
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
          name: 'New Opportunity - Fake Academies',
          description: 'Auto-generated opportunity from campaign contact form',
          tags: [
            { name: 'Book demo' }
          ]
        }
      })
    end
  end
end

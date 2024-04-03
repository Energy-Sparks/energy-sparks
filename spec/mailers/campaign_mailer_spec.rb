require 'rails_helper'

RSpec.describe CampaignMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:body) { email.html_part.body.raw_source }

  around do |example|
    ClimateControl.modify ENVIRONMENT_IDENTIFIER: 'unknown' do
      example.run
    end
  end

  describe '#notify_admin' do
    let(:request_type) { :book_demo }
    let(:contact) do
      {
        first_name: 'Jane',
        last_name: 'Smith',
        email: 'jane@example.org',
        tel: '01225 444444',
        job_title: 'CFO',
        organisation: 'Fake Academies',
        org_type: :mat,
        consent: true
      }
    end
    let(:party) do
      {
        'party' => {
          'id' => 1234
        }
      }
    end
    let(:opportunity) do
      {
        'opportunity' => {
          'id' => 5678
        }
      }
    end

    before do
      CampaignMailer.with(request_type: request_type,
                          contact: contact,
                          party: party,
                          opportunity: opportunity).notify_admin.deliver
    end

    it 'send email with expected subject' do
      expect(email.subject).to eq('[energy-sparks-unknown] Campaign form: Fake Academies - Book demo')
    end

    it 'includes contact details in email' do
      expect(email.html_part.decoded).to include('Jane Smith')
      expect(email.html_part.decoded).to include('jane@example.org')
      expect(email.html_part.decoded).to include('01225 444444')
      expect(email.html_part.decoded).to include('CFO')
      expect(email.html_part.decoded).to include('Mat')
      expect(email.html_part.decoded).to include('true')
    end

    it 'includes request type in email' do
      expect(email.html_part.decoded).to include('Book demo')
    end

    it 'includes capsule links' do
      expect(body).to have_link('View Contact', href: 'https://energysparks.capsulecrm.com/party/1234')
      expect(body).to have_link('View Opportunity', href: 'https://energysparks.capsulecrm.com/opportunity/5678')
    end

    context 'with no capsule information' do
      let(:party) { nil }
      let(:opportunity) { nil }

      it 'omits the links' do
        expect(email.html_part.decoded).not_to include('Capsule Links')
      end
    end
  end
end

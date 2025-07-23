require 'rails_helper'

RSpec.describe CampaignMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:body) { email.html_part.body.raw_source }
  let(:contact) do
    {
      first_name: 'Jane',
      last_name: 'Smith',
      email: 'jane@example.org',
      tel: '01225 444444',
      job_title: 'CFO',
      organisation: 'Fake Academies',
      org_type: org_type,
      consent: true
    }
  end

  around do |example|
    ClimateControl.modify ENVIRONMENT_IDENTIFIER: 'unknown' do
      example.run
    end
  end

  describe '#notify_admin' do
    let(:request_type) { :book_demo }
    let(:org_type) { ['multi_academy_trust'] }
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
      expect(email.html_part.decoded).to include('Multi academy trust')
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

  describe '#school_demo' do
    before do
      CampaignMailer.with(contact: contact).school_demo.deliver_now
    end

    let(:org_type) { ['primary'] }

    it 'send email with expected subject' do
      expect(email.subject).to eq(I18n.t('campaign_mailer.school_demo.subject'))
    end

    it 'includes contact name' do
      expect(email.html_part.decoded).to include('Jane')
    end

    it 'sends to correct email' do
      expect(email.to).to eq(['jane@example.org'])
    end

    it 'includes links to demos' do
      expect(body).to have_link(href: short_demo_video_campaigns_url)
      expect(body).to have_link(href: long_demo_video_campaigns_url)
    end

    it 'includes links to next steps' do
      expect(body).to have_link(href: enrol_our_school_url)
      expect(body).to have_link(href: school_pack_campaigns_url)
      expect(body).to have_link(href: schools_url)
      expect(body).to have_link(href: newsletters_url)
    end

    it 'includes link to support pages'
  end

  describe '#send_information_school' do
    before do
      CampaignMailer.with(contact: contact).send_information_school.deliver
    end

    let(:org_type) { ['primary'] }

    it 'send email with expected subject' do
      expect(email.subject).to eq(I18n.t('campaign_mailer.send_information_school.subject'))
    end

    it 'includes contact name' do
      expect(email.html_part.decoded).to include('Jane')
    end

    it 'sends to correct email' do
      expect(email.to).to eq(['jane@example.org'])
    end

    it 'sends the right content'
  end

  describe '#send_information_group' do
    before do
      CampaignMailer.with(contact: contact).send_information_school.deliver
    end

    let(:org_type) { ['multi_academy_trust'] }

    it 'send email with expected subject' do
      expect(email.subject).to eq(I18n.t('campaign_mailer.send_information.subject'))
    end

    it 'includes contact name' do
      expect(email.html_part.decoded).to include('Jane')
    end

    it 'sends to correct email' do
      expect(email.to).to eq(['jane@example.org'])
    end

    it 'sends the right content'

    context 'when sending for a local authority' do
      let(:org_type) { ['local_authority'] }

      it 'sends the right content'
    end
  end
end

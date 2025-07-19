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
  end

  describe '#send_information' do
    before do
      CampaignMailer.with(contact: contact).send_information.deliver
    end

    let(:org_type) { ['primary'] }

    it 'send email with expected subject' do
      expect(email.subject).to eq(I18n.t('campaign_mailer.send_information.subject'))
    end

    it 'includes contact name' do
      expect(email.html_part.decoded).to include('Jane')
    end

    it 'sends to correct email' do
      expect(email.to).to eq(['jane@example.org'])
    end

    context 'when sending for a school' do
      it 'includes common links' do
        expect(body).to have_link(href: demo_video_campaigns_url)
        expect(body).to have_link('Example adult dashboard', href: example_adult_dashboard_campaigns_url)
        expect(body).to have_link('Example pupil dashboard', href: example_pupil_dashboard_campaigns_url)
        expect(body).to have_link(href: case_studies_url)
        expect(body).to have_link(href: pricing_url)
      end

      it 'includes school specific links' do
        expect(body).to have_link(href: 'https://calendly.com/energy-sparks/demo-for-individual-schools')
        expect(body).to have_link(href: school_pack_campaigns_url)
        expect(body).to have_link(href: enrol_our_school_url)
      end

      it 'does not include group specific links' do
        expect(body).not_to have_link(href: 'https://calendly.com/energy-sparks/mat-demo')
        expect(body).not_to have_link(href: example_mat_dashboard_campaigns_url)
        expect(body).not_to have_link(href: example_la_dashboard_campaigns_url)
        expect(body).not_to have_link(href: mat_pack_campaigns_url)
        expect(body).not_to have_link(href: enrol_our_multi_academy_trust_url)
        expect(body).not_to have_link(href: enrol_our_local_authority_url)
      end
    end

    context 'when sending for a multi_academy_trust' do
      let(:org_type) { ['multi_academy_trust'] }

      it 'includes common links' do
        expect(body).to have_link(href: demo_video_campaigns_url)
        expect(body).to have_link('Example adult dashboard', href: example_adult_dashboard_campaigns_url)
        expect(body).to have_link('Example pupil dashboard', href: example_pupil_dashboard_campaigns_url)
        expect(body).to have_link(href: case_studies_url)
        expect(body).to have_link(href: pricing_url)
      end

      it 'includes mat specific links' do
        expect(body).to have_link(href: 'https://calendly.com/energy-sparks/mat-demo')
        expect(body).to have_link(href: example_mat_dashboard_campaigns_url)
        expect(body).to have_link(href: mat_pack_campaigns_url)
        expect(body).to have_link(href: enrol_our_multi_academy_trust_url)
      end

      it 'does not include school specific links' do
        expect(body).not_to have_link(href: 'https://calendly.com/energy-sparks/demo-for-individual-schools')
        expect(body).not_to have_link(href: school_pack_campaigns_url)
        expect(body).not_to have_link(href: enrol_our_school_url)
      end
    end

    context 'when sending for a local_authority' do
      let(:org_type) { ['local_authority'] }

      it 'includes common links' do
        expect(body).to have_link(href: demo_video_campaigns_url)
        expect(body).to have_link('Example adult dashboard', href: example_adult_dashboard_campaigns_url)
        expect(body).to have_link('Example pupil dashboard', href: example_pupil_dashboard_campaigns_url)
        expect(body).to have_link(href: case_studies_url)
        expect(body).to have_link(href: pricing_url)
      end

      it 'includes group specific links' do
        expect(body).to have_link(href: 'https://calendly.com/energy-sparks/mat-demo')
        expect(body).to have_link(href: example_la_dashboard_campaigns_url)
        expect(body).not_to have_link(href: example_mat_dashboard_campaigns_url)
        expect(body).to have_link(href: mat_pack_campaigns_url)
        expect(body).to have_link(href: enrol_our_local_authority_url)
      end

      it 'does not include school specific links' do
        expect(body).not_to have_link(href: 'https://calendly.com/energy-sparks/demo-for-individual-schools')
        expect(body).not_to have_link(href: school_pack_campaigns_url)
        expect(body).not_to have_link(href: enrol_our_school_url)
      end
    end
  end
end

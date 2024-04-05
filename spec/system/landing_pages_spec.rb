require 'rails_helper'

describe 'landing pages', type: :system do
  let(:case_study) { create(:case_study) }

  let(:first_name) { 'First' }
  let(:last_name) { 'Last' }
  let(:job_title) { 'CFO' }
  let(:org_type) { 'Multi-Academy Trust' }
  let(:email) { 'test@example.org' }
  let(:organisation) { 'Fake Academies' }
  # https://fakenumber.org/united-kingdom
  let(:tel) { '01632 960241' }

  let(:expected_contact) do
    {
      first_name: first_name,
      last_name: last_name,
      job_title: job_title,
      organisation: organisation,
      org_type: ['multi_academy_trust'],
      email: email,
      tel: tel,
      consent: true
    }
  end

  before do
    allow(CaseStudy).to receive(:find).and_return(case_study)
  end

  context 'when visiting initial landing page' do
    before do
      visit find_out_more_campaigns_path
    end

    it 'has book demo link' do
      expect(page).to have_link('Book demo')
    end

    it 'has find our more link' do
      expect(page).to have_link('Find out more')
    end
  end

  context 'when completing the more information workflow' do
    before do
      visit find_out_more_campaigns_path
      click_link('Find out more', :match => :first)
    end

    it 'handles form submission correctly' do
      expect(page).to have_content(I18n.t('campaigns.more_information.title'))

      fill_in('First Name', with: first_name)
      fill_in('Last Name', with: last_name)
      fill_in('Job Title', with: job_title)
      fill_in('Organisation', with: organisation)
      select(org_type, from: :contact_org_type)
      fill_in('Email Address', with: email)
      fill_in('Telephone Number', with: tel)
      check(:contact_consent)

      expect(CampaignContactHandlerJob).to receive(:perform_later).with(:more_information, expected_contact)
      allow(CampaignContactHandlerJob).to receive(:perform_later).and_return(true)

      click_on('Next')
      expect(page).to have_content(I18n.t('campaigns.more_info_final.title'))
    end
  end

  context 'when completing the book demo workflow' do
    before do
      visit find_out_more_campaigns_path
      click_link('Book demo', :match => :first)
    end

    it 'handles form submission correctly' do
      expect(page).to have_content(I18n.t('campaigns.book_demo.title'))

      fill_in('First Name', with: first_name)
      fill_in('Last Name', with: last_name)
      fill_in('Job Title', with: job_title)
      fill_in('Organisation', with: organisation)
      select(org_type, from: :contact_org_type)
      fill_in('Email Address', with: email)
      fill_in('Telephone Number', with: tel)
      check(:contact_consent)

      expect(CampaignContactHandlerJob).to receive(:perform_later).with(:book_demo, expected_contact)
      allow(CampaignContactHandlerJob).to receive(:perform_later).and_return(true)

      click_on('Next')
      expect(page).to have_content(I18n.t('campaigns.book_demo_final.title'))
      expect(page).to have_css('.calendly-inline-widget')
    end
  end
end

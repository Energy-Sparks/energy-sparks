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
      expect(page).to have_link('Book a demo', href: book_demo_campaigns_path)
    end

    it 'has find our more link' do
      expect(page).to have_link('Find out more', href: more_information_campaigns_path)
    end

    context 'with UTM parameters' do
      let(:expected_params) do
        {
          utm_medium: 'email',
          utm_campaign: 'test',
          utm_source: 'somewhere'
        }
      end

      before do
        visit find_out_more_campaigns_path(expected_params)
      end

      it 'adds campaign parameters to link' do
        expect(page).to have_link('Book a demo', href: book_demo_campaigns_path(expected_params))
        expect(page).to have_link('Find out more', href: more_information_campaigns_path(expected_params))
      end
    end
  end

  def fill_in_form
    fill_in('First Name', with: first_name)
    fill_in('Last Name', with: last_name)
    fill_in('Job Title', with: job_title)
    fill_in('Organisation', with: organisation)
    select(org_type, from: :contact_org_type)
    fill_in('Email Address', with: email)
    fill_in('Telephone Number', with: tel)
    check(:contact_consent)
  end

  context 'when completing the more information workflow' do
    let(:expected_utm_params) { {} }

    before do
      visit find_out_more_campaigns_path(expected_utm_params)
      click_link('Find out more', :match => :first)
    end

    context 'with no UTM params' do
      it 'handles form submission correctly' do
        expect(page).to have_content(I18n.t('campaigns.more_information.title'))
        fill_in_form
        expect(CampaignContactHandlerJob).to receive(:perform_later).with(:more_information, expected_contact)
        allow(CampaignContactHandlerJob).to receive(:perform_later).and_return(true)
        click_on('Next')
        expect(page).to have_content(I18n.t('campaigns.more_info_final.title'))
      end
    end

    context 'with UTM params' do
      let(:expected_utm_params) do
        {
          utm_medium: 'email',
          utm_campaign: 'test',
          utm_source: 'somewhere'
        }
      end

      it 'passes params to final page' do
        expect(page).to have_content(I18n.t('campaigns.more_information.title'))
        fill_in_form
        allow(CampaignContactHandlerJob).to receive(:perform_later).and_return(true)
        click_on('Next')
        expect(page).to have_content(I18n.t('campaigns.more_info_final.title'))
        params = Rack::Utils.parse_nested_query(URI.parse(page.current_url).query).symbolize_keys!
        expect(params).to include(expected_utm_params)
      end
    end
  end

  context 'when completing the book demo workflow' do
    let(:expected_utm_params) { {} }

    before do
      visit find_out_more_campaigns_path(expected_utm_params)
      click_link('Book a demo', :match => :first)
    end

    context 'with no UTM params' do
      it 'handles form submission correctly' do
        expect(page).to have_content(I18n.t('campaigns.book_demo.title'))
        fill_in_form
        expect(CampaignContactHandlerJob).to receive(:perform_later).with(:book_demo, expected_contact)
        allow(CampaignContactHandlerJob).to receive(:perform_later).and_return(true)
        click_on('Next')
        expect(page).to have_content(I18n.t('campaigns.book_demo_final.title'))
        expect(page).to have_css('.calendly-inline-widget')
      end
    end

    context 'with UTM params' do
      let(:expected_utm_params) do
        {
          utm_medium: 'email',
          utm_campaign: 'test',
          utm_source: 'somewhere'
        }
      end

      it 'passes params to final page' do
        expect(page).to have_content(I18n.t('campaigns.book_demo.title'))
        fill_in_form
        allow(CampaignContactHandlerJob).to receive(:perform_later).and_return(true)
        click_on('Next')
        expect(page).to have_content(I18n.t('campaigns.book_demo_final.title'))
        params = Rack::Utils.parse_nested_query(URI.parse(page.current_url).query).symbolize_keys!
        expect(params).to include(expected_utm_params)
      end
    end
  end

  context 'when following redirects from emails' do
    let!(:school_group) { create(:school_group, public: true)}
    let!(:school) { create(:school, data_enabled: true, visible: true, school_group: school_group)}

    it 'redirects to adult dashboard' do
      visit example_adult_dashboard_campaigns_path
      expect(page).to have_current_path(school_path(school))
    end

    it 'redirects to pupil dashboard' do
      visit example_pupil_dashboard_campaigns_path
      expect(page).to have_current_path(pupils_school_path(school))
    end

    it 'redirects to school group dashboard' do
      visit example_group_dashboard_campaigns_path
      expect(page).to have_current_path(school_group_path(school_group))
    end
  end
end

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

  def fill_in_form(organisation_type = org_type)
    fill_in('First Name', with: first_name)
    fill_in('Last Name', with: last_name)
    fill_in('Job Title', with: job_title)
    fill_in('Organisation', with: organisation)
    select(organisation_type, from: :contact_org_type)
    fill_in('Email Address', with: email)
    fill_in('Telephone Number', with: tel)
    check(:contact_consent)
  end

  context 'when completing the more information workflow' do
    let(:expected_utm_params) { {} }

    before do
      visit product_path(expected_utm_params)
      click_link('Request more information', :match => :first)
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
      visit product_path(expected_utm_params)
      click_link('Watch a demo', :match => :first)
    end

    context 'with no UTM params' do
      context 'when completing as a MAT' do
        it 'handles form submission correctly' do
          expect(page).to have_content(I18n.t('campaigns.book_demo.title'))
          fill_in_form
          expect(CampaignContactHandlerJob).to receive(:perform_later).with(:book_demo, expected_contact)
          allow(CampaignContactHandlerJob).to receive(:perform_later).and_return(true)
          click_on('Next')
          expect(page).to have_content(I18n.t('campaigns.book_demo_final.title'))
          expect(page).to have_css('.calendly-inline-widget')
          widget = find('.calendly-inline-widget')
          expect(widget['data-url']).to match('https://calendly.com/energy-sparks/mat-demo')
        end
      end

      context 'when completing as a school' do
        it 'shows the right calendar link' do
          expect(page).to have_content(I18n.t('campaigns.book_demo.title'))
          fill_in_form('Independent school')
          click_on('Next')
          expect(page).to have_content(I18n.t('campaigns.book_demo_final.title'))
          expect(page).to have_css('.calendly-inline-widget')
          widget = find('.calendly-inline-widget')
          expect(widget['data-url']).to match('https://calendly.com/energy-sparks/demo-for-individual-schools')
        end
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
    let!(:mat_school_group) { create(:school_group, :with_active_schools, group_type: :multi_academy_trust)}
    let!(:la_school_group) { create(:school_group, group_type: :local_authority)}

    it 'redirects to adult dashboard' do
      visit example_adult_dashboard_campaigns_path
      expect(page).to have_current_path(school_path(mat_school_group.schools.first))
    end

    it 'redirects to pupil dashboard' do
      visit example_pupil_dashboard_campaigns_path
      expect(page).to have_current_path(pupils_school_path(mat_school_group.schools.first))
    end

    it 'redirects to MAT dashboard' do
      visit example_mat_dashboard_campaigns_path
      expect(page).to have_current_path(school_group_path(mat_school_group))
    end

    it 'redirects to local authority dashboard' do
      visit example_la_dashboard_campaigns_path
      expect(page).to have_current_path(map_school_group_path(la_school_group))
    end
  end
end

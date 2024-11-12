require 'rails_helper'

RSpec.describe 'case_studies', type: :system do
  context 'when there is an existing case study' do
    let!(:case_study) do
      CaseStudy.create!(title: 'First Case Study', position: 1,
      file_en: fixture_file_upload(Rails.root + 'spec/fixtures/images/newsletter-placeholder.png'))
    end

    before do
      visit case_studies_path
    end

    it 'shows me the resources page' do
      expect(page).to have_content 'Case Studies'
      expect(page).to have_content 'First Case Study'
    end

    it 'shows the expected link' do
      expect(page).to have_link I18n.t('case_studies.download'), href: "/case_studies/#{case_study.id}/download?locale=en"
    end

    it 'serves the file' do
      find("a[href='/case_studies/#{case_study.id}/download?locale=en']").click
      expect(page).to have_http_status(:ok)
    end

    context 'a welsh download is not available' do
      before do
        visit case_studies_path(locale: 'cy')
      end

      it 'the welsh link is not displayed' do
        expect(page).to have_link I18n.t('case_studies.download', :locale => :cy), href: "/case_studies/#{case_study.id}/download?locale=en"
      end
    end
  end

  context 'when case study does not exist' do
    before do
      visit case_study_download_path('unknown')
    end

    it_behaves_like 'a 404 error page'
  end

  context 'when a welsh download is available' do
    let!(:case_study) do
      CaseStudy.create!(title: 'First Case Study', position: 1,
      file_en: fixture_file_upload(Rails.root + 'spec/fixtures/images/newsletter-placeholder.png'),
      file_cy: fixture_file_upload(Rails.root + 'spec/fixtures/images/newsletter-placeholder.png'))
    end

    before do
      visit case_studies_path(locale: 'cy')
    end

    it 'shows the welsh link' do
      expect(page).to have_link I18n.t('case_studies.download', :locale => :cy), href: "/case_studies/#{case_study.id}/download?locale=cy"
    end

    it 'serves the file' do
      find("a[href='/case_studies/#{case_study.id}/download?locale=cy']").click
      expect(page).to have_http_status(:ok)
    end
  end
end

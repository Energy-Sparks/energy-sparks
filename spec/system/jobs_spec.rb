require 'rails_helper'

RSpec.describe 'jobs', :include_application_helper do
  context 'when a job exists' do
    let!(:job)         { create(:job, closing_date: Time.zone.today, title: 'Closes today') }
    let!(:old_job)     { create(:job, closing_date: '2010-01-01', title: 'Old job')}
    let!(:voluntary)   { create(:job, voluntary: true, title: 'Voluntary') }
    let!(:open_role)   { create(:job, closing_date: nil, title: 'Open role') }

    before do
      visit jobs_path
    end

    it 'shows me the jobs page' do
      expect(page).to have_content('Jobs')
    end

    it 'shows me current jobs' do
      expect(page).to have_content(job.title)
      expect(page).to have_content(voluntary.title)
    end

    it 'shows roles with no closing date' do
      expect(page).to have_content(open_role.title)
    end

    it 'hides older jobs' do
      expect(page).not_to have_content(old_job.title)
    end

    it 'shows expected download links' do
      expect(page).to have_link('More information', href: job_download_path(job, serve: :inline))
    end

    it 'serves the file' do
      find("a[href='/jobs/#{job.id}/inline']").click
      expect(page.status_code).to be 200
    end
  end

  context 'when job is not found' do
    before do
      visit job_download_path(id: 'unknown', serve: :inline)
    end

    it_behaves_like 'a 404 error page'
  end
end

require 'rails_helper'

describe "Jobs", type: :system do

  let!(:job)         { create(:job, closing_date: Date.today, title: "Closes today") }
  let!(:old_job)     { create(:job, closing_date: "2010-01-01", title: "Old job")}
  let!(:voluntary)   { create(:job, voluntary: true, title: "Voluntary") }
  let!(:open_role)   { create(:job, closing_date: nil, title: "Open role") }

  before(:each) do
    visit jobs_path
  end

  it 'shows me the jobs page' do
    expect(page).to have_content("Jobs")
  end

  it 'shows me current jobs' do
    expect(page).to have_content(job.title)
    expect(page).to have_content(voluntary.title)
  end

  it 'shows roles with no closing date' do
    expect(page).to have_content(open_role.title)
  end

  it 'hides older jobs' do
    expect(page).to_not have_content(old_job.title)
  end

  it 'shows expected download links' do
    expect(page.has_link? "More information", href: "/jobs/#{job.id}/inline").to be true
  end

  it 'serves the file' do
    find("a[href='/jobs/#{job.id}/inline']").click
    expect(page.status_code).to eql 200
  end
end

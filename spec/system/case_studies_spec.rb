require 'rails_helper'

RSpec.describe "case_studies", type: :system do

  let!(:case_study) { CaseStudy.create!( title: "First Case Study", position: 1,
    file: fixture_file_upload(Rails.root + "spec/fixtures/images/newsletter-placeholder.png"))}

  it 'shows me the resources page' do
    visit case_studies_path
    expect(page.has_content? "Case Studies").to be true
    expect(page.has_content? "First Case Study").to be true
  end

  it 'shows the expected link' do
    visit case_studies_path
    expect(page.has_link? "", href: "/case_studies/#{case_study.id}/download").to be true
  end

  it 'serves the file' do
    visit case_studies_path
    find("a[href='/case_studies/#{case_study.id}/download']").click
    expect(page.status_code).to eql 200
  end
end

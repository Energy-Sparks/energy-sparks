require 'rails_helper'

RSpec.describe "resources", type: :system do
  before do
    @resource_type = ResourceFileType.create!(title: "Resource Collection", position: 1)
    @resource = ResourceFile.create!(title: "A resource", resource_file_type: @resource_type,
      file: fixture_file_upload(Rails.root + "spec/fixtures/images/newsletter-placeholder.png"))
    @other_resource = ResourceFile.create!(title: "Other resource",
     file: fixture_file_upload(Rails.root + "spec/fixtures/images/banes.png"))
  end

  it 'shows me the resources page' do
    visit resources_path
    expect(page.has_content?("Resources")).to be true
    expect(page.has_content?("Resource Collection")).to be true
  end

  it 'shows expected download links' do
    visit resources_path
    expect(page.has_link?("A resource", href: "/resources/#{@resource.id}/inline")).to be true
    expect(page.has_link?("", href: "/resources/#{@resource.id}/download")).to be true
    expect(page.has_link?("Other resource", href: "/resources/#{@other_resource.id}/inline")).to be true
  end

  it 'serves the file' do
    visit resources_path
    find("a[href='/resources/#{@resource.id}/download']").click
    expect(page.status_code).to eql 200
  end
end

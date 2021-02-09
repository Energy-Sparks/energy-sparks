require 'rails_helper'

RSpec.describe "videos", type: :system do

  let!(:video)          { create(:video, youtube_id: "PqoKZjwgmoY", title: "Test video", description: "video description") }

  it 'shows a default video on the home page' do
    visit root_path
    expect( page.has_css? "#featured-videos/div.card-deck").to be true
  end

  it 'displays user video page' do
    visit user_guide_videos_path
    expect(page.has_content? "User guide videos").to be true
    expect(page.has_content? video.title).to be true
    expect(page.has_content? video.description).to be true
  end

  it 'displays all videos' do
    create(:video, youtube_id: "dQw4w9WgXcQ", title: "That video")
    create(:video, youtube_id: "djV11Xbc914", title: "Other video", featured: false)
    create(:video, youtube_id: "nm6DO_7px1I", title: "Final video")

    visit user_guide_videos_path
    expect(page.has_content? "That video").to be true
    expect(page.has_content? "Other video").to be true
    expect(page.has_content? "Final video").to be true
  end
end

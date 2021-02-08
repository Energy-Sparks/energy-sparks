require 'rails_helper'

describe VideoHelper do
  describe '.featured_videos' do
    it "returns an default video when there are none in the database" do
      expect(helper.featured_videos.length).to be 1
    end

    it "returns the expected video" do
      create(:video, youtube_id: "dQw4w9WgXcQ", title: "That video")
      expect(helper.featured_videos.length).to be 1
      expect(helper.featured_videos.first.title).to eql("That video")
    end

    it "only returns featured videos" do
      create(:video, youtube_id: "dQw4w9WgXcQ", title: "That video")
      create(:video, youtube_id: "djV11Xbc914", title: "Other video", featured: false)
      expect(helper.featured_videos(2).length).to be 1
      expect(helper.featured_videos(2).first.title).to eql("That video")
    end
  end
end

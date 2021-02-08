require 'rails_helper'

RSpec.describe Video, type: :model do
  it "created correct embed url" do
    video = Video.new(youtube_id: 12345, title: "test")

    expect( video.embed_url ).to eql "https://www.youtube.com/embed/12345"
  end

end

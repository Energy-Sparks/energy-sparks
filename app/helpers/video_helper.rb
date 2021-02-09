module VideoHelper
  def featured_videos(number = 1)
    featured = Video.featured.sample(number)
    #provide a default based on video previously embedded into home page
    if featured.empty?
      featured << Video.new(youtube_id: "PqoKZjwgmoY", title: "", position: 1)
    end
    featured
  end
end

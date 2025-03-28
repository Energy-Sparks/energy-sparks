class YoutubeController < ApplicationController
  def show
    @youtube = Youtube.new(id: params[:id])
    content = render_to_string(
      partial: 'youtubes/thumbnail',
      locals: { youtube: @youtube },
      formats: [:html]
    )
    render json: {
      sgid: @youtube.attachable_sgid,
      content: content
    }
  end
end

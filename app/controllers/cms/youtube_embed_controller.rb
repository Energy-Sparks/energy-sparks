module Cms
  class YoutubeEmbedController < ApplicationController
    def show
      @youtube_embed = Cms::YoutubeEmbed.new(id: params[:id])
      content = render_to_string(
        partial: 'cms/youtube_embeds/thumbnail',
        locals: { youtube_embed: @youtube_embed },
        formats: [:html]
      )
      render json: {
        sgid: @youtube_embed.attachable_sgid,
        content: content
      }
    end
  end
end

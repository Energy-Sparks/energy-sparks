module Cms
  class YoutubeEmbedController < ApplicationController
    def show
      @embed = Cms::YoutubeEmbed.new(id: params[:id])
      content = render_to_string(
        partial: 'cms/youtube_embeds/thumbnail',
        locals: { embed: @embed },
        formats: [:html]
      )
      render json: {
        sgid: @embed.attachable_sgid,
        content: content
      }
    end
  end
end

module Cms
  class YoutubeEmbedController < ApplicationController
    def show
      @youtube_embed = Cms::YoutubeEmbed.new(id: params[:id])
      render json: {
        sgid: @youtube_embed.attachable_sgid,
        thumbnail_url: @youtube_embed.thumbnail_url
      }
    end
  end
end

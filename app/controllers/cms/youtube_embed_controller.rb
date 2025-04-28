module Cms
  class YoutubeEmbedController < ApplicationController
    def show
      @youtube_embed = Cms::YoutubeEmbed.new(id: params[:id])
      render json: { sgid: @youtube_embed.attachable_sgid,
                     content: ActionText::Attachment.from_attachable(@youtube_embed)
                                                    .to_trix_attachment.attributes['content'] }
    end
  end
end

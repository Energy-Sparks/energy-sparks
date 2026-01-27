# frozen_string_literal: true

module Admin
  module Reports
    class ImagesController < ApplicationController
      include Pagy::Backend
      helper_method :feed_item_path

      def index
        scope = params[:type] == 'activity' ? Activity : Observation
        @pagy, @records = pagy(
          scope.with_image_in_description
                  .includes(rich_text_description: { embeds_attachments: :blob })
                  .order(updated_at: :desc)
        )
      end

      private
    end
  end
end

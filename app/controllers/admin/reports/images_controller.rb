# frozen_string_literal: true

module Admin
  module Reports
    class ImagesController < ApplicationController
      include Pagy::Backend
      helper_method :item_path

      def index
        scope = params[:type] == 'observation' ? Observation : Activity
        if params[:school_group].present?
          scope = scope.joins(:school, school: :school_groupings).where(school_groupings: { school_group_id: params[:school_group] })
        end
        @pagy, @records = pagy(
          scope.with_image_in_description
                  .includes(rich_text_description: { embeds_attachments: :blob })
                  .order(updated_at: :desc)
        )
      end

      private

      def item_path(item)
        case item
        when Observation
          school_intervention_path(item.school, item)
        else
          polymorphic_path([item.school, item])
        end
      end
    end
  end
end

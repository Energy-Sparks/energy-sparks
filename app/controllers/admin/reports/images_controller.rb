# frozen_string_literal: true

module Admin
  module Reports
    class ImagesController < ApplicationController
      include Pagy::Backend
      helper_method :feed_item_path

      def index
        @pagy, @images = pagy(image_feed)
      end

      private

      def feed_item_path(item)
        case item.record_type
        when 'Activity'
          school_activity_path(item.school_id, item.record_id)
        when 'Observation'
          school_intervention_path(item.school_id, item.record_id)
        end
      end

      # Fetches a list of all attachments that have images, along with the id, school id and name as well as its
      # associated activity or an action.
      def image_feed
        records_union = <<~SQL.squish
          (
            SELECT id, school_id, created_at, updated_at, 'Activity' AS record_type FROM activities
            UNION ALL
            SELECT id, school_id, created_at, updated_at, 'Observation' AS record_type FROM observations
          ) AS records
        SQL

        ActiveStorage::Attachment
          .joins(:blob)
          .joins("INNER JOIN action_text_rich_texts
                    ON action_text_rich_texts.id = active_storage_attachments.record_id")
          .joins("INNER JOIN #{records_union}
                    ON records.id = action_text_rich_texts.record_id
                   AND records.record_type = action_text_rich_texts.record_type")
          .joins('INNER JOIN schools ON schools.id = records.school_id')
          .where(
            active_storage_attachments: {
              record_type: 'ActionText::RichText',
              name: 'embeds'
            },
            action_text_rich_texts: { name: 'description' }
          )
          .where("active_storage_blobs.content_type LIKE 'image/%'")
          .select(
            'active_storage_attachments.*',
            'records.record_type AS record_type',
            'records.id AS record_id',
            'records.created_at AS created_at',
            'records.updated_at AS updated_at',
            'schools.id AS school_id',
            'schools.name AS school_name'
          )
          .order('records.updated_at DESC')
      end
    end
  end
end

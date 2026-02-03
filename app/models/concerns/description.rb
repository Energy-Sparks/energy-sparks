# frozen_string_literal: true

module Description
  extend ActiveSupport::Concern

  included do
    scope :with_image_in_description, -> {
      joins(rich_text_description: { embeds_attachments: :blob })
        .where("active_storage_blobs.content_type LIKE 'image/%'")
        .distinct
    }
  end

  def description_includes_images?
    return false unless description

    description.embeds.any? do |embed|
      blob =
        if embed.respond_to?(:attachable)
          embed.attachable
        elsif embed.respond_to?(:blob)
          embed.blob
        end

      blob&.content_type&.start_with?('image/')
    end
  end
end

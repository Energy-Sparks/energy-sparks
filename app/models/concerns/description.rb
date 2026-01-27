# frozen_string_literal: true

module Description
  extend ActiveSupport::Concern

  included do
    # Scope: records whose description contains at least one image blob
    scope :with_image_in_description, -> {
      joins(rich_text_description: { embeds_attachments: :blob })
        .where("active_storage_blobs.content_type LIKE 'image/%'")
        .distinct
    }
  end

  # Instance method: does this record have any embedded images?
  def has_image?
    rich_text_description
      .embeds_attachments
      .joins(:blob)
      .where("active_storage_blobs.content_type LIKE 'image/%'")
      .exists?
  end

  def description_includes_images?
    description&.body&.to_trix_html&.include?('figure')
  end
end

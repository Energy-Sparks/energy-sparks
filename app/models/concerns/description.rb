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
    return false unless description&.body

    html = description.body.to_html
    html.include?('<action-text-attachment') && html.include?('content-type="image/')

    ## Alternative approach using embeds, but does not always work if description is not saved and embeds are not associated
    # description.embeds.any? do |embed|
    #  embed.blob&.content_type&.start_with?('image/')
    # end
  end
end

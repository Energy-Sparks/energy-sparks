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

    fragment = Nokogiri::HTML.fragment(description.body.to_html)
    fragment.css('action-text-attachment').any? do |node|
      node['content-type']&.start_with?('image/')
    end

    # If we just want to check for attachments without checking content type, we could use:
    # description.body.to_html.include?("action-text-attachment")

    ## Alternative approach using embeds, but may not work if description is not saved yet and embeds are not associated
    # description.embeds.any? do |embed|
    #  embed.blob&.content_type&.start_with?('image/')
    # end
  end
end

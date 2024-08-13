# frozen_string_literal: true

module Description
  extend ActiveSupport::Concern

  def description_includes_images?
    description&.body&.to_trix_html&.include?('figure')
  end
end

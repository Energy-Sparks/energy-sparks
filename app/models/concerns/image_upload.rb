# frozen_string_literal: true

module MediumImageValidation
  extend ActiveSupport::Concern

  ALLOWED_CONTENT_TYPES = %w[image/png image/jpeg].freeze

  included do
    # Limit width to between half and full container size.
    validates :image, content_type: ALLOWED_CONTENT_TYPES,
                      dimension: { width: { min: 640, max: 1400 } }
  end
end

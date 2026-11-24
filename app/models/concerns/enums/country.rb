# frozen_string_literal: true

module Enums
  module Country
    extend ActiveSupport::Concern

    ENUM_COUNTRY = {
      england: 'england',
      scotland: 'scotland',
      wales: 'wales'
    }.freeze

    included do
      enum :country, ENUM_COUNTRY

      scope :for_country, ->(country) { where(country: country) }
    end
  end
end

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
    end
  end
end

module Enums::SchoolType
  extend ActiveSupport::Concern

  ENUM_SCHOOL_TYPES = {
    primary: 0, secondary: 1, special: 2, infant: 3, junior: 4, middle: 5,
    mixed_primary_and_secondary: 6
  }.freeze

  included do
    enum :school_type, ENUM_SCHOOL_TYPES
  end
end

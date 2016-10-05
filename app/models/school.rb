class School < ApplicationRecord
  has_many :meters
  has_many :meter_readings, through: :meter

  enum school_type: [:primary, :secondary]
end

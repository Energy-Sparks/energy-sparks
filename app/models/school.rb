class School < ApplicationRecord

  TYPE_PRIMARY = 0
  TYPE_SECONDARY = 1

  has_many :meters
  has_many :meter_readings, through: :meter
end

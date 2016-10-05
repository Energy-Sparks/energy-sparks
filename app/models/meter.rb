class Meter < ApplicationRecord
  belongs_to :school
  has_many :meter_readings

  enum meter_type: [:electricity, :gas]
end

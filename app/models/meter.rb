class Meter < ApplicationRecord

  TYPE_ELECTRICITY = 0
  TYPE_GAS = 1

  belongs_to :school
  has_many :meter_readings

end

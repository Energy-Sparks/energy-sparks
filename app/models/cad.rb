class Cad < ApplicationRecord
  belongs_to :school

  validates_presence_of :name, :device_identifier
end

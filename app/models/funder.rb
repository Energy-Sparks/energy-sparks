class Funder < ApplicationRecord
  has_many :schools
  validates :name, presence: true
end

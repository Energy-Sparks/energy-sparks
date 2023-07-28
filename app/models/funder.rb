class Funder < ApplicationRecord
  has_many :schools
  validates :name, presence: true, uniqueness: true
end

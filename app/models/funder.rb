class Funder < ApplicationRecord
  has_many :schools
  has_many :school_groups

  validates :name, presence: true, uniqueness: true
end

# == Schema Information
#
# Table name: funders
#
#  id   :bigint(8)        not null, primary key
#  name :string           not null
#
class Funder < ApplicationRecord
  has_many :schools
  has_many :school_groups

  scope :with_schools,  -> { where('id IN (SELECT DISTINCT(funder_id) FROM schools)') }
  scope :by_name,       -> { order(name: :asc) }

  validates :name, presence: true, uniqueness: true
end

# == Schema Information
#
# Table name: schools
#
#  address           :text
#  created_at        :datetime         not null
#  eco_school_status :integer
#  id                :integer          not null, primary key
#  name              :string
#  postcode          :string
#  school_type       :integer
#  updated_at        :datetime         not null
#  website           :string
#

class School < ApplicationRecord
  include Usage
  has_many :users, dependent: :destroy
  has_many :meters, inverse_of: :school, dependent: :destroy
  has_many :activities, inverse_of: :school, dependent: :destroy
  has_many :meter_readings, through: :meters

  enum school_type: [:primary, :secondary]
  validates_presence_of :name
  accepts_nested_attributes_for :meters, reject_if: proc { |attributes| attributes[:meter_no].blank? }
end

# == Schema Information
#
# Table name: schools
#
#  address           :text
#  created_at        :datetime         not null
#  eco_school_status :integer
#  enrolled          :boolean          default(FALSE)
#  id                :integer          not null, primary key
#  name              :string
#  postcode          :string
#  school_type       :integer
#  updated_at        :datetime         not null
#  urn               :integer          not null
#  website           :string
#
# Indexes
#
#  index_schools_on_urn  (urn) UNIQUE
#

class School < ApplicationRecord
  include Usage
  has_many :users, dependent: :destroy
  has_many :meters, inverse_of: :school, dependent: :destroy
  has_many :activities, inverse_of: :school, dependent: :destroy
  has_many :meter_readings, through: :meters

  enum school_type: [:primary, :secondary]
  enum eco_school_status: [:bronze, :silver, :green]

  scope :enrolled, -> { where(enrolled: true) }

  validates_presence_of :urn, :name
  validates_uniqueness_of :urn
  accepts_nested_attributes_for :meters, reject_if: proc { |attributes| attributes[:meter_no].blank? }

  def meters?(supply = nil)
    self.meters.where(meter_type: supply).any?
  end
end

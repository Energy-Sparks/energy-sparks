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
  has_many :users
  has_many :meters
  has_many :meter_readings, through: :meter

  enum school_type: [:primary, :secondary]
end

# == Schema Information
#
# Table name: partners
#
#  id         :bigint           not null, primary key
#  name       :string
#  position   :integer          default(0), not null
#  url        :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Partner < ApplicationRecord
  has_one_attached :image

  has_many :school_group_partners, dependent: :delete_all
  has_many :school_groups, through: :school_group_partners

  has_many :school_partners, dependent: :delete_all
  has_many :schools, through: :school_partners

  validates :image, presence: true
  validates :position, numericality: true, presence: true

  def display_name
    name || "Partner #{id}"
  end
end

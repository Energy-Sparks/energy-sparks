# == Schema Information
#
# Table name: partners
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  position   :integer          default(0), not null
#  updated_at :datetime         not null
#

class Partner < ApplicationRecord
  has_one_attached :image

  validates :image, presence: true
  validates :position, numericality: true, presence: true
end

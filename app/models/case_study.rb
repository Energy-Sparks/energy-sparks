# == Schema Information
#
# Table name: case_studies
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  position   :integer          default(0), not null
#  title      :string           not null
#  updated_at :datetime         not null
#

class CaseStudy < ApplicationRecord
  has_one_attached :file
  has_rich_text :description

  validates :title, :file, presence: true
  validates :position, numericality: true, presence: true
end

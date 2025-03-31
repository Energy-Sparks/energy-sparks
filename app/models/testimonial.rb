# == Schema Information
#
# Table name: testimonials
#
#  active        :boolean          default(FALSE), not null
#  case_study_id :bigint(8)
#  category      :integer          default("default"), not null
#  created_at    :datetime         not null
#  id            :bigint(8)        not null, primary key
#  name          :string
#  organisation  :string
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_testimonials_on_case_study_id  (case_study_id)
#
class Testimonial < ApplicationRecord
  extend Mobility
  include TransifexSerialisable

  belongs_to :case_study, optional: true
  has_one_attached :image

  translates :title, type: :string, fallbacks: { cy: :en }
  translates :quote, type: :string, fallbacks: { cy: :en }
  translates :role, type: :string, fallbacks: { cy: :en }

  enum :category, { default: 0 } # need more here

  validates :image, :title_en, :name, :quote_en, :organisation, :category, presence: true

  scope :active, -> { where(active: true) }
end

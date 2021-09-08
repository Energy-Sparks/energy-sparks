# == Schema Information
#
# Table name: intervention_type_groups
#
#  active      :boolean          default(TRUE)
#  created_at  :datetime         not null
#  description :string
#  icon        :string           default("question-circle")
#  id          :bigint(8)        not null, primary key
#  title       :string           not null
#  updated_at  :datetime         not null
#

class InterventionTypeGroup < ApplicationRecord
  has_many :intervention_types

  has_one_attached :image

  scope :by_title, -> { order(title: :asc) }
  scope :active,   -> { where(active: true) }

  validates :title, presence: true, uniqueness: true
end

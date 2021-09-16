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

  def self.listed_with_intervention_types
    all.order(:title).map {|group| [group, group.intervention_types.display_order.to_a]}
  end
end

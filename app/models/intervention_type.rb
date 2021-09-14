# == Schema Information
#
# Table name: intervention_types
#
#  active                     :boolean          default(TRUE)
#  id                         :bigint(8)        not null, primary key
#  intervention_type_group_id :bigint(8)        not null
#  other                      :boolean          default(FALSE)
#  points                     :integer
#  summary                    :string
#  title                      :string           not null
#
# Indexes
#
#  index_intervention_types_on_intervention_type_group_id  (intervention_type_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (intervention_type_group_id => intervention_type_groups.id) ON DELETE => cascade
#

class InterventionType < ApplicationRecord
  belongs_to :intervention_type_group
  has_many :observations

  has_one_attached :image
  has_rich_text :description
  has_rich_text :download_links

  validates :intervention_type_group, :title, presence: true
  validates :title, uniqueness: { scope: :intervention_type_group_id }
  validates :points, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :by_title,      -> { order(title: :asc) }
  scope :active,        -> { where(active: true) }
  scope :display_order, -> { order(:other, :title) }

  scope :not_other, -> { where(other: false) }

  scope :active_and_not_other, -> { active.not_other }

  def display_with_points
    points ? "#{title} (#{points} points)" : title
  end
end

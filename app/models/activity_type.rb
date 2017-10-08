# == Schema Information
#
# Table name: activity_types
#
#  active               :boolean          default(TRUE)
#  activity_category_id :integer
#  badge_name           :string
#  created_at           :datetime         not null
#  data_driven          :boolean          default(FALSE)
#  description          :text
#  id                   :integer          not null, primary key
#  name                 :string
#  repeatable           :boolean          default(TRUE)
#  score                :integer
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_activity_types_on_active                (active)
#  index_activity_types_on_activity_category_id  (activity_category_id)
#
# Foreign Keys
#
#  fk_rails_60d4f5f88d  (activity_category_id => activity_categories.id)
#

class ActivityType < ApplicationRecord
  belongs_to :activity_category
  scope :active, -> { where(active: true) }
  scope :repeatable, -> { where(repeatable: true)}
  scope :data_driven, -> { where(data_driven: true)}
  validates_presence_of :name, :activity_category_id, :score
  validates_uniqueness_of :name, scope: :activity_category_id
  validates_uniqueness_of :badge_name, allow_blank: true, allow_nil: true
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end

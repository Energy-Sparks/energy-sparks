# == Schema Information
#
# Table name: activity_types
#
#  active               :boolean          default(TRUE)
#  activity_category_id :integer
#  badge_name           :string
#  created_at           :datetime         not null
#  custom               :boolean          default(FALSE)
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
#  fk_rails_...  (activity_category_id => activity_categories.id)
#

class ActivityType < ApplicationRecord
  belongs_to :activity_category

  acts_as_taggable_on :key_stages

  where(active: true, custom: false, data_driven: true, repeatable: true)

  scope :active, -> { where(active: true) }
  scope :repeatable, -> { where(repeatable: true) }
  scope :data_driven, -> { where(data_driven: true) }
  scope :random_suggestions, -> { active.repeatable }
  validates_presence_of :name, :activity_category_id, :score
  validates_uniqueness_of :name, scope: :activity_category_id
  validates_uniqueness_of :badge_name, allow_blank: true, allow_nil: true
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  has_many :activity_type_suggestions
  has_many :suggested_types, through: :activity_type_suggestions

  accepts_nested_attributes_for :activity_type_suggestions, reject_if: proc { |attributes| attributes[:suggested_type_id].blank? }, allow_destroy: true

  def key_stages
    key_stage_list.to_a.sort.join(', ')
  end

  def name_with_key_stages
    "#{name} (#{key_stages})"
  end
end

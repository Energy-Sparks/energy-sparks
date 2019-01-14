# == Schema Information
#
# Table name: activity_categories
#
#  badge_name  :string
#  created_at  :datetime         not null
#  description :string
#  id          :bigint(8)        not null, primary key
#  name        :string
#  updated_at  :datetime         not null
#

class ActivityCategory < ApplicationRecord
  has_many :activity_types
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_uniqueness_of :badge_name, allow_blank: true, allow_nil: true

  def sorted_activity_types(by: :name)
    activity_types.where(active: true).other_last.order(by)
  end

  def sorted_activity_types_with_key_stages(by: :name, array_of_key_stages: [])
    activity_types.where(active: true).includes(:key_stages).where(key_stages: { id: array_of_key_stages }).other_last.order(by)
  end
end

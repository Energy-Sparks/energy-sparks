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

  def self.listed_with_activity_types
    all.order(:name).map {|category| [category, category.activity_types.custom_last.order(:name).to_a]}
  end
end

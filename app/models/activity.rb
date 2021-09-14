# == Schema Information
#
# Table name: activities
#
#  activity_category_id :bigint(8)
#  activity_type_id     :bigint(8)        not null
#  created_at           :datetime         not null
#  happened_on          :date
#  id                   :bigint(8)        not null, primary key
#  school_id            :bigint(8)        not null
#  title                :string
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_activities_on_activity_category_id  (activity_category_id)
#  index_activities_on_activity_type_id      (activity_type_id)
#  index_activities_on_school_id             (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (activity_category_id => activity_categories.id) ON DELETE => restrict
#  fk_rails_...  (activity_type_id => activity_types.id) ON DELETE => restrict
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class Activity < ApplicationRecord
  belongs_to :school, inverse_of: :activities
  belongs_to :activity_type, inverse_of: :activities
  belongs_to :activity_category, optional: true

  has_many   :programme_activities
  has_many   :observations

  validates_presence_of :school, :activity_type, :activity_category, :happened_on

  scope :for_school, ->(school) { where(school: school) }

  has_rich_text :description

  self.ignored_columns = %w(deprecated_description)

  def display_name
    activity_type.custom ? title : activity_type.name
  end

  def points
    observations.sum(:points)
  end

  def description_includes_images?
    description.body.to_trix_html.include?("figure")
  end
end

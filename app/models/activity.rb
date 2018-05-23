# == Schema Information
#
# Table name: activities
#
#  activity_category_id :integer
#  activity_type_id     :integer
#  created_at           :datetime         not null
#  description          :text
#  happened_on          :date
#  id                   :integer          not null, primary key
#  school_id            :integer
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
#  fk_rails_...  (activity_category_id => activity_categories.id)
#  fk_rails_...  (activity_type_id => activity_types.id)
#  fk_rails_...  (school_id => schools.id)
#

class Activity < ApplicationRecord
  belongs_to :school, inverse_of: :activities
  belongs_to :activity_type
  belongs_to :activity_category
  validates_presence_of :school_id, :activity_type_id, :activity_category_id, :title, :happened_on
end

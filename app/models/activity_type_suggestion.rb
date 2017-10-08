# == Schema Information
#
# Table name: activity_type_suggestions
#
#  activity_type_id  :integer
#  created_at        :datetime         not null
#  id                :integer          not null, primary key
#  suggested_type_id :integer
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_activity_type_suggestions_on_activity_type_id  (activity_type_id)
#
# Foreign Keys
#
#  fk_rails_8e4909da04  (activity_type_id => activity_types.id)
#

class ActivityTypeSuggestion < ApplicationRecord
  belongs_to :activity_type
  belongs_to :suggested_type, class_name: "ActivityType"

  scope :initial, -> { where(activity_type: nil) }
end

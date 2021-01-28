# == Schema Information
#
# Table name: activity_type_suggestions
#
#  activity_type_id  :bigint(8)
#  created_at        :datetime         not null
#  id                :bigint(8)        not null, primary key
#  suggested_type_id :bigint(8)        not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_activity_type_suggestions_on_activity_type_id   (activity_type_id)
#  index_activity_type_suggestions_on_suggested_type_id  (suggested_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (activity_type_id => activity_types.id) ON DELETE => cascade
#

class ActivityTypeSuggestion < ApplicationRecord
  belongs_to :activity_type, optional: true
  belongs_to :suggested_type, class_name: "ActivityType"

  scope :initial, -> { where(activity_type: nil) }
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: activities_activity_type_durations
#
#  id               :bigint(8)        not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  activity_type_id :bigint(8)        not null
#  duration_id      :bigint(8)        not null
#
# Indexes
#
#  idx_on_activity_type_id_duration_id_1f107c7df1                (activity_type_id,duration_id) UNIQUE
#  index_activities_activity_type_durations_on_activity_type_id  (activity_type_id)
#  index_activities_activity_type_durations_on_duration_id       (duration_id)
#
# Foreign Keys
#
#  fk_rails_...  (activity_type_id => activity_types.id)
#  fk_rails_...  (duration_id => activities_durations.id)
#
module Activities
  class ActivityTypeDuration < ApplicationRecord
    self.table_name = 'activities_activity_type_durations'

    belongs_to :activity_type
    belongs_to :duration
  end
end

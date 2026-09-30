# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks_activity_type_subject_areas
#
#  id               :bigint(8)        not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  activity_type_id :bigint(8)        not null
#  subject_area_id  :bigint(8)        not null
#
# Indexes
#
#  idx_on_activity_type_id_subject_area_id_7ee6044b0b           (activity_type_id,subject_area_id) UNIQUE
#  index_tasks_activity_type_subject_areas_on_activity_type_id  (activity_type_id)
#  index_tasks_activity_type_subject_areas_on_subject_area_id   (subject_area_id)
#
# Foreign Keys
#
#  fk_rails_...  (activity_type_id => activity_types.id)
#  fk_rails_...  (subject_area_id => tasks_subject_areas.id)
#
module Tasks
  class ActivityTypeSubjectArea < ApplicationRecord
    self.table_name = 'tasks_activity_type_subject_areas'

    belongs_to :activity_type
    belongs_to :subject_area
  end
end

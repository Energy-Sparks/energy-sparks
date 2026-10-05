# frozen_string_literal: true

# == Schema Information
#
# Table name: activities_activity_type_subject_areas
#
#  id               :bigint(8)        not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  activity_type_id :bigint(8)        not null
#  subject_area_id  :bigint(8)        not null
#
# Indexes
#
#  idx_on_activity_type_id_e4890ca96a                  (activity_type_id)
#  idx_on_activity_type_id_subject_area_id_1830e25d8f  (activity_type_id,subject_area_id) UNIQUE
#  idx_on_subject_area_id_e66245bb54                   (subject_area_id)
#
# Foreign Keys
#
#  fk_rails_...  (activity_type_id => activity_types.id)
#  fk_rails_...  (subject_area_id => activities_subject_areas.id)
#
module Activities
  class ActivityTypeSubjectArea < ApplicationRecord
    self.table_name = 'activities_activity_type_subject_areas'

    belongs_to :activity_type
    belongs_to :subject_area
  end
end

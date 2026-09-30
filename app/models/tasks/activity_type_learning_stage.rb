# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks_activity_type_learning_stages
#
#  id                :bigint(8)        not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  activity_type_id  :bigint(8)        not null
#  learning_stage_id :bigint(8)        not null
#
# Indexes
#
#  idx_on_activity_type_id_learning_stage_id_752d89db99            (activity_type_id,learning_stage_id) UNIQUE
#  index_tasks_activity_type_learning_stages_on_activity_type_id   (activity_type_id)
#  index_tasks_activity_type_learning_stages_on_learning_stage_id  (learning_stage_id)
#
# Foreign Keys
#
#  fk_rails_...  (activity_type_id => activity_types.id)
#  fk_rails_...  (learning_stage_id => learning_stages.id)
#
module Tasks
  class ActivityTypeLearningStage < ApplicationRecord
    self.table_name = 'tasks_activity_type_learning_stages'

    belongs_to :activity_type
    belongs_to :learning_stage
  end
end

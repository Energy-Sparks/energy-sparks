# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks_activity_type_topics
#
#  id               :bigint(8)        not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  activity_type_id :bigint(8)        not null
#  topic_id         :bigint(8)        not null
#
# Indexes
#
#  idx_on_activity_type_id_topic_id_eb90e9c10e           (activity_type_id,topic_id) UNIQUE
#  index_tasks_activity_type_topics_on_activity_type_id  (activity_type_id)
#  index_tasks_activity_type_topics_on_topic_id          (topic_id)
#
# Foreign Keys
#
#  fk_rails_...  (activity_type_id => activity_types.id)
#  fk_rails_...  (topic_id => tasks_topics.id)
#
module Tasks
  class ActivityTypeTopic < ApplicationRecord
    self.table_name = 'tasks_activity_type_topics'

    belongs_to :activity_type
    belongs_to :topic
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: activities_activity_type_aims
#
#  id               :bigint(8)        not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  activity_type_id :bigint(8)        not null
#  aim_id           :bigint(8)        not null
#
# Indexes
#
#  idx_on_activity_type_id_aim_id_3867f63bb2                (activity_type_id,aim_id) UNIQUE
#  index_activities_activity_type_aims_on_activity_type_id  (activity_type_id)
#  index_activities_activity_type_aims_on_aim_id            (aim_id)
#
# Foreign Keys
#
#  fk_rails_...  (activity_type_id => activity_types.id)
#  fk_rails_...  (aim_id => activities_aims.id)
#
module Activities
  class ActivityTypeAim < ApplicationRecord
    self.table_name = 'activities_activity_type_aims'

    belongs_to :activity_type
    belongs_to :aim
  end
end

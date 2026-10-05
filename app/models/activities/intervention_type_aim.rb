# frozen_string_literal: true

# == Schema Information
#
# Table name: activities_intervention_type_aims
#
#  id                   :bigint(8)        not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  aim_id               :bigint(8)        not null
#  intervention_type_id :bigint(8)        not null
#
# Indexes
#
#  idx_on_intervention_type_id_aim_id_9fe98d157d      (intervention_type_id,aim_id) UNIQUE
#  idx_on_intervention_type_id_e093609ee8             (intervention_type_id)
#  index_activities_intervention_type_aims_on_aim_id  (aim_id)
#
# Foreign Keys
#
#  fk_rails_...  (aim_id => activities_aims.id)
#  fk_rails_...  (intervention_type_id => intervention_types.id)
#
module Activities
  class InterventionTypeAim < ApplicationRecord
    self.table_name = 'activities_intervention_type_aims'

    belongs_to :intervention_type
    belongs_to :aim
  end
end

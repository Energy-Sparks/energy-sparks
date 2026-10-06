# frozen_string_literal: true

# == Schema Information
#
# Table name: actions_intervention_type_focuses
#
#  id                   :bigint(8)        not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  focus_id             :bigint(8)        not null
#  intervention_type_id :bigint(8)        not null
#
# Indexes
#
#  idx_on_intervention_type_id_6a1ee4b473               (intervention_type_id)
#  idx_on_intervention_type_id_focus_id_a6fdf69984      (intervention_type_id,focus_id) UNIQUE
#  index_actions_intervention_type_focuses_on_focus_id  (focus_id)
#
# Foreign Keys
#
#  fk_rails_...  (focus_id => actions_focuses.id)
#  fk_rails_...  (intervention_type_id => intervention_types.id)
#
module Actions
  class InterventionTypeFocus < ApplicationRecord
    self.table_name = 'actions_intervention_type_focuses'

    belongs_to :intervention_type
    belongs_to :focus
  end
end

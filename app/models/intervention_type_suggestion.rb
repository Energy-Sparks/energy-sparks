# == Schema Information
#
# Table name: intervention_type_suggestions
#
#  created_at           :datetime         not null
#  id                   :bigint(8)        not null, primary key
#  intervention_type_id :bigint(8)
#  suggested_type_id    :integer
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_intervention_type_suggestions_on_intervention_type_id  (intervention_type_id)
#  index_intervention_type_suggestions_on_suggested_type_id     (suggested_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (intervention_type_id => intervention_types.id) ON DELETE => cascade
#

class InterventionTypeSuggestion < ApplicationRecord
  belongs_to :intervention_type, optional: true
  belongs_to :suggested_type, class_name: 'InterventionType'

  scope :initial, -> { where(intervention_type: nil) }
end

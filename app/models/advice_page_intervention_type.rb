# == Schema Information
#
# Table name: advice_page_intervention_types
#
#  id                   :bigint           not null, primary key
#  position             :integer
#  advice_page_id       :bigint
#  intervention_type_id :bigint
#
# Indexes
#
#  index_advice_page_intervention_types_on_advice_page_id        (advice_page_id)
#  index_advice_page_intervention_types_on_intervention_type_id  (intervention_type_id)
#
class AdvicePageInterventionType < ApplicationRecord
  belongs_to :advice_page
  belongs_to :intervention_type

  validates :intervention_type, :advice_page, presence: true
end

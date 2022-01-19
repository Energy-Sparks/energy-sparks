# == Schema Information
#
# Table name: audit_intervention_types
#
#  audit_id             :bigint(8)        not null
#  id                   :bigint(8)        not null, primary key
#  intervention_type_id :bigint(8)        not null
#  notes                :text
#  position             :integer          default(0), not null
#
# Indexes
#
#  audit_intervention_type_uniq  (audit_id,intervention_type_id) UNIQUE
#
class AuditInterventionType < ApplicationRecord
  belongs_to :intervention_type
  belongs_to :audit

  validates :intervention_type, :audit, presence: true

  scope :by_title, -> { joins(:intervention_type).order('intervention_types.title ASC') }

  def intervention_title
    intervention_type.title
  end
end

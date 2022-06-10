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
#  index_audit_intervention_types_on_audit_id  (audit_id)
#
class AuditInterventionType < ApplicationRecord
  belongs_to :intervention_type
  belongs_to :audit

  validates :intervention_type, :audit, presence: true

  scope :by_title, -> { joins(:intervention_type).order('intervention_types.name ASC') }

  def intervention_title
    intervention_type.name
  end
end

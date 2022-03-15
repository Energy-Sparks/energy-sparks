# == Schema Information
#
# Table name: audit_activity_types
#
#  activity_type_id :bigint(8)        not null
#  audit_id         :bigint(8)        not null
#  id               :bigint(8)        not null, primary key
#  notes            :text
#  position         :integer          default(0), not null
#
# Indexes
#
#  index_audit_activity_types_on_audit_id  (audit_id)
#
class AuditActivityType < ApplicationRecord
  belongs_to :activity_type
  belongs_to :audit

  validates :activity_type, :audit, presence: true

  scope :by_name, -> { joins(:activity_type).order('activity_types.name ASC') }

  def activity_name
    activity_type.name
  end
end

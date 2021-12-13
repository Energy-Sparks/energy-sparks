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
#  audit_activity_type_uniq  (audit_id,activity_type_id) UNIQUE
#
class AuditActivityType < ApplicationRecord
  belongs_to :activity_type
  belongs_to :audit

  validates :activity_type, :audit, presence: true

  def activity_name
    activity_type.name
  end
end

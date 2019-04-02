# == Schema Information
#
# Table name: alert_type_activity_types
#
#  activity_type_id :bigint(8)        not null
#  alert_type_id    :bigint(8)        not null
#  id               :bigint(8)        not null, primary key
#  position         :integer          default(0), not null
#
# Indexes
#
#  activity_alert_uniq  (alert_type_id,activity_type_id) UNIQUE
#

class AlertTypeActivityType < ApplicationRecord
  belongs_to :activity_type
  belongs_to :alert_type

  validates :activity_type, :alert_type, presence: true
end

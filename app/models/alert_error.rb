# == Schema Information
#
# Table name: alert_errors
#
#  alert_generation_run_id :bigint(8)
#  alert_type_id           :bigint(8)
#  asof_date               :date
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  information             :text
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_alert_errors_on_alert_generation_run_id  (alert_generation_run_id)
#  index_alert_errors_on_alert_type_id            (alert_type_id)
#

class AlertError < ApplicationRecord
  belongs_to :alert_type
  belongs_to :alert_generation_run
end

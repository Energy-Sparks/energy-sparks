# == Schema Information
#
# Table name: alerts
#
#  acknowledged  :boolean          default(FALSE)
#  alert_type_id :bigint(8)
#  created_at    :datetime         not null
#  data          :json
#  id            :bigint(8)        not null, primary key
#  run_on        :date
#  school_id     :bigint(8)
#  status        :text
#  summary       :text
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_alerts_on_alert_type_id  (alert_type_id)
#  index_alerts_on_school_id      (school_id)
#  unique_alerts                  (school_id,alert_type_id,run_on) UNIQUE
#

class Alert < ApplicationRecord
  belongs_to :school,     inverse_of: :alerts
  belongs_to :alert_type, inverse_of: :alerts
end

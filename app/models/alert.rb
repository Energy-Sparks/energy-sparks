# == Schema Information
#
# Table name: alerts
#
#  acknowledged  :boolean
#  alert_data    :hstore
#  alert_type_id :bigint(8)
#  id            :bigint(8)        not null, primary key
#  school_id     :bigint(8)
#  status        :text
#  summary       :text
#  when_run      :date
#
# Indexes
#
#  index_alerts_on_alert_type_id  (alert_type_id)
#  index_alerts_on_school_id      (school_id)
#

class Alert < ApplicationRecord
  belongs_to :school,     inverse_of: :alerts
  belongs_to :alert_type, inverse_of: :alerts

  store :data, coder: JSON

  def example_hash
    { woof: 'meow', agrgh: 'crash' }
  end
end

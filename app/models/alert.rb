# == Schema Information
#
# Table name: alerts
#
#  alert_type_id :bigint(8)
#  created_at    :datetime         not null
#  data          :json
#  id            :bigint(8)        not null, primary key
#  run_on        :date
#  school_id     :bigint(8)
#  status        :integer
#  summary       :text
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_alerts_on_alert_type_id  (alert_type_id)
#  index_alerts_on_school_id      (school_id)
#

class Alert < ApplicationRecord
  belongs_to :school,     inverse_of: :alerts
  belongs_to :alert_type, inverse_of: :alerts

  delegate :title, to: :alert_type
  delegate :description, to: :alert_type

  enum status: [:good, :poor, :not_enough_data, :error]

  def rating
    data['rating']
  end

  def detail
    data['detail']
  end

  def help_url
    data['help_url']
  end

  def type
    data['type']
  end

  def term
    data['term']
  end
end

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

  has_many :alert_subscription_events

  delegate :title, to: :alert_type
  delegate :description, to: :alert_type
  delegate :display_fuel_type, to: :alert_type

  scope :electricity,         -> { joins(:alert_type).merge(AlertType.electricity) }
  scope :gas,                 -> { joins(:alert_type).merge(AlertType.gas) }
  scope :no_fuel,             -> { joins(:alert_type).merge(AlertType.no_fuel) }
  scope :termly,              -> { joins(:alert_type).merge(AlertType.termly) }
  scope :weekly,              -> { joins(:alert_type).merge(AlertType.weekly) }
  scope :before_each_holiday, -> { joins(:alert_type).merge(AlertType.before_each_holiday) }

  enum status: [:good, :poor, :not_enough_data, :error]

  scope :latest, -> { order(created_at: :desc).group_by { |alert| [alert.alert_type_id] }.values.map(&:first) }

  # Data hash may end up being attributes of alert
  # Also uses string keys as serialised as JSON in DB
  def detail
    data['detail']
  end

  def help_url
    data['help_url']
  end

  def frequency
    alert_type.frequency
  end

  def show_ratings?
    alert_type.show_ratings
  end

  def rating
    data['rating'].nil? ? 'Unrated' : "#{data['rating'].round(0)}/10"
  end
end

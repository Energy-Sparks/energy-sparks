# == Schema Information
#
# Table name: alerts
#
#  alert_type_id   :bigint(8)        not null
#  analytics_valid :boolean          default(TRUE), not null
#  chart_data      :json
#  created_at      :datetime         not null
#  displayable     :boolean          default(TRUE), not null
#  enough_data     :integer
#  id              :bigint(8)        not null, primary key
#  priority_data   :json
#  rating          :decimal(, )
#  relevance       :integer          default("relevant")
#  run_on          :date
#  school_id       :bigint(8)        not null
#  table_data      :json
#  template_data   :json
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_alerts_on_alert_type_id  (alert_type_id)
#  index_alerts_on_school_id      (school_id)
#

class Alert < ApplicationRecord
  belongs_to :school,     inverse_of: :alerts
  belongs_to :alert_type, inverse_of: :alerts

  has_many :find_out_mores, inverse_of: :alert
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

  scope :rating_between, ->(from, to) { where("rating BETWEEN ? AND ?", from, to) }

  enum enough_data: [:enough, :not_enough, :minimum_might_not_be_accurate], _prefix: :data
  enum relevance: [:relevant, :not_relevant, :never_relevant], _prefix: :relevance

  def self.latest
    select('DISTINCT ON ("alert_type_id") alerts.*').order('alert_type_id', created_at: :desc)
  end

  def frequency
    alert_type.frequency
  end

  def formatted_rating
    rating.nil? ? 'Unrated' : "#{rating.round(0)}/10"
  end

  def template_variables
    template_data.deep_transform_keys do |key|
      :"#{key.to_s.gsub('£', 'gbp')}"
    end
  end

  def chart_variables_hash
    chart_data
  end

  def tables
    table_data.values
  end
end

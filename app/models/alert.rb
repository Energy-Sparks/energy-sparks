# == Schema Information
#
# Table name: alerts
#
#  alert_generation_run_id :bigint(8)
#  alert_type_id           :bigint(8)        not null
#  analytics_valid         :boolean          default(TRUE), not null
#  chart_data              :json
#  comparison_report_id    :bigint(8)
#  created_at              :datetime         not null
#  displayable             :boolean          default(TRUE), not null
#  enough_data             :integer
#  id                      :bigint(8)        not null, primary key
#  priority_data           :json
#  rating                  :decimal(, )
#  relevance               :integer          default("relevant")
#  reporting_period        :integer
#  run_on                  :date
#  school_id               :bigint(8)        not null
#  table_data              :json
#  template_data           :json
#  template_data_cy        :json
#  updated_at              :datetime         not null
#  variables               :jsonb
#
# Indexes
#
#  index_alerts_on_alert_generation_run_id       (alert_generation_run_id)
#  index_alerts_on_alert_type_id                 (alert_type_id)
#  index_alerts_on_alert_type_id_and_created_at  (alert_type_id,created_at)
#  index_alerts_on_comparison_report_id          (comparison_report_id)
#  index_alerts_on_run_on                        (run_on)
#  index_alerts_on_school_id                     (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_generation_run_id => alert_generation_runs.id) ON DELETE => cascade
#  fk_rails_...  (alert_type_id => alert_types.id) ON DELETE => cascade
#  fk_rails_...  (comparison_report_id => comparison_reports.id)
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class Alert < ApplicationRecord
  include Enums::ReportingPeriod
  include AlertTypeWithComparisonReport

  belongs_to :school,               inverse_of: :alerts
  belongs_to :alert_type,           inverse_of: :alerts
  belongs_to :alert_generation_run, optional: true
  belongs_to :comparison_report, class_name: 'Comparison::Report', optional: true

  has_many :find_out_mores, inverse_of: :alert
  has_many :alert_subscription_events

  has_many :alert_type_ratings, lambda { |alert|
    alert.rating.present? ? for_rating(alert.rating.to_f.round(1)) : none
  }, primary_key: 'alert_type_id', foreign_key: 'alert_type_id'
  has_many :intervention_types, through: :alert_type_ratings
  has_many :activity_types, through: :alert_type_ratings

  delegate :title, to: :alert_type
  delegate :description, to: :alert_type
  delegate :display_fuel_type, to: :alert_type

  scope :electricity,         -> { joins(:alert_type).merge(AlertType.electricity_fuel_type) }
  scope :gas,                 -> { joins(:alert_type).merge(AlertType.gas_fuel_type) }
  scope :with_fuel_type,      -> { joins(:alert_type).select('alert_types.fuel_type, alerts.*') }
  scope :no_fuel,             -> { joins(:alert_type).merge(AlertType.no_fuel) }
  scope :termly,              -> { joins(:alert_type).merge(AlertType.termly) }
  scope :weekly,              -> { joins(:alert_type).merge(AlertType.weekly) }
  scope :before_each_holiday, -> { joins(:alert_type).merge(AlertType.before_each_holiday) }

  scope :analytics, -> { joins(:alert_type).merge(AlertType.analytics) }
  scope :system,    -> { joins(:alert_type).merge(AlertType.system) }
  scope :analysis,  -> { joins(:alert_type).merge(AlertType.analysis) }

  scope :by_type, -> { joins(:alert_type).order('alert_types.title') }

  scope :rating_between, ->(from, to) { where('rating BETWEEN ? AND ?', from, to) }
  scope :by_rating, ->(order: :asc) { order(rating: order) }

  enum :enough_data, { enough: 0, not_enough: 1, minimum_might_not_be_accurate: 2 }, prefix: :data
  enum :relevance, { relevant: 0, not_relevant: 1, never_relevant: 2 }, prefix: :relevance

  scope :without_exclusions, lambda {
    joins(:alert_type).joins('LEFT OUTER JOIN school_alert_type_exclusions ON school_alert_type_exclusions.school_id = alerts.school_id AND school_alert_type_exclusions.alert_type_id = alert_types.id').where(school_alert_type_exclusions: { school_id: nil })
  }
  scope :displayable, -> { where(displayable: true) }

  delegate :advice_page, to: :alert_type

  delegate :frequency, to: :alert_type

  def formatted_rating
    rating.nil? ? 'Unrated' : "#{rating.round(0)}/10"
  end

  def template_variables(locale = I18n.locale)
    template_data_for_locale(locale).deep_transform_keys do |key|
      :"#{key.to_s.gsub('£', 'gbp')}"
    end
  end

  private

  def template_data_for_locale(locale)
    if locale == :cy
      template_data_cy&.any? ? template_data_cy : template_data
    else
      template_data
    end
  end
end

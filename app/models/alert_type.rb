# == Schema Information
#
# Table name: alert_types
#
#  advice_page_id  :bigint(8)
#  background      :boolean          default(FALSE)
#  benchmark       :boolean          default(FALSE)
#  class_name      :text
#  enabled         :boolean          default(TRUE), not null
#  frequency       :integer
#  fuel_type       :integer
#  group           :integer          default("advice"), not null
#  has_ratings     :boolean          default(TRUE)
#  id              :bigint(8)        not null, primary key
#  link_to         :integer          default("insights_page"), not null
#  link_to_section :string
#  source          :integer          default("analytics"), not null
#  sub_category    :integer
#  title           :text
#  user_restricted :boolean          default(FALSE), not null
#
# Indexes
#
#  index_alert_types_on_advice_page_id  (advice_page_id)
#

class AlertType < ApplicationRecord
  SUB_CATEGORIES = %i[hot_water heating baseload electricity_use solar_pv tariffs co2 boiler_control overview storage_heaters].freeze

  belongs_to :advice_page, optional: true

  has_many :alerts

  has_many :ratings, class_name: 'AlertTypeRating'
  has_many :school_alert_type_exclusions

  enum source: { analytics: 0, system: 1, analysis: 2 }
  enum fuel_type: { electricity: 0, gas: 1, storage_heater: 2, solar_pv: 3 }, _suffix: :fuel_type
  enum sub_category: SUB_CATEGORIES
  enum frequency: { termly: 0, weekly: 1, before_each_holiday: 2 }
  enum group: { advice: 0, benchmarking: 1, change: 2, priority: 3 }
  enum link_to: { insights_page: 0, analysis_page: 1, learn_more_page: 2 }

  scope :enabled,       -> { where(enabled: true) }
  scope :electricity,   -> { where(fuel_type: :electricity) }
  scope :gas,           -> { where(fuel_type: :gas) }
  scope :no_fuel,       -> { where(fuel_type: nil) }

  scope :editable, -> { where.not(background: true) }

  validates :frequency, :title, :class_name, :source, :group, presence: true

  has_rich_text :description

  def display_fuel_type
    return 'No fuel type' if fuel_type.nil?

    fuel_type.humanize
  end

  def advice_page_tab_for_link_to
    case link_to.to_sym
    when :analysis_page
      :analysis
    when :learn_more_page
      :learn_more
    else
      :insights
    end
  end

  def cleaned_template_variables
    # TODO: make the analytics code remove the £ sign
    class_name.constantize.front_end_template_variables.deep_transform_keys do |key|
      :"#{key.to_s.gsub('£', 'gbp')}"
    end
  end

  def available_charts
    class_name.constantize.front_end_template_charts.map { |variable_name, values| [values[:description], variable_name] }
  end

  def available_tables
    class_name.constantize.front_end_template_tables.map { |variable_name, values| [values[:description], variable_name] }
  end

  def worst_management_priority_rating
    ratings.where(management_priorities_active: true).order(:rating_from).last
  end
end

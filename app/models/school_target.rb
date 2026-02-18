# frozen_string_literal: true

# == Schema Information
#
# Table name: school_targets
#
#  created_at                          :datetime         not null
#  electricity                         :float
#  electricity_monthly_consumption     :jsonb
#  electricity_progress                :json
#  gas                                 :float
#  gas_monthly_consumption             :jsonb
#  gas_progress                        :json
#  id                                  :bigint(8)        not null, primary key
#  report_last_generated               :datetime
#  revised_fuel_types                  :string           default([]), not null, is an Array
#  school_id                           :bigint(8)        not null
#  start_date                          :date
#  storage_heaters                     :float
#  storage_heaters_monthly_consumption :jsonb
#  storage_heaters_progress            :json
#  target_date                         :date
#  updated_at                          :datetime         not null
#
# Indexes
#
#  index_school_targets_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
class SchoolTarget < ApplicationRecord
  belongs_to :school

  # for timeline entry
  has_many :observations, as: :observable, dependent: :destroy

  validates :target_date, :start_date, presence: true
  validate :must_have_one_target

  validates :electricity, :gas, :storage_heaters,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_blank: true

  scope :by_date, -> { order(created_at: :desc) }
  scope :by_start_date, -> { order(start_date: :desc) }
  scope :expired, -> { where(':now >= start_date and :now >= target_date', now: Time.zone.today) }
  scope :currently_active, -> { where('start_date <= :now and :now <= target_date', now: Time.zone.today) }

  before_save :adjust_target_date
  after_update :ensure_observation_date_is_correct
  after_save :add_observation

  alias_attribute :storage_heater, :storage_heaters
  alias_attribute :storage_heater_monthly_consumption, :storage_heaters_monthly_consumption
  alias_attribute :storage_heater_progress, :storage_heaters_progress

  FUEL_TYPES = %i[electricity gas storage_heater].freeze

  def current?
    Time.zone.now >= start_date && Time.zone.now <= target_date
  end

  def expired?
    Time.zone.now >= start_date && Time.zone.now >= target_date
  end

  def meter_attributes_by_meter_type
    attributes = {}
    attributes[:aggregated_electricity] = [meter_attribute_for_electricity_target] if electricity.present?
    attributes[:aggregated_gas] = [meter_attribute_for_gas_target] if gas.present?
    attributes[:storage_heater_aggregated] = [meter_attribute_for_storage_heaters_target] if storage_heaters.present?
    attributes
  end

  def meter_attribute_for_electricity_target
    MeterAttribute.new(attribute_type: :targeting_and_tracking, input_data: target_to_hash(electricity))
  end

  def meter_attribute_for_gas_target
    MeterAttribute.new(attribute_type: :targeting_and_tracking, input_data: target_to_hash(gas))
  end

  def meter_attribute_for_storage_heaters_target
    MeterAttribute.new(attribute_type: :targeting_and_tracking, input_data: target_to_hash(storage_heaters))
  end

  def suggest_revision?
    revised_fuel_types.any?
  end

  MONTHLY_CONSUMPTION_FIELDS =
    %i[year month current_consumption previous_consumption target_consumption current_missing previous_missing manual]
    .each_with_index.to_h

  def monthly_consumption(fuel_type)
    self["#{fuel_type}_monthly_consumption"]&.map do |month|
      consumption = MONTHLY_CONSUMPTION_FIELDS.keys.zip(month).to_h
      consumption[:missing] = consumption[:current_missing] || consumption[:previous_missing]
      consumption
    end
  end

  def target(fuel_type)
    self[fuel_type]
  end

  private

  def target_to_hash(target)
    {
      start_date: start_date,
      target: target_to_percent_reduction(target)
    }
  end

  def target_to_percent_reduction(target)
    (100.0 - target) / 100.0
  end

  def must_have_one_target
    return unless electricity.blank? && gas.blank? && storage_heaters.blank?

    errors.add :base, 'At least one target must be provided'
  end

  def adjust_target_date
    self.target_date = start_date.next_year
  end

  def add_observation
    return if observations.school_target.any?

    observations.school_target.create!(at: start_date, points: 10)
  end

  def ensure_observation_date_is_correct
    observations.school_target.update_all(at: start_date)
  end
end

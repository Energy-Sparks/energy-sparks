# == Schema Information
#
# Table name: school_targets
#
#  created_at               :datetime         not null
#  electricity              :float
#  electricity_progress     :json
#  gas                      :float
#  gas_progress             :json
#  id                       :bigint(8)        not null, primary key
#  report_last_generated    :datetime
#  revised_fuel_types       :string           default([]), not null, is an Array
#  school_id                :bigint(8)        not null
#  start_date               :date
#  storage_heaters          :float
#  storage_heaters_progress :json
#  target_date              :date
#  updated_at               :datetime         not null
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

  validates_presence_of :school, :target_date, :start_date
  validate :must_have_one_target

  validates :electricity, :gas, :storage_heaters, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_blank: true

  scope :by_date, -> { order(created_at: :desc) }
  scope :by_start_date, -> { order(start_date: :desc) }

  scope :currently_active, -> { where('start_date <= ? and target_date <= ?', Time.zone.today, Time.zone.today.next_year) }

  before_save :adjust_target_date

  def current?
    Time.zone.now >= start_date && Time.zone.now <= target_date
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

  def to_progress_summary
    Targets::ProgressSummary.new(
      school_target: self,
      electricity: electricity_progress.any? ? Targets::FuelProgress.new(electricity_progress.symbolize_keys!) : nil,
      gas: gas_progress.any? ? Targets::FuelProgress.new(gas_progress.symbolize_keys!) : nil,
      storage_heater: storage_heaters_progress.any? ? Targets::FuelProgress.new(storage_heaters_progress.symbolize_keys!) : nil
    )
  end

  private

  def target_to_hash(target)
    {
      start_date: start_date,
      target: target_to_percent_reduction(target)
    }
  end

  def target_to_percent_reduction(target)
    return (100.0 - target) / 100.0
  end

  def must_have_one_target
    if electricity.blank? && gas.blank? && storage_heaters.blank?
      errors.add :base, "At least one target must be provided"
    end
  end

  def adjust_target_date
    self.target_date = self.start_date.next_year
  end
end

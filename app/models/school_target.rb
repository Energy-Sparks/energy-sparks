# == Schema Information
#
# Table name: school_targets
#
#  created_at               :datetime         not null
#  electricity              :float
#  electricity_progress     :json
#  electricity_report       :jsonb
#  gas                      :float
#  gas_progress             :json
#  gas_report               :jsonb
#  id                       :bigint(8)        not null, primary key
#  report_last_generated    :datetime
#  revised_fuel_types       :string           default([]), not null, is an Array
#  school_id                :bigint(8)        not null
#  start_date               :date
#  storage_heaters          :float
#  storage_heaters_progress :json
#  storage_heaters_report   :jsonb
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

  #for timeline entry
  has_many :observations, dependent: :destroy

  validates_presence_of :school, :target_date, :start_date
  validate :must_have_one_target

  validates :electricity, :gas, :storage_heaters, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_blank: true

  scope :by_date, -> { order(created_at: :desc) }
  scope :by_start_date, -> { order(start_date: :desc) }
  scope :expired, -> { where(":now >= start_date and :now >= target_date", now: Time.zone.today) }
  scope :currently_active, -> { where('start_date <= :now and :now <= target_date', now: Time.zone.today) }

  before_save :adjust_target_date
  after_save :add_observation
  after_update :ensure_observation_date_is_correct

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

  def to_progress_summary
    Targets::ProgressSummary.new(
      school_target: self,
      electricity: electricity_progress.any? ? Targets::FuelProgress.new(**electricity_progress.symbolize_keys!) : nil,
      gas: gas_progress.any? ? Targets::FuelProgress.new(**gas_progress.symbolize_keys!) : nil,
      storage_heater: storage_heaters_progress.any? ? Targets::FuelProgress.new(**storage_heaters_progress.symbolize_keys!) : nil
    )
  end

  def saved_progress_report_for(fuel_type)
    fuel_type = :storage_heaters if fuel_type == :storage_heater
    raise "Invalid fuel type" unless [:electricity, :gas, :storage_heaters].include?(fuel_type)
    report = self["#{fuel_type}_report".to_sym]
    return nil unless report&.any?
    TargetsProgress.new(**reformat_saved_report(report))
  end

  private

  #ensure TargetsProgress is round-tripped properly
  def reformat_saved_report(report)
    report.symbolize_keys!
    report[:fuel_type] = report[:fuel_type].to_sym
    #reparse to Dates from yyyy-mm-dd format
    report[:months].map! {|m| Date.strptime(m, '%Y-%m-%d')}
    report
  end

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

  def add_observation
    unless observations.any?
      Observation.create!(
        school: school,
        observation_type: :school_target,
        school_target: self,
        at: start_date,
        points: 0
      )
    end
  end

  def ensure_observation_date_is_correct
    observations.update_all(at: start_date)
  end
end

class SchoolTarget < ApplicationRecord
  belongs_to :school

  validates_presence_of :school, :target_date, :start_date
  validate :must_have_one_target

  scope :by_date, -> { order(created_at: :desc) }

  def current?
    Time.zone.now <= target_date
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

  private

  def target_to_hash(target)
    {
      start_date: start_date,
      target: target_to_percent_reduction(target)
    }
  end

  def target_to_percent_reduction(target)
    return 100.0 - target
  end

  def must_have_one_target
    if electricity.blank? && gas.blank? && storage_heaters.blank?
      errors.add :base, "At least one target must be provided"
    end
  end
end

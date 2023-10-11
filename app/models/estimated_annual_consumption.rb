# == Schema Information
#
# Table name: estimated_annual_consumptions
#
#  created_at      :datetime         not null
#  electricity     :float
#  gas             :float
#  id              :bigint(8)        not null, primary key
#  school_id       :bigint(8)        not null
#  storage_heaters :float
#  updated_at      :datetime         not null
#  year            :integer          not null
#
# Indexes
#
#  index_estimated_annual_consumptions_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
class EstimatedAnnualConsumption < ApplicationRecord
  belongs_to :school

  validates :school, :year, presence: true
  validate :must_have_one_estimate

  def meter_attributes_by_meter_type
    attributes = {}
    attributes[:aggregated_electricity] = [meter_attribute_for_electricity_estimate] if electricity.present?
    attributes[:aggregated_gas] = [meter_attribute_for_gas_estimate] if gas.present?
    attributes[:storage_heater_aggregated] = [meter_attribute_for_storage_heaters_estimate] if storage_heaters.present?
    attributes
  end

  def meter_attribute_for_electricity_estimate
    MeterAttribute.new(attribute_type: :estimated_period_consumption, input_data: estimate_to_hash(electricity))
  end

  def meter_attribute_for_gas_estimate
    MeterAttribute.new(attribute_type: :estimated_period_consumption, input_data: estimate_to_hash(gas))
  end

  def meter_attribute_for_storage_heaters_estimate
    MeterAttribute.new(attribute_type: :estimated_period_consumption, input_data: estimate_to_hash(storage_heaters))
  end

  private

  def estimate_to_hash(estimate)
    {
      start_date: Date.new(year, 1, 1).iso8601,
      end_date: Date.new(year, 12, 31).iso8601,
      kwh: estimate
    }
  end

  def must_have_one_estimate
    if electricity.blank? && gas.blank? && storage_heaters.blank?
      errors.add :base, 'At least one estimate must be provided'
    end
  end
end

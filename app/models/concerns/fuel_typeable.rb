module FuelTypeable
  extend ActiveSupport::Concern
  VALID_FUEL_TYPES = %i[gas electricity solar storage_heater].freeze

  private

  def all_fuel_types_are_in_valid_fuel_types_list
    return if fuel_type.reject(&:blank?).empty?

    invalid_fuel_types = (fuel_type.reject(&:blank?).map(&:to_s) - VALID_FUEL_TYPES.map(&:to_s))

    return if invalid_fuel_types.empty?

    errors.add(:fuel_type, I18n.t("#{self.class.name.tableize}.errors.invalid_fuel_type", count: invalid_fuel_types.count) + invalid_fuel_types.to_sentence)
  end
end

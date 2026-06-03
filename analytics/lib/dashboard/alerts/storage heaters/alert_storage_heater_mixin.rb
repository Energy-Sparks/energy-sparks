module AlertGasToStorageHeaterSubstitutionMixIn
  def needs_storage_heater_data?
    true
  end

  def aggregate_meter
    @school.storage_heater_meter
  end

  def self.fuel_lc
    'storage heater'
  end

  def self.fuel_cap
    'Storage heater'
  end

  def self.template_variables
    specific = self.superclass.template_variables
    substitute_template_variables_fuel_type(specific, 'gas', 'storage heater', 'Gas', 'Storage heater', :electricity)
    specific
  end

  def self.substitute_template_variables_fuel_type(variable_groups, from_lc, to_lc, from_cap, to_cap, fuel_sym)
    variable_groups.transform_keys! { |key| key.gsub(from_lc, to_lc).gsub(from_cap, to_cap) }
    variable_groups.each do |group_description, variables|
      variables.each do |variable, definition|
        definition[:units] = { kwh: fuel_sym } if definition.key?(:units) && definition[:units].is_a?(Hash) && definition[:units].key?(:kwh)
        definition[:units] = { £:   fuel_sym } if definition.key?(:units) && definition[:units].is_a?(Hash) && definition[:units].key?(:£)
        if definition.key?(:description) && !definition[:description].nil?
          definition[:description] = definition[:description].gsub(from_lc, to_lc).gsub(from_cap, to_cap)
        end
      end
    end
    variable_groups
  end

  # needs electricity_cost_co2_mixin.rb
  def gas_cost_deprecated(kwh)
    kwh * blended_electricity_£_per_kwh
  end

  def gas_co2(kwh)
    kwh * blended_co2_per_kwh
  end

  def tariff
    blended_electricity_£_per_kwh
  end

  def co2_intensity_per_kwh
    blended_co2_per_kwh
  end
end

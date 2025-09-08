require 'singleton'
class AllEquivalences
  include Singleton

  def available_equivalence_types(kwh_or_co2_or_£ = :kwh)
    puts "Grid = #{electricity_grid_carbon_intensity}"
    EnergyEquivalences.equivalence_choice_by_via_type(kwh_or_co2_or_£)
  end

  def all_eqivalence_types
    {
      kwh: available_equivalence_types(:kwh),
      co2: available_equivalence_types(:co2),
      £:   available_equivalence_types(:£)
    }
  end

  def convert(val, equivalence_type = :tree, via_kwh_or_co2_or_£ = :kwh)
    val / conversion(equivalence_type, via_kwh_or_co2_or_£)[:rate]
  end

  def front_end_description(equivalence_type = tree,  kwh_or_co2_or_£ = :kwh)
    conversion(equivalence_type, kwh_or_co2_or_£)[:front_end_description]
  end

  private

  def conversion(equivalence_type, kwh_or_co2_or_£)
    @conversion ||= {}
    @conversion[equivalence_type] ||= {}
    @conversion[equivalence_type][kwh_or_co2_or_£] ||= EnergyEquivalences.equivalence_conversion_configuration(equivalence_type, kwh_or_co2_or_£, electricity_grid_carbon_intensity)
  end

  def electricity_grid_carbon_intensity
    @electricity_grid_carbon_intensity ||= GridCarbonIntensity.grid_carbon_intensity_for_year_kg(Date.today.year)
  end
end

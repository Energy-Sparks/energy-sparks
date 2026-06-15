class SchoolGroups::ComparisonReportListComponentPreview < ViewComponent::Preview
  # @param fuel_type select { choices: [all, electricity, gas, solar_pv] }
  # @param slug select :group_options
  def example(slug: nil, fuel_type: :all)
    fuel_types = fuel_type == :all ? [:electricity, :gas, :solar_pv, :storage_heaters] : [fuel_type]
    school_group = slug ? SchoolGroup.find(slug) : SchoolGroup.with_active_schools.sample
    render SchoolGroups::ComparisonReportListComponent.new(school_group:, fuel_types:) do |c|
      c.with_link 'No fuel type', report: :annual_energy_use
      c.with_link 'Electricity report', report: :baseload_per_pupil, fuel_type: :electricity
      c.with_named 'Baseload variation', fuel_type: :electricity, reports: {
        season_baseload_variation: 'Seasonal variation',
        weekday_baseload_variation: 'Weekday variation'
      }
      c.with_fuel_types 'Annual change', reports: {
        electricity: :change_in_electricity_since_last_year,
        gas: :change_in_gas_since_last_year,
        storage_heaters: :change_in_storage_heaters_since_last_year
      }
      c.with_fuel_types 'Annual savings potential', reports: {
        electricity: { report: :annual_electricity_costs_per_pupil, label: 'electricity (per pupil)' },
        gas: { report: :annual_gas_costs_per_floor_area, label: 'gas (per floor area)' }
      }
    end
  end

  private

  def group_options
    {
      choices: SchoolGroup.with_active_schools.by_name.map { |g| [g.name, g.slug] }
    }
  end
end

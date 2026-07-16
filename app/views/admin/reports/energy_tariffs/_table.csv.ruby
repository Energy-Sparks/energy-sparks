CSV.generate do |csv|
  csv << @headers
  @school_groups.each do |school_group|
    if @count_by_active_school_group[school_group.slug].present?
        current_tariffs = school_group.energy_tariffs.current.by_start_date
        electricity_tariff = current_tariffs&.electricity&.last
        gas_tariff = current_tariffs&.gas&.last
    end
    electricity_schools = EnergyTariff.count_schools_with_tariff_by_group(school_group, :electricity)
    gas_schools = EnergyTariff.count_schools_with_tariff_by_group(school_group, :gas)
    csv << [
      school_group.name,
      school_group.default_issues_admin_user.display_name,
      @count_by_active_school_group[school_group.slug],
      electricity_tariff&.display_start_date,
      electricity_tariff&.display_end_date,
      gas_tariff&.display_start_date,
      gas_tariff&.display_end_date,
      electricity_schools,
      gas_schools
    ]
  end
end.html_safe

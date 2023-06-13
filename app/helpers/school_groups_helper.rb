module SchoolGroupsHelper
  #Accepts a list of savings as produced by SchoolGroups::PriorityActions
  #OpenStruct(school:, average_one_year_saving_gbp, :one_year_saving_co2)
  #
  #Sorts them by school name
  def sort_priority_actions(list_of_savings)
    list_of_savings.sort {|a, b| a.school.name <=> b.school.name }
  end

  def radio_button_checked_for(metric)
    return true if params['metric'] == metric
    return true if params['metric'].blank? && metric == 'change'

    false
  end

  def value_for(recent_usage)
    return nil unless recent_usage
    case params['metric']
    when 'usage' then recent_usage.usage
    when 'co2' then recent_usage.co2
    when 'cost' then recent_usage.cost
    when 'change' then recent_usage.change
    else
      recent_usage.change
    end
  end

  def compare_benchmark_key_for(advice_page_key)
    case advice_page_key
    when :baseload then :baseload_per_pupil
    when :electricity_intraday then :electricity_peak_kw_per_pupil
    when :electricity_long_term then :annual_electricity_costs_per_pupil
    when :electricity_out_of_hours then :annual_electricity_out_of_hours_use
    when :gas_long_term then :annual_heating_costs_per_floor_area
    when :gas_out_of_hours then :annual_gas_out_of_hours_use
    when :heating_control then :heating_in_warm_weather #heating_coming_on_too_early
    when :thermostatic_control then :thermostatic_control
    end
  end
end

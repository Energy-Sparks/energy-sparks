module SchoolGroupsHelper
  # Accepts a list of savings as produced by SchoolGroups::PriorityActions
  # OpenStruct(school:, average_one_year_saving_gbp, :one_year_saving_co2)
  #
  # Sorts them by school name
  def sort_priority_actions(list_of_savings)
    list_of_savings.sort {|a, b| a.school.name <=> b.school.name }
  end

  def radio_button_checked_for(selected_metric, metric)
    return true if selected_metric == metric
    return true if selected_metric.blank? && metric == :change
    return true if %i[usage co2 cost change].exclude?(selected_metric) && metric == :change

    false
  end

  def value_for(recent_usage, formatted: true)
    return nil unless recent_usage
    case params['metric']
    when 'usage' then formatted ? recent_usage.usage : recent_usage.usage_text
    when 'co2' then formatted ? recent_usage.co2 : recent_usage.co2_text
    when 'cost' then formatted ? recent_usage.cost : recent_usage.cost_text
    when 'change' then formatted ? recent_usage.change : recent_usage.change_text.gsub(/[^-.0-9]/, '')
    else
      formatted ? recent_usage.change : recent_usage.change_text.gsub(/[^-.0-9]/, '')
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
    when :heating_control then :heating_in_warm_weather # heating_coming_on_too_early
    when :thermostatic_control then :thermostatic_control
    end
  end

  def secr_format_number(number)
    number_with_delimiter(number.round(2))
  end

  # Cache (and use cached) pages if the list of schools for the current user
  # all have public sharing. If not, then their list is bespoke to them so
  # dont cache the content.
  def can_cache_group_advice?(schools)
    return false unless Rails.env.production?
    schools.all?(&:data_sharing_public?)
  end

  def group_advice_cache_key(school_group, additional = nil)
    [school_group, school_group.most_recent_content_generation_run, *additional, I18n.locale]
  end

  def comparison_table_class(list)
    list.length > 10 ? 'table-paged' : 'table-sorted'
  end

  def include_clusters?(school_group)
    school_group.organisation? && can?(:update_settings, school_group)
  end
end

# rubocop:disable Naming/AsciiIdentifiers
module AdvicePageHelper
  def advice_page_path(model, advice_page = nil, tab = :insights, params: {}, anchor: nil)
    if advice_page.present?
      polymorphic_path([tab, model, :advice, advice_page.key.to_sym], params: params, anchor: anchor)
    else
      polymorphic_path([model, :advice])
    end
  end

  def group_advice_page_path(school_group, advice_page_key = nil, tab = :insights, params: {}, anchor: nil)
    if advice_page_key.present?
      polymorphic_path([tab, school_group, :advice, advice_page_key], params: params, anchor: anchor)
    else
      school_group_advice_path(school_group)
    end
  end

  def sort_by_label(advice_pages)
    advice_pages.sort_by { |ap| translated_label(ap) }
  end

  def translated_label(advice_page)
    I18n.t("advice_pages.nav.pages.#{advice_page.key}")
  end

  # Helper for the advice pages, passes a scope to the I18n.t API based on
  # our naming convention and page keys. Will only work on advice pages
  # content, e.g advice_pages.*
  def advice_t(key, **vars)
    I18n.t(key, **vars.merge(scope: [:advice_pages])).html_safe
  end

  def format_unit(value, units, in_table = true, user_numeric_comprehension_level = :ks2, medium = :html)
    # Ensure all tiny numbers are displayed as zero (e.g. -0.000000000000004736951571734001 should be shown as 0 and not -4.7e-15)
    begin
      value = 0.0 if value&.between?(-0.001, 0.001)
    rescue ArgumentError
      # use original value, probably NaN
    end
    FormatEnergyUnit.format(units, value, medium, false, in_table, user_numeric_comprehension_level).html_safe
  end

  def advice_baseload_high?(estimated_savings_vs_benchmark)
    estimated_savings_vs_benchmark > 0.0
  end

  def format_rating(rating)
    rating > 4 ? 'Limited variation' : 'Large variation'
  end

  # link to a specific benchmark for a school group, falls back to the
  # generic benchmark page if a school doesn't have a group
  def compare_for_school_group_path(benchmark_type, school)
    if school.school_group.present?
      compare_path(benchmark: benchmark_type, school_group_ids: [school.school_group.id])
    else
      compare_path(benchmark: benchmark_type)
    end
  end

  # calculate relative % change of a current value from a base value
  def relative_percent(base, current)
    return 0.0 if base.nil? || current.nil? || base == current
    return 0.0 if base == 0.0
    (current - base) / base
  end

  def annual_usage_breakdown_totals_for(annual_usage_breakdown, unit = :kwh)
    annual_usage_breakdown.holiday.send(unit) +
      annual_usage_breakdown.weekend.send(unit) +
      annual_usage_breakdown.school_day_open.send(unit) +
      annual_usage_breakdown.school_day_closed.send(unit) +
      annual_usage_breakdown.community.send(unit)
  end

  def meters_by_estimated_saving(meters)
    meters.sort_by {|_, v| v.estimated_saving_£.present? ? -v.estimated_saving_£ : 0.0 }
  end

  def meters_by_percentage_baseload(meters)
    meters.sort_by {|_, v| -v.percentage_baseload }
  end

  def heating_time_class(heating_start_time, recommended_time)
    return '' if heating_start_time.nil?
    if heating_start_time >= recommended_time
      'text-positive'
    else
      'text-negative'
    end
  end

  def heating_time_assessment(heating_start_time, recommended_time)
    return I18n.t('analytics.modelling.heating.no_heating') if heating_start_time.nil?
    if heating_start_time >= recommended_time
      I18n.t('analytics.modelling.heating.on_time')
    else
      I18n.t('analytics.modelling.heating.too_early')
    end
  end

  def warm_weather_on_days_adjective(rating)
    I18nHelper.adjective(rating)
  end

  def notice_status_for(rating_value)
    rating_value > 6 ? :positive : :negative
  end

  def warm_weather_on_days_status(rating)
    if [:excellent, :good].include?(rating)
      :positive
    else
      :negative
    end
  end

  def advice_pages_for_school_and_fuel(advice_pages, school, fuel_type, current_user)
    advice_pages = advice_pages.where(fuel_type:)
    unless Flipper.enabled?(:target_advice_pages2025, current_user)
      advice_pages = advice_pages.where.not(key: %i[electricity_target gas_target storage_heater_target])
    end
    school.multiple_meters?(fuel_type) ? advice_pages : advice_pages.where(multiple_meters: false)
  end

  def display_advice_page?(school, fuel_type)
    school_has_fuel_type?(school, fuel_type)
  end

  def school_has_fuel_type?(school, fuel_type)
    fuel_type = 'storage_heaters' if fuel_type == 'storage_heater'
    fuel_type = 'electricity' if fuel_type == 'solar_pv'
    school.send("has_#{fuel_type}?".to_sym)
  end

  def can_benchmark?(advice_page:)
    Schools::AdvicePageBenchmarks::SchoolBenchmarkGenerator.can_benchmark?(advice_page: advice_page)
  end

  def tariff_source(tariff_summary)
    return t('advice_pages.tables.labels.default') unless tariff_summary.real
    if tariff_summary.name.include?('DCC SMETS2')
      t('advice_pages.tables.labels.smart_meter')
    else
      t('advice_pages.tables.labels.user_supplied')
    end
  end

  def alert_types_for_group(group)
    AlertType.groups.key?(group) ? AlertType.send(group) : []
  end

  def alert_types_for_class(class_name)
    class_names = Array(class_name).map(&:to_s)
    AlertType.where(class_name: class_names)
  end

  def dashboard_alert_groups(dashboard_alerts)
    # alert type groups have a specific order here
    %w[priority change benchmarking advice].filter_map do |group|
      alerts = dashboard_alerts.select { |dashboard_alert| dashboard_alert.alert.alert_type.group == group }
      [group, alerts] if alerts.any?
    end
  end

  def t_weekday(week_day)
    I18n.t('date.day_names')[week_day]
  end

  def icon_tooltip(text = '')
    tag.span(fa_icon('info-circle'), data: { toggle: 'tooltip', placement: 'top', title: text }, class: 'text-muted') if text.present?
  end

  def formatted_unit_to_num(value)
    value.gsub(/(,|kWh|kg CO2)/, '').to_i
  end

  def format_date_range(date_range)
    date_range.map { |d| d.to_fs(:es_short) }.join(' - ')
  end

  # holiday usage is a Hash of school_period => OpenStruct
  # confirms that at least one period has usage
  def show_holiday_usage_section?(holiday_usage)
    holiday_usage.values.any? { |usage| usage.usage.present? }
  end
end
# rubocop:enable Naming/AsciiIdentifiers

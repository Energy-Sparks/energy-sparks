# Generates a cost table for a meter.
#
# Meter costs can be quite simple: a flat rate charge for usage, then a standing
# charge.
#
# But tariffs might have a range of additional bill components associated with them
# e.g. consumption charges, a range of different standard charges and other fees.
#
# Tariffs might also change from month to month, meaning a table needs to adjust
# based on what charges there are for the reporting period.
#
# This component will produce a table that will automatically adjust to include
# rows for all known bill components, only including a row if there's at least
# one charge for a specific month.
#
# At present it includes a fixed list of bill components to provide a
# stable ordering of components with tables. So charges to our tariff / cost
# calculation code may need changes to this table.
class MeterCostsTableComponent < ViewComponent::Base
  # Monthly costs: a hash of Date (first day of month) => Costs::MeterMonth
  # Change in costs: a hash of Date (first day of month) => change in total cost for month (£)
  # id: HTML id of the table
  # year_header: display year header row in table
  # month_format: change month format for month row
  # precision: change rounding of numbers, see FormatUnit
  def initialize(id: 'meter-costs-table', year_header: true, month_format: '%b', precision: :approx_accountant, monthly_costs:, change_in_costs: nil, school: nil, fuel_type: nil)
    @id = id
    @year_header = year_header
    @month_format = month_format
    @precision = precision
    @monthly_costs = monthly_costs
    @change_in_costs = change_in_costs
    @any_partial_months = false
    @school = school
    @fuel_type = fuel_type
    @t_scope = 'advice_pages.tables.tooltips.bill_components'
  end

  # Iterate over months, yielding either year or nil
  def years_header
    year = nil
    months.map do |month|
      val = month.year != year ? month.year : nil
      year = month.year
      yield val
    end
  end

  # Iterate over each month
  def months_header
    months.map do |month|
      yield I18n.l(month, format: @month_format), partial_month?(month)
    end
  end

  # List of different charge components, with an id and list of components for each group
  # id allows us to later add row level grouping and/or totals
  #
  # Change order of this array, or the individual lists to reorder the table rows
  def all_components
    [
      { id: :consumption_charges, list: consumption_charges },
      { id: :duos_charges, list: duos_charges },
      { id: :tnuos, list: tnuos },
      { id: :asc, list: asc },
      { id: :fixed, list: fixed },
      { id: :agent_charges, list: agent_charges },
      { id: :other, list: other },
      { id: :vat_charges, list: vat_charges }
    ]
  end

  def consumption_charges
    [
      :flat_rate,
      :commodity_rate,
      :non_commodity_rate
    ] + all_day_night_rate_combinations
  end

  def duos_charges
    [:duos_green, :duos_amber, :duos_red]
  end

  def tnuos
    [:tnuos]
  end

  def asc
    [:agreed_availability_charge, :excess_availability_charge, :reactive_power_charge]
  end

  def fixed
    [:fixed_charge, :standing_charge, :site_fee]
  end

  def agent_charges
    [:settlement_agency_fee, :nhh_automatic_meter_reading_charge, :data_collection_dcda_agent_charge, :nhh_metering_agent_charge, :meter_asset_provider_charge]
  end

  def other
    [:feed_in_tariff_levy, :climate_change_levy, :renewable_energy_obligation]
  end

  def vat_charges
    [:vat_5, :vat_20]
  end

  def bill_component?(component:)
    @monthly_costs.values.any? {|costs| costs.present? && costs.bill_component_costs.key?(component) }
  end

  def tooltip(component:)
    if (band = is_duos?(component))
      duos_charge_times(band)
    elsif component[2] == '_'
      component_times = component.to_s.gsub('_to_', ' ').tr('_', ':').split(' ')
      helpers.icon_tooltip(t('day_night', scope: @t_scope, time_from: component_times.first, time_to: component_times.last, default: ''))
    else
      helpers.icon_tooltip(t(component, scope: @t_scope, default: ''))
    end
  end

  def bill_component_row(component:)
    # early return if we don't have any of these components
    return unless bill_component?(component: component)

    total = 0.0
    months.each do |month|
      monthly_cost = @monthly_costs[month]
      if monthly_cost.present?
        cost = monthly_cost.bill_component_costs[component]
        total += cost if cost.present?
        # yield each value
        yield format(cost)
      else
        yield nil
      end
    end
    # yield total value
    yield format(total)
  end

  def totals_row
    months.each do |month|
      monthly_costs = @monthly_costs[month]
      yield monthly_costs.present? ? format(monthly_costs.total) : nil
    end
    yield format(@monthly_costs.values.compact.sum(&:total))
  end

  def change_in_costs_row
    months.each do |month|
      cost = @change_in_costs[month]
      yield cost.present? ? format(cost) : nil
    end
    values = @change_in_costs.values.compact
    yield values.any? ? format(@change_in_costs.values.compact.sum) : ''
  end

  def include_change_in_costs_row?
    @change_in_costs.present? && @change_in_costs.values.compact.any?
  end

  private

  def period_sym(period)
    period.parameterize.underscore.to_sym
  end

  def months
    @months ||= @monthly_costs.reject { |_month, costs| costs.nil? || costs.total == 0.0 }.keys.sort
  end

  def partial_month?(month)
    costs = @monthly_costs[month]
    return nil unless costs.present?
    @any_partial_months |= costs.full_month
    costs.full_month
  end

  def is_duos?(component)
    duos_charges.include?(component) && component.to_s[/duos_(\w+)$/, 1].to_sym
  end

  def duos_charge_times(band)
    return '' unless mpan_mprn
    @duos ||= DUOSCharges.regional_charge_table(mpan_mprn.to_i)[:bands]
    charge_times = @duos[band].inject([]) do |memo, (key, period)|
      period = t(:all_day, scope: @t_scope) if period == 'all day'
      memo << t(key, scope: @t_scope, period: period)
      memo
    end
    helpers.icon_tooltip(t(:duos, scope: @t_scope, charge_times: charge_times.join(' ')))
  end

  def format(value)
    return '-' if value.nil?
    FormatUnit.format_pounds(:£, value, :text, @precision, true)
  end

  def mpan_mprn
    if @school && @fuel_type && @fuel_type.to_sym == :electricity # duos is only for electricity
      return @school.meters.active.where(meter_type: @fuel_type).first.try(:mpan_mprn)
    end
  end

  def all_day_night_rate_combinations
    @all_day_night_rate_combinations ||= day_night_rate_combinations.map { |day_night_rate_combination| period_sym("#{day_night_rate_combination.first} to #{day_night_rate_combination.last}") }
  end

  def day_night_rate_combinations
    @day_night_rate_combinations ||= possible_time_combinations.product(possible_time_combinations)
  end

  def possible_time_combinations
    @possible_time_combinations ||= ('00'..'23').to_a.product(%w[00 30]).collect { |hour, minutes| "#{hour}:#{minutes}" }
  end
end

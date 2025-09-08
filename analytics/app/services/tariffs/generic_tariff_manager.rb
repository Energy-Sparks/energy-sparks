# frozen_string_literal: true

class GenericTariffManager
  include Logging
  MAX_DAYS_BACKDATE_TARIFF = 30

  attr_reader :meter_tariffs, :school_tariffs, :school_group_tariffs, :system_tariffs

  def initialize(meter)
    @meter = meter
    @meter_tariffs = []
    @school_tariffs = []
    @school_group_tariffs = []
    @system_tariffs = []
    @list_of_all_tariffs = [@meter_tariffs, @school_tariffs, @school_group_tariffs, @system_tariffs]
    pre_process_tariff_attributes
    backdate_dcc_tariffs
  end

  # Original method name used by MeterTariffManager
  def accounting_tariff_for_date(date)
    find_tariff_for_date(date)
  end

  # Find tariff for a specific date
  # Caches the calculation of the accounting tariff
  def find_tariff_for_date(date)
    @tariff_cache       ||= {}
    @tariff_cache[date] ||= search_tariffs_by_date(date)
  end

  def economic_cost(date, kwh_x48)
    find_tariff_for_date(date)&.economic_costs(date, kwh_x48)
  end

  def accounting_cost(date, kwh_x48)
    find_tariff_for_date(date)&.costs(date, kwh_x48)
  end

  # Determine whether there are any differential tariffs within the specified date range
  def any_differential_tariff?(start_date, end_date)
    # slow, TODO(PH, 30Mar2021) speed up by scanning tariff date ranges
    # LD 2023-08-08, switch to detect to avoid scanning entire date range
    (start_date..end_date).detect { |date| differential_tariff_on_date?(date) } != nil
  end

  # Does this meter have time-varying economic tariffs?
  #
  # This is currently used by the aggregation code. If this is false then we
  # assume that its fine to set the "current economic cost" to the "economic cost"
  # schedule, as there isn't any difference over time.
  #
  # Equivalent here is to check if we have multiple tariffs at any level, starting
  # from top-down. If we do, then they will differ by date. If there's a single one
  # at any level, we assume it covers all time.
  #
  # This is close enough for the moment, pending further optimisation.
  def economic_tariffs_change_over_time?
    @list_of_all_tariffs.reverse_each do |list|
      return true if list.size > 1
    end
    false
  end

  # Returns the date of the last change in tariff within the
  # specified date range.
  #
  # If tariff has not changed within period, then returns nil.
  #
  # Will also return nil if no tariffs found at all within period.
  #
  # Otherwise returns the start date of the most recent tariff
  def last_tariff_change_date(start_date = @meter.amr_data.start_date, end_date = @meter.amr_data.end_date)
    prev_tariff = nil
    found_tariff = nil
    end_date.downto(start_date).each do |date|
      found_tariff = find_tariff_for_date(date)
      prev_tariff = found_tariff if prev_tariff.nil?
      break if found_tariff != prev_tariff
    end
    # no tariffs found at all
    return nil if prev_tariff.nil? && found_tariff.nil?
    # tariff unchanged in period
    return nil if prev_tariff == found_tariff

    # tariff changed, so return start unless its the minimum date
    prev_tariff.start_date == GenericAccountingTariff::MIN_DEFAULT_START_DATE ? nil : prev_tariff.start_date
  end

  # Find all the dates when the tariff changes within the period
  #
  # AlertEconomicTariffCalculations
  # Costs::EconomicTariffsChangeCaveatsService
  def tariff_change_dates_in_period(start_date = @meter.amr_data.start_date, end_date = @meter.amr_data.end_date)
    list_of_tariffs = find_tariffs_between_dates(start_date, end_date)
    list_of_tariffs = list_of_tariffs.reject { |t| t.end_date == GenericAccountingTariff::MAX_DEFAULT_END_DATE }
    list_of_tariffs.map { |t| t.end_date + 1 }.reverse
  end

  # Costs::EconomicTariffsChangeCaveatsService
  # AlertBaseloadBase, change text
  # ContentBase, generic text
  # Old co2 advice, old dashboard analysis advice
  def meter_tariffs_differ_within_date_range?(start_date, end_date)
    # use detect to avoid iterating over full list
    constituent_meters.detect do |meter|
      meter.meter_tariffs.tariffs_differ_within_date_range?(start_date, end_date)
    end != nil
  end

  def tariffs_differ_within_date_range?(start_date, end_date)
    last_tariff_change_date(start_date, end_date) != nil
  end

  # Used: ContentBase, generic text
  def meter_tariffs_changes_between_periods?(period1, period2)
    # use detect to avoid iterating over full list
    constituent_meters.detect do |meter|
      meter.meter_tariffs.tariffs_change_between_periods?(period1, period2)
    end != nil
  end

  def tariffs_change_between_periods?(period1, period2)
    period1_tariffs = find_all_tariffs_between_dates(period1.first, period1.last)
    period2_tariffs = find_all_tariffs_between_dates(period2.first, period2.last)
    period1_tariffs != period2_tariffs
  end

  private

  # Searches the tariffs to find the right one for the given date
  def search_tariffs_by_date(date)
    found_tariffs = nil
    @list_of_all_tariffs.each do |list|
      found_tariffs = search_list_of_tariffs(list, date)
      break if found_tariffs.any?
    end
    return nil unless found_tariffs.any?

    most_recent(found_tariffs)
  end

  def search_list_of_tariffs(list, date)
    list.select { |accounting_tariff| accounting_tariff.in_date_range?(date) }
  end

  # find most recently created tariff, force nil timestamps to sort last
  def most_recent(found_tariffs)
    found_tariffs.max_by do |t|
      t.tariff[:created_at].nil? ? GenericAccountingTariff::MIN_DEFAULT_START_DATE : t.tariff[:created_at]
    end
  end

  # All tariffs used within a specific date range, in reverse order
  def find_tariffs_between_dates(start_date, end_date)
    prev_tariff = nil
    found_tariff = nil
    list_of_tariffs = []
    end_date.downto(start_date).each do |date|
      found_tariff = find_tariff_for_date(date)
      prev_tariff = found_tariff if prev_tariff.nil?
      list_of_tariffs << found_tariff if !found_tariff.nil? && found_tariff != prev_tariff
      prev_tariff = found_tariff
    end
    list_of_tariffs
  end

  # All tariffs used within date, regardlss of whether they have been
  # applied 1 or more times.
  def find_all_tariffs_between_dates(start_date, end_date)
    list_of_tariffs = []
    end_date.downto(start_date).each do |date|
      found_tariff = find_tariff_for_date(date)
      list_of_tariffs << found_tariff unless found_tariff.nil?
    end
    list_of_tariffs.uniq
  end

  def tariff_attributes
    @meter.attributes(:accounting_tariff_generic)
  end

  def pre_process_tariff_attributes
    return if tariff_attributes.nil?

    # sort the attributes into separate bins based on tariff_holder
    # within each bin, sort by created_at, newest first
    tariff_attributes.each do |attribute|
      tariff = GenericAccountingTariff.new(@meter, attribute)
      case attribute[:tariff_holder]
      when :meter
        @meter_tariffs << tariff
      when :school
        @school_tariffs << tariff
      when :school_group
        @school_group_tariffs << tariff
      when :site_settings
        @system_tariffs << tariff
      else
        raise "Unknown tariff holder type: #{attribute[:tariff_holder]}"
      end
    end
  end

  # tariffs for new SMETS2 meters are often setup several days after
  # kWh data has started recording, the earlier kWh readings therefore
  # have no DCC tariff and default to default accounting tariffs
  # in this circumstance, unless overridden backdate the existing DCC tariff
  # to the start of the meter readings, so the default is no longer used
  #
  # NOTE: as n3rgy no longer hold archived tariffs, then we'll only ever have
  # the tariffs from the point that we begin loading data. So this may be more
  # common than it was before
  #
  # TODO: this could be done in the application. When the DCC tariffs or readings are loaded for a
  # meter, the start date of the tariff could be adjusted once. Or the adjustment could
  # happen when the data is loaded and past to the analytics.
  def backdate_dcc_tariffs
    return if @meter_tariffs.empty? || dcc_tariffs.empty? || @meter.amr_data.nil?

    # sorted by date, so this is the earliest
    first_dcc_tariff = dcc_tariffs[0]
    override_days = backdate_tariff_override

    if override_days.nil?
      days_gap = first_dcc_tariff.tariff[:start_date] - amr_start_date
      first_dcc_tariff.backdate_tariff(amr_start_date) if days_gap.between?(1, MAX_DAYS_BACKDATE_TARIFF)
    else
      first_dcc_tariff.backdate_tariff(first_dcc_tariff.tariff[:start_date] - override_days)
    end
  end

  def amr_start_date
    @meter.amr_data.start_date
  end

  def backdate_tariff_override
    @meter.meter_attributes[:backdate_tariff].first[:days] if @meter.meter_attributes.key?(:backdate_tariff)
  end

  def dcc_tariffs
    @dcc_tariffs ||= @meter_tariffs.select(&:dcc?).sort { |a, b| a.tariff[:start_date] <=> b.tariff[:start_date] }
  end

  def constituent_meters
    # defensive just in case aggregation service doesn't set for single fuel type meter school
    if @meter.constituent_meters.nil? || @meter.constituent_meters.empty?
      [@meter]
    else
      @meter.constituent_meters
    end
  end

  # Determine whether there's a differential tariff for a specific date
  def differential_tariff_on_date?(date)
    tariff = find_tariff_for_date(date)
    !tariff.nil? && tariff.differential?
  end
end

class AlertGasHeatingHotWaterOnDuringHoliday < Alerts::UsageDuringCurrentHolidayBase
  def initialize(school)
    super(school, :gas)
  end

  def aggregate_meter
    @school.aggregated_heat_meters
  end

  def heating_type
    I18n.t('analytics.common.gas_boiler')
  end

  def fuel_type
    :gas
  end

  def i18n_prefix
    'analytics.alert_heating_hot_water_on_during_holiday_base'
  end

  def summary
    if @rating == 0.0
      I18n.t("#{i18n_prefix}.summary",
             heating_type: heating_type,
             holiday_name: holiday_name,
             date: I18n.l(@asof_date, format: '%A %e %b %Y'),
             cost: FormatUnit.format(:£, @holiday_usage_to_date_£, :html),
             project_cost: FormatUnit.format(:£, @holiday_projected_usage_£, :html))
    else
      I18n.t("#{i18n_prefix}.heating_not_on")
    end
  end

  protected

  def needs_electricity_data?
    false
  end

  def needs_gas_data?
    true
  end
end

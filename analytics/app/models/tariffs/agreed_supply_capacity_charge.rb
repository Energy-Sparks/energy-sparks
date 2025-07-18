require_rel './max_monthly_demand_charges_base.rb'
class AgreedSupplyCapacityCharge < MaxMonthlyDemandChargesBase
  def agreed_supply_capacity_daily_cost(date)
    @tariff[:rates][:agreed_availability_charge][:rate] *
    @tariff[:asc_limit_kw] / DateTimeHelper.days_in_month(date)
  end

  def excess_supply_capacity_daily_cost(date)
    kw = max_demand_for_month_kw(date, @amr_data)
    if kw > @tariff[:asc_limit_kw]
      excess = kw - @tariff[:asc_limit_kw]
      excess * @tariff[:rates][:excess_availability_charge][:rate] / DateTimeHelper.days_in_month(date)
    else
      nil
    end
  end
end

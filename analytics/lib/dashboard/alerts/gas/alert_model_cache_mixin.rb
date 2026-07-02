module AlertModelCacheMixin
  private def model_cache(asof_date)
    aggregate_meter.model_cache.create_and_fit_model(:best, one_year_period(asof_date))
  end

  protected def asof_date_minus_one_year(date)
    date - 364
  end

  protected def model_start_date(asof_date)
    [asof_date_minus_one_year(asof_date), aggregate_meter.amr_data.start_date].max
  end

  protected def one_year_period(asof_date)
    SchoolDatePeriod.new(:analysis, 'Current Year', model_start_date(asof_date), asof_date)
  end

  protected def enough_data_for_model_fit
    @heating_model = calculate_model(asof_date) if @heating_model.nil?
    @heating_model.enough_samples_for_good_fit
  end
end

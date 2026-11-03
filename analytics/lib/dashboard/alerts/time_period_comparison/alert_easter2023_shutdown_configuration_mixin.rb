module AlertEaster2023ShutdownConfigurationMixin
  def basic_configuration
    {
      name:                   'Easter shutdown 2023',
      max_days_out_of_date:   30,
      enough_days_data:       1,
      holiday_date:           Date.new(2023,4,7), #good friday
      school_weeks:           0
    }
  end
end

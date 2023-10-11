class TempusDominusDateTimeInput < TempusDominusDateInput
  def input_group_class
    'tempus-dominus-date-time'.freeze
  end

  def input_value_key
    :default_date_time
  end

  def input_value_format
    '%d/%m/%Y %H:%M'.freeze
  end
end

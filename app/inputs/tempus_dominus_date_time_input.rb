# frozen_string_literal: true

class TempusDominusDateTimeInput < TempusDominusDateInput
  def input_group_class
    'tempus-dominus-date-time'
  end

  def input_value_key
    :default_date_time
  end

  def input_value_format
    '%d/%m/%Y %H:%M'
  end
end

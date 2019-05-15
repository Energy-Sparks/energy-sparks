class TempusDominusDateTimeInput < TempusDominusDateInput
  def input(_wrapper_options)
    template.content_tag(:div, class: 'input-group date tempus-dominus-date-time', data: { target_input: 'nearest' }, id: "#{object_name}_#{attribute_name}") do
      template.concat @builder.text_field(attribute_name, input_html_options)
      template.concat div_button
    end
  end

  def input_group_class
    "tempus-dominus-date-time".freeze
  end

  def input_value_key
    :default_date_time
  end

  def input_value_format
    "%d/%m/%Y %H:%M".freeze
  end

  def input_value
    value = @builder.object.send(attribute_name).try(:strftime, input_value_format)
    if value.nil? && options.key?(input_value_key)
      value = options[input_value_key].strftime(input_value_format)
    end
    value
  end
end

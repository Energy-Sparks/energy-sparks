class TempusDominusDateInput < SimpleForm::Inputs::Base
  def input(_wrapper_options)
    template.content_tag(:div, class: "input-group date #{input_group_class}", data: { target_input: 'nearest' }, id: "#{object_name}_#{attribute_name}") do
      template.concat @builder.text_field(attribute_name, input_html_options)
      template.concat div_button
    end
  end

  def input_group_class
    "tempus-dominus-date".freeze
  end

  def input_html_options
    super.merge(class: 'form-control datetimepicker-input', value: input_value, data: { target: "##{object_name}_#{attribute_name}" })
  end

  def input_value_key
    :default_date
  end

  def input_value_format
    "%d/%m/%Y".freeze
  end

  def input_value
    value = @builder.object.send(attribute_name).try(:strftime, input_value_format)
    if value.nil? && options.key?(input_value_key)
      value = options[input_value_key].strftime(input_value_format)
    end
    value
  end

  def div_button
    template.content_tag(:div, class: 'input-group-append', data: { target: "##{object_name}_#{attribute_name}", toggle: 'datetimepicker' }) do
      template.concat span_table
    end
  end

  def span_table
    template.content_tag(:div, class: 'input-group-text') do
      template.concat icon_table
    end
  end

  def icon_remove
    "<i class='glyphicon glyphicon-remove'></i>".html_safe
  end

  def icon_table
    "<i class='fa fa-calendar'></i>".html_safe
  end
end

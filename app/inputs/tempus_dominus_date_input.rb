class TempusDominusDateInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    template.content_tag(:div, class: "input-group date #{input_group_class}", data: { target_input: 'nearest' }, id: wrapper_id) do
      template.concat @builder.text_field(attribute_name, merged_input_options)
      template.concat div_button
    end
  end

  def input_group_class
    "tempus-dominus-date".freeze
  end

  def input_html_options
    super.deep_merge(class: 'form-control datetimepicker-input', value: input_value, data: { target: "##{wrapper_id}" })
  end

  def input_value_key
    :default_date
  end

  def input_value_format
    "%d/%m/%Y".freeze
  end

  def input_value
    object = @builder.object
    value = object && object.send(attribute_name).try(:strftime, input_value_format)
    if value.nil? && options.key?(input_value_key)
      value = options[input_value_key].try(:strftime, input_value_format)
    end
    value
  end

  def div_button
    template.content_tag(:div, class: 'input-group-append', data: { target: "##{wrapper_id}", toggle: 'datetimepicker' }) do
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

  def wrapper_id
    "#{object_name.to_s.gsub(/[^_a-z]/, '_')}_#{attribute_name.to_s.gsub(/[^_a-z]/, '_')}_dominus"
  end
end

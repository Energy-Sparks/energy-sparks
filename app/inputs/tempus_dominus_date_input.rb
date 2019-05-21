class TempusDominusDateInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    template.content_tag(:div, class: 'input-group date tempus-dominus-date', data: { target_input: 'nearest' }, id: wrapper_id) do
      template.concat @builder.text_field(attribute_name, merged_input_options)
      template.concat div_button
    end
  end

  def input_html_options
    super.merge(class: 'form-control datetimepicker-input', value: input_value, data: { target: "##{wrapper_id}" })
  end

  def input_value
    value = @builder.object.send(attribute_name).try(:strftime, "%d/%m/%Y")
    if value.nil? && options.key?(:default_date)
      value = options[:default_date].try(:strftime, "%d/%m/%Y")
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
    "#{object_name.gsub(/[^_a-z]/, '_')}_#{attribute_name}_dominus"
  end
end

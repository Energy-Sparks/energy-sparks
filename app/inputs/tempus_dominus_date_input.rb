class TempusDominusDateInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    template.content_tag(:div, class: "input-group date #{input_group_class}", data: { target_input: 'nearest' }, id: wrapper_id) do
      template.concat @builder.text_field(attribute_name, merged_input_options)
      template.concat div_button
    end
  end

  def input_group_class
    'tempus-dominus-date'.freeze
  end

  def input_html_options
    super.deep_merge(class: 'form-control datetimepicker-input', value: input_value, data: { target: "##{wrapper_id}" })
  end

  def input_value_key
    :default_date
  end

  def input_value_format
    '%d/%m/%Y'.freeze
  end

  def input_value
    # Attempt to get value from the object associated with the form
    object = @builder.object
    if object.respond_to?(attribute_name)
      raw = object.send(attribute_name)
      return raw.strftime(input_value_format) if raw.respond_to?(:strftime)
      return raw if raw.is_a?(String)
    end

    # Try the default date if its available
    if options.key?(input_value_key)
      raw = options[input_value_key]
      return raw.strftime(input_value_format) if raw.respond_to?(:strftime)
      return raw if raw.is_a?(String)
    end

    nil
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
    # Extract nested index if present (e.g. 345 from [345])
    index = object_name.to_s[/\[(\d+)\]/, 1]

    if index
      # Preserve index when there are nested attributes so IDs stay unique
      safe_object = object_name.to_s.gsub(/[^a-z0-9_]/i, '_')
      safe_attr   = attribute_name.to_s.gsub(/[^_a-z]/, '_')
      "#{safe_object}_#{index}_#{safe_attr}_dominus"
    else
      "#{object_name.to_s.gsub(/[^_a-z]/, '_')}_#{attribute_name.to_s.gsub(/[^_a-z]/, '_')}_dominus"
    end
  end
end

class TempusDominusDateTimeInput < TempusDominusDateInput
  def input(_wrapper_options)
    template.content_tag(:div, class: 'input-group date tempus-dominus-date-time', data: { target_input: 'nearest' }, id: "#{object_name}_#{attribute_name}") do
      template.concat @builder.text_field(attribute_name, input_html_options)
      template.concat div_button
    end
  end

  def input_value
    @builder.object.send(attribute_name) || Time.zone.now
  end
end

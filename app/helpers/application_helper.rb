module ApplicationHelper
  def nice_date_times(datetime)
    return "" if datetime.nil?
    "#{datetime.strftime('%a')} #{datetime.day.ordinalize} #{datetime.strftime('%b %Y %H:%M')} "
  end

  def nice_times_only(datetime)
    return "" if datetime.nil?
    datetime.strftime('%H:%M')
  end

  def nice_dates(date)
    return "" if date.nil?
    "#{date.strftime('%a')} #{date.day.ordinalize} #{date.strftime('%b %Y')} "
  end

  def active(bool = true)
    bool ? '' : 'bg-warning'
  end

  def options_from_collection_for_select_with_data(collection, value_method, text_method, selected = nil, data = {})
    options = collection.map do |element|
      [element.send(text_method), element.send(value_method), data.map do |k, v|
        { "data-#{k}" => element.send(v) }
      end
      ].flatten
    end
    selected, disabled = extract_selected_and_disabled(selected)
    select_deselect = {}
    select_deselect[:selected] = extract_values_from_collection(collection, value_method, selected)
    select_deselect[:disabled] = extract_values_from_collection(collection, value_method, disabled)

    options_for_select(options, select_deselect)
  end

  def class_for_last_date(last_date)
    if last_date.nil?
      "table-light"
    elsif last_date < Time.zone.now - 30.days
      "table-danger"
    elsif last_date < Time.zone.now - 5.days
      "table-warning"
    else
      "table-success"
    end
  end

  def class_for_alert_colour(colour)
    return class_for_alert_colour(:unknown) if colour.nil?
    case colour.to_sym
    when :negative then 'bg-negative'
    when :neutral then 'bg-neutral'
    when :positive then 'bg-positive'
    else 'bg-secondary'
    end
  end

  def temperature_cell_colour(temperature)
    if temperature >= 19
      'bg-negative'
    elsif temperature < 18
      'bg-neutral'
    else
      'bg-positive'
    end
  end

  def class_for_alert_rating(rating)
    return class_for_alert_colour(:unknown) if rating.nil?
    if rating > 9
      class_for_alert_colour(:green)
    elsif rating > 6
      class_for_alert_colour(:yellow)
    else
      class_for_alert_colour(:red)
    end
  end

  def class_for_boolean(boolean)
    boolean ? 'bg-success' : 'bg-danger'
  end

  def icon(style, name)
    content_class = "#{style} fa-#{name}"
    content_tag(:i, nil, class: content_class)
  end

  def fa_icon(icon_type)
    icon('fas', icon_type)
  end

  def fab_icon(icon_type)
    icon('fab', icon_type)
  end

  def fal_icon(icon_type)
    icon('fal', icon_type)
  end

  def far_icon(icon_type)
    icon('far', icon_type)
  end

  def alert_icon(alert, size = nil)
    alert.alert_type.fuel_type.nil? ? "calendar-alt #{size}" : "#{fuel_type_icon(alert.alert_type.fuel_type)} #{size}"
  end

  def fuel_type_icon(fuel_type)
    case fuel_type.to_sym
    when :electricity
      'bolt'
    when :gas
      'fire'
    when :solar_pv
      'sun'
    when :exported_solar_pv
      'arrow-right'
    end
  end

  def label_is_energy_plus?(label)
    label.is_a?(String) && label.start_with?('Energy') && label.length > 6
  end

  def tidy_label(current_label)
    if label_is_energy_plus?(current_label)
      current_label = sort_out_dates_when_tidying_labels(current_label)
    end
    current_label
  end

  def tidy_and_keep_label(current_label)
    label_bit = current_label.scan(/\d+|[A-Za-z]+/).shift
    label_bit + ' ' + sort_out_dates_when_tidying_labels(current_label)
  end

  def sort_out_dates_when_tidying_labels(current_label)
    date_to_and_from = current_label.scan(/\d+|[A-Za-z]+/).drop(1).each_slice(4).to_a

    if date_to_and_from.size > 1 && date_to_and_from[0][3] != date_to_and_from[1][3]
      date_to_and_from[0].delete_at(0)
      date_to_and_from[1].delete_at(0)
    end
    date_to_and_from.map { |bit| bit.join(' ') }.join(' - ')
  end

  def format_school_time(school_time)
    return school_time if school_time.blank?
    sprintf('%04d', school_time).insert(2, ':')
  end

  def table_headers_from_array(array)
    header = array[0]
    header.map do |column|
      html_class = column == header.first ? '' : 'text-center'
      [column, html_class]
    end
  end

  def table_body_from_array(array)
    array[1, array.length - 1]
  end

  def table_row_from_array(row)
    row.map do |column|
      html_class = column == row.first ? '' : 'text-right'
      [column, html_class]
    end
  end

  def y_n(boolean)
    boolean ? 'Yes' : 'No'
  end
end

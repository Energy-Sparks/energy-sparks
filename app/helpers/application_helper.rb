require 'pagy/extras/bootstrap'

module ApplicationHelper
  include Pagy::Frontend

  def nice_date_times(datetime)
    return "" if datetime.nil?
    "#{datetime.strftime('%a')} #{datetime.day.ordinalize} #{datetime.strftime('%b %Y %H:%M')} "
  end

  def nice_times_only(datetime)
    return "" if datetime.nil?
    datetime.strftime('%H:%M')
  end

  def nice_dates(date)
    date ? date.to_s(:es_full) : ""
  end

  def short_dates(date)
    date ? date.to_s(:es_short) : ""
  end

  def nice_dates_from_timestamp(timestamp)
    return "" if timestamp.nil?
    datetime = DateTime.strptime(timestamp.to_s, '%s')
    nice_dates(datetime)
  end

  def date_range_from_reading_gaps(readings_chunks)
    readings_chunks.map do |chunk|
      "#{chunk.size} days (#{short_dates(chunk.first.reading_date)} to #{short_dates(chunk.last.reading_date)})"
    end.join('<br/>').html_safe
  end

  def active(bool = true)
    bool ? '' : 'bg-warning'
  end

  def display_last_signed_in_as(user)
    user.last_sign_in_at ? nice_date_times(user.last_sign_in_at) : 'Never signed in'
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

  def missing_dates(dates)
    if dates.count > 0
      dates.count
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

  def target_percent_cell_colour(percent)
    if percent
      if percent > 0.0
        'bg-negative-light'
      else
        'bg-positive-light'
      end
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

  def stars(rating)
    out_of_five = [(rating.round / 2.0), 0.5].max # enforce at least a half star
    full_stars = out_of_five.to_i
    half_stars = out_of_five.round != out_of_five ? 1 : 0
    empty_stars = 5 - full_stars - half_stars

    (Array.new(full_stars) { fa_icon('star') } +
     Array.new(half_stars) { fa_icon('star-half-alt') } +
     Array.new(empty_stars) { far_icon('star') }).compact.inject(&:+)
  end

  def up_downify(text)
    return if text.nil?
    icon = if text.match?(/^\+/)
             fa_icon('arrow-circle-up')
           elsif text.match?(/increased/)
             fa_icon('arrow-circle-up')
           elsif text.match?(/^\-/)
             fa_icon('arrow-circle-down')
           elsif text.match?(/decreased/)
             fa_icon('arrow-circle-down')
           else
             ''
           end
    (sanitize(text) + ' ' + icon).html_safe
  end

  def safely
    yield
  rescue => e
    e.message
  end

  def print_meter_attribute(meter_attribute)
    sanitize(ap(MeterAttribute.to_analytics([meter_attribute]), index: false, plain: true))
  rescue => e
    e.message
  end

  def print_meter_attributes(school, index = false, plain = true)
    sanitize ap(school.meter_attributes_to_analytics, index: index, plain: plain)
  rescue => e
    e.message
  end

  def warnings_from_warning_types(warning_types)
    warning_types.map { |w| AmrReadingData::WARNINGS[AmrReadingWarning::WARNINGS[w]] }.join(', ')
  end

  def other_field_name(category_title)
    words = category_title.upcase.split
    if words.size > 1
      'OTHER_' + words.map(&:first).join
    else
      'OTHER_' + words.first
    end
  end

  def tariff_anchor(meter)
    "#{meter.mpan_mprn}-tariff"
  end

  def can_ignore_children?(field)
    !field.required? && field.structure.any? { |_k, v| v.required? }
  end

  def format_target(value, units)
    FormatEnergyUnit.format(units, value, :html, false, true, :target)
  end
end

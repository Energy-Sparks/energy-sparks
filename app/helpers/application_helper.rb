module ApplicationHelper
  def nice_date_times(datetime)
    return "" if datetime.nil?
    "#{datetime.strftime('%a')} #{datetime.day.ordinalize} #{datetime.strftime('%b %Y %H:%M')} "
  end

  def nice_dates(date)
    return "" if date.nil?
    "#{date.strftime('%a')} #{date.day.ordinalize} #{date.strftime('%b %Y')} "
  end

  def active(bool = true)
    bool ? '' : 'bg-warning'
  end

  def html_from_markdown(folder, file)
    folder_dir = Rails.root.join('markdown_pages').join(folder.to_s)
    if File.exist? folder_dir
      file_name = file.nil? ? 'default.md' : file + '.md'
      full_path = folder_dir.join file_name
      return "Sorry, we couldn't find that page. [File not found]" unless File.exist? full_path
      render_markdown File.read(full_path)
    else
      "Sorry, we couldn't find that page. [Folder not found]"
    end
  end

  def render_markdown(content)
    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer, autolink: true)
    markdown.render(content).html_safe
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

  def class_for_alert_rating(rating)
    return 'bg-secondary' if rating.nil?
    if rating > 9
      'bg-success'
    elsif rating > 6
      'bg-warning'
    else
      'bg-danger'
    end
  end

  def class_for_alert_subscription(status)
    case status
    when 'sent'
      'bg-success'
    when 'pending'
      'bg-warning'
    else
      'bg-danger'
    end
  end

  def fa_icon(icon_type)
    icon('fas', icon_type)
  end

  def fab_icon(icon_type)
    icon('fab', icon_type)
  end

  def alert_icon(alert)
    fuel_type_icon(alert.alert_type.fuel_type) || 'calendar-check-o'
  end

  def fuel_type_icon(fuel_type)
    case fuel_type
    when :electricity, 'electricity'
      'bolt'
    when :gas, 'gas'
      'fire'
    end
  end

  def nav_link(link_text, link_path)
    content_tag(:li) do
      if current_page?(link_path)
        link_to link_text, link_path, class: 'nav-link active'
      else
        link_to link_text, link_path, class: 'nav-link'
      end
    end
  end

  def label_is_energy_plus?(label)
    label.is_a?(String) && label.start_with?('Energy') && label.length > 6
  end

  def label_is_temperature_plus?(label)
    label.start_with?('Temperature') && label.length > 11
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
end

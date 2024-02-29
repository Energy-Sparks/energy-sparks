module ApplicationHelper
  include Pagy::Frontend

  def nice_date_times(datetime, options = {})
    return '' if datetime.nil?

    datetime = datetime.in_time_zone(Rails.application.config.display_timezone) if options[:localtime] && Rails.application.config.display_timezone
    "#{nice_dates(datetime)} #{nice_times_only(datetime)}"
  end

  def nice_times_only(datetime)
    return '' if datetime.nil?
    datetime.strftime('%H:%M')
  end

  def nice_dates(date)
    date ? date.to_s(:es_full) : ''
  end

  def short_dates(date)
    date ? date.to_s(:es_short) : ''
  end

  def nice_date_times_today(datetime)
    datetime.today? ? nice_times_only(datetime) : short_dates(datetime)
  end

  def human_counts(collection)
    case collection.count
    when 0
      t('application_helper.human_counts.no_times')
    when 1
      t('application_helper.human_counts.once')
    when 2
      t('application_helper.human_counts.twice')
    else
      t('application_helper.human_counts.several_times')
    end
  end

  def nice_dates_from_timestamp(timestamp)
    return '' if timestamp.nil?
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
    user.last_sign_in_at ? user.last_sign_in_at.strftime('%d/%m/%Y %H:%M') : '-'
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
      'table-light'
    elsif last_date < Time.zone.now - 30.days
      'table-danger'
    elsif last_date < Time.zone.now - 5.days
      'table-warning'
    else
      'table-success'
    end
  end

  def missing_dates(dates)
    if dates.count > 0
      dates.count
    end
  end

  def status_for_alert_colour(colour)
    return :neutral if colour.nil?
    colour
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
        'bg-negative-dark'
      else
        'bg-positive-dark'
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

  def spinner_icon
    content_class = 'fa fa-spinner fa-spin'
    content_tag(:i, nil, class: content_class)
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

  def alert_type_icon(alert_type, size = nil)
    alert_type.fuel_type.nil? ? "calendar-alt #{size}" : "#{fuel_type_icon(alert_type.fuel_type)} #{size}"
  end

  def alert_icon(alert, size = nil)
    alert_type_icon(alert.alert_type, size)
  end

  def fuel_type_icon(fuel_type)
    case fuel_type.to_sym
    when :electricity
      'bolt'
    when :gas
      'fire'
    when :solar_pv
      'sun'
    when :storage_heater, :storage_heaters
      'fire-alt'
    when :exported_solar_pv
      'arrow-right'
    end
  end

  def fuel_type_image(fuel_type)
    image_tag "email/#{fuel_type_icon(fuel_type)}.png", width: '20px', height: '20px'
  end

  def fuel_type_background_class(fuel_type)
    case fuel_type.to_sym
    when :electricity
      'bg-electric-light'
    when :gas
      'bg-gas-light'
    when :solar_pv
      'bg-solar-light'
    when :storage_heater, :storage_heaters
      'bg-storage-light'
    when :exported_solar_pv
      'bg-solar-light'
    end
  end

  def fuel_type_class(fuel_type)
    case fuel_type.to_sym
    when :electricity
      'text-electricity'
    when :gas
      'text-gas'
    when :solar_pv
      'text-solar'
    when :storage_heater, :storage_heaters
      'text-storage'
    when :exported_solar_pv
      'text-solar'
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
    boolean ? I18n.t('common.labels.yes_label') : I18n.t('common.labels.no_label')
  end

  def checkmark(boolean, on_class: 'text-success', off_class: 'text-danger')
    fa_icon(boolean ? "check-circle #{on_class}" : "times-circle #{off_class}")
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
    return if text.nil? || text == '-'
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
    FormatEnergyUnit.format(units, value, :html, false, true, :target).html_safe
  end

  def progress_as_percent(completed, total)
    return unless (completed.is_a? Numeric) && (total.is_a? Numeric)
    return unless total > 0
    percent = [100, (100 * completed.to_f / total.to_f)].min
    percent.round.to_s + ' %'
  end

  def weekly_alert_utm_parameters
    email_utm_parameters(source: 'weekly-alert', campaign: 'alerts')
  end

  def targets_utm_parameters(source: 'weekly-alert')
    email_utm_parameters(source: source, campaign: 'targets')
  end

  def email_utm_parameters(source:, campaign:)
    {
      utm_source: source,
      utm_medium: 'email',
      utm_campaign: campaign
    }
  end

  def add_or_remove(list, item)
    arr = list ? list.split(',').map(&:strip) : []
    arr.include?(item) ? arr.delete(item) : arr.append(item)
    arr.join(',')
  end

  def activity_types_search_link(params, key_stage, subject)
    query = params[:query]
    key_stages = params[:key_stages]
    subjects = params[:subjects]
    search_activity_types_path(query: query, key_stages: add_or_remove(key_stages, key_stage), subjects: add_or_remove(subjects, subject))
  end

  def activity_types_badge_class(list, item, color = 'info')
    list && list.include?(item) ? "badge badge-#{color}" : 'badge badge-light outline'
  end

  def file_type_icon(type)
    icon = if type.match?(/spreadsheet/)
             fa_icon('file-excel')
           elsif type.match?(/word/)
             fa_icon('file-word')
           else
             fa_icon('file-download')
           end
    icon.html_safe
  end

  def calendar_event_status(calendar_event)
    calendar_event.based_on ? 'inherited' : ''
  end

  def current_locale?(locale)
    locale.to_s == I18n.locale.to_s
  end

  def path_with_locale(preview_url, locale)
    if preview_url.include?('?')
      preview_url += '&'
    else
      preview_url += '?'
    end
    preview_url + "locale=#{locale}"
  end

  def i18n_key_from(str)
    str.gsub('+', ' And ').delete(' ').underscore
  end

  def redirect_back_url(params)
    params[:redirect_back].blank? ? request.referer : params[:redirect_back]
  end

  def redirect_back_tag(params)
    tag.input type: 'hidden', name: :redirect_back, value: redirect_back_url(params)
  end

  def redirect_back_params(params)
    { redirect_back: redirect_back_url(params) }
  end

  def dashboard_message_icon(messageable)
    if messageable.dashboard_message
      title = 'Dashboard message is shown for '
      title += messageable.is_a?(SchoolGroup) ? 'schools in this group' : 'school'
      tag.span class: 'badge badge-info', title: "#{title}: #{messageable.dashboard_message.message}" do
        fa_icon(:info)
      end
    end
  end

  def toggler
    (fa_icon('chevron-down') + fa_icon('chevron-right')).html_safe
  end

  def text_with_icon(text, icon)
    (icon ? "#{fa_icon(icon)} #{text}" : text).html_safe
  end

  def component(name, *args, **kwargs, &block)
    component = name.to_s.sub(%r{(/|$)}, '_component\1').camelize.constantize
    render(component.new(*args, **kwargs), &block)
  end

  def school_name_group(school)
    if school.school_group
      "#{school.name} (#{school.school_group.name})"
    else
      school.name
    end
  end

  def user_school_role(user)
    user.staff_role ? user.staff_role.title : user.role.humanize
  end

  def recommendations_scope_for(task_type)
    { 'action': :adult, 'activity': :pupil }[task_type]
  end

  def live_data_path
    ActivityCategory.live_data.any? ? activity_category_path(ActivityCategory.live_data.last) : activity_categories_path
  end

  def comparison_exists?(key)
    Rails.application.routes.url_helpers.respond_to?("comparisons_#{key}_index_path")
  end
end

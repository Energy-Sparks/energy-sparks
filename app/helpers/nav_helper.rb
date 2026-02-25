module NavHelper
  def navigation_image_link
    title = on_test? ? "Analytics version: #{Dashboard::VERSION}" : ''
    link_to '/home-page', class: 'navbar-brand', title: title do
      image = I18n.locale == :cy ? 'navigation-brand-transparent-cy.png' : 'navigation-brand-transparent-en.png'
      image_tag(image)
    end
  end

  def expand_class
    I18n.locale.to_s == 'en' ? 'lg' : 'xl'
  end

  def navbar_expand_class
    "navbar-expand-#{expand_class}"
  end

  def order_expand_class
    "order-#{expand_class}-12"
  end

  def navbar_hide_class
    "d-none d-#{expand_class}-inline-block"
  end

  def navbar_secondary_class
    controller.controller_path == 'pupils/schools' ? 'pupil' : 'adult'
  end

  def other_locales
    I18n.available_locales - [I18n.locale]
  end

  def link_to_locale(locale, **kwargs)
    secondary_presentation = request.params['secondary_presentation'] ? "/#{request.params['secondary_presentation']}" : ''
    link_to(locale_name_for(locale), url_for(subdomain: subdomain_for(locale), only_path: false, params: request.query_parameters) + secondary_presentation, **kwargs)
  end

  def conditional_application_container_classes
    " #{content_for(:container_classes)}" if content_for?(:container_classes)
  end

  def subdomain_for(locale)
    split_application_host = split_application_host_for(locale)
    return split_application_host.first if split_application_host&.size == 3
    return '' if locale.to_s == 'en'
    locale.to_s
  end

  def split_application_host_for(locale)
    case locale.to_s
    when 'en' then ENV['APPLICATION_HOST']&.split('.')
    when 'cy' then ENV['WELSH_APPLICATION_HOST']&.split('.')
    end
  end

  def locale_name_for(locale)
    case I18n.locale.to_s
    when 'cy' then 'English'
    when 'en' then 'Cymraeg'
    else I18n.t('name', locale: locale)
    end
  end

  def on_test?
    request.host.include?('test')
  end

  def show_admin_page_switch?(school)
    current_user && current_user.admin? && !school.data_enabled?
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

  def group_for_nav(user)
    if user
      if user.school_group
        user.school_group
      elsif user.school && user.school.school_group
        user.school.school_group
      end
    end
  end

  def header_nav_link(link_text, link_path, **kwargs)
    return if current_page?(link_path) # don't show link if already on page
    nav_class = 'btn '
    nav_class += " #{kwargs[:class]}" if kwargs[:class]
    link_to link_text, link_path, class: nav_class
  end

  def school_context?
    current_school && request.path.starts_with?('/schools/', '/pupils/schools/', '/admin/')
  end

  def school_group_context?
    # Historically we have not allowed /admin/school_group routes to have school group
    # context menus etc, so leaving as is for now. Something to consider for the future
    current_school_group && request.path.starts_with?('/school_groups/')
  end
end

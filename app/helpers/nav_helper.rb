module NavHelper
  def on_test_link
    if on_test?
      link_to 'Test', '/', class: 'nav-item px-1'
    end
  end

  def navbar_image_link
    title = on_test? ? "Analytics version: #{Dashboard::VERSION}" : ''
    link_to '/home-page', class: 'navbar-brand', title: title do
      image = I18n.locale == 'cy' ? 'nav-brand-transparent-cy.png' : 'nav-brand-transparent-en.png'
      image_tag(image, class: 'd-inline-block align-top')
    end
  end

  def navigation_image_link
    title = on_test? ? "Analytics version: #{Dashboard::VERSION}" : ''
    link_to '/home-page', class: 'navbar-brand', title: title do
      image = I18n.locale == 'cy' ? 'navigation-brand-transparent-cy.png' : 'navigation-brand-transparent-en.png'
      image_tag(image)
    end
  end

  def expand_class
    I18n.locale.to_s == 'en' ? 'lg' : 'xl'
  end

  def order_expand_class
    "order-#{expand_class}-12"
  end

  def navbar_expand_class
    "navbar-expand-#{expand_class}"
  end

  def other_locales
    I18n.available_locales - [I18n.locale]
  end

  # rotate to the next locale - not used at the moment
  def next_locale
    idx = I18n.available_locales.index(I18n.locale)
    I18n.available_locales.rotate(idx)[1]
  end

  def locale_switcher_buttons
    li_tags = other_locales.map {|locale| tag.li(link_to_locale(locale), class: 'nav-item pl-3 pr-3 nav-lozenge my-3px') }
    tag.ul(safe_join(li_tags), class: 'navbar-nav navbar-expand')
  end

  def link_to_locale(locale, **kwargs)
    secondary_presentation = request.params['secondary_presentation'] ? "/#{request.params['secondary_presentation']}" : ''
    link_to(locale_name_for(locale), url_for(subdomain: subdomain_for(locale), only_path: false, params: request.query_parameters) + secondary_presentation, **kwargs)
  end

  def sub_nav?
    @sub_nav == true
  end

  def nav_margin_classes
    if Flipper.enabled?(:navigation, current_user, current_user&.school_group)
      ' navigation-margin'
    else
      sub_nav? ? ' sub-nav-margin' : ' top-nav-margin'
    end
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

  def show_sub_nav?(school, hide_subnav)
    school.present? && school.id && hide_subnav.nil?
  end

  def show_partner_footer?(school)
    school.present? && school.id && school.all_partners.any?
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

  def header_nav_link(link_text, link_path)
    nav_class = 'btn btn-outline-dark rounded-pill font-weight-bold'
    nav_class += ' disabled' if current_page?(link_path)
    link_to link_text, link_path, class: nav_class
  end
end

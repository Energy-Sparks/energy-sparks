module NavHelper
  def navbar_image_link
    title = on_test? ? "Analytics version: #{Dashboard::VERSION}" : ''
    link_to '/home-page', class: 'navbar-brand', title: title do
      image_tag('nav-brand-transparent.png', class: "d-inline-block align-top")
    end
  end

  def locale_switcher_buttons
    locale_links = ['<ul class="navbar-nav">']
    (I18n.available_locales - [I18n.locale]).each do |locale|
      locale_links << '<li class="nav-item pl-3 pr-3 nav-lozenge nav-lozenge-little-padding">' + link_to_locale(locale) + '</li>'
    end
    locale_links << '</ul>'
    locale_links.join('').html_safe
  end

  def link_to_locale(locale)
    link_to(locale_name_for(locale), url_for(subdomain: subdomain_for(locale), only_path: false, params: request.query_parameters))
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
    I18n.t('name', locale: locale)
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
end

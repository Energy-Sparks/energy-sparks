module NavHelper
  def navbar_image_link
    title = on_test? ? "Analytics version: #{Dashboard::VERSION}" : ''
    link_to '/home-page', class: 'navbar-brand', title: title do
      image_tag('nav-brand-transparent.png', class: "d-inline-block align-top")
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
end

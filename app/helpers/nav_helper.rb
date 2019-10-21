module NavHelper
  def navbar_brand_link
    link_text = "Energy Sparks#{' (Test)' if on_test?}"
    title = on_test? ? "Analytics version: #{Dashboard::VERSION}" : ''
    link_to link_text, '/home-page', class: 'navbar-brand', title: title
  end

  def navbar_image_link
  end

  def on_test?
    request.host.include?('test')
  end

  def show_sub_nav?(school, hide_subnav)
    school.present? && school.id && hide_subnav.nil?
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
end

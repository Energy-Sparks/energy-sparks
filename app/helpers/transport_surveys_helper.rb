module TransportSurveysHelper
  def nav_item(link_text, link_path, opts = { disabled: false })
    content_tag(:li, class: "nav-item") do
      nav_class = 'nav-link'
      nav_class += ' active' if current_page?(link_path)
      nav_class += ' disabled' if opts[:disabled]
      link_to link_text, link_path, class: nav_class
    end
  end

  def header_nav_link(link_text, link_path)
    nav_class = 'btn btn-outline-dark rounded-pill font-weight-bold'
    nav_class += ' disabled' if current_page?(link_path)
    link_to link_text, link_path, class: nav_class
  end
end

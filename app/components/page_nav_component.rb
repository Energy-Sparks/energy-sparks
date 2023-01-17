# frozen_string_literal: true

class PageNavComponent < ViewComponent::Base
  renders_many :sections, ->(**args) do
    args[:options] = options
    SectionComponent.new(**args)
  end

  attr_reader :name, :bgcolor, :href, :options

  def initialize(name: "Menu", icon: 'home', bgcolor: nil, href: nil, options: {})
    @name = name
    @icon = icon
    @bgcolor = bgcolor
    @href = href
    @options = options
  end

  def icon
    @icon ? helpers.fa_icon(@icon) : ''
  end

  class SectionComponent < ViewComponent::Base
    renders_many :items, ->(**args) do
      args[:options] = options
      PageNavComponent::ItemComponent.new(**args)
    end

    attr_reader :bgcolor, :icon, :name, :visible, :options

    def initialize(name: nil, bgcolor: nil, icon: nil, visible: true, options: {})
      @name = name
      @bgcolor = bgcolor
      @icon = icon
      @visible = visible
      @options = options
    end

    def call
      args = { class: 'nav-link small toggler', 'data-toggle': 'collapse', 'data-target': "##{id}" }
      args[:style] = "background-color: #{bgcolor};" if bgcolor
      link_to(name_text.html_safe, "##{id}", args)
    end

    def id
      name.try(:parameterize)
    end

    def name_text
      output = icon ? "#{helpers.fa_icon(icon)} #{name}" : name
      output += content_tag(:span, helpers.toggler, class: 'pl-1 float-right')
      output
    end

    def render?
      visible && name
    end
  end

  class ItemComponent < ViewComponent::Base
    attr_reader :name, :href, :options

    def initialize(name:, href:, options: { match_controller: false })
      @name = name
      @href = href
      @options = options
    end

    def current_controller?(href)
      controller_path == Rails.application.routes.recognize_path(href)[:controller]
    end

    def call
      args = { class: "nav-link small" }
      if (options[:match_controller] && current_controller?(href)) || !options[:match_controller] && current_page?(href)
        args[:class] += ' current'
      end
      link_to(name, href, args)
    end

    def render?
      name
    end
  end

  class CollapseButton < ViewComponent::Base
    attr_reader :display

    def initialize(icon: 'bars', display: 'block')
      @icon = icon
      @display = display
    end

    def id
      'page-nav'
    end

    def icon
      @icon ? helpers.fa_icon(@icon) : ''
    end

    def call
      args = { class: "nav-link d-md-none d-#{display}", 'data-toggle': 'collapse', 'data-target': "##{id}" }
      link_to(icon, '', args)
    end
  end
end

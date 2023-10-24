# frozen_string_literal: true

class PageNavComponent < ViewComponent::Base
  renders_many :sections, ->(**args) do
    args[:options] = options
    SectionComponent.new(**args)
  end

  attr_reader :name, :icon, :classes, :href, :options

  def initialize(name: "Menu", icon: 'home', href:, classes: nil, options: {})
    @name = name
    @icon = icon
    @classes = classes
    @href = href
    @options = options
  end

  def header
    args = { class: 'nav-link border-bottom' }
    args[:class] += " #{classes}" if classes
    link_to(helpers.text_with_icon(name, icon), href, args)
  end

  class SectionComponent < ViewComponent::Base
    renders_many :items, ->(**args) do
      args[:match_controller] ||= options[:match_controller]
      PageNavComponent::ItemComponent.new(**args)
    end

    attr_reader :name, :icon, :visible, :classes, :options

    def initialize(name: nil, icon: nil, visible: true, classes: nil, options: {})
      @name = name
      @classes = classes
      @icon = icon
      @visible = visible
      @options = options
    end

    def id
      name.try(:parameterize)
    end

    def link_text
      helpers.text_with_icon(name, icon) + content_tag(:span, helpers.toggler, class: 'pl-1 float-right')
    end

    def render?
      name
    end

    def call
      args = { class: 'nav-link border-bottom small toggler', 'data-toggle': 'collapse', 'data-target': "##{id}" }
      args[:class] += " #{classes}" if classes
      link_to(link_text, "##{id}", args)
    end
  end

  class ItemComponent < ViewComponent::Base
    attr_reader :name, :href, :match_controller, :classes

    def initialize(name:, href:, classes: nil, match_controller: false)
      @name = name
      @href = href
      @match_controller = match_controller
      @classes = classes
    end

    def current_controller?(href)
      controller_path == Rails.application.routes.recognize_path(href)[:controller]
    end

    def current_item?(href)
      match_controller ? current_controller?(href) : current_page?(href)
    end

    def call
      args = { class: "nav-link border-bottom item small" }
      args[:class] += " #{classes}" if classes
      args[:class] += ' current' if current_item?(href)
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

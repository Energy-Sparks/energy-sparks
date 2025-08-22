# frozen_string_literal: true

class PageNavComponent < ViewComponent::Base
  renders_many :sections, ->(**args) do
    args[:options] ||= {}
    args[:options] = options.merge(args[:options])
    SectionComponent.new(**args)
  end

  attr_reader :name, :icon, :classes, :href, :options

  def initialize(name: 'Menu', icon: 'home', href:, classes: nil, options: {})
    @name = name
    @icon = icon
    @classes = classes
    @href = href
    @options = options
  end

  def header
    args = { class: 'nav-link header' }
    args[:class] += " #{classes}" if classes
    text = icon.nil? ? name : helpers.text_with_icon(name, icon)
    link_to(text, href, args)
  end

  class SectionComponent < ViewComponent::Base
    renders_many :items, ->(**args) do
      args[:match_controller] ||= options[:match_controller]
      PageNavComponent::ItemComponent.new(**args)
    end

    attr_reader :name, :icon, :visible, :classes, :options

    def initialize(id: nil, name: nil, icon: nil, visible: true, toggler: true, expanded: true, classes: nil, options: {})
      @id = id
      @name = name
      @classes = classes
      @icon = icon
      @visible = visible
      @options = options
      @toggler = toggler
      @expanded = expanded
    end

    def id
      @id || name.try(:parameterize)
    end

    def link_text
      helpers.text_with_icon(content_tag(:span, name, class: 'nav-text'), icon, class: 'fuel fa-fw') + content_tag(:span, helpers.toggler, class: 'nav-toggle-icons')
    end

    def expanded?
      @expanded
    end

    def render?
      name
    end

    def call
      if @toggler
        toggle_classes = 'nav-link toggler'
        toggle_classes += ' collapsed' unless expanded?
        args = { class: toggle_classes, 'data-toggle': 'collapse', 'data-target': "##{id}" }
      else
        args = { class: '' }
      end
      args[:class] += " #{classes}" if classes
      link_to(link_text, "##{id}", args)
    end
  end

  class ItemComponent < ViewComponent::Base
    attr_reader :name, :href, :match_controller, :classes

    def initialize(name:, href:, note: nil, classes: nil, match_controller: false)
      @name = name
      @note = note
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
      args = { class: 'nav-link item' }
      args[:class] += " #{classes}" if classes
      args[:class] += ' current' if current_item?(href)
      note = @note.nil? ? '' : content_tag(:span, @note, class: 'nav-toggle-icons')
      link_to(content_tag(:span, name, class: 'nav-text') + note, href, args)
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

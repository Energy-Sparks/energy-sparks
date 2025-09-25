# frozen_string_literal: true

class PageNavComponent < ApplicationComponent
  renders_many :sections, ->(**kwargs) do
    kwargs[:options] ||= {}
    kwargs[:options] = options.merge(kwargs[:options])
    SectionComponent.new(**kwargs)
  end

  attr_reader :name, :icon, :classes, :href, :options

  def initialize(name: 'Menu', icon: 'home', href:, classes: nil, options: {})
    super(classes: classes)
    @name = name
    @icon = icon
    @href = href
    @options = options
  end

  def header
    kwargs = { class: 'nav-link header' }
    kwargs[:class] += " #{classes}" if classes
    text = icon.nil? ? name : helpers.text_with_icon(name, icon)
    link_to(text, href, kwargs)
  end

  class SectionComponent < ViewComponent::Base
    renders_many :items, ->(**kwargs) do
      kwargs[:match_controller] ||= options[:match_controller]
      PageNavComponent::ItemComponent.new(**kwargs)
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

    def initialize(name:, href:, note: nil, match_controller: false, selected: false, classes: nil, **kwargs)
      @name = name
      @note = note
      @href = href
      @match_controller = match_controller
      @selected = selected
      @classes = classes
      @if = kwargs.fetch(:if) { true }
    end

    def current_controller?(href)
      controller_path == Rails.application.routes.recognize_path(href)[:controller]
    end

    def current_item?(href)
      match_controller ? current_controller?(href) : current_page?(href)
    end

    def call
      kwargs = { class: 'nav-link item' }
      kwargs[:class] += " #{classes}" if classes
      kwargs[:class] += ' current' if current_item?(href) || @selected
      note = @note.nil? ? '' : content_tag(:span, @note, class: 'nav-toggle-icons')
      link_to(content_tag(:span, name, class: 'nav-text') + note, href, kwargs)
    end

    def render?
      name && @if
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
      kwargs = { class: "nav-link d-md-none d-#{display}", 'data-toggle': 'collapse', 'data-target': "##{id}" }
      link_to(icon, '', kwargs)
    end
  end
end

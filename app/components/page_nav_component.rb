# frozen_string_literal: true

class PageNavComponent < ViewComponent::Base
  renders_many :sections, 'SectionComponent'

  attr_reader :name, :bgcolor, :href

  def initialize(name: "Menu", icon: 'home', bgcolor: nil, href: nil)
    @name = name
    @icon = icon
    @bgcolor = bgcolor
    @href = href
  end

  def icon
    @icon ? helpers.fa_icon(@icon) : ''
  end

  class SectionComponent < ViewComponent::Base
    renders_many :items, 'PageNavComponent::ItemComponent'

    attr_reader :bgcolor, :icon, :name, :visible

    def initialize(name: nil, bgcolor: nil, icon: nil, visible: true)
      @name = name
      @bgcolor = bgcolor
      @icon = icon
      @visible = visible
    end

    def call
      args = { class: 'small nav-link toggler', 'data-toggle': 'collapse', 'data-target': "##{id}" }
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
    attr_reader :name, :href

    def initialize(name:, href:)
      @name = name
      @href = href
    end

    def call
      args = { class: "small nav-link" }
      args[:class] += ' current' if current_page?(href)
      link_to(name, href, args)
    end

    def render?
      name
    end
  end
end

# frozen_string_literal: true

class PageNavComponent < ViewComponent::Base
  renders_many :sections, 'SectionComponent'

  attr_reader :name, :bgcolor

  def initialize(name: "Menu", icon: 'bars', bgcolor: '#232b49')
    @name = name
    @icon = icon
    @bgcolor = bgcolor
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
      args = { class: 'p-1', 'data-toggle': 'collapse', 'aria-expanded': "true" }
      args[:style] = "background-color: #{bgcolor};" if bgcolor
      output = link_to(name_text.html_safe, "##{id}", args)
      output
    end

    def id
      name.try(:parameterize)
    end

    def name_text
      icon ? "#{helpers.fa_icon(icon)} #{name}" : name
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
      args = { class: 'pl-4', style: "flex: 1" }
      content_tag(:li, link_to_unless_current(name, href), args)
    end

    def render?
      name
    end
  end
end

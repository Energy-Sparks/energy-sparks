# frozen_string_literal: true

class BreadcrumbsComponent < ViewComponent::Base
  renders_one :school, 'SchoolComponent'
  renders_many :items, 'ItemComponent'

  class SchoolComponent < ViewComponent::Base
    attr_accessor :selected, :school

    def initialize(school)
      @school = school
      @selected = false
    end

    def call
      out  = render(ItemComponent.new(name: t('components.breadcrumbs.schools'), href: schools_path))
      out += render(ItemComponent.new(name: school.school_group.name, href: school_group_path(school.school_group))) if school.school_group
      out += render(ItemComponent.new(name: school.name, href: school_path(school), selected: selected))
      out
    end
  end

  class ItemComponent < ViewComponent::Base
    attr_accessor :selected, :name, :href, :visible

    def initialize(name:, href: nil, selected: false, visible: true)
      @name = name
      @href = href
      @selected = selected
      @visible = visible
    end

    def call
      args = { class: 'breadcrumb-item' }
      if selected
        args[:class] += ' active'
        args[:"aria-current"] = 'page'
      end
      content_tag(:li, link_to_unless(selected || href.blank?, name, href), args)
    end

    def render?
      visible
    end
  end
end

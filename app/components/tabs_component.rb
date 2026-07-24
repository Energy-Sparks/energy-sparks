# frozen_string_literal: true

class TabsComponent < ApplicationComponent
  renders_many :tabs, 'TabComponent'

  def initialize(top_margin: true, **_kwargs)
    super
    @top_margin = top_margin
  end

  def before_render
    unless tabs.any?(&:active)
      tabs.first.active = true
    end
  end

  class TabComponent < ApplicationComponent
    attr_reader :name, :label
    attr_accessor :active

    def initialize(name:, label:, active: false, **_kwargs)
      super
      @name = name
      @label = label
      @active = active
    end

    def link_id
      "#{@name}-tab"
    end

    def call
      content
    end
  end
end

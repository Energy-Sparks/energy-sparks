# frozen_string_literal: true

class TabsComponent < ApplicationComponent
  renders_many :tabs, 'TabComponent'

  def initialize(top_margin: true, **_kwargs)
    super
    @top_margin = top_margin
  end

  def before_render
    tabs.first.active = true
  end

  class TabComponent < ApplicationComponent
    attr_reader :name, :label
    attr_accessor :active

    def initialize(name:, label:, **_kwargs)
      super
      @name = name
      @label = label
      @active = false
    end

    def link_id
      "#{@name}-tab"
    end

    def call
      content
    end
  end
end

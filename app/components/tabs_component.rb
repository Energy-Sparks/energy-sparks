# frozen_string_literal: true

class TabsComponent < ApplicationComponent
  renders_many :tabs, 'TabComponent'

  class TabComponent < ApplicationComponent
    attr_reader :name, :label
    attr_accessor :active

    def initialize(name:, label:)
      super()
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

  def initialize(id: nil, classes: '', top_margin: true)
    super(id:, classes:)
    @top_margin = top_margin
  end

  def before_render
    tabs.first.active = true
  end
end

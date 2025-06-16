# frozen_string_literal: true

class TabsComponent < ApplicationComponent
  renders_many :tabs, 'TabComponent'

  class TabComponent < ApplicationComponent
    attr_reader :name, :label, :active

    def initialize(name:, label:, active: false)
      super()
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

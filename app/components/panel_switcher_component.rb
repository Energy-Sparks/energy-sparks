# frozen_string_literal: true

class PanelSwitcherComponent < ViewComponent::Base
  attr_reader :title, :description, :classes, :id

  renders_many :panels, "PanelComponent"

  def initialize(title: nil, description: nil, selected: nil, classes: '', id: nil)
    @title = title
    @description = description
    @classes = classes
    @selected = selected
    @id = id
  end

  def selected
    @selected.blank? ? panels.first.name : @selected
  end

  class PanelComponent < ViewComponent::Base
    attr_accessor :label, :name

    def initialize(label:, name:)
      @name = name
      @label = label
    end

    def call
      content
    end
  end
end

# frozen_string_literal: true

class PanelSwitcherComponent < ApplicationComponent
  attr_reader :title, :description, :classes, :id, :name

  renders_many :panels, 'PanelComponent'

  def initialize(title: nil, description: nil, selected: nil, **_kwargs)
    super
    @title = title
    @description = description
    @selected = selected
    @name = title.try(:parameterize) || SecureRandom.uuid
  end

  def before_render
    # remove empty panels
    panels.delete_if do |panel|
      panel.to_s.blank? # need to_s to flush component output buffer early
    end
  end

  def selected
    @selected.blank? || !selected_panel_exists? ? panels.first.name : @selected
  end

  def render?
    panels.any?
  end

  private

  def selected_panel_exists?
    panels.map(&:name).include?(@selected)
  end

  class PanelComponent < ViewComponent::Base
    attr_reader :label, :name

    def initialize(label:, name:)
      @name = name
      @label = label
    end

    def call
      content
    end
  end
end

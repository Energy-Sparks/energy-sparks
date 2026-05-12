class TogglerDropdownComponent < ApplicationComponent
  include ApplicationHelper

  attr_reader :title, :hide

  def initialize(title: nil, hide: true, bg: 'light', **) # rubocop:disable Naming/MethodParameterName
    super(**)
    add_classes("bg-#{bg}")
    @title = title
    @hide = hide
  end

  def identifier
    @identifier ||= SecureRandom.hex
  end

  def render?
    content
  end
end

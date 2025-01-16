class TogglerDropdownComponent < ApplicationComponent
  include ApplicationHelper

  attr_reader :title, :hide

  def initialize(title: nil, hide: true, id: nil, classes: '')
    super(id: id, classes: classes)
    @title = title
    @hide = hide
  end

  def render?
    content
  end
end

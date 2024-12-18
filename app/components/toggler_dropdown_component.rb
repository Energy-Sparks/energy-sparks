class TogglerDropdownComponent < ApplicationComponent
  include ApplicationHelper

  attr_reader :title, :surround

  def initialize(title: nil, surround: true, id: nil, classes: '')
    super(id: id, classes: classes)
    @title = title
    @surround = surround
  end

  def render?
    content
  end
end

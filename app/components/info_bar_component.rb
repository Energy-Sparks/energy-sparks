# frozen_string_literal: true

class InfoBarComponent < ViewComponent::Base
  include ApplicationHelper
  attr_accessor :status, :title, :icon, :buttons, :style

  def initialize(status: :neutral, title:, icon: nil, buttons: nil, classes: nil, style: :normal)
    @status = status
    @title = title
    @icon = icon
    @buttons = buttons
    @classes = classes
    @style = style
  end

  def classes
    classes = " #{@classes}"
    classes += @style == :compact ? ' mb-3' : ' mb-4'
    classes
  end

  def base_columns
    icon ? 11 : 12
  end
end

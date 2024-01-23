# frozen_string_literal: true

class InfoBarComponent < ViewComponent::Base
  include ApplicationHelper
  attr_accessor :status, :title, :icon, :icon_cols, :buttons, :style

  def initialize(status: :neutral, title:, icon: nil, icon_cols: 1, buttons: nil, classes: nil, style: :normal)
    @status = status
    @title = title
    @icon = icon
    @icon_cols = icon_cols
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
    return 12 unless icon
    12 - icon_cols
  end
end

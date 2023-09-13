# frozen_string_literal: true

class InfoBarComponent < ViewComponent::Base
  attr_accessor :title, :icon, :buttons

  def initialize(title:, icon:, buttons:)
    @title = title
    @icon = icon
    @buttons = buttons
  end
end

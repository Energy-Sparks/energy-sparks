# frozen_string_literal: true

class InfoBarComponent < ViewComponent::Base
  include ApplicationHelper
  attr_accessor :status, :title, :icon, :buttons

  def initialize(status: :neutral, title:, icon:, buttons:)
    @status = status
    @title = title
    @icon = icon
    @buttons = buttons
  end
end

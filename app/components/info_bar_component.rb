# frozen_string_literal: true

class InfoBarComponent < ViewComponent::Base
  include ApplicationHelper
  attr_accessor :status, :title, :icon, :buttons

  def initialize(status: :neutral, title:, icon:, buttons:, classes: nil)
    @status = status
    @title = title
    @icon = icon
    @buttons = buttons
    @classes = classes
  end

  def classes
    @classes || ' p-4 mb-2'
  end
end

# frozen_string_literal: true

class NoticeComponent < ViewComponent::Base
  attr_reader :status, :classes, :link_name, :href

  def initialize(status:, classes: nil, link_name: nil, href: nil)
    @status = status
    @classes = classes
    @link_name = link_name
    @href = href
  end
end

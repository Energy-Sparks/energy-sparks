# frozen_string_literal: true

class NoticeComponent < ViewComponent::Base
  renders_one :link

  def initialize(status:, classes: nil, style: :normal)
    @status = status
    @classes = classes
    @style = style
    validate
  end

  def validate
    raise ArgumentError.new(self.class.status_error) unless self.class.statuses.include?(@status.to_sym)
  end

  def classes
    classes = " #{@status}"
    classes += @style == :compact ? ' p-3' : ' p-4'
    classes += " #{@classes}" if @classes
    classes
  end

  def render?
    content
  end

  def self.statuses
    [:positive, :negative, :neutral]
  end

  def self.status_error
    'Status must be: ' + self.statuses.to_sentence(last_word_connector: ' or ')
  end
end

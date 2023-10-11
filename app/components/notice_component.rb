# frozen_string_literal: true

class NoticeComponent < ViewComponent::Base
  renders_one :link

  def initialize(status:, classes: nil)
    @classes = classes
    @status = status
    validate
  end

  def validate
    raise ArgumentError, self.class.status_error unless self.class.statuses.include?(@status.to_sym)
  end

  def classes
    classes = " #{@status}"
    classes += " #{@classes}" if @classes
    classes
  end

  def render?
    content
  end

  def self.statuses
    %i[positive negative neutral]
  end

  def self.status_error
    'Status must be: ' + statuses.to_sentence(last_word_connector: ' or ')
  end
end

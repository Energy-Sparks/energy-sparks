# frozen_string_literal: true

class NoticeComponent < ApplicationComponent
  renders_one :link

  def initialize(status:, style: :normal, **_kwargs)
    super
    @status = status
    @style = style
    validate
    add_classes(status)
    add_classes(@style == :compact ? ' p-3' : ' p-4')
  end

  def validate
    raise ArgumentError.new(self.class.status_error) unless self.class.statuses.include?(@status.to_sym)
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

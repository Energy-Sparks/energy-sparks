# frozen_string_literal: true

# Promopts are coloured by a status, which can be:
# :none (grey?)
# :positive
# :negative
# :neutral (blue)

# Basic versions has:
# icon on left
# colour based on status, so a symbol or class?
#
#
#
# text via content
# link via slot
class PromptComponent < ApplicationComponent
  renders_one :link
  renders_one :title
  renders_one :pill

  attr_reader :icon, :style

  def initialize(id: nil, icon: nil, status: nil, style: :full, classes: '')
    super(id: id, classes: "#{status} #{classes}")
    @icon = icon
    @status = status
    @style = style
    validate
  end

  def render?
    content
  end

  def validate
    raise ArgumentError.new(self.class.status_error) unless @status.nil? || self.class.statuses.include?(@status.to_sym)
  end

  def self.statuses
    [:none, :positive, :negative, :neutral]
  end

  def self.status_error
    'Status must be: ' + self.statuses.to_sentence(last_word_connector: ' or ')
  end
end

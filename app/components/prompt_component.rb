# frozen_string_literal: true

# Prompts can be coloured by a status, which can be:
# :none (grey?)
# :positive
# :negative
# :neutral (grey)

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
  renders_one :content_action, ->(**kwargs) { Layout::Cards::ContentAction.new(**kwargs) }

  attr_reader :icon, :style, :fuel_type

  def initialize(id: nil, icon: nil, fuel_type: nil, status: nil, style: :full, classes: '', always_render: false)
    super(id: id, classes: "#{status} #{classes}")
    @icon = icon
    @fuel_type = fuel_type
    @status = status
    @style = style
    @always_render = always_render
    validate
  end

  def render_icon?
    @fuel_type || @icon
  end

  def render?
    content || content_action || @always_render
  end

  def validate
    raise ArgumentError.new(self.class.status_error) unless @status.nil? || self.class.statuses.include?(@status.to_sym)
  end

  def self.statuses
    %i[none positive negative neutral]
  end

  def self.status_error
    'Status must be: ' + statuses.to_sentence(last_word_connector: ' or ')
  end
end

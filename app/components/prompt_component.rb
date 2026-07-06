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

  STATUSES = %i[none positive negative neutral].freeze
  private_constant :STATUSES

  attr_reader :icon, :style, :fuel_type

  def initialize(icon: nil, fuel_type: nil, status: nil, style: :full, always_render: false, **_kwargs)
    super
    validate_inclusion(status: status, in: STATUSES) if status
    add_classes(status)
    @icon = icon
    @fuel_type = fuel_type
    @status = status
    @style = style
    @always_render = always_render
  end

  def render_icon?
    @fuel_type || @icon
  end

  def render?
    content || content_action || @always_render
  end
end

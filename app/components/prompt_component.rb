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

  attr_reader :icon, :image, :style, :fuel_type

  def initialize(icon: nil, image: nil, fuel_type: nil, status: nil, style: :full, always_render: false, **_kwargs)
    super
    validate_inclusion(status:, in: STATUSES) if status
    add_classes(status)
    @icon = icon
    @image = image
    @fuel_type = fuel_type
    @status = status
    @style = style
    @always_render = always_render
  end

  def render?
    content || content_action || @always_render
  end

  def self.statuses
    STATUSES
  end

  private

  def image?
    !!@image
  end

  def icon?
    @fuel_type || @icon
  end

  def media?
    icon? || image?
  end

  def media_cols
    'col-1' if media?
  end

  def main_cols
    'col-md-11' if media?
  end
end

class Elements::IconLabelComponent < ApplicationComponent
  def initialize(icon: nil, label: nil, fuel_type: nil, public_status: nil, icon_size: 'f7', icon_colour: nil, badge: :light, **_kwargs)
    super
    @icon = icon
    @label = label
    @fuel_type = fuel_type
    @public_status = public_status
    @icon_size = icon_size
    @icon_colour = icon_colour
    @badge = badge
  end

  def badge(text)
    if @badge
      render(Elements::BadgeComponent.new(style: @badge, classes: 'me-1')) { text }
    else
      text
    end
  end

  def label
    if @label
      @label
    elsif @fuel_type
      t(@fuel_type, scope: 'common')
    elsif @public_status
      t(@public_status, scope: 'schools.public_status')
    end
  end

  def icon
    @icon || @fuel_type || @public_status ? render(Elements::IconComponent.new(name: @icon, fuel_type: @fuel_type, public_status: @public_status, size: @icon_size, colour: @icon_colour, classes: 'pe-1')) : ''
  end

  def call
    badge(icon + ' ' + label)
  end
end

class Adjective
  ADJECTIVES = {
    #used to assess percentage differences, so 0.1..0.2 is 10-20% higher
    relative_to_1: {
      -Float::INFINITY..-0.3  => :significantly_below,
      -0.3..-0.1              => :below,
      -0.1..-0.05             => :just_below,
      -0.05..0.05             => :about,
      0.05..0.1               => :just_above,
      0.1..0.2                => :above,
      0.2..Float::INFINITY    => :significantly_above
    },
    simple_relative_to_1: {
      -Float::INFINITY..-0.05  => :below,
      -0.05..0.05              => :about,
      0.05..Float::INFINITY    => :above
    }
  }

  #assess where a value sits against a range of values, mapping it to an adjective.
  #pass in a symbol identifying one of the default defined ranges above
  #OR a custom hash which maps to one of the adjective symbols defined
  #in common.yml.
  def self.relative(value, range_to_adjective_map)
    range_to_adjective_map = ADJECTIVES[range_to_adjective_map] if range_to_adjective_map.is_a?(Symbol)
    found = range_to_adjective_map.keys.find { |range| value.between?(range.first, range.last) }
    I18nHelper.adjective(range_to_adjective_map[found])
  end

  def self.adjective_for(result, greater_than_value = 0.0)
    if result > greater_than_value
      I18nHelper.adjective('higher')
    else
      I18nHelper.adjective('lower')
    end
  end

  def self.adjective_for_change(change, up, no_change, down)
    if change < 0.0
      I18nHelper.adjective(down)
    elsif change == 0.0
      I18nHelper.adjective(no_change)
    else
      I18nHelper.adjective(up)
    end
  end

  def self.warm_weather_on_days_adjective(days)
    I18nHelper.adjective( warm_weather_on_days_rating(days)[:adjective] )
  end

  def self.warm_weather_on_days_rating(days)
    range = {
      0..6     => { adjective: :excellent,      rating_value: 10  },
      6..11    => { adjective: :good,           rating_value:  8  },
      12..16   => { adjective: :above_average,  rating_value:  4  },
      17..24   => { adjective: :poor,           rating_value:  2  },
      25..365  => { adjective: :very_poor,      rating_value:  0  }
    }

    range.select { |k, _v| k.cover?(days.to_i) }.values.first
  end

end
